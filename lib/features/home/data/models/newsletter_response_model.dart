import 'newsletter_model.dart';

class NewsletterResponseModel {
  final List<NewsletterModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  NewsletterResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory NewsletterResponseModel.fromJson(Map<String, dynamic> json) {
    // Frappe wrapper: { message: { success, data: { items, total, page, ... } } }
    final message = json['message'];
    final inner = message is Map ? Map<String, dynamic>.from(message) : json;
    final data = inner['data'];
    final body = data is Map ? Map<String, dynamic>.from(data) : inner;

    final rawItems = body['items'];
    final items = <NewsletterModel>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map) {
          items.add(NewsletterModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return NewsletterResponseModel(
      items: items,
      total: (body['total'] as num?)?.toInt() ?? items.length,
      page: (body['page'] as num?)?.toInt() ?? 1,
      pageSize: (body['page_size'] as num?)?.toInt() ?? 20,
      totalPages: (body['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}
