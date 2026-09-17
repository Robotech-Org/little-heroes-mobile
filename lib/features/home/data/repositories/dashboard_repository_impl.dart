import '../datasources/dashboard_remote_data_source.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_response_model.dart';

// class DashboardRepositoryImpl implements DashboardRepository {
//   final DashboardRemoteDataSource remoteDataSource;

//   DashboardRepositoryImpl({required this.remoteDataSource});

//   @override
//   Future<DashboardResponse> getDashboard() {
//     return remoteDataSource.getDashboard();
//   }
// }

import '../datasources/dashboard_remote_data_source.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_response_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardResponse> getDashboard({String? studentId}) {
    return remoteDataSource.getDashboard(studentId: studentId);
  }
}
