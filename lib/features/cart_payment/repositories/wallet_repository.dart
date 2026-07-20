import '../../../../core/network/dio_client.dart';
import '../models/wallet_transaction_model.dart';
import 'api_error_util.dart';
import 'topup_amount_cache.dart';
import 'topup_notification_sync.dart';

class WalletRepository {
  final DioClient _dioClient;
  final TopUpNotificationSync _notifSync;
  WalletRepository(this._dioClient) : _notifSync = TopUpNotificationSync(_dioClient);

  Future<double> getBalance() async {
    try {
      final response = await _dioClient.get('/user/wallet');
      return (response.data as num).toDouble();
    } catch (e) {
      throw Exception('Failed to load wallet balance: ${extractErrorMessage(e)}');
    }
  }
  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final response = await _dioClient.get('/user/transaction');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final list = (data['data'] as List)
            .map((e) =>
                WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return _enrichTopUpAmounts(list);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load transaction history: ${extractErrorMessage(e)}');
    }
  }

  Future<List<WalletTransactionModel>> _enrichTopUpAmounts(
      List<WalletTransactionModel> list) async {
    final firstPass = <WalletTransactionModel>[];
    final stillUnknownIds = <int>[];
    for (final t in list) {
      if (t.isTopUp && t.price == null) {
        final cached = await TopUpAmountCache.getAmount(t.transactionId);
        if (cached != null && cached >= 0) {
          firstPass.add(t.withCachedAmount(cached));
        } else {
          firstPass.add(t);
          stillUnknownIds.add(t.transactionId);
        }
      } else {
        firstPass.add(t);
      }
    }

    // Bước 2: những giao dịch máy này chưa biết (ví dụ vừa đổi sang thiết bị
    // mới) thì hỏi server qua Notification đã đồng bộ trước đó.
    if (stillUnknownIds.isEmpty) return firstPass;

    final serverAmounts = await _notifSync.fetchKnownAmounts();
    if (serverAmounts.isEmpty) return firstPass;

    final result = <WalletTransactionModel>[];
    for (final t in firstPass) {
      final fromServer = serverAmounts[t.transactionId];
      if (t.isTopUp && t.price == null && fromServer != null) {
        result.add(t.withCachedAmount(fromServer));
        // Lưu lại vào cache local để lần sau không cần gọi server nữa.
        await TopUpAmountCache.saveAmount(t.transactionId, fromServer);
      } else {
        result.add(t);
      }
    }
    return result;
  }

  /// POST /user/wallet/add?amount=
  /// Bước "chốt sổ" cộng tiền thật vào ví sau khi WebView VNPay báo thành
  /// công (IPN phía BE hiện chưa tự cộng ví). Trả về số dư mới nhất.
  ///
  /// BE (`UserController.addBalance`) đã tự tạo 1 bản ghi Transaction (type
  /// "Add") cho lần nạp này, nên lịch sử giao dịch thực ra ĐÃ được ghi nhận.
  /// Vấn đề chỉ là API danh sách giao dịch không trả kèm số tiền cho loại
  /// "Add". Vì vậy ngay sau khi cộng ví thành công, FE chủ động dò lại danh
  /// sách giao dịch, tìm bản ghi "Add" mới nhất chưa từng thấy (transactionId
  /// lớn nhất, chưa có trong cache) và lưu số tiền vừa nạp vào cache local
  /// để hiển thị đúng trong lịch sử — không cần và không đụng tới BE.
  Future<double> addBalance(double amountUsd) async {
    try {
      // Chụp lại danh sách id giao dịch top-up hiện có TRƯỚC khi nạp, để sau
      // đó xác định chính xác bản ghi nào là mới được BE tạo ra.
      final beforeIds = await _existingTopUpTransactionIds();

      final response = await _dioClient.post(
        '/user/wallet/add',
        queryParameters: {'amount': amountUsd},
      );
      final newBalance = (response.data as num).toDouble();

      await _rememberNewTopUpAmount(beforeIds, amountUsd);

      return newBalance;
    } catch (e) {
      throw Exception('Failed to add balance: ${extractErrorMessage(e)}');
    }
  }

  Future<Set<int>> _existingTopUpTransactionIds() async {
    try {
      final response = await _dioClient.get('/user/transaction');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
            .where((t) => t.isTopUp)
            .map((t) => t.transactionId)
            .toSet();
      }
    } catch (_) {
      // Nếu không lấy được danh sách trước đó thì bỏ qua, chấp nhận không
      // cache được số tiền lần này (lịch sử vẫn có bản ghi, chỉ là thiếu số
      // tiền hiển thị).
    }
    return <int>{};
  }

  Future<void> _rememberNewTopUpAmount(
      Set<int> beforeIds, double amountUsd) async {
    try {
      final response = await _dioClient.get('/user/transaction');
      final data = response.data;
      if (data is! Map || data['data'] is! List) return;

      final current = (data['data'] as List)
          .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
          .where((t) => t.isTopUp && !beforeIds.contains(t.transactionId))
          .toList()
        ..sort((a, b) => b.transactionId.compareTo(a.transactionId));

      if (current.isNotEmpty) {
        final newTxnId = current.first.transactionId;
        await TopUpAmountCache.saveAmount(newTxnId, amountUsd);
        // Đồng bộ lên server để tài khoản này xem lịch sử trên MÁY KHÁC
        // cũng thấy đúng số tiền — không chặn luồng nạp tiền nếu lỗi.
        await _notifSync.reportTopUp(
          transactionId: newTxnId,
          amountUsd: amountUsd,
        );
        // Các bản ghi mới khác (nếu có, hiếm khi xảy ra) đánh dấu là "đã
        // thấy" để không bị gán nhầm số tiền ở lần nạp kế tiếp.
        if (current.length > 1) {
          await TopUpAmountCache.markSeenIfUnknown(
            current.skip(1).map((t) => t.transactionId),
          );
        }
      }
    } catch (_) {
      // Không chặn luồng nạp tiền nếu bước "vá" cache này lỗi.
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