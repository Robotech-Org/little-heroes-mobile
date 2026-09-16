class CurriculumPlanModel {
  final String name;
  final String title;
  final String framework;
  final String monthlyTheme;
  final String goal;
  final String ageGroup;
  final String term;
  final String startDate;
  final String endDate;
  final String description;

  CurriculumPlanModel({
    required this.name,
    required this.title,
    required this.framework,
    required this.monthlyTheme,
    required this.goal,
    required this.ageGroup,
    required this.term,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory CurriculumPlanModel.fromJson(Map<String, dynamic> json) {
    return CurriculumPlanModel(
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      framework: json['framework']?.toString() ?? '',
      monthlyTheme: json['monthly_theme']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      ageGroup: json['age_group']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}
