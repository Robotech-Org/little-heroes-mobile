import '../entities/user_profile.dart';
import '../repositories/settings_repository.dart';

class GetMyProfile {
  final SettingsRepository repository;
  GetMyProfile(this.repository);

  Future<UserProfile> call() => repository.getMyProfile();
}
