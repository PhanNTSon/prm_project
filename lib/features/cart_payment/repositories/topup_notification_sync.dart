import '../../../../core/network/dio_client.dart';
import '../../../../core/network/secure_storage_service.dart';

class TopUpNotificationSync {
  final DioClient _dioClient;
  final SecureStorageService _secureStorageService;

  TopUpNotificationSync(this._dioClient, [SecureStorageService? storage])
      : _secureStorageService = storage ?? SecureStorageService();

  static const String _notifType = 'WalletTopUp';
  static final RegExp _txnTagRegex = RegExp(r'\[txn:(\d+)\]');
  static final RegExp _amountRegex = RegExp(r'\+\$([0-9]+(?:\.[0-9]+)?)');
  Future<void> reportTopUp({
    required int transactionId,
    required double amountUsd,
  }) async {
    try {
      final userId = await _secureStorageService.getUserId();
      if (userId == null) return;

      final content = 'Top-up successful: +\$${amountUsd.toStringAsFixed(2)} '
          'added to your wallet. [txn:$transactionId]';

      await _dioClient.post('/notification/create', data: {
        'receiverId': int.parse(userId),
        'notificationType': _notifType,
        'notificationContent': content,
      });
    } catch (_) {
    }
  }

  Future<Map<int, double>> fetchKnownAmounts() async {
    try {
      final response = await _dioClient.get('/notification/list');
      final data = response.data;
      if (data is! List) return {};

      final result = <int, double>{};
      for (final item in data) {
        if (item is! Map) continue;
        if (item['notificationType'] != _notifType) continue;
        final content = item['notificationContent'] as String?;
        if (content == null) continue;

        final txnMatch = _txnTagRegex.firstMatch(content);
        final amountMatch = _amountRegex.firstMatch(content);
        if (txnMatch == null || amountMatch == null) continue;

        final txnId = int.tryParse(txnMatch.group(1)!);
        final amount = double.tryParse(amountMatch.group(1)!);
        if (txnId != null && amount != null) {
          result[txnId] = amount;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}