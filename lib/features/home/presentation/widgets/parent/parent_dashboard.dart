import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_page.dart'
    show DailyReportPage;
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/three_month_report_page.dart';
import 'package:little_heroes_mobile/features/payments/presentation/pages/payment_page.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WeeklyThemeCard(),

        const SizedBox(height: 24),

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

        const _SectionTitle(title: 'Quick Access'),

        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.description_outlined,
                title: 'Daily Report',
                subtitle: 'Updated 1h ago',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DailyReportPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.history_edu_outlined,
                title: '3 Month Report',
                subtitle: 'Last: Jun 2026',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThreeMonthReportPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.photo_library_outlined,
                title: 'Photo Gallery',
                subtitle: '12 new photos',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PhotoGalleryPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.payment_outlined,
                title: 'Payment',
                subtitle: 'View payments',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// WEEKLY THEME

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

// SECTION TITLE

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

// CHILD STATUS

enum _ChildStatus { ready, inProgress }

// CHILD CARD

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

// QUICK ACCESS CARD

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 105,
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

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
        ),
      ),
    );
  }
}
