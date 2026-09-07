
import 'package:little_heroes_mobile/features/chats/data/models/chat_participant_model.dart';

class Chat {
  final String id;
  final String personName;
  final String role;
  final String lastMessage;
  final String lastMessageTime;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;

  Chat({
    required this.id,
    required this.personName,
    required this.role,
    this.lastMessage = '',
    this.lastMessageTime = '',
    this.avatarUrl = '',
    this.unreadCount = 0,
    this.isOnline = false,
  });

  // Create Chat from ChatParticipantModel (Recommended)
  factory Chat.fromParticipantModel(
    ChatParticipantModel participant,
    String role,
  ) {
    return Chat(
      id: participant.name,
      personName: participant.fullName,
      role: role,
      lastMessage: 'Start a conversation',
      lastMessageTime: '',
      avatarUrl: participant.initials,
      unreadCount: 0,
      isOnline: false,
    );
  }

  // Legacy: Create Chat from Map
  factory Chat.fromParticipant(Map<String, dynamic> participant, String role) {
    return Chat(
      id: participant['name']?.toString() ?? '',
      personName: participant['full_name']?.toString() ?? '',
      role: role,
      lastMessage: 'Start a conversation',
      lastMessageTime: '',
      avatarUrl: '',
      unreadCount: 0,
      isOnline: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'role': role,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'avatarUrl': avatarUrl,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }
}
