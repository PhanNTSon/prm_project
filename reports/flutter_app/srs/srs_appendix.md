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
