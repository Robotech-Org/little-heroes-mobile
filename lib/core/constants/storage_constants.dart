class StorageConstants {
  StorageConstants._();

  // =
  // Authentication
  // =

  /// JWT access token
  static const String accessToken = 'access_token';

  /// JWT refresh token
  static const String refreshToken = 'refresh_token';

  /// Whether the user is authenticated
  static const String isLoggedIn = 'is_logged_in';

  // =
  // User
  // =

  static const String userId = 'user_id';

  static const String user = 'user';

  static const String userProfile = 'user_profile';

  // =
  // Onboarding
  // =

  static const String onboardingCompleted = 'onboarding_completed';

  // =
  // App Settings
  // =

  static const String themeMode = 'theme_mode';

  static const String language = 'language';

  // =
  // Notifications
  // =

  static const String notificationsEnabled = 'notifications_enabled';

  // =
  // Cache
  // =

  static const String cachedHomeData = 'cached_home_data';

  static const String cachedNotifications = 'cached_notifications';

  static const String cachedChats = 'cached_chats';

  static const String cachedReports = 'cached_reports';

  // =
  // General
  // =

  static const String lastSyncTime = 'last_sync_time';
}
