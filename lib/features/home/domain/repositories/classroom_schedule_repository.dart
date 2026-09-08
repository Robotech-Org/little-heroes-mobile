// lib/features/home/domain/repositories/classroom_schedule_repository.dart
import '../../data/models/classroom_schedule_model.dart';

abstract class ClassroomScheduleRepository {
  Future<ClassroomScheduleResponseModel> getClassroomSchedules({
    int page = 1,
    int pageSize = 20,
    String? classroom,
    String? dayOfWeek,
  });

  Future<ClassroomScheduleModel> getClassroomSchedule(String scheduleName);
}
