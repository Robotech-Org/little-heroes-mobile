import '../datasources/announcement_remote_data_source.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';
import '../models/announcement_response_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AnnouncementResponseModel> getAnnouncements({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getAnnouncements(page: page, pageSize: pageSize);
  }

  @override
  Future<AnnouncementModel> getAnnouncement(String announcementName) {
    return remoteDataSource.getAnnouncement(announcementName);
  }

  @override
  Future<AnnouncementModel> updateAnnouncement({
    required String announcementName,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.updateAnnouncement(
      announcementName: announcementName,
      data: data,
    );
  }
}
