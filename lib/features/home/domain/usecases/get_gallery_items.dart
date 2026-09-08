// lib/features/home/domain/usecases/get_gallery_items.dart
import '../../data/models/gallery_response_model.dart';
import '../repositories/gallery_repository.dart';

class GetGalleryItems {
  final GalleryRepository repository;

  GetGalleryItems(this.repository);

  Future<GalleryResponseModel> call({int page = 1, int pageSize = 20}) async {
    return await repository.getGallery(page: page, pageSize: pageSize);
  }
}
