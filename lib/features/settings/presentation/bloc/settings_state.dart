import 'package:equatable/equatable.dart';

import '../../domain/entities/user_preferences.dart';
import '../../domain/entities/user_profile.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserPreferences prefs;
  final UserProfile? profile;
  final bool saving;

  const SettingsLoaded(this.prefs, {this.profile, this.saving = false});

  @override
  List<Object?> get props => [prefs, profile, saving];
}

class SettingsSaved extends SettingsState {
  final UserPreferences prefs;
  final String message;

  const SettingsSaved(this.prefs, this.message);

  @override
  List<Object?> get props => [prefs, message];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordChanged extends SettingsState {
  final String message;

  const PasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends SettingsState {
  final String message;

  const ProfileUpdated(this.message);

  @override
  List<Object?> get props => [message];
}
