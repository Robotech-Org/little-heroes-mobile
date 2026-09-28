class ArrivedStudent {
  final String student;
  final String studentName;
  final String? studentPhoto;
  final String arrivedAt;
  final String classroom;

  const ArrivedStudent({
    required this.student,
    required this.studentName,
    this.studentPhoto,
    required this.arrivedAt,
    required this.classroom,
  });

  factory ArrivedStudent.fromJson(Map<String, dynamic> m) => ArrivedStudent(
    student: m['student']?.toString() ?? '',
    studentName: m['student_name']?.toString() ?? '',
    studentPhoto: m['student_photo']?.toString(),
    arrivedAt: m['arrived_at']?.toString() ?? '',
    classroom: m['classroom']?.toString() ?? '',
  );
}
