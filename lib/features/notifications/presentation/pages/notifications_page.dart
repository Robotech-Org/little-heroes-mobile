import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/services/announcement_cache_service.dart';
import 'package:little_heroes_mobile/features/notifications/presentation/pages/notification_detail_page.dart';

import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/announcement_model.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../widgets/notification_empty.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  final bool isFullPage;

  const NotificationsPage({super.key, this.isFullPage = false});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isOffline = false;
  String _errorMessage = '';
  DateTime? _cachedAt;

  int _currentPage = 1;
  int _totalPages = 0;
  int _totalAnnouncements = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD — cache first, then network
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadAnnouncements({int page = 1}) async {
    final cache = AnnouncementCacheService.instance;

    // 1️ Cache-first — only when loading the first page
    if (page == 1) {
      final cached = cache.load();
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _announcements = cached;
          _isLoading = false;
          _isError = false;
          _isOffline = false;
          _cachedAt = cache.lastUpdated();
        });
      } else {
        setState(() {
          _isLoading = true;
          _isError = false;
        });
      }
    } else {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    }

    // 2️ Network
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (!mounted) return;
        if (_announcements.isEmpty) {
          setState(() {
            _isLoading = false;
            _isError = true;
            _errorMessage = 'Please login to view announcements';
          });
        }
        return;
      }

      final repository = di.sl<AnnouncementRepository>();
      final response = await repository.getAnnouncements(
        page: page,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      // 3️Persist the first page for offline use
      if (page == 1) {
        await cache.save(response.items);
      }

      setState(() {
        _announcements = response.items;
        _totalAnnouncements = response.total;
        _totalPages = response.totalPages;
        _currentPage = response.page;
        _isLoading = false;
        _isError = false;
        _isOffline = false;
        _cachedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;

      // 4️ Network failed → keep cache if we have it
      if (_announcements.isNotEmpty && page == 1) {
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

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: widget.isFullPage
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadAnnouncements(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Offline banner ────────────────────
          if (_isOffline) ...[
            _OfflineBanner(
              cachedAt: _cachedAt,
              onRetry: () => _loadAnnouncements(),
            ),
          ],

          // ── Main content ──────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadAnnouncements(),
              child: _buildContent(theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading && _announcements.isEmpty) {
      return const _NotificationsSkeleton();
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_announcements.isEmpty) {
      // Keep the pull-to-refresh working even on empty state
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          NotificationEmpty(
            title: 'No Notifications',
            message: 'You\'re all caught up! No new notifications.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return NotificationTile(
          announcement: announcement,
          onTap: () => _openNotificationDetail(announcement),
        );
      },
    );
  }

  void _openNotificationDetail(AnnouncementModel announcement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailPage(announcement: announcement),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
    // Wrapped in ListView so pull-to-refresh works here too
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Failed to load notifications',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _loadAnnouncements(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cachedAt != null
                    ? 'Offline — showing cached notifications (${_fmtAgo(cachedAt!)})'
                    : 'Offline — showing cached notifications',
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
// SKELETON
// ═══════════════════════════════════════════════════════════════
class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      itemCount: 8,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _NotificationCardSkeleton(baseColor: baseColor, delay: i),
      ),
    );
  }
}

class _NotificationCardSkeleton extends StatelessWidget {
  final Color baseColor;
  final int delay;

  const _NotificationCardSkeleton({
    required this.baseColor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Slightly fade the last few items for a nicer visual
    final opacity = (1.0 - delay * 0.08).clamp(0.4, 1.0);

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),

            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line (varying widths)
                  _bar(
                    width: 140.0 + ((delay * 17) % 60),
                    height: 14,
                    color: baseColor,
                  ),
                  const SizedBox(height: 8),
                  // Body line 1
                  _bar(
                    width: double.infinity,
                    height: 11,
                    color: baseColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 6),
                  // Body line 2 (shorter)
                  _bar(
                    width: 100.0 + ((delay * 23) % 80),
                    height: 11,
                    color: baseColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 10),
                  // Time stamp
                  _bar(
                    width: 60,
                    height: 9,
                    color: baseColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
