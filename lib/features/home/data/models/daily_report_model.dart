class DailyReportModel {
  final String name;
  final String student;
  final String studentName;
  final String studentClassroom;
  final String reportDate;
  final String recordedBy;
  final String dailyReportStatus;
  final String mealsAndSnacks;
  final String napTime;
  final String moodAndBehavior;
  final String healthAndHygiene;
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
    required this.napTime,
    required this.moodAndBehavior,
    required this.healthAndHygiene,
    required this.creation,
    required this.modified,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      name: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentClassroom: json['student_classroom']?.toString() ?? '',
      reportDate: json['report_date']?.toString() ?? '',
      recordedBy: json['recorded_by']?.toString() ?? '',
      dailyReportStatus: json['daily_report_status']?.toString() ?? 'Saved',
      mealsAndSnacks: json['meals_and_snacks']?.toString() ?? '',
      napTime: json['nap_time']?.toString() ?? '',
      moodAndBehavior: json['mood_and_behavior']?.toString() ?? '',
      healthAndHygiene: json['health_and_hygiene']?.toString() ?? '',
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student': student,
      'student_name': studentName,
      'student_classroom': studentClassroom,
      'report_date': reportDate,
      'recorded_by': recordedBy,
      'daily_report_status': dailyReportStatus,
      'meals_and_snacks': mealsAndSnacks,
      'nap_time': napTime,
      'mood_and_behavior': moodAndBehavior,
      'health_and_hygiene': healthAndHygiene,
      'creation': creation,
      'modified': modified,
    };
  }
}
