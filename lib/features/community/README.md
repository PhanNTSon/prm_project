# 💬 Tính Năng Cộng Đồng (Community / Chat)

Thư mục này chứa toàn bộ logic và giao diện liên quan đến tính năng Cộng đồng của ứng dụng, bao gồm quản lý Danh sách bạn bè và Trò chuyện thời gian thực (Realtime Chat). Đây là một trong những tính năng cốt lõi do **Tech Lead** đảm nhiệm.

## 1. Cấu trúc thư mục

- `data/`: Chứa các Model (`friend_model.dart`, `friend_invite_model.dart`) và Repository (`friend_repository.dart`) dùng để tương tác với API lấy dữ liệu bạn bè ban đầu.
- `providers/`: 
  - `friend_provider.dart`: Quản lý danh sách bạn bè, trạng thái lời mời kết bạn và cung cấp dữ liệu cho màn hình danh sách Chat.
  - `chat_provider.dart`: Cầu nối trực tiếp với `WebSocketService`. Quản lý lịch sử tin nhắn của đoạn hội thoại hiện tại, gửi tin nhắn đi và cập nhật UI khi có tin nhắn mới tới.
- `views/screens/`:
  - `chat_list_screen.dart`: Màn hình danh sách bạn bè để chọn người chat (tab cuối cùng của BottomNavigationBar).
  - `chat_detail_screen.dart`: Màn hình hiển thị bong bóng chat (chat bubbles) chi tiết với một user cụ thể.

## 2. Luồng hoạt động của Tin nhắn Realtime (Data Flow)

Tính năng Chat không dựa hoàn toàn vào API polling (gọi API liên tục), mà sử dụng giao thức STOMP thông qua `WebSocketService` nằm ở thư mục `core/network`.

### Khi Gửi Tin Nhắn
1. Người dùng gõ text và bấm gửi tại `chat_detail_screen.dart`.
2. Hàm `sendMessage()` trong `chat_provider.dart` được gọi.
3. `ChatProvider` chuyển tiếp nội dung này cho `WebSocketService` để đẩy gói tin lên STOMP Server (thường là qua destination `/app/chat.sendMessage`).
4. Ngay lập tức, `ChatProvider` chèn tin nhắn vừa gửi vào danh sách cục bộ (Optimistic UI) và gọi `notifyListeners()` để người dùng thấy tin nhắn hiện lên tức thì.

### Khi Nhận Tin Nhắn
1. Khi App khởi động hoặc user đăng nhập, `WebSocketService` đã mở sẵn kết nối.
2. `ChatProvider` sẽ gọi lệnh `subscribe` vào kênh chat cá nhân của user (VD: `/user/queue/chat`).
3. Khi Server đẩy tin nhắn tới, callback đăng ký trong `WebSocketService` sẽ được kích hoạt, truyền dữ liệu JSON sang cho `ChatProvider`.
4. `ChatProvider` phân tích dữ liệu, đóng gói thành Message model, chèn vào danh sách và gọi `notifyListeners()`.
5. Màn hình `chat_detail_screen.dart` (nếu đang mở) sẽ tự động vẽ thêm bong bóng chat mới nhận.

## 3. Lưu ý dành cho lập trình viên
- **Không tự ý ngắt kết nối WebSocket** trong tính năng này. Việc đóng mở đường truyền STOMP thuộc thẩm quyền của `AuthProvider` (tự động theo vòng đời đăng nhập).
- Các thay đổi liên quan đến cấu trúc tin nhắn (JSON payload) cần được trao đổi chéo với Backend để đảm bảo quá trình Parsing trong Provider không bị lỗi văng App.
