### **1.2 Storefront & Catalog**

#### ***1.2.1 Catalog Navigation***

##### 1.2.1.1 Home Store Screen
###### a. UI Specifications
**Home Store Screen**
- **Brief Description:** Màn hình chính hiển thị danh mục các trò chơi.
- **Mockup UI Layout:** `[Mockup: Thanh search trên cùng, các mục cuộn ngang: Game Under $5, Top Selling, New Publish]`
- **Component Requirements:**
  - `Search Bar`: Tìm kiếm game bằng từ khóa.
  - `Game Cards`: Hiển thị hình ảnh, tên game, và giá tiền. Click vào sẽ điều hướng đến chi tiết game.

#### ***1.2.2 Game Details***

##### 1.2.2.1 Game Detail Screen
###### a. UI Specifications
**Game Detail Screen**
- **Brief Description:** Xem thông tin chi tiết một game cụ thể.
- **Mockup UI Layout:** `[Mockup: Ảnh banner lớn, mô tả ngắn, giá bán, cấu hình hệ thống, nút Add to Cart]`
- **Component Requirements:**
  - `Price Tag / Add to Cart Button`: Nếu game đã sở hữu, đổi thành nút "In Library". Nếu chưa, hiển thị nút "Add to Cart" gọi API `/user/cart/add`.

---
