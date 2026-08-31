import 'package:flutter/material.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  message,
  assignment,
  attendance,
  announcement,
  event,
  system,
}

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.message:
        return Icons.message_outlined;

      case NotificationType.assignment:
        return Icons.assignment_outlined;

      case NotificationType.attendance:
        return Icons.fact_check_outlined;

      case NotificationType.announcement:
        return Icons.campaign_outlined;

      case NotificationType.event:
        return Icons.event_outlined;

      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }
}
