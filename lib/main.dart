import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/network/secure_storage_service.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    // Khởi tạo các Service và Provider cốt lõi
    final secureStorage = SecureStorageService();
    _authProvider = AuthProvider(secureStorage);
    
    // Yêu cầu Provider khôi phục phiên đăng nhập từ Storage
    _authProvider.initializeAuth();

    // Khởi tạo GoRouter với instance của AuthProvider
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        // Thêm các Provider khác tại đây (CartProvider, WalletProvider...)
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
