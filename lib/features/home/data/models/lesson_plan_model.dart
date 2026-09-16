class LessonPlanModel {
  final String name;
  final String status;
  final String? adminRejectionNote;
  final String teacher;
  final String classroom;
  final String? curriculumPlan;
  final String? lessonPlanDate;
  final String? lessonPlanWeekStart;
  final String? lessonPlanType;
  final String? frameworkDomain;
  final String? subDomainObjective;
  final String? subject;
  final String? titleOfLesson;
  final String? objective;
  final String? introduction;
  final String? materials;
  final String? keyDevelopmentIndicator;
  final String? teacherDisplayName;
  final String creation;
  final String modified;

  LessonPlanModel({
    required this.name,
    required this.status,
    this.adminRejectionNote,
    required this.teacher,
    required this.classroom,
    this.curriculumPlan,
    this.lessonPlanDate,
    this.lessonPlanWeekStart,
    this.lessonPlanType,
    this.frameworkDomain,
    this.subDomainObjective,
    this.subject,
    this.titleOfLesson,
    this.objective,
    this.introduction,
    this.materials,
    this.keyDevelopmentIndicator,
    this.teacherDisplayName,
    required this.creation,
    required this.modified,
  });

  factory LessonPlanModel.fromJson(Map<String, dynamic> json) {
    return LessonPlanModel(
      name: json['name']?.toString() ?? '',
      status: json['lesson_plan_status']?.toString() ?? 'Draft',
      adminRejectionNote: json['admin_rejection_note']?.toString(),
      teacher: json['lesson_plan_teacher']?.toString() ?? '',
      classroom: json['lesson_plan_classroom']?.toString() ?? '',
      curriculumPlan: json['curriculum_plan']?.toString(),
      lessonPlanDate: json['lesson_plan_date']?.toString(),
      lessonPlanWeekStart: json['lesson_plan_week_start']?.toString(),
      lessonPlanType: json['lesson_plan_type']?.toString(),
      frameworkDomain: json['lesson_plan_framework_domain']?.toString(),
      subDomainObjective: json['lesson_plan_sub_domain_objective']?.toString(),
      subject: json['lesson_plan_subject']?.toString(),
      titleOfLesson: json['lesson_plan_title_of_lesson']?.toString(),
      objective: json['lesson_plan_objective']?.toString(),
      introduction: json['lesson_plan_introduction']?.toString(),
      materials: json['lesson_plan_materials']?.toString(),
      keyDevelopmentIndicator: json['lesson_plan_key_development_indicator']
          ?.toString(),
      teacherDisplayName: json['teacher_display_name']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lesson_plan_status': status,
    'admin_rejection_note': adminRejectionNote,
    'lesson_plan_teacher': teacher,
    'lesson_plan_classroom': classroom,
    'curriculum_plan': curriculumPlan,
    'lesson_plan_date': lessonPlanDate,
    'lesson_plan_week_start': lessonPlanWeekStart,
    'lesson_plan_type': lessonPlanType,
    'lesson_plan_framework_domain': frameworkDomain,
    'lesson_plan_sub_domain_objective': subDomainObjective,
    'lesson_plan_subject': subject,
    'lesson_plan_title_of_lesson': titleOfLesson,
    'lesson_plan_objective': objective,
    'lesson_plan_introduction': introduction,
    'lesson_plan_materials': materials,
    'lesson_plan_key_development_indicator': keyDevelopmentIndicator,
    'teacher_display_name': teacherDisplayName,
    'creation': creation,
    'modified': modified,
  };

  /// Whether the plan was rejected with a reason attached
  bool get hasRejection =>
      status.toLowerCase() == 'rejected' &&
      adminRejectionNote != null &&
      adminRejectionNote!.trim().isNotEmpty;

  String get statusText {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'draft':
        return 'Draft';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
