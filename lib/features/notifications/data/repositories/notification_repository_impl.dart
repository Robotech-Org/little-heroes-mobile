import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await localDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await localDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await localDataSource.markAllAsRead();
  }
}
