import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';

import '../../data/models/three_month_report_response_model.dart';

abstract class ThreeMonthReportRepository {
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  });
  Future<ThreeMonthReportResponseModel> getThreeMonthReportsParent({
    int page = 1,
    int pageSize = 20,
    String? student,
  });
  Future<ThreeMonthReportModel> getThreeMonthReport(String reportName);

  Future<ThreeMonthReportModel> createThreeMonthReport(
    Map<String, dynamic> data,
  );

  // NEW: Update three month report
  Future<ThreeMonthReportModel> updateThreeMonthReport({
    required String reportName,
    required Map<String, dynamic> data,
  });
  Future<String> getThreeMonthReportPdf(String reportName);

  Future<ThreeMonthReportModel> createThreeMonthReportTmr(
    Map<String, dynamic> data,
  );
}
