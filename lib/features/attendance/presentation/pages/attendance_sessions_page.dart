import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/models/attendance_session.dart';
import '../../data/models/pending_attendance_scan.dart';
import '../../data/services/attendance_session_service.dart';
import '../../domain/usecases/sync_pending_sessions.dart';
import '../../../../injection_container.dart' as di;

import '../widgets/attendance_empty_state.dart';
import '../widgets/attendance_unified_card.dart';

class AttendanceSessionsPage extends StatefulWidget {
  const AttendanceSessionsPage({super.key});

  @override
  State<AttendanceSessionsPage> createState() => _AttendanceSessionsPageState();
}

class _AttendanceSessionsPageState extends State<AttendanceSessionsPage> {
  // ── Raw data ──────────────────────────────────────────
  List<AttendanceSession> _todaySessions = [];
  AttendanceSession? _active;

  /// Flattened, deduplicated roster — the single source of truth.
  List<PendingAttendanceScan> _roster = [];

  /// Students already checked out today.
  Set<String> _punchedOutStudentIds = {};

  /// Session that carries the device/GPS metadata for this day.
  AttendanceSession? _sourceSession;

  // ── UI state ──────────────────────────────────────────
  bool _loading = true;
  bool _saving = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ═════════════════════════════════════════════════════════════
  // LOAD
  // ═════════════════════════════════════════════════════════════
  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    try {
      final service = di.sl<AttendanceSessionService>();
      final sessions = await service.getTodaySessions();
      final active = await service.getActiveSession();

      final rosterMap = <String, PendingAttendanceScan>{};
      final punched = <String>{};
      AttendanceSession? source;

      for (final s in sessions) {
        if (s.logType == AttendanceLogType.punchIn) {
          source ??= s;
          for (final scan in s.scans) {
            rosterMap.putIfAbsent(scan.studentId, () => scan);
          }
        }
      }
      for (final s in sessions) {
        if (s.logType == AttendanceLogType.punchOut) {
          for (final scan in s.scans) {
            punched.add(scan.studentId);
          }
        }
      }

      if (active != null) {
        if (active.logType == AttendanceLogType.punchIn) {
          source ??= active;
          for (final scan in active.scans) {
            rosterMap.putIfAbsent(scan.studentId, () => scan);
          }
        } else {
          for (final scan in active.scans) {
            punched.add(scan.studentId);
          }
        }
      }

      final roster = rosterMap.values.toList()
        ..sort((a, b) => a.scannedAt.compareTo(b.scannedAt));

      if (!mounted) return;

      setState(() {
        _todaySessions = sessions;
        _active = active;
        _sourceSession = source;
        _roster = roster;
        _punchedOutStudentIds = punched;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      SnackbarUtils.showError(
        context,
        'Unable to load attendance. Please try again.',
      );
    }
  }

  // ═════════════════════════════════════════════════════════════
  // Derived — the whole phase machine in three flags
  // ═════════════════════════════════════════════════════════════

  /// True when there's an unsaved punch-in session in progress.
  bool get _isPunchInPhase {
    // Active session = still scanning punch-ins
    if (_active != null && _active!.logType == AttendanceLogType.punchIn) {
      return true;
    }
    // Unsaved punch-in sessions exist
    return _todaySessions.any(
      (s) => s.logType == AttendanceLogType.punchIn && !s.synced,
    );
  }

  /// True when the punch-in batch has been saved and we're on punch-out.
  bool get _isPunchOutPhase {
    if (_isPunchInPhase) return false;
    return _roster.isNotEmpty;
  }

  bool get _allPunchedOut =>
      _roster.isNotEmpty && _punchedOutStudentIds.length >= _roster.length;

  int get _remainingStudents {
    final r = _roster.length - _punchedOutStudentIds.length;
    return r > 0 ? r : 0;
  }

  int get _pendingPunchInCount {
    var count = 0;
    for (final s in _todaySessions) {
      if (!s.synced && s.logType == AttendanceLogType.punchIn) {
        count += s.scans.length;
      }
    }
    if (_active != null &&
        _active!.logType == AttendanceLogType.punchIn &&
        !_active!.synced) {
      count += _active!.scans.length;
    }
    return count;
  }

  int get _pendingPunchOutCount {
    var count = 0;
    for (final s in _todaySessions) {
      if (!s.synced && s.logType == AttendanceLogType.punchOut) {
        count += s.scans.length;
      }
    }
    return count;
  }

  int get _pendingTotal => _pendingPunchInCount + _pendingPunchOutCount;

  // ═════════════════════════════════════════════════════════════
  // SAVE ATTENDANCE (works for both phases)
  // ═════════════════════════════════════════════════════════════
  Future<void> _saveAttendance() async {
    if (_saving || _pendingTotal == 0) return;

    setState(() => _busy = true);

    try {
      // If a session is still active, close it first so it can be synced
      if (_active != null) {
        await di.sl<AttendanceSessionService>().finalizeActiveSession();
        await _load();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }

    setState(() => _saving = true);
    try {
      final summary = await di.sl<SyncPendingSessions>()();
      if (!mounted) return;

      if (summary.nothingToSync) {
        SnackbarUtils.showSuccess(context, 'Attendance is already up to date.');
      } else if (summary.failed == 0) {
        SnackbarUtils.showSuccess(
          context,
          '${summary.synced} record(s) saved.',
        );
      } else {
        SnackbarUtils.showError(
          context,
          '${summary.synced} saved • ${summary.failed} failed',
        );
      }
    } catch (_) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Could not save attendance. Please try again.',
        );
      }
    } finally {
      await _load();
      if (mounted) setState(() => _saving = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // DISCARD PUNCH-IN SESSION
  // ═════════════════════════════════════════════════════════════
  Future<void> _discardActive() async {
    final active = _active;
    if (active == null) return;

    final confirmed = await _showConfirm(
      icon: Icons.delete_outline_rounded,
      title: 'Cancel attendance?',
      message:
          'The ${active.scans.length} scanned student(s) will be removed from '
          'this unfinished attendance.',
      cancelText: 'Keep',
      confirmText: 'Cancel Attendance',
      color: Theme.of(context).colorScheme.error,
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await di.sl<AttendanceSessionService>().discardActiveSession();
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CHECK OUT — one student
  // ═════════════════════════════════════════════════════════════
  Future<void> _punchOutStudent(PendingAttendanceScan scan) async {
    if (_busy) return;
    if (_punchedOutStudentIds.contains(scan.studentId)) {
      SnackbarUtils.showError(context, 'This student has already checked out.');
      return;
    }

    final source = _sourceSession;
    if (source == null) {
      SnackbarUtils.showError(context, 'No attendance session found.');
      return;
    }

    final confirmed = await _showConfirm(
      icon: Icons.logout_rounded,
      title: 'Check out student?',
      message: 'Student ${scan.studentId} will be marked as checked out.',
      cancelText: 'Cancel',
      confirmText: 'Check Out',
      color: AppColors.warningDark,
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final service = di.sl<AttendanceSessionService>();
      await _ensurePunchOutSessionOpen(source);
      await service.addScan(
        PendingAttendanceScan(
          studentId: scan.studentId,
          qrPayload: scan.qrPayload,
          scannedAt: DateTime.now(),
        ),
      );
      await service.finalizeActiveSession();

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'Student checked out successfully.');
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CHECK OUT — everyone remaining
  // ═════════════════════════════════════════════════════════════
  Future<void> _punchOutAll() async {
    if (_busy) return;

    final remaining = _roster
        .where((s) => !_punchedOutStudentIds.contains(s.studentId))
        .toList();
    if (remaining.isEmpty) {
      SnackbarUtils.showError(
        context,
        'All students have already checked out.',
      );
      return;
    }

    final source = _sourceSession;
    if (source == null) {
      SnackbarUtils.showError(context, 'No attendance session found.');
      return;
    }

    final confirmed = await _showConfirm(
      icon: Icons.groups_rounded,
      title: 'Check out everyone?',
      message: '${remaining.length} student(s) will be marked as checked out.',
      cancelText: 'Cancel',
      confirmText: 'Check Out All',
      color: AppColors.warningDark,
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final service = di.sl<AttendanceSessionService>();
      await _ensurePunchOutSessionOpen(source);

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
        '${remaining.length} student(s) checked out.',
      );
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _ensurePunchOutSessionOpen(AttendanceSession source) async {
    final service = di.sl<AttendanceSessionService>();
    final existing = await service.getActiveSession();
    if (existing != null) {
      await service.finalizeActiveSession();
    }
    await service.startSession(
      logType: AttendanceLogType.punchOut,
      deviceId: source.deviceId,
      latitude: source.deviceLatitude,
      longitude: source.deviceLongitude,
      accuracyMeters: source.gpsAccuracyMeters,
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DEBUG — clear all
  // ═════════════════════════════════════════════════════════════
  Future<void> _clearAllLocalAttendance() async {
    if (_busy) return;

    final confirmed = await _showConfirm(
      icon: Icons.delete_sweep_rounded,
      title: 'Clear all attendance data?',
      message:
          'This will delete every locally stored session.\n'
          'Server data is not affected.',
      cancelText: 'Cancel',
      confirmText: 'Clear All',
      color: Theme.of(context).colorScheme.error,
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await di.sl<AttendanceSessionService>().clearAll();
      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'All local attendance data cleared.');
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // Dialog helper
  // ═════════════════════════════════════════════════════════════
  Future<bool?> _showConfirm({
    required IconData icon,
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
    required Color color,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _FriendlyDialog(
        icon: icon,
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        color: color,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear all local attendance',
            onPressed: _busy ? null : _clearAllLocalAttendance,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy || _saving ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                children: [
                  // ── Phase banner (small, single line) ──
                  if (_roster.isNotEmpty)
                    _PhaseBanner(
                      isPunchInPhase: _isPunchInPhase,
                      total: _roster.length,
                      checkedOut: _punchedOutStudentIds.length,
                    ),

                  if (_roster.isNotEmpty) const SizedBox(height: 12),

                  // ── Single unified list ───────────────
                  if (_roster.isNotEmpty)
                    AttendanceUnifiedCard(
                      students: _roster,
                      punchedOutStudentIds: _punchedOutStudentIds,
                      // Only show punch-out controls after save
                      enablePunchOut: !_isPunchInPhase,
                      // Discard is only meaningful in the punch-in phase
                      onDiscardPunchIn: _isPunchInPhase && _active != null
                          ? _discardActive
                          : null,
                      busy: _busy || _saving,
                      onPunchOutStudent: _punchOutStudent,
                      onPunchOutAll: _allPunchedOut ? null : _punchOutAll,
                    ),

                  // ── Empty state ───────────────────────
                  if (_roster.isEmpty) ...[
                    const SizedBox(height: 24),
                    const AttendanceEmptyState(),
                  ],
                ],
              ),
            ),

      // ── Bottom: single Save Attendance action ─────────
      bottomNavigationBar: _pendingTotal == 0
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      offset: const Offset(0, -4),
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _saving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colors.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Save Attendance ($_pendingTotal)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PHASE BANNER
// ═════════════════════════════════════════════════════════════
class _PhaseBanner extends StatelessWidget {
  final bool isPunchInPhase;
  final int total;
  final int checkedOut;

  const _PhaseBanner({
    required this.isPunchInPhase,
    required this.total,
    required this.checkedOut,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isPunchInPhase ? AppColors.success : AppColors.warningDark;
    final remaining = total - checkedOut;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(
            isPunchInPhase
                ? Icons.qr_code_scanner_rounded
                : Icons.logout_rounded,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPunchInPhase ? 'Check-In Phase' : 'Check-Out Phase',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: accent,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPunchInPhase
                      ? '$total student(s) scanned · Tap Save to finish'
                      : '$remaining of $total still to check out',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// FRIENDLY CONFIRMATION DIALOG
// ═════════════════════════════════════════════════════════════
class _FriendlyDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color color;

  const _FriendlyDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.45,
          fontSize: 14,
          color: colors.onSurfaceVariant,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(cancelText),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(confirmText, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
