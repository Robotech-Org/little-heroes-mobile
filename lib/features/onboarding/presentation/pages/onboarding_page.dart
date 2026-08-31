import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_navigation.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage >= _pageCount - 1) {
      _goToLogin();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    _goToLogin();
  }

  void _goToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  OnboardingContent(
                    icon: Icons.child_care,
                    title: 'Welcome to Little Heroes',
                    description: 'A safe and friendly place designed to help you and your little heroes get started.',
                  ),

                  OnboardingContent(
                    icon: Icons.favorite_outline,
                    title: 'Everything in One Place',
                    description: 'Easily access the services, activities, and information you need for your little heroes.',
                  ),

                  OnboardingContent(
                    icon: Icons.verified_user_outlined,
                    title: 'Safe & Simple',
                    description: 'Create your account using your phone number and securely verify it with an OTP.',
                  ),
                ],
              ),
            ),

            OnboardingIndicator(
              currentPage: _currentPage,
              pageCount: _pageCount,
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OnboardingNavigation(
                currentPage: _currentPage,
                pageCount: _pageCount,
                onNext: _nextPage,
                onSkip: _skip,
                onGetStarted: _goToLogin,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
