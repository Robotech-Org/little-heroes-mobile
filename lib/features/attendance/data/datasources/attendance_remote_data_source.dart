import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/attendance_batch_response_model.dart';

abstract class AttendanceRemoteDataSource {
  /// POST /punch_in — batch of scans
  Future<AttendanceBatchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  });

  /// POST /punch_out — batch of scans
  Future<AttendanceBatchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceBatchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  }) => _punch(ApiConstants.punchIn, {
    'device_latitude': latitude,
    'device_longitude': longitude,
    'gps_accuracy_meters': gpsAccuracyMeters,
    if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    'scans': scans,
  });

  @override
  Future<AttendanceBatchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    String? deviceId,
  }) => _punch(ApiConstants.punchOut, {
    'device_latitude': latitude,
    'device_longitude': longitude,
    'gps_accuracy_meters': gpsAccuracyMeters,
    if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    'scans': scans,
  });

  //   Future<AttendanceBatchResponse> _punch(
  //     String endpoint,
  //     Map<String, dynamic> body,
  //   ) async {
  //     try {
  //       debugPrint('📤 [Attendance] POST $endpoint');
  //       debugPrint('📤 body: $body');

  //       final response = await dio.post(endpoint, data: body);

  //       debugPrint('📥 response: ${response.data}');

  //       return AttendanceBatchResponse.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     } on DioException catch (e) {
  //       final serverData = e.response?.data;
  //       final serverMsg = serverData is Map
  //           ? (serverData['message'] ?? serverData['exception'])
  //           : null;
  //       debugPrint(
  //         '❌ [Attendance] failed '
  //         '(status=${e.response?.statusCode}): ${serverMsg ?? e.message}',
  //       );
  //       DioErrorHandler.handle(e);
  //       rethrow;
  //     } catch (e) {
  //       throw Exception(e.toString());
  //     }
  //   }
  Future<AttendanceBatchResponse> _punch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📤 [Attendance] POST $endpoint');
      debugPrint('📤 body: $body');

      final response = await dio.post(endpoint, data: body);

      debugPrint('📥 response: ${response.data}');

      return AttendanceBatchResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final serverData = e.response?.data;
      String? serverMsg;
      if (serverData is Map) {
        serverMsg =
            serverData['message']?.toString() ??
            serverData['exception']?.toString();
      }
      final status = e.response?.statusCode;

      debugPrint(
        '❌ [Attendance] failed (status=$status): ${serverMsg ?? e.message}',
      );

      DioErrorHandler.handle(e);

      // Re-throw a cleaner exception so the UI can show it
      if (serverMsg != null && serverMsg.isNotEmpty) {
        throw Exception(serverMsg);
      }
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
