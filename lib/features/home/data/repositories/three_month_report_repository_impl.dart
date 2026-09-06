import 'package:little_heroes_mobile/features/home/domain/hello.dart';

import '../datasources/three_month_report_remote_data_source.dart';
import '../../domain/repositories/three_month_report_repository.dart';
import '../models/three_month_report_response_model.dart';

class ThreeMonthReportRepositoryImpl implements ThreeMonthReportRepository {
  final ThreeMonthReportRemoteDataSource remoteDataSource;

  ThreeMonthReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ThreeMonthReportResponseModel> getThreeMonthReports({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? month,
    int? year,
  }) {
    return remoteDataSource.getThreeMonthReports(
      page: page,
      pageSize: pageSize,
      student: student,
      month: month,
      year: year,
    );
  }
}
