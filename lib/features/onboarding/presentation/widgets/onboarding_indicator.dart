
import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) {
          final isActive = index == currentPage;

          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                  : Theme.of(context)
                      .colorScheme
                      .outline,
            ),
          );
        },
      ),
    );
  }
}
