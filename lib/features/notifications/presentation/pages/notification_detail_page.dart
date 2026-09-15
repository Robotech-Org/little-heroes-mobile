import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/notifications/data/models/announcement_model.dart';
import 'package:little_heroes_mobile/features/notifications/domain/repositories/announcement_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class NotificationDetailPage extends StatefulWidget {
  /// Can be constructed either with a full [announcement] (fast path)
  /// or with just an [announcementId] (deep-link path).
  final AnnouncementModel? announcement;
  final String? announcementId;

  const NotificationDetailPage({
    super.key,
    this.announcement,
    this.announcementId,
  }) : assert(
         announcement != null || announcementId != null,
         'Provide either an announcement or an announcementId',
       );

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  AnnouncementModel? _announcement;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Fast path: we already have the object from the list.
    if (widget.announcement != null) {
      _announcement = widget.announcement;
      return;
    }

    // Deep-link path: fetch by id.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _loading = false;
          _error = 'Please login to view this notification';
        });
        return;
      }

      final repo = di.sl<AnnouncementRepository>();
      final result = await repo.getAnnouncement(widget.announcementId!);

      if (!mounted) return;
      setState(() {
        _announcement = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_announcement != null)
            IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () {
                // Optional: copy body to clipboard
                SnackbarUtils.showSuccess(context, 'Copied to clipboard');
              },
            ),
        ],
      ),
      body: _buildBody(theme, colorScheme),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colorScheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError(theme, colorScheme, _error!);
    }

    final a = _announcement;
    if (a == null) {
      return _buildEmpty(theme, colorScheme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card with title ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        a.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meta row: date · author · classroom
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _metaChip(
                      icon: Icons.schedule_rounded,
                      label: a.postedAt,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                    if (a.postedBy != null && a.postedBy!.isNotEmpty)
                      _metaChip(
                        icon: Icons.person_outline_rounded,
                        label: a.postedBy!,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    if (a.classroom != null && a.classroom!.isNotEmpty)
                      _metaChip(
                        icon: Icons.class_rounded,
                        label: a.classroom!,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Body ────────────────────────────────────────────────
          Text(
            'Message',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              a.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Attachment placeholder ──────────────────────────────
          // If your AnnouncementModel has an attachment field, show it here.
          // Example:
          // if (a.attachmentUrl != null) _buildAttachment(a.attachmentUrl!),

          // ── Footer ──────────────────────────────────────────────
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Received ${a.postedAt}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load notification',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.announcementId != null)
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

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Notification not found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
