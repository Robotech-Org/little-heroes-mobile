

import '../../domain/entities/auth_user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

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