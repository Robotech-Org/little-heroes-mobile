import 'package:hive/hive.dart';

import '../models/attendance_session.dart';
import '../models/pending_attendance_scan.dart';

class AttendanceSessionService {
  static const String _boxName = 'attendance_sessions';
  static const String _activeKey = '__active__';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  // ─────────────────────────────────────────────
  // ACTIVE SESSION
  // ─────────────────────────────────────────────

  Future<AttendanceSession> startSession({
    required String deviceId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) async {
    final now = DateTime.now();
    final session = AttendanceSession(
      sessionId: now.millisecondsSinceEpoch.toString(),
      deviceId: deviceId,
      deviceLatitude: latitude,
      deviceLongitude: longitude,
      gpsAccuracyMeters: accuracyMeters,
      startedAt: now,
      scans: [],
    );
    final box = await _getBox();
    await box.put(_activeKey, session.toMap());
    return session;
  }

  Future<AttendanceSession?> getActiveSession() async {
    final box = await _getBox();
    final raw = box.get(_activeKey);
    if (raw == null) return null;
    return AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<AttendanceSession?> addScan(PendingAttendanceScan scan) async {
    final box = await _getBox();
    final raw = box.get(_activeKey);
    if (raw == null) return null;

    final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
    final updatedScans = List<PendingAttendanceScan>.from(session.scans)
      ..removeWhere((s) => s.studentId == scan.studentId)
      ..add(scan);

    final updated = session.copyWith(scans: updatedScans);
    await box.put(_activeKey, updated.toMap());
    return updated;
  }

  Future<AttendanceSession?> finalizeActiveSession() async {
    final box = await _getBox();
    final raw = box.get(_activeKey);
    if (raw == null) return null;

    final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
    if (session.isEmpty) {
      await box.delete(_activeKey);
      return null;
    }

    await box.put(session.sessionId, session.toMap());
    await box.delete(_activeKey);
    return session;
  }

  Future<void> discardActiveSession() async {
    final box = await _getBox();
    await box.delete(_activeKey);
  }

  // ─────────────────────────────────────────────
  // PENDING SESSIONS
  // ─────────────────────────────────────────────

  Future<List<AttendanceSession>> getPendingSessions() async {
    final box = await _getBox();
    final items = <AttendanceSession>[];
    for (final key in box.keys) {
      if (key == _activeKey) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
      if (!session.synced) items.add(session);
    }
    items.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return items;
  }

  Future<int> pendingScanCount() async {
    final sessions = await getPendingSessions();
    return sessions.fold<int>(0, (sum, s) => sum + s.scans.length);
  }

  Future<void> markSessionSynced(String sessionId) async {
    final box = await _getBox();
    final raw = box.get(sessionId);
    if (raw == null) return;
    final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
    await box.put(sessionId, session.copyWith(synced: true).toMap());
  }

  Future<void> purgeSyncedSessions() async {
    final box = await _getBox();
    final toRemove = <dynamic>[];
    for (final key in box.keys) {
      if (key == _activeKey) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
      if (session.synced) toRemove.add(key);
    }
    await box.deleteAll(toRemove);
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
