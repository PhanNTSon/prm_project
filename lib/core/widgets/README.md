# 🎨 UI Kit - Thành Phần Giao Diện Dùng Chung (Core Widgets)

Thư mục này chứa toàn bộ các Widget tái sử dụng được thiết kế đồng bộ theo phong cách giao diện của Steam (Dark Mode, bo góc nhẹ, viền mảnh phát sáng xanh lam/xám tối).

---

## 1. Mục Tiêu & Trách Nhiệm
- **Chịu trách nhiệm chính**: **Developer D**.
- **Mục tiêu**: Đóng gói các thành phần giao diện nhỏ như Nút bấm (Button), Hộp nhập liệu (TextField), Thẻ hiển thị Game (GameCard), Hộp thoại cảnh báo (Dialog)... thành các Widget dùng chung để các Developer khác gọi ngay lập tức, tiết kiệm thời gian code và đảm bảo giao diện thống nhất 100%.

---

## 2. Các Quy Tắc Khi Viết Core Widget
1. **Stateless Widget**: Đa số các Core Widget nên là `StatelessWidget` để dễ kiểm soát hiệu năng. Mọi trạng thái động bên trong (nếu có) nên được quản lý bởi Widget cha hoặc truyền qua callback (ví dụ: `onPressed`, `onChanged`).
2. **Tham số hóa linh hoạt (Constructor Parameters)**:
   - Các thuộc tính như text, icon, color, padding, width, height... nên được truyền vào từ bên ngoài thay vì hardcode giá trị cố định.
   - Sử dụng các giá trị mặc định (`defaultValue`) hợp lý theo thiết kế Steam để giảm thiểu số lượng tham số bắt buộc.
3. **Màu sắc và Theme**:
   - Bắt buộc lấy màu từ `Theme.of(context).colorScheme` hoặc dùng lớp hằng số `AppColors` trong `core/constants/`.
   - Không được viết cứng mã Hex màu như `color: Color(0xFF171A21)` trực tiếp trong code Widget.

---

## 3. Ví Dụ Về Widget Dùng Chung Mẫu (`SteamButton`)
Dưới đây là thiết kế chuẩn cho một Custom Button phong cách Steam:

```dart
import 'package:flutter/material.dart';

class SteamButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const SteamButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
    );
  }
}
```

---

## 4. Cách Sử Dụng Cho Các Lập Trình Viên Khác
Khi viết các màn hình tính năng (trong `features/`), thay vì tự viết các nút bấm hay ô nhập liệu, bạn chỉ cần import thư viện dùng chung:

```dart
import '../../../core/widgets/steam_button.dart';

// Trong build()
SteamButton(
  text: 'Mua Ngay',
  onPressed: () {
    // Logic mua game
  },
)
```
