import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/moment_model.dart';
import '../models/moment_response_model.dart';

abstract class MomentRemoteDataSource {
  Future<MomentResponseModel> getMoments({
    int page = 1,
    int pageSize = 20,
    Map<String, String>? filters,
  });

  Future<MomentModel> getMoment(String momentName);

  Future<MomentModel> createMoment(Map<String, dynamic> data);

  Future<MomentModel> updateMoment({
    required String momentName,
    required Map<String, dynamic> data,
  });

  Future<void> deleteMoment(String momentName);

  Future<void> approveMoment(String momentName);

  Future<void> denyMoment(String momentName);

  Future<String> uploadMomentFile({
    required String fileName,
    required String filePath,
  });
}

class MomentRemoteDataSourceImpl implements MomentRemoteDataSource {
  final Dio dio;

  MomentRemoteDataSourceImpl(this.dio);

  @override
  Future<MomentResponseModel> getMoments({
    int page = 1,
    int pageSize = 20,
    Map<String, String>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (filters != null && filters.isNotEmpty) {
        queryParams['filters'] = filters;
      }

      final response = await dio.get(
        ApiConstants.listMoments,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return MomentResponseModel.fromJson(response.data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<MomentModel> getMoment(String momentName) async {
    try {
      final response = await dio.get(
        ApiConstants.getMoment,
        queryParameters: {'name': momentName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return MomentModel.fromJson(data);
      }

      throw Exception('Moment not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<MomentModel> createMoment(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.createMoment, data: data);

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final momentData = message['data'] ?? {};

      if (momentData is Map<String, dynamic>) {
        return MomentModel.fromJson(momentData);
      }

      throw Exception('Failed to create moment');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<MomentModel> updateMoment({
    required String momentName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.updateMoment,
        queryParameters: {'name': momentName},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final momentData = message['data'] ?? {};

      if (momentData is Map<String, dynamic>) {
        return MomentModel.fromJson(momentData);
      }

      throw Exception('Failed to update moment');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteMoment(String momentName) async {
    try {
      await dio.delete(
        ApiConstants.deleteMoment,
        queryParameters: {'name': momentName},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> approveMoment(String momentName) async {
    try {
      await dio.post(
        ApiConstants.approveMoment,
        queryParameters: {'name': momentName},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> denyMoment(String momentName) async {
    try {
      await dio.post(
        ApiConstants.denyMoment,
        queryParameters: {'name': momentName},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadMomentFile({
    required String fileName,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'fieldname': 'moment_photo',
        'doctype': 'Moment',
        'docname': '',
        'is_private': 0,
      });

      final response = await dio.post(
        ApiConstants.uploadMomentFile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      final fileUrl = data['file_url']?.toString() ?? '';
      if (fileUrl.isEmpty) {
        final messageFileUrl = message['file_url']?.toString();
        if (messageFileUrl != null && messageFileUrl.isNotEmpty) {
          return messageFileUrl;
        }
        throw Exception('File uploaded but no file_url returned');
      }

      return fileUrl;
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
