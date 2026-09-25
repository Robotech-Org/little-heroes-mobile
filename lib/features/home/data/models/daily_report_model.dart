// class DailyReportModel {
//   final String name;
//   final String student;
//   final String studentName;
//   final String studentClassroom;
//   final String reportDate;
//   final String recordedBy;
//   final String dailyReportStatus;
//   final String mealsAndSnacks;
//   final String napTime;
//   final String moodAndBehavior;
//   final String healthAndHygiene;
//   final String dailyReportNotes;
//   final String creation;
//   final String modified;

//   DailyReportModel({
//     required this.name,
//     required this.student,
//     required this.studentName,
//     required this.studentClassroom,
//     required this.reportDate,
//     required this.recordedBy,
//     required this.dailyReportStatus,
//     required this.mealsAndSnacks,
//     required this.napTime,
//     required this.moodAndBehavior,
//     required this.healthAndHygiene,
//     required this.dailyReportNotes, // NEW
//     required this.creation,
//     required this.modified,
//   });

//   factory DailyReportModel.fromJson(Map<String, dynamic> json) {
//     return DailyReportModel(
//       name: json['name']?.toString() ?? '',
//       student: json['student']?.toString() ?? '',
//       studentName: json['student_name']?.toString() ?? '',
//       studentClassroom: json['student_classroom']?.toString() ?? '',
//       reportDate: json['report_date']?.toString() ?? '',
//       recordedBy: json['recorded_by']?.toString() ?? '',
//       dailyReportStatus: json['daily_report_status']?.toString() ?? 'Saved',
//       mealsAndSnacks: json['meals_and_snacks']?.toString() ?? '',
//       napTime: json['nap_time']?.toString() ?? '',
//       moodAndBehavior: json['mood_and_behavior']?.toString() ?? '',
//       healthAndHygiene: json['health_and_hygiene']?.toString() ?? '',
//       dailyReportNotes: json['daily_report_notes']?.toString() ?? '', // NEW
//       creation: json['creation']?.toString() ?? '',
//       modified: json['modified']?.toString() ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'student': student,
//       'student_name': studentName,
//       'student_classroom': studentClassroom,
//       'report_date': reportDate,
//       'recorded_by': recordedBy,
//       'daily_report_status': dailyReportStatus,
//       'meals_and_snacks': mealsAndSnacks,
//       'nap_time': napTime,
//       'mood_and_behavior': moodAndBehavior,
//       'health_and_hygiene': healthAndHygiene,
//       'daily_report_notes': dailyReportNotes, // NEW
//       'creation': creation,
//       'modified': modified,
//     };
//   }
// }

class DailyReportModel {
  final String name;
  final String student;
  final String studentName;
  final String studentClassroom;
  final String reportDate;
  final String recordedBy;
  final String dailyReportStatus;

  // ── Meals ────────────────────────────────────────────
  final String mealsAndSnacks;
  final String mealsAndSnacksNotes;

  // ── Nap ──────────────────────────────────────────────
  final String napTime;
  final String napDuration;
  final String napTimeNotes;

  // ── Mood ─────────────────────────────────────────────
  final String moodAndBehavior;
  final String moodAndBehaviorNotes;

  // ── Learning / Play ──────────────────────────────────
  final String learningAndPlayActivities;
  final String learningAndPlayActivitiesNotes;

  // ── Diaper / Toilet ──────────────────────────────────
  final String diaperToiletTraining;
  final String diaperToiletTrainingNotes;

  // ── Health ───────────────────────────────────────────
  final String healthAndHygiene;
  final String healthCheckNotes;

  // ── Reminders (Check = 0/1) ──────────────────────────
  final bool reminderBringClothes;
  final String reminderClothesDetails;
  final bool reminderBringToyBlanket;
  final String reminderToyBlanketDetails;
  final bool reminderUpcomingEvent;
  final String reminderUpcomingEventDetails;
  final bool reminderOther;
  final String reminderOtherDetails;

  // ── Free-form ────────────────────────────────────────
  final String specialNotesAndReminders;
  final String dailyReportNotes;

  final String creation;
  final String modified;

  DailyReportModel({
    required this.name,
    required this.student,
    required this.studentName,
    required this.studentClassroom,
    required this.reportDate,
    required this.recordedBy,
    required this.dailyReportStatus,
    required this.mealsAndSnacks,
    this.mealsAndSnacksNotes = '',
    required this.napTime,
    this.napDuration = '',
    this.napTimeNotes = '',
    required this.moodAndBehavior,
    this.moodAndBehaviorNotes = '',
    this.learningAndPlayActivities = '',
    this.learningAndPlayActivitiesNotes = '',
    this.diaperToiletTraining = '',
    this.diaperToiletTrainingNotes = '',
    required this.healthAndHygiene,
    this.healthCheckNotes = '',
    this.reminderBringClothes = false,
    this.reminderClothesDetails = '',
    this.reminderBringToyBlanket = false,
    this.reminderToyBlanketDetails = '',
    this.reminderUpcomingEvent = false,
    this.reminderUpcomingEventDetails = '',
    this.reminderOther = false,
    this.reminderOtherDetails = '',
    this.specialNotesAndReminders = '',
    required this.dailyReportNotes,
    required this.creation,
    required this.modified,
  });

  // ── Helper: parse Check (0/1/true/false) ─────────────
  static bool _parseCheck(dynamic v) =>
      v == 1 || v == true || v == '1' || v == 'true';

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    String s(String key) => json[key]?.toString() ?? '';
    return DailyReportModel(
      name: s('name'),
      student: s('student'),
      studentName: s('student_name'),
      studentClassroom: s('student_classroom'),
      reportDate: s('report_date'),
      recordedBy: s('recorded_by'),
      dailyReportStatus: s('daily_report_status').isEmpty
          ? 'Pending'
          : s('daily_report_status'),

      mealsAndSnacks: s('meals_and_snacks'),
      mealsAndSnacksNotes: s('meals_and_snacks_notes'),

      napTime: s('nap_time'),
      napDuration: s('nap_duration'),
      napTimeNotes: s('nap_time_notes'),

      moodAndBehavior: s('mood_and_behavior'),
      moodAndBehaviorNotes: s('mood_and_behavior_notes'),

      learningAndPlayActivities: s('learning_and_play_activities'),
      learningAndPlayActivitiesNotes: s('learning_and_play_activities_notes'),

      diaperToiletTraining: s('diaper_toilet_training'),
      diaperToiletTrainingNotes: s('diaper_toilet_training_notes'),

      healthAndHygiene: s('health_and_hygiene'),
      healthCheckNotes: s('health_check_notes'),

      reminderBringClothes: _parseCheck(json['reminder_bring_clothes']),
      reminderClothesDetails: s('reminder_clothes_details'),
      reminderBringToyBlanket: _parseCheck(json['reminder_bring_toy_blanket']),
      reminderToyBlanketDetails: s('reminder_toy_blanket_details'),
      reminderUpcomingEvent: _parseCheck(json['reminder_upcoming_event']),
      reminderUpcomingEventDetails: s('reminder_upcoming_event_details'),
      reminderOther: _parseCheck(json['reminder_other']),
      reminderOtherDetails: s('reminder_other_details'),

      specialNotesAndReminders: s('special_notes_and_reminders'),
      dailyReportNotes: s('daily_report_notes'),

      creation: s('creation'),
      modified: s('modified'),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'student': student,
    'student_name': studentName,
    'student_classroom': studentClassroom,
    'report_date': reportDate,
    'recorded_by': recordedBy,
    'daily_report_status': dailyReportStatus,

    'meals_and_snacks': mealsAndSnacks,
    'meals_and_snacks_notes': mealsAndSnacksNotes,

    'nap_time': napTime,
    'nap_duration': napDuration,
    'nap_time_notes': napTimeNotes,

    'mood_and_behavior': moodAndBehavior,
    'mood_and_behavior_notes': moodAndBehaviorNotes,

    'learning_and_play_activities': learningAndPlayActivities,
    'learning_and_play_activities_notes': learningAndPlayActivitiesNotes,

    'diaper_toilet_training': diaperToiletTraining,
    'diaper_toilet_training_notes': diaperToiletTrainingNotes,

    'health_and_hygiene': healthAndHygiene,
    'health_check_notes': healthCheckNotes,

    'reminder_bring_clothes': reminderBringClothes ? 1 : 0,
    'reminder_clothes_details': reminderClothesDetails,
    'reminder_bring_toy_blanket': reminderBringToyBlanket ? 1 : 0,
    'reminder_toy_blanket_details': reminderToyBlanketDetails,
    'reminder_upcoming_event': reminderUpcomingEvent ? 1 : 0,
    'reminder_upcoming_event_details': reminderUpcomingEventDetails,
    'reminder_other': reminderOther ? 1 : 0,
    'reminder_other_details': reminderOtherDetails,

    'special_notes_and_reminders': specialNotesAndReminders,
    'daily_report_notes': dailyReportNotes,

    'creation': creation,
    'modified': modified,
  };
}
