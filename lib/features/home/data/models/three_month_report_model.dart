// import 'dart:ui';

// import 'package:flutter/material.dart' show Colors, ColorScheme;

// import 'assessment_model.dart';

// class ThreeMonthReportModel {
//   final String name;
//   final String student;
//   final String studentName;
//   final String classroom;
//   final String month;
//   final int year;
//   final String reportDate;
//   final String status;
//   final String teacher;
//   final String? reviewedBy;
//   final String? submittedOn;
//   final String creation;
//   final String modified;
//   final List<AssessmentModel> assessments;

//   ThreeMonthReportModel({
//     required this.name,
//     required this.student,
//     required this.studentName,
//     required this.classroom,
//     required this.month,
//     required this.year,
//     required this.reportDate,
//     required this.status,
//     required this.teacher,
//     this.reviewedBy,
//     this.submittedOn,
//     required this.creation,
//     required this.modified,
//     this.assessments = const [], // Default empty list
//   });

//   factory ThreeMonthReportModel.fromJson(Map<String, dynamic> json) {
//     // Parse assessments - handle if missing
//     final assessmentsList = json['assessments'] as List? ?? [];
//     final assessments = assessmentsList
//         .map((item) => AssessmentModel.fromJson(item))
//         .toList();

//     return ThreeMonthReportModel(
//       name: json['name']?.toString() ?? '',
//       student: json['student']?.toString() ?? '',
//       studentName: json['student_name']?.toString() ?? '',
//       classroom: json['classroom']?.toString() ?? '',
//       month: json['month']?.toString() ?? '',
//       year: json['year'] ?? 0,
//       reportDate: json['report_date']?.toString() ?? '',
//       status: json['status']?.toString() ?? 'Draft',
//       teacher: json['teacher']?.toString() ?? '',
//       reviewedBy: json['reviewed_by']?.toString(),
//       submittedOn: json['submitted_on']?.toString(),
//       creation: json['creation']?.toString() ?? '',
//       modified: json['modified']?.toString() ?? '',
//       assessments: assessments,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'student': student,
//       'student_name': studentName,
//       'classroom': classroom,
//       'month': month,
//       'year': year,
//       'report_date': reportDate,
//       'status': status,
//       'teacher': teacher,
//       'reviewed_by': reviewedBy,
//       'submitted_on': submittedOn,
//       'creation': creation,
//       'modified': modified,
//       'assessments': assessments.map((e) => e.toJson()).toList(),
//     };
//   }

//   // Helper to get initials
//   String get initials {
//     final parts = studentName.trim().split(' ');
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }

//   // Helper to get status text
//   String get statusText {
//     switch (status.toLowerCase()) {
//       case 'submitted':
//         return 'Complete';
//       case 'saved':
//         return 'In Progress';
//       case 'draft':
//         return 'Not Started';
//       case 'pending':
//         return 'Pending';
//       default:
//         return status;
//     }
//   }

//   // Helper to get status color
//   Color getStatusColor(ColorScheme colorScheme) {
//     switch (status.toLowerCase()) {
//       case 'submitted':
//         return Colors.green;
//       case 'saved':
//         return Colors.orange;
//       case 'draft':
//         return Colors.grey;
//       case 'pending':
//         return Colors.amber;
//       case 'reviewed':
//         return Colors.blue;
//       default:
//         return colorScheme.primary;
//     }
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart' show Colors, ColorScheme;

import 'assessment_model.dart';

class ThreeMonthReportModel {
  final String name;
  final String student;
  final String studentName;
  final String classroom;

  // ── NEW: academic year + period window ──────────────
  final String? academicYear;
  final String? periodStartDate; // "2026-09-01"
  final String? periodEndDate; // "2026-11-30"

  // ── NEW: narrative fields ───────────────────────────
  final String? reportIntroduction; // "<p>…</p>"
  final String? reportSummary; // "<p>…</p>" (optional)

  final String status;
  final String teacher;
  final String? reviewedBy;
  final String? submittedOn;
  final String creation;
  final String modified;
  final List<AssessmentModel> assessments;

  ThreeMonthReportModel({
    required this.name,
    required this.student,
    required this.studentName,
    required this.classroom,
    this.academicYear,
    this.periodStartDate,
    this.periodEndDate,
    this.reportIntroduction,
    this.reportSummary,
    required this.status,
    required this.teacher,
    this.reviewedBy,
    this.submittedOn,
    required this.creation,
    required this.modified,
    this.assessments = const [],
  });

  factory ThreeMonthReportModel.fromJson(Map<String, dynamic> json) {
    // Parse assessments - handle if missing
    final assessmentsList = json['assessments'] as List? ?? [];
    final assessments = assessmentsList
        .map((item) => AssessmentModel.fromJson(item))
        .toList();

    return ThreeMonthReportModel(
      name: json['name']?.toString() ?? '',
      student: json['student']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',

      // ── NEW ─────────────────────────────────────────
      academicYear: json['academic_year']?.toString(),
      periodStartDate: json['period_start_date']?.toString(),
      periodEndDate: json['period_end_date']?.toString(),
      reportIntroduction: json['report_introduction']?.toString(),
      reportSummary: json['report_summary']?.toString(),

      status: json['status']?.toString() ?? 'Draft',
      teacher: json['teacher']?.toString() ?? '',
      reviewedBy: json['reviewed_by']?.toString(),
      submittedOn: json['submitted_on']?.toString(),
      creation: json['creation']?.toString() ?? '',
      modified: json['modified']?.toString() ?? '',
      assessments: assessments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student': student,
      'student_name': studentName,
      'classroom': classroom,

      // ── NEW ─────────────────────────────────────────
      'academic_year': academicYear,
      'period_start_date': periodStartDate,
      'period_end_date': periodEndDate,
      'report_introduction': reportIntroduction,
      'report_summary': reportSummary,

      'status': status,
      'teacher': teacher,
      'reviewed_by': reviewedBy,
      'submitted_on': submittedOn,
      'creation': creation,
      'modified': modified,
      'assessments': assessments.map((e) => e.toJson()).toList(),
    };
  }

  // ══════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════

  /// Safe initials — never throws `RangeError` on empty/whitespace names.
  String get initials {
    final parts = studentName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.isNotEmpty ? p[0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Human-readable status label (aligned with the workflow states).
  String get statusText {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'needs revision':
        return 'Needs Revision';
      case 'shared with parent':
        return 'Shared';
      case 'saved':
        return 'In Progress';
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      default:
        return status;
    }
  }

  /// Status color for badges.
  Color getStatusColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'shared with parent':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'needs revision':
        return Colors.orange;
      case 'saved':
        return Colors.amber;
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.amber;
      case 'reviewed':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
  }

  /// Parsed period start (or null if absent/invalid).
  DateTime? get periodStart {
    if (periodStartDate == null || periodStartDate!.isEmpty) return null;
    return DateTime.tryParse(periodStartDate!.replaceFirst(' ', 'T'));
  }

  /// Parsed period end (or null if absent/invalid).
  DateTime? get periodEnd {
    if (periodEndDate == null || periodEndDate!.isEmpty) return null;
    return DateTime.tryParse(periodEndDate!.replaceFirst(' ', 'T'));
  }

  /// Pretty period label, e.g. "Sep 1, 2026 – Nov 30, 2026".
  /// Falls back to '' if either boundary is missing.
  String get periodLabel {
    final s = periodStart;
    final e = periodEnd;
    if (s == null || e == null) return '';
    return '${_shortDate(s)} – ${_shortDate(e)}';
  }

  /// Parsed creation time.
  DateTime? get creationDate {
    if (creation.isEmpty) return null;
    return DateTime.tryParse(creation.replaceFirst(' ', 'T'));
  }

  /// Strips HTML tags (useful if you want to display intro/summary as plain text).
  String get plainIntroduction => _stripHtml(reportIntroduction ?? '');
  String get plainSummary => _stripHtml(reportSummary ?? '');

  static String _shortDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _stripHtml(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}
