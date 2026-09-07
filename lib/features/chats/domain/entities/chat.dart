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

  factory Chat.fromParticipant(Map<String, dynamic> participant, String role) {
    return Chat(
      id: participant['name']?.toString() ?? '',
      personName: participant['full_name']?.toString() ?? '',
      role: role,
      lastMessage: 'Start a conversation',
      lastMessageTime: '',
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
