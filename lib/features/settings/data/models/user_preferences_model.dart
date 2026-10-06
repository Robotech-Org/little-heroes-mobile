import '../../domain/entities/user_preferences.dart';

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.userType,
    required super.biometricLoginEnabled,
    required super.quietHoursEnabled,
    required super.quietHoursStart,
    required super.quietHoursEnd,
    required super.notifyChat,
    required super.notifyDailyReports,
    required super.notifyAnnouncements,
    required super.notifyAttendance,
    required super.notifyMoments,
    required super.notifyBilling,
    required super.receiveSmsUpdates,
    required super.notifyLeaveUpdates,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is bool) return v ? 1 : 0;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userType: (json['user_type'] ?? 'Parent').toString(),
      biometricLoginEnabled: _toInt(json['biometric_login_enabled']) == 1,
      quietHoursEnabled: _toInt(json['quiet_hours_enabled']) == 1,
      quietHoursStart: (json['quiet_hours_start'] ?? '18:00:00').toString(),
      quietHoursEnd: (json['quiet_hours_end'] ?? '07:30:00').toString(),
      notifyChat: _toInt(json['notify_chat']) == 1,
      notifyDailyReports: _toInt(json['notify_daily_reports']) == 1,
      notifyAnnouncements: _toInt(json['notify_announcements']) == 1,
      notifyAttendance: _toInt(json['notify_attendance']) == 1,
      notifyMoments: _toInt(json['notify_moments']) == 1,
      notifyBilling: _toInt(json['notify_billing']) == 1,
      receiveSmsUpdates: _toInt(json['receive_sms_updates']) == 1,
      notifyLeaveUpdates: _toInt(json['notify_leave_updates']) == 1,
    );
  }

  /// Payload for PUT /update_preferences — send only the toggles + times.
  Map<String, dynamic> toUpdatePayload() => {
    'biometric_login_enabled': biometricLoginEnabled ? 1 : 0,
    'quiet_hours_enabled': quietHoursEnabled ? 1 : 0,
    'quiet_hours_start': quietHoursStart,
    'quiet_hours_end': quietHoursEnd,
    'notify_chat': notifyChat ? 1 : 0,
    'notify_daily_reports': notifyDailyReports ? 1 : 0,
    'notify_announcements': notifyAnnouncements ? 1 : 0,
    'notify_attendance': notifyAttendance ? 1 : 0,
    'notify_moments': notifyMoments ? 1 : 0,
    'notify_billing': notifyBilling ? 1 : 0,
    'receive_sms_updates': receiveSmsUpdates ? 1 : 0,
    'notify_leave_updates': notifyLeaveUpdates ? 1 : 0,
  };
}
