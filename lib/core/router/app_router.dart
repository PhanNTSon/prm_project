import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:prm_project/features/storefront/home_screen.dart';
import 'package:prm_project/features/storefront/views/screens/game_search_screen.dart';
import 'package:prm_project/features/storefront/views/screens/all_games_screen.dart';
import 'main_shell_screen.dart';
import 'placeholder_screens.dart';
import 'splash_screen.dart';
import 'package:prm_project/features/auth/views/screens/login_screen.dart';
import 'package:prm_project/features/auth/views/screens/register_screen.dart';
import 'package:prm_project/features/auth/views/screens/verify_email_screen.dart';
import 'package:prm_project/features/auth/views/screens/register_details_screen.dart';
import 'package:prm_project/features/auth/views/screens/forgot_password_screen.dart';
import 'package:prm_project/features/auth/views/screens/reset_password_screen.dart';

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

        final isAuthRoute =
            state.matchedLocation == '/login' ||
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
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              VerifyEmailScreen(email: state.extra as String),
        ),
        GoRoute(
          path: '/register-details',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              RegisterDetailsScreen(email: state.extra as String),
        ),
        GoRoute(
          path: '/forgot-password',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              ResetPasswordScreen(email: state.extra as String),
        ),

        // 2. Trang Payment WebView - Fullscreen
        GoRoute(
          path: '/payment-webview',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const PaymentWebViewPlaceholder(),
        ),

        // 3. Tìm kiếm Game - Fullscreen (không hiện Bottom Navigation)
        GoRoute(
          path: '/search',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const GameSearchScreen(),
        ),

        // 4. Tất cả Game - Fullscreen (không hiện Bottom Navigation)
        GoRoute(
          path: '/all-games',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AllGamesScreen(),
        ),

        // 5. Shell Layout chứa Bottom Navigation Bar
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
