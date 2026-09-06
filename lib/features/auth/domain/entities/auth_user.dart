
import '../../../../core/constants/user_role.dart';

class AuthUser {
  final String phoneNumber;
  final String fullName;
  final UserRole role;

  const AuthUser({
    required this.phoneNumber,
    required this.fullName,
    required this.role,
  });

  /// Convert AuthUser to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'role': role.name,
    };
  }

  /// Create AuthUser from local storage
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: _parseRole(json['role']),
    );
  }

  static UserRole _parseRole(dynamic role) {
    switch (role?.toString().toLowerCase()) {
      case 'parent':
        return UserRole.parent;

      case 'teacher':
        return UserRole.teacher;

      case 'adviser':
      case 'advisor':
        return UserRole.adviser;

      default:
        return UserRole.parent;
    }
  }
}
