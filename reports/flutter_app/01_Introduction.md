# **Acknowledgement**

The project is implemented by Group 6 - SE1924-JS(IT) based on the requirements documentation (RDS/SRS) of the old web version, which has been redesigned and optimized for the cross-platform mobile application using Flutter.

# **Definition and Acronyms**

| Acronym | Definition                              |
| :-----: | --------------------------------------- |
|   API   | Application Programming Interface       |
|   BR    | Business Rule                           |
|   JWT   | JSON Web Token                          |
|   OTP   | One-Time Password                       |
|   SRS   | Software Requirement Specification      |
|  STOMP  | Simple Text Oriented Messaging Protocol |
|   UI    | User Interface                          |
|   UX    | User Experience                         |
|  VNPay  | Vietnam Payment Gateway                 |

# **I. Project Introduction**

## **1\. Overview**

### **1.1 Project Information**

- **Project Name:** Centurion Store (Flutter Mobile App)
- **Platform:** Android & iOS (Flutter)
- **Backend:** Spring Boot (REST API)
- **Prepared by:** SE1924-JS(IT) - Group 6

### **1.2 Project Team**

| _No._ | _Member_               | _Task/Screen_                                                          |
| :---- | :--------------------- | :--------------------------------------------------------------------- |
| _1_   | Nguyễn Văn A           | Authentication & Profile                                               |
| _2_   | Nguyễn Văn B           | Storefront (Home, Search, Game Details)                                |
| _3_   | Nguyễn Văn C           | Cart, Payment (VNPay), & Wallet                                        |
| _4_   | Ngô Tiến Đạt           | Library & UI Kit Components                                            |
| _5_   | Phan Nguyễn Trường Sơn | Architecture, Routing, Base Network, Testing, Community (Friend, Chat) |

## **2\. Product Background**

The digital game market is constantly expanding; however, mobile users often encounter difficulties in tracking, shopping, and managing their PC/Console game library quickly on the go. The **Centurion Store Mobile App** project is built to provide a convenient mobile platform, allowing users (gamers) to access the game store, top up their wallet balance via the VNPay gateway, purchase games, and view their owned game library anytime and anywhere via their mobile application.

## **3\. Existing Solutions**

- **Steam Mobile App:** The official Steam application allows shopping and authentication, but the interface is sometimes complex and heavy.
- **PlayStation App / Xbox App:** Allows shopping and console game library management.
  Centurion Store Mobile App learns from these systems by simplifying the UI/UX experience into 4 main tabs: Store, Cart, Library, and Profile.

## **4\. Project Scope & Limitations**

**In Scope:**

- Mobile application (Android/iOS) developed using Flutter.
- Registration, Login, User profile management (Auth).
- Browse game categories (Home, Top Selling, Under $5, etc.).
- View game details.
- Manage cart and payment using Wallet balance.
- Top up wallet via the VNPay payment gateway (displayed via InAppWebView).
- Manage purchased Game Library (Library).

**Out of Scope (Limitations):**

- No support for downloading and playing games directly on the mobile phone (as the system is a PC/Desktop game store).
- Advanced publisher/admin management functions are not included (Managing and uploading new games will be performed on the old Web/Desktop version).
- No real-time chat support in mobile version V1.0 (to be considered for future additions).
