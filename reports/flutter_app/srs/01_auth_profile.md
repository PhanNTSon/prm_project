### **1.1 Authentication & Profile**

#### ***1.1.1 Login & Registration***

##### 1.1.1.1 Login Screen
- **Function Description:** Allows users to log into the system using their account credentials (Username/Password) or a Google account.
- **Screen Layout:**
  {{IMAGE:login_screen.png}}
  `[Mockup: Login Screen with Steam-like dark theme, Centurion logo, input fields for Username, Password, Login button, and Google Sign-in button]`
- **Function Detail:**
  - `Username Field`: Required input, minimum 3 characters.
  - `Password Field`: Required input, characters obscured by dots.
  - `Login Button`: Calls API `/api/auth/login`. On success, stores JWT in local storage (SharedPreferences) and redirects to `/home`.
  - `Login with Google Button`: Login via OAuth2.

##### 1.1.1.2 Register Screen
- **Function Description:** Create a new account using an email.
- **Screen Layout:**
  {{IMAGE:register_screen.png}}
  `[Mockup: Screen to input Email and send OTP button]`
- **Function Detail:**
  - `Email Field`: Required, valid email format. Calls `/api/auth/send-verification-otp` to send the verification code.

#### ***1.1.2 Profile Management***

##### 1.1.2.1 User Profile Screen
- **Function Description:** Displays user profile details and their wallet balance.
- **Screen Layout:**
  {{IMAGE:user_profile_screen.png}}
  `[Mockup: User profile screen showing Avatar, Username, Email, Wallet balance, and Logout button]`
- **Function Detail:**
  - `Wallet Balance Display`: Displays the current balance of the account (automatically updated in real-time via WebSocket STOMP subscription on `/user/queue/wallet.balance`).
  - `Logout Button`: Clears JWT token from local storage (SharedPreferences) and redirects to `/login`.

---
