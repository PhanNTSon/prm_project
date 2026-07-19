### **1.2 Storefront & Catalog**

This section outlines the detailed requirements for the Storefront module, which serves as the primary discovery and catalog browsing interface for the Centurion Store application.

---

#### ***1.2.1 Catalog Navigation***

##### 1.2.1.1 Home Store Screen

**A. General Description**
The Home Store Screen is the main entry point of the application after a successful login. It displays a curated list of featured games, categories, and dynamic thematic sections (Special Offers, Under $5, Free to Play) to encourage game discovery and impulse purchases.

**B. UI Layout**
{{IMAGE:home_store_screen.png}}
*Mockup Description: A scrollable vertical view. Top contains a fixed AppBar with Logo, Search Icon, and Cart Icon. Below the AppBar is the "Featured & Recommended" horizontal carousel, followed by a "Browse by Category" 3x2 grid. Below that are multiple horizontal scrolling lists for "Special Offers", "Under $5", and "Free to Play".*

**C. UI Components & Fields Specification**

| Component Name | Type | Data Source | Rules & Constraints |
| :--- | :--- | :--- | :--- |
| **Search Icon** | Action Button | Local | Navigates to the Game Search Screen (`/search`). |
| **Cart Icon** | Action Button | Local | Navigates to the Cart Screen (`/cart`). |
| **Featured Carousel** | PageView | `GET /game?page=0&size=50` | Displays up to 5 randomly selected games from the first 50 games. Auto-snaps to center. |
| **FeaturedGameCard** | Widget | Game Basic DTO | Displays `imageUrl`, `title`, and formatted price. Shows "FEATURED" badge. Tapping navigates to `/game-detail/{id}`. |
| **Category Grid** | GridView | `GET /tags` | Displays 5 randomly selected categories. Uses Steam CDN for background images. Tapping sets global tag filter and navigates to `/all-games`. |
| **Special Offers List** | Horizontal List | `GET /game?page=0&size=50` | Displays games where `isOnSale == true`. Max 10 items. |
| **Under $5 List** | Horizontal List | `GET /game?page=0&size=50` | Displays games where `0 < displayPrice < 5.0`. Max 10 items. |
| **Free to Play List** | Horizontal List | `GET /game?page=0&size=50` | Displays games where `displayPrice == 0`. Max 10 items. |
| **RefreshIndicator** | Gesture | Local | Pulling down from the top re-triggers `loadHomeData()` to fetch new random data. |

**D. Use Case Specification**
- **Pre-conditions:** The user is authenticated and the application has initialized the `HomeProvider`.
- **Post-conditions:** The user views the latest catalog data or navigates to a specific category/game.
- **Main Success Scenario:**
  1. The user navigates to the Home tab.
  2. The system invokes `loadHomeData()` to fetch games and categories concurrently.
  3. The system displays a loading indicator.
  4. The system renders the Featured Carousel, Category Grid, and Horizontal Game Lists.
- **Alternate Flows:**
  - *Network Failure:* If the API fails, the system logs the error and displays empty placeholders or previous cached state. Pull-to-refresh can be used to retry.
  - *Missing CDN Image:* If the Steam CDN image for a category fails to load, the system falls back to a local asset or a gradient color.

**E. Technical Mapping**
- **State Management:** `HomeProvider`
- **APIs Used:** 
  - `GET /game?page={page}&size={size}`
  - `GET /tags`

---

##### 1.2.1.2 All Games Screen (Browse / Tag-filtered List)

**A. General Description**
A paginated, vertically scrollable list displaying all games in the catalog. It supports alphabetical sorting by default and can be filtered by specific categories (tags) when navigated from the Home Screen.

**B. UI Layout**
{{IMAGE:all_games_screen.png}}
*Mockup Description: AppBar with a back arrow, dynamic title reflecting the current filter, and a total items badge. A sticky A-Z alphabet bar sits below. The main body is a continuous vertical list of game cards (GameSearchResultItem) with a shimmer loading effect for initial loads.*

**C. UI Components & Fields Specification**

| Component Name | Type | Data Source | Rules & Constraints |
| :--- | :--- | :--- | :--- |
| **Dynamic Title** | Text Label | `GameListProvider` | Displays "All Games" or the specific Category Name (e.g., "Action"). |
| **Total Count Badge**| Text Label | Pagination Metadata | Displays the total number of games matching the current criteria (`totalElements`). |
| **Game List View** | ListView | API Content | Renders `GameSearchResultItem` for each game. Triggers pagination when scrolled within 200px of the bottom. |
| **GameSearchResultItem**| Widget | Game Basic DTO | Displays game icon, title, publisher, and price. Shows strikethrough price if discounted. |
| **Shimmer Loader** | Animation | Local | Shown only when `isLoading == true` and the list is currently empty (first page load). |
| **Empty State View** | Graphic/Text | Local | Shown if `totalElements == 0` after a successful API call. |

**D. Use Case Specification**
- **Pre-conditions:** The user taps on a category card or the "All Games" navigation link.
- **Post-conditions:** The user browses the paginated list of games.
- **Main Success Scenario:**
  1. The user enters the screen.
  2. The system checks `GameListProvider.currentTagFilter`.
  3. The system fetches Page 0 of the game list (either filtered or unfiltered).
  4. The user scrolls down.
  5. Upon reaching the bottom threshold, the system fetches Page N+1 and appends it to the list.
- **Alternate Flows:**
  - *Pagination Exhausted:* If `currentPage >= totalPages - 1`, the system stops triggering API calls on scroll.

**E. Technical Mapping**
- **State Management:** `GameListProvider`
- **APIs Used:** 
  - *Unfiltered:* `GET /game?page={page}&size={size}&sort=name&dir=asc`
  - *Filtered:* `GET /game/tag/{tagId}?page={page}&size={size}`

---

#### ***1.2.2 Game Details***

##### 1.2.2.1 Game Detail Screen

**A. General Description**
The Game Detail Screen provides comprehensive information about a specific game. It includes media galleries, rich text descriptions, publisher details, and the primary call-to-action for purchasing. It dynamically adapts its UI based on the user's ownership and cart status.

**B. UI Layout**
{{IMAGE:game_detail_screen.png}}
*Mockup Description: Full-screen view without bottom navigation. Uses a Collapsing SliverAppBar with the game's header image. Below is the main info block: small thumbnail, title, rating, and a bordered price container with the CTA button. Further down are sections for Publisher info, "About This Game" text, a horizontal Screenshots gallery, and a Tags chip list.*

**C. UI Components & Fields Specification**

| Component Name | Type | Data Source | Rules & Constraints |
| :--- | :--- | :--- | :--- |
| **SliverAppBar Header** | Image | `gameUrl` / `iconUrl` | Expands to 280px. Uses a bottom-to-top dark gradient fade. Falls back to a color block if URLs are invalid. |
| **Price Display** | Text Group | `price`, `discountPrice` | Shows "FREE TO PLAY" in `#BEEE11` if price is 0. If `isOnSale`, shows discount percentage badge, strikethrough original price, and bold new price. |
| **Action CTA Button** | Dynamic Button | User State | Follows strict precedence: <br>1. **Spinner:** If `isCheckingOwnership` is true.<br>2. **In Library:** Outlined Green. Navigates to `/library`.<br>3. **In Cart:** Outlined Blue. Navigates to `/cart`.<br>4. **Add to Cart:** Solid Green. Triggers API call. |
| **Description Text** | Text Block | `fullDescription` | Falls back to `shortDescription` if full is null. Rendered with custom line height for readability. |
| **Media Gallery** | Horizontal List| `media[]` | Displays screenshots. Each image is 280px wide. |
| **Tags List** | Wrap (Chips) | `tags[]` | Renders a chip for each associated tag. |

**D. Use Case Specification**
- **Pre-conditions:** The user selects a game from any catalog view and passes a valid `gameId`.
- **Post-conditions:** The user successfully adds the game to the cart or navigates away.
- **Main Success Scenario (Add to Cart):**
  1. The user taps "Add to Cart".
  2. The system disables the button and shows a loading spinner inside it.
  3. The system calls the backend to add the item to the cart.
  4. Upon success, the system changes the button state to "In Cart".
  5. The system displays a SnackBar with a "VIEW CART" action.
- **Alternate Flows:**
  - *Already Owned (BR-09):* Upon screen load, the system asynchronously checks `/user/library/contain/{gameId}`. If true, the CTA button permanently changes to "In Library" and disables adding to the cart.
  - *Add to Cart Failure:* If the API returns an error (e.g., game already in cart on server), the system displays a red Error SnackBar and restores the "Add to Cart" button state.

**E. Technical Mapping**
- **State Management:** `GameDetailProvider`, `CartProvider`
- **APIs Used:** 
  - *Detail Fetch:* `GET /game/detail/{id}`
  - *Ownership Check:* `GET /user/library/contain/{id}`
  - *Add to Cart:* `POST /user/cart/add?gameId={id}`

---
