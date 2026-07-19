import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  bool _isProcessing = false;

  late final Uri _uri = Uri.tryParse(widget.paymentUrl) ?? Uri();
  late final Map<String, String> _params = _uri.queryParameters;

  String get _amountVnd {
    final raw = _params['vnp_Amount'];
    if (raw == null) return '--';
    final value = int.tryParse(raw);
    if (value == null) return raw;
    // vnp_Amount VNPay quy ước = số tiền thật x 100
    final real = value / 100;
    final s = real.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write('.');
    }
    return '$buf VND';
  }

  String get _transactionNo => _params['vnp_TransactionNo'] ?? '--';
  String get _bankCode => _params['vnp_BankCode'] ?? 'NCB';

  String get _payDate {
    final raw = _params['vnp_PayDate'];
    if (raw == null || raw.length < 14) return '--';
    // format yyyyMMddHHmmss -> dd/MM/yyyy HH:mm:ss
    final y = raw.substring(0, 4);
    final mo = raw.substring(4, 6);
    final d = raw.substring(6, 8);
    final h = raw.substring(8, 10);
    final mi = raw.substring(10, 12);
    final s = raw.substring(12, 14);
    return '$d/$mo/$y $h:$mi:$s';
  }

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    // Mô phỏng độ trễ xử lý giao dịch cho có cảm giác thật
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    context.pop<Map<String, dynamic>>({
      'success': true,
      'responseCode': '00',
      'transactionNo': _transactionNo,
      'bankCode': _bankCode,
      'payDate': _params['vnp_PayDate'],
      'amountVnd': _params['vnp_Amount'],
    });
  }

  void _cancelPayment() {
    context.pop<Map<String, dynamic>>({
      'success': false,
      'responseCode': '24', // Mã VNPay chuẩn cho "Khách hàng hủy giao dịch"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF1), // nền trắng xám kiểu VNPay
      appBar: AppBar(
        backgroundColor: const Color(0xFF005BAA), // xanh VNPay
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.account_balance, size: 20),
            const SizedBox(width: 8),
            const Text(
              'VNPAY Sandbox',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isProcessing ? null : _cancelPayment,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF005BAA),
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Xác nhận thanh toán',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cổng thanh toán VNPAY (môi trường Sandbox)',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const Divider(height: 28),
                      _InfoRow(label: 'Số tiền', value: _amountVnd, emphasize: true),
                      _InfoRow(label: 'Ngân hàng', value: _bankCode),
                      _InfoRow(label: 'Mã giao dịch', value: _transactionNo),
                      _InfoRow(label: 'Thời gian', value: _payDate),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005BAA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác nhận thanh toán',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isProcessing ? null : _cancelPayment,
                  child: const Text(
                    'Hủy giao dịch',
                    style: TextStyle(color: Colors.black54),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? const Color(0xFF005BAA) : const Color(0xFF1A1A1A),
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
              fontSize: emphasize ? 17 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
