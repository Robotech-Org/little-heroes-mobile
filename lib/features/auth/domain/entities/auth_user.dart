import '../../../../core/constants/user_role.dart';

class AuthUser {
  final String phoneNumber;
  final UserRole role;

  const AuthUser({required this.phoneNumber, required this.role});
}
