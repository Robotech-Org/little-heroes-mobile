// lib/features/home/data/models/classroom_response_model.dart
import 'classroom_model.dart';

class ClassroomResponseModel {
  final List<ClassroomModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  ClassroomResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ClassroomResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested response structure
    final message = json['message'] ?? {};
    final data = message['data'] ?? json['data'] ?? {};
    final items = data['items'] as List? ?? [];

    return ClassroomResponseModel(
      items: items.map((item) => ClassroomModel.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
      totalPages: data['total_pages'] ?? 1,
    );
  }
}
