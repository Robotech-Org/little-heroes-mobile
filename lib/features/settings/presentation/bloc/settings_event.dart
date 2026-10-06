import 'package:equatable/equatable.dart';

import '../../domain/entities/user_preferences.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

// ══════════════════════════════════════════════════
// LOADING
// ══════════════════════════════════════════════════

class LoadPreferences extends SettingsEvent {
  const LoadPreferences();
}

class LoadMyProfile extends SettingsEvent {
  const LoadMyProfile();
}

// ══════════════════════════════════════════════════
// SAVE / TOGGLE
// ══════════════════════════════════════════════════

class SavePreferences extends SettingsEvent {
  final UserPreferences prefs;
  const SavePreferences(this.prefs);

  @override
  List<Object?> get props => [prefs];
}

class TogglePreference extends SettingsEvent {
  final UserPreferences prefs;
  const TogglePreference(this.prefs);

  @override
  List<Object?> get props => [prefs];
}

// ══════════════════════════════════════════════════
// SECURITY
// ══════════════════════════════════════════════════

class ChangePasswordEvent extends SettingsEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// ══════════════════════════════════════════════════
// PROFILE
// ══════════════════════════════════════════════════

class UpdateProfileEvent extends SettingsEvent {
  final String? phoneNumber;
  final String? emergencyPhone;
  final String? userImage;

  const UpdateProfileEvent({
    this.phoneNumber,
    this.emergencyPhone,
    this.userImage,
  });

  @override
  List<Object?> get props => [phoneNumber, emergencyPhone, userImage];
}
