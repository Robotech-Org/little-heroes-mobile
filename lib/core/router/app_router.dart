import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    routes: [
      // =========================
      // Startup
      // =========================

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

      // =========================
      // Authentication
      // =========================

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),

      // =========================
      // Main
      // =========================

      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Home'),
            ),
          );
        },
      ),

      // =========================
      // Chats
      // =========================

      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Chats'),
            ),
          );
        },
      ),

      // =========================
      // Notifications
      // =========================

      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Notifications'),
            ),
          );
        },
      ),

      // =========================
      // Reports
      // =========================

      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Reports'),
            ),
          );
        },
      ),
    ],
  );
}