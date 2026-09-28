import '../../data/models/punch_response.dart';

abstract class GateAttendanceRepository {
  Future<PunchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });

  Future<PunchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });
}
