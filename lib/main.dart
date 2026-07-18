import 'package:flutter/material.dart';
import 'package:prm_project/features/library/data/repositories/library_repository.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/network/dio_client.dart';
import 'core/network/secure_storage_service.dart';
import 'core/network/websocket_service.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/library_provider.dart';
import 'features/profile/providers/wallet_provider.dart';
import 'features/profile/providers/notification_provider.dart';
import 'features/cart_payment/providers/cart_provider.dart';
import 'features/cart_payment/repositories/cart_repository.dart';
import 'features/cart_payment/providers/payment_provider.dart';
import 'features/cart_payment/repositories/wallet_repository.dart';
import 'features/storefront/data/repositories/game_repository.dart';
import 'features/storefront/providers/game_search_provider.dart';
import 'features/storefront/providers/game_list_provider.dart';
import 'features/storefront/providers/home_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Lỗi load .env (hoặc không tồn tại), dùng giá trị mặc định.");
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  // Realtime Services & Providers
  late final DioClient _dioClient;
  late final WebSocketService _webSocketService;
  late final CartProvider _cartProvider;
  late final WalletProvider _walletProvider;
  late final PaymentProvider _paymentProvider;
  late final NotificationProvider _notificationProvider;
  late final GameSearchProvider _gameSearchProvider;
  late final GameListProvider _gameListProvider;
  late final HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các Service và Provider cốt lõi
    final secureStorage = SecureStorageService();
    _authProvider = AuthProvider(secureStorage);
    _dioClient = DioClient(AppRouter.rootNavigatorKey);
    _cartProvider = CartProvider(CartRepository(_dioClient));
    _paymentProvider = PaymentProvider(WalletRepository(_dioClient));

    _webSocketService = WebSocketService();
    _walletProvider = WalletProvider();
    _notificationProvider = NotificationProvider();

    // Khởi tạo DioClient, Repository và Provider cho Game Search
    final dioClient = DioClient(AppRouter.rootNavigatorKey);
    final gameRepository = GameRepository(dioClient);
    _gameSearchProvider = GameSearchProvider(gameRepository);
    _gameListProvider = GameListProvider(gameRepository);
    _homeProvider = HomeProvider(gameRepository);

    // Lắng nghe trạng thái đăng nhập để bật/tắt WebSocket
    _authProvider.addListener(_onAuthStateChanged);

    // Yêu cầu Provider khôi phục phiên đăng nhập từ Storage
    _authProvider.initializeAuth();

    // Khởi tạo GoRouter với instance của AuthProvider
    _router = AppRouter.createRouter(_authProvider);
  }

  void _onAuthStateChanged() {
    if (_authProvider.isAuthenticated && _authProvider.token != null) {
      if (!_webSocketService.isConnected) {
        _webSocketService.connect(_authProvider.token!);

        // Đăng ký nhận bản tin ví
        _webSocketService.subscribe('/user/queue/wallet.balance', (data) {
          final balance =
              double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
          _walletProvider.updateBalance(balance);
        });

        // Đăng ký nhận thông báo
        _webSocketService.subscribe('/user/queue/notification.unread', (data) {
          final count = int.tryParse(data['count']?.toString() ?? '0') ?? 0;
          _notificationProvider.updateUnreadCount(count);
          if (data['message'] != null) {
            _notificationProvider.addNotification(data['message']);
          }
        });
      }
    } else {
      if (_webSocketService.isConnected) {
        _webSocketService.disconnect();
        _walletProvider.clearBalance();
        _notificationProvider.clearNotifications();
      }
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<WalletProvider>.value(value: _walletProvider),
        ChangeNotifierProvider<CartProvider>.value(value: _cartProvider),
        ChangeNotifierProvider<PaymentProvider>.value(value: _paymentProvider),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: _notificationProvider,
        ),
        ChangeNotifierProvider<GameSearchProvider>.value(
          value: _gameSearchProvider,
        ),
        ChangeNotifierProvider<GameListProvider>.value(
          value: _gameListProvider,
        ),
        ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
        Provider<WebSocketService>.value(value: _webSocketService),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(LibraryRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Steam Clone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
