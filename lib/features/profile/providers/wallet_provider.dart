import 'package:flutter/foundation.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void updateBalance(double newBalance) {
    if (_balance != newBalance) {
      _balance = newBalance;
      notifyListeners();
    }
  }

  void addBalance(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void clearBalance() {
    _balance = 0.0;
    notifyListeners();
  }
}
