import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;

  AuthBloc({required this.sendOtp}) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final response = await sendOtp(phoneNumber: event.phoneNumber);

      if (response.success) {
        emit(
          OtpSent(phoneNumber: response.phoneNumber, message: response.message),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
