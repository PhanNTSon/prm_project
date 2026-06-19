import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/storefront/home_screen.dart';
import '../network/secure_storage_service.dart';
import 'main_shell_screen.dart';
import 'placeholder_screens.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellNavigatorCart =
      GlobalKey<NavigatorState>(debugLabel: 'shellCart');
  static final GlobalKey<NavigatorState> _shellNavigatorLibrary =
      GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');
  static final GlobalKey<NavigatorState> _shellNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) async {
      // Logic Auth Guard: Kiểm tra đăng nhập
      final secureStorage = SecureStorageService();
      final token = await secureStorage.getToken();

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email';

      if (token == null || token.isEmpty) {
        // Chưa đăng nhập mà vào trang không phải Auth -> đá về Login
        if (!isAuthRoute) {
          return '/login';
        }
      } else {
        // Đã đăng nhập mà vào trang Auth -> đá về Home
        if (isAuthRoute) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      // 1. Các trang xác thực (Auth) - Nằm ngoài Bottom Navigation
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginPlaceholderScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterPlaceholderScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VerifyEmailPlaceholderScreen(),
      ),

      // 2. Trang Payment WebView - Fullscreen
      GoRoute(
        path: '/payment-webview',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PaymentWebViewPlaceholder(),
      ),

      // 3. Shell Layout chứa Bottom Navigation Bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Cửa hàng
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // Sub-route Chi tiết game (Vẫn giữ Bottom Navigation)
                  GoRoute(
                    path: 'game-detail/:id',
                    // Không dùng rootNavigatorKey ở đây để giữ lại BottomNavigationBar
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return GameDetailPlaceholderScreen(gameId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 1: Giỏ hàng
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCart,
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPlaceholderScreen(),
              ),
            ],
          ),

          // Tab 2: Thư viện
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLibrary,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryPlaceholderScreen(),
              ),
            ],
          ),

          // Tab 3: Cá nhân
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
