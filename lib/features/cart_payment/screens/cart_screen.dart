import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/features/profile/providers/wallet_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  String _formatVnd(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write('.');
    }
    return '$buf ₫';
  }

  Future<void> _onPurchase() async {
    final provider = context.read<CartProvider>();
    final result = await provider.checkout();

    if (!context.mounted) return;

    switch (result) {
      case CheckoutResult.success:
        context.go('/payment-result');
        break;
      case CheckoutResult.insufficientBalance:
        _showInsufficientBalanceDialog();
        break;
      case CheckoutResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Checkout failed'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        break;
    }
  }

  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: const Text(
          'Insufficient Balance',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          "You don't have enough balance to complete this purchase. "
          'Would you like to top up your wallet?',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.go('/account/wallet');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final walletBalance = context.watch<WalletProvider>().balance;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store  >  Your Cart',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 11,
              ),
            ),
            const Text(
              'Your Cart',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
              ? const _EmptyCart()
              : _CartContent(
                  provider: provider,
                  formatVnd: _formatVnd,
                  walletBalance: walletBalance,
                  onRemove: (gameId) => provider.removeItem(gameId),
                  onPurchase: _onPurchase,
                ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/store'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

// ── Cart content ─────────────────────────────────────────────────────────────

class _CartContent extends StatelessWidget {
  final CartProvider provider;
  final String Function(double) formatVnd;
  final double walletBalance;
  final void Function(int) onRemove;
  final VoidCallback onPurchase;

  const _CartContent({
    required this.provider,
    required this.formatVnd,
    required this.walletBalance,
    required this.onRemove,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.items.length,
            itemBuilder: (_, index) {
              final item = provider.items[index];
              return CartItemTile(
                item: item,
                onRemove: () => onRemove(item.gameId),
              );
            },
          ),
        ),
        _CartSummaryBar(
          totalPrice: formatVnd(provider.totalPrice),
          walletBalance: formatVnd(walletBalance),
          isEnough: walletBalance >= provider.totalPrice,
          isLoading: provider.isCheckingOut,
          onContinueShopping: () => context.go('/store'),
          onPurchase: onPurchase,
        ),
      ],
    );
  }
}

// ── Summary bar ──────────────────────────────────────────────────────────────

class _CartSummaryBar extends StatelessWidget {
  final String totalPrice;
  final String walletBalance;
  final bool isEnough;
  final bool isLoading;
  final VoidCallback onContinueShopping;
  final VoidCallback onPurchase;

  const _CartSummaryBar({
    required this.totalPrice,
    required this.walletBalance,
    required this.isEnough,
    required this.isLoading,
    required this.onContinueShopping,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Số dư ví
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet balance',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
              Text(
                walletBalance,
                style: TextStyle(
                  color: isEnough
                      ? AppColors.successColor
                      : AppColors.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated total',
                style: TextStyle(color: AppColors.secondaryTextColor),
              ),
              Text(
                totalPrice,
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!isEnough) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: AppColors.warningColor),
                SizedBox(width: 4),
                Text(
                  'Insufficient balance',
                  style: TextStyle(
                      color: AppColors.warningColor, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onContinueShopping,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderColor),
                    foregroundColor: AppColors.primaryTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Continue Shopping'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                          'Purchase',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}