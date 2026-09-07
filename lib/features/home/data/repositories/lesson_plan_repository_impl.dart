import '../datasources/lesson_plan_remote_data_source.dart';
import '../../domain/repositories/lesson_plan_repository.dart';
import '../models/lesson_plan_model.dart';
import '../models/lesson_plan_response_model.dart';

class LessonPlanRepositoryImpl implements LessonPlanRepository {
  final LessonPlanRemoteDataSource remoteDataSource;

  LessonPlanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LessonPlanResponseModel> getLessonPlans({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getLessonPlans(page: page, pageSize: pageSize);
  }

  @override
  Future<LessonPlanModel> getLessonPlan(String lessonPlanName) {
    return remoteDataSource.getLessonPlan(lessonPlanName);
  }

  @override
  Future<LessonPlanModel> createLessonPlan(Map<String, dynamic> data) {
    return remoteDataSource.createLessonPlan(data);
  }

  @override
  Future<LessonPlanModel> updateLessonPlan({
    required String lessonPlanName,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.updateLessonPlan(
      lessonPlanName: lessonPlanName,
      data: data,
    );
  }
}
