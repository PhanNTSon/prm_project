# Module Xác Thực (Auth Feature)

Module này chịu trách nhiệm quản lý toàn bộ luồng nghiệp vụ liên quan đến Đăng nhập, Đăng ký, Xác thực người dùng và Quản lý phiên truy cập (Session) thông qua JWT.

## Cấu trúc thư mục

- `models/`: Chứa các thực thể dữ liệu như `UserModel` (trích xuất thông tin người dùng từ JWT payload).
- `providers/`: Chứa `AuthProvider`, trung tâm quản lý State xác thực của toàn bộ ứng dụng bằng `ChangeNotifier`.

## Trách nhiệm của AuthProvider
1. **Lưu trữ State Tập Trung**: Chứa biến `isAuthenticated`, `currentUser` và `token` để bất kỳ Widget nào trong app cũng có thể truy xuất (Ví dụ: Header, Profile).
2. **Khôi phục Phiên (Session Persistence)**: Khi app mới mở lên, `AuthProvider.initializeAuth()` sẽ chạy để lấy lại token từ Storage cục bộ.
3. **Cơ chế Chặn Định Tuyến (Route Guard)**: Tích hợp với `refreshListenable` của GoRouter. Mỗi khi người dùng Đăng nhập, Đăng xuất, router tự động vẽ lại và đá người dùng về đúng trang (không cho phép người chưa đăng nhập chui vào các trang riêng tư).
4. **Bảo mật Token**: Quản lý một `Timer` đếm ngược định kỳ mỗi 30 giây để tự động phát hiện token hết hạn (`exp`) và kích hoạt `logout()` tự động.

## Tiện ích đi kèm
Module này phối hợp chặt chẽ với:
- `lib/core/network/secure_storage_service.dart`: Xử lý lưu trữ an toàn token vào Keychain/Keystore hệ thống.
- `lib/core/utils/jwt_decoder.dart`: Tự động giải mã phần thân của chuỗi JWT Base64 để lấy thông tin.

## Hướng dẫn sử dụng cho Team

**Lấy thông tin người dùng hiện tại ở bất kỳ đâu:**
```dart
final auth = context.watch<AuthProvider>();
if (auth.isAuthenticated) {
  print('Xin chào ${auth.currentUser?.username}');
}
```

**Thực hiện đăng xuất (Router sẽ tự động nhảy về /login):**
```dart
await context.read<AuthProvider>().logout();
```
