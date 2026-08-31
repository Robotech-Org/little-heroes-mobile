import '../../domain/entities/notification_entity.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationEntity>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: '1',
      title: 'New Teacher Message',
      message: 'Your teacher sent you a new message.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
      type: NotificationType.message,
    ),

    NotificationEntity(
      id: '2',
      title: 'Assignment Submitted',
      message: 'A new assignment has been submitted.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      type: NotificationType.assignment,
    ),

    NotificationEntity(
      id: '3',
      title: 'Attendance Updated',
      message: 'Student attendance has been updated.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      type: NotificationType.attendance,
    ),

    NotificationEntity(
      id: '4',
      title: 'School Announcement',
      message: 'There is a new announcement from the school.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
      type: NotificationType.announcement,
    ),

    NotificationEntity(
      id: '5',
      title: 'Upcoming Event',
      message: 'Parent meeting is scheduled for tomorrow.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.event,
    ),

    NotificationEntity(
      id: '6',
      title: 'Welcome to Little Heroes',
      message: 'Your account has been successfully created.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.system,
    ),
  ];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index == -1) {
      return;
    }

    final notification = _notifications[index];

    _notifications[index] = NotificationEntity(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      createdAt: notification.createdAt,
      isRead: true,
      type: notification.type,
    );
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];

      _notifications[i] = NotificationEntity(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        createdAt: notification.createdAt,
        isRead: true,
        type: notification.type,
      );
    }
  }
}
