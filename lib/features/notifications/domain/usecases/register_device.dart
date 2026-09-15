import '../repositories/device_notification_repository.dart';

class RegisterDevice {
  final DeviceNotificationRepository repository;
  RegisterDevice(this.repository);

  Future<void> call({
    required String fcmToken,
    required String platform,
    String? deviceName,
  }) => repository.registerDevice(
    fcmToken: fcmToken,
    platform: platform,
    deviceName: deviceName,
  );
}
