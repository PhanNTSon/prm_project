# 🛣️ Kịch Bản Kiểm Thử Bộ Định Tuyến (Router Test Plan)

Thư mục này chứa mã nguồn và tài liệu kiểm thử cho hệ thống định tuyến `GoRouter` và bộ lọc bảo mật `Auth Guard`.

Tệp kiểm thử tự động: [router_test.dart](file:///d:/Ki_8/PRM393/Proj/prm_project/test/router/router_test.dart)

---

## 1. Mục Đích & Lý Do Kiểm Thử
- Đảm bảo người dùng vãng lai chưa đăng nhập bị chặn không thể truy cập vào các trang chính như `/home`, `/cart`, `/library`.
- Đảm bảo người dùng đã đăng nhập thành công (có token hợp lệ trong bộ nhớ) được điều hướng trực tiếp vào màn hình chính `/home` mà không bị hiển thị lại trang `/login`.
- Tránh các lỗi vòng lặp điều hướng vô hạn (Redirect loops).

---

## 2. Các Ca Kiểm Thử Tự Động (Automated Test Cases)

| Mã Case | Tên Case | Input (Dữ liệu đầu vào) | Output Expected (Kết quả kỳ vọng) | Lý do test |
| :--- | :--- | :--- | :--- | :--- |
| **TC_RTE_01** | Redirect No Token | Bộ nhớ `SecureStorageService` rỗng. Khởi chạy app với đích đến mặc định `/home`. | Ứng dụng tự động điều hướng sang màn hình `/login` (hiển thị `LoginPlaceholderScreen`). | Ngăn chặn truy cập trái phép khi chưa đăng nhập. |
| **TC_RTE_02** | Direct Token Exists| Giả lập lưu token `valid_token` trong `SecureStorageService`. Gọi `go('/home')`. | Người dùng vào thẳng trang chủ, màn hình hiển thị `HomePlaceholderScreen`. | Tránh bắt người dùng phải đăng nhập lại mỗi khi mở app nếu phiên làm việc còn hạn. |

---

## 3. Cách Thức Thực Hiện
Mở terminal tại thư mục dự án và chạy lệnh sau để thực thi:
```bash
flutter test test/router/router_test.dart
```
