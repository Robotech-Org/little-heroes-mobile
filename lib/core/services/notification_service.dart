import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _requestPermission();

    final token = await _messaging.getToken();

    print('FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM TOKEN REFRESHED: $newToken');

      // Send newToken to your backend.
    });
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Notification received in foreground');

    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped');

    print('Data: ${message.data}');

    // Navigate to the appropriate screen here.
  }
}
