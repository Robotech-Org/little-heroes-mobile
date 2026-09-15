import '../repositories/device_notification_repository.dart';

class MarkNotificationsRead {
  final DeviceNotificationRepository repository;
  MarkNotificationsRead(this.repository);

  Future<List<String>> call({List<String>? ids, bool markAll = false}) =>
      repository.markAsRead(ids: ids, markAll: markAll);
}
