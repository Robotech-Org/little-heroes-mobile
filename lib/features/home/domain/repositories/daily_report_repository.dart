import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';

import '../../data/models/daily_report_response_model.dart';

abstract class DailyReportRepository {
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  });

  Future<DailyReportModel> getDailyReport(String reportName);
  Future<DailyReportModel> createDailyReport(Map<String, dynamic> data);

  Future<DailyReportModel> updateDailyReport({
    required String reportName,
    required Map<String, dynamic> data,
  });
}
