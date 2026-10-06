import 'package:little_heroes_mobile/features/settings/domain/repositories/settings_repository.dart';

class ChangePasswordSettings {
  final SettingsRepository repository;
  ChangePasswordSettings(this.repository);

  Future<void> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
