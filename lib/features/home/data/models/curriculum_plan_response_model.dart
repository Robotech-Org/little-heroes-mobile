import 'curriculum_plan_model.dart';

class CurriculumPlanResponseModel {
  final bool success;
  final List<CurriculumPlanModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CurriculumPlanResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory CurriculumPlanResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return CurriculumPlanResponseModel(
      success: message['success'] ?? false,
      items: itemsList
          .map((e) => CurriculumPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
      totalPages: data['total_pages'] ?? 1,
    );
  }
}
