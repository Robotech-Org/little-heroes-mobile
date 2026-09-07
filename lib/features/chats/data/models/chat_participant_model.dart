class ChatParticipantModel {
  final String name;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? relationshipType;
  final String? status;
  final String creation;
  final String modified;

  ChatParticipantModel({
    required this.name,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.relationshipType,
    this.status,
    required this.creation,
    required this.modified,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      name: json['name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      relationshipType: json['relationship_type']?.toString(),
      status: json['status']?.toString(),
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
      'creation': creation,
      'modified': modified,
    };
  }
}
