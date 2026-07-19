import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/features/profile/providers/wallet_provider.dart'
    as global_wallet;

import '../../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';
import '../widgets/transaction_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PaymentProvider>();
      provider.loadBalance();
      provider.loadTransactions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onTopUp() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final provider = context.read<PaymentProvider>();
    final paymentUrl = await provider.requestTopUp(amount);

    if (!mounted) return;

    if (paymentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create payment'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    // Mở WebView VNPay, chờ kết quả trả về qua pop({success, responseCode})
    final result = await context.push<Map<String, dynamic>>(
      '/payment-webview',
      extra: paymentUrl,
    );

    if (!mounted) return;

    final success = result != null && result['success'] == true;
    if (success) {
      final confirmed = await provider.confirmTopUp(amount);
      if (!mounted) return;
      if (confirmed) {
        // Đồng bộ số dư sang WalletProvider toàn cục để các màn khác
        // (Cart, Profile...) cũng cập nhật realtime mà không cần sửa file đó.
        context.read<global_wallet.WalletProvider>().updateBalance(provider.balance);
        provider.loadTransactions();
      }
      if (!mounted) return;
      context.push('/payment-result', extra: {
        'type': 'topup',
        'success': confirmed,
        'amount': amount,
        'transactionNo': result['transactionNo'],
        'bankCode': result['bankCode'],
        'payDate': result['payDate'],
      });
    } else if (result != null) {
      // Người dùng đóng WebView hoặc thanh toán thất bại
      context.push('/payment-result', extra: {
        'type': 'topup',
        'success': false,
        'amount': amount,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        title: const Text(
          'Wallet',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadBalance();
          await provider.loadTransactions();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceCard(
              balance: provider.balance,
              isLoading: provider.isLoading,
            ),
            const SizedBox(height: 20),
            _TopUpForm(
              controller: _amountController,
              isLoading: provider.isTopUpLoading,
              onTopUp: _onTopUp,
            ),
            const SizedBox(height: 24),
            const Text(
              'Transaction History',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (provider.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                ),
              )
            else
              ...provider.transactions.map(
                (t) => TransactionTile(transaction: t),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final bool isLoading;

  const _BalanceCard({required this.balance, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceColor, AppColors.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Wallet Balance',
                  style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                isLoading
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primaryColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopUpForm extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onTopUp;

  const _TopUpForm({
    required this.controller,
    required this.isLoading,
    required this.onTopUp,
  });

  static const _quickAmounts = [5, 10, 20, 50];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top up via VNPay',
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.primaryTextColor),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(color: AppColors.primaryTextColor),
              filled: true,
              fillColor: AppColors.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              hintText: 'Enter amount (USD)',
              hintStyle: const TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _quickAmounts.map((amount) {
              return OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () => controller.text = amount.toString(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderColor),
                  foregroundColor: AppColors.primaryTextColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text('\$$amount'),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.backgroundColor,
                      ),
                    )
                  : const Text(
                      'Top up with VNPay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
