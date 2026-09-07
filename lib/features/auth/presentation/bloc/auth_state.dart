
import '../../domain/entities/auth_user.dart';

abstract class AuthState {}

// ============================================================
// INITIAL
// ============================================================

class AuthInitial extends AuthState {}

// ============================================================
// LOADING
// ============================================================

class AuthLoading extends AuthState {}

// ============================================================
// UNAUTHENTICATED
// ============================================================

class AuthUnauthenticated extends AuthState {}

// ============================================================
// OTP SENT
// ============================================================

class OtpSent extends AuthState {
  final String phoneNumber;
  final String message;
  final String tmpId;

  OtpSent({
    required this.phoneNumber,
    required this.message,
    required this.tmpId,
  });
}

// ============================================================
// AUTHENTICATED
// ============================================================

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated({required this.user});
}

// ============================================================
// ERROR
// ============================================================

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// ============================================================
// PASSWORD CHANGED - NEW
// ============================================================

class AuthPasswordChanged extends AuthState {}
