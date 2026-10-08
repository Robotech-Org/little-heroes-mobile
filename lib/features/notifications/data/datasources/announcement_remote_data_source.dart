import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/announcement_model.dart';
import '../models/announcement_response_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<AnnouncementResponseModel> getAnnouncements({
    int page = 1,
    int pageSize = 20,
  });

  Future<AnnouncementModel> getAnnouncement(String announcementName);

  Future<AnnouncementModel> updateAnnouncement({
    required String announcementName,
    required Map<String, dynamic> data,
  });
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final Dio dio;

  AnnouncementRemoteDataSourceImpl(this.dio);

  @override
  Future<AnnouncementResponseModel> getAnnouncements({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.listAnnouncements,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.data is Map<String, dynamic>) {
        final result = AnnouncementResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        // Log when the server has nothing — but do NOT replace with mock.
        if (result.items.isEmpty) {
          // debugPrint('ℹ️ [Announcements] Server returned 0 items');
        }

        return result;
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
  Future<AnnouncementModel> getAnnouncement(String announcementName) async {
    try {
      final response = await dio.get(
        ApiConstants.getAnnouncement,
        queryParameters: {'name': announcementName},
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final data = message['data'] ?? {};

      if (data is Map<String, dynamic>) {
        return AnnouncementModel.fromJson(data);
      }

      throw Exception('Announcement not found');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AnnouncementModel> updateAnnouncement({
    required String announcementName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.updateAnnouncement,
        queryParameters: {'name': announcementName},
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final message = responseData['message'] ?? {};
      final announcementData = message['data'] ?? {};

      if (announcementData is Map<String, dynamic>) {
        return AnnouncementModel.fromJson(announcementData);
      }

      throw Exception('Failed to update announcement');
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
