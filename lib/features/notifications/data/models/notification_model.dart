import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    required super.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      type: _parseType(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type.name,
    };
  }

  static NotificationType _parseType(dynamic value) {
    switch (value) {
      case 'message':
        return NotificationType.message;

      case 'assignment':
        return NotificationType.assignment;

      case 'attendance':
        return NotificationType.attendance;

      case 'announcement':
        return NotificationType.announcement;

      case 'event':
        return NotificationType.event;

      default:
        return NotificationType.system;
    }
  }
}
