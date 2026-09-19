import '../../data/models/attendance_batch_response_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceBatchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    required DateTime scannedAt,
    String? deviceId,
  });

  Future<AttendanceBatchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    required DateTime scannedAt,
    String? deviceId,
  });
}
