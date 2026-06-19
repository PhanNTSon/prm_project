## **3\. Requirement Appendix**

### **3.1 Business Rules**
- **BR1:** Users are not allowed to add a game that is already in their Library to the Cart. Call the API `/user/library/contain/{gameId}` to verify ownership before displaying the "Add to Cart" button.
- **BR2:** The total checkout price of the cart must not exceed the current wallet balance. If exceeded, disable the Checkout button and prompt the user to deposit funds.

### **3.2 Common Requirements**
- All API calls must configure a timeout limit of 10 seconds.
- Display a Loading Spinner while fetching data from the server.

### **3.3 Application Messages List**
- "Registration successful!"
- "Invalid username or password."
- "OTP verified successfully."
- "Adding game to cart successfully."
- "Checkout successfully."

### **3.4 Other Requirements…**
- No other special requirements.
