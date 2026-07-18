import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Màn hình fullscreen mở paymentUrl (VNPay) trong InAppWebView.
///
/// BE hiện tại là bản "simulated bypass": paymentUrl trả về từ
/// `POST /api/v1/payments/create-vnpay-payment` đã là URL kết quả cuối
/// cùng (chứa sẵn `vnp_ResponseCode`), trỏ về `http://localhost:5173/...`
/// (domain của FE React cũ, không tồn tại/không load được trên thiết bị
/// thật hay emulator). Vì vậy màn này CHỦ ĐỘNG chặn navigation ngay khi
/// phát hiện URL có `vnp_ResponseCode` trong query, thay vì chờ WebView
/// load trang đó (sẽ chỉ ra lỗi "không kết nối được").
///
/// Khi phát hiện, sẽ `pop` màn hình này và trả về Map:
/// `{ success: bool, responseCode, transactionNo, bankCode, payDate, amountVnd }`
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  bool _isLoading = true;
  bool _resultHandled = false;

  /// URL được coi là "URL kết quả" nếu chứa query param vnp_ResponseCode,
  /// hoặc path chứa 'payment-result' / 'vnpay-ipn'.
  bool _isReturnUrl(Uri uri) {
    return uri.queryParameters.containsKey('vnp_ResponseCode') ||
        uri.path.contains('payment-result') ||
        uri.path.contains('vnpay-ipn');
  }

  void _handleReturnUrl(Uri uri) {
    if (_resultHandled) return;
    _resultHandled = true;

    final params = uri.queryParameters;
    final responseCode = params['vnp_ResponseCode'];
    final success = responseCode == '00';

    if (context.mounted) {
      context.pop<Map<String, dynamic>>({
        'success': success,
        'responseCode': responseCode,
        'transactionNo': params['vnp_TransactionNo'],
        'bankCode': params['vnp_BankCode'],
        'payDate': params['vnp_PayDate'],
        'amountVnd': params['vnp_Amount'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        title: const Text(
          'VNPay Payment Gateway',
          style: TextStyle(color: AppColors.primaryTextColor, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryTextColor),
          onPressed: () => context.pop<Map<String, dynamic>>(null),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              javaScriptEnabled: true,
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null && _isReturnUrl(uri)) {
                _handleReturnUrl(uri);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStart: (controller, url) {
              // Lớp bảo hiểm thứ 2: một số bản Android không gọi
              // shouldOverrideUrlLoading cho navigation đầu tiên.
              if (url != null && _isReturnUrl(url)) {
                controller.stopLoading();
                _handleReturnUrl(url);
              }
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onLoadError: (controller, url, code, message) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
        ],
      ),
    );
  }
}
