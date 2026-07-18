import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  // ── LOGIN dùng username, không phải email ──
  Future<String> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );
      return response.data['token'] as String;
    } catch (e) {
      throw Exception('Tên đăng nhập hoặc mật khẩu không chính xác');
    }
  }

  // ── REGISTER Bước 1: Kiểm tra email available ──
  Future<bool> checkEmailAvailable(String email) async {
    try {
      final response = await _dioClient.get(
        '/api/auth/check-email',
        queryParameters: {'email': email},
      );
      return response.data['available'] as bool;
    } catch (e) {
      throw Exception('Lỗi kiểm tra email');
    }
  }

  // ── REGISTER Bước 2: Gửi OTP ──
  Future<void> sendVerificationOtp(String email) async {
    try {
      await _dioClient.post(
        '/api/auth/send-verification-otp',
        data: {'email': email},
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Gửi OTP thất bại');
    }
  }

  // ── REGISTER Bước 3: Verify OTP ──
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _dioClient.post(
        '/api/auth/verify-otp',
        data: {'email': email, 'otp': otp},
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Mã OTP không hợp lệ hoặc đã hết hạn');
    }
  }

  // ── REGISTER Bước 4: Check username available (realtime) ──
  Future<bool> checkUsernameAvailable(String username) async {
    try {
      final response = await _dioClient.get(
        '/api/auth/check-username',
        queryParameters: {'username': username},
      );
      return response.data['available'] as bool;
    } catch (e) {
      throw Exception('Lỗi kiểm tra tên tài khoản');
    }
  }

  // ── REGISTER Bước 5: Đăng ký tài khoản ──
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String country,
  }) async {
    try {
      await _dioClient.post(
        '/api/auth/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'country': country,
        },
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Đăng ký thất bại');
    }
  }

  // ── FORGOT PASSWORD ──
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        '/api/password/request',
        data: {'email': email},
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Email không tồn tại hoặc gửi yêu cầu thất bại');
    }
  }

  // ── RESET PASSWORD ──
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        '/api/password/reset',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('Đặt lại mật khẩu thất bại');
    }
  }
}