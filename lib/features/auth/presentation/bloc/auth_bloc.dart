import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/services/notification_service.dart';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/auth/domain/usecases/change_password.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_event.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/logout.dart'; // Add this import
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithPhoneAndPassword loginWithPhoneAndPassword;
  final VerifyOtp verifyOtp;
  final Logout logout; // Add this

  // Flag to prevent multiple auth checks
  bool _isAuthChecked = false;
  final ChangePassword changePassword; // ADD THIS

  AuthBloc({
    required this.loginWithPhoneAndPassword,
    required this.verifyOtp,
    required this.logout, // Add this parameter
    required this.changePassword,
  }) : super(AuthInitial()) {
    // ==========================================================
    // EVENTS
    // ==========================================================

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested); // ADD THIS

    // Auto-check auth on creation, but only once
    _checkAuthOnStart();
  }

  void _checkAuthOnStart() {
    // Check auth status after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isAuthChecked) {
        add(AuthCheckRequested());
      }
    });
  }

  // ============================================================
  // CHECK SAVED AUTHENTICATION
  // ============================================================

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Prevent multiple checks
    if (_isAuthChecked && state is! AuthInitial) {
      return;
    }

    _isAuthChecked = true;

    try {
      final storage = StorageService.instance;

      // Check login status
      final isLoggedIn = storage.isLoggedIn();

      // User is NOT logged in
      if (!isLoggedIn) {
        emit(AuthUnauthenticated());
        return;
      }

      // Get saved user
      final userData = storage.getUser();

      // Login says true but user data doesn't exist
      if (userData == null) {
        await storage.logout();
        emit(AuthUnauthenticated());
        return;
      }

      // Restore user from local storage
      final user = AuthUser.fromJson(userData);
      NotificationService.registerCurrentDevice();

      // Restore authenticated state
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      // Something failed, clear broken authentication
      await StorageService.instance.logout();
      emit(AuthUnauthenticated());
    }
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
      // Verify OTP from API
      final user = await verifyOtp(
        tmpId: event.tmpId,
        otp: event.otp,
        phoneNumber: event.phoneNumber,
      );

      // ========================================================
      // SAVE AUTHENTICATION LOCALLY
      // ========================================================

      final storage = StorageService.instance;
      await storage.saveUserRole(user.role.name);

      // Save login status
      await storage.setLoggedIn(true);

      // Save onboarding completed
      await storage.setOnboardingCompleted(true);

      // Save user data
      await storage.saveUser(user.toJson());

      // Save user ID
      if (user.fullName != null) {
        await storage.saveUserId(user.fullName!);
      }

      // ========================================================
      // AUTHENTICATED
      // ========================================================

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Call logout API and clear cookies
      await logout();

      // Clear local storage
      await StorageService.instance.logout();

      // Reset auth check flag
      _isAuthChecked = false;

      // Emit unauthenticated state
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if something fails, try to clear local data
      try {
        await StorageService.instance.logout();
        _isAuthChecked = false;
        emit(AuthUnauthenticated());
      } catch (_) {
        emit(AuthError('Failed to logout properly. Please try again.'));
      }
    }
  }

  // ============================================================
  // CHANGE PASSWORD - NEW
  // ============================================================

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Call change password API
      await changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      // Emit password changed state
      emit(AuthPasswordChanged());

      // After successful password change, re-emit authenticated state
      // Get current user from storage
      final userData = StorageService.instance.getUser();
      if (userData != null) {
        final user = AuthUser.fromJson(userData);
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
