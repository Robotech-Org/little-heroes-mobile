import '../entities/user_preferences.dart';
import '../entities/user_profile.dart';

abstract class SettingsRepository {
  Future<UserPreferences> getPreferences();
  Future<UserPreferences> updatePreferences(UserPreferences prefs);
  Future<void> updateProfile({
    String? phoneNumber,
    String? emergencyPhone,
    String? userImage,
  });
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<UserProfile> getProfile();
  Future<UserProfile> getMyProfile();
}
