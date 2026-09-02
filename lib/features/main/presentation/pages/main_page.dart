import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/widgets/document_viewer/document_viewer_demo_page.dart';
import 'package:little_heroes_mobile/features/chats/presentation/pages/chat_page.dart';
import 'package:little_heroes_mobile/features/payments/presentation/pages/payment_page.dart';
import 'package:little_heroes_mobile/features/students/presentation/pages/students_page.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/user_role.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/navigation_item.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  final UserRole role;

  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late UserRole _role;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
  }

  // ============================================================
  // CHANGE ROLE
  // ============================================================

  void _changeRole(UserRole newRole) {
    if (_role == newRole) {
      return;
    }

    setState(() {
      _role = newRole;

      // Always return to Home when role changes.
      _currentIndex = 0;
    });
  }

  // ============================================================
  // NAVIGATION ITEMS
  // ============================================================

  List<NavigationItem> get _navigationItems {
    switch (_role) {
      // ========================================================
      // TEACHER
      // ========================================================

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

      // ========================================================
      // PARENT
      // ========================================================

      case UserRole.parent:
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
            label: 'Payment',
            icon: Icons.payment_outlined,
            activeIcon: Icons.payment_rounded,
          ),
          NavigationItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

      // ========================================================
      // ADVISOR
      // ========================================================

      case UserRole.advisor:
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

  // ============================================================
  // PAGES
  // ============================================================

  List<Widget> get _pages {
    switch (_role) {
      // ========================================================
      // TEACHER
      // ========================================================

      case UserRole.teacher:
        return [
          HomePage(role: _role),
          const ChatsPage(),
          const StudentsPage(),
          SettingsPage(role: _role, onRoleChanged: _changeRole),
        ];

      // ========================================================
      // PARENT
      // ========================================================

      case UserRole.parent:
        return [
          HomePage(role: _role),
          const ChatsPage(),

          // Payment instead of Students
          const PaymentPage(),

          SettingsPage(role: _role, onRoleChanged: _changeRole),
        ];

      // ========================================================
      // ADVISOR
      // ========================================================

      case UserRole.advisor:
        return [
          HomePage(role: _role),
          // const ChatsPage(),
          DocumentViewerDemoPage(),
          const StudentsPage(),
          SettingsPage(role: _role, onRoleChanged: _changeRole),
        ];
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationChanged(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final items = _navigationItems;
    final pages = _pages;

    if (_currentIndex >= items.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),

      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _currentIndex,
        items: items,
        onDestinationSelected: _onNavigationChanged,
      ),
    );
  }
}
