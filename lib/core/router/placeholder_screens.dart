import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/secure_storage_service.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đây là màn hình Đăng nhập (Chưa có UI)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final storage = SecureStorageService();
                await storage.saveAuthData(
                  token: 'fake_jwt_token',
                  userId: '1',
                  role: 'STANDARD',
                  username: 'tester',
                );
                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text('Đăng nhập giả lập (Lưu token & Tới Home)'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Chưa có tài khoản? Đăng ký'),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterPlaceholderScreen extends StatelessWidget {
  const RegisterPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đây là màn hình Đăng ký'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/verify-email'),
              child: const Text('Gửi OTP Xác thực'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyEmailPlaceholderScreen extends StatelessWidget {
  const VerifyEmailPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đây là màn hình Nhập OTP'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Xác thực thành công -> Về Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storefront (Home)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Danh sách Game'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/home/game-detail/123'),
              child: const Text('Xem chi tiết Game ID 123'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameDetailPlaceholderScreen extends StatelessWidget {
  final String gameId;
  const GameDetailPlaceholderScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết Game: $gameId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đây là thông tin chi tiết của Game $gameId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPlaceholderScreen extends StatelessWidget {
  const CartPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ Hàng')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Giỏ hàng của bạn'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/payment-webview'),
              child: const Text('Thanh toán bằng VNPay (WebView)'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentWebViewPlaceholder extends StatelessWidget {
  const PaymentWebViewPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cổng Thanh Toán VNPay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hiển thị InAppWebView tại đây...'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Giả lập thanh toán xong -> Đóng WebView'),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryPlaceholderScreen extends StatelessWidget {
  const LibraryPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thư Viện Game')),
      body: const Center(
        child: Text('Danh sách game bạn đã sở hữu'),
      ),
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final storage = SecureStorageService();
              await storage.clearAuthData();
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Thông tin người dùng & Lịch sử giao dịch'),
      ),
    );
  }
}
