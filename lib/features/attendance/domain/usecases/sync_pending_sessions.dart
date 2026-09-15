import '../repositories/attendance_repository.dart';
import '../../data/services/attendance_session_service.dart';

class SyncPendingSessions {
  final AttendanceRepository repository;
  final AttendanceSessionService sessions;

  SyncPendingSessions(this.repository, this.sessions);

  /// Syncs all pending sessions. One HTTP call per session
  /// (each session has its own device + GPS envelope).
  Future<SyncSummary> call() async {
    final pending = await sessions.getPendingSessions();
    if (pending.isEmpty) {
      return SyncSummary(synced: 0, failed: 0, nothingToSync: true);
    }

    int ok = 0;
    int fail = 0;

    for (final session in pending) {
      try {
        final response = await repository.scanQrBatch(session.toRequestJson());
        await sessions.markSessionSynced(session.sessionId);
        ok += response.results.where((r) => r.success).length;
        fail += response.results.where((r) => !r.success).length;
      } catch (_) {
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
