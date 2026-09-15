import '../../data/models/device_notification_model.dart';
import '../repositories/device_notification_repository.dart';

class GetMyNotifications {
  final DeviceNotificationRepository repository;
  GetMyNotifications(this.repository);

  Future<NotificationPageModel> call({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) => repository.getMyNotifications(
    page: page,
    pageSize: pageSize,
    unreadOnly: unreadOnly,
  );
}
