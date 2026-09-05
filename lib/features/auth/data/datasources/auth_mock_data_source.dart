import '../models/otp_response_model.dart';

abstract class AuthMockDataSource {
  Future<OtpResponseModel> sendOtp({required String phoneNumber});
}

class AuthMockDataSourceImpl implements AuthMockDataSource {
  @override
  Future<OtpResponseModel> sendOtp({required String phoneNumber}) async {
    print('📱 MOCK OTP REQUEST: $phoneNumber');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Test phone numbers
    final testNumbers = ['+251911111111', '+251922222222', '+251933333333'];

    if (testNumbers.contains(phoneNumber)) {
      print('✅ MOCK OTP SENT SUCCESSFULLY');

      return OtpResponseModel(
        success: true,
        message: 'OTP sent successfully. Test OTP: 123456',
        phoneNumber: phoneNumber,
      );
    }

    print('❌ MOCK OTP FAILED');

    return OtpResponseModel(
      success: false,
      message: 'Mock login failed. Please use +251911111111 for testing.',
      phoneNumber: phoneNumber,
    );
  }
}
