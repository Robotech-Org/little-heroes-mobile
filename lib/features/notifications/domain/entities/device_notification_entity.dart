class DeviceNotificationEntity {
  final String name;
  final String title;
  final String body;
  final String? referenceDoctype;
  final String? referenceName;
  final bool isRead;
  final DateTime createdAt;
  final String? route;

  const DeviceNotificationEntity({
    required this.name,
    required this.title,
    required this.body,
    this.referenceDoctype,
    this.referenceName,
    required this.isRead,
    required this.createdAt,
    this.route,
  });
}
