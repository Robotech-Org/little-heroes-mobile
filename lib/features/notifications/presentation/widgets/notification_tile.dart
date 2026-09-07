import 'package:flutter/material.dart';

import '../../data/models/announcement_model.dart';

class NotificationTile extends StatefulWidget {
  final AnnouncementModel announcement;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          widget.onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildIcon(context),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.announcement.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Body - Show preview when collapsed, full when expanded
                    if (_isExpanded)
                      Text(
                        widget.announcement.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      )
                    else
                      Text(
                        widget.announcement.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    // Time
                    Row(
                      children: [
                        Text(
                          _getTimeAgo(widget.announcement.postedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        if (_isExpanded &&
                            widget.announcement.classroom != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.announcement.classroom!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Read More/Less
                    if (_isExpanded) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Read Less',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine icon based on announcement content
    IconData iconData;
    Color iconColor;

    final title = widget.announcement.title.toLowerCase();
    final body = widget.announcement.body.toLowerCase();

    if (title.contains('photo') ||
        title.contains('gallery') ||
        title.contains('moment')) {
      iconData = Icons.photo_library_outlined;
      iconColor = Colors.purple.shade400;
    } else if (title.contains('announcement') ||
        title.contains('notice') ||
        title.contains('update')) {
      iconData = Icons.campaign_outlined;
      iconColor = Colors.orange.shade400;
    } else if (title.contains('report') ||
        title.contains('assessment') ||
        title.contains('evaluation')) {
      iconData = Icons.assessment_outlined;
      iconColor = Colors.blue.shade400;
    } else if (title.contains('event') ||
        title.contains('meeting') ||
        title.contains('orientation')) {
      iconData = Icons.event_available_outlined;
      iconColor = Colors.green.shade400;
    } else if (title.contains('holiday') ||
        title.contains('break') ||
        title.contains('closed')) {
      iconData = Icons.beach_access_outlined;
      iconColor = Colors.teal.shade400;
    } else {
      iconData = Icons.notifications_none_rounded;
      iconColor = colorScheme.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 22, color: iconColor),
    );
  }

  String _getTimeAgo(String dateTime) {
    try {
      // Parse the date string
      final parts = dateTime.split(' ');
      if (parts.isEmpty) return 'Just now';

      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return 'Just now';

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final timeParts = parts.length > 1
          ? parts[1].split(':')
          : ['00', '00', '00'];
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final date = DateTime(year, month, day, hour, minute);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  String _formatDate(String date) {
    try {
      final parts = date.split(' ');
      if (parts.isNotEmpty) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
        }
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}
