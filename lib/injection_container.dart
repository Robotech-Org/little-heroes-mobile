import 'package:get_it/get_it.dart';
import 'package:little_heroes_mobile/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:little_heroes_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:little_heroes_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/send_otp.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';

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

  // ============================================
  // AUTH - BLOC
  // ============================================

  sl.registerFactory(() => AuthBloc(sendOtp: sl()));

  // ============================================
  // AUTH - USE CASES
  // ============================================

  sl.registerLazySingleton(() => SendOtp(sl()));

  // ============================================
  // AUTH - REPOSITORY
  // ============================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(mockDataSource: sl()),
  );

  // ============================================
  // AUTH - DATA SOURCE
  // ============================================

  sl.registerLazySingleton<AuthMockDataSource>(() => AuthMockDataSourceImpl());
}
