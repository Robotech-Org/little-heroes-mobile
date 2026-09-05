import '../../domain/entities/auth_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phoneNumber;
  final String message;

  OtpSent({
    required this.phoneNumber,
    required this.message,
  });
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated({
    required this.user,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}