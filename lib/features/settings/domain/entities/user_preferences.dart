import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String userType;
  final bool biometricLoginEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  // Common
  final bool notifyChat;
  final bool notifyDailyReports;
  final bool notifyAnnouncements;

  // Parent only
  final bool notifyAttendance;
  final bool notifyMoments;
  final bool notifyBilling;
  final bool receiveSmsUpdates;

  // Teacher only
  final bool notifyLeaveUpdates;

  const UserPreferences({
    required this.userType,
    required this.biometricLoginEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.notifyChat,
    required this.notifyDailyReports,
    required this.notifyAnnouncements,
    required this.notifyAttendance,
    required this.notifyMoments,
    required this.notifyBilling,
    required this.receiveSmsUpdates,
    required this.notifyLeaveUpdates,
  });

  bool get isParent => userType.toLowerCase() == 'parent';
  bool get isTeacher => userType.toLowerCase() == 'teacher';

  UserPreferences copyWith({
    bool? biometricLoginEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? notifyChat,
    bool? notifyDailyReports,
    bool? notifyAnnouncements,
    bool? notifyAttendance,
    bool? notifyMoments,
    bool? notifyBilling,
    bool? receiveSmsUpdates,
    bool? notifyLeaveUpdates,
  }) {
    return UserPreferences(
      userType: userType,
      biometricLoginEnabled:
          biometricLoginEnabled ?? this.biometricLoginEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notifyChat: notifyChat ?? this.notifyChat,
      notifyDailyReports: notifyDailyReports ?? this.notifyDailyReports,
      notifyAnnouncements: notifyAnnouncements ?? this.notifyAnnouncements,
      notifyAttendance: notifyAttendance ?? this.notifyAttendance,
      notifyMoments: notifyMoments ?? this.notifyMoments,
      notifyBilling: notifyBilling ?? this.notifyBilling,
      receiveSmsUpdates: receiveSmsUpdates ?? this.receiveSmsUpdates,
      notifyLeaveUpdates: notifyLeaveUpdates ?? this.notifyLeaveUpdates,
    );
  }

  @override
  List<Object?> get props => [
    userType,
    biometricLoginEnabled,
    quietHoursEnabled,
    quietHoursStart,
    quietHoursEnd,
    notifyChat,
    notifyDailyReports,
    notifyAnnouncements,
    notifyAttendance,
    notifyMoments,
    notifyBilling,
    receiveSmsUpdates,
    notifyLeaveUpdates,
  ];
}
