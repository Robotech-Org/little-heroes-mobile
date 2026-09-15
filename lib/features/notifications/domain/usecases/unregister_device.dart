import '../repositories/device_notification_repository.dart';

class UnregisterDevice {
  final DeviceNotificationRepository repository;
  UnregisterDevice(this.repository);

  Future<void> call({required String fcmToken}) =>
      repository.unregisterDevice(fcmToken: fcmToken);
}
