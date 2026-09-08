// import 'package:flutter/material.dart';

// import '../widgets/common/home_header.dart';
// import '../widgets/common/recent_activity.dart';
// import '../widgets/common/section_header.dart';
// import '../widgets/common/upcoming_card.dart';
// import '../widgets/teacher/teacher_dashboard.dart';
// import '../widgets/teacher/teacher_qr_scanner_card.dart';
// import '../widgets/teacher/teacher_quick_actions.dart';

// class TeacherHomePage extends StatelessWidget {
//   const TeacherHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // const SliverToBoxAdapter(child: HomeHeader()),

//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   const TeacherDashboard(),

//                   const SizedBox(height: 28),

//                   const SectionHeader(title: 'Quick Actions'),

//                   const SizedBox(height: 14),

//                   const TeacherQrScannerCard(),

//                   const SizedBox(height: 28),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../widgets/common/home_header.dart';
import '../widgets/common/recent_activity.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/upcoming_card.dart';
import '../widgets/teacher/teacher_dashboard.dart';
import '../widgets/teacher/teacher_qr_scanner_card.dart';
import '../widgets/teacher/teacher_quick_actions.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HomeHeader(),
                const TeacherDashboard(),
                const SizedBox(height: 28),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 14),
                const TeacherQrScannerCard(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
