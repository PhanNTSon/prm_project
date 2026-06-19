# **Acknowledgement**

Dự án được thực hiện bởi Group 1 - SE1933 dựa trên tài liệu yêu cầu (RDS/SRS) của phiên bản web cũ, hiện đã được thiết kế lại để tối ưu hóa cho ứng dụng di động đa nền tảng bằng Flutter.

# **Definition and Acronyms**

| Acronym | Definition |
| :---: | ----- |
| JWT | JSON Web Token |
| CS | Centurion Store |
| BA | Business Analysis |
| BR | Business Rule |
| ERD | Entity Relationship Diagram |
| GUI | Graphical User Interface |
| PM | Project Manager |
| SDD | Software Design Description |
| SRS | Software Requirement Specification |
| UAT | User Acceptance Test |
| UC | Use Case |
| API | Application Program Interface |

# **I. Project Introduction**

## **1\. Overview**

### **1.1 Project Information**
- **Project Name:** Centurion Store (Flutter Mobile App)
- **Platform:** Android & iOS (Flutter)
- **Backend:** Spring Boot (REST API)
- **Prepared by:** SE1933 - Group 1

### **1.2 Project Team**
| *STT* | *Member* | *Task/Screen* |
| :---- | :---- | :---- |
| *1* | Nguyễn Văn A | Authentication & Profile |
| *2* | Nguyễn Văn B | Storefront (Home, Search, Game Details) |
| *3* | Nguyễn Văn C | Cart, Payment (VNPay), & Wallet |
| *4* | Nguyễn Văn D | Library & UI Kit Components |
| *5* | Tech Lead | Architecture, Routing, Base Network, Testing |

## **2\. Product Background**

Thị trường game kỹ thuật số đang ngày càng mở rộng, tuy nhiên người dùng di động thường gặp khó khăn khi muốn theo dõi, mua sắm và quản lý thư viện game PC/Console của họ một cách nhanh chóng. Dự án **Centurion Store Mobile App** được xây dựng nhằm cung cấp một nền tảng di động tiện lợi, cho phép người dùng (game thủ) truy cập vào cửa hàng game, nạp tiền vào ví điện tử thông qua VNPay, mua sắm trò chơi, và xem thư viện game đã sở hữu mọi lúc mọi nơi thông qua ứng dụng điện thoại.

## **3\. Existing Solutions**

- **Steam Mobile App:** Ứng dụng chính thức của Steam cho phép mua sắm và xác thực, tuy nhiên giao diện đôi khi phức tạp và nặng nề.
- **PlayStation App / Xbox App:** Cho phép mua sắm và quản lý thư viện game trên console.
Centurion Store Mobile App học hỏi từ các hệ thống này bằng cách tối giản hóa trải nghiệm UI/UX thành kiến trúc 4 tab chính: Cửa hàng, Giỏ hàng, Thư viện, và Cá nhân.

## **4\. Project Scope & Limitations**

**In Scope:**
- Ứng dụng di động (Android/iOS) được phát triển bằng Flutter.
- Đăng ký, Đăng nhập, Quản lý hồ sơ người dùng (Auth).
- Duyệt danh mục trò chơi (Home, Top Selling, Under $5, v.v.).
- Xem chi tiết trò chơi.
- Quản lý giỏ hàng và thanh toán bằng số dư Ví (Wallet).
- Nạp tiền vào ví thông qua cổng thanh toán VNPay (hiển thị InAppWebView).
- Quản lý Thư viện Game đã mua (Library).

**Out of Scope (Limitations):**
- Không hỗ trợ tải xuống và chơi game trực tiếp trên điện thoại (vì hệ thống là cửa hàng bán game PC/Desktop).
- Không bao gồm các chức năng quản lý cao cấp dành cho Publisher và Admin (Quản lý và upload game mới sẽ được thực hiện trên phiên bản Web/Desktop cũ).
- Không hỗ trợ chat realtime trong phiên bản di động V1.0 (sẽ xem xét bổ sung sau).


# **II. Software Requirement Specification**

## **1\. Functional Specifications**


### **1.1 Authentication & Profile**

#### ***1.1.1 Login & Registration***

##### 1.1.1.1 Login Screen
###### a. UI Specifications
**Login Screen**
![login_screen.png](reports/assets/login_screen.png)
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


# **III. Software Design Description**

## **1\. System Design**

### **1.1 System Architecture**

Kiến trúc tổng thể của hệ thống dựa trên mô hình Client-Server.

![system_architecture](reports/assets/system_architecture.png)

- **Mobile Client (Flutter):** Chịu trách nhiệm hiển thị giao diện người dùng, quản lý State cục bộ, điều hướng (GoRouter) và giao tiếp mạng (Dio). Thông tin phiên đăng nhập (JWT Token) được lưu trữ qua `shared_preferences`.
- **VNPay Sandbox:** Khi cần nạp tiền, Flutter App mở một `InAppWebView` trỏ đến đường dẫn VNPay do Backend tạo ra. Người dùng thao tác thanh toán, sau đó VNPay chuyển hướng (callback) URL chứa tham số giao dịch. App đánh chặn URL này và báo cáo kết quả cho người dùng.
- **Backend & Database:** Đóng vai trò là nguồn dữ liệu sự thật duy nhất (Single Source of Truth), quản lý nghiệp vụ, kiểm tra tính hợp lệ của giao dịch và lưu trữ trên PostgreSQL.

### **1.2 Package Diagram**

Dự án Flutter áp dụng kiến trúc **Feature-First (Phân tách theo tính năng)**. Phương pháp này giúp chia nhỏ dự án thành các module độc lập, cho phép các lập trình viên làm việc song song mà không bị xung đột (conflict) mã nguồn.

![package_diagram](reports/assets/package_diagram.png)

Mỗi feature con (ví dụ `storefront`) sẽ tiếp tục được chia theo mô hình 3 tầng (3-Layer Architecture):

- `data/`: Chứa các model (DTO) và repository giao tiếp với API.
- `providers/`: Chứa logic xử lý trạng thái (State Management) cho feature đó.
- `views/`: Chứa các màn hình (Screen) và các thành phần UI (Widget) cụ thể của feature đó.

## **2\. Database Design**

_Thiết kế CSDL được giữ nguyên theo CSDL PostgreSQL hiện hành của Backend Spring Boot._

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


# **IV. Software Testing Documentation**

## **1\. Scope of Testing**

Phạm vi kiểm thử tập trung vào tính đúng đắn của logic nội bộ ứng dụng Flutter Mobile, đặc biệt là các thành phần cốt lõi: Tầng kết nối mạng (Network Layer) và Định tuyến hệ thống (Routing Guard).

- **In Scope:** Unit Test cho các cơ chế gán Token tự động (AuthInterceptor), lưu trữ bảo mật (SecureStorageService) và điều hướng GoRouter (Auth Guard).
- **Out of Scope:** Các chức năng thuộc về Backend (đã có bộ kiểm thử Postman/Backend riêng), UI Test chi tiết cho từng màn hình (sẽ thực hiện manual test ở giai đoạn này).

## **2\. Test Strategy**

### **2.1 Testing Types**

- **Functional Testing:** Đảm bảo hệ thống điều hướng đúng mục tiêu (ví dụ: mất token thì trả về `/login`).
- **Security Testing:** Đảm bảo token JWT được lưu trữ và truy xuất an toàn, không bị rò rỉ. Đảm bảo ứng dụng từ chối mở trang `/home` nếu không có token.

### **2.2 Test Levels**

- **Unit Testing:** Kiểm tra độc lập các component cốt lõi (`DioClient`, `AuthInterceptor`).
- **Widget Testing:** Bơm (Pump) hệ thống GoRouter vào một cây Widget ảo để giả lập sự kiện chuyển trang và xác minh logic Guard hoạt động bình thường.
- **Manual Testing:** Cài đặt ứng dụng trên Emulator hoặc thiết bị thật để kiểm tra luồng trải nghiệm thực tế (chạm, cuộn, hiệu ứng).

### **2.3 Supporting Tools**

- Thư viện `flutter_test` (Mặc định của SDK Flutter).
- `SharedPreferences Mock`: Sử dụng `SharedPreferences.setMockInitialValues({})` để giả lập bộ nhớ tĩnh khi chạy Unit Test nhằm cách ly hệ thống lưu trữ thật mà không cần thiết bị.

## **3\. Test Cases**

Các bài kiểm thử tự động (Automated Test) đã được triển khai trong dự án theo cấu trúc:

![testcase_architecture](reports/assets/testcase_architecture.png)

### Chi tiết các Test Case quan trọng:

1. **TC_NET_01 (Header Injection):** Gửi Request API bất kỳ -> Kỳ vọng tự động chèn `Authorization: Bearer <token>`.
2. **TC_NET_03 (401 Error Clean):** Giả lập Backend trả về lỗi HTTP 401 -> Kỳ vọng App tự động gọi hàm xóa sạch Token trong Secure Storage.
3. **TC_RTE_01 (Redirect No Token):** Mở App nhưng bộ nhớ rỗng -> Kỳ vọng `GoRouter` chặn truy cập trang Chủ và hất văng về màn hình Đăng nhập.
4. **TC_RTE_02 (Direct Token Exists):** Mở App khi bộ nhớ có Token hợp lệ -> Kỳ vọng `GoRouter` cho phép bỏ qua trang Đăng nhập và đi thẳng vào Trang Chủ.

## **4\. Test Reports**

Hiện tại (Phiên bản V1.0 Foundation):

- **Unit/Widget Tests:** Chạy lệnh `flutter test` báo cáo 100% Pass (Thành công) cho mọi bài kiểm thử Tầng Mạng và Định Tuyến.
- **Manual Tests:** Các kịch bản KeepAlive của BottomNavigationBar, lồng ghép trang chi tiết (Nested Routing) và hiển thị WebView VNPay đã được xác minh thành công trên Android Emulator (Pixel 7 API 34).


