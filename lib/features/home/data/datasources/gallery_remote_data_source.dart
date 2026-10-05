import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/gallery_response_model.dart';

abstract class GalleryRemoteDataSource {
  Future<GalleryResponseModel> getGallery({int page = 1, int pageSize = 20});
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final Dio dio;

  GalleryRemoteDataSourceImpl(this.dio);

  @override
  Future<GalleryResponseModel> getGallery({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listGallery,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        return GalleryResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
