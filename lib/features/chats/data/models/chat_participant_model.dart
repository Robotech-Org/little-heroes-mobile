

class ChatParticipantModel {
  final String name;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? relationshipType;
  final String? status;
  final String? teacherFirstName;
  final String? teacherLastName;
  final String creation;
  final String modified;

  ChatParticipantModel({
    required this.name,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.relationshipType,
    this.status,
    this.teacherFirstName,
    this.teacherLastName,
    required this.creation,
    required this.modified,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    // Try to get full_name first
    String fullName = json['full_name']?.toString() ?? '';

    // If full_name is empty, try first_name + last_name (for teachers)
    if (fullName.isEmpty) {
      final firstName = json['teacher_first_name']?.toString() ?? '';
      final lastName = json['teacher_last_name']?.toString() ?? '';
      fullName = '$firstName $lastName'.trim();

      // If still empty, try name field
      if (fullName.isEmpty) {
        fullName = json['name']?.toString() ?? '';
      }
    }

    return ChatParticipantModel(
      name: json['name']?.toString() ?? '',
      fullName: fullName,
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      relationshipType: json['relationship_type']?.toString(),
      status: json['status']?.toString(),
      teacherFirstName: json['teacher_first_name']?.toString(),
      teacherLastName: json['teacher_last_name']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'relationship_type': relationshipType,
      'status': status,
      'teacher_first_name': teacherFirstName,
      'teacher_last_name': teacherLastName,
      'creation': creation,
      'modified': modified,
    };
  }

  // Helper to get initials
  String get initials {
    if (fullName.isEmpty) return '?';

    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    final first = parts[0][0];
    final last = parts[parts.length - 1][0];
    return '$first$last'.toUpperCase();
  }
}
