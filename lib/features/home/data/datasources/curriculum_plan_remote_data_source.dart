import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/curriculum_plan_response_model.dart';

abstract class CurriculumPlanRemoteDataSource {
  Future<CurriculumPlanResponseModel> getCurriculumPlans({
    int page = 1,
    int pageSize = 20,
  });
}

class CurriculumPlanRemoteDataSourceImpl
    implements CurriculumPlanRemoteDataSource {
  final Dio dio;

  CurriculumPlanRemoteDataSourceImpl(this.dio);

  @override
  Future<CurriculumPlanResponseModel> getCurriculumPlans({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listCurriculumPlans,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return CurriculumPlanResponseModel.fromJson(response.data);
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
