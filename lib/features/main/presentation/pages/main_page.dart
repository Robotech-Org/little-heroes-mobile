import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/core/router/app_routes.dart';
import 'package:little_heroes_mobile/core/widgets/little_heroes_loading.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chat_detail_page.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chats_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/pages/home_page.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notifications_page.dart';
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

  // NAVIGATION ITEMS

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

  // PAGES

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

  // NAVIGATION

  void _onNavigationChanged(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // ======================================================
        // UNAUTHENTICATED - Navigate to Login
        // ======================================================
        if (state is AuthUnauthenticated) {
          // Use addPostFrameCallback to navigate after build
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
            // body: Center(child: CircularProgressIndicator()
            body: LittleHeroesLoading(message: 'Loading your account...'),
          );
        }

        //
        // UNAUTHENTICATED - Show loading while redirecting
        //

        if (authState is AuthUnauthenticated) {
          return const Scaffold(
            // body: Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       CircularProgressIndicator(),
            //       SizedBox(height: 16),
            //       Text('Redirecting to login...'),
            //     ],
            //   ),
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
          // UI
          //

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: pages),
            bottomNavigationBar: MainBottomNavigation(
              currentIndex: _currentIndex,
              items: items,
              onDestinationSelected: _onNavigationChanged,
            ),
          );
        }

        // Fallback
        return const Scaffold(
          // body: Center(child: CircularProgressIndicator()),
          // );

          body: LittleHeroesLoading(message: 'Loading...'),
        );
      },
    );
  }
}
