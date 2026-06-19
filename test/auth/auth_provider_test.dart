import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loginSuccess should update state and storage', () async {
      final storage = SecureStorageService();
      final authProvider = AuthProvider(storage);
      addTearDown(() => authProvider.dispose());
      
      // Tạo token không hết hạn
      final futureTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payloadStr = jsonEncode({"sub": "tester", "userId": "100", "role": "STANDARD", "exp": futureTime});
      final encodedPayload = base64UrlEncode(utf8.encode(payloadStr));
      final fakeToken = 'header.$encodedPayload.signature';

      await authProvider.loginSuccess(fakeToken);

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.username, 'tester');
      expect(authProvider.currentUser?.userId, '100');
      
      // Kiểm tra xem đã lưu storage chưa thông qua service
      expect(await storage.getToken(), fakeToken);
      expect(await storage.getUserId(), '100');
    });

    test('logout should clear state and storage', () async {
      final storage = SecureStorageService();
      final authProvider = AuthProvider(storage);
      addTearDown(() => authProvider.dispose());
      
      // Giả lập trạng thái đã đăng nhập
      await storage.saveAuthData(
        token: 'some_token',
        userId: '100',
        role: 'STANDARD',
        username: 'tester',
      );
      
      await authProvider.logout();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.token, isNull);
      expect(authProvider.currentUser, isNull);
      
      // Storage bị xóa
      expect(await storage.getToken(), isNull);
      expect(await storage.getUserId(), isNull);
    });
  });
}
