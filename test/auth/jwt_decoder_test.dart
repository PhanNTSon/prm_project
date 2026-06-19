import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/core/utils/jwt_decoder.dart';

void main() {
  group('JwtDecoder Tests', () {
    test('Should decode a valid JWT token payload correctly', () {
      // payload: {"sub":"tester","userId":"10","role":"VIP"}
      final payloadStr = jsonEncode({"sub": "tester", "userId": "10", "role": "VIP"});
      final encodedPayload = base64UrlEncode(utf8.encode(payloadStr));
      final fakeToken = 'header.$encodedPayload.signature';

      final decoded = JwtDecoder.decode(fakeToken);

      expect(decoded['sub'], 'tester');
      expect(decoded['userId'], '10');
      expect(decoded['role'], 'VIP');
    });

    test('Should throw FormatException for invalid token structure', () {
      const invalidToken = 'just.two.parts? No, only one dot.';
      
      expect(() => JwtDecoder.decode(invalidToken), throwsA(isA<FormatException>()));
    });

    test('Should correctly identify an expired token', () {
      // Tạo token hết hạn cách đây 1 giờ
      final pastTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
      final payloadStr = jsonEncode({"sub": "tester", "exp": pastTime});
      final encodedPayload = base64UrlEncode(utf8.encode(payloadStr));
      final fakeToken = 'header.$encodedPayload.signature';

      expect(JwtDecoder.isExpired(fakeToken), isTrue);
    });

    test('Should correctly identify a valid (non-expired) token', () {
      // Tạo token hết hạn sau 1 giờ
      final futureTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payloadStr = jsonEncode({"sub": "tester", "exp": futureTime});
      final encodedPayload = base64UrlEncode(utf8.encode(payloadStr));
      final fakeToken = 'header.$encodedPayload.signature';

      expect(JwtDecoder.isExpired(fakeToken), isFalse);
    });
  });
}
