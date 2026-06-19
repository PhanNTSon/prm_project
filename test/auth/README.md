# 🔐 Kiểm Thử Module Xác Thực (Auth Module Tests)

Thư mục này chứa các ca kiểm thử tự động (Unit Tests) cho các nghiệp vụ giải mã JWT và quản lý trạng thái đăng nhập của người dùng.

---

## 1. Danh Sách Các Ca Kiểm Thử

### A. Kiểm thử Bộ Giải Mã JWT (`jwt_decoder_test.dart`)
- **Should decode a valid JWT token payload correctly**: Kiểm tra hàm `JwtDecoder.decode` có bóc tách chính xác thông tin Payload (username, userId, role) từ chuỗi token Base64 hợp lệ hay không.
- **Should throw FormatException for invalid token structure**: Kiểm tra hàm decode có ném ra lỗi `FormatException` khi đưa vào một chuỗi token lỗi cấu trúc (không đủ 3 phần phân tách bởi dấu chấm).
- **Should correctly identify an expired token**: Kiểm tra hàm `JwtDecoder.isExpired` có nhận diện đúng token đã hết hạn dựa vào thời gian `exp` trong quá khứ.
- **Should correctly identify a valid (non-expired) token**: Kiểm tra hàm `JwtDecoder.isExpired` trả về `false` đối với token có `exp` trong tương lai.

### B. Kiểm thử Quản Lý Trạng Thái (`auth_provider_test.dart`)
- **loginSuccess should update state and storage**:
  - Mô phỏng đăng nhập thành công với một token JWT giả định.
  - Kiểm tra xem trạng thái `isAuthenticated` có đổi sang `true` không.
  - Đảm bảo thông tin người dùng được giải mã chính xác và lưu xuống `SecureStorageService` thành công.
- **logout should clear state and storage**:
  - Mô phỏng trạng thái đã đăng nhập.
  - Gọi hàm `logout()`.
  - Kiểm tra các biến state trong `AuthProvider` có được reset về `null` không, `isAuthenticated` chuyển sang `false` không.
  - Đảm bảo token và ID người dùng bị xóa hoàn toàn khỏi `SecureStorageService`.

---

## 2. Hướng Dẫn Chạy Test Riêng Lẻ

Chạy riêng các bài kiểm thử liên quan đến Auth bằng lệnh:

```bash
flutter test test/auth/
```
