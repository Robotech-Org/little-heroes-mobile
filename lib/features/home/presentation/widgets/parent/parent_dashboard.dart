import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // WEEKLY THEME
        // ============================================================

        const _WeeklyThemeCard(),

        const SizedBox(height: 24),

        // ============================================================
        // CHILDREN
        // ============================================================
        const _SectionTitle(title: 'Your Children'),

        const SizedBox(height: 12),

        const _ChildCard(
          initials: 'AF',
          name: 'Abeebech Fekadu',
          className: 'Sunbeam Room',
          status: 'Report Ready',
          statusType: _ChildStatus.ready,
        ),

        const SizedBox(height: 10),

        const _ChildCard(
          initials: 'KT',
          name: 'Kebede Tadesse',
          className: 'Sunbeam Room',
          status: 'In Progress',
          statusType: _ChildStatus.inProgress,
        ),

        const SizedBox(height: 24),

        // ============================================================
        // QUICK ACCESS
        // ============================================================
        const _SectionTitle(title: 'Quick Access'),

        const SizedBox(height: 12),

        // ============================================================
        // QUICK ACCESS ROW 1
        // ============================================================
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.description_outlined,
                title: 'Daily Report',
                subtitle: 'Updated 1h ago',
              ),
            ),

            SizedBox(width: 10),

            Expanded(
              child: _QuickAccessCard(
                icon: Icons.history_edu_outlined,
                title: '3 Month Report',
                subtitle: 'Last: Jun 2026',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ============================================================
        // QUICK ACCESS ROW 2
        // ============================================================
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.photo_library_outlined,
                title: 'Photo Gallery',
                subtitle: '12 new photos',
              ),
            ),

            SizedBox(width: 10),

            Expanded(
              child: _QuickAccessCard(
                icon: Icons.payment_outlined,
                title: 'Payment',
                subtitle: 'View payments',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// WEEKLY THEME CARD
// ============================================================================

class _WeeklyThemeCard extends StatelessWidget {
  const _WeeklyThemeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "THIS WEEK'S THEME",
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'All About Me & My World',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Abeebech has 2 new photos and today's daily report is ready to view.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// ============================================================================
// CHILD STATUS
// ============================================================================

enum _ChildStatus { ready, inProgress }

// ============================================================================
// CHILD CARD
// ============================================================================

class _ChildCard extends StatelessWidget {
  final String initials;
  final String name;
  final String className;
  final String status;
  final _ChildStatus statusType;

  const _ChildCard({
    required this.initials,
    required this.name,
    required this.className,
    required this.status,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = statusType == _ChildStatus.ready
        ? Colors.green
        : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // ============================================================
          // INITIALS
          // ============================================================

          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ============================================================
          // CHILD INFORMATION
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  className,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ============================================================
          // STATUS
          // ============================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACCESS CARD
// ============================================================================

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // IMPORTANT:
      // Use a fixed height instead of minHeight.
      //
      // The card is inside a vertically scrolling CustomScrollView.
      // minHeight does not provide a bounded height to the Column.
      // Spacer() requires bounded height.
      height: 105,

      width: double.infinity,

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // ICON
          // ============================================================

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),

          // ============================================================
          // FILL AVAILABLE SPACE
          // ============================================================
          const Spacer(),

          // ============================================================
          // TITLE
          // ============================================================
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          // ============================================================
          // SUBTITLE
          // ============================================================
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
