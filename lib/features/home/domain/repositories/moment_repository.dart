import 'package:little_heroes_mobile/features/home/data/models/moment_response_model.dart';

import '../../data/models/moment_model.dart';

abstract class MomentRepository {
  Future<MomentResponseModel> getMoments({
    int page = 1,
    int pageSize = 20,
    Map<String, String>? filters,
  });

  Future<MomentModel> getMoment(String momentName);

  Future<MomentModel> createMoment(Map<String, dynamic> data);

  Future<MomentModel> updateMoment({
    required String momentName,
    required Map<String, dynamic> data,
  });

  Future<void> deleteMoment(String momentName);

  Future<void> approveMoment(String momentName);

  Future<void> denyMoment(String momentName);

  Future<String> uploadMomentFile({
    required String fileName,
    required String filePath,
  });
}
