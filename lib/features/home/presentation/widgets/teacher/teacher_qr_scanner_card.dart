import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/device_id_utils.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/widgets/qr_scanner/qr_scanner_page.dart';
import '../../../../../core/widgets/qr_scanner/qr_scanner_result.dart';
import '../../../../../features/attendance/data/models/attendance_session.dart';
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

  // ─────────────────────────────────────────────────────────
  // MAIN ENTRY — sequential Punch-In scanning
  // ─────────────────────────────────────────────────────────
  Future<void> _scanQrCode(BuildContext context) async {
    final service = di.sl<AttendanceSessionService>();

    var active = await service.getActiveSession();

    if (active == null) {
      final ok = await _startPunchInSession(context, service);
      if (!ok || !context.mounted) return;
      active = await service.getActiveSession();
      if (active == null) return;
    }

    if (active.logType != AttendanceLogType.punchIn) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Punch-in session for today is already closed',
        );
      }
      return;
    }

    await _scanSequence(context, active);
  }

  // ─────────────────────────────────────────────────────────
  // SCAN SEQUENCE
  //   open scanner → scan → show dialog → wait for button →
  //   if user tapped "Done" → return (stop loop)
  //   otherwise → reopen scanner
  // ─────────────────────────────────────────────────────────
  Future<void> _scanSequence(
    BuildContext context,
    AttendanceSession initialSession,
  ) async {
    final service = di.sl<AttendanceSessionService>();
    AttendanceSession session = initialSession;

    while (context.mounted) {
      final result = await Navigator.push<QrScannerResult>(
        context,
        MaterialPageRoute(
          builder: (_) => const QrScannerPage(
            title: 'Punch In — Scan Student',
            instruction: 'Place the student QR code inside the frame',
          ),
        ),
      );

      // User backed out of scanner with system back → exit loop
      if (!context.mounted || result == null) return;

      final card = QrPayloadDecoder.tryDecode(result.value);

      // ── Invalid QR ───────────────────────────────────
      if (card == null || card.card.isEmpty) {
        final keepGoing = await _showResultDialog(
          context,
          title: 'Invalid QR code',
          message: 'This QR code is not a student ID card.\nTry again.',
          isSuccess: false,
          accent: AppColors.error,
          showDone: false,
        );
        if (!keepGoing || !context.mounted) return;
        continue;
      }

      // ── Duplicate detection ──────────────────────────
      final alreadyScanned = session.scans.any((s) => s.studentId == card.card);
      if (alreadyScanned) {
        final keepGoing = await _showResultDialog(
          context,
          title: 'Already scanned',
          message: '${card.card} was already scanned in this session.',
          isSuccess: false,
          accent: AppColors.warningDark,
          showDone: false,
        );
        if (!keepGoing || !context.mounted) return;
        continue;
      }

      // ── Add scan ─────────────────────────────────────
      final updated = await service.addScan(
        PendingAttendanceScan(
          studentId: card.card,
          qrPayload: result.value,
          scannedAt: DateTime.now(),
        ),
      );
      if (updated != null) session = updated;

      if (!context.mounted) return;

      // ── Success dialog ───────────────────────────────
      final keepGoing = await _showResultDialog(
        context,
        title: 'Scanned ✓',
        message: '${card.card}\n\nTotal: ${session.scans.length} students',
        isSuccess: true,
        accent: AppColors.success,
        showDone: true, // success dialog gets both buttons
      );

      // Done → stop the loop entirely
      if (!keepGoing) return;
      // Otherwise loop continues → scanner reopens
    }
  }

  // ─────────────────────────────────────────────────────────
  // RESULT DIALOG — returns:
  //   true  → user wants to continue scanning
  //   false → user tapped "Done", stop the loop
  // ─────────────────────────────────────────────────────────
  Future<bool> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
    required Color accent,
    required bool showDone,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.error_outline_rounded,
                  color: accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            // Primary action → continue scanning
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true), // continue
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isSuccess ? 'Scan Next' : 'Try Again',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            // Secondary action → only on success dialog
            if (showDone) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false), // stop
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );

    // If the dialog was dismissed by any means other than tapping a
    // button (shouldn't happen with barrierDismissible:false, but be safe),
    // treat it as "continue".
    return result ?? true;
  }

  // ─────────────────────────────────────────────────────────
  // START PUNCH-IN SESSION — captures GPS + device id once
  // ─────────────────────────────────────────────────────────
  Future<bool> _startPunchInSession(
    BuildContext context,
    AttendanceSessionService service,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(message: 'Capturing location…'),
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
          SnackbarUtils.showError(
            context,
            'Location permission is required to start a session',
          );
        }
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final deviceId = await DeviceIdUtils.getDeviceId();

      await service.startSession(
        logType: AttendanceLogType.punchIn,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        SnackbarUtils.showError(
          context,
          'Failed to start session: '
          '${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
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
                          'Punch In — Scan Students',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Scan each student ID card one at a time.',
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

          Divider(
            height: 1,
            thickness: 1,
            color: colors.outline.withValues(alpha: 0.12),
          ),

          // ── View list ────────────────────────────────
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
                          'See all sessions and scans',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
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

// ═════════════════════════════════════════════════════════════
// LOADING DIALOG
// ═════════════════════════════════════════════════════════════
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
