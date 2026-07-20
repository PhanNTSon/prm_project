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
  final String? transactionNo;
  final String? bankCode;
  final String? payDate;

  const PaymentResultScreen({
    super.key,
    required this.type,
    required this.success,
    this.amount,
    this.transactionNo,
    this.bankCode,
    this.payDate,
  });

  /// Factory tiện dụng để app_router build từ `state.extra`.
  factory PaymentResultScreen.fromExtra(Object? extra) {
    final map = (extra is Map) ? extra : const {};
    return PaymentResultScreen(
      type: map['type'] as String? ?? 'purchase',
      success: map['success'] as bool? ?? false,
      amount: (map['amount'] as num?)?.toDouble(),
      transactionNo: map['transactionNo'] as String?,
      bankCode: map['bankCode'] as String?,
      payDate: _formatPayDate(map['payDate'] as String?),
    );
  }

  static String? _formatPayDate(String? raw) {
    if (raw == null || raw.length < 14) return null;
    final y = raw.substring(0, 4);
    final mo = raw.substring(4, 6);
    final d = raw.substring(6, 8);
    final h = raw.substring(8, 10);
    final mi = raw.substring(10, 12);
    final s = raw.substring(12, 14);
    return '$d/$mo/$y $h:$mi:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isTopUp = type == 'topup';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (success ? AppColors.successColor : AppColors.errorColor)
                        .withOpacity(0.15),
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.cancel,
                    color: success ? AppColors.successColor : AppColors.errorColor,
                    size: 56,
                  ),
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
                const SizedBox(height: 8),
                Text(
                  success
                      ? (isTopUp
                          ? 'Your wallet has been topped up successfully.'
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
                if (success && isTopUp) ...[
                  const SizedBox(height: 24),
                  _ReceiptCard(
                    amount: amount,
                    transactionNo: transactionNo,
                    bankCode: bankCode,
                    payDate: payDate,
                  ),
                ],
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

/// Thẻ hoá đơn hiển thị chi tiết giao dịch nạp tiền thành công.
class _ReceiptCard extends StatelessWidget {
  final double? amount;
  final String? transactionNo;
  final String? bankCode;
  final String? payDate;

  const _ReceiptCard({
    this.amount,
    this.transactionNo,
    this.bankCode,
    this.payDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          if (amount != null) ...[
            const Text(
              'Amount Added',
              style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '+\$${amount!.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.successColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 28, color: AppColors.borderColor),
          ],
          if (transactionNo != null)
            _ReceiptRow(label: 'Transaction No.', value: transactionNo!),
          if (bankCode != null) _ReceiptRow(label: 'Bank', value: bankCode!),
          if (payDate != null) _ReceiptRow(label: 'Time', value: payDate!),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
