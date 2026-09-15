import 'dart:convert';

import 'pending_attendance_scan.dart';

/// One continuous scanning session.
/// Device + GPS are captured ONCE when the session starts.
class AttendanceSession {
  final String sessionId;
  final String deviceId;
  final double deviceLatitude;
  final double deviceLongitude;
  final double gpsAccuracyMeters;
  final DateTime startedAt;
  final List<PendingAttendanceScan> scans;
  final bool synced;

  AttendanceSession({
    required this.sessionId,
    required this.deviceId,
    required this.deviceLatitude,
    required this.deviceLongitude,
    required this.gpsAccuracyMeters,
    required this.startedAt,
    required this.scans,
    this.synced = false,
  });

  bool get isEmpty => scans.isEmpty;

  AttendanceSession copyWith({
    List<PendingAttendanceScan>? scans,
    bool? synced,
  }) {
    return AttendanceSession(
      sessionId: sessionId,
      deviceId: deviceId,
      deviceLatitude: deviceLatitude,
      deviceLongitude: deviceLongitude,
      gpsAccuracyMeters: gpsAccuracyMeters,
      startedAt: startedAt,
      scans: scans ?? this.scans,
      synced: synced ?? this.synced,
    );
  }

  /// The exact payload sent to the server.
  Map<String, dynamic> toRequestJson() => {
    'device_id': deviceId,
    'device_latitude': deviceLatitude,
    'device_longitude': deviceLongitude,
    'gps_accuracy_meters': gpsAccuracyMeters,
    'scanned_at': startedAt.toUtc().toIso8601String(),
    'scans': scans.map((s) => s.toRequestItem()).toList(),
  };

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'deviceId': deviceId,
    'deviceLatitude': deviceLatitude,
    'deviceLongitude': deviceLongitude,
    'gpsAccuracyMeters': gpsAccuracyMeters,
    'startedAt': startedAt.toIso8601String(),
    'scans': scans.map((s) => s.toMap()).toList(),
    'synced': synced,
  };

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    final scansList = (map['scans'] as List? ?? [])
        .map(
          (e) => PendingAttendanceScan.fromMap(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    return AttendanceSession(
      sessionId: map['sessionId'] as String,
      deviceId: map['deviceId'] as String,
      deviceLatitude: (map['deviceLatitude'] as num).toDouble(),
      deviceLongitude: (map['deviceLongitude'] as num).toDouble(),
      gpsAccuracyMeters: (map['gpsAccuracyMeters'] as num).toDouble(),
      startedAt: DateTime.parse(map['startedAt'] as String),
      scans: scansList,
      synced: map['synced'] as bool? ?? false,
    );
  }

  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(toRequestJson());
}
