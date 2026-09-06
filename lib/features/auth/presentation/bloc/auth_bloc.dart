import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_event.dart';

import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithPhoneAndPassword loginWithPhoneAndPassword;
  final VerifyOtp verifyOtp;

  AuthBloc({required this.loginWithPhoneAndPassword, required this.verifyOtp})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
  }

  // ============================================================
  // LOGIN WITH PHONE + PASSWORD
  // ============================================================

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await loginWithPhoneAndPassword(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );

      if (response.tmpId == null || response.tmpId!.isEmpty) {
        emit(
          AuthError(
            'OTP temporary ID (tmp_id) was not received from the server.',
          ),
        );
        return;
      }

      emit(
        OtpSent(
          phoneNumber: event.phoneNumber,
          message: response.message,
          tmpId: response.tmpId!,
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await verifyOtp(
        tmpId: event.tmpId,
        otp: event.otp,
        phoneNumber: event.phoneNumber,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
