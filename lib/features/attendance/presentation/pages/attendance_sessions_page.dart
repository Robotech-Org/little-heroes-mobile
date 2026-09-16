import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/models/attendance_session.dart';
import '../../data/models/pending_attendance_scan.dart';
import '../../data/services/attendance_session_service.dart';
import '../../domain/usecases/sync_pending_sessions.dart';
import '../../../../injection_container.dart' as di;

class AttendanceSessionsPage extends StatefulWidget {
  const AttendanceSessionsPage({super.key});

  @override
  State<AttendanceSessionsPage> createState() => _AttendanceSessionsPageState();
}

class _AttendanceSessionsPageState extends State<AttendanceSessionsPage> {
  List<AttendanceSession> _allSessions = [];
  AttendanceSession? _active;
  bool _loading = true;
  bool _syncing = false;

  /// Student IDs already punched out — used to prevent duplicate punch-outs.
  Set<String> _punchedOutStudentIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ═════════════════════════════════════════════════════════════
  // LOAD — rebuild the punched-out set
  // ═════════════════════════════════════════════════════════════
  Future<void> _load() async {
    setState(() => _loading = true);
    final service = di.sl<AttendanceSessionService>();
    final sessions = await service.getAllSessions();
    final active = await service.getActiveSession();

    // Build the set of already-punched-out student IDs
    final punched = <String>{};
    for (final s in sessions) {
      if (s.logType == AttendanceLogType.punchOut) {
        for (final scan in s.scans) {
          punched.add(scan.studentId);
        }
      }
    }
    if (active != null && active.logType == AttendanceLogType.punchOut) {
      for (final scan in active.scans) {
        punched.add(scan.studentId);
      }
    }

    if (!mounted) return;
    setState(() {
      _allSessions = sessions;
      _active = active;
      _punchedOutStudentIds = punched;
      _loading = false;
    });
  }

  // ═════════════════════════════════════════════════════════════
  // FINALIZE / DISCARD ACTIVE
  // ═════════════════════════════════════════════════════════════
  Future<void> _finalizeActive() async {
    final service = di.sl<AttendanceSessionService>();
    final finalized = await service.finalizeActiveSession();
    if (!mounted) return;
    if (finalized != null) {
      final label = finalized.logType == AttendanceLogType.punchIn
          ? 'Punch IN'
          : 'Punch OUT';
      SnackbarUtils.showSuccess(
        context,
        '$label session finalized with ${finalized.scans.length} scan(s)',
      );
    } else {
      SnackbarUtils.showError(context, 'No active session to finalize');
    }
    await _load();
  }

  Future<void> _discardActive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard active session?'),
        content: const Text('All unsaved scans in this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await di.sl<AttendanceSessionService>().discardActiveSession();
    await _load();
  }

  // ═════════════════════════════════════════════════════════════
  // PUNCH OUT — SINGLE STUDENT
  // ═════════════════════════════════════════════════════════════
  Future<void> _punchOutStudent(
    AttendanceSession session,
    PendingAttendanceScan scan,
  ) async {
    if (_punchedOutStudentIds.contains(scan.studentId)) {
      SnackbarUtils.showError(
        context,
        '${scan.studentId} is already punched out',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Punch out ${scan.studentId}?'),
        content: const Text(
          'This student will be added to the next OUT batch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Punch Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final service = di.sl<AttendanceSessionService>();
    final existing = await service.getActiveSession();

    if (existing != null && existing.logType == AttendanceLogType.punchOut) {
      if (existing.scans.any((s) => s.studentId == scan.studentId)) {
        SnackbarUtils.showError(
          context,
          '${scan.studentId} is already in the OUT session',
        );
        await _load();
        return;
      }
      await service.addScan(
        PendingAttendanceScan(
          studentId: scan.studentId,
          qrPayload: scan.qrPayload,
          scannedAt: DateTime.now(),
        ),
      );
    } else {
      await service.startSession(
        logType: AttendanceLogType.punchOut,
        deviceId: session.deviceId,
        latitude: session.deviceLatitude,
        longitude: session.deviceLongitude,
        accuracyMeters: session.gpsAccuracyMeters,
      );
      await service.addScan(
        PendingAttendanceScan(
          studentId: scan.studentId,
          qrPayload: scan.qrPayload,
          scannedAt: DateTime.now(),
        ),
      );
    }

    if (!mounted) return;
    SnackbarUtils.showSuccess(
      context,
      '✓ ${scan.studentId} marked for punch-out',
    );
    await _load();
  }

  // ═════════════════════════════════════════════════════════════
  // PUNCH OUT — ALL REMAINING IN A SESSION
  // ═════════════════════════════════════════════════════════════
  Future<void> _punchOutAllStudents(AttendanceSession session) async {
    final remaining = session.scans
        .where((s) => !_punchedOutStudentIds.contains(s.studentId))
        .toList();

    if (remaining.isEmpty) {
      SnackbarUtils.showError(
        context,
        'All students in this session are already punched out',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Punch Out All Students?'),
        content: Text(
          'Punch out ${remaining.length} remaining student(s) from '
          '${_fmtDate(session.startedAt)}.\n\n'
          'This will be sent as one batch on the next sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Punch Out All'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final service = di.sl<AttendanceSessionService>();
    final existing = await service.getActiveSession();
    if (existing != null && existing.logType == AttendanceLogType.punchOut) {
      await service.finalizeActiveSession();
    }

    await service.startSession(
      logType: AttendanceLogType.punchOut,
      deviceId: session.deviceId,
      latitude: session.deviceLatitude,
      longitude: session.deviceLongitude,
      accuracyMeters: session.gpsAccuracyMeters,
    );

    final now = DateTime.now();
    for (final scan in remaining) {
      await service.addScan(
        PendingAttendanceScan(
          studentId: scan.studentId,
          qrPayload: scan.qrPayload,
          scannedAt: now,
        ),
      );
    }

    await service.finalizeActiveSession();

    if (!mounted) return;
    SnackbarUtils.showSuccess(
      context,
      '✓ ${remaining.length} student(s) marked for punch-out',
    );
    await _load();
  }

  // ═════════════════════════════════════════════════════════════
  // SYNC
  // ═════════════════════════════════════════════════════════════
  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      final summary = await di.sl<SyncPendingSessions>()();
      if (!mounted) return;

      if (summary.nothingToSync) {
        SnackbarUtils.showSuccess(context, 'Nothing to sync');
      } else if (summary.failed == 0) {
        SnackbarUtils.showSuccess(
          context,
          '${summary.synced} scan(s) synced successfully',
        );
      } else {
        SnackbarUtils.showError(
          context,
          '${summary.synced} synced • ${summary.failed} failed',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Sync failed: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    } finally {
      await _load();
      if (mounted) setState(() => _syncing = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CLEAR SENT — manual cleanup
  // ═════════════════════════════════════════════════════════════
  Future<void> _clearSentSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear sent sessions?'),
        content: const Text(
          'Removes sessions already synced to the server.\n'
          'The server keeps the data — this only cleans your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await di.sl<AttendanceSessionService>().clearSyncedSessions();
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Sent sessions cleared');
    await _load();
  }

  // ═════════════════════════════════════════════════════════════
  // Derived lists
  // ═════════════════════════════════════════════════════════════
  List<AttendanceSession> get _pendingInSessions => _allSessions
      .where((s) => s.logType == AttendanceLogType.punchIn && !s.synced)
      .toList();

  List<AttendanceSession> get _pendingOutSessions => _allSessions
      .where((s) => s.logType == AttendanceLogType.punchOut && !s.synced)
      .toList();

  List<AttendanceSession> get _syncedInSessions => _allSessions
      .where((s) => s.logType == AttendanceLogType.punchIn && s.synced)
      .toList();

  List<AttendanceSession> get _syncedOutSessions => _allSessions
      .where((s) => s.logType == AttendanceLogType.punchOut && s.synced)
      .toList();

  int get _pendingCount =>
      _pendingInSessions.fold(0, (sum, s) => sum + s.scans.length) +
      _pendingOutSessions.fold(0, (sum, s) => sum + s.scans.length);

  bool get _hasSentSessions =>
      _syncedInSessions.isNotEmpty || _syncedOutSessions.isNotEmpty;

  bool get _hasAnyPunchIn =>
      _pendingInSessions.isNotEmpty || _syncedInSessions.isNotEmpty;

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Attendance Sessions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
          if (_hasSentSessions)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              onPressed: _clearSentSessions,
              tooltip: 'Clear sent sessions',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  // ── ACTIVE SESSION ──────────────────────
                  if (_active != null) ...[
                    _ActiveSessionCard(
                      session: _active!,
                      onFinalize: _finalizeActive,
                      onDiscard: _discardActive,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── EMPTY ───────────────────────────────
                  if (_active == null && _allSessions.isEmpty)
                    _emptyState(theme, colorScheme),

                  // ── PUNCH-IN SESSIONS (pending + synced) ─
                  if (_hasAnyPunchIn) ...[
                    _sectionHeader(
                      theme,
                      colorScheme,
                      icon: Icons.login_rounded,
                      title: 'Punch-In Sessions',
                      subtitle:
                          '${_pendingInSessions.length + _syncedInSessions.length} '
                          'session(s) · tap a student to punch out',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    ..._pendingInSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionCard(
                          session: s,
                          punchedOutStudentIds: _punchedOutStudentIds,
                          onPunchOutStudent: (scan) =>
                              _punchOutStudent(s, scan),
                          onPunchOutAll: () => _punchOutAllStudents(s),
                        ),
                      ),
                    ),
                    ..._syncedInSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionCard(
                          session: s,
                          punchedOutStudentIds: _punchedOutStudentIds,
                          onPunchOutStudent: (scan) =>
                              _punchOutStudent(s, scan),
                          onPunchOutAll: () => _punchOutAllStudents(s),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── PENDING PUNCH-OUT BATCHES ───────────
                  if (_pendingOutSessions.isNotEmpty) ...[
                    _sectionHeader(
                      theme,
                      colorScheme,
                      icon: Icons.pending_actions_rounded,
                      title: 'Ready to Sync',
                      subtitle:
                          '${_pendingOutSessions.fold<int>(0, (sum, s) => sum + s.scans.length)} '
                          'punch-out(s) queued',
                      color: AppColors.warningDark,
                    ),
                    const SizedBox(height: 10),
                    ..._pendingOutSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionCard(
                          session: s,
                          punchedOutStudentIds: _punchedOutStudentIds,
                          onPunchOutStudent: null,
                          onPunchOutAll: null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── SENT HISTORY ────────────────────────
                  if (_syncedOutSessions.isNotEmpty) ...[
                    _sectionHeader(
                      theme,
                      colorScheme,
                      icon: Icons.cloud_done_rounded,
                      title: 'Sent',
                      subtitle:
                          '${_syncedOutSessions.length} batch(es) already on the server',
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    ..._syncedOutSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SessionCard(
                          session: s,
                          punchedOutStudentIds: _punchedOutStudentIds,
                          onPunchOutStudent: null,
                          onPunchOutAll: null,
                          dimmed: true,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _pendingCount == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _syncing ? null : _sync,
                    icon: _syncing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(
                      _syncing ? 'Syncing...' : 'Sync $_pendingCount scan(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // Section header
  // ═════════════════════════════════════════════════════════════
  Widget _sectionHeader(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 48,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No sessions yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Scan student QR codes from the home screen\nto record attendance.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}

// ═════════════════════════════════════════════════════════════
// ACTIVE SESSION CARD
// ═════════════════════════════════════════════════════════════
class _ActiveSessionCard extends StatelessWidget {
  final AttendanceSession session;
  final VoidCallback onFinalize;
  final VoidCallback onDiscard;

  const _ActiveSessionCard({
    required this.session,
    required this.onFinalize,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isIn = session.logType == AttendanceLogType.punchIn;
    final accent = isIn ? AppColors.success : AppColors.warningDark;
    final accentBg = accent.withValues(alpha: isDark ? 0.12 : 0.08);
    final accentBorder = accent.withValues(alpha: 0.40);

    final innerSurface = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.6)
        : AppColors.lightSurface.withValues(alpha: 0.7);

    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBorder, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIn ? Icons.login_rounded : Icons.logout_rounded,
                      color: accent,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isIn ? 'PUNCH IN' : 'PUNCH OUT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // const Spacer(),
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 10,
              //     vertical: 4,
              //   ),
              //   decoration: BoxDecoration(
              //     color: colorScheme.primary.withValues(alpha: 0.12),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Text(
              //     '${session.scans.length}',
              //     style: theme.textTheme.bodySmall?.copyWith(
              //       fontWeight: FontWeight.w800,
              //       color: colorScheme.primary,
              //     ),
              //   ),
              // ),
            ],
          ),
          // const SizedBox(height: 12),

          // Text(
          //   'Active session',
          //   style: theme.textTheme.titleMedium?.copyWith(
          //     fontWeight: FontWeight.w800,
          //     color: primaryText,
          //   ),
          // ),
          // const SizedBox(height: 4),
          // Row(
          //   children: [
          //     Icon(Icons.smartphone_rounded, size: 12, color: secondaryText),
          //     const SizedBox(width: 4),
          //     Expanded(
          //       child: Text(
          //         session.deviceId,
          //         style: theme.textTheme.bodySmall?.copyWith(
          //           color: secondaryText,
          //           fontSize: 11,
          //           fontFamily: 'monospace',
          //         ),
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 2),
          // Row(
          //   children: [
          //     Icon(Icons.location_on_rounded, size: 12, color: secondaryText),
          //     const SizedBox(width: 4),
          //     Expanded(
          //       child: Text(
          //         '${session.deviceLatitude.toStringAsFixed(5)}, '
          //         '${session.deviceLongitude.toStringAsFixed(5)} '
          //         '(±${session.gpsAccuracyMeters.toStringAsFixed(1)}m)',
          //         style: theme.textTheme.bodySmall?.copyWith(
          //           color: secondaryText,
          //           fontSize: 11,
          //           fontFamily: 'monospace',
          //         ),
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 14),
          if (session.scans.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: innerSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No scans yet — scan a student to begin',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryText,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: innerSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: session.scans.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  itemBuilder: (_, index) {
                    final scan = session.scans[index];
                    return _ScanRow(index: index + 1, scan: scan);
                  },
                ),
              ),
            ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDiscard,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: session.isEmpty ? null : onFinalize,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text(
                    'Finalize',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PENDING / SENT SESSION CARD
// ═════════════════════════════════════════════════════════════
class _SessionCard extends StatelessWidget {
  final AttendanceSession session;
  final Set<String> punchedOutStudentIds;
  final void Function(PendingAttendanceScan scan)? onPunchOutStudent;
  final VoidCallback? onPunchOutAll;
  final bool dimmed;

  const _SessionCard({
    required this.session,
    required this.punchedOutStudentIds,
    required this.onPunchOutStudent,
    required this.onPunchOutAll,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isIn = session.logType == AttendanceLogType.punchIn;
    final accent = isIn ? AppColors.success : AppColors.warningDark;

    final remainingCount = isIn
        ? session.scans
              .where((s) => !punchedOutStudentIds.contains(s.studentId))
              .length
        : 0;
    final punchedCount = isIn ? session.scans.length - remainingCount : 0;

    final allPunchedOut = isIn && remainingCount == 0;
    final showPunchOutAll = onPunchOutAll != null && isIn && !allPunchedOut;
    final showActions = onPunchOutStudent != null;

    return Opacity(
      opacity: dimmed ? 0.75 : 1.0,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIn ? Icons.login_rounded : Icons.logout_rounded,
                color: accent,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    isIn
                        ? 'Punch IN · ${session.scans.length}'
                        : 'Punch OUT · ${session.scans.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _statusChip(
                  theme,
                  session.synced ? 'Sent' : 'Pending',
                  session.synced ? AppColors.success : AppColors.warningDark,
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmt(session.startedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (isIn) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Punched: $punchedCount · Remaining: $remainingCount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: remainingCount == 0
                            ? AppColors.success
                            : AppColors.warningDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            children: [
              // Punch Out All button
              if (showPunchOutAll) ...[
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onPunchOutAll,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      'Punch Out All ($remainingCount remaining)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warningDark,
                      side: BorderSide(
                        color: AppColors.warningDark.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // All-punched-out banner
              if (allPunchedOut)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All students in this session are punched out',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Scanned students list
              ...session.scans.asMap().entries.map((entry) {
                final scan = entry.value;
                final alreadyOut = punchedOutStudentIds.contains(
                  scan.studentId,
                );

                return _ScanRow(
                  index: entry.key + 1,
                  scan: scan,
                  trailing: showActions && isIn
                      ? (alreadyOut
                            ? const _PunchedOutBadge()
                            : IconButton(
                                tooltip: 'Punch Out',
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.warningDark,
                                ),
                                onPressed: () => onPunchOutStudent!(scan),
                              ))
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 9.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} $h:$m';
  }
}

// ═════════════════════════════════════════════════════════════
// PUNCHED OUT BADGE
// ═════════════════════════════════════════════════════════════
class _PunchedOutBadge extends StatelessWidget {
  const _PunchedOutBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_rounded, size: 12, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'OUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// SCAN ROW
// ═════════════════════════════════════════════════════════════
class _ScanRow extends StatelessWidget {
  final int index;
  final PendingAttendanceScan scan;
  final Widget? trailing;

  const _ScanRow({required this.index, required this.scan, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$index',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              scan.studentId,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: primaryTextColor,
              ),
            ),
          ),
          Text(
            _fmtTime(scan.scannedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryTextColor,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
