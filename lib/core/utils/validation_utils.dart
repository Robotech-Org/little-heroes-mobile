class ValidationUtils {
  ValidationUtils._();

  /// Validates an email address.
  static bool isValidEmail(String email) {
    final value = email.trim();

    if (value.isEmpty) return false;

    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
  }

  
  /// Requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=]').hasMatch(password);
  }

  /// Returns true when the password is weak.
  static bool isWeakPassword(String password) {
    if (password.isEmpty) return true;

    return !isStrongPassword(password);
  }

  /// Returns a readable password validation message.
  static String? passwordError(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=]').hasMatch(password)) {
      return 'Password must contain a special character';
    }

    return null;
  }

  /// Returns a readable email validation message.
  static String? emailError(String email) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}