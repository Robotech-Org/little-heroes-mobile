import 'package:little_heroes_mobile/features/chats/data/models/chat_participants_response_model.dart';

import '../datasources/chat_remote_data_source.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatParticipantsResponseModel> getParents({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getParents(page: page, pageSize: pageSize);
  }

  @override
  Future<ChatParticipantsResponseModel> getTeachers({
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getTeachers(page: page, pageSize: pageSize);
  }
}
