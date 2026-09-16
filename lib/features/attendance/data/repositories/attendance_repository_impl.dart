import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../models/attendance_batch_response_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AttendanceBatchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  }) => remoteDataSource.punchIn(
    scans: scans,
    latitude: latitude,
    longitude: longitude,
    gpsAccuracyMeters: gpsAccuracyMeters,
    deviceId: deviceId,
  );

  @override
  Future<AttendanceBatchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  }) => remoteDataSource.punchOut(
    scans: scans,
    latitude: latitude,
    longitude: longitude,
    gpsAccuracyMeters: gpsAccuracyMeters,
    deviceId: deviceId,
  );
}
