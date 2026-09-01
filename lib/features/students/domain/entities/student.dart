class Student {
  final String id;
  final String name;
  final String initials;
  final String grade;
  final String className;
  final String lastActivity;
  final bool isActive;

  // Details
  final String age;
  final String gender;
  final String dateOfBirth;
  final String parentName;
  final String parentPhone;
  final String email;
  final String attendance;
  final String academicProgress;
  final String favoriteSubject;

  const Student({
    required this.id,
    required this.name,
    required this.initials,
    required this.grade,
    required this.className,
    required this.lastActivity,
    required this.isActive,
    required this.age,
    required this.gender,
    required this.dateOfBirth,
    required this.parentName,
    required this.parentPhone,
    required this.email,
    required this.attendance,
    required this.academicProgress,
    required this.favoriteSubject,
  });
}
