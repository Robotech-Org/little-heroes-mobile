
import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
          ),

          const SizedBox(height: 40),

          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),
        ],
      ),
    );
  }
}
