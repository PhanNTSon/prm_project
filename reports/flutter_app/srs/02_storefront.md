### **1.2 Storefront & Catalog**

#### ***1.2.1 Catalog Navigation***

##### 1.2.1.1 Home Store Screen
- **Function Description:** Main store screen displaying various game categories.
- **Screen Layout:**
  {{IMAGE:home_store_screen.png}}
  `[Mockup: Search bar at the top, horizontal scrolling rows: Games Under $5, Top Selling, New Releases]`
- **Function Detail:**
  - `Search Bar`: Search for games using keywords.
  - `Game Cards`: Displays game image, name, and price. Tapping a card navigates to the Game Detail Screen.

#### ***1.2.2 Game Details***

##### 1.2.2.1 Game Detail Screen
- **Function Description:** View detailed information of a specific game.
- **Screen Layout:**
  {{IMAGE:game_detail_screen.png}}
  `[Mockup: Large banner image, short description, price, system requirements, and Add to Cart button]`
- **Function Detail:**
  - `Price Tag / Add to Cart Button`: If the game is already owned, display "In Library". Otherwise, show the "Add to Cart" button which calls the API `/user/cart/add`.

---
