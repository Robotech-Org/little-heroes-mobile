import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/common/home_header.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/three_month_report_page.dart';
import 'package:little_heroes_mobile/features/payments/presentation/pages/payment_page.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  ParentData? _dashboardData;
  bool _isLoading = true;
  bool _isError = false;
  bool _isRefreshing = false;
  String _errorMessage = '';

  // Cache for data
  ParentData? _cachedData;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool useCache = true}) async {
    // Check if we have valid cached data
    if (useCache && _cachedData != null && _lastCacheTime != null) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _dashboardData = _cachedData;
          _isLoading = false;
          _isError = false;
        });
        return;
      }
    }

    // Don't show loading if we have cached data to show
    final hasCachedData = _cachedData != null;
    if (!hasCachedData) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    } else {
      setState(() {
        _isRefreshing = true;
        _isError = false;
      });
    }

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view dashboard';
        });
        return;
      }

      final repository = di.sl<DashboardRepository>();
      final response = await repository.getDashboard();

      // Check if the response data is for parent
      if (response.data is ParentData) {
        final data = response.data as ParentData;
        setState(() {
          _dashboardData = data;
          _cachedData = data;
          _lastCacheTime = DateTime.now();
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Invalid dashboard data for parent';
        });
      }
    } catch (e) {
      // If we have cached data, keep showing it even on error
      if (_cachedData != null) {
        setState(() {
          _dashboardData = _cachedData;
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
        });
        // Show a toast or snackbar for the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading only on first load
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (_isError) {
      return _buildErrorWidget();
    }

    if (_dashboardData == null) {
      return const SizedBox.shrink();
    }

    final data = _dashboardData!;
    final theme = Theme.of(context);

    // REMOVED: RefreshIndicator and SingleChildScrollView - no nested scroll
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeHeader(),
        const SizedBox(height: 12),

        // Weekly Theme Card
        _WeeklyThemeCard(theme: data.theme),
        const SizedBox(height: 24),

        // Your Children Section
        const _SectionTitle(title: 'Your Children'),
        const SizedBox(height: 12),

        // Children List
        // ...data.children.map((child) {
        //   return Padding(
        //     padding: const EdgeInsets.only(bottom: 10),
        //     child: _ChildCard(
        //       initials: child.initials.isNotEmpty
        //           ? child.initials
        //           : _getInitials(child.name),
        //       name: child.name,
        //       className: child.classroom,
        //       status: child.status,
        //       statusType: child.status.toLowerCase().contains('ready')
        //           ? _ChildStatus.ready
        //           : _ChildStatus.inProgress,
        //     ),
        //   );
        // }).toList(),
        ...data.children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChildCard(
              initials: child.initials.isNotEmpty
                  ? child.initials
                  : _getInitials(child.name),
              name: child.name,
              className: child.classroom,
              status: child.status,
              statusType: child.status.toLowerCase().contains('ready')
                  ? _ChildStatus.ready
                  : _ChildStatus.inProgress,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DailyReportPage(
                      studentName: child.name,
                      studentId: child.id,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        // Quick Access Section
        const _SectionTitle(title: 'Quick Access'),
        const SizedBox(height: 12),

        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       child: _QuickAccessCard(
        //         icon: Icons.description_outlined,
        //         title: data.quickAccess.dailyReport.label,
        //         subtitle: data.quickAccess.dailyReport.lastUpdated ?? 'Updated',
        //         onTap: () {
        //           Navigator.of(context).push(
        //             MaterialPageRoute(builder: (_) => const DailyReportPage()),
        //           );
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     Expanded(
        //       child: _QuickAccessCard(
        //         icon: Icons.history_edu_outlined,
        //         title: data.quickAccess.threeMonthReport.label,
        //         subtitle:
        //             data.quickAccess.threeMonthReport.lastUpdated ??
        //             'Last: Jun 2026',
        //         onTap: () {
        //           Navigator.of(context).push(
        //             MaterialPageRoute(
        //               builder: (_) => const ThreeMonthReportPage(),
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.description_outlined,
                title: data.quickAccess.dailyReport.label,
                subtitle: data.quickAccess.dailyReport.lastUpdated ?? 'Updated',
                onTap: () {
                  // Get the first child if available
                  if (data.children.isNotEmpty) {
                    final firstChild = data.children.first;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DailyReportPage(
                          studentName: firstChild.name,
                          studentId: firstChild.id,
                        ),
                      ),
                    );
                  } else {
                    // Show a snackbar if no children
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No children found to view report'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.history_edu_outlined,
                title: data.quickAccess.threeMonthReport.label,
                subtitle:
                    data.quickAccess.threeMonthReport.lastUpdated ??
                    'Last: Jun 2026',
                onTap: () {
                  // For three month report, you might want to pass the first child too
                  if (data.children.isNotEmpty) {
                    final firstChild = data.children.first;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ThreeMonthReportPage(
                          studentName: firstChild.name,
                          studentId: firstChild.id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No children found'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
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
                title: data.quickAccess.photoGallery.label,
                subtitle: data.quickAccess.photoGallery.newCount != null
                    ? '${data.quickAccess.photoGallery.newCount} new photos'
                    : 'View photos',
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
                title: data.quickAccess.billingAndPayment.label,
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

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDashboard(useCache: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ============================================================
  // SKELETON LOADING WIDGET
  // ============================================================

  Widget _buildSkeletonLoading() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weekly Theme Skeleton
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSkeletonLine(width: 120, height: 12),
              const SizedBox(height: 10),
              _buildSkeletonLine(width: 200, height: isSmallScreen ? 20 : 24),
              const SizedBox(height: 10),
              _buildSkeletonLine(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              _buildSkeletonLine(width: 150, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Title Skeleton
        _buildSkeletonLine(width: 150, height: 20),
        const SizedBox(height: 12),

        // Children List Skeletons
        ...List.generate(2, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Avatar Skeleton
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: 120, height: 16),
                      const SizedBox(height: 4),
                      _buildSkeletonLine(width: 80, height: 12),
                    ],
                  ),
                ),
                // Status Skeleton
                _buildSkeletonLine(width: 60, height: 24),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Quick Access Section Skeleton
        _buildSkeletonLine(width: 150, height: 20),
        const SizedBox(height: 12),

        // Quick Access Cards Row 1
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuickAccessSkeleton(theme)),
            const SizedBox(width: 10),
            Expanded(child: _buildQuickAccessSkeleton(theme)),
          ],
        ),
        const SizedBox(height: 10),

        // Quick Access Cards Row 2
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuickAccessSkeleton(theme)),
            const SizedBox(width: 10),
            Expanded(child: _buildQuickAccessSkeleton(theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildQuickAccessSkeleton(ThemeData theme) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Skeleton
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Spacer(),
          // Title Skeleton
          _buildSkeletonLine(width: 80, height: 14),
          const SizedBox(height: 3),
          // Subtitle Skeleton
          _buildSkeletonLine(width: 60, height: 12),
        ],
      ),
    );
  }
}

// ============================================================
// WEEKLY THEME CARD - FIXED OVERFLOW
// ============================================================

class _WeeklyThemeCard extends StatelessWidget {
  final ThemeInfo theme;

  const _WeeklyThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 14.0 : 18.0;
    final titleSize = isSmallScreen ? 18.0 : 24.0;
    final goalSize = isSmallScreen ? 12.0 : 14.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "THIS WEEK'S THEME",
            style: themeData.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            theme.title,
            style: themeData.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: titleSize,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            theme.summary.isNotEmpty
                ? theme.summary
                : 'Your child\'s daily report is ready to view.',
            style: themeData.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
              fontSize: goalSize,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

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

// ============================================================
// CHILD STATUS
// ============================================================

enum _ChildStatus { ready, inProgress }

// ============================================================
// CHILD CARD
// ============================================================

// class _ChildCard extends StatelessWidget {
//   final String initials;
//   final String name;
//   final String className;
//   final String status;
//   final _ChildStatus statusType;

//   const _ChildCard({
//     required this.initials,
//     required this.name,
//     required this.className,
//     required this.status,
//     required this.statusType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final statusColor = statusType == _ChildStatus.ready
//         ? Colors.green
//         : Colors.orange;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withValues(alpha: 0.10),
//               shape: BoxShape.circle,
//             ),
//             child: Text(
//               initials,
//               style: theme.textTheme.labelMedium?.copyWith(
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   name,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w700,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   className,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
//             decoration: BoxDecoration(
//               color: statusColor.withValues(alpha: 0.10),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               status,
//               style: theme.textTheme.labelSmall?.copyWith(
//                 color: statusColor,
//                 fontWeight: FontWeight.w700,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ChildCard extends StatelessWidget {
  final String initials;
  final String name;
  final String className;
  final String status;
  final _ChildStatus statusType;
  final VoidCallback onTap; // NEW

  const _ChildCard({
    required this.initials,
    required this.name,
    required this.className,
    required this.status,
    required this.statusType,
    required this.onTap, // NEW
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = statusType == _ChildStatus.ready
        ? Colors.green
        : Colors.orange;

    return GestureDetector(
      onTap: onTap, // NEW - Navigate to daily report
      child: Container(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    className,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACCESS CARD
// ============================================================

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
