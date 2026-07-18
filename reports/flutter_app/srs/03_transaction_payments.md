### **1.3 Transaction & Payments**

#### ***1.3.1 Cart Operations***

##### 1.3.1.1 Cart Screen
- **Function Description:** Manages the user's current shopping cart and lets the user complete a purchase using their wallet balance.
- **Screen Layout:**
  {{IMAGE:cart_screen.png}}
  `[Mockup: List of games in cart, wallet balance indicator, estimated total, Continue Shopping and Purchase buttons]`
- **Function Detail:**
  - `Cart List`: Loaded via `GET /user/cart` on screen entry and on pull-to-refresh. Each row (`CartItemTile`) displays the game thumbnail, name, and price, and shows a strikethrough original price when `originalPrice` is greater than `price` (discounted item).
  - `Remove Button`: Calls `DELETE /user/cart/remove?gameId={id}`. On success, the item is removed from the local list immediately without re-fetching the whole cart.
  - `Wallet Balance Row`: Reads the live balance from the shared `WalletProvider` (the same provider that powers the Profile screen's realtime balance) and displays it in green when sufficient or red when it is less than the cart's estimated total (**BR2**).
  - `Estimated Total`: Computed client-side as the sum of all item prices in the cart (`totalPrice`).
  - `Purchase Button`: Calls `POST /user/cart/checkout`, which charges the wallet and moves all cart items into the Library. The button is disabled and shows a spinner while the request is in flight (`isCheckingOut`).
  - `Insufficient Balance Dialog`: If the checkout call fails with an error message containing "insufficient" or "balance", the app shows a dialog explaining the wallet doesn't have enough funds, with a "Top Up" action that navigates to `/account/wallet`.
  - `Empty / Error States`: An empty-cart illustration with a "Continue Shopping" button is shown when the cart has no items; a retry view with a "Retry" button is shown when `GET /user/cart` fails (e.g. network/timeout).
  - On successful checkout, the app navigates to the Payment Result screen with `{ type: 'purchase', success: true }`.

#### ***1.3.2 Payouts & Topups***

The overall top-up flow spans three screens (Wallet → VNPay WebView → Payment Result) and one confirmation call back to the Backend, as shown below.

{{DIAGRAM:payment_flow}}

##### 1.3.2.1 Wallet Screen
- **Function Description:** Displays the current wallet balance, lets the user top up funds via VNPay, and shows the wallet's transaction history.
- **Screen Layout:**
  {{IMAGE:wallet_screen.png}}
  `[Mockup: Wallet balance card, deposit amount input with quick-amount chips, "Top up with VNPay" button, and a transaction history list below]`
- **Function Detail:**
  - `Balance Card`: Fetches the current balance via `GET /user/wallet` (`loadBalance()`) and shows a loading indicator while the request is in progress.
  - `Amount Input`: Free-text numeric field for the deposit amount (USD), defaulting to `10`. Validates the value is a positive number before submitting.
  - `Quick Amount Chips`: Preset shortcuts (`$5`, `$10`, `$20`, `$50`) that autofill the amount field.
  - `Top up with VNPay Button`: Calls `requestTopUp()`, which invokes `POST /api/v1/payments/create-vnpay-payment?amount=&bankCode=&language=` and receives a `paymentUrl`. The button is disabled and shows a spinner while the request is pending (`isTopUpLoading`).
  - `Transaction History List`: Fetched via `GET /user/transaction` (`loadTransactions()`) and rendered with `TransactionTile`. Each entry is classified as a top-up or a game purchase based on whether `gameId` is present (`isTopUp == (gameId == null)`); an empty state is shown when there is no history yet.
  - Pull-to-refresh reloads both the balance and the transaction history.

##### 1.3.2.2 VNPay Payment WebView
- **Function Description:** Opens the VNPay checkout page returned by the Backend inside a full-screen `InAppWebView` and detects the payment outcome without relying on the page finishing its own redirect chain.
- **Screen Layout:**
  {{IMAGE:vnpay_webview_screen.png}}
  `[Mockup: Full-screen WebView with a "VNPay Payment Gateway" app bar and a close button, loading indicator overlaid while the page loads]`
- **Function Detail:**
  - `Result URL Detection`: The screen watches every navigation inside the WebView (`shouldOverrideUrlLoading`, mirrored by a second check in `onLoadStart` for Android versions that skip the first callback) and treats a URL as the final result as soon as it contains a `vnp_ResponseCode` query parameter, or its path contains `payment-result` / `vnpay-ipn` — the navigation is then cancelled instead of letting the WebView actually load that page.
  - `Success Detection`: The payment is considered successful only when `vnp_ResponseCode == '00'`.
  - `Return Payload`: Once a result URL is detected, the screen pops itself and returns a map with `success`, `responseCode`, `transactionNo`, `bankCode`, `payDate`, and `amountVnd` to the caller (Wallet Screen).
  - `Close Button`: Lets the user abandon the payment early, popping with `null`.
  - **Current implementation note:** the Backend is presently a *simulated bypass* — the `paymentUrl` it returns already carries a `vnp_ResponseCode`, so the interception above happens immediately rather than after a real VNPay Sandbox checkout session.

##### 1.3.2.3 Confirming a Top-up & Payment Result Screen
- **Function Description:** Finalizes a successful top-up on the Backend and shows a unified result screen for both purchase and top-up flows.
- **Screen Layout:**
  {{IMAGE:payment_result_screen.png}}
  `[Mockup: Success/failure icon, contextual title and message, primary action button ("Back to Wallet" / "Go to Library" / "Back to Cart"), and a "Continue Shopping" link]`
- **Function Detail:**
  - `Confirm Top-up`: When the WebView reports success, the Wallet Screen calls `confirmTopUp()`, which invokes `POST /user/wallet/add?amount=` to credit the wallet on the Backend (the IPN callback does not yet credit the wallet automatically) and returns the new balance.
  - `Global Balance Sync`: On confirmation, the new balance is pushed into the app-wide `WalletProvider` so the Profile, Cart, and any other screen reading the shared balance update in realtime without needing their own refetch.
  - `Result Screen`: Reused for both flows via a `type` field (`purchase` or `topup`) plus a `success` flag and optional `amount`. It shows a check or cancel icon, a contextual message (e.g. "Your wallet has been topped up with $10.00" or "We could not complete your top-up. Please try again."), and routes the primary action button to `/library` (successful purchase), `/account/wallet` (top-up, either outcome), or `/cart` (failed purchase).

---
