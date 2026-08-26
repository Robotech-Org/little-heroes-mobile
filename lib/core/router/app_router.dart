import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,

    routes: [
      // =========================
      // Authentication
      // =========================

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Login'),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('Register'),
            ),
          );
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