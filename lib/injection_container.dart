import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:little_heroes_mobile/core/network/socket/socket_service.dart';
import 'package:little_heroes_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:little_heroes_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:little_heroes_mobile/features/attendance/data/services/attendance_session_service.dart';
import 'package:little_heroes_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:little_heroes_mobile/features/attendance/domain/usecases/sync_pending_sessions.dart';
import 'package:little_heroes_mobile/features/chats/data/datasources/chat_remote_datasource.dart';
import 'package:little_heroes_mobile/features/chats/data/repositories/chat_repository_impl.dart';
import 'package:little_heroes_mobile/features/chats/domain/repositories/chat_repository.dart';
import 'package:little_heroes_mobile/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/classroom_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/competency_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/daily_report_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/framework_domain_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/gallery_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/lesson_plan_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/moment_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/observation_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/datasources/three_month_report_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_schedule_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/classroom_remote_data_source.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/classroom_schedule_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/competency_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/daily_report_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/framework_domain_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/gallery_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/lesson_plan_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/moment_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/observation_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/data/repositories/three_month_report_repository_impl.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_schedule_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/competency_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/dashboard_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/framework_domain_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/gallery_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/lesson_plan_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/moment_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/usecases/get_gallery_items.dart';
import 'package:little_heroes_mobile/features/home/presentation/bloc/gallery_bloc.dart';
import 'package:little_heroes_mobile/features/notifications/data/datasources/announcement_remote_data_source.dart';
import 'package:little_heroes_mobile/features/notifications/data/datasources/device_notification_remote_data_source.dart';
import 'package:little_heroes_mobile/features/notifications/data/repositories/announcement_repository_impl.dart';
import 'package:little_heroes_mobile/features/notifications/data/repositories/device_notification_repository_impl.dart';
import 'package:little_heroes_mobile/features/notifications/domain/repositories/announcement_repository.dart';
import 'package:little_heroes_mobile/features/notifications/domain/repositories/device_notification_repository.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/get_my_notifications.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/mark_notifications_read.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/register_device.dart';
import 'package:little_heroes_mobile/features/notifications/domain/usecases/unregister_device.dart';
import 'package:little_heroes_mobile/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:little_heroes_mobile/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:little_heroes_mobile/features/payments/domain/repositories/payment_repository.dart';
import 'package:little_heroes_mobile/features/students/data/datasources/student_remote_data_source.dart';
import 'package:little_heroes_mobile/features/students/data/repositories/student_repository_impl.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';

import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart'; // ADD THIS IMPORT

import 'package:little_heroes_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:little_heroes_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:little_heroes_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/change_password.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/logout.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/send_otp.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/verify_otp.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================================
  // CORE - DIO (Using DioClient with CookieManager)
  // ============================================================

  if (!sl.isRegistered<Dio>()) {
    // Create DioClient which has CookieManager configured
    final dioClient = await DioClient.create();
    sl.registerLazySingleton<Dio>(() => dioClient.dio);
  }

  // ============================================================
  // NOTIFICATION DATA SOURCE
  // ============================================================

  // ============================================================
  // DEVICE NOTIFICATIONS (Push + Inbox)
  // ============================================================

  if (!sl.isRegistered<DeviceNotificationRemoteDataSource>()) {
    sl.registerLazySingleton<DeviceNotificationRemoteDataSource>(
      () => DeviceNotificationRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<DeviceNotificationRepository>()) {
    sl.registerLazySingleton<DeviceNotificationRepository>(
      () => DeviceNotificationRepositoryImpl(
        remoteDataSource: sl<DeviceNotificationRemoteDataSource>(),
      ),
    );
  }

  // Usecases
  if (!sl.isRegistered<RegisterDevice>()) {
    sl.registerLazySingleton<RegisterDevice>(
      () => RegisterDevice(sl<DeviceNotificationRepository>()),
    );
  }

  if (!sl.isRegistered<GetMyNotifications>()) {
    sl.registerLazySingleton<GetMyNotifications>(
      () => GetMyNotifications(sl<DeviceNotificationRepository>()),
    );
  }

  if (!sl.isRegistered<MarkNotificationsRead>()) {
    sl.registerLazySingleton<MarkNotificationsRead>(
      () => MarkNotificationsRead(sl<DeviceNotificationRepository>()),
    );
  }

  if (!sl.isRegistered<UnregisterDevice>()) {
    sl.registerLazySingleton<UnregisterDevice>(
      () => UnregisterDevice(sl<DeviceNotificationRepository>()),
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

  if (!sl.isRegistered<Logout>()) {
    sl.registerLazySingleton<Logout>(() => Logout(sl<AuthRepository>()));
  }

  if (!sl.isRegistered<ChangePassword>()) {
    sl.registerLazySingleton<ChangePassword>(
      () => ChangePassword(sl<AuthRepository>()),
    );
  }

  // ============================================================
  // AUTH BLOC
  // ============================================================

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginWithPhoneAndPassword: sl<LoginWithPhoneAndPassword>(),
        verifyOtp: sl<VerifyOtp>(),
        logout: sl<Logout>(),
        changePassword: sl<ChangePassword>(),
      ),
    );
  }

  // Daily Report Remote Data Source
  if (!sl.isRegistered<DailyReportRemoteDataSource>()) {
    sl.registerLazySingleton<DailyReportRemoteDataSource>(
      () => DailyReportRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Daily Report Repository
  if (!sl.isRegistered<DailyReportRepository>()) {
    sl.registerLazySingleton<DailyReportRepository>(
      () => DailyReportRepositoryImpl(
        remoteDataSource: sl<DailyReportRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // THREE MONTH REPORT - ADD THIS SECTION
  // ============================================================

  // Three Month Report Remote Data Source
  if (!sl.isRegistered<ThreeMonthReportRemoteDataSource>()) {
    sl.registerLazySingleton<ThreeMonthReportRemoteDataSource>(
      () => ThreeMonthReportRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Three Month Report Repository
  if (!sl.isRegistered<ThreeMonthReportRepository>()) {
    sl.registerLazySingleton<ThreeMonthReportRepository>(
      () => ThreeMonthReportRepositoryImpl(
        remoteDataSource: sl<ThreeMonthReportRemoteDataSource>(),
      ),
    );
  }

  // Student Remote Data Source
  if (!sl.isRegistered<StudentRemoteDataSource>()) {
    sl.registerLazySingleton<StudentRemoteDataSource>(
      () => StudentRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Student Repository
  if (!sl.isRegistered<StudentRepository>()) {
    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(
        remoteDataSource: sl<StudentRemoteDataSource>(),
      ),
    );
  }

  // Add this section after other repositories
  // ============================================================
  // OBSERVATION
  // ============================================================

  if (!sl.isRegistered<ObservationRemoteDataSource>()) {
    sl.registerLazySingleton<ObservationRemoteDataSource>(
      () => ObservationRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<ObservationRepository>()) {
    sl.registerLazySingleton<ObservationRepository>(
      () => ObservationRepositoryImpl(
        remoteDataSource: sl<ObservationRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // CHAT
  // ============================================================

  if (!sl.isRegistered<SocketService>()) {
    sl.registerLazySingleton<SocketService>(() => SocketService());
  }

  if (!sl.isRegistered<ChatRemoteDataSource>()) {
    sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSource(),
    );
  }

  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remote: sl<ChatRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<ChatBloc>()) {
    sl.registerFactory<ChatBloc>(
      () => ChatBloc(
        repository: sl<ChatRepository>(),
        socketService: sl<SocketService>(),
      ),
    );
  }

  // ============================================================
  // ANNOUNCEMENT
  // ============================================================

  if (!sl.isRegistered<AnnouncementRemoteDataSource>()) {
    sl.registerLazySingleton<AnnouncementRemoteDataSource>(
      () => AnnouncementRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<AnnouncementRepository>()) {
    sl.registerLazySingleton<AnnouncementRepository>(
      () => AnnouncementRepositoryImpl(
        remoteDataSource: sl<AnnouncementRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<LessonPlanRemoteDataSource>()) {
    sl.registerLazySingleton<LessonPlanRemoteDataSource>(
      () => LessonPlanRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<LessonPlanRepository>()) {
    sl.registerLazySingleton<LessonPlanRepository>(
      () => LessonPlanRepositoryImpl(
        remoteDataSource: sl<LessonPlanRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // FRAMEWORK DOMAIN
  // ============================================================

  if (!sl.isRegistered<FrameworkDomainRemoteDataSource>()) {
    sl.registerLazySingleton<FrameworkDomainRemoteDataSource>(
      () => FrameworkDomainRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<FrameworkDomainRepository>()) {
    sl.registerLazySingleton<FrameworkDomainRepository>(
      () => FrameworkDomainRepositoryImpl(
        remoteDataSource: sl<FrameworkDomainRemoteDataSource>(),
      ),
    );
  }
  // ============================================================
  // COMPETENCY
  // ============================================================

  if (!sl.isRegistered<CompetencyRemoteDataSource>()) {
    sl.registerLazySingleton<CompetencyRemoteDataSource>(
      () => CompetencyRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<CompetencyRepository>()) {
    sl.registerLazySingleton<CompetencyRepository>(
      () => CompetencyRepositoryImpl(
        remoteDataSource: sl<CompetencyRemoteDataSource>(),
      ),
    );
  }
  // ============================================================
  // DASHBOARD
  // ============================================================

  if (!sl.isRegistered<DashboardRemoteDataSource>()) {
    sl.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<DashboardRepository>()) {
    sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: sl<DashboardRemoteDataSource>(),
      ),
    );
  }

  // Classroom Remote Data Source
  if (!sl.isRegistered<ClassroomRemoteDataSource>()) {
    sl.registerLazySingleton<ClassroomRemoteDataSource>(
      () => ClassroomRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Classroom Repository
  if (!sl.isRegistered<ClassroomRepository>()) {
    sl.registerLazySingleton<ClassroomRepository>(
      () => ClassroomRepositoryImpl(
        remoteDataSource: sl<ClassroomRemoteDataSource>(),
      ),
    );
  }

  // In injection_container.dart
  // Classroom Schedule Remote Data Source
  if (!sl.isRegistered<ClassroomScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<ClassroomScheduleRemoteDataSource>(
      () => ClassroomScheduleRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Classroom Schedule Repository
  if (!sl.isRegistered<ClassroomScheduleRepository>()) {
    sl.registerLazySingleton<ClassroomScheduleRepository>(
      () => ClassroomScheduleRepositoryImpl(
        remoteDataSource: sl<ClassroomScheduleRemoteDataSource>(),
      ),
    );
  }

  // Payment Remote Data Source
  if (!sl.isRegistered<PaymentRemoteDataSource>()) {
    sl.registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Payment Repository
  if (!sl.isRegistered<PaymentRepository>()) {
    sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(
        remoteDataSource: sl<PaymentRemoteDataSource>(),
      ),
    );
  }

  // Gallery Remote Data Source
  if (!sl.isRegistered<GalleryRemoteDataSource>()) {
    sl.registerLazySingleton<GalleryRemoteDataSource>(
      () => GalleryRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Gallery Repository
  if (!sl.isRegistered<GalleryRepository>()) {
    sl.registerLazySingleton<GalleryRepository>(
      () => GalleryRepositoryImpl(
        remoteDataSource: sl<GalleryRemoteDataSource>(),
      ),
    );
  }

  // Gallery Use Cases
  if (!sl.isRegistered<GetGalleryItems>()) {
    sl.registerLazySingleton<GetGalleryItems>(
      () => GetGalleryItems(sl<GalleryRepository>()),
    );
  }

  // Gallery Bloc
  if (!sl.isRegistered<GalleryBloc>()) {
    sl.registerFactory<GalleryBloc>(
      () => GalleryBloc(getGalleryItems: sl<GetGalleryItems>()),
    );
  }

  // Moment Remote Data Source
  if (!sl.isRegistered<MomentRemoteDataSource>()) {
    sl.registerLazySingleton<MomentRemoteDataSource>(
      () => MomentRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  // Moment Repository
  if (!sl.isRegistered<MomentRepository>()) {
    sl.registerLazySingleton<MomentRepository>(
      () =>
          MomentRepositoryImpl(remoteDataSource: sl<MomentRemoteDataSource>()),
    );
  }

  // ============================================================
  // ATTENDANCE
  // ============================================================
  if (!sl.isRegistered<AttendanceRemoteDataSource>()) {
    sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<AttendanceRepository>()) {
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(
        remoteDataSource: sl<AttendanceRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<AttendanceSessionService>()) {
    sl.registerLazySingleton<AttendanceSessionService>(
      () => AttendanceSessionService(),
    );
  }

  if (!sl.isRegistered<SyncPendingSessions>()) {
    sl.registerLazySingleton<SyncPendingSessions>(
      () => SyncPendingSessions(
        sl<AttendanceRepository>(),
        sl<AttendanceSessionService>(),
      ),
    );
  }
}
