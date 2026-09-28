import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/arrived_student.dart';
import '../models/punch_response.dart';
import '../models/student_status.dart';

abstract class ClassroomAttendanceDataSource {
  Future<List<ArrivedStudent>> listArrivedStudents({String? classroom});
  Future<List<StudentStatus>> todayStatus({String? classroom});

  Future<PunchResponse> punchIn({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });

  Future<PunchResponse> punchOut({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });
}

class ClassroomAttendanceDataSourceImpl
    implements ClassroomAttendanceDataSource {
  final Dio dio;
  ClassroomAttendanceDataSourceImpl(this.dio);

  // ── Lists ──────────────────────────────────────
  @override
  Future<List<ArrivedStudent>> listArrivedStudents({String? classroom}) async {
    try {
      final res = await dio.get(
        ApiConstants.listArrivedStudents,
        queryParameters: {
          if (classroom != null && classroom.isNotEmpty) 'classroom': classroom,
        },
      );
      return _extractList(res.data)
          .map((e) => ArrivedStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<StudentStatus>> todayStatus({String? classroom}) async {
    try {
      final res = await dio.get(
        ApiConstants.todayStatus,
        queryParameters: {
          if (classroom != null && classroom.isNotEmpty) 'classroom': classroom,
        },
      );
      return _extractList(res.data)
          .map((e) => StudentStatus.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Punch ──────────────────────────────────────
  @override
  Future<PunchResponse> punchIn({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => _post(
    ApiConstants.classroomPunchIn,
    studentIds,
    latitude,
    longitude,
    accuracyMeters,
  );

  @override
  Future<PunchResponse> punchOut({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => _post(
    ApiConstants.classroomPunchOut,
    studentIds,
    latitude,
    longitude,
    accuracyMeters,
  );

  Future<PunchResponse> _post(
    String url,
    List<String> studentIds,
    double lat,
    double lng,
    double acc,
  ) async {
    try {
      final body = <String, dynamic>{
        'device_latitude': lat,
        'device_longitude': lng,
        'gps_accuracy_meters': acc,
      };
      if (studentIds.length == 1) {
        body['student'] = studentIds.first;
      } else {
        body['students'] = studentIds;
      }

      final res = await dio.post(url, data: body);
      return PunchResponse.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Helper: handle both shapes ─────────────────
  List<dynamic> _extractList(dynamic raw) {
    if (raw is! Map) return const [];
    final root = Map<String, dynamic>.from(raw);
    final container = root['message'] is Map
        ? Map<String, dynamic>.from(root['message'] as Map)
        : root;
    return container['data'] as List? ?? const [];
  }
}
