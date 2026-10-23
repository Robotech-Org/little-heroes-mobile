import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //  ADDED for SystemNavigator.pop()
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/core/constants/app_colors.dart';

import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/widgets/little_heroes_loading.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chats_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/pages/home_page.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:little_heroes_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:little_heroes_mobile/features/students/presentation/pages/students_page.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/navigation_item.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // ═════════════════════════════════════════════════════════════
  // NAVIGATION ITEMS
  // ═════════════════════════════════════════════════════════════

  List<NavigationItem> _navigationItems(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return const [
          NavigationItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          NavigationItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
          ),
          NavigationItem(
            label: 'Students',
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
          ),
          NavigationItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

      case UserRole.parent:
        return const [
          NavigationItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          NavigationItem(
            label: 'Notifications',
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
          ),
          NavigationItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
          ),
          NavigationItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

      case UserRole.adviser:
        return const [
          NavigationItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          NavigationItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
          ),
          NavigationItem(
            label: 'Students',
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
          ),
          NavigationItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];
    }
  }

  // ═════════════════════════════════════════════════════════════
  // PAGES
  // ═════════════════════════════════════════════════════════════

  List<Widget> _pages(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return [
          HomePage(role: role),
          const ChatsPage(),
          const StudentsPage(),
          const SettingsPage(),
        ];

      case UserRole.parent:
        return [
          HomePage(role: role),
          const NotificationsPage(isFullPage: true),
          const ChatsPage(),
          const SettingsPage(),
        ];

      case UserRole.adviser:
        return [
          HomePage(role: role),
          const ChatsPage(),
          const StudentsPage(),
          const SettingsPage(),
        ];
    }
  }

  // ═════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═════════════════════════════════════════════════════════════

  void _onNavigationChanged(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ═════════════════════════════════════════════════════════════
  // EXIT CONFIRMATION DIALOG   ADDED
  // ═════════════════════════════════════════════════════════════

  // ═════════════════════════════════════════════════════════════
  // EXIT CONFIRMATION DIALOG (theme-aware)
  // ═════════════════════════════════════════════════════════════

  Future<bool> _showExitConfirmation() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Pull the theme INSIDE the dialog so it reacts to the
        // dialog's own context (safe if app theme ever changes).
        final dialogTheme = Theme.of(dialogContext);
        final dialogColors = dialogTheme.colorScheme;
        final dialogIsDark = dialogTheme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: dialogIsDark
              ? AppColors.darkCard
              : AppColors.lightCard,
          surfaceTintColor: Colors.transparent,
          icon: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: dialogColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.exit_to_app_rounded,
              color: dialogColors.error,
              size: 26,
            ),
          ),
          title: Text(
            'Exit App',
            textAlign: TextAlign.center,
            style: dialogTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: dialogIsDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to exit?',
            textAlign: TextAlign.center,
            style: dialogTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: dialogIsDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            // ── Cancel (outlined, subtle) ─────────────────
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: dialogIsDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                side: BorderSide(
                  color: dialogIsDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),

            // ── Exit (error-colored, prominent) ───────────
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.error,
                foregroundColor: dialogColors.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // ======================================================
        // UNAUTHENTICATED - Navigate to Login
        // ======================================================
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(AppRoutes.login);
            }
          });
        }
      },
      builder: (context, authState) {
        //
        // LOADING STATE
        //
        if (authState is AuthLoading || authState is AuthInitial) {
          return const Scaffold(
            body: LittleHeroesLoading(message: 'Loading your account...'),
          );
        }

        //
        // UNAUTHENTICATED - Show loading while redirecting
        //
        if (authState is AuthUnauthenticated) {
          return const Scaffold(
            body: LittleHeroesLoading(message: 'Redirecting to login...'),
          );
        }

        //
        // USER AUTHENTICATED
        //
        if (authState is AuthAuthenticated) {
          final role = authState.user.role;
          final items = _navigationItems(role);
          final pages = _pages(role);

          //
          // SAFETY CHECK
          //
          if (_currentIndex >= items.length) {
            _currentIndex = 0;
          }

          //
          // UI  — wrapped with PopScope
          //
          return PopScope(
            // Home tab (index 0) → allow default back (exits app)
            // Any other tab    → block pop so we can show the dialog
            canPop: _currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return; // Home tab: already popped normally

              // Non-home tab: confirm exit
              final shouldExit = await _showExitConfirmation();
              if (shouldExit && mounted) {
                SystemNavigator.pop(); // actually close the app
              }
            },
            child: Scaffold(
              body: IndexedStack(index: _currentIndex, children: pages),
              bottomNavigationBar: MainBottomNavigation(
                currentIndex: _currentIndex,
                items: items,
                onDestinationSelected: _onNavigationChanged,
              ),
            ),
          );
        }

        // Fallback
        return const Scaffold(body: LittleHeroesLoading(message: 'Loading...'));
      },
    );
  }
}
