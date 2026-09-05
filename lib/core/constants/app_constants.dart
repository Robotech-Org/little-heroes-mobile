class AppConstants {
  AppConstants._();

  // =
  // App Information
  // =

  static const String appName = 'Little Heroes';

  static const String appVersion = '1.0.0';

  // =
  // Pagination
  // =

  static const int defaultPage = 1;

  static const int defaultPageSize = 20;

  // =
  // Validation
  // =

  static const int minPasswordLength = 8;

  static const int maxPasswordLength = 50;

  static const int minNameLength = 2;

  static const int maxNameLength = 50;

  // =
  // UI
  // =

  static const double defaultPadding = 16.0;

  static const double smallPadding = 8.0;

  static const double largePadding = 24.0;

  static const double defaultRadius = 12.0;

  static const double buttonHeight = 52.0;

  // =
  // Timing
  // =

  static const Duration splashDuration = Duration(seconds: 2);

  static const Duration snackbarDuration = Duration(seconds: 3);

  static const Duration debounceDuration = Duration(milliseconds: 500);

  // =
  // Network
  // =

  static const Duration connectionTimeout = Duration(seconds: 30);

  static const Duration receiveTimeout = Duration(seconds: 30);

  // =
  // Other
  // =

  static const int maxChatMessageLength = 1000;
}
