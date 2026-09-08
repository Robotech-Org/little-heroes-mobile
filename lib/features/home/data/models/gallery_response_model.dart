// lib/features/home/data/models/gallery_response_model.dart
import 'gallery_item_model.dart';

class GalleryResponseModel {
  final List<GalleryItemModel> items;
  final int total;
  final int page;
  final int pageSize;

  GalleryResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory GalleryResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? json['data'] ?? {};
    final items = data['items'] as List? ?? [];

    return GalleryResponseModel(
      items: items.map((item) => GalleryItemModel.fromJson(item)).toList(),
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
