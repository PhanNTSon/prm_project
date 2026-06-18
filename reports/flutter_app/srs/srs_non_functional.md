## **2\. Non-Functional Requirements**

### **2.1 External Interfaces**
- **User Interface (UI):** Thiết kế tối màu (Dark Mode) theo chuẩn màu của hệ thống Steam (`Color(0xFF1B2838)`). Sử dụng Material 3 Design với `BottomNavigationBar`.
- **Software Interfaces:** Giao tiếp hoàn toàn qua RESTful API với Backend (Spring Boot). Định dạng dữ liệu trao đổi là JSON.

### **2.2 Quality Attributes**
- **Security:** Mọi HTTP Request sau khi đăng nhập phải được đính kèm Header `Authorization: Bearer <token>`. Nếu Backend trả về HTTP 401 (Unauthorized), hệ thống tự động xóa bộ nhớ và đá người dùng về trang Đăng nhập.
- **Usability:** Chuyển đổi giữa 4 Tab chính (Store, Cart, Library, Profile) không được gây load lại trang từ đầu (giữ nguyên State bằng `StatefulShellRoute` của GoRouter).
- **Performance:** Hình ảnh tải về phải được cache lại bằng thư viện `cached_network_image` để giảm băng thông và tăng tốc độ hiển thị.
