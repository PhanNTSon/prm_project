import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorageService;
  
  String? _token;
  UserModel? _currentUser;
  bool _isInitialized = false;
  Timer? _tokenExpiryTimer;

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

    final expirationDate = JwtDecoder.getExpirationDate(currentToken);
    if (expirationDate == null) return;

    // Chạy kiểm tra mỗi 30 giây
    _tokenExpiryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (DateTime.now().isAfter(expirationDate)) {
        debugPrint("Token đã hết hạn, tiến hành đăng xuất tự động.");
        timer.cancel();
        logout();
      }
    });
  }

  @override
  void dispose() {
    _tokenExpiryTimer?.cancel();
    super.dispose();
  }
}
