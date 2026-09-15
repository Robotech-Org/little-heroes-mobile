import '../../domain/entities/device_notification_entity.dart';

class DeviceNotificationModel extends DeviceNotificationEntity {
  const DeviceNotificationModel({
    required super.name,
    required super.title,
    required super.body,
    super.referenceDoctype,
    super.referenceName,
    required super.isRead,
    required super.createdAt,
    super.route,
  });

  factory DeviceNotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return DeviceNotificationModel(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      referenceDoctype: json['reference_doctype'] as String?,
      referenceName: json['reference_name'] as String?,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: _parseDate(json['created_at'] as String?),
      route: data['route'] as String?,
    );
  }

  static DateTime _parseDate(String? s) {
    if (s == null || s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s.replaceFirst(' ', 'T')) ?? DateTime.now();
  }

  DeviceNotificationModel copyWith({bool? isRead}) => DeviceNotificationModel(
    name: name,
    title: title,
    body: body,
    referenceDoctype: referenceDoctype,
    referenceName: referenceName,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    route: route,
  );
}

class NotificationPageModel {
  final int unreadCount;
  final int page;
  final int pageSize;
  final List<DeviceNotificationModel> items;

  const NotificationPageModel({
    required this.unreadCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });
}
