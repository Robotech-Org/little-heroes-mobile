import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/competency_model.dart';
import '../models/competency_response_model.dart';

abstract class CompetencyRemoteDataSource {
  Future<CompetencyResponseModel> getCompetencies({
    int page = 1,
    int pageSize = 20,
  });

  Future<CompetencyModel> getCompetency(String competencyName);
}

class CompetencyRemoteDataSourceImpl implements CompetencyRemoteDataSource {
  final Dio dio;

  CompetencyRemoteDataSourceImpl(this.dio);

  @override
  Future<CompetencyResponseModel> getCompetencies({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listCompetencies,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return CompetencyResponseModel.fromJson(response.data);
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
  Future<CompetencyModel> getCompetency(String competencyName) async {
    try {
      final response = await dio.get(
        ApiConstants.getCompetency,
        queryParameters: {'name': competencyName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return CompetencyModel.fromJson(data);
      }

      throw Exception('Competency not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
