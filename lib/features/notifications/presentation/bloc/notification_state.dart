import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  List<NotificationEntity> get unreadNotifications {
    return notifications.where((notification) => !notification.isRead).toList();
  }

  int get unreadCount {
    return unreadNotifications.length;
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
