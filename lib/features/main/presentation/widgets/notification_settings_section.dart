import 'package:flutter/material.dart';

import '../../../../core/constants/user_role.dart';

import 'notification_switch_tile.dart';
import 'settings_section.dart';

class NotificationSettingsSection extends StatelessWidget {
  final UserRole role;

  final bool dailyReportEnabled;
  final bool newPhotosEnabled;
  final bool messagesEnabled;
  final bool billingRemindersEnabled;

  final bool studentUpdatesEnabled;
  final bool reportRemindersEnabled;
  final bool systemAnnouncementsEnabled;

  final ValueChanged<bool> onDailyReportChanged;
  final ValueChanged<bool> onNewPhotosChanged;
  final ValueChanged<bool> onMessagesChanged;
  final ValueChanged<bool> onBillingChanged;

  final ValueChanged<bool> onStudentUpdatesChanged;
  final ValueChanged<bool> onReportRemindersChanged;
  final ValueChanged<bool> onSystemAnnouncementsChanged;

  const NotificationSettingsSection({
    super.key,
    required this.role,

    required this.dailyReportEnabled,
    required this.newPhotosEnabled,
    required this.messagesEnabled,
    required this.billingRemindersEnabled,

    required this.studentUpdatesEnabled,
    required this.reportRemindersEnabled,
    required this.systemAnnouncementsEnabled,

    required this.onDailyReportChanged,
    required this.onNewPhotosChanged,
    required this.onMessagesChanged,
    required this.onBillingChanged,

    required this.onStudentUpdatesChanged,
    required this.onReportRemindersChanged,
    required this.onSystemAnnouncementsChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      // ==========================================================
      // PARENT
      // ==========================================================

      case UserRole.parent:
        return SettingsSection(
          title: 'Notifications',
          child: Column(
            children: [
              NotificationSwitchTile(
                icon: Icons.description_outlined,
                title: 'Daily Report Ready',
                value: dailyReportEnabled,
                onChanged: onDailyReportChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.photo_library_outlined,
                title: 'New Photos',
                value: newPhotosEnabled,
                onChanged: onNewPhotosChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Messages',
                value: messagesEnabled,
                onChanged: onMessagesChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.payment_outlined,
                title: 'Billing Reminders',
                value: billingRemindersEnabled,
                onChanged: onBillingChanged,
                showDivider: false,
              ),
            ],
          ),
        );

      // ==========================================================
      // TEACHER
      // ==========================================================

      case UserRole.teacher:
        return SettingsSection(
          title: 'Notifications',
          child: Column(
            children: [
              NotificationSwitchTile(
                icon: Icons.people_outline_rounded,
                title: 'Student Updates',
                value: studentUpdatesEnabled,
                onChanged: onStudentUpdatesChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.edit_note_rounded,
                title: 'Report Reminders',
                value: reportRemindersEnabled,
                onChanged: onReportRemindersChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Messages',
                value: messagesEnabled,
                onChanged: onMessagesChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.campaign_outlined,
                title: 'School Announcements',
                value: systemAnnouncementsEnabled,
                onChanged: onSystemAnnouncementsChanged,
                showDivider: false,
              ),
            ],
          ),
        );

      // ==========================================================
      // ADVISER
      // ==========================================================

      case UserRole.adviser:
        return SettingsSection(
          title: 'Notifications',
          child: Column(
            children: [
              NotificationSwitchTile(
                icon: Icons.people_outline_rounded,
                title: 'Student Updates',
                value: studentUpdatesEnabled,
                onChanged: onStudentUpdatesChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.description_outlined,
                title: 'Report Updates',
                value: reportRemindersEnabled,
                onChanged: onReportRemindersChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Messages',
                value: messagesEnabled,
                onChanged: onMessagesChanged,
              ),

              NotificationSwitchTile(
                icon: Icons.campaign_outlined,
                title: 'System Announcements',
                value: systemAnnouncementsEnabled,
                onChanged: onSystemAnnouncementsChanged,
                showDivider: false,
              ),
            ],
          ),
        );
    }
  }
}
