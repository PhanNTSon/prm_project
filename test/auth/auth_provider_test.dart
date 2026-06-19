import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Tests', () {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final Map<String, String> storageMap = {};

    setUp(() {
      storageMap.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'write') {
          storageMap[methodCall.arguments['key']] = methodCall.arguments['value'];
          return null;
        }
        if (methodCall.method == 'read') {
          return storageMap[methodCall.arguments['key']];
        }
        if (methodCall.method == 'delete') {
          storageMap.remove(methodCall.arguments['key']);
          return null;
        }
        if (methodCall.method == 'deleteAll') {
          storageMap.clear();
          return null;
        }
        return null;
      });
    });

    test('loginSuccess should update state and storage', () async {
      final storage = SecureStorageService();
      final authProvider = AuthProvider(storage);
      addTearDown(() => authProvider.dispose());
      
      // Tạo token không hết hạn
      final futureTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payloadStr = jsonEncode({"sub": "tester", "userId": "100", "exp": futureTime});
      final encodedPayload = base64UrlEncode(utf8.encode(payloadStr));
      final fakeToken = 'header.$encodedPayload.signature';

      await authProvider.loginSuccess(fakeToken);

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.username, 'tester');
      expect(authProvider.currentUser?.userId, '100');
      
      // Kiểm tra xem đã lưu storage chưa
      expect(storageMap['jwt_token'], fakeToken);
      expect(storageMap['user_id'], '100');
    });

    test('logout should clear state and storage', () async {
      final storage = SecureStorageService();
      final authProvider = AuthProvider(storage);
      addTearDown(() => authProvider.dispose());
      
      // Giả lập trạng thái đã đăng nhập
      storageMap['jwt_token'] = 'some_token';
      storageMap['user_id'] = '100';
      
      await authProvider.logout();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.token, isNull);
      expect(authProvider.currentUser, isNull);
      
      // Storage bị xóa
      expect(storageMap['jwt_token'], isNull);
      expect(storageMap['user_id'], isNull);
    });
  });
}
