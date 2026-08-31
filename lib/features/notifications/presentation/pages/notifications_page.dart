import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_empty.dart';
import '../widgets/notification_filter.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();

    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.status == NotificationStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == NotificationStatus.failure) {
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () {
                  context.read<NotificationBloc>().add(
                    const LoadNotifications(),
                  );
                },
              );
            }

            final notifications = _filterNotifications(state);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },

              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverToBoxAdapter(
                    child: NotificationHeader(
                      unreadCount: state.unreadCount,
                      onMarkAllRead: () {
                        context.read<NotificationBloc>().add(
                          const MarkAllNotificationsRead(),
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: NotificationFilterWidget(
                      selected: _filter,
                      onChanged: (filter) {
                        setState(() {
                          _filter = filter;
                        });
                      },
                    ),
                  ),

                  if (notifications.isEmpty)
                    const SliverFillRemaining(child: NotificationEmpty())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final notification = notifications[index];

                        return NotificationTile(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<NotificationBloc>().add(
                                MarkNotificationRead(notification.id),
                              );
                            }

                            // TODO:
                            // Navigate to the
                            // related feature.
                          },
                        );
                      }, childCount: notifications.length),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List _filterNotifications(NotificationState state) {
    if (_filter == NotificationFilter.unread) {
      return state.unreadNotifications;
    }

    return state.notifications;
  }
}

// ==================================================================
// ERROR
// ==================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),

            const SizedBox(height: 15),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 15),

            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
