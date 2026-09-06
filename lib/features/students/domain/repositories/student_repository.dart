import '../../data/models/student_response_model.dart';

abstract class StudentRepository {
  Future<StudentResponseModel> getStudents({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? search,
  });
}
