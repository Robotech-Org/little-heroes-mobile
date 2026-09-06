class ThreeMonthReportModel {
  final String name;
  final String student;
  final String studentName;
  final String classroom;
  final String month;
  final int year;
  final String reportDate;
  final String status;
  final String teacher;
  final String? reviewedBy;
  final String? submittedOn;
  final String creation;
  final String modified;

  ThreeMonthReportModel({
    required this.name,
    required this.student,
    required this.studentName,
    required this.classroom,
    required this.month,
    required this.year,
    required this.reportDate,
    required this.status,
    required this.teacher,
    this.reviewedBy,
    this.submittedOn,
    required this.creation,
    required this.modified,
  });

  factory ThreeMonthReportModel.fromJson(Map<String, dynamic> json) {
    return ThreeMonthReportModel(
      name: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      year: json['year'] ?? 0,
      reportDate: json['report_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      teacher: json['teacher']?.toString() ?? '',
      reviewedBy: json['reviewed_by']?.toString(),
      submittedOn: json['submitted_on']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student': student,
      'student_name': studentName,
      'classroom': classroom,
      'month': month,
      'year': year,
      'report_date': reportDate,
      'status': status,
      'teacher': teacher,
      'reviewed_by': reviewedBy,
      'submitted_on': submittedOn,
      'creation': creation,
      'modified': modified,
    };
  }
}
