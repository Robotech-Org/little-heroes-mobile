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

  /// GET - Get single observation
  static const String getObservation =
      '/api/method/little_heroes.api.v1.observations.get_observation';

  /// GET - List observations
  static const String listObservations =
      '/api/method/little_heroes.api.v1.observations.list_observations';

  /// PUT/PATCH - Update observation
  static const String updateObservation =
      '/api/method/little_heroes.api.v1.observations.update_observation';

  // OTHER APIs

  static const String listStudents =
      '/api/method/little_heroes.api.v1.students.list_students';

  static const String notifications = '/notifications';

  static const String chats = '/chats';

  static const String reports = '/reports';
}
