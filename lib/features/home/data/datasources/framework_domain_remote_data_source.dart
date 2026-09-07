import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/framework_domain_response_model.dart';

abstract class FrameworkDomainRemoteDataSource {
  Future<FrameworkDomainResponseModel> getFrameworkDomains({
    int page = 1,
    int pageSize = 20,
  });
}

class FrameworkDomainRemoteDataSourceImpl
    implements FrameworkDomainRemoteDataSource {
  final Dio dio;

  FrameworkDomainRemoteDataSourceImpl(this.dio);

  @override
  Future<FrameworkDomainResponseModel> getFrameworkDomains({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listFrameworkDomains,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return FrameworkDomainResponseModel.fromJson(response.data);
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
