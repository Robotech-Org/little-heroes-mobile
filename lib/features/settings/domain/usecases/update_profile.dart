import '../repositories/settings_repository.dart';

class UpdateProfile {
  final SettingsRepository repository;
  UpdateProfile(this.repository);

  Future<void> call({
    String? phoneNumber,
    String? emergencyPhone,
    String? userImage,
  }) {
    return repository.updateProfile(
      phoneNumber: phoneNumber,
      emergencyPhone: emergencyPhone,
      userImage: userImage,
    );
  }
}
