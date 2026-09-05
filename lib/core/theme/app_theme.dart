import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // LIGHT THEME

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.white,

          secondary: AppColors.secondary,

          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,

          error: AppColors.error,
          onError: AppColors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      //
      // COLOR SCHEME
      //
      colorScheme: colorScheme,

      //
      // BACKGROUND
      //
      scaffoldBackgroundColor: AppColors.lightBackground,

      //
      // APP BAR
      //
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
      ),

      //
      // CARD
      //
      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      //
      // INPUT
      //
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,

        hintStyle: const TextStyle(color: AppColors.lightTextTertiary),

        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      //
      // DIVIDER
      //
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),

      //
      // TEXT THEME
      //
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.lightTextPrimary),
        displayMedium: TextStyle(color: AppColors.lightTextPrimary),
        displaySmall: TextStyle(color: AppColors.lightTextPrimary),

        headlineLarge: TextStyle(color: AppColors.lightTextPrimary),
        headlineMedium: TextStyle(color: AppColors.lightTextPrimary),
        headlineSmall: TextStyle(color: AppColors.lightTextPrimary),

        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary),
        titleSmall: TextStyle(color: AppColors.lightTextSecondary),

        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),

        labelLarge: TextStyle(color: AppColors.lightTextPrimary),
        labelMedium: TextStyle(color: AppColors.lightTextSecondary),
        labelSmall: TextStyle(color: AppColors.lightTextTertiary),
      ),
    );
  }

  // DARK THEME

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.black,

          secondary: AppColors.secondaryLight,

          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,

          error: AppColors.error,
          onError: AppColors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      //
      // COLOR SCHEME
      //
      colorScheme: colorScheme,

      //
      // BACKGROUND
      //
      scaffoldBackgroundColor: AppColors.darkBackground,

      //
      // APP BAR
      //
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,

        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
      ),

      //
      // CARD
      //
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      //
      // INPUT
      //
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,

        hintStyle: const TextStyle(color: AppColors.darkTextTertiary),

        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      //
      // DIVIDER
      //
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),

      //
      // TEXT THEME
      //
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        displaySmall: TextStyle(color: AppColors.darkTextPrimary),

        headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
        headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
        headlineSmall: TextStyle(color: AppColors.darkTextPrimary),

        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(color: AppColors.darkTextSecondary),

        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),

        labelLarge: TextStyle(color: AppColors.darkTextPrimary),
        labelMedium: TextStyle(color: AppColors.darkTextSecondary),
        labelSmall: TextStyle(color: AppColors.darkTextTertiary),
      ),
    );
  }
}
