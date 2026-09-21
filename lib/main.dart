// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// import 'package:little_heroes_mobile/core/services/notification_service.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/chats/presentation/bloc/chat_bloc.dart';
// import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
// import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
// import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
// import 'package:little_heroes_mobile/injection_container.dart';

// import 'core/router/app_router.dart';
// import 'core/services/storage_service.dart';
// import 'core/theme/app_theme.dart';
// import 'core/theme/theme_cubit.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize everything BEFORE runApp
//   await _initializeApp();

//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
//         BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
//         BlocProvider(
//           create: (context) => sl<GalleryBloc>(),
//           child: const PhotoGalleryPage(),
//         ),
//         BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
//         BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
//       ],
//       child: const LittleHeroesApp(),
//     ),
//   );
// }

// Future<void> _initializeApp() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     await Hive.initFlutter();
//     await StorageService.instance.init();

//     await dotenv.load(fileName: '.env');
//     await initDependencies();

//     await NotificationService.initialize();

//     await initDependencies();

//     debugPrint('App initialized successfully');
//   } catch (e, stackTrace) {
//     debugPrint('Initialization error: $e');
//     debugPrintStack(stackTrace: stackTrace);
//   }
// }

// class LittleHeroesApp extends StatelessWidget {
//   const LittleHeroesApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, ThemeMode>(
//       builder: (context, themeMode) {
//         return MaterialApp.router(
//           debugShowCheckedModeBanner: false,
//           title: 'Little Heroes',
//           theme: AppTheme.lightTheme,
//           darkTheme: AppTheme.darkTheme,
//           themeMode: themeMode,
//           routerConfig: AppRouter.router,
//         );
//       },
//     );
//   }
// }

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/services/notification_service.dart';
import 'package:little_heroes_mobile/core/services/session_manager.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/injection_container.dart';

import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
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

    await NotificationService.initialize();

    // Initialize the session-manager cleanup once so the manager can
    // wipe storage the very first time a 401 fires.
    // (No further setup — it's a singleton.)
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
      // Skip if we're already on login.
      final current = AppRouter.router.state.uri.path;
      if (current == AppRoutes.login) return;

      // Navigate to login. The router's redirect guard will keep the
      // user there until they authenticate again.
      AppRouter.router.go(AppRoutes.login);

      // Friendly toast.
      final ctx = AppRouter.navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        SnackbarUtils.showError(ctx, 'Session expired. Please log in again.');
      }
    });
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
        );
      },
    );
  }
}
