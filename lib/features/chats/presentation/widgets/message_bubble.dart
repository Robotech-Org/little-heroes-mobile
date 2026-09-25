import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/features/chats/data/models/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const MessageBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) _avatar(theme),
          if (!isMine) const SizedBox(width: 8),
          Flexible(child: _bubble(context, theme, colorScheme)),
        ],
      ),
    );
  }

  Widget _avatar(ThemeData theme) {
    final url = message.senderAvatar;
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: url != null && url.isNotEmpty
          ? NetworkImage(_absoluteUrl(url))
          : null,
      child: url == null || url.isEmpty
          ? Text(
              _initials(message.senderName),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }

  //  FIX: pass BuildContext as a proper parameter
  Widget _bubble(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: message.isImage
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Sender label (not mine) ─────────────────────
          if (!isMine) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.senderName.isNotEmpty
                      ? message.senderName
                      : message.owner,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                if (message.senderRoleLabel.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _roleChip(colorScheme, message.senderRoleLabel),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],

          // ── Image attachment ────────────────────────────
          if (message.isImage && message.file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _absoluteUrl(message.file!),
                width: 220,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, p) {
                  if (p == null) return child;
                  return SizedBox(
                    width: 220,
                    height: 160,
                    child: Center(
                      child: message.uploadProgress != null
                          ? CircularProgressIndicator(
                              value: message.uploadProgress,
                            )
                          : const CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 160,
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // ── File attachment chip ────────────────────────
          if (message.isFile && message.file != null)
            _fileChip(theme, colorScheme),

          // ── Text ────────────────────────────────────────
          if (message.text.isNotEmpty)
            Padding(
              padding: message.hasAttachment
                  ? const EdgeInsets.fromLTRB(10, 8, 10, 4)
                  : EdgeInsets.zero,
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMine ? Colors.white : colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),

          // ── Timestamp + status ──────────────────────────
          Padding(
            padding: message.isImage && message.text.isEmpty
                ? const EdgeInsets.fromLTRB(0, 6, 6, 6)
                : EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.creation.toLocal()),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white70
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(ColorScheme colorScheme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _fileChip(ThemeData theme, ColorScheme colorScheme) {
    final onColor = isMine ? Colors.white : colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMine
            ? Colors.white.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 18, color: onColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.fileName ?? 'Attachment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    switch (message.sendStatus) {
      case MessageSendStatus.sending:
        if (message.uploadProgress != null) {
          return SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              value: message.uploadProgress,
              strokeWidth: 1.6,
              color: Colors.white70,
            ),
          );
        }
        return const Icon(
          Icons.access_time_rounded,
          size: 12,
          color: Colors.white70,
        );
      case MessageSendStatus.failed:
        return const Icon(
          Icons.error_outline_rounded,
          size: 12,
          color: Colors.redAccent,
        );
      case MessageSendStatus.sent:
        return const Icon(Icons.check_rounded, size: 12, color: Colors.white70);
    }
  }

  String _absoluteUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}$path';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
