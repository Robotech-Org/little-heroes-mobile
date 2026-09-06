import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:little_heroes_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/observations_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/three_month_reports_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/weekly_planner_page.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/main_page.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/settings_page.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:little_heroes_mobile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:little_heroes_mobile/features/splash/presentation/pages/splash_page.dart';

import 'package:little_heroes_mobile/injection_container.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    routes: [
      // STARTUP

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

      // AUTHENTICATION
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      // GoRoute(
      //   path: AppRoutes.otpVerification,
      //   name: 'otpVerification',
      //   builder: (context, state) {
      //     final phoneNumber = state.extra as String;

      //     return OtpVerificationPage(phoneNumber: phoneNumber);
      //   },
      // ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return OtpVerificationPage(
            phoneNumber: extra['phoneNumber'] as String,
            tmpId: extra['tmpId'] as String,
          );
        },
      ),

      // MAIN APPLICATION
      GoRoute(
        path: AppRoutes.main,
        name: 'main',
        builder: (context, state) {
          return const MainPage();
        },
      ),

      // CHATS
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Chats')));
        },
      ),

      // NOTIFICATIONS
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

      // REPORTS
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Reports')));
        },
      ),

      // SETTINGS
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) {
          return const SettingsPage();
        },
      ),

      // TEACHER TOOLS
      GoRoute(
        path: AppRoutes.dailyReport,
        name: 'dailyReport',
        builder: (context, state) {
          return const DailyReportPage();
        },
      ),

      GoRoute(
        path: AppRoutes.threeMonthReports,
        name: 'threeMonthReports',
        builder: (context, state) {
          return const ThreeMonthReportsPage();
        },
      ),

      GoRoute(
        path: AppRoutes.weeklyPlanner,
        name: 'weeklyPlanner',
        builder: (context, state) {
          return const WeeklyPlansPage();
        },
      ),

      GoRoute(
        path: AppRoutes.observations,
        name: 'observations',
        builder: (context, state) {
          return const ObservationsPage();
        },
      ),
    ],
  );
}
