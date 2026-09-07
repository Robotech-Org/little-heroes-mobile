import 'chat_participant_model.dart';

class ChatParticipantsResponseModel {
  final bool success;
  final List<ChatParticipantModel> items;
  final int total;
  final int page;
  final int pageSize;

  ChatParticipantsResponseModel({
    required this.success,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ChatParticipantsResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    final data = message['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];

    return ChatParticipantsResponseModel(
      success: message['success'] ?? false,
      items: itemsList
          .map((item) => ChatParticipantModel.fromJson(item))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 20,
    );
  }
}
