

import 'package:little_heroes_mobile/features/auth/data/datasources/auth_remote_data_source.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/otp_response.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OtpResponse> loginWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) {
    return remoteDataSource.loginWithPhoneAndPassword(
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  @override
  Future<AuthUser> verifyOtp({
    required String tmpId,
    required String otp,
    required String phoneNumber,
  }) {
    return remoteDataSource.verifyOtp(
      tmpId: tmpId,
      otp: otp,
      phoneNumber: phoneNumber,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
