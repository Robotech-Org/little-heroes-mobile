// import 'package:flutter/material.dart';

// import '../../data/models/pending_attendance_scan.dart';

// class AttendanceScanRow extends StatelessWidget {
//   final int index;
//   final PendingAttendanceScan scan;
//   final Widget? trailing;

//   const AttendanceScanRow({
//     super.key,
//     required this.index,
//     required this.scan,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: colorScheme.primary.withValues(alpha: 0.12),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               '$index',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: colorScheme.primary,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               scan.studentId,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'monospace',
//               ),
//             ),
//           ),
//           Text(
//             _shortTime(scan.scannedAt),
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: colorScheme.onSurfaceVariant,
//               fontSize: 11,
//               fontFamily: 'monospace',
//             ),
//           ),
//           if (trailing != null) ...[const SizedBox(width: 6), trailing!],
//         ],
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

import '../../data/models/pending_attendance_scan.dart';

class AttendanceScanRow extends StatelessWidget {
  final int index;
  final PendingAttendanceScan scan;
  final Widget? trailing;

  const AttendanceScanRow({
    super.key,
    required this.index,
    required this.scan,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$index',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              scan.studentId,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            _shortTime(scan.scannedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }

  String _shortTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
