import '../../data/models/attendance_session.dart';
import '../../data/services/attendance_session_service.dart';
import '../repositories/attendance_repository.dart';

class SyncSummary {
  final int synced;
  final int failed;
  bool get nothingToSync => synced == 0 && failed == 0;
  SyncSummary({required this.synced, required this.failed});
}

class SyncPendingSessions {
  final AttendanceSessionService sessionService;
  final AttendanceRepository repository;

  SyncPendingSessions({required this.sessionService, required this.repository});

  Future<SyncSummary> call() async {
    final pending = await sessionService.getPendingSessions();
    if (pending.isEmpty) return SyncSummary(synced: 0, failed: 0);

    int synced = 0;
    int failed = 0;

    for (final session in pending) {
      try {
        final scans = session.scans
            .map(
              (s) => {
                'student_id': s.studentId,
                'qr_payload': s.qrPayload,
                'scanned_at': s.scannedAt.toUtc().toIso8601String(),
              },
            )
            .toList();

        final batchScannedAt = session.scans.isEmpty
            ? session.startedAt
            : session.scans.first.scannedAt;

        if (session.logType == AttendanceLogType.punchIn) {
          await repository.punchIn(
            scans: scans,
            latitude: session.deviceLatitude,
            longitude: session.deviceLongitude,
            gpsAccuracyMeters: session.gpsAccuracyMeters,
            scannedAt: batchScannedAt,
            deviceId: session.deviceId,
          );
        } else {
          await repository.punchOut(
            scans: scans,
            latitude: session.deviceLatitude,
            longitude: session.deviceLongitude,
            gpsAccuracyMeters: session.gpsAccuracyMeters,
            scannedAt: batchScannedAt,
            deviceId: session.deviceId,
          );
        }

        await sessionService.markSessionSynced(session.sessionId);
        synced += session.scans.length;
      } catch (_) {
        failed += session.scans.length;
      }
    }

    return SyncSummary(synced: synced, failed: failed);
  }
}
