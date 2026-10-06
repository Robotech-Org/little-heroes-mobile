import 'package:flutter/material.dart';

import '../../domain/entities/user_preferences.dart';

class NotificationsSection extends StatelessWidget {
  final UserPreferences prefs;
  final void Function(UserPreferences) onChange;

  const NotificationsSection({
    super.key,
    required this.prefs,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_ToggleItem>[
      if (prefs.isTeacher)
        _ToggleItem(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat Messages',
          subtitle: 'Messages from parents',
          value: prefs.notifyChat,
          key: 'notify_chat',
        ),
      if (prefs.isTeacher)
        _ToggleItem(
          icon: Icons.event_note_outlined,
          title: 'Leave Updates',
          subtitle: 'Approvals & rejections',
          value: prefs.notifyLeaveUpdates,
          key: 'notify_leave_updates',
        ),
      if (prefs.isTeacher)
        _ToggleItem(
          icon: Icons.assignment_outlined,
          title: 'Daily Report Reminders',
          subtitle: 'Unsubmitted reports',
          value: prefs.notifyDailyReports,
          key: 'notify_daily_reports',
        ),

      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.login_rounded,
          title: 'Attendance',
          subtitle: 'Check-in & check-out alerts',
          value: prefs.notifyAttendance,
          key: 'notify_attendance',
        ),
      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Daily Reports',
          subtitle: 'Meals, naps & activities',
          value: prefs.notifyDailyReports,
          key: 'notify_daily_reports',
        ),
      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.photo_camera_back_outlined,
          title: 'Moments',
          subtitle: 'Photos & milestones',
          value: prefs.notifyMoments,
          key: 'notify_moments',
        ),
      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat Messages',
          subtitle: 'Teachers & admin',
          value: prefs.notifyChat,
          key: 'notify_chat',
        ),
      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.receipt_long_outlined,
          title: 'Billing',
          subtitle: 'Invoices & receipts',
          value: prefs.notifyBilling,
          key: 'notify_billing',
        ),
      if (prefs.isParent)
        _ToggleItem(
          icon: Icons.sms_outlined,
          title: 'SMS Updates',
          subtitle: 'Also send via SMS',
          value: prefs.receiveSmsUpdates,
          key: 'receive_sms_updates',
        ),

      _ToggleItem(
        icon: Icons.campaign_outlined,
        title: 'Announcements',
        subtitle: 'School-wide bulletins',
        value: prefs.notifyAnnouncements,
        key: 'notify_announcements',
      ),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SwitchListTile.adaptive(
            value: item.value,
            onChanged: (v) => onChange(_applyToggle(prefs, item.key, v)),
            secondary: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.12),
              child: Icon(
                item.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item.subtitle),
          ),
        );
      }).toList(),
    );
  }

  UserPreferences _applyToggle(UserPreferences p, String key, bool v) {
    switch (key) {
      case 'notify_chat':
        return p.copyWith(notifyChat: v);
      case 'notify_daily_reports':
        return p.copyWith(notifyDailyReports: v);
      case 'notify_attendance':
        return p.copyWith(notifyAttendance: v);
      case 'notify_moments':
        return p.copyWith(notifyMoments: v);
      case 'notify_billing':
        return p.copyWith(notifyBilling: v);
      case 'notify_leave_updates':
        return p.copyWith(notifyLeaveUpdates: v);
      case 'notify_announcements':
        return p.copyWith(notifyAnnouncements: v);
      case 'receive_sms_updates':
        return p.copyWith(receiveSmsUpdates: v);
      default:
        return p;
    }
  }
}

class _ToggleItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final String key;
  const _ToggleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.key,
  });
}
