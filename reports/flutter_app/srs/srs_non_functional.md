## **2\. Non-Functional Requirements**

### **2.1 External Interfaces**
- **User Interface (UI):** Dark mode design matching the Steam system theme (`Color(0xFF1B2838)`). Uses Material 3 Design with a `BottomNavigationBar`.
- **Software Interfaces:** Interacts with the Backend (Spring Boot) via RESTful APIs and WebSocket STOMP for real-time bi-directional messaging. Exchange data format is JSON.

### **2.2 Quality Attributes**
- **Security:** All HTTP requests after logging in must include the `Authorization: Bearer <token>` header. If the Backend returns an HTTP 401 (Unauthorized) error, the system automatically clears local storage and redirects the user back to the Login page.
- **Usability:** Switching between the 4 main tabs (Store, Cart, Library, Profile) must not cause the page to reload from scratch (State is preserved using GoRouter's `StatefulShellRoute`).
- **Performance:** Downloaded images must be cached using the `cached_network_image` library to reduce network bandwidth usage and accelerate image rendering.
