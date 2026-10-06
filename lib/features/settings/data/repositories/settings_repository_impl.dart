import '../../domain/entities/user_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/user_preferences_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remote;
  SettingsRepositoryImpl(this.remote);

  @override
  Future<UserPreferences> getPreferences() async {
    return await remote.getPreferences();
  }

  @override
  Future<UserPreferences> updatePreferences(UserPreferences prefs) async {
    final model = UserPreferencesModel(
      userType: prefs.userType,
      biometricLoginEnabled: prefs.biometricLoginEnabled,
      quietHoursEnabled: prefs.quietHoursEnabled,
      quietHoursStart: prefs.quietHoursStart,
      quietHoursEnd: prefs.quietHoursEnd,
      notifyChat: prefs.notifyChat,
      notifyDailyReports: prefs.notifyDailyReports,
      notifyAnnouncements: prefs.notifyAnnouncements,
      notifyAttendance: prefs.notifyAttendance,
      notifyMoments: prefs.notifyMoments,
      notifyBilling: prefs.notifyBilling,
      receiveSmsUpdates: prefs.receiveSmsUpdates,
      notifyLeaveUpdates: prefs.notifyLeaveUpdates,
    );
    return await remote.updatePreferences(model);
  }

  @override
  Future<void> updateProfile({
    String? phoneNumber,
    String? emergencyPhone,
    String? userImage,
  }) async {
    await remote.updateProfile(
      phoneNumber: phoneNumber,
      emergencyPhone: emergencyPhone,
      userImage: userImage,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await remote.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserProfile> getMyProfile() async {
    return await remote.getMyProfile();
  }

  @override
  Future<UserProfile> getProfile() async {
    // If you already have a profile endpoint elsewhere, delegate to it.
    // This is a placeholder so the UI can be wired end-to-end.
    throw UnimplementedError('Wire this to your existing profile datasource');
  }
}
