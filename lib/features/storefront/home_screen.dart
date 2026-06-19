import 'package:flutter/material.dart';
import 'package:prm_project/features/storefront/home_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      body: Column(
        children: [
          const HomeAppbar(currentPage: 'store'),

          Expanded(
            child: Center(
              child: Text(
                "Steam Store",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
