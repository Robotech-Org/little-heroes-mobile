// lib/features/payments/data/models/subscription_plan_model.dart
class SubscriptionPlanModel {
  final String name;
  final String planName;
  final String item;
  final String currency;
  final String priceDetermination;
  final double cost;
  final String billingInterval;
  final int billingIntervalCount;
  final String creation;
  final String modified;

  SubscriptionPlanModel({
    required this.name,
    required this.planName,
    required this.item,
    required this.currency,
    required this.priceDetermination,
    required this.cost,
    required this.billingInterval,
    required this.billingIntervalCount,
    required this.creation,
    required this.modified,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      name: json['name']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      item: json['item']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      priceDetermination: json['price_determination']?.toString() ?? '',
      cost: json['cost']?.toDouble() ?? 0.0,
      billingInterval: json['billing_interval']?.toString() ?? '',
      billingIntervalCount: json['billing_interval_count'] ?? 1,
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'plan_name': planName,
      'item': item,
      'currency': currency,
      'price_determination': priceDetermination,
      'cost': cost,
      'billing_interval': billingInterval,
      'billing_interval_count': billingIntervalCount,
      'creation': creation,
      'modified': modified,
    };
  }

  String get formattedCost => '$cost $currency';
  String get billingText => 'Every $billingIntervalCount $billingInterval';
}

// lib/features/payments/data/models/subscription_plan_response_model.dart
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
}
