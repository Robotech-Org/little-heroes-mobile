import 'package:flutter/material.dart';

import '../../../data/models/daily_report_model.dart';

class DailyReportCard extends StatelessWidget {
  final DailyReportModel report;
  final VoidCallback? onTap;

  const DailyReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ── Normalize once; use for BOTH text and color ──────────
    final displayStatus = _displayStatus(report.dailyReportStatus);
    final statusColor = _getStatusColor(displayStatus, colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Student Name + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.studentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus, // ← was report.dailyReportStatus
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Classroom
              Row(
                children: [
                  Icon(
                    Icons.class_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.studentClassroom,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(report.reportDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Emoji Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildEmojiChip(context, '🥣', report.mealsAndSnacks),
                  _buildEmojiChip(context, '😴', report.napTime),
                  _buildEmojiChip(context, '🙂', report.moodAndBehavior),
                  if (report.healthAndHygiene.isNotEmpty)
                    _buildEmojiChip(context, '💚', report.healthAndHygiene),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// pending / Pending / PENDING → "Draft"
  /// everything else → original (trimmed)
  String _displayStatus(String status) {
    final trimmed = status.trim();
    if (trimmed.toLowerCase() == 'pending') return 'Draft';
    return trimmed;
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green;
      case 'saved':
        return colorScheme.primary;
      case 'draft':
      case 'pending': // safety net (usually already normalized to 'draft')
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  Widget _buildEmojiChip(BuildContext context, String emoji, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}
