import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/services/newsletter_cache_service.dart';

import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/newsletter_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/newsletter_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'newsletter_detail_page.dart';

class NewsletterPage extends StatefulWidget {
  const NewsletterPage({super.key});

  @override
  State<NewsletterPage> createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  final _searchController = TextEditingController();

  List<NewsletterModel> _all = [];
  List<NewsletterModel> _filtered = [];

  bool _isLoading = true; // true only when there's nothing to show yet
  bool _isError = false;
  bool _isOffline = false; // ← true when showing cached data due to API failure
  String _errorMessage = '';
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  // LOAD — cache first, then network
  // ══════════════════════════════════════════════════

  Future<void> _load() async {
    //  Try cache first — instant display
    final cached = NewsletterCacheService.instance.load();
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _all = cached;
        _filtered = cached;
        _isLoading = false;
        _isOffline = false;
        _isError = false;
        _cachedAt = NewsletterCacheService.instance.lastUpdated();
      });
    } else {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    }

    // 2️ Then hit the network
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (!mounted) return;
        // If we have cache, keep showing it; only show error if we don't
        if (cached == null || cached.isEmpty) {
          setState(() {
            _isLoading = false;
            _isError = true;
            _errorMessage = 'Please login to view newsletters';
          });
        }
        return;
      }

      final repo = di.sl<NewsletterRepository>();
      final response = await repo.listNewsletters(page: 1, pageSize: 50);

      if (!mounted) return;

      // 3️ Success — update UI + save to cache
      await NewsletterCacheService.instance.save(response.items);

      setState(() {
        _all = response.items;
        _filtered = response.items;
        _isLoading = false;
        _isError = false;
        _isOffline = false;
        _cachedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      // 4️ Network failed — if we have cache, stay offline (don't error)
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _isError = false;
          _isOffline = true;
          _errorMessage = message;
        });
      } else {
        // No cache to fall back to — show full error screen
        setState(() {
          _isLoading = false;
          _isError = true;
          _isOffline = false;
          _errorMessage = message;
        });
      }
    }
  }

  // ══════════════════════════════════════════════════
  // SEARCH
  // ══════════════════════════════════════════════════

  void _applySearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
        return;
      }
      _filtered = _all.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.body.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Newsletters',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // ══════════ OFFLINE BANNER ══════════
          if (_isOffline) _buildOfflineBanner(theme, colors),

          // ══════════ SEARCH BAR ══════════
          if (!_isLoading && !_isError && _all.isNotEmpty)
            _buildSearchBar(theme, colors),

          Expanded(child: _buildBody(theme, colors)),
        ],
      ),
    );
  }

  // ─── Offline banner ───────────────────────────────
  Widget _buildOfflineBanner(ThemeData theme, ColorScheme colors) {
    return Material(
      color: Colors.orange.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _cachedAt != null
                    ? 'Offline — showing cached data from ${_fmtDate(_cachedAt!)}'
                    : 'Offline — showing cached data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _load,
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

  // ─── Search bar ───────────────────────────────────
  Widget _buildSearchBar(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _applySearch,
        decoration: InputDecoration(
          hintText: 'Search newsletters…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _applySearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: colors.surfaceVariant.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────
  Widget _buildBody(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load newsletters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                _searchController.text.isNotEmpty
                    ? 'No matching newsletters'
                    : 'No newsletters yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Try a different search term.'
                    : 'Newsletters from the school will appear here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _NewsletterCard(
            newsletter: _filtered[i],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      NewsletterDetailPage(newsletterName: _filtered[i].name),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Date formatter ───────────────────────────────
  String _fmtDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════
// CARD (unchanged)
// ═══════════════════════════════════════════════════════════════

class _NewsletterCard extends StatelessWidget {
  final NewsletterModel newsletter;
  final VoidCallback onTap;
  const _NewsletterCard({required this.newsletter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDraft = !newsletter.isPublished;
    final statusColor = isDraft ? Colors.orange : Colors.green;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          newsletter.status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            fontSize: 9.5,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (newsletter.publishedAt != null)
                    Text(
                      _fmtDate(newsletter.publishedAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                newsletter.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _stripHtml(newsletter.body),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 13,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      newsletter.publishedBy.isNotEmpty
                          ? newsletter.publishedBy
                          : 'School',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
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
      ),
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
