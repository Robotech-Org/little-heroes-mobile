import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<InformationSection> sections;

  const InformationPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // =====================================================
            // HEADER
            // =====================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(icon, size: 34, color: colors.primary),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final section = sections[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _InformationSectionWidget(section: section),
                  );
                }, childCount: sections.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// INFORMATION SECTION MODEL
// ================================================================

class InformationSection {
  final String heading;
  final String content;

  const InformationSection({required this.heading, required this.content});
}

// ================================================================
// INFORMATION SECTION WIDGET
// ================================================================

class _InformationSectionWidget extends StatelessWidget {
  final InformationSection section;

  const _InformationSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          section.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.65,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
