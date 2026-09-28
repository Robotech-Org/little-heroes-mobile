import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_response_model.dart';

abstract class DashboardRemoteDataSource {
  /// If [studentId] is null/empty, fetch the parent's overall dashboard.
  /// Otherwise, fetch the dashboard scoped to that specific student.
  Future<DashboardResponse> getDashboard({String? studentId});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<DashboardResponse> getDashboard({String? studentId}) async {
    try {
      final endpoint = (studentId != null && studentId.isNotEmpty)
          ? ApiConstants.dashboardForStudent(studentId)
          : ApiConstants.dashboard;

      print('📊 [Dashboard] GET $endpoint');

      final response = await dio.get(endpoint);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] ?? {};
        final responseData = message['data'] ?? {};

        if (responseData.isEmpty ||
            (responseData is Map && responseData.isEmpty) ||
            (responseData is List && responseData.isEmpty)) {
          print('📊 Dashboard data is empty, returning mock data');
          return _getMockDashboard();
        }

        return DashboardResponse.fromJson(data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      print('❌ Dashboard API error: ${e.message}');
      return _getMockDashboard();
    } catch (e) {
      print('❌ Dashboard error: $e');
      return _getMockDashboard();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MOCK
  // ─────────────────────────────────────────────────────────────
  DashboardResponse _getMockDashboard() {
    // Your existing mocks unchanged
    return _getMockTeacherDashboard();
  }

  DashboardResponse _getMockTeacherDashboard() {
    final mockData = {
      'message': {
        'success': true,
        'data': {
          'teacher': {
            'name': 'Demo Teacher',
            'first_name': 'Demo',
            'greeting': 'Good afternoon',
            'greeting_line': 'Good afternoon, Demo',
          },
          'theme': {
            'title': 'All About Me & My World',
            'goal': 'Exploring self-discovery and community',
          },
          'dashboard': {
            'daily_report': {
              'label': 'Daily Report',
              'reports_logged': 3,
              'total_students': 5,
              'summary': '3 of 5 logged',
              'pending_badge': null,
            },
            'three_month_report': {
              'label': '3 Month Report',
              'frameworks_count': 8,
              'summary': '8 frameworks assessment',
            },
            'weekly_planner': {
              'label': 'Weekly Planner',
              'pending_review': 2,
              'summary': '2 pending review',
            },
            'observation': {
              'label': 'Observation',
              'summary': 'Schedule-linked notes',
            },
            'add_a_moment': {
              'label': 'Add a Moment',
              'summary': 'Share with parents',
            },
          },
        },
      },
    };

    return DashboardResponse.fromJson(mockData);
  }

  DashboardResponse _getMockParentDashboard() {
    final mockData = {
      'message': {
        'success': true,
        'data': {
          'parent': {
            'id': 'mock_parent_001',
            'name': 'Demo Parent',
            'family_name': "Demo's Family",
          },
          'theme': {
            'title': 'All About Me & My World',
            'summary': 'Your child\'s daily report is ready to view.',
          },
          'children': [
            {
              'id': 'mock_child_001',
              'name': 'Child Name',
              'first_name': 'Child',
              'last_name': 'Name',
              'initials': 'CN',
              'age': 'Age 5',
              'classroom': 'Class A',
              'status': 'Report Ready',
            },
            {
              'id': 'mock_child_002',
              'name': 'Second Child',
              'first_name': 'Second',
              'last_name': 'Child',
              'initials': 'SC',
              'age': 'Age 3',
              'classroom': 'Class B',
              'status': 'In Progress',
            },
          ],
          'quick_access': {
            'daily_report': {
              'label': 'Daily Report',
              'last_updated': 'Just now',
            },
            'three_month_report': {
              'label': '3 Month Report',
              'last_updated': '2 hours ago',
            },
            'photo_gallery': {'label': 'Photo Gallery', 'new_count': 3},
            'billing_and_payment': {'label': 'Billing & Payment'},
          },
        },
      },
    };

    return DashboardResponse.fromJson(mockData);
  }
}
