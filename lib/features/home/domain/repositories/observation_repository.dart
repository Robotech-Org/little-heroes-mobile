import '../../data/models/observation_model.dart';
import '../../data/models/observation_response_model.dart';

abstract class ObservationRepository {
  Future<ObservationResponseModel> getObservations({
    int page = 1,
    int pageSize = 20,
    String? student,
    String? startDate,
    String? endDate,
  });

  Future<ObservationModel> createObservation(Map<String, dynamic> data);

  Future<ObservationModel> getObservation(String observationId);

  Future<ObservationModel> updateObservation(
    String observationId,
    Map<String, dynamic> data,
  );

  Future<void> deleteObservation(String observationId);

  Future<String> uploadObservationFile({
    required String fileName,
    required String filePath,
  });
}
