import '../../data/models/arrived_student.dart';
import '../../data/models/punch_response.dart';
import '../../data/models/student_status.dart';

abstract class ClassroomAttendanceRepository {
  Future<List<ArrivedStudent>> listArrivedStudents({String? classroom});
  Future<List<StudentStatus>> todayStatus({String? classroom});

  Future<PunchResponse> punchIn({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });

  Future<PunchResponse> punchOut({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  });
}
