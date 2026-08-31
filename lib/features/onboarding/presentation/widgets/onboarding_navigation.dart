
import 'package:flutter/material.dart';

class OnboardingNavigation extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onGetStarted;

  const OnboardingNavigation({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
    required this.onSkip,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == pageCount - 1;

    return Row(
      children: [
        if (!isLastPage)
          TextButton(
            onPressed: onSkip,
            child: const Text('Skip'),
          ),

        const Spacer(),

        ElevatedButton(
          onPressed:
              isLastPage ? onGetStarted : onNext,
          child: Text(
            isLastPage
                ? 'Get Started'
                : 'Next',
          ),
        ),
      ],
    );
  }
}
