# **IV. Software Testing Documentation**

## **1\. Scope of Testing**

Phạm vi kiểm thử tập trung vào tính đúng đắn của logic nội bộ ứng dụng Flutter Mobile, đặc biệt là các thành phần cốt lõi: Tầng kết nối mạng (Network Layer) và Định tuyến hệ thống (Routing Guard).

- **In Scope:** Unit Test cho các cơ chế gán Token tự động (AuthInterceptor), lưu trữ bảo mật (SecureStorageService) và điều hướng GoRouter (Auth Guard).
- **Out of Scope:** Các chức năng thuộc về Backend (đã có bộ kiểm thử Postman/Backend riêng), UI Test chi tiết cho từng màn hình (sẽ thực hiện manual test ở giai đoạn này).

## **2\. Test Strategy**

### **2.1 Testing Types**

- **Functional Testing:** Đảm bảo hệ thống điều hướng đúng mục tiêu (ví dụ: mất token thì trả về `/login`).
- **Security Testing:** Đảm bảo token JWT được lưu trữ và truy xuất an toàn, không bị rò rỉ. Đảm bảo ứng dụng từ chối mở trang `/home` nếu không có token.

### **2.2 Test Levels**

- **Unit Testing:** Kiểm tra độc lập các component cốt lõi (`DioClient`, `AuthInterceptor`).
- **Widget Testing:** Bơm (Pump) hệ thống GoRouter vào một cây Widget ảo để giả lập sự kiện chuyển trang và xác minh logic Guard hoạt động bình thường.
- **Manual Testing:** Cài đặt ứng dụng trên Emulator hoặc thiết bị thật để kiểm tra luồng trải nghiệm thực tế (chạm, cuộn, hiệu ứng).

### **2.3 Supporting Tools**

- Thư viện `flutter_test` (Mặc định của SDK Flutter).
- `Mock Method Channel`: Để giả lập các cuộc gọi xuống hệ điều hành (Native) của plugin `flutter_secure_storage` trong quá trình chạy Unit Test mà không cần thiết bị thật.

## **3\. Test Cases**

Các bài kiểm thử tự động (Automated Test) đã được triển khai trong dự án theo cấu trúc:

{{DIAGRAM:testcase_architecture}}


### Chi tiết các Test Case quan trọng:

1. **TC_NET_01 (Header Injection):** Gửi Request API bất kỳ -> Kỳ vọng tự động chèn `Authorization: Bearer <token>`.
2. **TC_NET_03 (401 Error Clean):** Giả lập Backend trả về lỗi HTTP 401 -> Kỳ vọng App tự động gọi hàm xóa sạch Token trong Secure Storage.
3. **TC_RTE_01 (Redirect No Token):** Mở App nhưng bộ nhớ rỗng -> Kỳ vọng `GoRouter` chặn truy cập trang Chủ và hất văng về màn hình Đăng nhập.
4. **TC_RTE_02 (Direct Token Exists):** Mở App khi bộ nhớ có Token hợp lệ -> Kỳ vọng `GoRouter` cho phép bỏ qua trang Đăng nhập và đi thẳng vào Trang Chủ.

## **4\. Test Reports**

Hiện tại (Phiên bản V1.0 Foundation):

- **Unit/Widget Tests:** Chạy lệnh `flutter test` báo cáo 100% Pass (Thành công) cho mọi bài kiểm thử Tầng Mạng và Định Tuyến.
- **Manual Tests:** Các kịch bản KeepAlive của BottomNavigationBar, lồng ghép trang chi tiết (Nested Routing) và hiển thị WebView VNPay đã được xác minh thành công trên Android Emulator (Pixel 7 API 34).
