import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService();

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();

    return status.isGranted;
  }

  Future<bool> isNotificationGranted() async {
    return Permission.notification.isGranted;
  }

  Future<bool> isCameraGranted() async {
    return Permission.camera.isGranted;
  }

  Future<bool> isMicrophoneGranted() async {
    return Permission.microphone.isGranted;
  }

  Future<bool> isLocationGranted() async {
    return Permission.location.isGranted;
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }
}