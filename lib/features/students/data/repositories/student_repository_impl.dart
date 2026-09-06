import '../datasources/student_remote_data_source.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_response_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StudentResponseModel> getStudents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? search,
  }) {
    return remoteDataSource.getStudents(
      page: page,
      pageSize: pageSize,
      status: status,
      search: search,
    );
  }
}
