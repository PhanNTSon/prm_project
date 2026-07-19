### **1.1 Authentication & Profile**

#### ***1.1.1 Login & Registration***

##### 1.1.1.1 Login Screen
- **Function Description:** Allows users to log into the system using their Username and Password credentials.
- **Screen Layout:**
  {{IMAGE:login_screen.png}}
  `[Mockup: Login Screen — Dark Steam-like theme, input fields for Username, Password with show/hide toggle, Login button, Forgot Password link, Register link]`
- **Function Detail:**
  - `Username Field`: Required input. No format restriction.
  - `Password Field`: Required input, characters obscured. Toggle show/hide with eye icon.
  - `Login Button`: Validates form → Calls `POST /api/auth/login` with `{username, password}`. On success: stores JWT in SharedPreferences and redirects to `/home`. On failure: displays inline error message. Button is disabled and shows spinner during loading.
  - `Forgot Password Link`: Navigates to `/forgot-password`.
  - `Register Link`: Navigates to `/register`.

##### 1.1.1.2 Register Screen
- **Function Description:** Step 1 of 3-step account creation flow. User inputs Email, selects Country, agrees to Terms of Service, then triggers OTP sending.
- **Screen Layout:**
  {{IMAGE:register_screen.png}}
  `[Mockup: Dark theme — Title "TẠO TÀI KHOẢN CỦA BẠN", Email field, Confirm Email field, Country dropdown, hCaptcha placeholder, Terms checkbox, "Tiếp tục" button]`
- **Function Detail:**
  - `Email Field`: Required, valid email format.
  - `Confirm Email Field`: Required, must match Email field exactly.
  - `Country Dropdown`: Required, defaults to "Việt Nam".
  - `Terms Checkbox`: Required. If unchecked, shows SnackBar warning on submit.
  - `"Tiếp tục" Button`: 1. Validates form. 2. Calls `GET /api/auth/check-email` to verify availability. 3. If available, calls `POST /api/auth/send-verification-otp`. 4. Navigates to `/verify-email` passing `RegisterRequestModel` as extra.

##### 1.1.1.3 Verify Email Screen
- **Function Description:** Step 2 of registration flow. User inputs the 6-digit OTP sent to their email.
- **Screen Layout:**
  {{IMAGE:verify_email_screen.png}}
  `[Mockup: Dark theme — Title "XÁC THỰC EMAIL", email subtitle, 6 individual OTP input boxes, "Xác nhận" button, "Gửi lại mã xác thực" link]`
- **Function Detail:**
  - `OTP Input (×6)`: Each box accepts 1 digit. Auto-focus advances to next box on input; returns to previous on delete. Numeric keyboard only.
  - `"Xác nhận" Button`: Concatenates 6 digits → Calls `POST /api/auth/verify-otp` with `{email, otp}`. On success: navigates to `/register-details`. On failure: shows inline error.
  - `"Gửi lại mã" Link`: Re-calls `POST /api/auth/send-verification-otp` to resend OTP.

##### 1.1.1.4 Register Details Screen
- **Function Description:** Step 3 (final) of registration flow. User sets Username and Password to complete account creation.
- **Screen Layout:**
  {{IMAGE:register_details_screen.png}}
  `[Mockup: Dark theme — Title "THIẾT LẬP TÀI KHOẢN", email subtitle, Username field with real-time availability indicator, Password field, Confirm Password field, "Hoàn tất" button]`
- **Function Detail:**
  - `Username Field`: Required, 3–32 chars, letters/numbers/underscore only. Calls `GET /api/auth/check-username` on change for real-time availability check. Shows green "✓ Available" or red "✗ Already taken".
  - `Password Field`: Required, min 8 chars, must contain uppercase, lowercase, digit, and special character.
  - `Confirm Password Field`: Required, must match Password exactly.
  - `"Hoàn tất" Button`: Validates all fields → Calls `POST /api/auth/register` with `{email, username, password, country}`. On success: shows SnackBar "Đăng ký thành công!" and navigates to `/login`.

##### 1.1.1.5 Forgot Password Screen
- **Function Description:** User requests a password reset OTP sent to their registered email.
- **Screen Layout:**
  {{IMAGE:forgot_password_screen.png}}
  `[Mockup: Dark theme — Title "QUÊN MẬT KHẨU", description text, Email field, "Gửi mã xác thực" button, "Quay lại đăng nhập" link]`
- **Function Detail:**
  - `Email Field`: Required, valid email format.
  - `"Gửi mã xác thực" Button`: Calls `POST /api/password/request` with `{email}`. On success: shows SnackBar and navigates to `/reset-password` passing email as extra.
  - `"Quay lại đăng nhập" Link`: Navigates back to `/login` via `context.go()`.

##### 1.1.1.6 Reset Password Screen
- **Function Description:** User inputs the OTP received by email and sets a new password.
- **Screen Layout:**
  {{IMAGE:reset_password_screen.png}}
  `[Mockup: Dark theme — Title "ĐẶT LẠI MẬT KHẨU", email subtitle, 6 OTP boxes, New Password field, Confirm Password field, "Xác nhận" button]`
- **Function Detail:**
  - `OTP Input (×6)`: Same behavior as Verify Email screen.
  - `New Password Field`: Required, min 8 chars, must contain uppercase, lowercase, digit, and special character.
  - `Confirm Password Field`: Required, must match New Password exactly.
  - `"Xác nhận" Button`: Validates OTP length and form → Calls `POST /api/password/reset` with `{email, otp, newPassword, confirmPassword}`. On success: shows SnackBar and navigates to `/login`.

#### ***1.1.2 Profile Management***

##### 1.1.2.1 User Profile Screen
- **Function Description:** Displays user's public profile. `/profile` shows own profile with full controls; `/profile/:userId` shows another user's public profile.
- **Screen Layout:**
  {{IMAGE:user_profile_screen.png}}
  `[Mockup: Dark theme — AppBar "Trang cá nhân" + notification badge, Avatar, displayName, @username, country, role badge, "Chỉnh sửa hồ sơ" button, Wallet card, Stats row (Games | Reviews), Bio section, Menu section]`
- **Function Detail:**
  - `Notification Badge`: Shows unread count from `NotificationProvider` (WebSocket realtime). Shows "99+" when count exceeds 99.
  - `Profile Avatar`: Loads `avatarUrl` via `CachedNetworkImage`. Falls back to CircleAvatar showing first letter of username.
  - `Display Name`: Shows `profileName` if set; otherwise falls back to `username`.
  - `Role Badge`: `ROLE_USER` → "Người dùng" (blue), `ROLE_PUBLISHER` → "Publisher" (amber), `ROLE_ADMIN` → "Admin" (red).
  - `Wallet Card`: Only shown on own profile. Balance from `PaymentProvider` (synced on load). "Nạp tiền" navigates to `/account/wallet`.
  - `Stats Row`: Shows `totalGames` and `reviewCount` from API.
  - `Pull to Refresh`: Re-calls `GET /user/profile/:userId` to reload data.
  - `Logout`: Shows confirmation dialog → Calls `AuthProvider.logout()` → Clears token → Router redirects to `/login`.

##### 1.1.2.2 Account Detail Screen
- **Function Description:** Displays current user's private account details including wallet balance, email, and security settings links.
- **Screen Layout:**
  {{IMAGE:account_detail_screen.png}}
  `[Mockup: Dark theme — AppBar "Thông tin tài khoản", Avatar + "Chỉnh sửa hồ sơ" link, Wallet card (balance + "Nạp tiền"), Email display, "Đổi mật khẩu" link]`
- **Function Detail:**
  - `Avatar Section`: Shows avatar and displayName. "Chỉnh sửa hồ sơ" navigates to `/account/edit` passing current `ProfileModel` as extra.
  - `Wallet Balance`: From `PaymentProvider.balance` (USD, synced via `loadBalance()` on screen load).
  - `"Đổi mật khẩu" Link`: Navigates to `/change-password`.

---