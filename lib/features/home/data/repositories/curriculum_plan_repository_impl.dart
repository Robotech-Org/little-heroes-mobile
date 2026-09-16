import 'package:little_heroes_mobile/features/home/data/datasources/curriculum_plan_repository.dart';

import '../datasources/curriculum_plan_remote_data_source.dart';
import '../models/curriculum_plan_response_model.dart';

class CurriculumPlanRepositoryImpl implements CurriculumPlanRepository {
  final CurriculumPlanRemoteDataSource remoteDataSource;

  CurriculumPlanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CurriculumPlanResponseModel> getCurriculumPlans({
    int page = 1,
    int pageSize = 20,
  }) => remoteDataSource.getCurriculumPlans(page: page, pageSize: pageSize);
}
