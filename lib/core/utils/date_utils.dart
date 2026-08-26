class DateUtilsHelper {
  DateUtilsHelper._();

  /// Format date as: 26/08/2026
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Format date as: Aug 26, 2026
  static String formatDateLong(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format time as: 02:30 PM
  static String formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Format date and time.
  /// Example: Aug 26, 2026 • 02:30 PM
  static String formatDateTime(DateTime date) {
    return '${formatDateLong(date)} • ${formatTime(date)}';
  }

 
  /// Just now
  /// 5 minutes ago
  /// 2 hours ago
  /// Yesterday
  /// 3 days ago
  /// 2 months ago
  static String timeAgo(
    DateTime date, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final difference = currentTime.difference(date);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 10) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days days ago';
    }

    if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }

    final years = difference.inDays ~/ 365;
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  
  /// Today
  /// Yesterday
  /// Tomorrow
  /// Aug 26, 2026
  static String relativeDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == -1) {
      return 'Yesterday';
    }

    if (difference == 1) {
      return 'Tomorrow';
    }

    return formatDateLong(date);
  }

  /// Checks whether a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks whether a date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );

    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}