import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:prm_project/features/storefront/home_screen.dart';
import 'main_shell_screen.dart';
import 'placeholder_screens.dart';
import 'splash_screen.dart';

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

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      refreshListenable: authProvider,
      redirect: (context, state) {
        // Logic Auth Guard đồng bộ với AuthProvider
        final bool isInitialized = authProvider.isInitialized;
        final bool isAuthenticated = authProvider.isAuthenticated;
        
        final isAuthRoute = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register' || 
                            state.matchedLocation == '/verify-email';

        // Nếu app chưa khôi phục xong trạng thái từ Local Storage -> Chờ ở Splash
        if (!isInitialized) {
          return '/splash';
        }

        if (!isAuthenticated) {
          // Chưa đăng nhập mà đang ở trang không phải Auth -> đá về Login (giúp thoát khỏi /splash)
          if (!isAuthRoute) {
            return '/login';
          }
        } else {
          // Đã đăng nhập mà vào trang Auth hoặc Splash -> đá về Home
          if (isAuthRoute || state.matchedLocation == '/splash') {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        // Màn hình chờ khởi tạo
        GoRoute(
          path: '/splash',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const SplashPlaceholderScreen(),
        ),

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
}
