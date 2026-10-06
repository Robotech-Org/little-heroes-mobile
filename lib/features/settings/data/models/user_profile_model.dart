import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.userType,
    required super.fullName,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    super.emergencyPhone,
    super.userImage,
    super.relationshipType,
    super.address,
    super.children,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse children array safely
    final rawChildren = json['children'];
    final children = <LinkedChild>[];
    if (rawChildren is List) {
      for (final c in rawChildren) {
        if (c is Map) {
          children.add(LinkedChild.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    return UserProfileModel(
      userId: (json['user_id'] ?? '').toString(),
      userType: (json['user_type'] ?? 'Parent').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      emergencyPhone: json['emergency_phone']?.toString(),
      userImage: json['user_image']?.toString(),
      relationshipType: json['relationship_type']?.toString(),
      address: json['address']?.toString(),
      children: children,
    );
  }
}
