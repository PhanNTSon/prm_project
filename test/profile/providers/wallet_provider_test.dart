import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/features/profile/providers/wallet_provider.dart';

void main() {
  group('WalletProvider Tests', () {
    late WalletProvider walletProvider;

    setUp(() {
      walletProvider = WalletProvider();
    });

    test('Initial balance should be 0.0', () {
      expect(walletProvider.balance, 0.0);
    });

    test('updateBalance should set correct balance', () {
      walletProvider.updateBalance(150.5);
      expect(walletProvider.balance, 150.5);
    });

    test('addBalance should increment balance correctly', () {
      walletProvider.updateBalance(50.0);
      walletProvider.addBalance(20.5);
      expect(walletProvider.balance, 70.5);
    });

    test('clearBalance should reset balance to 0.0', () {
      walletProvider.updateBalance(100.0);
      walletProvider.clearBalance();
      expect(walletProvider.balance, 0.0);
    });
  });
}
