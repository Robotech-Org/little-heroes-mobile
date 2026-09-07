import 'package:little_heroes_mobile/features/chats/data/models/chat_participants_response_model.dart';


abstract class ChatRepository {
  Future<ChatParticipantsResponseModel> getParents({
    int page = 1,
    int pageSize = 20,
  });

  Future<ChatParticipantsResponseModel> getTeachers({
    int page = 1,
    int pageSize = 20,
  });
}
