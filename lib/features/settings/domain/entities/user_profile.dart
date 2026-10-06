import 'package:equatable/equatable.dart';

class LinkedChild extends Equatable {
  final String studentId;
  final String studentName;
  final String? studentPhoto;
  final String classroom;
  final String status;

  const LinkedChild({
    required this.studentId,
    required this.studentName,
    this.studentPhoto,
    required this.classroom,
    required this.status,
  });

  factory LinkedChild.fromJson(Map<String, dynamic> json) {
    return LinkedChild(
      studentId: (json['student_id'] ?? '').toString(),
      studentName: (json['student_name'] ?? '').toString(),
      studentPhoto: json['student_photo']?.toString(),
      classroom: (json['classroom'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    studentPhoto,
    classroom,
    status,
  ];
}

class UserProfile extends Equatable {
  final String userId;
  final String userType;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? emergencyPhone;
  final String? userImage;
  final String? relationshipType;
  final String? address;
  final List<LinkedChild> children;

  const UserProfile({
    required this.userId,
    required this.userType,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.emergencyPhone,
    this.userImage,
    this.relationshipType,
    this.address,
    this.children = const [],
  });

  bool get isParent => userType.toLowerCase() == 'parent';
  bool get isTeacher => userType.toLowerCase() == 'teacher';

  @override
  List<Object?> get props => [
    userId,
    userType,
    fullName,
    firstName,
    lastName,
    email,
    phoneNumber,
    emergencyPhone,
    userImage,
    relationshipType,
    address,
    children,
  ];
}
