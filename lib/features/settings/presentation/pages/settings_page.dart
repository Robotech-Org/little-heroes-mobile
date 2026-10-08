import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/constants/app_colors.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/settings/domain/entities/user_preferences.dart';
import 'package:little_heroes_mobile/features/settings/domain/entities/user_profile.dart';

import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

import '../widgets/appearance_section.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/notifications_section.dart';
import '../widgets/privacy_section.dart';
import '../widgets/profile_card.dart';
import '../widgets/quiet_hours_section.dart';
import '../widgets/settings_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Tracks whether we're currently showing cached data because the
  /// network call failed. Cleared on any successful refresh.
  bool _isOffline = false;

  /// When we last successfully fetched from the network.
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsBloc>().add(const LoadPreferences());
    });
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : null,
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // AVATAR URL HELPER
  // ══════════════════════════════════════════════════

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final origin = Uri.parse(ApiConstants.baseUrl).origin;
    return '$origin$path';
  }

  // ══════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;
    context.read<AuthBloc>().add(LogoutRequested());
  }

  // ══════════════════════════════════════════════════
  // ROLE HELPERS
  // ══════════════════════════════════════════════════

  UserRole? _currentRole(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.role;
    }
    return null;
  }

  bool _isParent(BuildContext context) =>
      _currentRole(context) == UserRole.parent;

  bool _isTeacher(BuildContext context) =>
      _currentRole(context) == UserRole.teacher;

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          SnackbarUtils.showSuccess(context, 'Logged out successfully');
          context.go(AppRoutes.login);
        } else if (authState is AuthError) {
          SnackbarUtils.showError(context, authState.message);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          foregroundColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is PasswordChanged) {
              _showSnack(state.message);
            } else if (state is ProfileUpdated) {
              _showSnack(state.message);
              // Successful write → we're clearly online
              if (mounted && _isOffline) {
                setState(() => _isOffline = false);
              }
            } else if (state is SettingsSaved) {
              _showSnack(state.message);
              if (mounted && _isOffline) {
                setState(() => _isOffline = false);
              }
            } else if (state is SettingsError) {
              _showSnack(state.message, error: true);
            }
          },
          builder: (context, state) {
            // Auth loading (logout in progress) — show spinner
            final authState = context.watch<AuthBloc>().state;
            if (authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Loading
            if (state is SettingsLoading || state is SettingsInitial) {
              return const _SettingsSkeleton();
            }

            // Error — full-screen error only if we have NO cache
            if (state is SettingsError && state.message.isNotEmpty) {
              return _SettingsErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<SettingsBloc>().add(const LoadPreferences()),
              );
            }

            // Loaded
            if (state is SettingsLoaded) {
              // If the emitted state came from cache (bloc flag), keep
              // the offline indicator visible. We detect it here by
              // checking a "saved" flag we track locally.
              return _buildBody(
                state.prefs,
                state.profile,
                state.saving,
                isDark,
              );
            }

            if (state is SettingsSaved) {
              return _buildBody(state.prefs, null, false, isDark);
            }

            if (state is PasswordChanged || state is ProfileUpdated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<SettingsBloc>().add(const LoadPreferences());
                }
              });
              return const _SettingsSkeleton();
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════

  Widget _buildBody(
    UserPreferences prefs,
    UserProfile? profile,
    bool isSaving,
    bool isDark,
  ) {
    final isParent = _isParent(context);
    final isTeacher = _isTeacher(context);
    final userType = profile?.userType ?? prefs.userType;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<SettingsBloc>().add(const LoadPreferences());
          },
          child: Column(
            children: [
              // ══════════ OFFLINE BANNER ══════════
              if (_isOffline)
                _SettingsOfflineBanner(
                  cachedAt: _cachedAt,
                  onRetry: () =>
                      context.read<SettingsBloc>().add(const LoadPreferences()),
                ),

              // ══════════ MAIN LIST ══════════
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 60),
                  children: [
                    // ══════════ PROFILE ══════════
                    const SettingsHeader(title: 'PROFILE'),
                    ProfileCard(
                      userName: profile?.fullName ?? 'User',
                      userEmail: profile?.email ?? '—',
                      userImageUrl: _resolveImageUrl(profile?.userImage),
                      userType: userType,
                      onEdit: isParent
                          ? () => EditProfileSheet.show(context)
                          : null,
                    ),

                    // ══════════ SECURITY (parent only) ══════════
                    if (isParent) ...[
                      const SettingsHeader(title: 'SECURITY'),
                      _SecuritySection(
                        isDark: isDark,
                        biometricEnabled: prefs.biometricLoginEnabled,
                        onBiometricChanged: (v) {
                          context.read<SettingsBloc>().add(
                            TogglePreference(
                              prefs.copyWith(biometricLoginEnabled: v),
                            ),
                          );
                        },
                        onChangePassword: () =>
                            ChangePasswordDialog.show(context),
                      ),
                    ],

                    // ══════════ NOTIFICATIONS + QUIET HOURS ══════════
                    if (isParent || isTeacher) ...[
                      const SettingsHeader(title: 'NOTIFICATIONS'),
                      NotificationsSection(
                        prefs: prefs,
                        onChange: (updated) {
                          context.read<SettingsBloc>().add(
                            TogglePreference(updated),
                          );
                        },
                      ),

                      const SettingsHeader(title: 'QUIET HOURS'),
                      QuietHoursSection(
                        enabled: prefs.quietHoursEnabled,
                        start: prefs.quietHoursStart,
                        end: prefs.quietHoursEnd,
                        onChange: (enabled, start, end) {
                          context.read<SettingsBloc>().add(
                            TogglePreference(
                              prefs.copyWith(
                                quietHoursEnabled: enabled,
                                quietHoursStart: start,
                                quietHoursEnd: end,
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // ══════════ APPEARANCE ══════════
                    const SettingsHeader(title: 'APPEARANCE'),
                    AppearanceSection(isDark: isDark),

                    // ══════════ PRIVACY & TERMS ══════════
                    const SettingsHeader(title: 'PRIVACY & TERMS'),
                    PrivacySection(isDark: isDark),

                    // ══════════ LOGOUT ══════════
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Little Heroes • v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Saving indicator
        if (isSaving)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECURITY SECTION
// ═══════════════════════════════════════════════════════════

class _SecuritySection extends StatelessWidget {
  final bool isDark;
  final bool biometricEnabled;
  final ValueChanged<bool> onBiometricChanged;
  final VoidCallback onChangePassword;

  const _SecuritySection({
    required this.isDark,
    required this.biometricEnabled,
    required this.onBiometricChanged,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          // SwitchListTile.adaptive(
          //   value: biometricEnabled,
          //   onChanged: onBiometricChanged,
          //   contentPadding: const EdgeInsets.symmetric(
          //     horizontal: 16,
          //     vertical: 4,
          //   ),
          //   secondary: Container(
          //     width: 40,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: colorScheme.primary.withValues(alpha: 0.15),
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Icon(
          //       Icons.fingerprint_rounded,
          //       size: 20,
          //       color: colorScheme.primary,
          //     ),
          //   ),
          //   title: const Text(
          //     'Biometric Login',
          //     style: TextStyle(fontWeight: FontWeight.w600),
          //   ),
          //   subtitle: const Text('Face ID or Fingerprint'),
          // ),
          Divider(height: 1, indent: 72, color: dividerColor),
          ListTile(
            onTap: onChangePassword,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// OFFLINE BANNER
// ═══════════════════════════════════════════════════════════

class _SettingsOfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback onRetry;

  const _SettingsOfflineBanner({required this.cachedAt, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.orange.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cachedAt != null
                    ? 'Offline — showing cached settings'
                    : 'Offline — changes may not be saved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// LOADING SKELETON
// ═══════════════════════════════════════════════════════════

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < 6; i++) ...[
          Container(
            height: 24,
            width: 120,
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════

class _SettingsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SettingsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Could not load settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
