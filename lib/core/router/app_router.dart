import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/features/attendance/presentation/pages/attendance_list_page.dart';
import 'package:little_heroes_mobile/features/attendance/presentation/pages/classroom_punch_in_page.dart';
import 'package:little_heroes_mobile/features/attendance/presentation/pages/classroom_punch_out_page.dart';
import 'package:little_heroes_mobile/features/attendance/presentation/pages/gate_attendance_page.dart';

import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:little_heroes_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:little_heroes_mobile/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chats_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/moment_show.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/newsletter_detail_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/newsletter_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/add_moment_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/add_observation_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/daily_report_detail_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/daily_report_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/observation_detail_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/observations_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/three_month_reports_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/weekly_planner_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/share_with_parents_page.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/main_page.dart';
import 'package:little_heroes_mobile/features/main/presentation/pages/settings_page.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notification_detail_page.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:little_heroes_mobile/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:little_heroes_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:little_heroes_mobile/injection_container.dart';

import '../../core/services/storage_service.dart';
import 'app_routes.dart';
import 'page_not_found.dart';

class AppRouter {
  AppRouter._();

  /// Root navigator key — used by SessionManager to show a snackbar
  /// on top of whatever route is currently showing.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey, // 👈 add this

    initialLocation: AppRoutes.splash,

    // ═══════════════════════════════════════════════════════════
    // NOT FOUND — shown when no route matches the URL
    // ═══════════════════════════════════════════════════════════
    errorBuilder: (context, state) {
      debugPrint('⚠️ Route not found: ${state.uri}');
      debugPrint('   Error: ${state.error}');

      return PageNotFound(location: state.uri.toString(), error: state.error);
    },

    // ═══════════════════════════════════════════════════════════
    // REDIRECT — Handle authentication state
    // ═══════════════════════════════════════════════════════════
    redirect: (context, state) {
      // Don't redirect on splash screen
      if (state.uri.path == AppRoutes.splash) {
        return null;
      }

      // Get auth state
      final authState = context.read<AuthBloc>().state;

      // Check if user is logged in from storage
      final isLoggedIn = StorageService.instance.isLoggedIn();

      // Define public routes (no authentication required)
      final publicRoutes = [
        AppRoutes.login,
        AppRoutes.onboarding,
        AppRoutes.otpVerification,
        AppRoutes.splash,
      ];

      // ── UNAUTHENTICATED → login ────────────────────
      if (authState is AuthUnauthenticated || !isLoggedIn) {
        if (!publicRoutes.contains(state.uri.path)) {
          return AppRoutes.login;
        }
        return null;
      }

      // ── AUTHENTICATED → main ───────────────────────
      if (authState is AuthAuthenticated && isLoggedIn) {
        if (publicRoutes.contains(state.uri.path)) {
          return AppRoutes.main;
        }
        return null;
      }

      return null;
    },

    routes: [
      // ═══════════════════════════════════════════════════════════
      // STARTUP
      // ═══════════════════════════════════════════════════════════
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

      // ═══════════════════════════════════════════════════════════
      // AUTHENTICATION
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

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

      // ═══════════════════════════════════════════════════════════
      // MAIN
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.main,
        name: 'main',
        builder: (context, state) {
          return const MainPage();
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // CHATS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Chats')));
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // NOTIFICATIONS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) {
          return const NotificationsPage(isFullPage: true);
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // REPORTS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Reports')));
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // SETTINGS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.newsletters,
        name: 'newsletters',
        builder: (context, state) => const NewsletterPage(),
      ),
      GoRoute(
        path: AppRoutes.newsletterDetail,
        name: 'newsletterDetail',
        builder: (context, state) {
          final id = state.extra as String? ?? '';
          return NewsletterDetailPage(newsletterName: id);
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // TEACHER TOOLS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.dailyReport,
        name: 'dailyReport',
        builder: (context, state) {
          final studentName = state.uri.queryParameters['studentName'] ?? '';
          final studentId = state.uri.queryParameters['studentId'] ?? '';

          return DailyReportPage(
            studentName: studentName,
            studentId: studentId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dailyReport_teachers,
        name: 'dailyReport_teachers',
        builder: (context, state) {
          return const DailyReportPageTeachers();
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
          return const WeeklyPlannerPage();
        },
      ),

      GoRoute(
        path: AppRoutes.observations,
        name: 'observations',
        builder: (context, state) {
          return const ObservationsPage();
        },
      ),

      GoRoute(
        path: AppRoutes.addMoment,
        name: 'addMoment',
        builder: (context, state) => const AddMomentPage(),
      ),
      GoRoute(
        path: AppRoutes.Compile_3_onth_report,
        name: 'shareWithParents',
        builder: (context, state) => const ShareWithParentsPage(),
      ),

      // ═══════════════════════════════════════════════════════════
      // DEEP-LINK TARGETS
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.dailyReportDetail,
        name: 'dailyReportDetail',
        builder: (context, state) {
          final reportId = state.extra as String? ?? '';
          return DailyReportDetailPage(reportName: reportId);
        },
      ),

      GoRoute(
        path: AppRoutes.announcementDetail,
        name: 'announcementDetail',
        builder: (context, state) {
          final announcementId = state.extra as String? ?? '';
          return NotificationDetailPage(announcementId: announcementId);
        },
      ),
      GoRoute(
        path: AppRoutes.observationDetail,
        name: 'observationDetail',
        builder: (context, state) {
          final observationId = state.extra as String? ?? '';
          return ObservationDetailPage(observationId: observationId);
        },
      ),

      // ── Chat room ──────────────────────────────────
      // Accepts either a String extra (channelId) or a Map
      // with `channelId` and `title` (from notifications).
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra;

          String channelId = '';
          String title = 'Chat';

          if (extra is String) {
            channelId = extra;
          } else if (extra is Map) {
            channelId = extra['channelId']?.toString() ?? '';
            title = extra['title']?.toString() ?? 'Chat';
          }

          if (channelId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Channel not found')),
            );
          }

          return BlocProvider<ChatBloc>(
            create: (_) => sl<ChatBloc>(),
            child: ChatsPage(),
          );
        },
      ),

      // ── Moment detail ──────────────────────────────
      GoRoute(
        path: AppRoutes.momentDetail,
        name: 'momentDetail',
        builder: (context, state) {
          final momentId = state.extra as String? ?? '';
          return MomentsPage();
        },
      ),
      // ═══════════════════════════════════════════════════════════
      // PARENT — PHOTO GALLERY
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.photoGallery,
        name: 'photoGallery',
        builder: (context, state) {
          return BlocProvider<GalleryBloc>(
            create: (_) => sl<GalleryBloc>(),
            child: const PhotoGalleryPage(),
          );
        },
      ),

      // inside the teacher shell:
      GoRoute(
        path: AppRoutes.gateAttendance,
        builder: (_, __) => const GateAttendancePage(),
      ),
      GoRoute(
        path: AppRoutes.attendanceList,
        builder: (_, __) => const AttendanceListPage(),
      ),
      GoRoute(
        path: AppRoutes.classroomPunchIn,
        builder: (_, __) => const ClassroomPunchInPage(),
      ),
      GoRoute(
        path: AppRoutes.classroomPunchOut,
        builder: (_, __) => const ClassroomPunchOutPage(),
      ),
    ],
  );
}
