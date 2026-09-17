import '../../data/models/dashboard_response_model.dart';

abstract class DashboardRepository {
  // Future<DashboardResponse> getDashboard();
  Future<DashboardResponse> getDashboard({String? studentId});
}
