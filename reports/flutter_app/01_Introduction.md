# **Acknowledgement**

The project is implemented by Group 1 - SE1933 based on the requirements documentation (RDS/SRS) of the old web version, which has been redesigned and optimized for the cross-platform mobile application using Flutter.

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
| *No.* | *Member* | *Task/Screen* |
| :---- | :---- | :---- |
| *1* | Nguyễn Văn A | Authentication & Profile |
| *2* | Nguyễn Văn B | Storefront (Home, Search, Game Details) |
| *3* | Nguyễn Văn C | Cart, Payment (VNPay), & Wallet |
| *4* | Nguyễn Văn D | Library & UI Kit Components |
| *5* | Tech Lead | Architecture, Routing, Base Network, Testing |

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
