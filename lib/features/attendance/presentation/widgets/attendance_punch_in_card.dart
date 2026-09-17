// import 'package:flutter/material.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../data/models/attendance_session.dart';
// import '../../data/models/pending_attendance_scan.dart';
// import 'attendance_out_badge.dart';
// import 'attendance_scan_row.dart';
// import 'attendance_status_chip.dart';

// class AttendancePunchInCard extends StatelessWidget {
//   final AttendanceSession session;
//   final Set<String> punchedOutStudentIds;
//   final bool busy;
//   final void Function(PendingAttendanceScan scan) onPunchOutStudent;
//   final VoidCallback onPunchOutAll;

//   const AttendancePunchInCard({
//     super.key,
//     required this.session,
//     required this.punchedOutStudentIds,
//     required this.busy,
//     required this.onPunchOutStudent,
//     required this.onPunchOutAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     final remaining = session.scans
//         .where((s) => !punchedOutStudentIds.contains(s.studentId))
//         .length;
//     final done = remaining == 0;
//     final accent = done ? AppColors.success : AppColors.warningDark;

//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkCard : AppColors.lightCard,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
//         ),
//       ),
//       child: Theme(
//         data: theme.copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 14),
//           childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
//           shape: const Border(),
//           collapsedShape: const Border(),
//           leading: Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: AppColors.success.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: const Icon(Icons.login_rounded, color: AppColors.success),
//           ),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Punch IN · ${session.scans.length}',
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//               AttendanceStatusChip(
//                 label: session.synced ? 'Synced' : 'Pending',
//                 color: session.synced
//                     ? AppColors.success
//                     : AppColors.warningDark,
//               ),
//             ],
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               done
//                   ? '✓ All punched out'
//                   : 'Remaining to punch out: $remaining of ${session.scans.length}',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: accent,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//           children: [
//             if (!done)
//               SizedBox(
//                 width: double.infinity,
//                 height: 42,
//                 child: OutlinedButton.icon(
//                   onPressed: busy ? null : onPunchOutAll,
//                   icon: const Icon(Icons.logout_rounded, size: 18),
//                   label: Text(
//                     'Punch Out All ($remaining remaining)',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.warningDark,
//                     side: BorderSide(
//                       color: AppColors.warningDark.withValues(alpha: 0.5),
//                       width: 1.4,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppColors.success.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: AppColors.success.withValues(alpha: 0.3),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.check_circle_rounded,
//                       size: 16,
//                       color: AppColors.success,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'All students punched out',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.success,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 10),

//             ...session.scans.asMap().entries.map((entry) {
//               final scan = entry.value;
//               final out = punchedOutStudentIds.contains(scan.studentId);

//               return AttendanceScanRow(
//                 index: entry.key + 1,
//                 scan: scan,
//                 trailing: out
//                     ? const AttendanceOutBadge()
//                     : IconButton(
//                         tooltip: 'Punch Out',
//                         icon: const Icon(
//                           Icons.logout_rounded,
//                           size: 18,
//                           color: AppColors.warningDark,
//                         ),
//                         onPressed: busy ? null : () => onPunchOutStudent(scan),
//                       ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/attendance_session.dart';
import '../../data/models/pending_attendance_scan.dart';
import 'attendance_scan_row.dart';
import 'attendance_status_chip.dart';

class AttendancePunchInCard extends StatelessWidget {
  final AttendanceSession session;
  final Set<String> punchedOutStudentIds;
  final bool busy;
  final void Function(PendingAttendanceScan scan) onPunchOutStudent;
  final VoidCallback onPunchOutAll;

  const AttendancePunchInCard({
    super.key,
    required this.session,
    required this.punchedOutStudentIds,
    required this.busy,
    required this.onPunchOutStudent,
    required this.onPunchOutAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final remaining = session.scans
        .where((s) => !punchedOutStudentIds.contains(s.studentId))
        .length;
    final done = remaining == 0;
    final accent = done ? AppColors.success : AppColors.warningDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.login_rounded, color: AppColors.success),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance · ${session.scans.length}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AttendanceStatusChip(
                label: session.synced ? 'Synced' : 'Pending',
                color: session.synced
                    ? AppColors.success
                    : AppColors.warningDark,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              done
                  ? '✓ All students punched out'
                  : '$remaining of ${session.scans.length} still need punch out',
              style: theme.textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            // ── Punch Out All button ──────────────────
            if (!done)
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onPunchOutAll,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    'Punch Out All ($remaining remaining)',
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
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All students punched out',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // ── Student list — two status icons per row ─
            ...session.scans.asMap().entries.map((entry) {
              final scan = entry.value;
              final isOut = punchedOutStudentIds.contains(scan.studentId);

              return AttendanceScanRow(
                index: entry.key + 1,
                scan: scan,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1) Punched in — always green ✓ if we're showing this row
                    const _StatusIcon(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      tooltip: 'Punched in',
                    ),
                    const SizedBox(width: 6),

                    // 2) Punched out — green ✓ if done, otherwise tappable logout
                    isOut
                        ? const _StatusIcon(
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                            tooltip: 'Punched out',
                          )
                        : IconButton(
                            tooltip: 'Punch Out',
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: AppColors.warningDark,
                            ),
                            onPressed: busy
                                ? null
                                : () => onPunchOutStudent(scan),
                          ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Small reusable icon wrapper so both checkmarks render at the same size.
class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;

  const _StatusIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 20, color: color),
    );
  }
}
