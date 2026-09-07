// import 'daily_report_model.dart';

// class DailyReportResponseModel {
//   final bool success;
//   final List<DailyReportModel> items;
//   final int total;
//   final int page;
//   final int pageSize;

//   DailyReportResponseModel({
//     required this.success,
//     required this.items,
//     required this.total,
//     required this.page,
//     required this.pageSize,
//   });

//   factory DailyReportResponseModel.fromJson(Map<String, dynamic> json) {
//     final message = json['message'] ?? {};
//     final data = message['data'] ?? {};
//     final itemsList = data['items'] as List? ?? [];

//     return DailyReportResponseModel(
//       success: message['success'] ?? false,
//       items: itemsList.map((item) => DailyReportModel.fromJson(item)).toList(),
//       total: data['total'] ?? 0,
//       page: data['page'] ?? 1,
//       pageSize: data['page_size'] ?? 20,
//     );
//   }
// }

import 'daily_report_model.dart';

class DailyReportResponseModel {
  final bool success;
  final List<DailyReportModel> items;
  final int total;
  final int page;
  final int pageSize;

  DailyReportResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DailyReportResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return DailyReportResponseModel(
      success: message['success'] ?? false,
      items: itemsList.map((item) => DailyReportModel.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }
}
