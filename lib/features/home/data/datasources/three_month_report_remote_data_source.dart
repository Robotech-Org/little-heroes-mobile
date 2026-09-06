import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/three_month_report_response_model.dart';

abstract class ThreeMonthReportRemoteDataSource {
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  });
}

class ThreeMonthReportRemoteDataSourceImpl
    implements ThreeMonthReportRemoteDataSource {
  final Dio dio;

  ThreeMonthReportRemoteDataSourceImpl(this.dio);

  @override
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (student != null && student.isNotEmpty) {
        queryParams['student'] = student;
      }
      if (month != null && month.isNotEmpty) {
        queryParams['month'] = month;
      }
      if (year != null) {
        queryParams['year'] = year;
      }

      // Using the existing constant from ApiConstants
      final response = await dio.get(
        ApiConstants.listMonthlyReports,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return ThreeMonthReportResponseModel.fromJson(response.data);
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
