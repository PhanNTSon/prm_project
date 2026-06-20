import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _client;
  bool _isConnected = false;
  Timer? _mockTimer;
  
  // Lưu trữ các hàm callback được đăng ký theo destination
  final Map<String, List<Function(Map<String, dynamic>)>> _subscriptions = {};

  bool get isConnected => _isConnected;

  /// Khởi tạo kết nối STOMP qua WebSocket
  void connect(String token) {
    if (_isConnected) return;

    final useMock = dotenv.isInitialized && dotenv.env['USE_MOCK_WEBSOCKET'] == 'true';
    if (useMock) {
      debugPrint('🔌 Bật chế độ GIẢ LẬP WebSocket (Offline Simulator Mode)');
      _isConnected = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isConnected) {
          _onConnect(StompFrame(command: 'CONNECTED', headers: {}, body: ''));
          _startMockUpdates();
        }
      });
      return;
    }

    // Ưu tiên đọc URL từ biến môi trường, mặc định là localhost
    String baseUrl = 'ws://10.0.2.2:8080';
    if (dotenv.isInitialized) {
      baseUrl = dotenv.env['WS_BASE_URL'] ?? baseUrl;
    }
    
    // Tự động chuyển đổi http/https thành ws/wss vì thư viện Dart WebSocket chỉ hỗ trợ ws/wss
    if (baseUrl.startsWith('https://')) {
      baseUrl = baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'ws://');
    }
    
    // Gắn token vào query parameter để dễ dàng vượt qua các filter Authentication
    final wsUrl = '$baseUrl/ws-community?token=$token';

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        beforeConnect: () async {
          debugPrint('Đang chuẩn bị kết nối WebSocket...');
        },
        onWebSocketError: (dynamic error) => debugPrint('Lỗi WebSocket: $error'),
        onStompError: (StompFrame frame) {
          debugPrint('Lỗi STOMP: ${frame.body}');
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          debugPrint('Đã ngắt kết nối WebSocket.');
        },
      ),
    );

    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    debugPrint('Kết nối WebSocket STOMP thành công!');

    // Tự động subscribe lại các topic đã đăng ký trước đó (nếu có)
    _subscriptions.forEach((destination, callbacks) {
      final useMock = dotenv.isInitialized && dotenv.env['USE_MOCK_WEBSOCKET'] == 'true';
      if (!useMock) {
        _subscribeInternal(destination);
      }
    });
  }

  void _startMockUpdates() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_isConnected) return;
      
      final isWallet = timer.tick % 2 == 0;
      if (isWallet) {
        final mockBalance = 100.0 + (timer.tick * 15.5) % 1000.0;
        final data = {'balance': mockBalance.toStringAsFixed(2)};
        _triggerMockSubscription('/user/queue/wallet.balance', data);
      } else {
        final mockCount = (timer.tick ~/ 2) % 10 + 1;
        final data = {
          'count': mockCount,
          'message': 'Thông báo giả lập số ${timer.tick}: Bạn nhận được 1 giao dịch thành công!'
        };
        _triggerMockSubscription('/user/queue/notification.unread', data);
      }
    });
  }

  void _triggerMockSubscription(String destination, Map<String, dynamic> data) {
    if (_subscriptions.containsKey(destination)) {
      for (var callback in _subscriptions[destination]!) {
        callback(data);
      }
    }
  }

  /// Ngắt kết nối
  void disconnect() {
    _client?.deactivate();
    _mockTimer?.cancel();
    _mockTimer = null;
    _isConnected = false;
    _subscriptions.clear();
  }

  /// Đăng ký nhận tin nhắn từ một destination
  void subscribe(String destination, Function(Map<String, dynamic>) callback) {
    if (!_subscriptions.containsKey(destination)) {
      _subscriptions[destination] = [];
      if (_isConnected) {
        _subscribeInternal(destination);
      }
    }
    _subscriptions[destination]!.add(callback);
  }

  /// Thực hiện gọi hàm subscribe của StompClient
  void _subscribeInternal(String destination) {
    _client?.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> data = json.decode(frame.body!);
            // Gọi tất cả các callback đã đăng ký cho destination này
            if (_subscriptions.containsKey(destination)) {
              for (var callback in _subscriptions[destination]!) {
                callback(data);
              }
            }
          } catch (e) {
            debugPrint('Lỗi khi parse JSON từ WebSocket: $e');
          }
        }
      },
    );
  }

  /// Hủy đăng ký nhận tin nhắn
  void unsubscribe(String destination) {
    _subscriptions.remove(destination);
    // Lưu ý: stomp_dart_client trả về một Unsubscribe function khi gọi client.subscribe. 
    // Ở implementation đơn giản này, ta xóa khỏi Map để callback không được gọi nữa.
  }
}
