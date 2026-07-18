import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Màn hình kết quả thanh toán - dùng chung cho 2 luồng:
/// - `type: 'purchase'` — sau khi mua game thành công từ giỏ hàng
/// - `type: 'topup'`    — sau khi nạp tiền qua VNPay (thành công hoặc thất bại)
///
/// Nhận dữ liệu qua `state.extra` (Map) khi push route `/payment-result`.
class PaymentResultScreen extends StatelessWidget {
  final String type;
  final bool success;
  final double? amount;

  const PaymentResultScreen({
    super.key,
    required this.type,
    required this.success,
    this.amount,
  });

  /// Factory tiện dụng để app_router build từ `state.extra`.
  factory PaymentResultScreen.fromExtra(Object? extra) {
    final map = (extra is Map) ? extra : const {};
    return PaymentResultScreen(
      type: map['type'] as String? ?? 'purchase',
      success: map['success'] as bool? ?? false,
      amount: (map['amount'] as num?)?.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTopUp = type == 'topup';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.cancel,
                  color: success ? AppColors.successColor : AppColors.errorColor,
                  size: 88,
                ),
                const SizedBox(height: 20),
                Text(
                  success
                      ? (isTopUp ? 'Top-up Successful' : 'Purchase Successful')
                      : (isTopUp ? 'Top-up Failed' : 'Purchase Failed'),
                  style: const TextStyle(
                    color: AppColors.primaryTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  success
                      ? (isTopUp
                          ? 'Your wallet has been topped up${amount != null ? ' with \$${amount!.toStringAsFixed(2)}' : ''}.'
                          : 'Your games have been added to your library.')
                      : (isTopUp
                          ? 'We could not complete your top-up. Please try again.'
                          : 'Something went wrong while processing your purchase.'),
                  style: const TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isTopUp) {
                        context.go('/account/wallet');
                      } else if (success) {
                        context.go('/library');
                      } else {
                        context.go('/cart');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isTopUp
                          ? 'Back to Wallet'
                          : (success ? 'Go to Library' : 'Back to Cart'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
