# Hướng Dẫn Tầng Mạng (Network Layer)

Thư mục này quản lý toàn bộ các giao tiếp HTTP giữa ứng dụng Flutter và Spring Boot Backend.

## 1. Cấu trúc và Lý do thiết kế
- **`secure_storage_service.dart`**: Bộ nhớ bảo mật lưu trữ JWT Token dưới dạng mã hóa trên thiết bị. Tránh lưu ở SharedPreferences thông thường vì dễ bị lộ token, đảm bảo tính bảo mật cao nhất cho người dùng.
- **`auth_interceptor.dart`**: Hoạt động như một "chốt kiểm soát" trung gian. Mỗi khi ứng dụng gửi đi một HTTP request, nó tự động lấy Token từ `SecureStorageService` và chèn vào header `Authorization: Bearer <token>`. Nếu nhận về lỗi 401 (hết hạn hoặc sai token), nó sẽ xóa sạch bộ nhớ và đẩy người dùng về trang Login bằng cách sử dụng `GlobalKey<NavigatorState>` tích hợp từ Router.
- **`dio_client.dart`**: Trực tiếp quản lý thư viện Dio để gọi API. Mọi Repository trong app đều sẽ dùng chung một instance duy nhất của class này để đảm bảo đồng bộ về cấu hình timeout (10 giây) và base URL (đọc từ file `.env` hoặc fallback về localhost).

## 2. Luồng hoạt động (Data Flow)
```text
[Widget/Page] -> Gọi API qua [DioClient] 
                   ↓ (AuthInterceptor tự động chèn Token vào Header)
             [Spring Boot Backend]
                   ↓ (Nếu Token hết hạn hoặc không hợp lệ -> Server trả về 401)
[AuthInterceptor] bắt được 401 -> Xóa token cục bộ -> Điều hướng người dùng về [/login]
```

## 3. Cách sử dụng (Cho các Developer)
Khi viết một Repository mới, bạn KHÔNG tạo đối tượng Dio mới mà phải Inject `DioClient` vào.

```dart
class GameRepository {
  final DioClient _dioClient;

  GameRepository(this._dioClient);

  Future<void> fetchGames() async {
    try {
      final response = await _dioClient.get('/api/games');
      // Xử lý dữ liệu
    } catch (e) {
      // Xử lý lỗi
    }
  }
}
```
