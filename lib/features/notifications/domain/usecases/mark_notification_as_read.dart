import '../repositories/notification_repository.dart';

class MarkNotificationAsRead {
  final NotificationRepository repository;

  MarkNotificationAsRead({required this.repository});

  Future<void> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}
