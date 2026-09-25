

import 'dart:ui';

import 'package:flutter/material.dart' show Colors, ColorScheme;

import 'assessment_model.dart';

class ThreeMonthReportModel {
  final String name;
  final String student;
  final String studentName;
  final String classroom;
  final String month;
  final int year;
  final String reportDate;
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
    required this.month,
    required this.year,
    required this.reportDate,
    required this.status,
    required this.teacher,
    this.reviewedBy,
    this.submittedOn,
    required this.creation,
    required this.modified,
    this.assessments = const [], // Default empty list
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
      month: json['month']?.toString() ?? '',
      year: json['year'] ?? 0,
      reportDate: json['report_date']?.toString() ?? '',
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
      'month': month,
      'year': year,
      'report_date': reportDate,
      'status': status,
      'teacher': teacher,
      'reviewed_by': reviewedBy,
      'submitted_on': submittedOn,
      'creation': creation,
      'modified': modified,
      'assessments': assessments.map((e) => e.toJson()).toList(),
    };
  }

  // Helper to get initials
  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Helper to get status text
  String get statusText {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Complete';
      case 'saved':
        return 'In Progress';
      case 'draft':
        return 'Not Started';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  // Helper to get status color
  Color getStatusColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green;
      case 'saved':
        return Colors.orange;
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
}
