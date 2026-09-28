class StudentStatus {
  final String student;
  final String studentName;
  final String? studentPhoto;
  final String status; // Pending | ARRIVED | IN | OUT | LEFT | ABSENT

  const StudentStatus({
    required this.student,
    required this.studentName,
    this.studentPhoto,
    required this.status,
  });

  bool get isIn => status.toUpperCase() == 'IN';

  factory StudentStatus.fromJson(Map<String, dynamic> m) => StudentStatus(
    student: m['student']?.toString() ?? '',
    studentName: m['student_name']?.toString() ?? '',
    studentPhoto: m['student_photo']?.toString(),
    status: m['status']?.toString() ?? 'Pending',
  );
}
