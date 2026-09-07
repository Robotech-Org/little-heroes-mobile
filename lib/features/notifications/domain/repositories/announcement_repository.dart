import '../../data/models/announcement_model.dart';
import '../../data/models/announcement_response_model.dart';

abstract class AnnouncementRepository {
  Future<AnnouncementResponseModel> getAnnouncements({
    int page = 1,
    int pageSize = 20,
  });

  Future<AnnouncementModel> getAnnouncement(String announcementName);

  Future<AnnouncementModel> updateAnnouncement({
    required String announcementName,
    required Map<String, dynamic> data,
  });
}
