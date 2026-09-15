import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/attendance_batch_response_model.dart';

abstract class AttendanceRemoteDataSource {
  /// Sends a whole session batch to the server in ONE request.
  Future<AttendanceBatchResponse> scanQrBatch(Map<String, dynamic> payload);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceBatchResponse> scanQrBatch(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(ApiConstants.scanQr, data: payload);

      return AttendanceBatchResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
