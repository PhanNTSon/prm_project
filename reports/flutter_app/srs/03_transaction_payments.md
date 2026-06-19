### **1.3 Transaction & Payments**

#### ***1.3.1 Cart Operations***

##### 1.3.1.1 Cart Screen
- **Function Description:** Manages the user's current shopping cart.
- **Screen Layout:**
  {{IMAGE:cart_screen.png}}
  `[Mockup: List of games in cart, total price, and Checkout button]`
- **Function Detail:**
  - `Remove Button`: Removes the selected game from the cart.
  - `Checkout Button`: Purchases all games in the cart using the wallet balance.

#### ***1.3.2 Payouts & Topups***

##### 1.3.2.1 Wallet Screen & Payment WebView
- **Function Description:** Tops up the user's wallet balance via VNPay Sandbox.
- **Screen Layout:**
  {{IMAGE:wallet_screen.png}}
  `[Mockup: Screen to input deposit amount, opening an InAppWebView connecting to the VNPay gateway]`
- **Function Detail:**
  - `Amount Input`: Input field for the deposit amount (USD).
  - `VNPay InAppWebView`: Renders the payment gateway page and intercepts the IPN callback URL (`/vnpay-ipn`) to automatically close the webview on completion.

---
