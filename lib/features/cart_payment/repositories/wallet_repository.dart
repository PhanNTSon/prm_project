import '../../../../core/network/dio_client.dart';
import '../models/wallet_transaction_model.dart';

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
      throw Exception('Failed to load wallet balance: ${e.toString()}');
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
      throw Exception('Failed to load transaction history: ${e.toString()}');
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
      throw Exception('Failed to add balance: ${e.toString()}');
    }
  }

}
