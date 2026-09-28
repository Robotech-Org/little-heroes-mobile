import '../../domain/repositories/gate_attendance_repository.dart';
import '../datasources/gate_attendance_datasource.dart';
import '../models/punch_response.dart';

class GateAttendanceRepositoryImpl implements GateAttendanceRepository {
  final GateAttendanceDataSource remote;
  GateAttendanceRepositoryImpl({required this.remote});

  @override
  Future<PunchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => remote.punchIn(
    scans: scans,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
  );

  @override
  Future<PunchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => remote.punchOut(
    scans: scans,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
  );
}
