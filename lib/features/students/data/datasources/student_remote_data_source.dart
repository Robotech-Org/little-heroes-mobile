import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/student_response_model.dart';

abstract class StudentRemoteDataSource {
  Future<StudentResponseModel> getStudents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? search,
  });
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl(this.dio);

  @override
  Future<StudentResponseModel> getStudents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstants.listStudents,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return StudentResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
