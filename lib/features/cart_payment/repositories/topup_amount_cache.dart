import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TopUpAmountCache {
  TopUpAmountCache._();

  static const _prefsKey = 'topup_amount_cache_v1';

  /// Đọc toàn bộ cache: {transactionId -> amountUsd}
  static Future<Map<int, double>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeAll(Map<int, double> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
    await prefs.setString(_prefsKey, encoded);
  }

  /// Lấy số tiền đã cache cho 1 giao dịch, null nếu chưa biết.
  static Future<double?> getAmount(int transactionId) async {
    final all = await _readAll();
    return all[transactionId];
  }

  /// Ghi nhận số tiền đã nạp cho 1 transactionId.
  static Future<void> saveAmount(int transactionId, double amountUsd) async {
    final all = await _readAll();
    all[transactionId] = amountUsd;
    // Giữ cache gọn, chỉ cần nhớ tối đa 200 giao dịch gần nhất.
    if (all.length > 200) {
      final sortedKeys = all.keys.toList()..sort();
      for (final k in sortedKeys.take(all.length - 200)) {
        all.remove(k);
      }
    }
    await _writeAll(all);
  }

  static Future<void> markSeenIfUnknown(Iterable<int> transactionIds) async {
    final all = await _readAll();
    var changed = false;
    for (final id in transactionIds) {
      if (!all.containsKey(id)) {
        all[id] = -1; // 
        changed = true;
      }
    }
    if (changed) await _writeAll(all);
  }
}