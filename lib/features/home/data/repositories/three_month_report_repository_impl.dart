import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';

import '../datasources/three_month_report_remote_data_source.dart';
import '../models/three_month_report_response_model.dart';
import '../../domain/repositories/three_month_report_repository.dart';

class ThreeMonthReportRepositoryImpl implements ThreeMonthReportRepository {
  final ThreeMonthReportRemoteDataSource remoteDataSource;

  ThreeMonthReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  }) {
    return remoteDataSource.getThreeMonthReports(
      page: page,
      pageSize: pageSize,
      student: student,
      month: month,
      year: year,
    );
  }

  @override
  Future<ThreeMonthReportModel> getThreeMonthReport(String reportName) {
    return remoteDataSource.getThreeMonthReport(reportName);
  }

  @override
  Future<ThreeMonthReportModel> createThreeMonthReport(
    Map<String, dynamic> data,
  ) {
    return remoteDataSource.createThreeMonthReportInternal(data);
  }

  @override
  Future<ThreeMonthReportModel> updateThreeMonthReport({
    required String reportName,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.updateThreeMonthReport(
      reportName: reportName,
      data: data,
    );
  }

  @override
  Future<String> getThreeMonthReportPdf(String reportName) {
    return remoteDataSource.getThreeMonthReportPdf(reportName);
  }

  @override
  Future<ThreeMonthReportModel> createThreeMonthReportTmr(
    Map<String, dynamic> data,
  ) {
    return remoteDataSource.createThreeMonthReportTmr(data);
  }
}
