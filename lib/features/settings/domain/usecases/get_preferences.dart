import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class GetPreferences {
  final SettingsRepository repository;
  GetPreferences(this.repository);

  Future<UserPreferences> call() => repository.getPreferences();
}
