// lib/features/payments/data/models/subscription_plan_response_model.dart
import 'subscription_plan_model.dart';

class SubscriptionPlanResponseModel {
  final List<SubscriptionPlanModel> items;
  final int total;
  final int page;
  final int pageSize;

  SubscriptionPlanResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory SubscriptionPlanResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested response structure from Frappe
    final message = json['message'] ?? {};
    final data = message['data'] ?? json['data'] ?? {};
    final items = data['items'] as List? ?? [];

    return SubscriptionPlanResponseModel(
      items: items.map((item) => SubscriptionPlanModel.fromJson(item)).toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
    };
  }
}
