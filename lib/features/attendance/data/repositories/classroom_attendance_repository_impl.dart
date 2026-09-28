import '../../domain/repositories/classroom_attendance_repository.dart';
import '../datasources/classroom_attendance_datasource.dart';
import '../models/arrived_student.dart';
import '../models/punch_response.dart';
import '../models/student_status.dart';

class ClassroomAttendanceRepositoryImpl
    implements ClassroomAttendanceRepository {
  final ClassroomAttendanceDataSource remote;

  ClassroomAttendanceRepositoryImpl({required this.remote});

  @override
  Future<List<ArrivedStudent>> listArrivedStudents({String? classroom}) =>
      remote.listArrivedStudents(classroom: classroom);

  @override
  Future<List<StudentStatus>> todayStatus({String? classroom}) =>
      remote.todayStatus(classroom: classroom);

  @override
  Future<PunchResponse> punchIn({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => remote.punchIn(
    studentIds: studentIds,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
  );

  @override
  Future<PunchResponse> punchOut({
    required List<String> studentIds,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) => remote.punchOut(
    studentIds: studentIds,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
  );
}
