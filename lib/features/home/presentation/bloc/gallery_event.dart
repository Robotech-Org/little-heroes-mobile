// lib/features/home/presentation/bloc/gallery_event.dart
abstract class GalleryEvent {}

class LoadGalleryItems extends GalleryEvent {
  final int page;
  final int pageSize;

  LoadGalleryItems({this.page = 1, this.pageSize = 20});
}

class RefreshGalleryItems extends GalleryEvent {}
