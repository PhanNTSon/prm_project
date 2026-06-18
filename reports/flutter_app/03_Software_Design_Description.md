# **III. Software Design Description** {#iii.-software-design-description}

## **1\. System Design** {#1.-system-design}

### **1.1 System Architecture**

Kiến trúc tổng thể của hệ thống dựa trên mô hình Client-Server.

```text
+---------------------+        HTTP/REST        +-----------------------+
|  Mobile Client      | <=====================> |  Spring Boot Backend  |
|  (Flutter App)      |    (JSON payloads)      |  (Centurion API)      |
+---------------------+                         +-----------------------+
        |                                                 |
        | InAppWebView                                    | JDBC
        v                                                 v
+---------------------+                         +-----------------------+
|  VNPay Sandbox      |                         |  PostgreSQL Database  |
|  (Payment Gateway)  |                         |  (Managed by Railway) |
+---------------------+                         +-----------------------+
```

- **Mobile Client (Flutter):** Chịu trách nhiệm hiển thị giao diện người dùng, quản lý State cục bộ, điều hướng (GoRouter) và giao tiếp mạng (Dio). Mọi thông tin nhạy cảm (JWT Token) được lưu trữ mã hóa qua `flutter_secure_storage`.
- **VNPay Sandbox:** Khi cần nạp tiền, Flutter App mở một `InAppWebView` trỏ đến đường dẫn VNPay do Backend tạo ra. Người dùng thao tác thanh toán, sau đó VNPay chuyển hướng (callback) URL chứa tham số giao dịch. App đánh chặn URL này và báo cáo kết quả cho người dùng.
- **Backend & Database:** Đóng vai trò là nguồn dữ liệu sự thật duy nhất (Single Source of Truth), quản lý nghiệp vụ, kiểm tra tính hợp lệ của giao dịch và lưu trữ trên PostgreSQL.

### **1.2 Package Diagram**

Dự án Flutter áp dụng kiến trúc **Feature-First (Phân tách theo tính năng)**. Phương pháp này giúp chia nhỏ dự án thành các module độc lập, cho phép các lập trình viên làm việc song song mà không bị xung đột (conflict) mã nguồn.

```text
lib/
├── core/                       # Chứa mã nguồn dùng chung toàn hệ thống
│   ├── network/                # Cấu hình DioClient, AuthInterceptor, SecureStorage
│   ├── router/                 # Cấu hình GoRouter, MainShellScreen, Auth Guard
│   ├── widgets/                # UI Component dùng chung (SteamButton, Loading,...)
│   └── constants/              # Hằng số, Bảng màu (AppColors, ApiEndpoints)
│
├── features/                   # Chứa các chức năng chính của app
│   ├── auth/                   # [Dev A] Logic và Giao diện Đăng nhập / Đăng ký
│   ├── profile/                # [Dev A] Hồ sơ người dùng
│   ├── storefront/             # [Dev B] Trang chủ, Tìm kiếm, Chi tiết game
│   ├── cart/                   # [Dev C] Quản lý giỏ hàng, nạp tiền (VNPay)
│   └── library/                # [Dev D] Thư viện game sở hữu
│
└── main.dart                   # Điểm khởi chạy của ứng dụng, khởi tạo Router và App
```

Mỗi feature con (ví dụ `storefront`) sẽ tiếp tục được chia theo mô hình 3 tầng (3-Layer Architecture):
- `data/`: Chứa các model (DTO) và repository giao tiếp với API.
- `providers/`: Chứa logic xử lý trạng thái (State Management) cho feature đó.
- `views/`: Chứa các màn hình (Screen) và các thành phần UI (Widget) cụ thể của feature đó.

## **2\. Database Design** {#2.-database-design}

*Thiết kế CSDL được giữ nguyên theo CSDL PostgreSQL hiện hành của Backend Spring Boot.*
- **Bảng chính:** `User`, `Game`, `Transaction`, `TransactionDetail`, `Library`, `Cart`, `Review`.
- **Cấu trúc:** Một User có nhiều Game trong Library (Mối quan hệ N-N giải quyết qua bảng Library). Mỗi lần thêm vào giỏ hàng sẽ tạo bản ghi trong bảng Cart. Thanh toán thành công sẽ trừ số dư `WalletBalance` của User và sinh ra `Transaction` kèm `TransactionDetail`.
- **Chi tiết bảng User:**
  - `UserID` (bigint, PK)
  - `Email` (varchar, Unique)
  - `Username` (varchar, Unique)
  - `WalletBalance` (numeric)
- **Chi tiết bảng Game:**
  - `GameID` (bigint, PK)
  - `Name` (varchar)
  - `Price` (numeric)
  - `IconUrl` (varchar)
