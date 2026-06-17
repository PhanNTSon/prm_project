# 🔌 Kịch Bản Kiểm Thử Tầng Mạng (Network Test Plan)

Thư mục này chứa mã nguồn và tài liệu kiểm thử cho Tầng mạng (Network Layer), bao gồm `DioClient`, `AuthInterceptor` và `SecureStorageService`.

Tệp kiểm thử tự động: [network_test.dart](file:///d:/Ki_8/PRM393/Proj/prm_project/test/network/network_test.dart)

---

## 1. Mục Đích & Lý Do Kiểm Thử
- Đảm bảo cơ chế tự động đính kèm token (Bearer Token) vào Header của mọi request API hoạt động chính xác.
- Bảo đảm khi token rỗng, request không bị đính kèm dữ liệu thừa/lỗi.
- Kiểm tra tính bảo mật: khi nhận lỗi HTTP `401 Unauthorized` từ API Backend, ứng dụng phải tự động xóa thông tin tài khoản đã lưu để tránh bị giả mạo phiên.
- Xác thực cơ chế ghi/đọc/xóa dữ liệu bảo mật trên bộ nhớ máy ảo/thiết bị (`SecureStorageService`).

---

## 2. Các Ca Kiểm Thử Tự Động (Automated Test Cases)

| Mã Case | Tên Case | Input (Dữ liệu đầu vào) | Output Expected (Kết quả kỳ vọng) |
| :--- | :--- | :--- | :--- |
| **TC_NET_01** | Header Injection | `SecureStorageService` lưu token `test_jwt_token`. Gọi API bất kỳ. | Header của Request tự động xuất hiện `Authorization: Bearer test_jwt_token`. |
| **TC_NET_02** | No-Token Request | `SecureStorageService` không có token. Gọi API bất kỳ. | Header của Request không tồn tại trường `Authorization`. |
| **TC_NET_03** | 401 Error Clean | Giả lập request nhận mã phản hồi HTTP `401 Unauthorized` từ Backend. | Hàm `clearAuthData()` được gọi, xóa sạch token khỏi bộ nhớ. |
| **TC_NET_04** | Read/Write Storage | Gọi lưu `saveAuthData` với token `test_token`, userId `123`, role `ADMIN`. | Đọc lại đúng các thông số đã lưu. |
| **TC_NET_05** | Clear Storage | Đăng xuất hoặc xóa bộ nhớ. | Các trường token, userId, role, v.v. trả về `null`. |

---

## 3. Cách Thức Thực Hiện
Mở terminal tại thư mục dự án và chạy lệnh sau để thực thi:
```bash
flutter test test/network/network_test.dart
```
