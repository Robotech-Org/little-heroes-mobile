// lib/features/home/presentation/bloc/gallery_state.dart
import '../../domain/entities/gallery_item.dart';

abstract class GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<GalleryItem> items;
  final int total;
  final int currentPage;
  final bool hasMore;

  GalleryLoaded({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.hasMore,
  });
}

class GalleryError extends GalleryState {
  final String message;

  GalleryError(this.message);
}
