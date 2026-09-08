// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:little_heroes_mobile/core/services/notification_service.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/pages/login_page.dart';
// import 'package:little_heroes_mobile/injection_container.dart';

// import 'core/router/app_router.dart';
// import 'core/services/storage_service.dart';
// import 'core/theme/app_theme.dart';
// import 'core/theme/theme_cubit.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize local storage
//   await StorageService.instance.init();
//   await dotenv.load(fileName: '.env');

//   // Initialize FCM
//   await NotificationService.initialize();

//   await initDependencies();
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         // Theme
//         BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
//         BlocProvider(create: (_) => sl<AuthBloc>(), child: const LoginPage()),

//         // Notifications
//         // BlocProvider<NotificationBloc>(create: (_) => NotificationBloc()),
//         // BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
//       ],
//       child: const LittleHeroesApp(),
//     ),
//   );
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:little_heroes_mobile/core/services/notification_service.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
import 'package:little_heroes_mobile/injection_container.dart';

import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize everything BEFORE runApp
  await _initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider(
          create: (context) => sl<GalleryBloc>(),
          child: const PhotoGalleryPage(),
        ),
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

    await StorageService.instance.init();

    await dotenv.load(fileName: '.env');

    await NotificationService.initialize();

    await initDependencies();

    debugPrint('App initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class LittleHeroesApp extends StatelessWidget {
  const LittleHeroesApp({super.key});

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
