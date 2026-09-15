import '../../data/models/attendance_batch_response_model.dart';

abstract class AttendanceRepository {
  /// Sends one whole session batch in a single request.
  Future<AttendanceBatchResponse> scanQrBatch(Map<String, dynamic> payload);
}
