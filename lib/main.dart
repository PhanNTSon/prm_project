import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Steam Clone',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B2838), // Nền xanh sẫm Steam
      ),
      routerConfig: AppRouter.router,
    );
  }
}
