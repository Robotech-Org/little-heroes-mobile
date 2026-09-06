import '../../data/models/daily_report_response_model.dart';

abstract class DailyReportRepository {
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  });
}
