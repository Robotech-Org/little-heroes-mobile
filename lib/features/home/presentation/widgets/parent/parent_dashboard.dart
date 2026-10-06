import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/services/parent_dashboard_cache_service.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/dashboard_response_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/common/home_header.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_list_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/newsletter_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/photo_gallery_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/three_month_report_list_page.dart';
import 'package:little_heroes_mobile/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:little_heroes_mobile/features/payments/presentation/pages/payment_history_page.dart';
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
  bool _isOffline = false;
  String _errorMessage = '';
  DateTime? _cachedAt;

  /// Children list — cached across scoped requests.
  List<ChildInfo> _children = [];

  /// Currently selected child. `null` = parent-wide dashboard.
  String? _selectedStudentId;

  /// Guards against repeated auto-scope fetches when there's only one child.
  bool _autoScoped = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD — cache first, then network
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadDashboard() async {
    final cache = ParentDashboardCacheService.instance;

    // 1️ Try cached data for the current scope (null = All Children)
    final cached = cache.load(_selectedStudentId);

    if (cached != null) {
      setState(() {
        _dashboardData = cached;
        _children = cached.children.isNotEmpty ? cached.children : _children;
        _isLoading = false;
        _isError = false;
        _isOffline = false;
        _cachedAt = cache.lastUpdated(_selectedStudentId);
      });
    } else {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    }

    // 2️ Hit the network
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (!mounted) return;
        if (cached == null) {
          setState(() {
            _isLoading = false;
            _isError = true;
            _errorMessage = 'Please login to view dashboard';
          });
        }
        return;
      }

      final repository = di.sl<DashboardRepository>();
      final response = await repository.getDashboard(
        studentId: _selectedStudentId,
      );

      if (!mounted) return;

      if (response.data is ParentData) {
        final data = response.data as ParentData;

        // Keep the children list cached across scoped requests.
        final incomingChildren = data.children;
        final children = _children.isEmpty
            ? incomingChildren
            : (_selectedStudentId == null ? incomingChildren : _children);

        // Auto-select the only child
        String? autoSelected = _selectedStudentId;
        bool needsRefetch = false;
        if (children.length == 1 &&
            _selectedStudentId == null &&
            !_autoScoped) {
          autoSelected = children.first.id;
          _autoScoped = true;
          needsRefetch = true;
        }

        // 3️ Persist for next time
        await cache.save(_selectedStudentId, data);

        setState(() {
          _dashboardData = data;
          _children = children;
          _selectedStudentId = autoSelected;
          _isLoading = false;
          _isError = false;
          _isOffline = false;
          _cachedAt = DateTime.now();
        });

        if (needsRefetch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadDashboard();
          });
        }
      } else {
        if (cached == null) {
          setState(() {
            _isLoading = false;
            _isError = true;
            _errorMessage = 'Invalid dashboard data for parent';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      // 4️ Network failed → fall back to cache if we have it
      if (cached != null) {
        setState(() {
          _isLoading = false;
          _isError = false;
          _isOffline = true;
          _errorMessage = e.toString();
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
          _isOffline = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _onChildSelected(String? studentId) async {
    if (studentId == _selectedStudentId) return;
    setState(() => _selectedStudentId = studentId);
    await _loadDashboard();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final showSelector = _children.isNotEmpty;
    final hasSingleChild = _children.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header (always visible) ────────────────────
        const HomeHeader(),

        // ── Offline banner ─────────────────────────────
        if (_isOffline) ...[
          const SizedBox(height: 10),
          _OfflineBanner(cachedAt: _cachedAt, onRetry: _loadDashboard),
        ],

        const SizedBox(height: 12),

        // ── Child selector ─────────────────────────────
        if (_isLoading && !showSelector) ...[
          const _ChildSelectorSkeleton(),
          const SizedBox(height: 5),
        ] else if (showSelector) ...[
          _ChildSelector(
            children: _children,
            selectedId: _selectedStudentId,
            onChanged: _isLoading ? null : _onChildSelected,
            allowAll: !hasSingleChild,
          ),
          const SizedBox(height: 8),
        ],

        // ── Body ───────────────────────────────────────
        if (_isLoading)
          _buildSkeletonLoading()
        else if (_isError || _dashboardData == null)
          _buildErrorWidget()
        else
          _buildContent(_dashboardData!),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildContent(ParentData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Weekly theme ───────────────────────────────
        _WeeklyThemeCard(theme: data.theme),
        const SizedBox(height: 24),

        // ── Your children ──────────────────────────────
        const _SectionTitle(title: 'Your Children'),
        const SizedBox(height: 12),
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
                    builder: (_) => ParentDailyReportListPage(
                      studentId: child.id,
                      studentName: child.name,
                    ),
                  ),
                );
              },
            ),
          );
        }),

        const SizedBox(height: 5),

        // ── Quick access ───────────────────────────────
        const _SectionTitle(title: 'Quick Access'),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.description_outlined,
                title: data.quickAccess.dailyReport.label,
                subtitle: data.quickAccess.dailyReport.lastUpdated ?? 'Updated',
                onTap: () => _openDailyReport(),
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
                onTap: () => _openThreeMonthReport(),
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
                icon: Icons.mark_email_read_outlined,
                title: 'Newsletters',
                subtitle: 'News & updates',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewsletterPage()),
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
                icon: Icons.payment_outlined,
                title: data.quickAccess.billingAndPayment.label,
                subtitle: 'View payments',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => di.sl<PaymentBloc>(),
                        child: const PaymentHistoryPage(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAV HELPERS
  // ═══════════════════════════════════════════════════════════
  ChildInfo? get _activeChild {
    if (_children.isEmpty) return null;
    if (_selectedStudentId != null) {
      return _children.firstWhere(
        (c) => c.id == _selectedStudentId,
        orElse: () => _children.first,
      );
    }
    return _children.first;
  }

  void _openDailyReport() {
    final child = _activeChild;
    if (child == null) return _noChildSnack();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParentDailyReportListPage(
          studentName: child.name,
          studentId: child.id,
        ),
      ),
    );
  }

  void _openThreeMonthReport() {
    final child = _activeChild;
    if (child == null) return _noChildSnack();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParentThreeMonthReportListPage(
          studentId: child.id,
          studentName: child.name,
        ),
      ),
    );
  }

  void _noChildSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No children found'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR
  // ═══════════════════════════════════════════════════════════
  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SKELETON
  // ═══════════════════════════════════════════════════════════
  Widget _buildSkeletonLoading() {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _skeletonLine(width: 120, height: 12, alpha: 0.5),
              const SizedBox(height: 10),
              _skeletonLine(
                width: 200,
                height: isSmallScreen ? 20 : 24,
                alpha: 0.5,
              ),
              const SizedBox(height: 10),
              _skeletonLine(width: double.infinity, height: 14, alpha: 0.5),
              const SizedBox(height: 4),
              _skeletonLine(width: 150, height: 14, alpha: 0.5),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _skeletonLine(width: 140, height: 20),
        const SizedBox(height: 12),

        ...List.generate(2, (_) => _childCardSkeleton(theme)),

        const SizedBox(height: 24),

        _skeletonLine(width: 120, height: 20),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _quickAccessSkeleton(theme)),
            const SizedBox(width: 10),
            Expanded(child: _quickAccessSkeleton(theme)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _quickAccessSkeleton(theme)),
            const SizedBox(width: 10),
            Expanded(child: _quickAccessSkeleton(theme)),
          ],
        ),
      ],
    );
  }

  Widget _childCardSkeleton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonLine(width: 120, height: 16),
                const SizedBox(height: 6),
                _skeletonLine(width: 80, height: 12),
              ],
            ),
          ),
          _skeletonLine(width: 60, height: 24),
        ],
      ),
    );
  }

  Widget _quickAccessSkeleton(ThemeData theme) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Spacer(),
          _skeletonLine(width: 80, height: 14),
          const SizedBox(height: 4),
          _skeletonLine(width: 60, height: 12),
        ],
      ),
    );
  }

  Widget _skeletonLine({
    double? width,
    double height = 16,
    double alpha = 1.0,
  }) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OFFLINE BANNER
// ═══════════════════════════════════════════════════════════════
class _OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback onRetry;

  const _OfflineBanner({required this.cachedAt, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.orange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cachedAt != null
                    ? 'Offline — showing cached data (${_fmtAgo(cachedAt!)})'
                    : 'Offline — showing cached data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ═══════════════════════════════════════════════════════════════
// CHILD SELECTOR
// ═══════════════════════════════════════════════════════════════
class _ChildSelector extends StatelessWidget {
  final List<ChildInfo> children;
  final String? selectedId;
  final ValueChanged<String?>? onChanged;
  final bool allowAll;

  const _ChildSelector({
    required this.children,
    required this.selectedId,
    required this.onChanged,
    this.allowAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onChanged != null;

    final items = <DropdownMenuItem<String?>>[];
    if (allowAll) {
      items.add(
        DropdownMenuItem<String?>(
          value: null,
          child: Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'All Children',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    items.addAll(
      children.map(
        (c) => DropdownMenuItem<String?>(
          value: c.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colors.primaryContainer.withValues(alpha: 0.6),
                child: Text(
                  _initials(c.name),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final safeValue = items.any((i) => i.value == selectedId)
        ? selectedId
        : (items.isNotEmpty ? items.first.value : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeValue,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled
                ? colors.onSurfaceVariant
                : colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          hint: Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 18,
                color: enabled
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 8),
              Text(
                'All Children',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════
// CHILD SELECTOR — SKELETON
// ═══════════════════════════════════════════════════════════════
class _ChildSelectorSkeleton extends StatelessWidget {
  const _ChildSelectorSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WEEKLY THEME
// ═══════════════════════════════════════════════════════════════
class _WeeklyThemeCard extends StatelessWidget {
  final ThemeInfo theme;
  const _WeeklyThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
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

// ═══════════════════════════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CHILD CARD
// ═══════════════════════════════════════════════════════════════
enum _ChildStatus { ready, inProgress }

class _ChildCard extends StatelessWidget {
  final String initials;
  final String name;
  final String className;
  final String status;
  final _ChildStatus statusType;
  final VoidCallback onTap;

  const _ChildCard({
    required this.initials,
    required this.name,
    required this.className,
    required this.status,
    required this.statusType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = statusType == _ChildStatus.ready
        ? Colors.green
        : Colors.orange;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACCESS CARD
// ═══════════════════════════════════════════════════════════════
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
