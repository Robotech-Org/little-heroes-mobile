import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:little_heroes_mobile/core/router/app_router.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/register_device.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/unregister_device.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static String? _currentToken;

  static String? get currentToken => _currentToken;

  // ─────────────────────────────────────────────
  // INIT (called once from main.dart)
  // ─────────────────────────────────────────────
  static Future<void> initialize() async {
    await _requestPermission();

    // Fetch and cache the current token
    _currentToken = await _messaging.getToken();
    debugPrint('FCM TOKEN xyz: $_currentToken');

    // Foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App in background → user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App was terminated → launched from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Token rotation
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM TOKEN REFRESHED: $newToken');
      _currentToken = newToken;

      await _safeRegister(newToken);
    });
  }

  // ─────────────────────────────────────────────
  // CALLED FROM AUTH BLOC
  // ─────────────────────────────────────────────

  /// Register this device with the backend. Called on login success.
  static Future<void> registerCurrentDevice() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('NotificationService: no FCM token to register');
      return;
    }
    _currentToken = token;
    await _safeRegister(token);
  }

  /// Unregister this device. Called on logout.
  static Future<void> unregisterCurrentDevice() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await di.sl<UnregisterDevice>()(fcmToken: token);
      debugPrint('NotificationService: device unregistered');
    } catch (e) {
      debugPrint('NotificationService unregister failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // INTERNALS
  // ─────────────────────────────────────────────

  static Future<void> _safeRegister(String token) async {
    try {
      await di.sl<RegisterDevice>()(
        fcmToken: token,
        platform: Platform.isIOS ? 'iOS' : 'Android',
      );
      // debugPrint('NotificationService: device registered ($token)');
    } catch (e) {
      debugPrint('NotificationService register failed: $e');
    }
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Notification received in foreground');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // If you later add local notifications, show them here.
    // For now, routing the tap is enough.
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');

    final route = message.data['route'] as String?;
    if (route == null || route.isEmpty) return;

    _navigateToRoute(route);
  }

  /// Map backend route (e.g. `/daily-reports/DR-2026-0042`)
  /// to Flutter GoRouter path.
  static void _navigateToRoute(String route) {
    try {
      if (route.startsWith('/daily-reports/')) {
        final id = route.split('/').last;
        AppRouter.router.push('/daily-report-detail', extra: id);
        return;
      }
      if (route.startsWith('/observations/')) {
        final id = route.split('/').last;
        AppRouter.router.push('/observation-detail', extra: id);
        return;
      }
      if (route.startsWith('/announcements/')) {
        final id = route.split('/').last;
        AppRouter.router.push('/announcement-detail', extra: id);
        return;
      }
      if (route.startsWith('/chat/')) {
        final id = route.split('/').last;
        AppRouter.router.push('/chat', extra: id);
        return;
      }
      if (route.startsWith('/moments/')) {
        final id = route.split('/').last;
        AppRouter.router.push('/moment-detail', extra: id);
        return;
      }
      debugPrint('Unknown notification route: $route');
    } catch (e) {
      debugPrint('Route navigation failed: $e');
    }
  }
}
