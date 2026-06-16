# 📂 Hướng Dẫn Kiến Trúc & Cấu Trúc Thư Mục Dự Án (Steam Clone Flutter)

Tài liệu này giải thích cấu trúc thư mục của dự án và cách sắp xếp code trong quá trình chuyển đổi từ React sang Flutter.

---

## 1. Mục Tiêu Dự Án
Dự án được phát triển theo mô hình **Steam Clone** trên di động. Mục tiêu cốt lõi là hoàn thiện các tính năng chính trong luồng người dùng (Core User Loop): Xác thực, Cửa hàng, Giỏ hàng & Thanh toán, và Thư viện game sở hữu.

---

## 2. Kiến Trúc Dự Án (Feature-First)
Dự án áp dụng mô hình **Feature-First** (phân tách thư mục theo tính năng) kết hợp với các Layer cục bộ. Điều này giúp các lập trình viên có thể làm việc độc lập trên tính năng của mình mà không gây xung đột code khi gộp nhánh Git.

```text
lib/
├── core/                   # Chứa các thành phần cốt lõi dùng chung cho toàn bộ app
│   ├── constants/          # Khai báo hằng số (màu sắc, kích thước, API endpoint)
│   ├── network/            # Lớp kết nối HTTP (DioClient, Interceptors) & WebSocket
│   ├── router/             # Cấu hình định tuyến toàn app (GoRouter, ShellRoute)
│   ├── theme/              # Cấu hình giao diện Dark Mode đặc trưng của Steam
│   ├── utils/              # Các hàm bổ trợ (Format tiền tệ, định dạng ngày tháng)
│   └── widgets/            # UI Kit (Custom Button, Input field, Loading, Card dùng chung)
│
└── features/               # Thư mục chứa các tính năng độc lập (phân chia theo Dev)
    ├── auth/               # Đăng nhập, Đăng ký, Xác thực OTP (Developer A)
    ├── storefront/         # Màn hình chính, Banner Carousel, Tìm kiếm game (Developer B)
    ├── cart_payment/       # Giỏ hàng, Nạp tiền ví, Webview VNPay (Developer C)
    ├── library/            # Danh sách game đã mua, quản lý cài đặt (Developer D)
    └── profile/            # Trang cá nhân, lịch sử giao dịch (Developer A)
```

---

## 3. Quy Tắc Tổ Chức File Trong Mỗi Feature
Khi viết code cho một tính năng (ví dụ: `features/auth/`), bạn bắt buộc phải chia nhỏ code theo 3 tầng sau:
1. **`data/`**:
   - `models/`: Chứa các lớp định nghĩa dữ liệu (DTOs) ánh xạ từ API JSON.
   - `repositories/`: Chứa logic gọi API từ server. Nhận `DioClient` thông qua Constructor Injection.
2. **`providers/`**:
   - Quản lý trạng thái giao diện (State management) và tương tác với Repository để lấy dữ liệu. Kế thừa từ `ChangeNotifier` (Provider) hoặc Riverpod.
3. **`views/`**:
   - `screens/`: Màn hình hoàn chỉnh của tính năng.
   - `widgets/`: Các thành phần giao diện nhỏ chỉ dùng riêng cho tính năng này.

---

## 4. Tương Tác Giữa Các Thành Viên (Collaboration Rules)
- **Cấm tự ý sửa `lib/core/`**: Ngoại trừ Tech Lead và Dev D (UI Kit), các lập trình viên khác không được tự tiện sửa đổi cấu hình định tuyến, cấu hình Dio hoặc Theme dùng chung mà chưa có sự đồng thuận.
- **Tái sử dụng UI**: Luôn kiểm tra thư mục `lib/core/widgets/` trước khi tự tay viết một Widget mới (như Button, TextField) nhằm đảm bảo giao diện đồng bộ 100% theo phong cách Steam.
