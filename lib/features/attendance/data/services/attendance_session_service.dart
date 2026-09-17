// import 'package:hive/hive.dart';

// import '../models/attendance_session.dart';
// import '../models/pending_attendance_scan.dart';

// class AttendanceSessionService {
//   static const String _boxName = 'attendance_sessions';
//   static const String _activeKey = '__active__';

//   Future<Box> _getBox() async {
//     if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
//     return Hive.openBox(_boxName);
//   }

//   // ─────────────────────────────────────────────
//   // ACTIVE SESSION
//   // ─────────────────────────────────────────────

//   Future<AttendanceSession> startSession({
//     required AttendanceLogType logType, // ← NEW
//     required String deviceId,
//     required double latitude,
//     required double longitude,
//     required double accuracyMeters,
//   }) async {
//     final now = DateTime.now();
//     final session = AttendanceSession(
//       sessionId: now.millisecondsSinceEpoch.toString(),
//       logType: logType,
//       deviceId: deviceId,
//       deviceLatitude: latitude,
//       deviceLongitude: longitude,
//       gpsAccuracyMeters: accuracyMeters,
//       startedAt: now,
//       scans: [],
//     );
//     final box = await _getBox();
//     await box.put(_activeKey, session.toMap());
//     return session;
//   }

//   Future<AttendanceSession?> getActiveSession() async {
//     final box = await _getBox();
//     final raw = box.get(_activeKey);
//     if (raw == null) return null;
//     return AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//   }

//   Future<AttendanceSession?> addScan(PendingAttendanceScan scan) async {
//     final box = await _getBox();
//     final raw = box.get(_activeKey);
//     if (raw == null) return null;

//     final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//     final updatedScans = List<PendingAttendanceScan>.from(session.scans)
//       ..removeWhere((s) => s.studentId == scan.studentId)
//       ..add(scan);

//     final updated = session.copyWith(scans: updatedScans);
//     await box.put(_activeKey, updated.toMap());
//     return updated;
//   }

//   Future<AttendanceSession?> finalizeActiveSession() async {
//     final box = await _getBox();
//     final raw = box.get(_activeKey);
//     if (raw == null) return null;

//     final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//     if (session.isEmpty) {
//       await box.delete(_activeKey);
//       return null;
//     }

//     await box.put(session.sessionId, session.toMap());
//     await box.delete(_activeKey);
//     return session;
//   }

//   Future<void> discardActiveSession() async {
//     final box = await _getBox();
//     await box.delete(_activeKey);
//   }

//   // ─────────────────────────────────────────────
//   // PENDING SESSIONS
//   // ─────────────────────────────────────────────

//   Future<List<AttendanceSession>> getPendingSessions() async {
//     final box = await _getBox();
//     final items = <AttendanceSession>[];
//     for (final key in box.keys) {
//       if (key == _activeKey) continue;
//       final raw = box.get(key);
//       if (raw == null) continue;
//       final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//       if (!session.synced) items.add(session);
//     }
//     items.sort((a, b) => a.startedAt.compareTo(b.startedAt));
//     return items;
//   }

//   Future<int> pendingScanCount() async {
//     final sessions = await getPendingSessions();
//     return sessions.fold<int>(0, (sum, s) => sum + s.scans.length);
//   }

//   Future<void> markSessionSynced(String sessionId) async {
//     final box = await _getBox();
//     final raw = box.get(sessionId);
//     if (raw == null) return;
//     final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//     await box.put(sessionId, session.copyWith(synced: true).toMap());
//   }

//   Future<void> purgeSyncedSessions() async {
//     final box = await _getBox();
//     final toRemove = <dynamic>[];
//     for (final key in box.keys) {
//       if (key == _activeKey) continue;
//       final raw = box.get(key);
//       if (raw == null) continue;
//       final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//       if (session.synced) toRemove.add(key);
//     }
//     await box.deleteAll(toRemove);
//   }

//   Future<void> clearAll() async {
//     final box = await _getBox();
//     await box.clear();
//   }

//   Future<List<AttendanceSession>> getAllSessions() async {
//     final box = await _getBox();
//     final items = <AttendanceSession>[];
//     for (final key in box.keys) {
//       if (key == _activeKey) continue;
//       final raw = box.get(key);
//       if (raw == null) continue;
//       items.add(AttendanceSession.fromMap(Map<String, dynamic>.from(raw)));
//     }
//     items.sort((a, b) => b.startedAt.compareTo(a.startedAt));
//     return items;
//   }

//   Future<void> clearSyncedSessions() async {
//     final box = await _getBox();
//     final toRemove = <dynamic>[];
//     for (final key in box.keys) {
//       if (key == _activeKey) continue;
//       final raw = box.get(key);
//       if (raw == null) continue;
//       final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));
//       if (session.synced) toRemove.add(key);
//     }
//     await box.deleteAll(toRemove);
//   }
// }

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

  // ═════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ═════════════════════════════════════════════
  // ACTIVE SESSION — auto-expire if not today
  // ═════════════════════════════════════════════
  Future<AttendanceSession?> getActiveSession() async {
    final box = await _getBox();
    final raw = box.get(_activeKey);
    if (raw == null) return null;

    final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));

    // If the active session is from a previous day, finalize it automatically
    // and return null. This enforces per-day attendance.
    if (!_isSameDay(session.startedAt, DateTime.now())) {
      await box.put(session.sessionId, session.toMap());
      await box.delete(_activeKey);
      return null;
    }

    return session;
  }

  Future<AttendanceSession> startSession({
    required AttendanceLogType logType,
    required String deviceId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) async {
    final now = DateTime.now();
    final session = AttendanceSession(
      sessionId: now.millisecondsSinceEpoch.toString(),
      logType: logType,
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

  Future<AttendanceSession?> addScan(PendingAttendanceScan scan) async {
    final box = await _getBox();
    final raw = box.get(_activeKey);
    if (raw == null) return null;

    final session = AttendanceSession.fromMap(Map<String, dynamic>.from(raw));

    // ✅ Dedup by studentId — replace if the same card is scanned again
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

  // ═════════════════════════════════════════════
  // PENDING SESSIONS
  // ═════════════════════════════════════════════
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

  /// ⚠️ NEW — pending sessions that are ALSO from today (used by the UI to
  /// decide which sessions to show on the sessions page).
  Future<List<AttendanceSession>> getTodaySessions() async {
    final all = await getAllSessions();
    final today = DateTime.now();
    return all.where((s) => _isSameDay(s.startedAt, today)).toList();
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

  Future<List<AttendanceSession>> getAllSessions() async {
    final box = await _getBox();
    final items = <AttendanceSession>[];
    for (final key in box.keys) {
      if (key == _activeKey) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      items.add(AttendanceSession.fromMap(Map<String, dynamic>.from(raw)));
    }
    items.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return items;
  }

  Future<void> clearSyncedSessions() async {
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
}
