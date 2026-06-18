# **II. Software Requirement Specification**

## **1\. Functional Specifications**

### **1.1 Authentication & Profile**

#### ***1.1.1 Login & Registration***

##### 1.1.1.1 Login Screen
###### a. UI Specifications
**Login Screen**
- **Brief Description:** Cho phép người dùng đăng nhập vào hệ thống bằng tài khoản (Username/Password) hoặc tài khoản Google.
- **Mockup UI Layout:** `[Mockup: Login Screen với nền sẫm màu Steam, logo Centurion, các trường input Username, Password, nút Đăng nhập và nút Đăng nhập bằng Google]`
- **Component Requirements:**
  - `Username Field`: Bắt buộc nhập, tối thiểu 3 ký tự.
  - `Password Field`: Bắt buộc nhập, ẩn ký tự bằng dấu chấm.
  - `Login Button`: Gọi API `/api/auth/login`. Khi thành công, lưu JWT vào `SecureStorage` và chuyển đến `/home`.
  - `Login with Google Button`: Đăng nhập thông qua OAuth2.

##### 1.1.1.2 Register Screen
###### a. UI Specifications
**Register Screen**
- **Brief Description:** Tạo tài khoản mới bằng email.
- **Mockup UI Layout:** `[Mockup: Màn hình điền Email và nút gửi OTP]`
- **Component Requirements:**
  - `Email Field`: Bắt buộc, đúng định dạng email. Gọi `/api/auth/send-verification-otp` để gửi mã xác nhận.

#### ***1.1.2 Profile Management***

##### 1.1.2.1 User Profile Screen
###### a. UI Specifications
**User Profile Screen**
- **Brief Description:** Hiển thị thông tin cá nhân và số dư ví.
- **Mockup UI Layout:** `[Mockup: Màn hình thông tin User với Avatar, Username, Email, Số dư ví và nút Logout]`
- **Component Requirements:**
  - `Wallet Balance Display`: Hiển thị số dư hiện tại của tài khoản.
  - `Logout Button`: Xóa token JWT khỏi máy và chuyển hướng về `/login`.

---

### **1.2 Storefront & Catalog**

#### ***1.2.1 Catalog Navigation***

##### 1.2.1.1 Home Store Screen
###### a. UI Specifications
**Home Store Screen**
- **Brief Description:** Màn hình chính hiển thị danh mục các trò chơi.
- **Mockup UI Layout:** `[Mockup: Thanh search trên cùng, các mục cuộn ngang: Game Under $5, Top Selling, New Publish]`
- **Component Requirements:**
  - `Search Bar`: Tìm kiếm game bằng từ khóa.
  - `Game Cards`: Hiển thị hình ảnh, tên game, và giá tiền. Click vào sẽ điều hướng đến chi tiết game.

#### ***1.2.2 Game Details***

##### 1.2.2.1 Game Detail Screen
###### a. UI Specifications
**Game Detail Screen**
- **Brief Description:** Xem thông tin chi tiết một game cụ thể.
- **Mockup UI Layout:** `[Mockup: Ảnh banner lớn, mô tả ngắn, giá bán, cấu hình hệ thống, nút Add to Cart]`
- **Component Requirements:**
  - `Price Tag / Add to Cart Button`: Nếu game đã sở hữu, đổi thành nút "In Library". Nếu chưa, hiển thị nút "Add to Cart" gọi API `/user/cart/add`.

---

### **1.3 Transaction & Payments**

#### ***1.3.1 Cart Operations***

##### 1.3.1.1 Cart Screen
###### a. UI Specifications
**Cart Screen**
- **Brief Description:** Quản lý giỏ hàng hiện tại.
- **Mockup UI Layout:** `[Mockup: Danh sách các game trong giỏ hàng, tổng tiền, nút Checkout]`
- **Component Requirements:**
  - `Remove Button`: Xóa game khỏi giỏ hàng.
  - `Checkout Button`: Thanh toán toàn bộ game bằng số dư ví.

#### ***1.3.2 Payouts & Topups***

##### 1.3.2.1 Wallet Screen & Payment WebView
###### a. UI Specifications
**Wallet & VNPay Screen**
- **Brief Description:** Nạp tiền vào tài khoản thông qua VNPay Sandbox.
- **Mockup UI Layout:** `[Mockup: Giao diện nhập số tiền cần nạp, sau đó mở InAppWebView kết nối với cổng thanh toán VNPay]`
- **Component Requirements:**
  - `Amount Input`: Nhập số tiền (USD).
  - `VNPay InAppWebView`: Chạy trang thanh toán và tự động bắt URL IPN (`/vnpay-ipn`) để đóng webview khi hoàn thành.

---

### **1.4 Game Library**

#### ***1.4.1 Library Viewing***

##### 1.4.1.1 Library Screen
###### a. UI Specifications
**Library Screen**
- **Brief Description:** Quản lý danh sách các game người dùng đã sở hữu.
- **Mockup UI Layout:** `[Mockup: Grid View hiển thị các game có trong thư viện của người dùng]`
- **Component Requirements:**
  - `Playtime Counter`: Hiển thị số giờ chơi tích lũy của từng game.

---

## **2\. Non-Functional Requirements**

### **2.1 External Interfaces**
- **User Interface (UI):** Thiết kế tối màu (Dark Mode) theo chuẩn màu của hệ thống Steam (`Color(0xFF1B2838)`). Sử dụng Material 3 Design với `BottomNavigationBar`.
- **Software Interfaces:** Giao tiếp hoàn toàn qua RESTful API với Backend (Spring Boot). Định dạng dữ liệu trao đổi là JSON.

### **2.2 Quality Attributes**
- **Security:** Mọi HTTP Request sau khi đăng nhập phải được đính kèm Header `Authorization: Bearer <token>`. Nếu Backend trả về HTTP 401 (Unauthorized), hệ thống tự động xóa bộ nhớ và đá người dùng về trang Đăng nhập.
- **Usability:** Chuyển đổi giữa 4 Tab chính (Store, Cart, Library, Profile) không được gây load lại trang từ đầu (giữ nguyên State bằng `StatefulShellRoute` của GoRouter).
- **Performance:** Hình ảnh tải về phải được cache lại bằng thư viện `cached_network_image` để giảm băng thông và tăng tốc độ hiển thị.

## **3\. Requirement Appendix**

### **3.1 Business Rules**
- **BR1:** Người dùng không được phép thêm một game đã có trong Library vào Cart. Cần gọi API `/user/library/contain/{gameId}` để kiểm tra trước khi hiện nút "Add to Cart".
- **BR2:** Tổng tiền thanh toán giỏ hàng không được vượt quá số dư ví hiện tại. Nếu vượt quá, vô hiệu hóa nút Checkout và yêu cầu Nạp tiền.

### **3.2 Common Requirements**
- Mọi API call cần được cấu hình timeout là 10 giây.
- Hiển thị màn hình Loading Spinner khi đang tải dữ liệu từ server.

### **3.3 Application Messages List**
- "Registration successful!" - Đăng ký thành công.
- "Invalid username or password." - Sai tài khoản hoặc mật khẩu.
- "OTP verified successfully." - Xác thực OTP thành công.
- "Adding game to cart successfully." - Thêm vào giỏ hàng thành công.
- "Checkout successfully." - Thanh toán thành công.

### **3.4 Other Requirements…**
- Không có yêu cầu đặc biệt khác.
