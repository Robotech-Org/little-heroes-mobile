class Chat {
  final String id;
  final String personName;
  final String initials;
  final String role;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const Chat({
    required this.id,
    required this.personName,
    required this.initials,
    required this.role,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });
}
