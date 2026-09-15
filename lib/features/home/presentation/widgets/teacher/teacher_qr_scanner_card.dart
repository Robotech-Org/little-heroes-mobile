// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// import '../../../../../core/utils/device_id_utils.dart';
// import '../../../../../core/utils/snackbar_utils.dart';
// import '../../../../../core/widgets/qr_scanner/qr_scanner_page.dart';
// import '../../../../../core/widgets/qr_scanner/qr_scanner_result.dart';
// import '../../../../../features/attendance/data/models/pending_attendance_scan.dart';
// import '../../../../../features/attendance/data/services/attendance_session_service.dart';
// import '../../../../../features/attendance/data/utils/qr_payload_decoder.dart';
// import '../../../../../injection_container.dart' as di;

// class TeacherQrScannerCard extends StatelessWidget {
//   const TeacherQrScannerCard({super.key});

//   Future<void> _scanQrCode(BuildContext context) async {
//     final result = await Navigator.push<QrScannerResult>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const QrScannerPage(
//           title: 'Scan Student QR',
//           instruction: 'Place the student QR code inside the frame',
//         ),
//       ),
//     );

//     if (!context.mounted || result == null) return;

//     final card = QrPayloadDecoder.tryDecode(result.value);
//     if (card == null || card.card.isEmpty) {
//       SnackbarUtils.showError(context, 'Invalid student QR code');
//       return;
//     }

//     final sessionService = di.sl<AttendanceSessionService>();
//     final activeSession = await sessionService.getActiveSession();

//     if (activeSession == null) {
//       await _startSessionAndAddScan(context, card, result.value);
//     } else {
//       await _addScanToActiveSession(context, activeSession, card, result.value);
//     }
//   }

//   Future<void> _startSessionAndAddScan(
//     BuildContext context,
//     QrCardPayload card,
//     String qrPayload,
//   ) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const _LoadingDialog(
//         message: 'Starting session & capturing location...',
//       ),
//     );

//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         if (context.mounted) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         if (context.mounted) {
//           SnackbarUtils.showError(
//             context,
//             'Location permission is required to start a session',
//           );
//         }
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final deviceId = await DeviceIdUtils.getDeviceId();
//       final sessionService = di.sl<AttendanceSessionService>();

//       await sessionService.startSession(
//         deviceId: deviceId,
//         latitude: position.latitude,
//         longitude: position.longitude,
//         accuracyMeters: position.accuracy,
//       );

//       await sessionService.addScan(
//         PendingAttendanceScan(
//           studentId: card.card,
//           qrPayload: qrPayload,
//           scannedAt: DateTime.now(),
//         ),
//       );

//       if (context.mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       if (context.mounted) {
//         _showScanConfirmation(context, card.card, 1);
//       }
//     } catch (e) {
//       if (context.mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       if (context.mounted) {
//         SnackbarUtils.showError(
//           context,
//           'Failed: ${e.toString().replaceFirst('Exception: ', '')}',
//         );
//       }
//     }
//   }

//   Future<void> _addScanToActiveSession(
//     BuildContext context,
//     dynamic activeSession,
//     QrCardPayload card,
//     String qrPayload,
//   ) async {
//     final sessionService = di.sl<AttendanceSessionService>();

//     final updated = await sessionService.addScan(
//       PendingAttendanceScan(
//         studentId: card.card,
//         qrPayload: qrPayload,
//         scannedAt: DateTime.now(),
//       ),
//     );

//     if (!context.mounted) return;
//     _showScanConfirmation(context, card.card, updated?.scans.length ?? 1);
//   }

//   void _showScanConfirmation(
//     BuildContext context,
//     String studentId,
//     int totalInSession,
//   ) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 color: Colors.green.withValues(alpha: 0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_rounded,
//                 color: Colors.green,
//                 size: 34,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Scanned',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               studentId,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'monospace',
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '$totalInSession in session',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: InkWell(
//         onTap: () => _scanQrCode(context),
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Container(
//                 width: 58,
//                 height: 58,
//                 decoration: BoxDecoration(
//                   color: colors.primary.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   Icons.qr_code_scanner_rounded,
//                   color: colors.primary,
//                   size: 30,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Scan Student QR',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       'First scan captures location. All scans sync together.',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.textTheme.bodyMedium?.color?.withValues(
//                           alpha: 0.65,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 18,
//                 color: theme.iconTheme.color?.withValues(alpha: 0.6),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LoadingDialog extends StatelessWidget {
//   final String message;
//   const _LoadingDialog({this.message = 'Processing...'});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../core/utils/device_id_utils.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/widgets/qr_scanner/qr_scanner_page.dart';
import '../../../../../core/widgets/qr_scanner/qr_scanner_result.dart';
import '../../../../../features/attendance/data/models/pending_attendance_scan.dart';
import '../../../../../features/attendance/data/services/attendance_session_service.dart';
import '../../../../../features/attendance/data/utils/qr_payload_decoder.dart';
import '../../../../../features/attendance/presentation/pages/attendance_sessions_page.dart';
import '../../../../../injection_container.dart' as di;

class TeacherQrScannerCard extends StatelessWidget {
  const TeacherQrScannerCard({super.key});

  // ─────────────────────────────────────────────────────────
  // NAVIGATE TO SCANNED LIST PAGE
  // ─────────────────────────────────────────────────────────
  void _openSessionsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AttendanceSessionsPage()),
    );
  }

  Future<void> _scanQrCode(BuildContext context) async {
    final result = await Navigator.push<QrScannerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(
          title: 'Scan Student QR',
          instruction: 'Place the student QR code inside the frame',
        ),
      ),
    );

    if (!context.mounted || result == null) return;

    final card = QrPayloadDecoder.tryDecode(result.value);
    if (card == null || card.card.isEmpty) {
      SnackbarUtils.showError(context, 'Invalid student QR code');
      return;
    }

    final sessionService = di.sl<AttendanceSessionService>();
    final activeSession = await sessionService.getActiveSession();

    if (activeSession == null) {
      await _startSessionAndAddScan(context, card, result.value);
    } else {
      await _addScanToActiveSession(context, activeSession, card, result.value);
    }
  }

  Future<void> _startSessionAndAddScan(
    BuildContext context,
    QrCardPayload card,
    String qrPayload,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(
        message: 'Starting session & capturing location...',
      ),
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (context.mounted) {
          SnackbarUtils.showError(
            context,
            'Location permission is required to start a session',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final deviceId = await DeviceIdUtils.getDeviceId();
      final sessionService = di.sl<AttendanceSessionService>();

      await sessionService.startSession(
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );

      await sessionService.addScan(
        PendingAttendanceScan(
          studentId: card.card,
          qrPayload: qrPayload,
          scannedAt: DateTime.now(),
        ),
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (context.mounted) {
        _showScanConfirmation(context, card.card, 1);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _addScanToActiveSession(
    BuildContext context,
    dynamic activeSession,
    QrCardPayload card,
    String qrPayload,
  ) async {
    final sessionService = di.sl<AttendanceSessionService>();

    final updated = await sessionService.addScan(
      PendingAttendanceScan(
        studentId: card.card,
        qrPayload: qrPayload,
        scannedAt: DateTime.now(),
      ),
    );

    if (!context.mounted) return;
    _showScanConfirmation(context, card.card, updated?.scans.length ?? 1);
  }

  void _showScanConfirmation(
    BuildContext context,
    String studentId,
    int totalInSession,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scanned',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              studentId,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalInSession in session',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('View list'), // ← NEW action
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // ── Main scan row ─────────────────────────────
          InkWell(
            onTap: () => _scanQrCode(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: colors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Student QR',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'First scan captures location. All scans sync together.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: theme.iconTheme.color?.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outline.withValues(alpha: 0.12),
          ),

          // ── Bottom action: View scanned list ─────────
          InkWell(
            onTap: () => _openSessionsPage(context),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.list_alt_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View scanned list',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'See all students you\'ve scanned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Live pending badge ──────────────
                  FutureBuilder<int>(
                    future: di
                        .sl<AttendanceSessionService>()
                        .pendingScanCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  final String message;
  const _LoadingDialog({this.message = 'Processing...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
