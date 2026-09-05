class ValidationUtils {
  ValidationUtils._();

  // =
  // Required
  // =

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // =
  // Name
  // =

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  // =
  // Email
  // =

  static bool isValidEmail(String email) {
    final value = email.trim();

    if (value.isEmpty) return false;

    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value);
  }

  static String? emailError(String email) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // =
  // Password
  // =

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=]').hasMatch(password);
  }

  static bool isWeakPassword(String password) {
    if (password.isEmpty) return true;

    return !isStrongPassword(password);
  }

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

  // =
  // Confirm Password
  // =

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // =
  // Phone
  // =

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}
