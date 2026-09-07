import 'package:dio/dio.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';

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
  Future<DailyReportModel> getDailyReport(String reportName);

  Future<DailyReportModel> updateDailyReport({
    required String reportName,
    required Map<String, dynamic> data,
  });

  // Create daily report
  Future<DailyReportModel> createDailyReport(Map<String, dynamic> data);
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

  // ============================================================
  // GET SINGLE DAILY REPORT
  // ============================================================

  @override
  Future<DailyReportModel> getDailyReport(String reportName) async {
    try {
      final response = await dio.get(
        ApiConstants.getDailyReport,
        queryParameters: {'name': reportName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return DailyReportModel.fromJson(data);
      }

      throw Exception('Report not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // UPDATE DAILY REPORT
  // ============================================================

  @override
  Future<DailyReportModel> updateDailyReport({
    required String reportName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.updateDailyReport,
        queryParameters: {'name': reportName},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final reportData = message['data'] ?? {};

      if (reportData is Map<String, dynamic>) {
        return DailyReportModel.fromJson(reportData);
      }

      throw Exception('Failed to update report');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // CREATE DAILY REPORT
  // ============================================================

  @override
  Future<DailyReportModel> createDailyReport(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstants.createDailyReport,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final reportData = message['data'] ?? {};

      if (reportData is Map<String, dynamic>) {
        return DailyReportModel.fromJson(reportData);
      }

      throw Exception('Failed to create report');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
