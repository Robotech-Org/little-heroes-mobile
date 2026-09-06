import '../../domain/entities/student.dart';

class StudentResponseModel {
  final bool success;
  final List<Student> items;
  final int total;
  final int page;
  final int pageSize;

  StudentResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory StudentResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return StudentResponseModel(
      success: message['success'] ?? false,
      items: itemsList.map((item) => Student.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }
}
