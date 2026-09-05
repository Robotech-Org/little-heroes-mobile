abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phoneNumber;
  final String message;

  OtpSent({required this.phoneNumber, required this.message});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
