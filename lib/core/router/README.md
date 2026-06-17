# 🛣️ Định Tuyến & Điều Hướng Hệ Thống (App Router)

Thư mục này quản lý toàn bộ hệ thống định tuyến (Routing) và chuyển trang trong ứng dụng bằng thư viện `go_router`.

---

## 1. Mục Tiêu & Trách Nhiệm
- **Chịu trách nhiệm chính**: **Tech Lead**.
- **Mục tiêu**: Thiết lập cấu hình Router trung tâm, bảo vệ các trang yêu cầu quyền đăng nhập bằng Auth Guard và bố trí Layout dùng chung (Main Shell Layout) gồm `BottomNavigationBar` chứa các Tab: Cửa hàng (Storefront), Giỏ hàng (Cart), Thư viện (Library) và Cá nhân (Profile).

---

## 2. Các Thành Phần Chính Đã Triển Khai

### 2.1. `app_router.dart`
- Chứa cấu hình cốt lõi của `GoRouter`.
- **Auth Guard (redirect)**: Tự động chặn truy cập vào `/home` nếu chưa đăng nhập (token rỗng) và điều hướng về `/login`. Ngược lại, nếu đã đăng nhập mà người dùng vô tình vào `/login`, hệ thống sẽ đưa thẳng tới `/home`.
- **Định tuyến con (Nested Routing)**: Trang `/game-detail/:id` được đặt làm sub-route của `/home` để đảm bảo khi vào xem chi tiết game, `BottomNavigationBar` vẫn được hiển thị nguyên vẹn dưới chân trang.

### 2.2. `main_shell_screen.dart`
- Sử dụng `StatefulShellRoute` để bọc các tab chính.
- Triển khai `BottomNavigationBar` với 4 items. Cơ chế này giúp lưu giữ trạng thái cuộn của từng trang (KeepAlive) khi người dùng đổi qua lại giữa các tab.

### 2.3. `placeholder_screens.dart`
- Là các màn hình trống tạm thời (Mock UI) giúp ứng dụng biên dịch thành công ngay lập tức.
- Các nhà phát triển khác khi nhận việc chỉ cần vào `app_router.dart` thay thế các `PlaceholderScreen` bằng các Widget UI thực tế của họ.

---

## 3. Hướng Dẫn Điều Hướng (Navigation Guide)
Bắt buộc sử dụng GoRouter Extension thay vì Navigator thuần của Flutter:

### 3.1. Điều hướng chuyển hẳn trang (Thay đổi ngăn xếp)
Dùng khi chuyển giữa các Tab chính ở chân trang:
```dart
context.go('/cart');
```

### 3.2. Đẩy thêm trang mới lên đỉnh ngăn xếp (Stack Navigation)
Dùng khi đi vào các trang con (như từ Trang chủ đi vào Trang Chi tiết game, có nút Back ở góc trên để quay lại):
```dart
context.push('/home/game-detail/123');
```

### 3.3. Quay lại trang trước
```dart
context.pop();
```
*(Lưu ý: Luôn kiểm tra `context.mounted` trước khi thực hiện điều hướng sau các hàm gọi API không đồng bộ `await`).*
