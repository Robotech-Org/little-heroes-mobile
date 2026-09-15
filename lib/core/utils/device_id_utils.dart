import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdUtils {
  DeviceIdUtils._();

  static String? _cachedId;

  /// Stable device identifier: Android ID (Android) or
  /// identifierForVendor (iOS).
  ///
  /// Pass `useTestId: true` to return "TEST-DEVICE-UUID" (for dev/testing).
  static Future<String> getDeviceId({bool useTestId = false}) async {
    if (useTestId) return 'TEST-DEVICE-UUID';
    if (_cachedId != null) return _cachedId!;

    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      _cachedId = info.id;
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      _cachedId = info.identifierForVendor ?? 'unknown-ios';
    } else {
      _cachedId = 'unknown-platform';
    }

    return _cachedId!;
  }
}
