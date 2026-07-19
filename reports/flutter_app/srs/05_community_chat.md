### **1.5 Community & Chat**

#### ***1.5.1 Friend Management***

##### 1.5.1.1 Chat & Friend List Screen
- **Function Description:** Serves as the central hub for community interactions. Allows users to view their active Friend Code, search for new friends using their Friend Code, accept or decline incoming friend requests, and view their current friends categorized by online/offline status.
- **Screen Layout:**
  {{IMAGE:chat_list_screen.png}}
  `[Mockup: Dark theme — Top Box: "Your Friend Code" with copy button, Search bar with "Mã Kết Bạn" hint, "Pending Invites" list with Accept/Decline icons. Bottom Box: List of Friends grouped by "ONLINE" (green dot indicator) and "OFFLINE"]`
- **Function Detail:**
  - `Friend Code Display`: Shows the current user's unique `userId` to be shared with others. Includes a Copy-to-Clipboard button.
  - `Friend Search`: TextField that performs a debounced search (500ms) for other users using their Friend Code. Displays the matched user's Avatar and Name with a "Send Invite" button.
  - `Pending Invites List`: Displays incoming friend requests (fetched via `GET /user/pendinginvite/receive`). Users can Accept (`PATCH /user/acceptinvite/{id}`) or Decline (`DELETE /user/declineinvite/{id}`) the request. Real-time UI updates on action.
  - `Friend List`: Displays accepted friends fetched via `GET /user/friends`. Friends are cross-referenced with the WebSocket's `/app/online` stream to dynamically categorize them into "ONLINE" (with a green status indicator) and "OFFLINE" sections.
  - `Friend Tap`: Tapping a friend's ListTile navigates to `/chat/detail/:friendId/:username` to open the private chat interface.

#### ***1.5.2 Private Messaging***

##### 1.5.2.1 Chat Detail Screen
- **Function Description:** A real-time, private 1-on-1 messaging interface between the user and a selected friend.
- **Screen Layout:**
  {{IMAGE:chat_detail_screen.png}}
  `[Mockup: Dark theme — AppBar showing Friend's Avatar and Name. Main body: Scrollable chat history (bubbles on right for user, left for friend). Bottom: Message input field and send button]`
- **Function Detail:**
  - `Chat History Initialization`: On load, automatically fetches past message history via `GET /user/conversation/{friendId}`. Extracts and caches the `conversationId` for subsequent real-time messages.
  - `Message Bubbles`: Messages are displayed chronologically using `ListView.builder(reverse: true)`. 
    - *User's Messages (`isMine: true`)*: Rendered on the right side with a bright blue background.
    - *Friend's Messages (`isMine: false`)*: Rendered on the left side with a dark blue/grey background.
  - `Real-time WebSocket Sync`: Connects to STOMP topic `/user/queue/messages/{username}` to listen for incoming messages.
  - `Message Input & Send`: TextField for composing messages. Pressing the send button publishes the payload (including `conversationId`, `senderId`, `receiverUsername`, and `content`) to the WebSocket destination `/app/chat/private.send`. The UI optimistic-updates immediately without waiting for a server echo, appending the new message bubble to the right side of the screen.
