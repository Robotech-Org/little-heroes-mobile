import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/pending_attendance_scan.dart';

class AttendanceUnifiedCard extends StatelessWidget {
  final List<PendingAttendanceScan> students;
  final Set<String> punchedOutStudentIds;

  /// Whether check-out controls (↪ icon + "Check Out All") should appear.
  final bool enablePunchOut;

  /// Optional — show a small "Discard" row during the punch-in phase.
  final VoidCallback? onDiscardPunchIn;

  final bool busy;
  final void Function(PendingAttendanceScan scan) onPunchOutStudent;
  final VoidCallback? onPunchOutAll;

  const AttendanceUnifiedCard({
    super.key,
    required this.students,
    required this.punchedOutStudentIds,
    required this.enablePunchOut,
    required this.busy,
    required this.onPunchOutStudent,
    required this.onPunchOutAll,
    this.onDiscardPunchIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final remaining = students
        .where((s) => !punchedOutStudentIds.contains(s.studentId))
        .length;
    final done = enablePunchOut && remaining == 0;

    // Count failed rows (server rejected them last time)
    final failedCount = students.where((s) => s.hasFailed).length;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: failedCount > 0
              ? colors.error.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.45),
          width: failedCount > 0 ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: failedCount > 0
                        ? colors.error.withValues(alpha: 0.12)
                        : colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    failedCount > 0
                        ? Icons.error_outline_rounded
                        : enablePunchOut
                        ? (done
                              ? Icons.check_circle_rounded
                              : Icons.logout_rounded)
                        : Icons.people_alt_rounded,
                    color: failedCount > 0
                        ? colors.error
                        : colors.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${students.length} student(s)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subtitle(
                          failedCount: failedCount,
                          enablePunchOut: enablePunchOut,
                          done: done,
                          remaining: remaining,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: failedCount > 0
                              ? colors.error
                              : (enablePunchOut && done
                                    ? AppColors.success
                                    : colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── "Check Out All" — only in punch-out phase, no failures ──
          if (enablePunchOut &&
              !done &&
              onPunchOutAll != null &&
              failedCount == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onPunchOutAll,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    'Check Out All ($remaining)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warningDark,
                    side: BorderSide(
                      color: AppColors.warningDark.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          // ── "Discard" — only in punch-in phase ────────
          if (!enablePunchOut && onDiscardPunchIn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onDiscardPunchIn,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text(
                    'Discard This Attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          // ── Divider ─────────────────────────────────
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),

          // ── Rows ────────────────────────────────────
          ...students.asMap().entries.map((entry) {
            final i = entry.key;
            final scan = entry.value;
            final isOut = punchedOutStudentIds.contains(scan.studentId);
            return _row(
              context: context,
              colors: colors,
              index: i + 1,
              scan: scan,
              isOut: isOut,
              showPunchOut: enablePunchOut,
              onTapOut: busy ? null : () => onPunchOutStudent(scan),
              isLast: i == students.length - 1,
            );
          }),
        ],
      ),
    );
  }

  String _subtitle({
    required int failedCount,
    required bool enablePunchOut,
    required bool done,
    required int remaining,
  }) {
    if (failedCount > 0) {
      return '$failedCount failed — fix the card and tap Save to retry';
    }
    if (enablePunchOut) {
      return done ? 'All checked out' : '$remaining still to check out';
    }
    return 'Ready to save';
  }

  Widget _row({
    required BuildContext context,
    required ColorScheme colors,
    required int index,
    required PendingAttendanceScan scan,
    required bool isOut,
    required bool showPunchOut,
    required VoidCallback? onTapOut,
    required bool isLast,
  }) {
    // ✗ if the last sync failed for this scan
    final failed = scan.hasFailed;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Number badge (red if failed)
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: failed
                      ? colors.error.withValues(alpha: 0.15)
                      : colors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: failed ? colors.error : colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card ID + failure hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scan.studentId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (failed)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          scan.failureReason!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Time
              Text(
                _fmtTime(scan.scannedAt),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),

              // ── Status icons ──
              if (failed)
                // ✗ for failed — must be retried or rescanned
                Icon(Icons.cancel_rounded, size: 20, color: colors.error)
              else ...[
                // ✓ punched in
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
                if (showPunchOut) ...[
                  const SizedBox(width: 6),
                  if (isOut)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: AppColors.success,
                    )
                  else
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'Check Out',
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: AppColors.warningDark,
                        ),
                        onPressed: onTapOut,
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
      ],
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
