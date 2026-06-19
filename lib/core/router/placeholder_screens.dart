import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

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
                // Tạo một token JWT giả định hợp lệ
                const fakeJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0ZXIiLCJ1c2VySWQiOjEsInJvbGUiOiJTVEFOREFSRCIsImV4cCI6OTk5OTk5OTk5OX0.fakesignature';
                try {
                  await context.read<AuthProvider>().loginSuccess(fakeJwt);
                  // Không cần gọi context.go('/home') vì AuthProvider notifyListeners -> Router tự động redirect!
                } catch (e) {
                  debugPrint('Login error: $e');
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
  const RegisterPlaceholderScreen({super.key});

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
  const VerifyEmailPlaceholderScreen({super.key});

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
  const HomePlaceholderScreen({super.key});

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
  const GameDetailPlaceholderScreen({super.key, required this.gameId});

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
  const CartPlaceholderScreen({super.key});

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
  const PaymentWebViewPlaceholder({super.key});

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
  const LibraryPlaceholderScreen({super.key});

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
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              // Router sẽ tự động văng ra login do redirect lắng nghe sự thay đổi của AuthProvider
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
