import 'package:dio/dio.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';

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

  Future<ThreeMonthReportModel> getThreeMonthReport(String reportName);

  Future<ThreeMonthReportModel> createThreeMonthReport(
    Map<String, dynamic> data,
  );

  Future<ThreeMonthReportModel> updateThreeMonthReport({
    required String reportName,
    required Map<String, dynamic> data,
  });
}

class ThreeMonthReportRemoteDataSourceImpl
    implements ThreeMonthReportRemoteDataSource {
  final Dio dio;

  ThreeMonthReportRemoteDataSourceImpl(this.dio);

  // ═════════════════════════════════════════════════════════════
  // LIST
  // ═════════════════════════════════════════════════════════════
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

      final response = await dio.get(
        ApiConstants.listThreeMonthReports, // ✅ fixed
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

  // ═════════════════════════════════════════════════════════════
  // GET SINGLE
  // ═════════════════════════════════════════════════════════════
  @override
  Future<ThreeMonthReportModel> getThreeMonthReport(String reportName) async {
    try {
      final response = await dio.get(
        ApiConstants.getThreeMonthReport, // ✅ fixed
        queryParameters: {'name': reportName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return ThreeMonthReportModel.fromJson(data);
      }

      throw Exception('Report not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CREATE
  // ═════════════════════════════════════════════════════════════
  @override
  Future<ThreeMonthReportModel> createThreeMonthReport(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.createThreeMonthReport, // ✅ fixed
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final reportData = message['data'] ?? {};

      if (reportData is Map<String, dynamic>) {
        return ThreeMonthReportModel.fromJson(reportData);
      }

      throw Exception('Failed to create report');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // UPDATE
  // ═════════════════════════════════════════════════════════════
  @override
  Future<ThreeMonthReportModel> updateThreeMonthReport({
    required String reportName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.updateThreeMonthReport, // ✅ fixed
        queryParameters: {'name': reportName},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final reportData = message['data'] ?? {};

      if (reportData is Map<String, dynamic>) {
        return ThreeMonthReportModel.fromJson(reportData);
      }

      throw Exception('Failed to update report');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
