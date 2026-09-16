class DomainNarrativeEntry {
  final String domainCode; // AL, CA, LLC, ...
  final String domainTitle; // "Approaches to Learning"
  final String narrative; // teacher's note
  final String summary; // teacher's short summary / rating text

  DomainNarrativeEntry({
    required this.domainCode,
    required this.domainTitle,
    this.narrative = '',
    this.summary = '',
  });

  DomainNarrativeEntry copyWith({String? narrative, String? summary}) {
    return DomainNarrativeEntry(
      domainCode: domainCode,
      domainTitle: domainTitle,
      narrative: narrative ?? this.narrative,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toJson() => {
    'domain_code': domainCode,
    'domain_title': domainTitle,
    'narrative': narrative,
    'summary': summary,
  };
}

class ThreeMonthNarrativeModel {
  final String studentId;
  final String studentName;
  final String monthRange;
  final List<DomainNarrativeEntry> domains;
  final DateTime savedAt;

  ThreeMonthNarrativeModel({
    required this.studentId,
    required this.studentName,
    required this.monthRange,
    required this.domains,
    required this.savedAt,
  });

  /// Submit payload for the backend.
  Map<String, dynamic> toRequestJson() => {
    'student': studentId,
    'student_name': studentName,
    'month_range': monthRange,
    'report_date': DateTime.now().toIso8601String().split('T').first,
    'status': 'Submitted',
    'domains': domains.map((d) => d.toJson()).toList(),
  };
}
