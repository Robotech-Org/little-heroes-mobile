import 'package:flutter/material.dart';

import '../widgets/adviser/adviser_dashboard.dart';
import '../widgets/common/home_header.dart';
import '../widgets/common/home_stat_card.dart';
import '../widgets/common/recent_activity.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/upcoming_card.dart';

class AdviserHomePage extends StatelessWidget {
  const AdviserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: HomeHeader()),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const AdviserDashboard(),

                  const SizedBox(height: 24),

                  // const HomeStatCard(),
                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: 'Recent Activities',
                    subtitle: 'Latest student activities',
                  ),

                  const SizedBox(height: 14),

                  const RecentActivity(type: RecentActivityType.adviser),

                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: 'Upcoming',
                    subtitle: 'Your next scheduled activity',
                  ),

                  const SizedBox(height: 14),

                  const UpcomingCard(type: UpcomingType.adviser),

                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
