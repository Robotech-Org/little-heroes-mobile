import '../datasources/observation_remote_data_source.dart';
import '../../domain/repositories/observation_repository.dart';
import '../models/observation_model.dart';
import '../models/observation_response_model.dart';

class ObservationRepositoryImpl implements ObservationRepository {
  final ObservationRemoteDataSource remoteDataSource;

  ObservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ObservationResponseModel> getObservations({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  }) {
    return remoteDataSource.getObservations(
      page: page,
      pageSize: pageSize,
      student: student,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<ObservationModel> createObservation(Map<String, dynamic> data) {
    return remoteDataSource.createObservation(data);
  }

  @override
  Future<ObservationModel> getObservation(String observationId) {
    return remoteDataSource.getObservation(observationId);
  }

  @override
  Future<ObservationModel> updateObservation(
    String observationId,
    Map<String, dynamic> data,
  ) {
    return remoteDataSource.updateObservation(observationId, data);
  }

  @override
  Future<void> deleteObservation(String observationId) {
    return remoteDataSource.deleteObservation(observationId);
  }

  @override
  Future<String> uploadObservationFile({
    required String fileName,
    required String filePath,
  }) {
    return remoteDataSource.uploadObservationFile(
      fileName: fileName,
      filePath: filePath,
    );
  }
}
