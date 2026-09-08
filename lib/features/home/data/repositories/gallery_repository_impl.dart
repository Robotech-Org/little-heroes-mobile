// lib/features/home/data/repositories/gallery_repository_impl.dart
import '../../domain/repositories/gallery_repository.dart';
import '../datasources/gallery_remote_data_source.dart';
import '../models/gallery_response_model.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryRemoteDataSource remoteDataSource;

  GalleryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GalleryResponseModel> getGallery({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await remoteDataSource.getGallery(page: page, pageSize: pageSize);
  }
}
