// class Student {
//   final String name;
//   final String gender;
//   final String dateOfBirth;
//   final String ageRange;
//   final String enrollmentStatus;
//   final String creation;
//   final String modified;

//   Student({
//     required this.name,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.ageRange,
//     required this.enrollmentStatus,
//     required this.creation,
//     required this.modified,
//   });

//   factory Student.fromJson(Map<String, dynamic> json) {
//     return Student(
//       name: json['child_full_name']?.toString() ?? '',
//       gender: json['child_gender']?.toString() ?? '',
//       dateOfBirth: json['child_date_of_birth']?.toString() ?? '',
//       ageRange: json['child_age_range']?.toString() ?? '',
//       enrollmentStatus: json['enrollment_status']?.toString() ?? '',
//       creation: json['creation']?.toString() ?? '',
//       modified: json['modified']?.toString() ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'child_full_name': name,
//       'child_gender': gender,
//       'child_date_of_birth': dateOfBirth,
//       'child_age_range': ageRange,
//       'enrollment_status': enrollmentStatus,
//       'creation': creation,
//       'modified': modified,
//     };
//   }

//   // Helper to get initials
//   String get initials {
//     final parts = name.trim().split(' ');
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }

//   // Helper to get status color
//   String get statusText {
//     switch (enrollmentStatus.toLowerCase()) {
//       case 'active':
//         return 'Active';
//       case 'inactive':
//         return 'Inactive';
//       case 'pending':
//         return 'Pending';
//       default:
//         return enrollmentStatus;
//     }
//   }

//   bool get isActive {
//     return enrollmentStatus.toLowerCase() == 'active';
//   }

//   // ============================================================
//   // ADD THESE METHODS FOR DROPDOWN TO WORK PROPERLY
//   // ============================================================

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Student && other.name == name;
//   }

//   @override
//   int get hashCode => name.hashCode;

//   @override
//   String toString() => name;
// }

class Student {
  final String id; // This is the 'name' field from the API response
  final String name;
  final String gender;
  final String dateOfBirth;
  final String ageRange;
  final String enrollmentStatus;
  final String creation;
  final String modified;

  Student({
    required this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.ageRange,
    required this.enrollmentStatus,
    required this.creation,
    required this.modified,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['name']?.toString() ?? '', // 'name' is actually the ID
      name: json['child_full_name']?.toString() ?? '',
      gender: json['child_gender']?.toString() ?? '',
      dateOfBirth: json['child_date_of_birth']?.toString() ?? '',
      ageRange: json['child_age_range']?.toString() ?? '',
      enrollmentStatus: json['enrollment_status']?.toString() ?? '',
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id, // 'name' is the ID in the API
      'child_full_name': name,
      'child_gender': gender,
      'child_date_of_birth': dateOfBirth,
      'child_age_range': ageRange,
      'enrollment_status': enrollmentStatus,
      'creation': creation,
      'modified': modified,
    };
  }

  // Helper to get initials
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Helper to get status color
  String get statusText {
    switch (enrollmentStatus.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'pending':
        return 'Pending';
      default:
        return enrollmentStatus;
    }
  }

  bool get isActive {
    return enrollmentStatus.toLowerCase() == 'active';
  }

  // ============================================================
  // EQUALITY AND HASHCODE FOR DROPDOWN
  // ============================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
