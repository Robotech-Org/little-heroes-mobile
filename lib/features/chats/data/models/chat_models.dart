// lib/features/chats/data/models/chat_models.dart

// ============================================================
// CHANNEL MODEL (matches list_my_channels response)
// ============================================================
class ChatChannel {
  final String name;
  final String student;
  final String studentName;
  final String classroom;
  final String academicYear;
  final String ravenChannel;
  final String status;
  final String? lastMessagePreview;
  final String? lastMessageBy;
  final String? lastMessageAt;
  final String creation;

  ChatChannel({
    required this.name,
    required this.student,
    required this.studentName,
    required this.classroom,
    required this.academicYear,
    required this.ravenChannel,
    required this.status,
    this.lastMessagePreview,
    this.lastMessageBy,
    this.lastMessageAt,
    required this.creation,
  });

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      name: json['name'] ?? '',
      student: json['student'] ?? '',
      studentName: json['student_name'] ?? '',
      classroom: json['classroom'] ?? '',
      academicYear: json['academic_year'] ?? '',
      ravenChannel: json['raven_channel'] ?? '',
      status: json['status'] ?? '',
      lastMessagePreview: json['last_message_preview'],
      lastMessageBy: json['last_message_by'],
      lastMessageAt: json['last_message_at'],
      creation: json['creation'] ?? '',
    );
  }

  /// Parsed DateTime of last message
  DateTime? get lastMessageTime {
    if (lastMessageAt == null || lastMessageAt!.isEmpty) return null;
    try {
      return DateTime.parse(lastMessageAt!.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}

// ============================================================
// MESSAGE MODEL (matches get_channel_messages response)
// ============================================================
class ChatMessage {
  final String name;
  final String owner;
  final String text;
  final String messageType;
  final DateTime creation;
  final DateTime modified;
  final bool isEdited;
  final bool isReply;
  final MessageSendStatus sendStatus;

  ChatMessage({
    required this.name,
    required this.owner,
    required this.text,
    this.messageType = 'Text',
    required this.creation,
    required this.modified,
    this.isEdited = false,
    this.isReply = false,
    this.sendStatus = MessageSendStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      text: json['text'] ?? '',
      messageType: json['message_type'] ?? 'Text',
      creation: _parseDate(json['creation']),
      modified: _parseDate(json['modified'] ?? json['creation']),
      isEdited: json['is_edited'] == 1 || json['is_edited'] == true,
      isReply: json['is_reply'] == 1 || json['is_reply'] == true,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString().replaceFirst(' ', 'T'));
    } catch (_) {
      return DateTime.now();
    }
  }

  ChatMessage copyWith({String? name, MessageSendStatus? sendStatus}) {
    return ChatMessage(
      name: name ?? this.name,
      owner: owner,
      text: text,
      messageType: messageType,
      creation: creation,
      modified: modified,
      isEdited: isEdited,
      isReply: isReply,
      sendStatus: sendStatus ?? this.sendStatus,
    );
  }

  bool isMine(String currentUserEmail) => owner == currentUserEmail;
}

enum MessageSendStatus { sending, sent, failed }
