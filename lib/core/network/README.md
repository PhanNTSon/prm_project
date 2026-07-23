# 📡 Lớp Mạng & Giao Tiếp Dữ Liệu (Network Layer)

Tài liệu này hướng dẫn cách sử dụng các dịch vụ mạng trong ứng dụng, bao gồm HTTP Client (`Dio`), xử lý Xác thực (`AuthInterceptor`), và kết nối Thời gian thực (`WebSocketService`). Đây là lớp cốt lõi do **Tech Lead** chịu trách nhiệm thiết kế.

## 1. HTTP Client & Xác Thực Mật (Auth Interceptor)
Hệ thống sử dụng thư viện `Dio` làm bộ khung gọi API chính, kết hợp với các service bảo mật:

- **`secure_storage_service.dart`**: Dùng để lưu trữ Token JWT vào vùng nhớ mã hóa an toàn của thiết bị (Keychain/Keystore). Không bao giờ lưu token bằng `SharedPreferences` thông thường.
- **`dio_client.dart`**: Khởi tạo cấu hình Dio cơ bản (BaseURL, Timeout). Bất kỳ Provider/Repository nào cần gọi API đều phải nhận instance của `DioClient` này thông qua Dependency Injection.
- **`auth_interceptor.dart`**: Là một chốt chặn tự động. 
  - **Khi Gửi (Request)**: Tự động móc Token từ `SecureStorageService` gắn vào Header `Authorization: Bearer <Token>`. Bạn không cần phải tự chèn token bằng tay mỗi khi viết code gọi API.
  - **Khi Nhận (Response)**: Bắt lỗi `401 Unauthorized` tập trung. Nếu token hết hạn, nó sẽ kích hoạt quá trình tự động văng về màn hình Login.

---

## 2. Cơ chế hoạt động của WebSocketService (STOMP)
`WebSocketService` trong ứng dụng đã được tự động liên kết với vòng đời đăng nhập của `AuthProvider`.
- **Khi đăng nhập thành công**: App tự động kết nối STOMP đến `/ws-community?token=...`.
- **Khi đăng xuất hoặc token hết hạn**: App tự ngắt kết nối WebSocket và dọn dẹp các bản tin đăng ký (subscriptions).

Do đó, bạn **KHÔNG CẦN** phải gọi hàm `connect()` hay `disconnect()` thủ công ở bất kỳ đâu trong Widget của mình.

## 3. Cách lắng nghe dữ liệu Realtime (Wallet & Notification)
Hệ thống đã xây dựng sẵn `WalletProvider` và `NotificationProvider` và cấu hình chúng tự động cập nhật khi có bản tin mới từ Server gửi về thông qua WebSocket.

### A. Hiển thị Số dư ví (Wallet Balance)
Ví dụ trong màn hình `ProfileScreen` hoặc `CartScreen`, để lấy số dư cập nhật tức thời:
```dart
import 'package:provider/provider.dart';
import 'package:prm_project/features/profile/providers/wallet_provider.dart';

Widget build(BuildContext context) {
  // Lắng nghe WalletProvider
  final walletBalance = context.watch<WalletProvider>().balance;
  
  return Text('Số dư: \$${walletBalance.toStringAsFixed(2)}');
}
```

### B. Hiển thị Thông báo (Notifications)
Ví dụ trong `HomeAppbar`, để lấy số lượng thông báo chưa đọc:
```dart
import 'package:provider/provider.dart';
import 'package:prm_project/features/profile/providers/notification_provider.dart';

Widget build(BuildContext context) {
  final unreadCount = context.watch<NotificationProvider>().unreadCount;

  return Stack(
    children: [
      const Icon(Icons.notifications),
      if (unreadCount > 0)
        Positioned(
          right: 0,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.red,
            child: Text('$unreadCount', style: const TextStyle(fontSize: 10)),
          ),
        ),
    ],
  );
}
```

## 4. Cách Đăng ký nhận bản tin Custom (Subscribing to new Destinations)
Nếu bạn được phân công làm một tính năng cần WebSocket (VD: chat, trạng thái đơn hàng), bạn có thể lấy instance của `WebSocketService` và tự đăng ký `subscribe`:

```dart
import 'package:provider/provider.dart';
import 'package:prm_project/core/network/websocket_service.dart';

class _MyChatScreenState extends State<MyChatScreen> {
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    // Lấy service (listen: false vì ta chỉ gọi hàm, không cần rebuild khi service đổi state)
    _wsService = context.read<WebSocketService>();
    
    // Đăng ký nhận tin nhắn mới từ destination /topic/chat
    _wsService.subscribe('/topic/chat', _onNewMessageReceived);
  }

  void _onNewMessageReceived(Map<String, dynamic> data) {
    // Dữ liệu JSON từ server đã được parse thành Map<String, dynamic>
    print("Có tin nhắn mới: ${data['text']}");
    setState(() {
      // Cập nhật UI
    });
  }

  @override
  void dispose() {
    // Luôn nhớ unsubscribe khi rời khỏi màn hình!
    _wsService.unsubscribe('/topic/chat');
    super.dispose();
  }
}
```

## 5. Troubleshooting (Gỡ Lỗi Căn Bản)
- **Log: `Lỗi khi parse JSON từ WebSocket`**: Bản tin server gửi xuống không phải định dạng JSON hợp lệ. Hãy báo BE check lại.
- **Log: `Lỗi WebSocket: connection refused`**: Bạn chưa bật BE Server hoặc sai `WS_BASE_URL` trong file `.env`. Mặc định đang gọi đến `10.0.2.2:8080`.
- **Màn hình không cập nhật**: Đảm bảo bạn dùng `context.watch()` (hoặc `Consumer`) thay vì `context.read()` trong hàm `build()`.
