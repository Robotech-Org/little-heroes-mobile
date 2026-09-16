import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // BASE URL

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? baseUrl;

  static String get hostHeader => dotenv.env['HOST_HEADER'] ?? 'dev.local';

  static const String socketNamespace = '/';

  // AUTH APIs

  static const String login = '/api/method/little_heroes.api.v1.auth.login';

  static const String requestOtp =
      '/api/method/little_heroes.api.v1.auth.request_otp';

  static const String verifyOtp = '/api/method/little_heroes.api.v1.auth.login';

  static const String resetPassword =
      '/api/method/little_heroes.api.v1.auth.reset_password';

  static const String changePassword =
      '/api/method/little_heroes.api.v1.auth.change_password';

  static const String logout = '/api/method/logout';

  // DAILY REPORT APIs

  /// POST - Create daily report
  static const String createDailyReport =
      '/api/method/little_heroes.api.v1.daily_reports.create_daily_report';

  /// GET - Get single daily report
  static const String getDailyReport =
      '/api/method/little_heroes.api.v1.daily_reports.get_daily_report';

  /// GET - List daily reports
  static const String listDailyReports =
      '/api/method/little_heroes.api.v1.daily_reports.list_daily_reports';

  /// PUT/PATCH - Update daily report
  static const String updateDailyReport =
      '/api/method/little_heroes.api.v1.daily_reports.update_daily_report';

  // MONTHLY REPORT APIs

  /// POST - Create monthly report
  static const String createMonthlyReport =
      '/api/method/little_heroes.api.v1.monthly_reports.create_monthly_report';

  /// GET - Get single monthly report
  static const String getMonthlyReport =
      '/api/method/little_heroes.api.v1.monthly_reports.get_monthly_report';

  /// GET - List monthly reports
  static const String listMonthlyReports =
      '/api/method/little_heroes.api.v1.monthly_reports.list_monthly_reports';

  /// PUT/PATCH - Update monthly report
  static const String updateMonthlyReport =
      '/api/method/little_heroes.api.v1.monthly_reports.update_monthly_report';

  // OBSERVATION APIs

  /// POST - Create observation
  static const String createObservation =
      '/api/method/little_heroes.api.v1.observations.create_observation';

  /// GET - Get single observation by name
  static const String getObservation =
      '/api/method/little_heroes.api.v1.observations.get_observation';

  /// GET - List observations with pagination
  static const String listObservations =
      '/api/method/little_heroes.api.v1.observations.list_observations';

  /// PUT/PATCH - Update observation by name
  static const String updateObservation =
      '/api/method/little_heroes.api.v1.observations.update_observation';

  /// DELETE - Delete observation by name
  static const String deleteObservation =
      '/api/method/little_heroes.api.v1.observations.delete_observation';

  /// POST - Upload observation file
  static const String uploadObservationFile =
      '/api/method/little_heroes.api.v1.observations.upload_observation_file';

  // OTHER APIs

  // ANNOUNCEMENT APIs
  static const String listAnnouncements =
      '/api/method/little_heroes.api.v1.announcements.list_announcements';

  static const String getAnnouncement =
      '/api/method/little_heroes.api.v1.announcements.get_announcement';

  static const String updateAnnouncement =
      '/api/method/little_heroes.api.v1.announcements.update_announcement';

  // CHAT APIs
  static const String listTeachers =
      '/api/method/little_heroes.api.v1.teachers.list_teachers';

  static const String listParents =
      '/api/method/little_heroes.api.v1.parents.list_parents';

  static const String listStudents =
      '/api/method/little_heroes.api.v1.students.list_students';

  static const String notifications = '/notifications';

  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  static const String registerDevice =
      '/api/method/little_heroes.api.v1.notifications.register_device';

  static const String getMyNotifications =
      '/api/method/little_heroes.api.v1.notifications.get_my_notifications';

  static const String markNotificationsRead =
      '/api/method/little_heroes.api.v1.notifications.mark_as_read';

  static const String unregisterDevice =
      '/api/method/little_heroes.api.v1.notifications.unregister_device';

  static const String chats = '/chats';

  static const String reports = '/reports';

  // ✅ Admin / Oversight Endpoints (School Administrator role)
  static const String adminListChannels =
      '/api/method/little_heroes.api.v1.communications.admin_list_channels';
  static const String adminGetChannelMessages =
      '/api/method/little_heroes.api.v1.communications.admin_get_channel_messages';
  static const String adminPostIntervention =
      '/api/method/little_heroes.api.v1.communications.admin_post_intervention';

  // ============================================================
  // ✅ COMMUNICATIONS / CHAT (Raven Channel) APIs
  // ============================================================
  static const String listMyChannels =
      '/api/method/little_heroes.api.v1.communications.list_my_channels';
  static const String getChannelMessages =
      '/api/method/little_heroes.api.v1.communications.get_channel_messages';
  static const String sendMessage =
      '/api/method/little_heroes.api.v1.communications.send_message';
  static const String markAsRead =
      '/api/method/little_heroes.api.v1.communications.mark_as_read';

  // LESSON PLAN APIs
  static const String listLessonPlans =
      '/api/method/little_heroes.api.v1.lesson_plans.list_lesson_plans';

  static const String getLessonPlan =
      '/api/method/little_heroes.api.v1.lesson_plans.get_lesson_plan';

  static const String createLessonPlan =
      '/api/method/little_heroes.api.v1.lesson_plans.create_lesson_plan';

  static const String updateLessonPlan =
      '/api/method/little_heroes.api.v1.lesson_plans.update_lesson_plan';

  // FRAMEWORK DOMAIN APIs
  static const String listFrameworkDomains =
      '/api/method/little_heroes.api.v1.framework_domains.list_framework_domains';

  // COMPETENCY APIs
  static const String listCompetencies =
      '/api/method/little_heroes.api.v1.framework_competencies.list_framework_competencies';

  static const String getCompetency =
      '/api/method/little_heroes.api.v1.framework_competencies.get_framework_competency';

  // DASHBOARD APIs
  static const String dashboard =
      '/api/method/little_heroes.api.v1.dashboards.get_dashboard';
  // static const String dashboard =
  // '/api/method/little_heroes.api.v1.dashboards.get_parent_dashboard';

  // Classroom endpoints
  static const String listClassrooms =
      '/api/method/little_heroes.api.v1.classrooms.list_classrooms';
  static const String getClassroom =
      '/api/method/little_heroes.api.v1.classrooms.get_classroom';

  // In ApiConstants
  static const String listClassroomSchedules =
      '/api/method/little_heroes.api.v1.classroom_schedules.list_classroom_schedules';
  static const String getClassroomSchedule =
      '/api/method/little_heroes.api.v1.classroom_schedules.get_classroom_schedule';

  // In ApiConstants
  static const String listSubscriptionPlans =
      '/api/method/little_heroes.api.v1.subscription_plans.list_subscription_plans';

  // Gallery endpoints
  static const String listGallery =
      '/api/method/little_heroes.api.v1.galleries.list_gallery';
  static const String getGallery =
      '/api/method/little_heroes.api.v1.galleries.get_gallery';

  // lib/core/constants/api_constants.dart

  // Moments
  static const String listMoments =
      '/api/method/little_heroes.api.v1.moments.list_moments';
  static const String getMoment =
      '/api/method/little_heroes.api.v1.moments.get_moment';
  static const String createMoment =
      '/api/method/little_heroes.api.v1.moments.create_moment';
  static const String updateMoment =
      '/api/method/little_heroes.api.v1.moments.update_moment';
  static const String deleteMoment =
      '/api/method/little_heroes.api.v1.moments.delete_moment';
  static const String approveMoment =
      '/api/method/little_heroes.api.v1.moments.approve_moment';
  static const String denyMoment =
      '/api/method/little_heroes.api.v1.moments.deny_moment';
  static const String uploadMomentFile =
      '/api/method/little_heroes.api.v1.moments.upload_moment_file';

  // ============================================================
  // ATTENDANCE
  // ============================================================
  static const String scanQr =
      '/api/method/little_heroes.api.v1.attendance.scan_qr';

  // ============================================================
  // PAYMENTS
  // ============================================================

  /// GET — list the parent's tuition invoices
  static const String getMyInvoices =
      '/api/method/little_heroes.api.v1.payments.get_my_invoices';

  /// POST — initialize a Chapa checkout session
  static const String initializePayment =
      '/api/method/little_heroes.api.v1.payments.initialize_payment';

  /// GET — verify payment status by tx_ref or invoice_name
  static const String getPaymentStatus =
      '/api/method/little_heroes.api.v1.payments.get_payment_status';

  /// GET — public callback (opened in browser after Chapa)
  static const String paymentCallback =
      '/api/method/little_heroes.api.v1.payments.callback';
}
