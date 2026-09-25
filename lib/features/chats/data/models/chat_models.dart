// ============================================================
// SENDER MODEL (matches nested `sender` object)
// ============================================================
class MessageSender {
  final String id;
  final String name;
  final String role; // "parent" | "teacher" | "admin"
  final String roleLabel; // "Parent (Mother)", "Teacher", etc.
  final String? avatarUrl;
  final String docname;
  final bool isMe;

  const MessageSender({
    required this.id,
    required this.name,
    required this.role,
    required this.roleLabel,
    this.avatarUrl,
    this.docname = '',
    this.isMe = false,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      roleLabel: json['role_label'] ?? '',
      avatarUrl: json['avatar_url'],
      docname: json['docname'] ?? '',
      isMe: json['is_me'] == true || json['is_me'] == 1,
    );
  }

  /// Fallback when backend doesn't return a nested sender object
  factory MessageSender.fromLegacy({
    required String owner,
    required bool isMe,
  }) {
    return MessageSender(
      id: owner,
      name: owner.split('@').first,
      role: '',
      roleLabel: '',
      isMe: isMe,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isParent => role == 'parent';
}

// ============================================================
// MESSAGE ATTACHMENT (optional convenience wrapper)
// ============================================================
enum MessageType { text, image, file }

MessageType messageTypeFromString(String? raw) {
  switch ((raw ?? 'Text').toLowerCase()) {
    case 'image':
      return MessageType.image;
    case 'file':
      return MessageType.file;
    default:
      return MessageType.text;
  }
}

class ChatChannel {
  final String name;
  final String? student;
  final String? studentName;
  final String? classroom;
  final String? academicYear;
  final String ravenChannel;
  final String? status;
  final String? lastMessagePreview;
  final String? lastMessageBy;
  final String? lastMessageAt;
  final String? creation;
  final String? channelType;
  final bool? isAdminChannel;
  final bool? isPinned;
  final String? title;
  final String? subtitle;
  final String? avatarUrl;
  final String? parentsDisplay;
  final String? teachersDisplay;

  ChatChannel({
    required this.name,
    this.student,
    this.studentName,
    this.classroom,
    this.academicYear,
    required this.ravenChannel,
    this.status,
    this.lastMessagePreview,
    this.lastMessageBy,
    this.lastMessageAt,
    this.creation,
    this.channelType,
    this.isAdminChannel,
    this.isPinned,
    this.title,
    this.subtitle,
    this.avatarUrl,
    this.parentsDisplay,
    this.teachersDisplay,
  });

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      name: json['name'] ?? '',
      student: json['student'],
      studentName: json['student_name'],
      classroom: json['classroom'],
      academicYear: json['academic_year'],
      ravenChannel: json['raven_channel'] ?? '',
      status: json['status'],
      lastMessagePreview: json['last_message_preview'],
      lastMessageBy: json['last_message_by'],
      lastMessageAt: json['last_message_at'],
      creation: json['creation'],
      channelType: json['channel_type'],
      isAdminChannel: json['is_admin_channel'],
      isPinned: json['is_pinned'],
      title: json['title'],
      subtitle: json['subtitle'],
      avatarUrl: json['avatar_url'],
      parentsDisplay: json['parents_display'],
      teachersDisplay: json['teachers_display'],
    );
  }

  DateTime? get lastMessageTime {
    final raw = lastMessageAt;
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  DateTime? get creationTime {
    final raw = creation;
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  bool get isAdmin => isAdminChannel == true || channelType == 'Admin Support';

  /// Display name: student name → title → fallback
  String get displayTitle {
    final s = studentName?.trim();
    if (s != null && s.isNotEmpty) return s;
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Chat';
  }

  /// Display subtitle: preview → classroom → subtitle → ''
  String get displaySubtitle {
    final p = lastMessagePreview?.trim();
    if (p != null && p.isNotEmpty) return p;
    final c = classroom?.trim();
    if (c != null && c.isNotEmpty) return c;
    final s = subtitle?.trim();
    if (s != null && s.isNotEmpty) return s;
    return '';
  }
}

// ============================================================
// MESSAGE MODEL (updated with identity + attachments)
// ============================================================
class ChatMessage {
  final String name;
  final String channelId;
  final String owner;

  // ── Identity (new) ────────────────────────────────────────
  final String senderName;
  final String senderRole;
  final String senderRoleLabel;
  final String? senderAvatar;
  final bool isMe;
  final bool isAdmin;
  final MessageSender sender;

  // ── Content ───────────────────────────────────────────────
  final String text;
  final String messageType; // "Text" | "Image" | "File"
  final String? file; // "/files/clearance.pdf"
  final String? fileName; // "clearance.pdf"
  final int? fileSize;
  final int? imageWidth;
  final int? imageHeight;

  final DateTime creation;
  final DateTime modified;
  final bool isEdited;
  final bool isReply;

  // ── Client-only ───────────────────────────────────────────
  final MessageSendStatus sendStatus;
  final double? uploadProgress; // 0.0 → 1.0 when uploading

  ChatMessage({
    required this.name,
    required this.channelId,
    required this.owner,
    required this.senderName,
    required this.senderRole,
    required this.senderRoleLabel,
    this.senderAvatar,
    required this.isMe,
    required this.isAdmin,
    required this.sender,
    required this.text,
    this.messageType = 'Text',
    this.file,
    this.fileName,
    this.fileSize,
    this.imageWidth,
    this.imageHeight,
    required this.creation,
    required this.modified,
    this.isEdited = false,
    this.isReply = false,
    this.sendStatus = MessageSendStatus.sent,
    this.uploadProgress,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'];
    final owner = json['owner'] ?? '';
    final isMe = json['is_me'] == true || json['is_me'] == 1;

    final sender = senderJson is Map
        ? MessageSender.fromJson(Map<String, dynamic>.from(senderJson))
        : MessageSender.fromLegacy(owner: owner, isMe: isMe);

    return ChatMessage(
      name: json['name'] ?? '',
      channelId: json['channel_id'] ?? '',
      owner: owner,
      senderName: json['sender_name'] ?? sender.name,
      senderRole: json['sender_role'] ?? sender.role,
      senderRoleLabel: json['sender_role_label'] ?? sender.roleLabel,
      senderAvatar: json['sender_avatar'] ?? sender.avatarUrl,
      isMe: isMe,
      isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
      sender: sender,
      text: json['text'] ?? '',
      messageType: json['message_type'] ?? 'Text',
      file: json['file'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      imageWidth: json['image_width'],
      imageHeight: json['image_height'],
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

  // ── Convenience getters ───────────────────────────────────
  MessageType get type => messageTypeFromString(messageType);
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
  bool get hasAttachment => file != null && file!.isNotEmpty;

  bool get isUploading => sendStatus == MessageSendStatus.sending;
  bool get isFailed => sendStatus == MessageSendStatus.failed;

  /// True if this message was sent by the current user.
  /// Prefer `isMe` from the API; fallback to owner comparison.
  bool isMine(String currentUserEmail) => isMe || owner == currentUserEmail;

  ChatMessage copyWith({
    String? name,
    String? channelId,
    String? text,
    String? messageType,
    String? file,
    String? fileName,
    MessageSendStatus? sendStatus,
    double? uploadProgress,
  }) {
    return ChatMessage(
      name: name ?? this.name,
      channelId: channelId ?? this.channelId,
      owner: owner,
      senderName: senderName,
      senderRole: senderRole,
      senderRoleLabel: senderRoleLabel,
      senderAvatar: senderAvatar,
      isMe: isMe,
      isAdmin: isAdmin,
      sender: sender,
      text: text ?? this.text,
      messageType: messageType ?? this.messageType,
      file: file ?? this.file,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      creation: creation,
      modified: modified,
      isEdited: isEdited,
      isReply: isReply,
      sendStatus: sendStatus ?? this.sendStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

enum MessageSendStatus { sending, sent, failed }

// ============================================================
// UPLOAD RESULT (from upload_attachment endpoint)
// ============================================================
class AttachmentUploadResult {
  final String fileUrl;
  final String fileName;
  final String messageType;
  final int? fileSize;
  final int? imageWidth;
  final int? imageHeight;

  const AttachmentUploadResult({
    required this.fileUrl,
    required this.fileName,
    required this.messageType,
    this.fileSize,
    this.imageWidth,
    this.imageHeight,
  });

  factory AttachmentUploadResult.fromJson(Map<String, dynamic> json) {
    return AttachmentUploadResult(
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      messageType: json['message_type'] ?? 'File',
      fileSize: json['file_size'],
      imageWidth: json['image_width'],
      imageHeight: json['image_height'],
    );
  }
}
