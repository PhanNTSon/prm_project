# 🧪 Kế Hoạch & Hệ Thống Kiểm Thử Dự Án (Project Test Suite)

Thư mục này được chia thành các thư mục con tương ứng với từng tầng cấu trúc (Layer) hoặc tính năng (Feature) để kiểm thử một cách khoa học và biệt lập.

---

## 1. Cấu Trúc Thư Mục Kiểm Thử
```text
test/
├── auth/                  # Kiểm thử module Xác thực (Auth)
│   ├── auth_provider_test.dart
│   ├── jwt_decoder_test.dart
│   └── README.md          # Tài liệu mô tả kịch bản kiểm thử Auth
│
├── network/               # Kiểm thử tầng kết nối mạng và bảo mật lưu trữ
│   ├── network_test.dart  # File kiểm thử cho AuthInterceptor & SecureStorageService
│   └── README.md          # Tài liệu mô tả kịch bản kiểm thử tầng mạng
│
├── router/                # Kiểm thử cấu hình định tuyến và bộ lọc Auth Guard
│   ├── router_test.dart   # File kiểm thử cho GoRouter & Shell Route
│   └── README.md          # Tài liệu mô tả kịch bản kiểm thử định tuyến
│
└── README.md              # Entry point tài liệu kiểm thử (Tệp này)
```

---

## 2. Cách Chạy Toàn Bộ Các Bài Kiểm Thử (Run All Tests)
Để chạy toàn bộ các file test tự động có trong dự án, mở terminal tại thư mục gốc của dự án (`prm_project`) và thực hiện:

```bash
flutter test
```

Nếu muốn chạy riêng biệt từng phần, hãy truy cập vào tệp `README.md` trong từng thư mục con để xem hướng dẫn chi tiết của phần đó.
- 🔐 Chi tiết kiểm thử Auth: [test/auth/README.md](file:///d:/Ki_8/PRM393/Proj/prm_project/test/auth/README.md)
- 🔌 Chi tiết kiểm thử mạng: [test/network/README.md](file:///d:/Ki_8/PRM393/Proj/prm_project/test/network/README.md)
- 🛣️ Chi tiết kiểm thử định tuyến: [test/router/README.md](file:///d:/Ki_8/PRM393/Proj/prm_project/test/router/README.md)
