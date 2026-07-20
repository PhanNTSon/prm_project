### **1.3 Transaction & Payments**

#### ***1.3.1 Cart Operations***

##### 1.3.1.1 Cart Screen
- **Function Description:** Manages the user's current shopping cart and lets the user complete a purchase using their wallet balance.
- **Screen Layout:**
  {{IMAGE:cart_screen.png}}
  `[Mockup: List of games in cart, wallet balance indicator, estimated total, Continue Shopping and Purchase buttons]`
- **Function Detail:**
  - `Cart List`: Loaded via `GET /user/cart` on screen entry and on pull-to-refresh. Each row (`CartItemTile`) displays the game thumbnail, name, and price, and shows a discount badge plus a strikethrough original price when `originalPrice` is greater than `price` (discounted item).
  - `Remove Button`: Calls `DELETE /user/cart/remove?gameId={id}`. On success, the item is removed from the local list immediately without re-fetching the whole cart.
  - `Wallet Balance Row`: Reads the live balance from the shared `WalletProvider` (the same provider that powers the Profile screen's realtime balance) and displays it in green when sufficient or red when it is less than the cart's estimated total (**BR2**).
  - `Estimated Total`: Computed client-side as the sum of all item prices in the cart (`totalPrice`).
  - `Purchase Button`: Calls `POST /user/cart/checkout`, which charges the wallet and moves all cart items into the Library. The button is disabled and shows a spinner while the request is in flight (`isCheckingOut`).
  - `Insufficient Balance Dialog`: If the checkout call fails with an error message containing "insufficient" or "balance", the app shows a dialog explaining the wallet doesn't have enough funds, with a "Top Up" action that navigates to `/account/wallet`.
  - `Empty / Error States`: An empty-cart illustration with a "Continue Shopping" button is shown when the cart has no items; a retry view with a "Retry" button is shown when `GET /user/cart` fails (e.g. network/timeout).
  - On successful checkout, the app navigates to the Payment Result screen with `{ type: 'purchase', success: true }`.

#### ***1.3.2 Payouts & Topups***

The overall top-up flow spans three screens (Wallet → Payment Confirmation → Payment Result) and one confirmation call back to the Backend.

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

##### 1.3.2.2 Payment Confirmation Screen (Simulated VNPay)
- **Function Description:** Presents a screen styled after the VNPay checkout page and lets the user confirm or cancel the simulated payment. **Current implementation note:** this is *not* a real WebView loading VNPay's actual gateway — it is a native Flutter screen that parses the payment details directly out of the `paymentUrl` string returned by the Backend and lets the user manually trigger the outcome. The `flutter_inappwebview` package is listed as a project dependency but is not used by this screen; the intercepted-navigation approach described in earlier drafts of this flow was never implemented.
- **Screen Layout:**
  {{IMAGE:vnpay_webview_screen.png}}
  `[Mockup: App bar styled like the VNPay Sandbox gateway with a close (X) button, a receipt-style card showing amount / bank / transaction no. / time, a "Xác nhận thanh toán" (Confirm Payment) button, and a "Hủy giao dịch" (Cancel Transaction) text link]`
- **Function Detail:**
  - `Parameter Parsing`: On open, the screen parses the query parameters already embedded in the `paymentUrl` it received (`vnp_Amount`, `vnp_TransactionNo`, `vnp_BankCode`, `vnp_PayDate`) and renders them in a receipt card. `vnp_Amount` is converted from VNPay's "amount × 100" convention back to a real VND value for display.
  - `Confirm Action ("Xác nhận thanh toán")`: Shows a ~900ms simulated processing delay (spinner on the button), then pops the screen and returns a map with `success: true`, `responseCode: '00'`, `transactionNo`, `bankCode`, `payDate`, and `amountVnd` to the caller (Wallet Screen).
  - `Cancel Action ("Hủy giao dịch" / close button)`: Pops the screen immediately and returns `{ success: false, responseCode: '24' }` (VNPay's standard "customer cancelled the transaction" code), letting the user abandon the payment early.
  - Because the Backend is presently a *simulated bypass*, the `paymentUrl` it returns already carries a `vnp_ResponseCode=00` and all the display fields above — there is no real VNPay Sandbox checkout session being contacted.

##### 1.3.2.3 Confirming a Top-up & Payment Result Screen
- **Function Description:** Finalizes a successful top-up on the Backend and shows a unified result screen for both purchase and top-up flows.
- **Screen Layout:**
  {{IMAGE:payment_result_screen.png}}
  `[Mockup: Success/failure icon, contextual title and message, a receipt card (top-up success only) showing amount added / transaction no. / bank / time, primary action button ("Back to Wallet" / "Go to Library" / "Back to Cart"), and a "Continue Shopping" link]`
- **Function Detail:**
  - `Confirm Top-up`: When the confirmation screen reports success, the Wallet Screen calls `confirmTopUp()`, which invokes `POST /user/wallet/add?amount=` to credit the wallet on the Backend (the IPN callback does not yet credit the wallet automatically) and returns the new balance.
  - `Global Balance Sync`: On confirmation, the new balance is pushed into the app-wide `WalletProvider` so the Profile, Cart, and any other screen reading the shared balance update in realtime without needing their own refetch.
  - `Result Screen`: Reused for both flows via a `type` field (`purchase` or `topup`) plus a `success` flag and optional `amount`/`transactionNo`/`bankCode`/`payDate`. It shows a check or cancel icon, a contextual message (e.g. "Your wallet has been topped up successfully." or "We could not complete your top-up. Please try again."), a receipt card with the transaction details when a top-up succeeds, and routes the primary action button to `/library` (successful purchase), `/account/wallet` (top-up, either outcome), or `/cart` (failed purchase).

---
