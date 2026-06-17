import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/core/router/app_router.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoRouter Auth Guard Tests', () {
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

    testWidgets('Should redirect to /login when no token and accessing /home', (WidgetTester tester) async {
      // 1. Arrange: No token in storage

      // 2. Act: Pump the app with the router
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );
      
      // Chờ router xử lý chuyển hướng (await cho future của redirect)
      await tester.pumpAndSettle();

      // 3. Assert: Phải thấy chữ 'Login Page' của LoginPlaceholderScreen
      expect(find.text('Đây là màn hình Đăng nhập (Chưa có UI)'), findsOneWidget);
    });

    testWidgets('Should go to /home directly when token exists', (WidgetTester tester) async {
      // 1. Arrange: Have token in storage
      final storage = SecureStorageService();
      await storage.saveAuthData(
        token: 'valid_token',
        userId: '1',
        role: 'STANDARD',
        username: 'test_user',
      );

      // Force router refresh or recreate router?
      // Since AppRouter is static and initial location is /home, it will evaluate redirect again.
      AppRouter.router.go('/home');

      // 2. Act
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );
      await tester.pumpAndSettle();

      // 3. Assert: Phải thấy 'Storefront (Home)' của HomePlaceholderScreen
      expect(find.text('Danh sách Game'), findsOneWidget);
    });
  });
}
