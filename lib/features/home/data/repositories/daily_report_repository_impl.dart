import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';

import '../datasources/daily_report_remote_data_source.dart';
import '../../domain/repositories/daily_report_repository.dart';
import '../models/daily_report_response_model.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final DailyReportRemoteDataSource remoteDataSource;

  DailyReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  }) {
    return remoteDataSource.getDailyReports(
      page: page,
      pageSize: pageSize,
      student: student,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<DailyReportModel> getDailyReport(String reportName) {
    return remoteDataSource.getDailyReport(reportName);
  }

  @override
  Future<DailyReportModel> createDailyReport(Map<String, dynamic> data) {
    return remoteDataSource.createDailyReport(data);
  }

  @override
  Future<DailyReportModel> updateDailyReport({
    required String reportName,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.updateDailyReport(
      reportName: reportName,
      data: data,
    );
  }
}
