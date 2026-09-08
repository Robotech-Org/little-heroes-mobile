// lib/features/home/data/repositories/classroom_schedule_repository_impl.dart
import 'package:little_heroes_mobile/features/home/data/models/classroom_schedule_remote_data_source.dart';

import '../../domain/repositories/classroom_schedule_repository.dart';
import '../models/classroom_schedule_model.dart';

class ClassroomScheduleRepositoryImpl implements ClassroomScheduleRepository {
  final ClassroomScheduleRemoteDataSource remoteDataSource;

  ClassroomScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ClassroomScheduleResponseModel> getClassroomSchedules({
    int page = 1,
    int pageSize = 20,
    String? classroom,
    String? dayOfWeek,
  }) async {
    return await remoteDataSource.getClassroomSchedules(
      page: page,
      pageSize: pageSize,
      classroom: classroom,
      dayOfWeek: dayOfWeek,
    );
  }

  @override
  Future<ClassroomScheduleModel> getClassroomSchedule(
    String scheduleName,
  ) async {
    return await remoteDataSource.getClassroomSchedule(scheduleName);
  }
}
