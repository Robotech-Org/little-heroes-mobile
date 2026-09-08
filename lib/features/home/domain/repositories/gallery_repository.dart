// lib/features/home/domain/repositories/gallery_repository.dart
import '../../data/models/gallery_response_model.dart';

abstract class GalleryRepository {
  Future<GalleryResponseModel> getGallery({int page = 1, int pageSize = 20});
}
