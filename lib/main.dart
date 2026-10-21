import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/services/chat_read_state_service.dart';
import 'package:little_heroes_mobile/core/services/deep_link_service.dart';
import 'package:little_heroes_mobile/core/services/notification_service.dart';
import 'package:little_heroes_mobile/core/services/session_manager.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:little_heroes_mobile/injection_container.dart';

import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';

/// Global messenger key — lets us show snackbars that survive
/// route transitions (like the session-expired → login redirect).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Amber warning background for the session-expired banner.
///
///  OPTIONAL: move this to `AppColors` as `AppColors.warning` and delete
/// this constant — then reference `AppColors.warning` below.
const Color _kSessionWarning = Color.fromARGB(255, 12, 90, 192);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeepLinkService.instance.init();
  await _initializeApp();
  await ChatReadStateService.instance.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
        BlocProvider<GalleryBloc>(create: (_) => sl<GalleryBloc>()),
        BlocProvider<SettingsBloc>(create: (_) => sl<SettingsBloc>()),
      ],
      child: const LittleHeroesApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    await StorageService.instance.init();
    await dotenv.load(fileName: '.env');
    await initDependencies();

    try {
      await NotificationService.initialize();
    } catch (e, st) {
      debugPrint(' NotificationService init failed (non-fatal): $e');
      debugPrintStack(stackTrace: st);
    }

    debugPrint('App initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class LittleHeroesApp extends StatefulWidget {
  const LittleHeroesApp({super.key});

  @override
  State<LittleHeroesApp> createState() => _LittleHeroesAppState();
}

class _LittleHeroesAppState extends State<LittleHeroesApp> {
  StreamSubscription<void>? _sessionSub;

  @override
  void initState() {
    super.initState();

    _sessionSub = SessionManager.instance.onSessionExpired.listen((_) {
      _handleSessionExpired();
    });
  }

  void _handleSessionExpired() {
    // 1. Show the friendly banner FIRST via the global messenger key.
    //    Because we'll navigate right after, this banner would be lost
    //    if it were anchored to the current page's Scaffold.
    _showFriendlyExpiryBanner();

    // 2. Navigate to login. The router's redirect guard keeps the user
    //    there until they authenticate.
    final current = AppRouter.router.state.uri.path;
    if (current != AppRoutes.login) {
      AppRouter.router.go(AppRoutes.login);
    }
  }

  void _showFriendlyExpiryBanner() {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint(
        '❌ rootScaffoldMessengerKey has no state — '
        'did you set scaffoldMessengerKey on MaterialApp.router?',
      );
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: _kSessionWarning,
          elevation: 6,
          // ── Auto-close after 3 seconds ──────────────
          duration: const Duration(seconds: 3),
          // ── Allow swipe-to-dismiss (left/right) ─────
          dismissDirection: DismissDirection.horizontal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                color: AppColors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session expired',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Please log in again to continue.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Close (X) button ────────────────────
              IconButton(
                tooltip: 'Dismiss',
                onPressed: messenger.hideCurrentSnackBar,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          // ❌ Removed SnackBarAction "Log In" — we already redirect,
          //    and the X in the content does the job.
        ),
      );
  }

 

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Little Heroes',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          //  CRITICAL — anchors snackbars to the app root so they
          // survive route transitions during session expiry.
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        );
      },
    );
  }
}
