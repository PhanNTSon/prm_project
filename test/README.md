# 🧪 Hướng Dẫn Kiểm Thử Tầng Mạng (Network Layer Test Plan)

Thư mục này chứa các tài liệu và mã nguồn phục vụ việc kiểm thử (tự động và thủ công) cho tầng mạng và cơ chế bảo mật token của ứng dụng.

---

## 1. Kiểm Thử Tự Động (Automated Unit Tests)

Mã nguồn kiểm thử tự động được viết tại: [network_test.dart](file:///d:/Ki_8/PRM393/Proj/prm_project/test/network_test.dart)

### Các Test Cases Triển Khai:

| ID | Tên Case | Mục tiêu | Kết quả kỳ vọng |
| :--- | :--- | :--- | :--- |
| **TC_AUTO_01** | Header Injection | Kiểm tra khi bộ nhớ Secure Storage có JWT token. | Request gửi đi tự động chứa header `Authorization: Bearer <token>`. |
| **TC_AUTO_02** | No-Token Request | Kiểm tra khi bộ nhớ Secure Storage rỗng (chưa đăng nhập). | Request gửi đi không chứa header `Authorization`. |
| **TC_AUTO_03** | 401 Error Handling | Kiểm tra khi nhận mã lỗi 401 Unauthorized từ Backend. | Hệ thống tự động xóa sạch dữ liệu token trong Secure Storage để bảo mật. |

### Cách thực hiện:
Mở terminal tại thư mục gốc của dự án (`d:\Ki_8\PRM393\Proj\prm_project`) và chạy lệnh:
```bash
flutter test test/network_test.dart
```

---

## 2. Kiểm Thử Thủ Công (Manual Integration Tests)

Các kịch bản kiểm thử tích hợp thực tế với Backend Spring Boot và Giao diện (UI).

### Kịch Bản A: Xác thực Token trên Request (TC_MAN_01)
- **Chuẩn bị:** Đăng nhập vào ứng dụng để lưu token thật (hoặc ghi đè token giả vào Secure Storage qua hàm test).
- **Thực hiện:** Gọi bất kỳ API cần quyền (ví dụ: `/api/user/profile`).
- **Cách kiểm tra:** 
  1. Theo dõi log console của Flutter (Debug Console).
  2. Tìm request gửi đi dưới dạng:
     ```text
     Request: GET http://10.0.2.2:8080/api/user/profile
     headers: {
       Authorization: Bearer eyJhbGciOiJIUzI1NiIsIn...
     }
     ```
  3. Nếu header `Authorization` xuất hiện đúng giá trị token đã lưu -> **PASS**.

### Kịch Bản B: Hết Hạn Phiên Làm Việc / Đăng Xuất Tự Động (TC_MAN_02)
- **Chuẩn bị:** Chạy ứng dụng và vào một màn hình cần đăng nhập (ví dụ: Thư viện game).
- **Thực hiện:** 
  1. Giả lập token hết hạn bằng cách chỉnh thời gian hệ thống của Server hoặc chỉnh sửa token giả bị sai chữ ký.
  2. Thực hiện một hành động gọi API bất kỳ.
- **Cách kiểm tra:**
  1. Server trả về HTTP Status `401 Unauthorized`.
  2. Quan sát màn hình ứng dụng: Giao diện phải tự động điều hướng về màn hình Đăng nhập (`/login`).
  3. Thử tải lại app: Người dùng không được tự động đăng nhập nữa vì token đã bị xóa khỏi Secure Storage -> **PASS**.

### Kịch Bản C: Cấu hình Timeout và Không Kết Nối Được Server (TC_MAN_03)
- **Chuẩn bị:** Tắt kết nối internet của thiết bị/máy ảo hoặc tắt máy chủ Spring Boot Backend.
- **Thực hiện:** Mở app hoặc thực hiện thao tác gọi API.
- **Cách kiểm tra:**
  1. Quan sát log: Ứng dụng phải ngắt kết nối sau đúng **10 giây** (Connect Timeout).
  2. Bắt được ngoại lệ loại `DioExceptionType.connectionTimeout` hoặc `connectionError`.
  3. Giao diện hiển thị thông báo lỗi mạng thân thiện với người dùng (ví dụ: "Không thể kết nối đến máy chủ, vui lòng thử lại") thay vì bị crash ứng dụng -> **PASS**.
