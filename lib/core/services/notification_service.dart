import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_router.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/register_device.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/unregister_device.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _currentToken;
  static String? get currentToken => _currentToken;

  // ─────────────────────────────────────────────
  // PENDING ROUTE QUEUE (for cold start)
  // ─────────────────────────────────────────────
  static String? _pendingRoute;
  static Map<String, dynamic>? _pendingData;

  // ─────────────────────────────────────────────
  // INIT  ← FIXED (waits for APNs token on iOS)
  // ─────────────────────────────────────────────
  static Future<void> initialize() async {
    // 1. Ask permission first
    await _requestPermission();

    // 2. iOS ONLY — wait for APNs token before requesting FCM token
    if (Platform.isIOS) {
      final apns = await _waitForApnsToken();
      if (apns == null) {
        debugPrint('❌ APNs token never arrived — check Xcode Push capability');
      } else {
        debugPrint('✅ APNs token received: $apns');
      }
    }

    // 3. Now safe to fetch FCM token (retry loop)
    _currentToken = await _getFcmTokenSafely();
    debugPrint('FCM TOKEN xyz: $_currentToken');

    // 4. Wire listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken;
      await _safeRegister(newToken);
    });
  }

  // ─────────────────────────────────────────────
  // WAIT FOR APNs TOKEN (iOS only)
  // ─────────────────────────────────────────────
  static Future<String?> _waitForApnsToken({
    int maxRetries = 15,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        final apns = await _messaging.getAPNSToken();
        if (apns != null && apns.isNotEmpty) return apns;
      } catch (e) {
        debugPrint('APNs attempt $i: $e');
      }
      await Future.delayed(delay);
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // SAFE FCM TOKEN FETCH (retry loop)
  // ─────────────────────────────────────────────
  static Future<String?> _getFcmTokenSafely({int maxRetries = 5}) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('FCM token attempt $i: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // REGISTER / UNREGISTER
  // ─────────────────────────────────────────────
  static Future<void> registerCurrentDevice() async {
    final token = _currentToken ?? await _getFcmTokenSafely();
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No FCM token — cannot register device');
      return;
    }
    _currentToken = token;
    await _safeRegister(token);
  }

  static Future<void> unregisterCurrentDevice() async {
    final token = _currentToken ?? await _getFcmTokenSafely();
    if (token == null || token.isEmpty) return;
    try {
      await di.sl<UnregisterDevice>()(fcmToken: token);
    } catch (e) {
      debugPrint('unregister failed: $e');
    }
  }

  static Future<void> _safeRegister(String token) async {
    try {
      await di.sl<RegisterDevice>()(
        fcmToken: token,
        platform: Platform.isIOS ? 'iOS' : 'Android',
      );
    } catch (e) {
      debugPrint('register failed: $e');
    }
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.data}');
  }

  // ─────────────────────────────────────────────
  // TAP HANDLER
  // ─────────────────────────────────────────────
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');

    final route = message.data['route'] as String?;
    if (route == null || route.isEmpty) return;

    _pendingRoute = route;
    _pendingData = message.data;

    _tryFlushPending();
  }

  static void onAppReady() => _tryFlushPending();

  static void _tryFlushPending() {
    if (_pendingRoute == null) return;

    try {
      if (!StorageService.instance.isLoggedIn()) {
        debugPrint('⏸ Auth not ready — queueing notification route');
        return;
      }
    } catch (_) {
      debugPrint('⏸ Storage not ready — queueing notification route');
      return;
    }

    final route = _pendingRoute!;
    final data = _pendingData;
    _pendingRoute = null;
    _pendingData = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToRoute(route, data: data);
    });
  }

  // ═════════════════════════════════════════════════════════════
  // ROUTER
  // ═════════════════════════════════════════════════════════════
  static Future<void> _navigateToRoute(
    String route, {
    String? title,
    Map<String, dynamic>? data,
  }) async {
    try {
      final role = _safeRole();
      final isParent = role == UserRole.parent;

      // ── Daily report ────────────────────────────────────
      if (route.startsWith('/daily-reports')) {
        final reportId = route.split('/').last;

        String studentId = data?['studentId']?.toString() ?? '';
        String studentName = data?['studentName']?.toString() ?? '';

        if (studentId.isEmpty && reportId.isNotEmpty) {
          try {
            final repo = di.sl<DailyReportRepository>();
            final response = await repo.getDailyReports(page: 1, pageSize: 100);

            final match = response.items.firstWhere(
              (r) => r.name == reportId,
              orElse: () => throw StateError('report not found'),
            );
            studentId = match.student;
            studentName = match.studentName;
          } catch (e) {
            debugPrint('⚠️ Could not fetch report $reportId: $e');
          }
        }

        if (isParent && studentId.isEmpty && studentName.isEmpty) {
          debugPrint('❌ No student info — cannot route to parent daily report');
          _goHome();
          return;
        }

        if (isParent) {
          AppRouter.router.push(
            AppRoutes.parentDailyReport,
            extra: {
              'studentId': studentId,
              'studentName': studentName,
              'reportId': reportId,
            },
          );
        } else {
          AppRouter.router.push(AppRoutes.dailyReportDetail, extra: reportId);
        }
        return;
      }

      // ── Three-month report ──────────────────────────────
      if (route.startsWith('/three-month-report')) {
        final id = route.split('/').last;
        if (isParent) {
          AppRouter.router.push(
            AppRoutes.threeMonthReportsParents,
            extra: {
              'studentId': data?['studentId']?.toString() ?? '',
              'studentName': data?['studentName']?.toString() ?? '',
            },
          );
        } else {
          AppRouter.router.push(AppRoutes.threeMonthReports, extra: id);
        }
        return;
      }

      // ── Observations (teacher only) ─────────────────────
      if (route.startsWith('/observations/')) {
        if (isParent) {
          _goHome();
          return;
        }
        final id = route.split('/').last;
        AppRouter.router.push(AppRoutes.observationDetail, extra: id);
        return;
      }

      // ── Announcements (both) ────────────────────────────
      if (route.startsWith('/announcements/')) {
        final id = route.split('/').last;
        AppRouter.router.push(AppRoutes.announcementDetail, extra: id);
        return;
      }

      // ── Chat (both) ─────────────────────────────────────
      if (route.startsWith('/chat/')) {
        final segments = route.split('/').where((s) => s.isNotEmpty).toList();
        if (segments.length < 2) {
          _goHome();
          return;
        }
        AppRouter.router.push(
          AppRoutes.chat,
          extra: {'channelId': segments[1], 'title': title ?? 'Chat'},
        );
        return;
      }

      // ── Gallery (parent only) ───────────────────────────
      if (route == '/gallery' || route == '/galleries') {
        if (!isParent) {
          _goHome();
          return;
        }
        AppRouter.router.push(AppRoutes.photoGallery);
        return;
      }
      if (route.startsWith('/galleries/')) {
        if (!isParent) {
          _goHome();
          return;
        }
        final id = route.split('/').last;
        AppRouter.router.push(AppRoutes.galleryPhoto, extra: {'itemId': id});
        return;
      }

      // ── Moment (both) ───────────────────────────────────
      if (route.startsWith('/moments/')) {
        final id = route.split('/').last;
        AppRouter.router.push(AppRoutes.momentDetail, extra: id);
        return;
      }

      // ── Newsletter (both) ───────────────────────────────
      if (route.startsWith('/newsletters/')) {
        final id = route.split('/').last;
        AppRouter.router.push(AppRoutes.newsletterDetail, extra: id);
        return;
      }

      // ── Attendance (teacher only) ───────────────────────
      if (route.startsWith('/attendance')) {
        if (isParent) {
          _goHome();
          return;
        }
        AppRouter.router.push(AppRoutes.attendanceList);
        return;
      }

      debugPrint('Unknown notification route: $route — going home');
      _goHome();
    } catch (e) {
      debugPrint('Route navigation failed: $e');
      _goHome();
    }
  }

  // ─────────────────────────────────────────────
  // FALLBACK
  // ─────────────────────────────────────────────
  static void _goHome() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.router.go(AppRoutes.main);
      });
    } catch (e) {
      debugPrint('Could not navigate home: $e');
    }
  }

  // ─────────────────────────────────────────────
  // ROLE HELPER
  // ─────────────────────────────────────────────
  static UserRole _safeRole() {
    try {
      return StorageService.instance.getUserRole();
    } catch (e) {
      debugPrint('role read failed: $e');
      return UserRole.parent;
    }
  }
}
