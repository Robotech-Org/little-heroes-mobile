// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../domain/repositories/notification_repository.dart';
// import '../../domain/usecases/get_notifications.dart';
// import '../../domain/usecases/mark_notification_as_read.dart';
// import 'notification_event.dart';
// import 'notification_state.dart';

// class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
//   final GetNotifications getNotifications;
//   final MarkNotificationAsRead markNotificationAsRead;
//   final NotificationRepository repository;

//   NotificationBloc({
//     required this.getNotifications,
//     required this.markNotificationAsRead,
//     required this.repository,
//   }) : super(const NotificationState()) {
//     on<LoadNotifications>(_onLoadNotifications);
//     on<MarkNotificationRead>(_onMarkNotificationRead);
//     on<MarkAllNotificationsRead>(_onMarkAllNotificationsRead);
//   }

//   Future<void> _onLoadNotifications(
//     LoadNotifications event,
//     Emitter<NotificationState> emit,
//   ) async {
//     emit(state.copyWith(status: NotificationStatus.loading));

//     try {
//       final notifications = await getNotifications();

//       emit(
//         state.copyWith(
//           status: NotificationStatus.success,
//           notifications: notifications,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: NotificationStatus.failure,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> _onMarkNotificationRead(
//     MarkNotificationRead event,
//     Emitter<NotificationState> emit,
//   ) async {
//     await markNotificationAsRead(event.notificationId);

//     final updatedNotifications = await repository.getNotifications();

//     emit(
//       state.copyWith(
//         status: NotificationStatus.success,
//         notifications: updatedNotifications,
//       ),
//     );
//   }

//   Future<void> _onMarkAllNotificationsRead(
//     MarkAllNotificationsRead event,
//     Emitter<NotificationState> emit,
//   ) async {
//     await repository.markAllAsRead();

//     final updatedNotifications = await repository.getNotifications();

//     emit(
//       state.copyWith(
//         status: NotificationStatus.success,
//         notifications: updatedNotifications,
//       ),
//     );
//   }
// }
