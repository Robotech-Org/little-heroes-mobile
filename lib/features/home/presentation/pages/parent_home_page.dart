import 'package:flutter/material.dart';

import '../widgets/common/home_header.dart';
import '../widgets/common/recent_activity.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/upcoming_card.dart';
import '../widgets/parent/parent_dashboard.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER

            // const SliverToBoxAdapter(child: HomeHeader()),

            // CONTENT
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ==
                  // PARENT DASHBOARD
                  // ==

                  const ParentDashboard(),

                  const SizedBox(height: 28),

                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
