import '../../data/models/lesson_plan_model.dart';
import '../../data/models/lesson_plan_response_model.dart';

abstract class LessonPlanRepository {
  Future<LessonPlanResponseModel> getLessonPlans({
    int page = 1,
    int pageSize = 20,
  });

  Future<LessonPlanModel> getLessonPlan(String lessonPlanName);

  Future<LessonPlanModel> createLessonPlan(Map<String, dynamic> data);

  Future<LessonPlanModel> updateLessonPlan({
    required String lessonPlanName,
    required Map<String, dynamic> data,
  });
}
