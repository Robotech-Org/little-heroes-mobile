import 'framework_domain_model.dart';

class FrameworkDomainResponseModel {
  final bool success;
  final List<FrameworkDomainModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  FrameworkDomainResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory FrameworkDomainResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return FrameworkDomainResponseModel(
      success: message['success'] ?? false,
      items: itemsList
          .map((item) => FrameworkDomainModel.fromJson(item))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
      totalPages: data['total_pages'] ?? 0,
    );
  }
}
