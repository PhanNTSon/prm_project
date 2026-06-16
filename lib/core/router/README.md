# 🛣️ Định Tuyến & Điều Hướng Hệ Thống (App Router)

Thư mục này quản lý toàn bộ hệ thống định tuyến (Routing) và chuyển trang trong ứng dụng bằng thư viện `go_router`.

---

## 1. Mục Tiêu & Trách Nhiệm
- **Chịu trách nhiệm chính**: **Tech Lead**.
- **Mục tiêu**: Thiết lập cấu hình Router trung tâm và bố cục dùng chung (Main Shell Layout) gồm Bottom Navigation Bar chứa các Tab: Cửa hàng (Storefront), Giỏ hàng (Cart), Thư viện (Library) và Cá nhân (Profile).

---

## 2. Bố Cục Dùng Chung (StatefulShellRoute)
Để tránh việc các màn hình chính phải tự định nghĩa lại Bottom Navigation Bar ở chân trang, chúng ta sử dụng cơ chế `StatefulShellRoute` của GoRouter.
- Cơ chế này cho phép các màn hình được lồng bên trong một "Shell" dùng chung (`MainShellScreen`).
- Giữ nguyên trạng thái (KeepAlive) của từng tab. Ví dụ: khi bạn đang lướt Cửa hàng (Tab 1), chuyển sang Giỏ hàng (Tab 2), rồi quay lại Cửa hàng, vị trí cuộn trang của Cửa hàng vẫn được giữ nguyên.

---

## 3. Quy Tắc Khai Báo Routes (Mẫu Cho Thành Viên)
Khi một thành viên tạo xong màn hình giao diện mới (ví dụ màn hình Chi tiết game), họ phải thông báo cho Tech Lead để khai báo đường dẫn trong file `app_router.dart`:

```dart
// Ví dụ khai báo route lồng nhau
GoRoute(
  path: '/game-detail/:id',
  builder: (context, state) {
    final gameId = state.pathParameters['id']!;
    return GameDetailScreen(gameId: gameId);
  },
)
```

---

## 4. Hướng Dẫn Điều Hướng (Navigation Guide)
Bắt buộc sử dụng GoRouter Extension thay vì Navigator thuần của Flutter:

### 4.1. Điều hướng chuyển hẳn trang (Thay đổi ngăn xếp)
Dùng khi chuyển giữa các Tab chính ở chân trang:
```dart
context.go('/cart');
```

### 4.2. Đẩy thêm trang mới lên đỉnh ngăn xếp (Stack Navigation)
Dùng khi đi vào các trang con (như từ Trang chủ đi vào Trang Chi tiết game, có nút Back ở góc trên để quay lại):
```dart
context.push('/game-detail/123');
```

### 4.3. Quay lại trang trước
```dart
context.pop();
```
*(Lưu ý: Luôn kiểm tra `context.mounted` trước khi thực hiện điều hướng sau các hàm gọi API không đồng bộ `await`).*
