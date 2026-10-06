import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class UpdatePreferences {
  final SettingsRepository repository;
  UpdatePreferences(this.repository);

  Future<UserPreferences> call(UserPreferences prefs) =>
      repository.updatePreferences(prefs);
}
