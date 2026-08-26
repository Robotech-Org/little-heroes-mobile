import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: const LittleHeroesApp(),
    ),
  );
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