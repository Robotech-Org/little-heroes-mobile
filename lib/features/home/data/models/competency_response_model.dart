import 'competency_model.dart';

class CompetencyResponseModel {
  final bool success;
  final List<CompetencyModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CompetencyResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory CompetencyResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return CompetencyResponseModel(
      success: message['success'] ?? false,
      items: itemsList.map((item) => CompetencyModel.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
      totalPages: data['total_pages'] ?? 0,
    );
  }
}
