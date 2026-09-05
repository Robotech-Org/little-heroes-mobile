enum UserRole { parent, teacher, adviser }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.parent:
        return 'parent';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.adviser:
        return 'adviser';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'parent':
        return UserRole.parent;

      case 'teacher':
        return UserRole.teacher;

      case 'adviser':
        return UserRole.adviser;

      default:
        throw Exception('Unknown user role: $role');
    }
  }
}
