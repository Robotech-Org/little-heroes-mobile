class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const otpVerification = '/otp-verification';

  // Main
  static const String home = '/home';

  // Features
  static const String chats = '/chats';
  static const String notifications = '/notifications';
  static const String reports = '/reports';

  //  thhis sis fro the splash screen
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String main = '/main';
  static const String settings = '/settings';

  // ============================================================
  // TEACHER TOOLS
  // ============================================================

    static const dailyReport = '/daily-report';
    static const threeMonthReports = '/three-month-reports';
    static const weeklyPlanner = '/weekly-planner';
    static const observations = '/observations';
}
