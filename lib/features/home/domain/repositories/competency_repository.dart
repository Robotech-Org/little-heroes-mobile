import '../../data/models/competency_model.dart';
import '../../data/models/competency_response_model.dart';

abstract class CompetencyRepository {
  Future<CompetencyResponseModel> getCompetencies({
    int page = 1,
    int pageSize = 20,
  });

  Future<CompetencyModel> getCompetency(String competencyName);
}
