import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/daily_report_response_model.dart';

abstract class DailyReportRemoteDataSource {
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  });
}

class DailyReportRemoteDataSourceImpl implements DailyReportRemoteDataSource {
  final Dio dio;

  DailyReportRemoteDataSourceImpl(this.dio);

  @override
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // FIXED: Use Map<String, dynamic> to accept both int and String
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (student != null && student.isNotEmpty) {
        queryParams['student'] = student;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await dio.get(
        ApiConstants.listDailyReports,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return DailyReportResponseModel.fromJson(response.data);
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
