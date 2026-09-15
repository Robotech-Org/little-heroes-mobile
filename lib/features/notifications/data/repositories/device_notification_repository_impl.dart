import '../../domain/repositories/device_notification_repository.dart';
import '../datasources/device_notification_remote_data_source.dart';
import '../models/device_notification_model.dart';

class DeviceNotificationRepositoryImpl implements DeviceNotificationRepository {
  final DeviceNotificationRemoteDataSource remoteDataSource;

  DeviceNotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceName,
  }) => remoteDataSource.registerDevice(
    fcmToken: fcmToken,
    platform: platform,
    deviceName: deviceName,
  );

  @override
  Future<NotificationPageModel> getMyNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) => remoteDataSource.getMyNotifications(
    page: page,
    pageSize: pageSize,
    unreadOnly: unreadOnly,
  );

  @override
  Future<List<String>> markAsRead({List<String>? ids, bool markAll = false}) =>
      remoteDataSource.markAsRead(ids: ids, markAll: markAll);

  @override
  Future<void> unregisterDevice({required String fcmToken}) =>
      remoteDataSource.unregisterDevice(fcmToken: fcmToken);
}
