import '../repositories/attendance_repository.dart';
import '../../data/models/attendance_session.dart';
import '../../data/services/attendance_session_service.dart';

class SyncPendingSessions {
  final AttendanceRepository repository;
  final AttendanceSessionService sessions;

  SyncPendingSessions(this.repository, this.sessions);

  Future<SyncSummary> call() async {
    final pending = await sessions.getPendingSessions();
    if (pending.isEmpty) {
      return SyncSummary(synced: 0, failed: 0, nothingToSync: true);
    }

    int ok = 0;
    int fail = 0;

    for (final session in pending) {
      try {
        final scans = session.scans.map((s) => s.toRequestItem()).toList();

        final response = session.logType == AttendanceLogType.punchIn
            ? await repository.punchIn(
                scans: scans,
                latitude: session.deviceLatitude,
                longitude: session.deviceLongitude,
                gpsAccuracyMeters: session.gpsAccuracyMeters,
                deviceId: session.deviceId,
              )
            : await repository.punchOut(
                scans: scans,
                latitude: session.deviceLatitude,
                longitude: session.deviceLongitude,
                gpsAccuracyMeters: session.gpsAccuracyMeters,
                deviceId: session.deviceId,
              );

        // Mark session synced on success
        await sessions.markSessionSynced(session.sessionId);
        ok += response.successCount;
        fail += response.failedCount;
      } catch (e) {
        // Whole batch failed — leave session pending for retry
        fail += session.scans.length;
      }
    }

    await sessions.purgeSyncedSessions();

    return SyncSummary(synced: ok, failed: fail, nothingToSync: false);
  }
}

class SyncSummary {
  final int synced;
  final int failed;
  final bool nothingToSync;

  SyncSummary({
    required this.synced,
    required this.failed,
    required this.nothingToSync,
  });
}
