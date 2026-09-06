import '../datasources/daily_report_remote_data_source.dart';
import '../../domain/repositories/daily_report_repository.dart';
import '../models/daily_report_response_model.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final DailyReportRemoteDataSource remoteDataSource;

  DailyReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DailyReportResponseModel> getDailyReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  }) {
    return remoteDataSource.getDailyReports(
      page: page,
      pageSize: pageSize,
      student: student,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
