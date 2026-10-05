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

  static const String chatRoom = '/chat-room';

  static const String notifications = '/notifications';
  static const String reports = '/reports';

  //  thhis sis fro the splash screen
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String main = '/main';
  static const String settings = '/settings';

  // TEACHER TOOLS

  static const dailyReport = '/daily-report';
  static const dailyReport_teachers = '/daily-report-teachers';
  static const threeMonthReports = '/three-month-reports';
  static const threeMonthReportsParents = '/three-month-reports-parents';
  static const weeklyPlanner = '/weekly-planner';
  static const observations = '/observations';

  static const String addMoment = '/add-moment';
  static const String Compile_3_onth_report = '/Compile_3_onth_report';

  // Newsletter (blog)
  static const String newsletters = '/newsletters';
  static const String newsletterDetail = '/newsletter-detail';

  // ═════════════════════════════════════════════════════════════
  // PARENT-ONLY
  // ═════════════════════════════════════════════════════════════
  // static const String threeMonthReportsParents = '/three-month-reports-parents';
  static const String photoGallery = '/photo-gallery';
  static const String galleryPhoto = '/gallery-photo';
  
  static const String parentDailyReport = '/parent-daily-report';

  // ============================================================
  // Deep-link targets (used by push notifications)
  // ============================================================
  static const String dailyReportDetail = '/daily-report-detail';
  static const String observationDetail = '/observation-detail';
  static const String announcementDetail = '/announcement-detail';
  static const String momentDetail = '/moment-detail';
  static const String chat = '/chat';

  static const String gateAttendance = '/teacher/gate-attendance';
  static const String classroomAttendance = '/teacher/classroom-attendance';

  // ═══════════════════════════════════════════════════════════
  // ATTENDANCE ROUTES
  // ═══════════════════════════════════════════════════════════

  /// Gate scanner — used by the assigned gate teacher
  /// Handles BOTH morning punch-in and evening punch-out

  /// Classroom teacher — punch IN to class
  static const String classroomPunchIn = '/teacher/classroom-punch-in';

  /// Classroom teacher — punch OUT of class
  static const String classroomPunchOut = '/teacher/classroom-punch-out';

  // ═══════════════════════════════════════════════════════════
  // ATTENDANCE
  // ═══════════════════════════════════════════════════════════
  // static const String gateAttendance = '/teacher/gate-attendance';
  static const String attendanceList = '/teacher/attendance-list';
  // static const String classroomPunchIn = '/teacher/classroom-punch-in';
  // static const String classroomPunchOut = '/teacher/classroom-punch-out';
}
