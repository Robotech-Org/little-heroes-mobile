import 'three_month_report_model.dart';

class ThreeMonthReportResponseModel {
  final bool success;
  final List<ThreeMonthReportModel> items;
  final int total;
  final int page;
  final int pageSize;

  ThreeMonthReportResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ThreeMonthReportResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return ThreeMonthReportResponseModel(
      success: message['success'] ?? false,
      items: itemsList
          .map((item) => ThreeMonthReportModel.fromJson(item))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }
}
