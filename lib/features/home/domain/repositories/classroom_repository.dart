// lib/features/home/domain/repositories/classroom_repository.dart
import '../../data/models/classroom_model.dart';
import '../../data/models/classroom_response_model.dart';

abstract class ClassroomRepository {
  Future<ClassroomResponseModel> getClassrooms({
    int page = 1,
    int pageSize = 20,
  });

  Future<ClassroomModel> getClassroom(String classroomName);
}
