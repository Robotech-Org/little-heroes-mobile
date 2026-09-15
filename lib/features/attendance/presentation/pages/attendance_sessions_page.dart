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
  List<AttendanceSession> _sessions = [];
  AttendanceSession? _active;
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final service = di.sl<AttendanceSessionService>();
    final sessions = await service.getPendingSessions();
    final active = await service.getActiveSession();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _active = active;
      _loading = false;
    });
  }

  Future<void> _finalizeActive() async {
    final service = di.sl<AttendanceSessionService>();
    final finalized = await service.finalizeActiveSession();
    if (!mounted) return;
    if (finalized != null) {
      SnackbarUtils.showSuccess(
        context,
        'Session finalized with ${finalized.scans.length} scans',
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

  int get _totalPendingScans =>
      _sessions.fold(0, (sum, s) => sum + s.scans.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Attendance Sessions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (_active != null)
                    _ActiveSessionCard(
                      session: _active!,
                      onFinalize: _finalizeActive,
                      onDiscard: _discardActive,
                    ),

                  if (_active == null && _sessions.isEmpty)
                    _emptyState(theme, colorScheme),

                  if (_sessions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pending sync '
                            '(${_sessions.length} session(s), '
                            '$_totalPendingScans scans)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._sessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SessionCard(session: s),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _sessions.isEmpty
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
                      _syncing
                          ? 'Syncing...'
                          : 'Sync $_totalPendingScans scan(s)',
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

  Widget _emptyState(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning student QR codes to begin a session.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// ACTIVE SESSION — uses AppColors.warning (the yellow accent)
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

    // Pick the accent from AppColors based on brightness
    // (warning yellow is bright, so we dim it slightly for light mode)
    final accent = isDark ? AppColors.primary : AppColors.primary;

    // Background — very subtle tint, tuned per mode
    final accentBg = isDark
        ? AppColors.primary.withValues(alpha: 0.10)
        : AppColors.warningLight;
    final accentBorder = isDark
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.warning.withValues(alpha: 0.55);

    // Inner panel — neutral surface
    final innerSurface = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : colorScheme.surface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.radio_button_checked_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Active session',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.warning : AppColors.warningDark,
                ),
              ),
              const Spacer(),
              Text(
                '${session.scans.length} scan(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.warning : AppColors.warningDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Device: ${session.deviceId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          Text(
            'Location: '
            '${session.deviceLatitude.toStringAsFixed(5)}, '
            '${session.deviceLongitude.toStringAsFixed(5)} '
            '(±${session.gpsAccuracyMeters.toStringAsFixed(1)}m)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 12),

          // Scanned list
          if (session.scans.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: innerSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No scans yet — scan a student to begin',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
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

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDiscard,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Discard'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: session.isEmpty ? null : onFinalize,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Finalize'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    // Yellow accent → black text reads better on both modes
                    foregroundColor: isDark ? AppColors.black : AppColors.black,
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
// PENDING SESSION — expandable list
// ═════════════════════════════════════════════════════════════
class _SessionCard extends StatelessWidget {
  final AttendanceSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
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
          iconColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          collapsedIconColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            '${session.scans.length} scan(s)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmt(session.startedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  'Device: ${session.deviceId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          children: session.scans.asMap().entries.map((entry) {
            return _ScanRow(index: entry.key + 1, scan: entry.value);
          }).toList(),
        ),
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
// SHARED ROW — one scanned student
// ═════════════════════════════════════════════════════════════
class _ScanRow extends StatelessWidget {
  final int index;
  final PendingAttendanceScan scan;

  const _ScanRow({required this.index, required this.scan});

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
