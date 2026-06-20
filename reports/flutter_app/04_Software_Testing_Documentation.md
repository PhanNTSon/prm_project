# **IV. Software Testing Documentation**

## **1\. Scope of Testing**

The scope of testing focuses on the correctness of the internal logic of the Flutter Mobile application, especially the core components: the Network Layer and the Routing Guard.

- **In Scope:** Unit Tests for automatic Token assignment mechanisms (AuthInterceptor), local storage management (SecureStorageService), GoRouter navigation logic (Auth Guard), WebSocket connection/disconnect mechanisms, and realtime state updates (Wallet and Notification providers).
- **Out of Scope:** Backend-related functions (which have separate Postman/Backend test suites), and detailed UI testing for each screen (manual testing will be performed at this stage).

## **2\. Test Strategy**

### **2.1 Testing Types**

- **Functional Testing:** Ensures that the navigation system directs to the correct destination (e.g., redirecting to `/login` when the token is missing).
- **Security Testing:** Ensures that the JWT token is stored and retrieved securely without leakage. Verifies that the app denies access to the `/home` page when no token is present.

### **2.2 Test Levels**

- **Unit Testing:** Independently tests the core components (`DioClient`, `AuthInterceptor`).
- **Widget Testing:** Pumps the GoRouter system into a virtual Widget tree to simulate screen transitions and verify that the Guard logic works as expected.
- **Manual Testing:** Installs the application on an Emulator or a physical device to verify the actual user experience flow (taps, scrolls, transitions).

### **2.3 Supporting Tools**

- The `flutter_test` library (Default library from the Flutter SDK).
- `SharedPreferences Mock`: Uses `SharedPreferences.setMockInitialValues({})` to simulate local storage when running Unit Tests to isolate the real storage system without a device.

## **3\. Test Cases**

Automated tests have been deployed in the project according to the following structure:

{{DIAGRAM:testcase_architecture}}

### Important Test Case Details:

1. **TC_NET_01 (Header Injection):** Send any API request -> Expect automatic injection of `Authorization: Bearer <token>`.
2. **TC_NET_03 (401 Error Clean):** Simulate Backend returning HTTP 401 error -> Expect the App to automatically invoke the function to clear all token data in Secure Storage.
3. **TC_RTE_01 (Redirect No Token):** Open the App with empty storage -> Expect `GoRouter` to block access to the Home page and redirect to the Login screen.
4. **TC_RTE_02 (Direct Token Exists):** Open the App when a valid Token exists in storage -> Expect `GoRouter` to bypass the Login page and navigate directly to the Home page.
5. **TC_WS_01 (WebSocket Connection):** Establish login session -> Expect automatic connection to `ws-community` endpoint and token query validation.
6. **TC_WS_02 (Realtime Balance):** Receive balance frame over WebSocket -> Expect `WalletProvider` to automatically parse and reflect the balance instantly on UI listeners.
7. **TC_WS_03 (Realtime Notification):** Receive notification frame over WebSocket -> Expect `NotificationProvider` to increment unread badge count and insert new message.

## **4\. Test Reports**

Current State (V1.0 Foundation Version):

- **Unit/Widget Tests:** Running `flutter test` reports 100% Pass (Success) for all 26 tests across Authentication, Storage, Network, and WebSocket/Realtime components.
- **Manual Tests:** KeepAlive behaviors of the BottomNavigationBar, nested details navigation (Nested Routing), and VNPay WebView integration have been successfully verified on the Android Emulator (Pixel 7 API 34).
