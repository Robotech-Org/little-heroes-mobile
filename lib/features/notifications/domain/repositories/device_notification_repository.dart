import '../../data/models/device_notification_model.dart';

abstract class DeviceNotificationRepository {
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceName,
  });

  Future<NotificationPageModel> getMyNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  });

  Future<List<String>> markAsRead({List<String>? ids, bool markAll = false});

  Future<void> unregisterDevice({required String fcmToken});
}
