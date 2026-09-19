import '../../data/models/attendance_batch_response_model.dart';
import '../../data/models/attendance_session.dart';
import '../../data/services/attendance_session_service.dart';
import '../repositories/attendance_repository.dart';

class SyncSummary {
  final int synced;
  final int failed;
  final int flagged;
  bool get nothingToSync => synced == 0 && failed == 0;
  SyncSummary({required this.synced, required this.failed, this.flagged = 0});
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
    int flagged = 0;

    for (final session in pending) {
      // Only send scans that still need a round-trip
      final unsent = session.scans.where((s) => s.isPending).toList();
      if (unsent.isEmpty) {
        await sessionService.markSessionSynced(session.sessionId);
        continue;
      }

      try {
        final scans = unsent
            .map(
              (s) => {
                'student_id': s.studentId,
                'qr_payload': s.qrPayload,
                'scanned_at': s.scannedAt.toUtc().toIso8601String(),
              },
            )
            .toList();

        final batchScannedAt = unsent.first.scannedAt;

        final AttendanceBatchResponse response =
            session.logType == AttendanceLogType.punchIn
            ? await repository.punchIn(
                scans: scans,
                latitude: session.deviceLatitude,
                longitude: session.deviceLongitude,
                gpsAccuracyMeters: session.gpsAccuracyMeters,
                scannedAt: batchScannedAt,
                deviceId: session.deviceId,
              )
            : await repository.punchOut(
                scans: scans,
                latitude: session.deviceLatitude,
                longitude: session.deviceLongitude,
                gpsAccuracyMeters: session.gpsAccuracyMeters,
                scannedAt: batchScannedAt,
                deviceId: session.deviceId,
              );

        final failedPayloads = <String>{};
        final failureReasons = <String, String>{};
        for (final f in response.failedScans) {
          final p = f.qrPayload;
          if (p != null && p.isNotEmpty) {
            failedPayloads.add(p);
            failureReasons[p] = f.reason ?? 'Server rejected this scan';
          }
        }

        final sentPayloads = unsent.map((s) => s.qrPayload).toSet();
        final succeededPayloads = sentPayloads.difference(failedPayloads);

        await sessionService.applyBatchResult(
          sessionId: session.sessionId,
          succeededQrPayloads: succeededPayloads,
          failedQrPayloads: failedPayloads,
          failureReasons: failureReasons,
        );

        synced += response.successCount;
        failed += response.failedCount;

        if (response.validationStatus?.toLowerCase() == 'flagged') {
          flagged += response.successCount;
        }
      } catch (_) {
        failed += unsent.length;
      }
    }

    return SyncSummary(synced: synced, failed: failed, flagged: flagged);
  }
}
