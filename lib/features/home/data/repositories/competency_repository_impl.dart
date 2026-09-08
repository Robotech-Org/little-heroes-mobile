import '../datasources/competency_remote_data_source.dart';
import '../../domain/repositories/competency_repository.dart';
import '../models/competency_model.dart';
import '../models/competency_response_model.dart';

class CompetencyRepositoryImpl implements CompetencyRepository {
  final CompetencyRemoteDataSource remoteDataSource;

  CompetencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CompetencyResponseModel> getCompetencies({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getCompetencies(page: page, pageSize: pageSize);
  }

  @override
  Future<CompetencyModel> getCompetency(String competencyName) {
    return remoteDataSource.getCompetency(competencyName);
  }
}
