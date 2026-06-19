import 'dart:convert';

class JwtDecoder {
  /// Giải mã payload của JWT token thành Map
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token');
    }

    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    final decodedString = utf8.decode(base64Url.decode(normalized));
    
    return json.decode(decodedString) as Map<String, dynamic>;
  }

  /// Kiểm tra xem token đã hết hạn chưa
  static bool isExpired(String token) {
    try {
      final decoded = decode(token);
      if (!decoded.containsKey('exp')) {
        return false;
      }
      final exp = decoded['exp'] as int;
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      // Nếu có lỗi giải mã thì coi như token đã hỏng/hết hạn
      return true;
    }
  }

  /// Lấy thời gian hết hạn của token
  static DateTime? getExpirationDate(String token) {
    try {
      final decoded = decode(token);
      if (!decoded.containsKey('exp')) {
        return null;
      }
      final exp = decoded['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      return null;
    }
  }
}
