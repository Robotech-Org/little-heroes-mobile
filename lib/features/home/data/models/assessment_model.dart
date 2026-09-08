

class AssessmentModel {
  final String name;
  final String domain;
  final String competency;
  final String competencyTitle;
  final int levelAchieved;
  final String? levelDescription;
  final String? notes;
  final String? parent;

  AssessmentModel({
    required this.name,
    required this.domain,
    required this.competency,
    required this.competencyTitle,
    required this.levelAchieved,
    this.levelDescription,
    this.notes,
    this.parent,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    // Get the competency value from the server
    String competencyValue = json['competency']?.toString() ?? '';

    // Map server competency to framework code if needed
    // If the competency is a name like "Social Studies", map it
    String frameworkCode = _mapToFrameworkCode(competencyValue);

    // If no mapping found, use the original value
    final finalCompetency = frameworkCode.isNotEmpty
        ? frameworkCode
        : competencyValue;

    return AssessmentModel(
      name: json['name']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
      competency: finalCompetency,
      competencyTitle: json['competency_title']?.toString() ?? '',
      levelAchieved: json['level_achieved'] ?? 0,
      levelDescription: json['level_description']?.toString(),
      notes: json['notes']?.toString(),
      parent: json['parent']?.toString(),
    );
  }

  // Helper to map server competency to framework code
  static String _mapToFrameworkCode(String value) {
    // If it's already a framework code (AL1, SE2, etc.)
    if (value.startsWith('AL') || value.startsWith('SE')) {
      return value;
    }

    // Map common competency names to framework codes
    final Map<String, String> competencyMap = {
      'GG': 'AL1', // Geography -> Initiative and Planning
      'Initiative and Planning': 'AL1',
      'Problem Solving with Materials': 'AL2',
      'Reflection': 'AL3',
      'Emotional Expression and Regulation': 'SE1',
      'Building Relationships with Adults': 'SE2',
      'Building Relationships with Other Children': 'SE3',
      'Community and Classroom Participation': 'SE4',
      'Conflict Resolution': 'SE5',
      'Social Studies': 'AL1',
    };

    return competencyMap[value] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'domain': domain,
      'competency': competency,
      'competency_title': competencyTitle,
      'level_achieved': levelAchieved,
      'level_description': levelDescription,
      'notes': notes,
      'parent': parent,
    };
  }
}
