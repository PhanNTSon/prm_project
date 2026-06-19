import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/core/router/app_router.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';

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
      final storage = SecureStorageService();
      final authProvider = AuthProvider(storage);
      await authProvider.initializeAuth(); // Sẽ gán isInitialized = true, isAuthenticated = false
      final router = AppRouter.createRouter(authProvider);

      // 2. Act: Pump the app with the router
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Chờ router xử lý chuyển hướng
      await tester.pump();
      await tester.pump();

      // 3. Assert: Phải thấy chữ 'Login Page' của LoginPlaceholderScreen
      expect(find.text('Đây là màn hình Đăng nhập (Chưa có UI)'), findsOneWidget);
      
      authProvider.dispose();
    });

    testWidgets('Should go to /home directly when token exists', (WidgetTester tester) async {
      // 1. Arrange: Have fake JWT in storage (must have valid payload for JwtDecoder)
      final storage = SecureStorageService();
      const fakeJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0ZXIiLCJ1c2VySWQiOjEsInJvbGUiOiJTVEFOREFSRCIsImV4cCI6OTk5OTk5OTk5OX0.fakesignature';
      
      await storage.saveAuthData(
        token: fakeJwt,
        userId: '1',
        role: 'STANDARD',
        username: 'tester',
      );

      final authProvider = AuthProvider(storage);
      await authProvider.initializeAuth(); // Sẽ decode fakeJwt -> isAuthenticated = true
      final router = AppRouter.createRouter(authProvider);

      // 2. Act
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // 3. Assert: Phải thấy 'Storefront (Home)' của HomePlaceholderScreen
      expect(find.text('Danh sách Game'), findsOneWidget);
      
      authProvider.dispose();
    });
  });
}
