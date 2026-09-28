import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/punch_response.dart';

abstract class GateAttendanceDataSource {
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

class GateAttendanceDataSourceImpl implements GateAttendanceDataSource {
  final Dio dio;
  GateAttendanceDataSourceImpl(this.dio);

  @override
  Future<PunchResponse> punchIn({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => _post(
    ApiConstants.gatePunchIn,
    scans,
    latitude,
    longitude,
    accuracyMeters,
  );

  @override
  Future<PunchResponse> punchOut({
    required List<Map<String, dynamic>> scans,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => _post(
    ApiConstants.gatePunchOut,
    scans,
    latitude,
    longitude,
    accuracyMeters,
  );

  Future<PunchResponse> _post(
    String url,
    List<Map<String, dynamic>> scans,
    double lat,
    double lng,
    double acc,
  ) async {
    try {
      final response = await dio.post(
        url,
        data: {
          'device_latitude': lat,
          'device_longitude': lng,
          'gps_accuracy_meters': acc,
          'scans': scans,
        },
      );
      return PunchResponse.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
