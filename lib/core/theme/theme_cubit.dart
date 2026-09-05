import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  // STORAGE

  static const String _themeKey = 'theme_mode';

  // LOAD SAVED THEME

  Future<void> _loadTheme() async {
    try {
      final savedTheme = StorageService.instance.getString(_themeKey);

      if (savedTheme == null || savedTheme.isEmpty) {
        return;
      }

      final themeMode = _themeModeFromString(savedTheme);

      if (themeMode != null) {
        emit(themeMode);
      }
    } catch (_) {
      emit(ThemeMode.system);
    }
  }

  // SET LIGHT

  Future<void> setLightMode() async {
    emit(ThemeMode.light);
    await _saveTheme(ThemeMode.light);
  }

  // SET DARK

  Future<void> setDarkMode() async {
    emit(ThemeMode.dark);
    await _saveTheme(ThemeMode.dark);
  }

  // SET SYSTEM

  Future<void> setSystemMode() async {
    emit(ThemeMode.system);
    await _saveTheme(ThemeMode.system);
  }

  // TOGGLE

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    emit(newMode);
    await _saveTheme(newMode);
  }

  // SAVE

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      await StorageService.instance.saveString(
        _themeKey,
        _themeModeToString(mode),
      );
    } catch (_) {
      // Theme remains functional even if saving fails.
    }
  }

  // THEME MODE → STRING

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  // STRING → THEME MODE

  ThemeMode? _themeModeFromString(String value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }
}
