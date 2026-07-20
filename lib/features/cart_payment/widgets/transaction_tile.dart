import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/wallet_transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatUsd(double? amount) {
    if (amount == null) return '--';
    return '\$${amount.toStringAsFixed(2)}';
  }

  bool get _isCredit =>
      transaction.isTopUp || transaction.type.toLowerCase() == 'add';

  @override
  Widget build(BuildContext context) {
    final title = transaction.isTopUp
        ? 'Top up wallet'
        : (transaction.gameName ?? 'Game purchase');
    final amountText = transaction.price == null
        ? (transaction.isTopUp ? 'Amount unavailable' : '--')
        : '${_isCredit ? '+' : '-'}${_formatUsd(transaction.price)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              transaction.isTopUp
                  ? Icons.account_balance_wallet_outlined
                  : Icons.videogame_asset_outlined,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.dateCreated),
                  style: const TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              color: transaction.price == null
                  ? AppColors.secondaryTextColor
                  : (_isCredit ? AppColors.successColor : AppColors.errorColor),
              fontWeight: transaction.price == null
                  ? FontWeight.normal
                  : FontWeight.bold,
              fontSize: transaction.price == null ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}