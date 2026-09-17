// import 'package:flutter/material.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../data/models/attendance_session.dart';
// import 'attendance_out_badge.dart';
// import 'attendance_scan_row.dart';
// import 'attendance_status_chip.dart';

// class AttendancePunchOutCard extends StatelessWidget {
//   final AttendanceSession session;

//   const AttendancePunchOutCard({super.key, required this.session});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

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
//               color: AppColors.warningDark.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: const Icon(
//               Icons.logout_rounded,
//               color: AppColors.warningDark,
//             ),
//           ),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Punch OUT · ${session.scans.length}',
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
//               _shortTime(session.startedAt),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//           children: session.scans
//               .asMap()
//               .entries
//               .map(
//                 (e) => AttendanceScanRow(
//                   index: e.key + 1,
//                   scan: e.value,
//                   trailing: const AttendanceOutBadge(),
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }

//   String _shortTime(DateTime dt) {
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/attendance_session.dart';
import 'attendance_scan_row.dart';
import 'attendance_status_chip.dart';

class AttendancePunchOutCard extends StatelessWidget {
  final AttendanceSession session;

  const AttendancePunchOutCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
              color: AppColors.warningDark.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.warningDark,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Punch Out · ${session.scans.length}',
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
              _shortTime(session.startedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          children: session.scans
              .asMap()
              .entries
              .map(
                (e) => AttendanceScanRow(
                  index: e.key + 1,
                  scan: e.value,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // In this card, all students were already punched in.
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 6),
                      // And all were punched out.
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _shortTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
