import '../../data/models/three_month_report_response_model.dart';

abstract class ThreeMonthReportRepository {
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  });
}
