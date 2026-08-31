import 'package:get_it/get_it.dart';

import 'features/notifications/data/datasources/notification_local_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications.dart';
import 'features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

final GetIt sl = GetIt.instance;

/// Initialize all application dependencies.
Future<void> initDependencies() async {
  // ============================================================
  // NOTIFICATION DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<NotificationLocalDataSource>()) {
    sl.registerLazySingleton<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(),
    );
  }

  // ============================================================
  // NOTIFICATION REPOSITORY
  // ============================================================

  if (!sl.isRegistered<NotificationRepository>()) {
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        localDataSource: sl<NotificationLocalDataSource>(),
      ),
    );
  }

  // ============================================================
  // GET NOTIFICATIONS
  // ============================================================

  if (!sl.isRegistered<GetNotifications>()) {
    sl.registerLazySingleton<GetNotifications>(
      () => GetNotifications(repository: sl<NotificationRepository>()),
    );
  }

  // ============================================================
  // MARK NOTIFICATION AS READ
  // ============================================================

  if (!sl.isRegistered<MarkNotificationAsRead>()) {
    sl.registerLazySingleton<MarkNotificationAsRead>(
      () => MarkNotificationAsRead(repository: sl<NotificationRepository>()),
    );
  }

  // ============================================================
  // NOTIFICATION BLOC
  // ============================================================

  if (!sl.isRegistered<NotificationBloc>()) {
    sl.registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotifications: sl<GetNotifications>(),
        markNotificationAsRead: sl<MarkNotificationAsRead>(),
        repository: sl<NotificationRepository>(),
      ),
    );
  }
}
