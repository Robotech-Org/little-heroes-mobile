import 'package:flutter/material.dart';

class MomentsPage extends StatelessWidget {
  const MomentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final moments = [
      const _Moment(
        title: 'Circle Time & Storytelling',
        description: 'Painting our family trees',
        teacher: 'Ms. Selam',
        icon: Icons.auto_stories_rounded,
        imageUrl: null,
        time: 'Today • 9:30 AM',
      ),
      const _Moment(
        title: 'Outdoor Play',
        description: 'Block building activity',
        teacher: 'Mr. Abebe',
        icon: Icons.toys_rounded,
        imageUrl: null,
        time: 'Today • 11:00 AM',
      ),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ----------------------------------------------------
            // APP BAR
            // ----------------------------------------------------

            SliverAppBar(
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text(
                'Moments',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              centerTitle: false,
            ),

            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Little moments, big memories',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'See what your child has been learning, creating, and enjoying.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // MOMENTS
            // ----------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: SliverList.separated(
                itemCount: moments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _MomentCard(moment: moments[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MOMENT MODEL

class _Moment {
  final String title;
  final String description;
  final String teacher;
  final String time;
  final IconData icon;
  final String? imageUrl;

  const _Moment({
    required this.title,
    required this.description,
    required this.teacher,
    required this.time,
    required this.icon,
    required this.imageUrl,
  });
}

// MOMENT CARD

class _MomentCard extends StatelessWidget {
  final _Moment moment;

  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Open moment details
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // IMAGE
              // --------------------------------------------------

              AspectRatio(
                aspectRatio: 16 / 9,
                child: moment.imageUrl != null
                    ? Image.network(moment.imageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: colors.primaryContainer,
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              moment.icon,
                              size: 30,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
              ),

              // --------------------------------------------------
              // CONTENT
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            moment.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.more_horiz_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      moment.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: colors.secondaryContainer,
                          child: Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: colors.onSecondaryContainer,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moment.teacher,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                moment.time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
