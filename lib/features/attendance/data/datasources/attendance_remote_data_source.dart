import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/attendance_batch_response_model.dart';

abstract class AttendanceRemoteDataSource {
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

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceBatchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    required DateTime scannedAt,
    String? deviceId,
  }) => _punch(ApiConstants.punchIn, {
    'device_latitude': latitude,
    'device_longitude': longitude,
    'gps_accuracy_meters': gpsAccuracyMeters,
    'scanned_at': scannedAt.toUtc().toIso8601String(), // ✅ top-level
    if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    'scans': scans,
  });

  @override
  Future<AttendanceBatchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double gpsAccuracyMeters,
    required DateTime scannedAt,
    String? deviceId,
  }) => _punch(ApiConstants.punchOut, {
    'device_latitude': latitude,
    'device_longitude': longitude,
    'gps_accuracy_meters': gpsAccuracyMeters,
    'scanned_at': scannedAt.toUtc().toIso8601String(),
    if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    'scans': scans,
  });

  Future<AttendanceBatchResponse> _punch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📤 [Attendance] POST $endpoint');
      debugPrint('📤 body: $body');

      final response = await dio.post(endpoint, data: body);

      debugPrint('📥 response: ${response.data}');

      // Frappe wraps everything under "message"
      final raw = response.data;
      final Map<String, dynamic> json;
      if (raw is Map<String, dynamic>) {
        json = raw;
      } else if (raw is Map) {
        json = Map<String, dynamic>.from(raw);
      } else {
        throw Exception('Unexpected response type: ${raw.runtimeType}');
      }

      final unwrapped = json['message'] is Map
          ? Map<String, dynamic>.from(json['message'] as Map)
          : json;

      return AttendanceBatchResponse.fromJson(unwrapped);
    } on DioException catch (e) {
      final serverData = e.response?.data;
      String? serverMsg;
      if (serverData is Map) {
        serverMsg =
            serverData['message']?.toString() ??
            serverData['exception']?.toString();
      }
      debugPrint(
        '❌ [Attendance] failed (status=${e.response?.statusCode}): '
        '${serverMsg ?? e.message}',
      );
      DioErrorHandler.handle(e);
      if (serverMsg != null && serverMsg.isNotEmpty) {
        throw Exception(serverMsg);
      }
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
