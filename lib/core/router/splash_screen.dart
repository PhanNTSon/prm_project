import 'package:flutter/material.dart';

class SplashPlaceholderScreen extends StatelessWidget {
  const SplashPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Đang kiểm tra trạng thái đăng nhập...'),
          ],
        ),
      ),
    );
  }
}
