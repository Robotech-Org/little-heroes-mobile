import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // BASE URL

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

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

  static const String chats = '/chats';

  static const String reports = '/reports';

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
      '/api/method/little_heroes.api.v1.dashboards.get_teacher_dashboard';
  // static const String dashboard =
  // '/api/method/little_heroes.api.v1.dashboards.get_parent_dashboard';

  // Classroom endpoints
  static const String listClassrooms =
      '/api/method/little_heroes.api.v1.classrooms.list_classrooms';
  static const String getClassroom =
      '/api/method/little_heroes.api.v1.classrooms.get_classroom';
}
