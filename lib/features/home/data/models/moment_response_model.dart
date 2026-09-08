import 'moment_model.dart';

class MomentResponseModel {
  final List<MomentModel> items;
  final int total;
  final int page;
  final int pageSize;

  MomentResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory MomentResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested response structure from Frappe
    final message = json['message'] ?? {};
    final data = message['data'] ?? json['data'] ?? {};
    final items = data['items'] as List? ?? [];

    return MomentResponseModel(
      items: items.map((item) => MomentModel.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
    };
  }
}
