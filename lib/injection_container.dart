import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/api_constants.dart';

import 'package:little_heroes_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:little_heroes_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:little_heroes_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/send_otp.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/verify_otp.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';

import 'features/notifications/data/datasources/notification_local_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications.dart';
import 'features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================================
  // CORE - DIO
  // ============================================================

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() {
      final baseUrl = ApiConstants.baseUrl;

      if (baseUrl.isEmpty) {
        throw Exception('API_BASE_URL is empty. Please check your .env file.');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // API Request/Response Debugger
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) => print('🌐 DIO: $object'),
        ),
      );

      return dio;
    });
  }

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
  // NOTIFICATION USE CASES
  // ============================================================

  if (!sl.isRegistered<GetNotifications>()) {
    sl.registerLazySingleton<GetNotifications>(
      () => GetNotifications(repository: sl<NotificationRepository>()),
    );
  }

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

  // ============================================================
  // AUTH REMOTE DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // ============================================================
  // AUTH REPOSITORY
  // ============================================================

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
    );
  }

  // ============================================================
  // AUTH USE CASES
  // ============================================================

  if (!sl.isRegistered<LoginWithPhoneAndPassword>()) {
    sl.registerLazySingleton<LoginWithPhoneAndPassword>(
      () => LoginWithPhoneAndPassword(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<VerifyOtp>()) {
    sl.registerLazySingleton<VerifyOtp>(() => VerifyOtp(sl<AuthRepository>()));
  }

  // ============================================================
  // AUTH BLOC
  // ============================================================

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginWithPhoneAndPassword: sl<LoginWithPhoneAndPassword>(),
        verifyOtp: sl<VerifyOtp>(),
      ),
    );
  }
}
