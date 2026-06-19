### **1.1 Authentication & Profile**

#### ***1.1.1 Login & Registration***

##### 1.1.1.1 Login Screen
###### a. UI Specifications
**Login Screen**
{{IMAGE:login_screen.png}}
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
