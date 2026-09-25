// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:little_heroes_mobile/core/utils/url_helper.dart';
// import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart'; // ← adjust path
// import 'package:little_heroes_mobile/features/chats/data/models/chat_models.dart';

// class MessageBubble extends StatelessWidget {
//   final ChatMessage message;
//   final bool isMine;

//   const MessageBubble({super.key, required this.message, required this.isMine});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment: isMine
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isMine) _avatar(theme),
//           if (!isMine) const SizedBox(width: 8),
//           Flexible(child: _bubble(context, theme, colorScheme)),
//         ],
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // AVATAR — uses AuthenticatedImage for cookie auth
//   // ═════════════════════════════════════════════════
//   Widget _avatar(ThemeData theme) {
//     final raw = message.senderAvatar;
//     final hasAvatar = raw != null && raw.trim().isNotEmpty;

//     if (!hasAvatar) {
//       return CircleAvatar(
//         radius: 16,
//         backgroundColor: theme.colorScheme.primaryContainer,
//         child: Text(
//           _initials(message.senderName),
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: theme.colorScheme.onPrimaryContainer,
//           ),
//         ),
//       );
//     }

//     return ClipOval(
//       child: AuthenticatedImage(
//         imageUrl: UrlHelper.resolve(raw),
//         width: 32,
//         height: 32,
//         fit: BoxFit.cover,
//         errorWidget: CircleAvatar(
//           radius: 16,
//           backgroundColor: theme.colorScheme.primaryContainer,
//           child: Text(
//             _initials(message.senderName),
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: theme.colorScheme.onPrimaryContainer,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // BUBBLE
//   // ═════════════════════════════════════════════════
//   Widget _bubble(
//     BuildContext context,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final showImage = message.hasImage && message.fullImageUrl.isNotEmpty;
//     final showFile =
//         message.isFileType && !showImage && message.fullFileUrl.isNotEmpty;
//     final isImageOnly = showImage && message.text.trim().isEmpty;

//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.72,
//       ),
//       padding: showImage
//           ? const EdgeInsets.all(4)
//           : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: isMine
//             ? colorScheme.primary
//             : colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(16),
//           topRight: const Radius.circular(16),
//           bottomLeft: Radius.circular(isMine ? 16 : 4),
//           bottomRight: Radius.circular(isMine ? 4 : 16),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: isMine
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Sender label (only for the other side) ──────
//           if (!isMine) ...[
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   message.senderName.isNotEmpty
//                       ? message.senderName
//                       : message.owner,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 if (message.senderRoleLabel.isNotEmpty) ...[
//                   const SizedBox(width: 6),
//                   _roleChip(colorScheme, message.senderRoleLabel),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 4),
//           ],

//           // ── IMAGE ───────────────────────────────────────
//           if (showImage) _imageAttachment(theme, colorScheme),

//           // ── FILE CHIP ───────────────────────────────────
//           if (showFile) _fileChip(theme, colorScheme),

//           // ── TEXT ────────────────────────────────────────
//           if (message.text.trim().isNotEmpty)
//             Padding(
//               padding: (showImage || showFile)
//                   ? const EdgeInsets.fromLTRB(10, 8, 10, 4)
//                   : EdgeInsets.zero,
//               child: Text(
//                 message.text,
//                 style: TextStyle(
//                   color: isMine ? Colors.white : colorScheme.onSurface,
//                   fontSize: 15,
//                 ),
//               ),
//             ),

//           // ── Timestamp + status ──────────────────────────
//           Padding(
//             padding: isImageOnly
//                 ? const EdgeInsets.fromLTRB(0, 6, 6, 6)
//                 : EdgeInsets.zero,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   DateFormat('HH:mm').format(message.creation.toLocal()),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: isMine
//                         ? Colors.white70
//                         : colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // IMAGE — uses AuthenticatedImage (cookie auth + cache)
//   // ═════════════════════════════════════════════════
//   Widget _imageAttachment(ThemeData theme, ColorScheme colorScheme) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: AuthenticatedImage(
//         imageUrl: message.fullImageUrl,
//         width: 220,
//         fit: BoxFit.cover,
//         placeholder: Container(
//           width: 220,
//           height: 160,
//           color: colorScheme.surfaceContainerHigh,
//           alignment: Alignment.center,
//           child: message.uploadProgress != null
//               ? CircularProgressIndicator(value: message.uploadProgress)
//               : const CircularProgressIndicator(),
//         ),
//         errorWidget: Container(
//           width: 220,
//           height: 160,
//           color: colorScheme.surfaceContainerHigh,
//           alignment: Alignment.center,
//           child: Icon(
//             Icons.broken_image_outlined,
//             color: colorScheme.onSurfaceVariant,
//           ),
//         ),
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // ROLE CHIP
//   // ═════════════════════════════════════════════════
//   Widget _roleChip(ColorScheme colorScheme, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//       decoration: BoxDecoration(
//         color: colorScheme.primary.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.w700,
//           color: colorScheme.primary,
//         ),
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // FILE CHIP
//   // ═════════════════════════════════════════════════
//   Widget _fileChip(ThemeData theme, ColorScheme colorScheme) {
//     final onColor = isMine ? Colors.white : colorScheme.onSurface;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: isMine
//             ? Colors.white.withValues(alpha: 0.15)
//             : colorScheme.surfaceContainerHigh,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.insert_drive_file_outlined, size: 18, color: onColor),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               message.fileName ?? 'Attachment',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: onColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═════════════════════════════════════════════════
//   // STATUS ICON
//   // ═════════════════════════════════════════════════
//   Widget _statusIcon() {
//     switch (message.sendStatus) {
//       case MessageSendStatus.sending:
//         if (message.uploadProgress != null) {
//           return SizedBox(
//             width: 12,
//             height: 12,
//             child: CircularProgressIndicator(
//               value: message.uploadProgress,
//               strokeWidth: 1.6,
//               color: Colors.white70,
//             ),
//           );
//         }
//         return const Icon(
//           Icons.access_time_rounded,
//           size: 12,
//           color: Colors.white70,
//         );
//       case MessageSendStatus.failed:
//         return const Icon(
//           Icons.error_outline_rounded,
//           size: 12,
//           color: Colors.redAccent,
//         );
//       case MessageSendStatus.sent:
//         return const Icon(Icons.check_rounded, size: 12, color: Colors.white70);
//     }
//   }

//   // ═════════════════════════════════════════════════
//   // INITIALS
//   // ═════════════════════════════════════════════════
//   String _initials(String name) {
//     final parts = name
//         .trim()
//         .split(RegExp(r'\s+'))
//         .where((p) => p.isNotEmpty)
//         .toList();
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import 'package:little_heroes_mobile/core/utils/url_helper.dart';
import 'package:little_heroes_mobile/core/widgets/authenticated_image.dart';
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

  // ═════════════════════════════════════════════════
  // AVATAR
  // ═════════════════════════════════════════════════
  Widget _avatar(ThemeData theme) {
    final raw = message.senderAvatar;
    final hasAvatar = raw != null && raw.trim().isNotEmpty;

    if (!hasAvatar) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          _initials(message.senderName),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return ClipOval(
      child: AuthenticatedImage(
        imageUrl: UrlHelper.resolve(raw),
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorWidget: CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            _initials(message.senderName),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════
  // BUBBLE
  // ═════════════════════════════════════════════════
  Widget _bubble(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final showImage = message.hasImage && message.fullImageUrl.isNotEmpty;
    final showFile =
        message.isFileType && !showImage && message.fullFileUrl.isNotEmpty;
    final isImageOnly = showImage && message.text.trim().isEmpty;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: showImage
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
          // ── Sender label ────────────────────────────────
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

          // ── IMAGE ───────────────────────────────────────
          if (showImage) _imageAttachment(theme, colorScheme),

          // ── FILE CHIP ───────────────────────────────────
          if (showFile) _fileChip(theme, colorScheme),

          // ── TEXT (now HTML-aware) ───────────────────────
          if (message.text.trim().isNotEmpty)
            Padding(
              padding: (showImage || showFile)
                  ? const EdgeInsets.fromLTRB(10, 8, 10, 4)
                  : EdgeInsets.zero,
              child: _buildRichText(colorScheme, isMine),
            ),

          // ── Timestamp + status ──────────────────────────
          Padding(
            padding: isImageOnly
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

  // ═════════════════════════════════════════════════
  // RICH TEXT (HTML-aware)
  // ═════════════════════════════════════════════════
  Widget _buildRichText(ColorScheme colorScheme, bool isMine) {
    final textColor = isMine ? Colors.white : colorScheme.onSurface;
    final linkColor = isMine ? Colors.white : colorScheme.primary;

    // Fast path: no HTML → use plain Text (avoids Html overhead)
    if (!_containsHtml(message.text)) {
      return Text(
        message.text,
        style: TextStyle(color: textColor, fontSize: 15),
      );
    }

    return Html(
      data: message.text,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: textColor,
          fontSize: FontSize(15),
          lineHeight: LineHeight(1.35),
        ),
        "b": Style(fontWeight: FontWeight.w700),
        "strong": Style(fontWeight: FontWeight.w700),
        "i": Style(fontStyle: FontStyle.italic),
        "em": Style(fontStyle: FontStyle.italic),
        "u": Style(textDecoration: TextDecoration.underline),
        "a": Style(color: linkColor, textDecoration: TextDecoration.underline),
        "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        "br": Style(),
      },
      onLinkTap: (url, attributes, element) {
        if (url == null || url.isEmpty) return;
        // If url_launcher is set up:
        // launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }

  /// Quick heuristic: does the text contain HTML-like tags?
  bool _containsHtml(String text) {
    return RegExp(r'<[a-zA-Z][^>]*>').hasMatch(text);
  }

  // ═════════════════════════════════════════════════
  // IMAGE
  // ═════════════════════════════════════════════════
  Widget _imageAttachment(ThemeData theme, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AuthenticatedImage(
        imageUrl: message.fullImageUrl,
        width: 220,
        fit: BoxFit.cover,
        placeholder: Container(
          width: 220,
          height: 160,
          color: colorScheme.surfaceContainerHigh,
          alignment: Alignment.center,
          child: message.uploadProgress != null
              ? CircularProgressIndicator(value: message.uploadProgress)
              : const CircularProgressIndicator(),
        ),
        errorWidget: Container(
          width: 220,
          height: 160,
          color: colorScheme.surfaceContainerHigh,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════
  // ROLE CHIP
  // ═════════════════════════════════════════════════
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

  // ═════════════════════════════════════════════════
  // FILE CHIP
  // ═════════════════════════════════════════════════
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

  // ═════════════════════════════════════════════════
  // STATUS ICON
  // ═════════════════════════════════════════════════
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

  // ═════════════════════════════════════════════════
  // INITIALS
  // ═════════════════════════════════════════════════
  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
