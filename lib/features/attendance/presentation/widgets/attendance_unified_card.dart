// import 'package:flutter/material.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../data/models/pending_attendance_scan.dart';

// class AttendanceUnifiedCard extends StatelessWidget {
//   final List<PendingAttendanceScan> students;
//   final Set<String> punchedOutStudentIds;
//   final bool busy;
//   final void Function(PendingAttendanceScan scan) onPunchOutStudent;
//   final VoidCallback? onPunchOutAll;

//   const AttendanceUnifiedCard({
//     super.key,
//     required this.students,
//     required this.punchedOutStudentIds,
//     required this.busy,
//     required this.onPunchOutStudent,
//     required this.onPunchOutAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     final remaining = students
//         .where((s) => !punchedOutStudentIds.contains(s.studentId))
//         .length;
//     final done = remaining == 0;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: colors.outlineVariant.withValues(alpha: 0.45),
//         ),
//       ),
//       child: Column(
//         children: [
//           // ── Header ──────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: colors.primaryContainer,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     done
//                         ? Icons.check_circle_rounded
//                         : Icons.people_alt_rounded,
//                     color: colors.onPrimaryContainer,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${students.length} student(s)',
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         done
//                             ? 'All checked out'
//                             : '$remaining still to check out',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: done
//                               ? AppColors.success
//                               : colors.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Punch Out All ────────────────────────────
//           if (!done && onPunchOutAll != null)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 42,
//                 child: OutlinedButton.icon(
//                   onPressed: busy ? null : onPunchOutAll,
//                   icon: const Icon(Icons.logout_rounded, size: 18),
//                   label: Text(
//                     'Check Out All ($remaining)',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13.5,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.warningDark,
//                     side: BorderSide(
//                       color: AppColors.warningDark.withValues(alpha: 0.5),
//                       width: 1.2,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // ── Divider ──────────────────────────────────
//           Divider(
//             height: 1,
//             color: colors.outlineVariant.withValues(alpha: 0.35),
//           ),

//           // ── Rows ─────────────────────────────────────
//           ...students.asMap().entries.map((entry) {
//             final i = entry.key;
//             final scan = entry.value;
//             final isOut = punchedOutStudentIds.contains(scan.studentId);
//             return _row(
//               context: context,
//               theme: theme,
//               colors: colors,
//               index: i + 1,
//               scan: scan,
//               isOut: isOut,
//               onTapOut: busy ? null : () => onPunchOutStudent(scan),
//               isLast: i == students.length - 1,
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _row({
//     required BuildContext context,
//     required ThemeData theme,
//     required ColorScheme colors,
//     required int index,
//     required PendingAttendanceScan scan,
//     required bool isOut,
//     required VoidCallback? onTapOut,
//     required bool isLast,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(
//             children: [
//               // Number badge
//               Container(
//                 width: 28,
//                 height: 28,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: colors.primaryContainer.withValues(alpha: 0.6),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '$index',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w800,
//                     color: colors.onPrimaryContainer,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),

//               // Student ID
//               Expanded(
//                 child: Text(
//                   scan.studentId,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ),

//               // Time
//               Text(
//                 _fmtTime(scan.scannedAt),
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontFamily: 'monospace',
//                   color: colors.onSurfaceVariant,
//                 ),
//               ),
//               const SizedBox(width: 12),

//               // In-check (always present in this list)
//               const Icon(
//                 Icons.check_circle_rounded,
//                 size: 20,
//                 color: AppColors.success,
//               ),
//               const SizedBox(width: 6),

//               // Out-check OR tappable logout
//               if (isOut)
//                 const Icon(
//                   Icons.check_circle_rounded,
//                   size: 20,
//                   color: AppColors.success,
//                 )
//               else
//                 SizedBox(
//                   width: 30,
//                   height: 30,
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     tooltip: 'Check Out',
//                     icon: const Icon(
//                       Icons.logout_rounded,
//                       size: 20,
//                       color: AppColors.warningDark,
//                     ),
//                     onPressed: onTapOut,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (!isLast)
//           Divider(
//             height: 1,
//             indent: 56,
//             endIndent: 16,
//             color: colors.outlineVariant.withValues(alpha: 0.25),
//           ),
//       ],
//     );
//   }

//   String _fmtTime(DateTime dt) {
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }
// }

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

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
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
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    enablePunchOut
                        ? (done
                              ? Icons.check_circle_rounded
                              : Icons.logout_rounded)
                        : Icons.people_alt_rounded,
                    color: colors.onPrimaryContainer,
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
                        enablePunchOut
                            ? (done
                                  ? 'All checked out'
                                  : '$remaining still to check out')
                            : 'Ready to save',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: enablePunchOut && done
                              ? AppColors.success
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── "Check Out All" — only in punch-out phase ──
          if (enablePunchOut && !done && onPunchOutAll != null)
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Number
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card ID
              Expanded(
                child: Text(
                  scan.studentId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
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

              // Always: punched-in check
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.success,
              ),

              // Punch-out indicator (only in punch-out phase)
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
