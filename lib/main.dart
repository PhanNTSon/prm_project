import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/network/secure_storage_service.dart';
import 'core/network/websocket_service.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/wallet_provider.dart';
import 'features/profile/providers/notification_provider.dart';

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
  late final WebSocketService _webSocketService;
  late final WalletProvider _walletProvider;
  late final NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các Service và Provider cốt lõi
    final secureStorage = SecureStorageService();
    _authProvider = AuthProvider(secureStorage);
    
    _webSocketService = WebSocketService();
    _walletProvider = WalletProvider();
    _notificationProvider = NotificationProvider();

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
          final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
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
        ChangeNotifierProvider<NotificationProvider>.value(value: _notificationProvider),
        Provider<WebSocketService>.value(value: _webSocketService),
      ],
      child: MaterialApp.router(
        title: 'Steam Clone',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1B2838), // Nền xanh sẫm Steam
        ),
        routerConfig: _router,
      ),
    );
  }
}
