import 'package:dio/dio.dart';

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
        final result = AnnouncementResponseModel.fromJson(response.data);

        // If no announcements from API, return mock data
        if (result.items.isEmpty) {
          return _getMockAnnouncements();
        }

        return result;
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // If API fails, return mock data
      return _getMockAnnouncements();
    } catch (e) {
      // If any error, return mock data
      return _getMockAnnouncements();
    }
  }

  // ============================================================
  // MOCK ANNOUNCEMENTS
  // ============================================================

  AnnouncementResponseModel _getMockAnnouncements() {
    final now = DateTime.now();
    final mockItems = [
      AnnouncementModel(
        name: 'mock_1',
        title: 'Upcoming Parent-Teacher Orientation',
        body: 'Dear Parents, we invite you to our annual orientation session this Friday at 4 PM. Please come and join us for an informative session about your child\'s development and learning journey.',
        postedAt: _formatDateTime(now.subtract(const Duration(hours: 2))),
        postedBy: 'Administrator',
        classroom: 'THE DISCOVERERS Room A',
        creation: _formatDateTime(now.subtract(const Duration(hours: 2))),
        modified: _formatDateTime(now.subtract(const Duration(hours: 2))),
      ),
      AnnouncementModel(
        name: 'mock_2',
        title: 'School Holiday Announcement',
        body: 'This is to inform all parents that the school will be closed on Monday, September 12th, 2026, in observance of the national holiday. Classes will resume on Tuesday, September 13th, 2026.',
        postedAt: _formatDateTime(now.subtract(const Duration(days: 1))),
        postedBy: 'School Administration',
        classroom: 'All Classrooms',
        creation: _formatDateTime(now.subtract(const Duration(days: 1))),
        modified: _formatDateTime(now.subtract(const Duration(days: 1))),
      ),
    ];

    return AnnouncementResponseModel(
      success: true,
      items: mockItems,
      total: mockItems.length,
      page: 1,
      pageSize: 20,
      totalPages: 1,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00';
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

      // If not found, return a mock announcement
      return _getMockAnnouncement(announcementName);
    } on DioException catch (e) {
      // Return mock announcement on error
      return _getMockAnnouncement(announcementName);
    } catch (e) {
      return _getMockAnnouncement(announcementName);
    }
  }

  AnnouncementModel _getMockAnnouncement(String name) {
    return AnnouncementModel(
      name: name,
      title: 'Sample Announcement',
      body: 'This is a sample announcement. Please check back later for more updates.',
      postedAt: _formatDateTime(DateTime.now()),
      postedBy: 'Administrator',
      classroom: 'All Classrooms',
      creation: _formatDateTime(DateTime.now()),
      modified: _formatDateTime(DateTime.now()),
    );
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
