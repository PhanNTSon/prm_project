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
