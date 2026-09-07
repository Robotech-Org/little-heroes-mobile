import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/lesson_plan_model.dart';
import '../models/lesson_plan_response_model.dart';

abstract class LessonPlanRemoteDataSource {
  Future<LessonPlanResponseModel> getLessonPlans({
    int page = 1,
    int pageSize = 20,
  });

  Future<LessonPlanModel> getLessonPlan(String lessonPlanName);

  Future<LessonPlanModel> createLessonPlan(Map<String, dynamic> data);

  Future<LessonPlanModel> updateLessonPlan({
    required String lessonPlanName,
    required Map<String, dynamic> data,
  });
}

class LessonPlanRemoteDataSourceImpl implements LessonPlanRemoteDataSource {
  final Dio dio;

  LessonPlanRemoteDataSourceImpl(this.dio);

  @override
  Future<LessonPlanResponseModel> getLessonPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listLessonPlans,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return LessonPlanResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<LessonPlanModel> getLessonPlan(String lessonPlanName) async {
    try {
      final response = await dio.get(
        ApiConstants.getLessonPlan,
        queryParameters: {'name': lessonPlanName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return LessonPlanModel.fromJson(data);
      }

      throw Exception('Lesson plan not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<LessonPlanModel> createLessonPlan(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstants.createLessonPlan,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final planData = message['data'] ?? {};

      if (planData is Map<String, dynamic>) {
        return LessonPlanModel.fromJson(planData);
      }

      throw Exception('Failed to create lesson plan');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<LessonPlanModel> updateLessonPlan({
    required String lessonPlanName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.updateLessonPlan,
        queryParameters: {'name': lessonPlanName},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final planData = message['data'] ?? {};

      if (planData is Map<String, dynamic>) {
        return LessonPlanModel.fromJson(planData);
      }

      throw Exception('Failed to update lesson plan');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
