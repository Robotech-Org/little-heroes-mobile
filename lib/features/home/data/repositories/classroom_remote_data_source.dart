// lib/features/home/data/repositories/classroom_repository_impl.dart
import '../../domain/repositories/classroom_repository.dart';
import '../datasources/classroom_remote_data_source.dart';
import '../models/classroom_model.dart';
import '../models/classroom_response_model.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ClassroomRemoteDataSource remoteDataSource;

  ClassroomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ClassroomResponseModel> getClassrooms({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await remoteDataSource.getClassrooms(page: page, pageSize: pageSize);
  }

  @override
  Future<ClassroomModel> getClassroom(String classroomName) async {
    return await remoteDataSource.getClassroom(classroomName);
  }
}
