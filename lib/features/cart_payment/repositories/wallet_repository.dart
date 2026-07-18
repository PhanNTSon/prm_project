import '../../../../core/network/dio_client.dart';
import '../models/wallet_transaction_model.dart';
import 'api_error_util.dart';
class WalletRepository {
  final DioClient _dioClient;
  WalletRepository(this._dioClient);

  /// GET /user/wallet
  /// BE trả về TRỰC TIẾP 1 số (BigDecimal), không bọc {success, data}.
  Future<double> getBalance() async {
    try {
      final response = await _dioClient.get('/user/wallet');
      return (response.data as num).toDouble();
    } catch (e) {
      throw Exception('Failed to load wallet balance: ${extractErrorMessage(e)}');
    }
  }

  /// GET /user/transaction -> { success, data: [...] }
  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final response = await _dioClient.get('/user/transaction');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) =>
                WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load transaction history: ${extractErrorMessage(e)}');
    }
  }

  /// POST /user/wallet/add?amount=
  /// Bước "chốt sổ" cộng tiền thật vào ví sau khi WebView VNPay báo thành
  /// công (IPN phía BE hiện chưa tự cộng ví). Trả về số dư mới nhất.
  Future<double> addBalance(double amountUsd) async {
    try {
      final response = await _dioClient.post(
        '/user/wallet/add',
        queryParameters: {'amount': amountUsd},
      );
      return (response.data as num).toDouble();
    } catch (e) {
      throw Exception('Failed to add balance: ${extractErrorMessage(e)}');
    }
  }

  /// POST /api/v1/payments/create-vnpay-payment?amount=&bankCode=&language=
  /// Trả về paymentUrl để mở trong InAppWebView.
  ///
  /// Lưu ý: BE hiện là bản "simulated bypass" — paymentUrl trả về đã chứa
  /// sẵn vnp_ResponseCode=00, trỏ thẳng về return URL, KHÔNG thật sự đi qua
  /// cổng VNPay sandbox.
  Future<String> createVnpayPayment({
    required double amountUsd,
    String? bankCode,
    String language = 'vn',
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/payments/create-vnpay-payment',
        queryParameters: {
          'amount': amountUsd,
          if (bankCode != null && bankCode.isNotEmpty) 'bankCode': bankCode,
          'language': language,
        },
      );
      final data = response.data;
      final url = data is Map ? data['paymentUrl'] as String? : null;
      if (url == null || url.isEmpty) {
        throw Exception('BE không trả về paymentUrl hợp lệ');
      }
      return url;
    } catch (e) {
      throw Exception('Failed to create VNPay payment: ${extractErrorMessage(e)}');
    }
  }
}
