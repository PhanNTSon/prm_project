import '../../../core/network/dio_client.dart';
import '../models/register_request_model.dart';
import '../models/verify_otp_model.dart';
import '../models/register_details_model.dart';
import '../models/forgot_password_model.dart';
import '../models/reset_password_model.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data['token'] as String;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> register(String email, String country) async {
    try {
      await _dioClient.post(
        '/api/auth/register',
        data: RegisterRequestModel(email: email, country: country).toJson(),
      );
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _dioClient.post(
        '/api/auth/verify-email',
        data: VerifyOtpModel(email: email, otp: otp).toJson(),
      );
    } catch (e) {
      throw Exception('Xác thực OTP thất bại: ${e.toString()}');
    }
  }

  Future<void> registerDetails(
    String email,
    String username,
    String password,
  ) async {
    try {
      await _dioClient.post(
        '/api/auth/register-details',
        data: RegisterDetailsModel(
          email: email,
          username: username,
          password: password,
        ).toJson(),
      );
    } catch (e) {
      throw Exception('Thiết lập tài khoản thất bại: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        '/api/auth/forgot-password',
        data: ForgotPasswordModel(email: email).toJson(),
      );
    } catch (e) {
      throw Exception('Gửi yêu cầu thất bại: ${e.toString()}');
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _dioClient.post(
        '/api/auth/reset-password',
        data: ResetPasswordModel(
          email: email,
          otp: otp,
          newPassword: newPassword,
        ).toJson(),
      );
    } catch (e) {
      throw Exception('Đặt lại mật khẩu thất bại: ${e.toString()}');
    }
  }
}
