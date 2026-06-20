import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/core/network/websocket_service.dart';

void main() {
  group('WebSocketService Tests', () {
    late WebSocketService wsService;

    setUp(() {
      wsService = WebSocketService();
    });

    test('Initial connection state should be false', () {
      expect(wsService.isConnected, false);
    });

    test('Calling connect should initialize client (but not block)', () {
      // Vì không có WebSocket server thật nên ta chỉ test việc gọi hàm connect không bị lỗi
      expect(() => wsService.connect('dummy_token'), returnsNormally);
      // isConnected chỉ bằng true sau khi onConnect được trigger bởi StompClient
      expect(wsService.isConnected, false); 
    });

    test('Calling disconnect without connect should be safe', () {
      expect(() => wsService.disconnect(), returnsNormally);
      expect(wsService.isConnected, false);
    });

    test('Subscribing and Unsubscribing logic (Offline)', () {
      int callCount = 0;
      void testCallback(Map<String, dynamic> data) {
        callCount++;
      }

      // Offline subscribe
      wsService.subscribe('/topic/test', testCallback);
      // Vẫn không lỗi
      
      wsService.unsubscribe('/topic/test');
      expect(callCount, 0);
    });
  });
}
