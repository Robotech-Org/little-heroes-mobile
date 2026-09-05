import '../../domain/entities/otp_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthMockDataSource mockDataSource;

  AuthRepositoryImpl({required this.mockDataSource});

  @override
  Future<OtpResponse> sendOtp({required String phoneNumber}) {
    return mockDataSource.sendOtp(phoneNumber: phoneNumber);
  }
}
