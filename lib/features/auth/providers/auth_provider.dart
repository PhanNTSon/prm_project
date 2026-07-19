import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorageService;

  String? _token;
  UserModel? _currentUser;
  bool _isInitialized = false;
  Timer? _tokenExpiryTimer;
  bool _hasShownExpiryWarning = false;

  // Cảnh báo trước khi phiên hết hạn bao lâu
  static const Duration _expiryWarningThreshold = Duration(minutes: 2);

  AuthProvider(this._secureStorageService);

  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo trạng thái Auth từ Local Storage
  Future<void> initializeAuth() async {
    try {
      final storedToken = await _secureStorageService.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        if (!JwtDecoder.isExpired(storedToken)) {
          final payload = JwtDecoder.decode(storedToken);
          _currentUser = UserModel.fromJson(payload);
          _token = storedToken;
          _startTokenExpiryTimer(storedToken);
        } else {
          // Token hết hạn thì dọn dẹp
          await _secureStorageService.clearAuthData();
        }
      }
    } catch (e) {
      // Nếu có bất kỳ lỗi nào trong quá trình khôi phục, fallback về chưa đăng nhập
      debugPrint("Lỗi khởi tạo Auth: $e");
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Gọi khi đăng nhập thành công
  Future<void> loginSuccess(String jwtToken) async {
    try {
      final payload = JwtDecoder.decode(jwtToken);
      _currentUser = UserModel.fromJson(payload);
      _token = jwtToken;

      await _secureStorageService.saveAuthData(
        token: jwtToken,
        userId: _currentUser!.userId,
        role: _currentUser!.role,
        username: _currentUser!.username,
      );

      _startTokenExpiryTimer(jwtToken);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi loginSuccess: $e");
      throw Exception("Không thể xử lý token đăng nhập.");
    }
  }

  /// Đăng xuất khỏi ứng dụng
  Future<void> logout() async {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;

    _token = null;
    _currentUser = null;

    await _secureStorageService.clearAuthData();

    notifyListeners();
  }

  /// Kích hoạt bộ đếm thời gian kiểm tra token hết hạn
  void _startTokenExpiryTimer(String currentToken) {
    _tokenExpiryTimer?.cancel();
    _hasShownExpiryWarning = false;

    final expirationDate = JwtDecoder.getExpirationDate(currentToken);
    if (expirationDate == null) return;

    // Chạy kiểm tra mỗi 30 giây
    _tokenExpiryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (now.isAfter(expirationDate)) {
        debugPrint("Token đã hết hạn, tiến hành đăng xuất tự động.");
        timer.cancel();
        logout();
        return;
      }

      final remaining = expirationDate.difference(now);
      if (!_hasShownExpiryWarning && remaining <= _expiryWarningThreshold) {
        _hasShownExpiryWarning = true;
        _showSessionExpiryWarning(remaining);
      }
    });
  }

  /// Hiện thông báo cảnh báo phiên đăng nhập sắp hết hạn
  void _showSessionExpiryWarning(Duration remaining) {
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    final minutes = remaining.inMinutes.clamp(1, 999);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Phiên đăng nhập của bạn sắp hết hạn (còn khoảng $minutes phút). '
          'Vui lòng lưu công việc và đăng nhập lại nếu cần.',
        ),
        backgroundColor: AppColors.warningColor,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  void dispose() {
    _tokenExpiryTimer?.cancel();
    super.dispose();
  }
}
