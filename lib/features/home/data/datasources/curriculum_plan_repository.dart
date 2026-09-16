import '../../data/models/curriculum_plan_response_model.dart';

abstract class CurriculumPlanRepository {
  Future<CurriculumPlanResponseModel> getCurriculumPlans({
    int page = 1,
    int pageSize = 20,
  });
}
