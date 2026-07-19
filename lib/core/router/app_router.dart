import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/cart_payment/screens/cart_screen.dart';
import 'package:prm_project/features/cart_payment/screens/wallet_screen.dart';
import 'package:prm_project/features/cart_payment/screens/payment_webview_screen.dart';
import 'package:prm_project/features/cart_payment/screens/payment_result_screen.dart';
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
import 'package:prm_project/features/auth/views/screens/profile_screen.dart';
import 'package:prm_project/features/auth/views/screens/account_detail_screen.dart';
import 'package:prm_project/features/auth/views/screens/edit_profile_screen.dart';
import 'package:prm_project/features/auth/models/profile_model.dart';
import 'package:prm_project/features/auth/models/register_request_model.dart';
import 'package:prm_project/features/library/views/screens/library.dart';
import 'package:prm_project/features/storefront/views/screens/game_detail_screen.dart';
import 'package:prm_project/features/community/views/screens/chat_list_screen.dart';
import 'package:prm_project/features/community/views/screens/chat_detail_screen.dart';

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
        final bool isInitialized = authProvider.isInitialized;
        final bool isAuthenticated = authProvider.isAuthenticated;
        final String location = state.matchedLocation;

        // Chưa khởi tạo xong → chờ ở splash
        if (!isInitialized) {
          return location == '/splash' ? null : '/splash';
        }

        // Danh sách route công khai không cần đăng nhập
        final isPublicRoute = [
          '/login',
          '/register',
          '/verify-email',
          '/register-details',
          '/forgot-password',
          '/reset-password',
          '/splash',
        ].contains(location);

        // Chưa đăng nhập mà vào route cần auth → đá về login
        if (!isAuthenticated && !isPublicRoute) {
          return '/login';
        }

        // Đã đăng nhập mà vào public route → đá về home
        if (isAuthenticated && isPublicRoute) {
          return '/home';
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
              VerifyEmailScreen(data: state.extra as RegisterRequestModel),
        ),
        GoRoute(
          path: '/register-details',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              RegisterDetailsScreen(data: state.extra as RegisterRequestModel),
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

        GoRoute(
          path: '/account',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AccountDetailScreen(),
        ),
        GoRoute(
          path: '/account/edit',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              EditProfileScreen(profile: state.extra as ProfileModel),
        ),

        // 2. Trang Payment WebView - Fullscreen
        // [Dev C] Nhận paymentUrl qua `extra` khi push('/payment-webview', extra: paymentUrl)
        GoRoute(
          path: '/payment-webview',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final paymentUrl = state.extra as String? ?? '';
            return PaymentWebViewScreen(paymentUrl: paymentUrl);
          },
        ),

        // [Dev C] Trang kết quả thanh toán (mua game / nạp ví) - Fullscreen
        GoRoute(
          path: '/payment-result',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              PaymentResultScreen.fromExtra(state.extra),
        ),

        // [Dev C] Trang ví tiền - Fullscreen (push từ tab Cart hoặc Profile)
        GoRoute(
          path: '/account/wallet',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const WalletScreen(),
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

        // Game Detail - Fullscreen
        GoRoute(
          path: '/game-detail/:id',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return GameDetailScreen(gameId: id);
          },
        ),

        // Chat List & Detail
        GoRoute(
          path: '/chat',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/chat/detail/:username',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final username = state.pathParameters['username'] ?? '';
            return ChatDetailScreen(username: username);
          },
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
                ),
              ],
            ),

            // Tab 1: Giỏ hàng
            StatefulShellBranch(
              navigatorKey: _shellNavigatorCart,
              routes: [
                GoRoute(
                  path: '/cart',
                  builder: (context, state) => const CartScreen(),
                ),
              ],
            ),

            // Tab 2: Thư viện
            StatefulShellBranch(
              navigatorKey: _shellNavigatorLibrary,
              routes: [
                GoRoute(
                  path: '/library',
                  builder: (context, state) => const LibraryScreen(),
                ),
              ],
            ),

            // Tab 3: Cá nhân
            StatefulShellBranch(
              navigatorKey: _shellNavigatorProfile,
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                  routes: [
                    GoRoute(
                      path: ':userId',
                      builder: (context, state) =>
                          ProfileScreen(userId: state.pathParameters['userId']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
