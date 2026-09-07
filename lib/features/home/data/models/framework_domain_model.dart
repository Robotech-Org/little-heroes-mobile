class FrameworkDomainModel {
  final String name;
  final String domainTitle;
  final String domainCode;
  final int sequence;
  final String creation;
  final String modified;

  FrameworkDomainModel({
    required this.name,
    required this.domainTitle,
    required this.domainCode,
    required this.sequence,
    required this.creation,
    required this.modified,
  });

  factory FrameworkDomainModel.fromJson(Map<String, dynamic> json) {
    return FrameworkDomainModel(
      name: json['name']?.toString() ?? '',
      domainTitle: json['domain_title']?.toString() ?? '',
      domainCode: json['domain_code']?.toString() ?? '',
      sequence: json['sequence'] ?? 0,
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain_title': domainTitle,
      'domain_code': domainCode,
      'sequence': sequence,
      'creation': creation,
      'modified': modified,
    };
  }
}
