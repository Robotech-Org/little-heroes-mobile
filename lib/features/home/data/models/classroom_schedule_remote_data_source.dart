// lib/features/home/data/datasources/classroom_schedule_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/classroom_schedule_model.dart';

abstract class ClassroomScheduleRemoteDataSource {
  Future<ClassroomScheduleResponseModel> getClassroomSchedules({
    int page = 1,
    int pageSize = 20,
    String? classroom,
    String? dayOfWeek,
  });

  Future<ClassroomScheduleModel> getClassroomSchedule(String scheduleName);
}

class ClassroomScheduleRemoteDataSourceImpl
    implements ClassroomScheduleRemoteDataSource {
  final Dio dio;

  ClassroomScheduleRemoteDataSourceImpl(this.dio);

  @override
  Future<ClassroomScheduleResponseModel> getClassroomSchedules({
    int page = 1,
    int pageSize = 20,
    String? classroom,
    String? dayOfWeek,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (classroom != null && classroom.isNotEmpty) {
        queryParams['classroom'] = classroom;
      }
      if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
        queryParams['day_of_week'] = dayOfWeek;
      }

      final response = await dio.get(
        ApiConstants.listClassroomSchedules,
        queryParameters: queryParams,
      );

      // print('=== CLASSROOM SCHEDULE API RESPONSE ===');
      // print('Status Code: ${response.statusCode}');
      // print('Response Data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return ClassroomScheduleResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // print('DioException in getClassroomSchedules: ${e.message}');
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      // print('Error in getClassroomSchedules: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<ClassroomScheduleModel> getClassroomSchedule(
    String scheduleName,
  ) async {
    try {
      final response = await dio.get(
        ApiConstants.getClassroomSchedule,
        queryParameters: {'name': scheduleName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return ClassroomScheduleModel.fromJson(data);
      }

      throw Exception('Classroom schedule not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
