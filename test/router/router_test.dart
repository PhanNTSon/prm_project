import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/core/router/app_router.dart';
import 'package:prm_project/core/network/secure_storage_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoRouter Auth Guard Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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
      
      // Thiết lập màn hình đủ rộng để tránh lỗi tràn giao diện (overflow) của Appbar
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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

      // 3. Assert: Phải thấy 'Steam Store' của HomeScreen thực tế
      expect(find.text('Steam Store'), findsOneWidget);
      
      authProvider.dispose();
    });
  });
}
