import 'invoice_model.dart';

class InvoiceResponseModel {
  final bool success;
  final List<InvoiceModel> items;
  final String message;

  InvoiceResponseModel({
    required this.success,
    required this.items,
    required this.message,
  });

  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<InvoiceModel> items = [];

    if (data is List) {
      items = data
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      items = (data['items'] as List)
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return InvoiceResponseModel(
      success: json['success'] == true,
      items: items,
      message: json['message']?.toString() ?? '',
    );
  }
}
