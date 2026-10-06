import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/services/settings_cache_service.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_my_profile.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/update_preferences.dart';
import '../../domain/usecases/update_profile.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetPreferences getPreferences;
  final UpdatePreferences updatePreferences;
  final ChangePasswordSettings changePassword;
  final UpdateProfile updateProfile;
  final GetMyProfile getMyProfile;

  final _cache = SettingsCacheService.instance;

  SettingsBloc({
    required this.getPreferences,
    required this.updatePreferences,
    required this.changePassword,
    required this.updateProfile,
    required this.getMyProfile,
  }) : super(SettingsInitial()) {
    on<LoadPreferences>(_onLoad);
    on<SavePreferences>(_onSave);
    on<TogglePreference>(_onToggle);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LoadMyProfile>(_onLoadMyProfile);
  }

  // ══════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════

  UserProfile? get _currentProfile {
    final s = state;
    if (s is SettingsLoaded) return s.profile;
    return null;
  }

  UserPreferences? get _currentPrefs {
    final s = state;
    if (s is SettingsLoaded) return s.prefs;
    if (s is SettingsSaved) return s.prefs;
    return null;
  }

  // ══════════════════════════════════════════════════
  // LOAD — cache first, then network
  // ══════════════════════════════════════════════════

  Future<void> _onLoad(
    LoadPreferences event,
    Emitter<SettingsState> emit,
  ) async {
    // 1️ Read cache — emit immediately if we have it
    final cachedPrefs = _cache.loadPrefs();
    final cachedProfile = _cache.loadProfile();

    if (cachedPrefs != null) {
      emit(SettingsLoaded(cachedPrefs, profile: cachedProfile));
    } else {
      emit(SettingsLoading());
    }

    // 2️ Network
    try {
      final results = await Future.wait([getPreferences(), getMyProfile()]);

      final prefs = results[0] as UserPreferences;
      final profile = results[1] as UserProfile;

      // 3️ Persist for next time
      await _cache.savePrefs(prefs);
      await _cache.saveProfile(profile);

      emit(SettingsLoaded(prefs, profile: profile));
    } catch (e) {
      // 4️ If we have cache, keep it — otherwise show error
      if (cachedPrefs != null) {
        emit(SettingsLoaded(cachedPrefs, profile: cachedProfile));
      } else {
        emit(SettingsError(e.toString()));
      }
    }
  }

  // ══════════════════════════════════════════════════
  // LOAD PROFILE ONLY
  // ══════════════════════════════════════════════════

  Future<void> _onLoadMyProfile(
    LoadMyProfile event,
    Emitter<SettingsState> emit,
  ) async {
    final currentPrefs = _currentPrefs;

    if (currentPrefs == null) {
      add(const LoadPreferences());
      return;
    }

    try {
      final profile = await getMyProfile();
      await _cache.saveProfile(profile);
      emit(SettingsLoaded(currentPrefs, profile: profile));
    } catch (e) {
      // Silent fallback to cached profile
      final cached = _cache.loadProfile();
      emit(SettingsLoaded(currentPrefs, profile: cached));
    }
  }

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> _onSave(
    SavePreferences event,
    Emitter<SettingsState> emit,
  ) async {
    final profile = _currentProfile;
    final rollbackPrefs = _currentPrefs;

    emit(SettingsLoaded(event.prefs, profile: profile, saving: true));

    try {
      final updated = await updatePreferences(event.prefs);

      // Persist to cache
      await _cache.savePrefs(updated);

      emit(SettingsSaved(updated, 'Preferences saved'));
    } catch (e) {
      emit(SettingsError(e.toString()));
      if (rollbackPrefs != null) {
        emit(SettingsLoaded(rollbackPrefs, profile: profile));
      }
    }
  }

  // ══════════════════════════════════════════════════
  // TOGGLE
  // ══════════════════════════════════════════════════

  Future<void> _onToggle(
    TogglePreference event,
    Emitter<SettingsState> emit,
  ) async {
    final profile = _currentProfile;
    final rollbackPrefs = _currentPrefs;

    emit(SettingsLoaded(event.prefs, profile: profile, saving: true));

    try {
      final updated = await updatePreferences(event.prefs);

      // Persist to cache
      await _cache.savePrefs(updated);

      emit(SettingsLoaded(updated, profile: profile));
    } catch (e) {
      emit(SettingsError(e.toString()));
      if (rollbackPrefs != null) {
        emit(SettingsLoaded(rollbackPrefs, profile: profile));
      }
    }
  }

  // ══════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ══════════════════════════════════════════════════

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final profile = _currentProfile;
    final currentPrefs = _currentPrefs;

    if (currentPrefs != null) {
      emit(SettingsLoaded(currentPrefs, profile: profile, saving: true));
    }

    try {
      await changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      emit(const PasswordChanged('Password changed successfully'));
      if (currentPrefs != null) {
        emit(SettingsLoaded(currentPrefs, profile: profile));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
      if (currentPrefs != null) {
        emit(SettingsLoaded(currentPrefs, profile: profile));
      }
    }
  }

  // ══════════════════════════════════════════════════
  // UPDATE PROFILE
  // ══════════════════════════════════════════════════

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final profile = _currentProfile;
    final currentPrefs = _currentPrefs;

    if (currentPrefs != null) {
      emit(SettingsLoaded(currentPrefs, profile: profile, saving: true));
    }

    try {
      await updateProfile(
        phoneNumber: event.phoneNumber,
        emergencyPhone: event.emergencyPhone,
        userImage: event.userImage,
      );

      emit(const ProfileUpdated('Profile updated'));

      if (currentPrefs != null) {
        UserProfile? refreshed;
        try {
          refreshed = await getMyProfile();
          await _cache.saveProfile(refreshed);
        } catch (_) {
          refreshed = profile;
        }
        emit(SettingsLoaded(currentPrefs, profile: refreshed));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
      if (currentPrefs != null) {
        emit(SettingsLoaded(currentPrefs, profile: profile));
      }
    }
  }
}
