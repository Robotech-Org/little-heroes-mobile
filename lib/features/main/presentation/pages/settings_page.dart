import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../widgets/account_settings_section.dart';
import '../widgets/appearance_settings.dart';
import '../widgets/notification_settings_section.dart';
import '../widgets/privacy_terms_section.dart';
import '../widgets/settings_role_tile.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // PARENT NOTIFICATIONS

  bool _dailyReportEnabled = true;
  bool _newPhotosEnabled = true;
  bool _messagesEnabled = true;
  bool _billingRemindersEnabled = true;

  // TEACHER / ADVISER NOTIFICATIONS

  bool _studentUpdatesEnabled = true;
  bool _reportRemindersEnabled = true;
  bool _systemAnnouncementsEnabled = true;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Use BlocConsumer to listen for state changes
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // ======================================================
        // UNAUTHENTICATED - Navigate to Login
        // ======================================================
        if (state is AuthUnauthenticated) {
          // Show success message
          SnackbarUtils.showSuccess(context, 'Logged out successfully');

          // Navigate to login page
          context.go(AppRoutes.login);
        }

        // ======================================================
        // ERROR
        // ======================================================
        if (state is AuthError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      builder: (context, authState) {
        final authUser = authState is AuthAuthenticated ? authState.user : null;
        final role = authUser?.role;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),

          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),

            children: [
              //
              // ACCOUNT
              //

              AccountSettingsSection(
                role: role,
                phoneNumber: authUser?.phoneNumber,

                onProfileTap: () {
                  // TODO: Navigate to Profile
                },

                onContactTap: () {
                  // TODO: Navigate to Contact Details
                },

                onLinkedChildrenTap: () {
                  // TODO: Navigate to Linked Children
                },

                onSecurityTap: () {
                  // TODO: Navigate to Security
                },
              ),

              const SizedBox(height: 28),

              //
              // ROLE BASED NOTIFICATIONS
              //
              if (role != null)
                NotificationSettingsSection(
                  role: role,

                  dailyReportEnabled: _dailyReportEnabled,
                  newPhotosEnabled: _newPhotosEnabled,
                  messagesEnabled: _messagesEnabled,
                  billingRemindersEnabled: _billingRemindersEnabled,

                  studentUpdatesEnabled: _studentUpdatesEnabled,
                  reportRemindersEnabled: _reportRemindersEnabled,
                  systemAnnouncementsEnabled: _systemAnnouncementsEnabled,

                  onDailyReportChanged: (value) {
                    setState(() {
                      _dailyReportEnabled = value;
                    });
                  },

                  onNewPhotosChanged: (value) {
                    setState(() {
                      _newPhotosEnabled = value;
                    });
                  },

                  onMessagesChanged: (value) {
                    setState(() {
                      _messagesEnabled = value;
                    });
                  },

                  onBillingChanged: (value) {
                    setState(() {
                      _billingRemindersEnabled = value;
                    });
                  },

                  onStudentUpdatesChanged: (value) {
                    setState(() {
                      _studentUpdatesEnabled = value;
                    });
                  },

                  onReportRemindersChanged: (value) {
                    setState(() {
                      _reportRemindersEnabled = value;
                    });
                  },

                  onSystemAnnouncementsChanged: (value) {
                    setState(() {
                      _systemAnnouncementsEnabled = value;
                    });
                  },
                ),

              const SizedBox(height: 28),

              //
              // APPEARANCE
              //
              const AppearanceSettings(),

              // const SizedBox(height: 28),

              //
              // ACCOUNT ROLE
              //
              // if (role != null)
              //   SettingsSection(
              //     title: 'Account Role',
              //     child: SettingsRoleTile(role: role, onChange: () {}),
              //   ),
              const SizedBox(height: 28),

              //
              // PRIVACY & TERMS
              //
              const PrivacyTermsSection(),

              const SizedBox(height: 32),

              //
              // LOGOUT
              //
              OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },

                icon: const Icon(Icons.logout_rounded),

                label: const Text('Logout'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error.withValues(alpha: 0.7)),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                // Trigger logout
                context.read<AuthBloc>().add(LogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
