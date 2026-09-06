import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<void> call({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (oldPassword.isEmpty) {
      throw Exception('Current password is required');
    }
    if (newPassword.isEmpty) {
      throw Exception('New password is required');
    }
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters');
    }
    if (oldPassword == newPassword) {
      throw Exception('New password must be different from current password');
    }

    await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
