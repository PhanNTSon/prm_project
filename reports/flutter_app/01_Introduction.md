# **Acknowledgement**

Dự án được thực hiện bởi Group 1 - SE1933 dựa trên tài liệu yêu cầu (RDS/SRS) của phiên bản web cũ, hiện đã được thiết kế lại để tối ưu hóa cho ứng dụng di động đa nền tảng bằng Flutter.

# **Definition and Acronyms**

| Acronym | Definition |
| :---: | ----- |
| JWT | JSON Web Token |
| CS | Centurion Store |
| BA | Business Analysis |
| BR | Business Rule |
| ERD | Entity Relationship Diagram |
| GUI | Graphical User Interface |
| PM | Project Manager |
| SDD | Software Design Description |
| SRS | Software Requirement Specification |
| UAT | User Acceptance Test |
| UC | Use Case |
| API | Application Program Interface |

# **I. Project Introduction**

## **1\. Overview**

### **1.1 Project Information**
- **Project Name:** Centurion Store (Flutter Mobile App)
- **Platform:** Android & iOS (Flutter)
- **Backend:** Spring Boot (REST API)
- **Prepared by:** SE1933 - Group 1

### **1.2 Project Team**
| *STT* | *Member* | *Task/Screen* |
| :---- | :---- | :---- |
| *1* | Nguyễn Văn A | Authentication & Profile |
| *2* | Nguyễn Văn B | Storefront (Home, Search, Game Details) |
| *3* | Nguyễn Văn C | Cart, Payment (VNPay), & Wallet |
| *4* | Nguyễn Văn D | Library & UI Kit Components |
| *5* | Tech Lead | Architecture, Routing, Base Network, Testing |

## **2\. Product Background**

Thị trường game kỹ thuật số đang ngày càng mở rộng, tuy nhiên người dùng di động thường gặp khó khăn khi muốn theo dõi, mua sắm và quản lý thư viện game PC/Console của họ một cách nhanh chóng. Dự án **Centurion Store Mobile App** được xây dựng nhằm cung cấp một nền tảng di động tiện lợi, cho phép người dùng (game thủ) truy cập vào cửa hàng game, nạp tiền vào ví điện tử thông qua VNPay, mua sắm trò chơi, và xem thư viện game đã sở hữu mọi lúc mọi nơi thông qua ứng dụng điện thoại.

## **3\. Existing Solutions**

- **Steam Mobile App:** Ứng dụng chính thức của Steam cho phép mua sắm và xác thực, tuy nhiên giao diện đôi khi phức tạp và nặng nề.
- **PlayStation App / Xbox App:** Cho phép mua sắm và quản lý thư viện game trên console.
Centurion Store Mobile App học hỏi từ các hệ thống này bằng cách tối giản hóa trải nghiệm UI/UX thành kiến trúc 4 tab chính: Cửa hàng, Giỏ hàng, Thư viện, và Cá nhân.

## **4\. Project Scope & Limitations**

**In Scope:**
- Ứng dụng di động (Android/iOS) được phát triển bằng Flutter.
- Đăng ký, Đăng nhập, Quản lý hồ sơ người dùng (Auth).
- Duyệt danh mục trò chơi (Home, Top Selling, Under $5, v.v.).
- Xem chi tiết trò chơi.
- Quản lý giỏ hàng và thanh toán bằng số dư Ví (Wallet).
- Nạp tiền vào ví thông qua cổng thanh toán VNPay (hiển thị InAppWebView).
- Quản lý Thư viện Game đã mua (Library).

**Out of Scope (Limitations):**
- Không hỗ trợ tải xuống và chơi game trực tiếp trên điện thoại (vì hệ thống là cửa hàng bán game PC/Desktop).
- Không bao gồm các chức năng quản lý cao cấp dành cho Publisher và Admin (Quản lý và upload game mới sẽ được thực hiện trên phiên bản Web/Desktop cũ).
- Không hỗ trợ chat realtime trong phiên bản di động V1.0 (sẽ xem xét bổ sung sau).
