import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/classroom_model.dart';
import '../models/classroom_response_model.dart';

abstract class ClassroomRemoteDataSource {
  Future<ClassroomResponseModel> getClassrooms({
    int page = 1,
    int pageSize = 20,
  });

  Future<ClassroomModel> getClassroom(String classroomName);
}

class ClassroomRemoteDataSourceImpl implements ClassroomRemoteDataSource {
  final Dio dio;

  ClassroomRemoteDataSourceImpl(this.dio);

  @override
  Future<ClassroomResponseModel> getClassrooms({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listClassrooms,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      // print('=== CLASSROOM API RESPONSE ===');
      // print('Status Code: ${response.statusCode}');
      // print('Response Data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return ClassroomResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // print('DioException in getClassrooms: ${e.message}');
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      // print('Error in getClassrooms: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<ClassroomModel> getClassroom(String classroomName) async {
    try {
      final response = await dio.get(
        ApiConstants.getClassroom,
        queryParameters: {'name': classroomName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return ClassroomModel.fromJson(data);
      }

      throw Exception('Classroom not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
