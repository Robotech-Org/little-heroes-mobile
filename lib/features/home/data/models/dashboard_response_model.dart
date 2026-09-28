import 'dart:convert';

// ============================================================
// UNIFIED DASHBOARD RESPONSE
// ============================================================

class DashboardResponse {
  final bool success;
  final dynamic data; // Can be TeacherData or ParentData

  DashboardResponse({required this.success, required this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};

    // Check if data has 'teacher' field (Teacher dashboard)
    if (data.containsKey('teacher')) {
      return DashboardResponse(
        success: message['success'] ?? false,
        data: TeacherData.fromJson(data),
      );
    }
    // Check if data has 'parent' field (Parent dashboard)
    else if (data.containsKey('parent')) {
      return DashboardResponse(
        success: message['success'] ?? false,
        data: ParentData.fromJson(data),
      );
    }

    return DashboardResponse(success: message['success'] ?? false, data: data);
  }
}

// ============================================================
// TEACHER DATA
// ============================================================

// class TeacherData {
//   final TeacherInfo teacher;
//   final ThemeInfo theme;
//   final DashboardMetrics dashboard;

//   TeacherData({
//     required this.teacher,
//     required this.theme,
//     required this.dashboard,
//   });

//   factory TeacherData.fromJson(Map<String, dynamic> json) {
//     return TeacherData(
//       teacher: TeacherInfo.fromJson(json['teacher'] ?? {}),
//       theme: ThemeInfo.fromJson(json['theme'] ?? {}),
//       dashboard: DashboardMetrics.fromJson(json['dashboard'] ?? {}),
//     );
//   }
// }

// ════════════════════════════════════════════════════════════
// TEACHER DATA
// ════════════════════════════════════════════════════════════
class TeacherData {
  final TeacherInfo teacher;
  final ThemeInfo theme;
  final DashboardMetrics dashboard;
  final AttendancePermission attendance; // ✅ NEW

  TeacherData({
    required this.teacher,
    required this.theme,
    required this.dashboard,
    required this.attendance,
  });

  factory TeacherData.fromJson(Map<String, dynamic> json) {
    return TeacherData(
      teacher: TeacherInfo.fromJson(json['teacher'] ?? {}),
      theme: ThemeInfo.fromJson(json['theme'] ?? {}),
      dashboard: DashboardMetrics.fromJson(json['dashboard'] ?? {}),
      attendance: AttendancePermission.fromJson(json['attendance'] ?? {}),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ATTENDANCE PERMISSION — NEW
// ════════════════════════════════════════════════════════════
class AttendancePermission {
  /// True when the teacher is allowed to use the Gate Scanner and
  /// see the Attendance List.
  final bool isPermitted;

  const AttendancePermission({required this.isPermitted});

  factory AttendancePermission.fromJson(Map<String, dynamic> json) {
    // Accepts `is_permitted` OR `isPermitted` — tolerant to snake/camel case
    final value = json['is_permitted'] ?? json['isPermitted'];

    // Default to false if backend hasn't added the field yet
    return AttendancePermission(
      isPermitted: value == true || value == 1 || value == 'true',
    );
  }
}

class TeacherInfo {
  final String name;
  final String firstName;
  final String greeting;
  final String greetingLine;

  TeacherInfo({
    required this.name,
    required this.firstName,
    required this.greeting,
    required this.greetingLine,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      name: json['name']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      greeting: json['greeting']?.toString() ?? '',
      greetingLine: json['greeting_line']?.toString() ?? '',
    );
  }
}

class DashboardMetrics {
  final DailyReportMetric dailyReport;
  final ThreeMonthReportMetric threeMonthReport;
  final WeeklyPlannerMetric weeklyPlanner;
  final ObservationMetric observation;
  final AddMomentMetric addAMoment;

  DashboardMetrics({
    required this.dailyReport,
    required this.threeMonthReport,
    required this.weeklyPlanner,
    required this.observation,
    required this.addAMoment,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      dailyReport: DailyReportMetric.fromJson(json['daily_report'] ?? {}),
      threeMonthReport: ThreeMonthReportMetric.fromJson(
        json['three_month_report'] ?? {},
      ),
      weeklyPlanner: WeeklyPlannerMetric.fromJson(json['weekly_planner'] ?? {}),
      observation: ObservationMetric.fromJson(json['observation'] ?? {}),
      addAMoment: AddMomentMetric.fromJson(json['add_a_moment'] ?? {}),
    );
  }
}

class DailyReportMetric {
  final String label;
  final int reportsLogged;
  final int totalStudents;
  final String summary;
  final String? pendingBadge;

  DailyReportMetric({
    required this.label,
    required this.reportsLogged,
    required this.totalStudents,
    required this.summary,
    this.pendingBadge,
  });

  factory DailyReportMetric.fromJson(Map<String, dynamic> json) {
    return DailyReportMetric(
      label: json['label']?.toString() ?? '',
      reportsLogged: json['reports_logged'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
      summary: json['summary']?.toString() ?? '',
      pendingBadge: json['pending_badge']?.toString(),
    );
  }
}

class ThreeMonthReportMetric {
  final String label;
  final int frameworksCount;
  final String summary;

  ThreeMonthReportMetric({
    required this.label,
    required this.frameworksCount,
    required this.summary,
  });

  factory ThreeMonthReportMetric.fromJson(Map<String, dynamic> json) {
    return ThreeMonthReportMetric(
      label: json['label']?.toString() ?? '',
      frameworksCount: json['frameworks_count'] ?? 0,
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class WeeklyPlannerMetric {
  final String label;
  final int pendingReview;
  final String summary;

  WeeklyPlannerMetric({
    required this.label,
    required this.pendingReview,
    required this.summary,
  });

  factory WeeklyPlannerMetric.fromJson(Map<String, dynamic> json) {
    return WeeklyPlannerMetric(
      label: json['label']?.toString() ?? '',
      pendingReview: json['pending_review'] ?? 0,
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class ObservationMetric {
  final String label;
  final String summary;

  ObservationMetric({required this.label, required this.summary});

  factory ObservationMetric.fromJson(Map<String, dynamic> json) {
    return ObservationMetric(
      label: json['label']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class AddMomentMetric {
  final String label;
  final String summary;

  AddMomentMetric({required this.label, required this.summary});

  factory AddMomentMetric.fromJson(Map<String, dynamic> json) {
    return AddMomentMetric(
      label: json['label']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}

// ============================================================
// PARENT DATA
// ============================================================

class ParentData {
  final ParentInfo parent;
  final ThemeInfo theme;
  final List<ChildInfo> children;
  final QuickAccess quickAccess;

  ParentData({
    required this.parent,
    required this.theme,
    required this.children,
    required this.quickAccess,
  });

  factory ParentData.fromJson(Map<String, dynamic> json) {
    final childrenList = json['children'] as List? ?? [];
    return ParentData(
      parent: ParentInfo.fromJson(json['parent'] ?? {}),
      theme: ThemeInfo.fromJson(json['theme'] ?? {}),
      children: childrenList.map((item) => ChildInfo.fromJson(item)).toList(),
      quickAccess: QuickAccess.fromJson(json['quick_access'] ?? {}),
    );
  }
}

class ParentInfo {
  final String id;
  final String name;
  final String familyName;

  ParentInfo({required this.id, required this.name, required this.familyName});

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      familyName: json['family_name']?.toString() ?? '',
    );
  }
}

class ThemeInfo {
  final String title;
  final String goal;
  final String summary;

  ThemeInfo({required this.title, required this.goal, this.summary = ''});

  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    return ThemeInfo(
      title: json['title']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class ChildInfo {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String initials;
  final String age;
  final String classroom;
  final String status;

  ChildInfo({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.initials,
    required this.age,
    required this.classroom,
    required this.status,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class QuickAccess {
  final QuickAccessItem dailyReport;
  final QuickAccessItem threeMonthReport;
  final QuickAccessItem photoGallery;
  final QuickAccessItem billingAndPayment;

  QuickAccess({
    required this.dailyReport,
    required this.threeMonthReport,
    required this.photoGallery,
    required this.billingAndPayment,
  });

  factory QuickAccess.fromJson(Map<String, dynamic> json) {
    return QuickAccess(
      dailyReport: QuickAccessItem.fromJson(json['daily_report'] ?? {}),
      threeMonthReport: QuickAccessItem.fromJson(
        json['three_month_report'] ?? {},
      ),
      photoGallery: QuickAccessItem.fromJson(json['photo_gallery'] ?? {}),
      billingAndPayment: QuickAccessItem.fromJson(
        json['billing_and_payment'] ?? {},
      ),
    );
  }
}

class QuickAccessItem {
  final String label;
  final String? lastUpdated;
  final int? newCount;

  QuickAccessItem({required this.label, this.lastUpdated, this.newCount});

  factory QuickAccessItem.fromJson(Map<String, dynamic> json) {
    return QuickAccessItem(
      label: json['label']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString(),
      newCount: json['new_count'],
    );
  }
}
