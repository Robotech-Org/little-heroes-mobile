import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/features/main/domain/entities/user_role.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:little_heroes_mobile/injection_container.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    routes: [
      // ============================================================
      // STARTUP
      // ============================================================

      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) {
          return const SplashPage();
        },
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) {
          return const OnboardingPage();
        },
      ),

      // ============================================================
      // AUTHENTICATION
      // ============================================================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      // OTP Verification
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phoneNumber = state.extra as String;

          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),

      // Register
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),

      // ============================================================
      // MAIN APPLICATION
      // ============================================================
      //
      // MainPage contains:
      //
      // Teacher:
      // Home | Messages | Students | Settings
      //
      // Parent:
      // Home | Messages | Children | Settings
      //
      // Advisor:
      // Home | Messages | Students | Settings
      //
      // ============================================================
      GoRoute(
        path: AppRoutes.main,
        name: 'main',
        builder: (context, state) {
          return const MainPage(role: UserRole.teacher);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) {
          return const MainPage(role: UserRole.teacher);
        },
      ),

      // ============================================================
      // CHATS
      // ============================================================
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Chats')));
        },
      ),

      // ============================================================
      // NOTIFICATIONS
      // ============================================================
      // GoRoute(
      //   path: AppRoutes.notifications,
      //   name: 'notifications',
      //   builder: (context, state) {
      //     return const NotificationsPage();
      //   },
      // ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) {
          return BlocProvider<NotificationBloc>(
            create: (_) => sl<NotificationBloc>(),
            child: const NotificationsPage(),
          );
        },
      ),

      // ============================================================
      // REPORTS
      // ============================================================
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Reports')));
        },
      ),
    ],
  );
}
