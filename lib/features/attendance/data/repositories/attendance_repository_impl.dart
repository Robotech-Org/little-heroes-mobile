import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../models/attendance_batch_response_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AttendanceBatchResponse> scanQrBatch(Map<String, dynamic> payload) {
    return remoteDataSource.scanQrBatch(payload);
  }
}
