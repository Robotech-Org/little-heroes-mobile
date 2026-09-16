
class DailyReportDraftModel {
  final String? reportName; // null = new report, set = editing existing
  final String? studentId;
  final String? studentName;
  final String? classroomName;
  final String? reportDate;
  final String selectedMeal;
  final String selectedNap;
  final String selectedMood;
  final String selectedHealth;
  final String messageToParent;
  final DateTime savedAt;

  DailyReportDraftModel({
    this.reportName,
    this.studentId,
    this.studentName,
    this.classroomName,
    this.reportDate,
    this.selectedMeal = 'Ate All',
    this.selectedNap = 'Slept Well (1-2+ Hours)',
    this.selectedMood = 'Happy & Engaged',
    this.selectedHealth = 'Good / Normal',
    this.messageToParent = '',
    required this.savedAt,
  });

  /// Unique key per draft.
  /// - Editing an existing report → key by report name.
  /// - New report → key by student id (so each student gets their own draft).
  /// - No student selected yet → fallback key.
  String get draftKey {
    if (reportName != null && reportName!.isNotEmpty) {
      return 'report_$reportName';
    }
    if (studentId != null && studentId!.isNotEmpty) {
      return 'student_$studentId';
    }
    return 'new_draft';
  }

  Map<String, dynamic> toMap() => {
    'reportName': reportName,
    'studentId': studentId,
    'studentName': studentName,
    'classroomName': classroomName,
    'reportDate': reportDate,
    'selectedMeal': selectedMeal,
    'selectedNap': selectedNap,
    'selectedMood': selectedMood,
    'selectedHealth': selectedHealth,
    'messageToParent': messageToParent,
    'savedAt': savedAt.toIso8601String(),
  };

  factory DailyReportDraftModel.fromMap(Map<String, dynamic> map) {
    return DailyReportDraftModel(
      reportName: map['reportName'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      classroomName: map['classroomName'],
      reportDate: map['reportDate'],
      selectedMeal: map['selectedMeal'] ?? 'Ate All',
      selectedNap: map['selectedNap'] ?? 'Slept Well (1-2+ Hours)',
      selectedMood: map['selectedMood'] ?? 'Happy & Engaged',
      selectedHealth: map['selectedHealth'] ?? 'Good / Normal',
      messageToParent: map['messageToParent'] ?? '',
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}
