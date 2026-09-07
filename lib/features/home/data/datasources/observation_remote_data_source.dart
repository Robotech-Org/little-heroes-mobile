import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/observation_model.dart';
import '../models/observation_response_model.dart';

abstract class ObservationRemoteDataSource {
  Future<ObservationResponseModel> getObservations({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  });

  Future<ObservationModel> createObservation(Map<String, dynamic> data);

  Future<ObservationModel> getObservation(String observationId);

  Future<ObservationModel> updateObservation(
    String observationId,
    Map<String, dynamic> data,
  );

  Future<void> deleteObservation(String observationId);
  Future<String> uploadObservationFile({
    required String fileName,
    required String filePath,
  });
}

class ObservationRemoteDataSourceImpl implements ObservationRemoteDataSource {
  final Dio dio;

  ObservationRemoteDataSourceImpl(this.dio);

  @override
  Future<ObservationResponseModel> getObservations({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (student != null && student.isNotEmpty) {
        queryParams['student'] = student;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await dio.get(
        ApiConstants.listObservations,
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        return ObservationResponseModel.fromJson(response.data);
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
  Future<ObservationModel> createObservation(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstants.createObservation,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final observationData = message['data'] ?? {};

      if (observationData is Map<String, dynamic>) {
        return ObservationModel.fromJson(observationData);
      }

      throw Exception('Failed to create observation');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ObservationModel> getObservation(String observationId) async {
    try {
      final response = await dio.get(
        ApiConstants.getObservation,
        queryParameters: {'name': observationId},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return ObservationModel.fromJson(data);
      }

      throw Exception('Observation not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ObservationModel> updateObservation(
    String observationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(
        ApiConstants.updateObservation,
        queryParameters: {'name': observationId},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final observationData = message['data'] ?? {};

      if (observationData is Map<String, dynamic>) {
        return ObservationModel.fromJson(observationData);
      }

      throw Exception('Failed to update observation');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteObservation(String observationId) async {
    try {
      await dio.delete(
        ApiConstants.deleteObservation,
        queryParameters: {'name': observationId},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // UPLOAD OBSERVATION FILE
  // ============================================================

  @override
  Future<String> uploadObservationFile({
    required String fileName,
    required String filePath,
  }) async {
    try {
      // Create FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'file_name': fileName,
      });

      final response = await dio.post(
        ApiConstants.uploadObservationFile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      // Return the file URL or name
      return data['file_url']?.toString() ??
          data['file_name']?.toString() ??
          '';
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
