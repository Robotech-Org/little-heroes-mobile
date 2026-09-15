import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../models/device_notification_model.dart';

abstract class DeviceNotificationRemoteDataSource {
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceName,
  });

  Future<NotificationPageModel> getMyNotifications({
    int page,
    int pageSize,
    bool unreadOnly,
  });

  Future<List<String>> markAsRead({List<String>? ids, bool markAll});

  Future<void> unregisterDevice({required String fcmToken});
}

class DeviceNotificationRemoteDataSourceImpl
    implements DeviceNotificationRemoteDataSource {
  final Dio dio;

  DeviceNotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceName,
  }) async {
    try {
      await dio.post(
        ApiConstants.registerDevice,
        data: {
          'fcm_token': fcmToken,
          'platform': platform,
          if (deviceName != null) 'device_name': deviceName,
        },
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<NotificationPageModel> getMyNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.getMyNotifications,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'unread_only': unreadOnly ? 1 : 0,
        },
      );

      final message = response.data['message'] ?? {};
      final data = message['data'] ?? {};

      final items = (data['items'] as List? ?? [])
          .map(
            (e) => DeviceNotificationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      return NotificationPageModel(
        unreadCount: data['unread_count'] as int? ?? 0,
        page: data['page'] as int? ?? page,
        pageSize: data['page_size'] as int? ?? pageSize,
        items: items,
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<List<String>> markAsRead({
    List<String>? ids,
    bool markAll = false,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.markNotificationsRead,
        data: markAll ? {'mark_all': true} : {'notification_ids': ids ?? []},
      );

      final marked =
          (response.data['message']?['data']?['marked_ids'] as List? ?? [])
              .map((e) => e.toString())
              .toList();
      return marked;
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }

  @override
  Future<void> unregisterDevice({required String fcmToken}) async {
    try {
      await dio.post(
        ApiConstants.unregisterDevice,
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      DioErrorHandler.handle(e);
      rethrow;
    }
  }
}
