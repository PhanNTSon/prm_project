# System Diagrams List

## package_diagram

```mermaid
graph TD
    lib["lib/"] --> core["core/ (Shared Core)"]
    lib --> features["features/ (Feature-First Modules)"]
    lib --> main["main.dart"]

    core --> network["network/ (Dio, Interceptors)"]
    core --> router["router/ (GoRouter, Guards)"]
    core --> widgets["widgets/ (Common UI Kit)"]
    core --> constants["constants/ (AppColors, API)"]

    features --> auth["auth/ (Dev A)"]
    features --> profile["profile/ (Dev A)"]
    features --> storefront["storefront/ (Dev B)"]
    features --> cart["cart/ (Dev C)"]
    features --> library["library/ (Dev D)"]

    style lib fill:#1b2838,stroke:#66c0f4,stroke-width:2px,color:#fff
    style core fill:#2a475e,stroke:#66c0f4,stroke-width:1px,color:#fff
    style features fill:#2a475e,stroke:#66c0f4,stroke-width:1px,color:#fff
    style main fill:#171a21,stroke:#c7d5e0,stroke-width:1px,color:#fff
```

## system_architecture

```mermaid
graph TD
    %% Define main nodes
    A["📱 Mobile Client<br>(Flutter App)"]
    B["☕ Spring Boot Backend<br>(Centurion API)"]
    C["🌐 VNPay Sandbox<br>(Payment Gateway)"]
    D["🐘 PostgreSQL Database<br>(Managed by Railway)"]

    %% Establish connections with description labels
    A <-->|HTTP/REST<br>JSON payloads| B
    A -->|InAppWebView| C
    B -->|JDBC| D

    %% Customize display colors (Styles)
    classDef client fill:#e1f5fe,stroke:#03a9f4,stroke-width:2px,color:#000;
    classDef backend fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000;
    classDef gateway fill:#fff3e0,stroke:#ff9800,stroke-width:2px,color:#000;
    classDef database fill:#ede7f6,stroke:#673ab7,stroke-width:2px,color:#000;

    class A client;
    class B backend;
    class C gateway;
    class D database;
```

## testcase_architecture

```mermaid
graph TD
    %% Directory structure definition
    root["📁 test/"]

    %% Level 1
    network["📁 network/"]
    router["📁 router/"]
    readme_root["📄 README.md"]

    %% Level 2 (Inside network/)
    net_test["📄 network_test.dart"]
    readme_net["📄 README.md"]

    %% Level 2 (Inside router/)
    rot_test["📄 router_test.dart"]
    readme_rot_dir["📄 README.md"]

    %% Establish hierarchy connections
    root --> network
    root --> router
    root --> readme_root

    network --> net_test
    network --> readme_net

    router --> rot_test
    router --> readme_rot_dir

    %% Customize UI styles (Modern colors)
    style root fill:#fff3e0,stroke:#ff9800,stroke-width:2px,color:#000
    style network fill:#fff3e0,stroke:#ff9800,stroke-width:1px,color:#000
    style router fill:#fff3e0,stroke:#ff9800,stroke-width:1px,color:#000
    style readme_root fill:#f5f5f5,stroke:#9e9e9e,stroke-width:1px,color:#000
    style net_test fill:#e1f5fe,stroke:#03a9f4,stroke-width:1px,color:#000
    style rot_test fill:#e1f5fe,stroke:#03a9f4,stroke-width:1px,color:#000
    style readme_net fill:#f5f5f5,stroke:#9e9e9e,stroke-width:1px,color:#000
    style readme_rot_dir fill:#f5f5f5,stroke:#9e9e9e,stroke-width:1px,color:#000
```

## database_schema

```plantuml
@startuml
skinparam linetype ortho
skinparam shadowing false

entity "Roles" as Roles {
  * RoleID : BIGSERIAL
  --
  RoleName : VARCHAR(50)
}

entity "User" as User {
  * UserID : BIGSERIAL
  --
  RoleID : BIGINT <<FK>>
  Email : VARCHAR(100)
  Username : VARCHAR(50)
  Password : VARCHAR(255)
  WalletBalance : DECIMAL(10, 2)
}

entity "Publisher" as Publisher {
  * PublisherID : BIGINT <<PK, FK>>
  --
  PublisherName : VARCHAR(100)
}

entity "Game" as Game {
  * GameID : BIGSERIAL
  --
  PublisherID : BIGINT <<FK>>
  Name : VARCHAR(100)
  Price : DECIMAL(10, 2)
  State : BOOLEAN
}

entity "Transaction" as Transaction {
  * TransactionID : BIGSERIAL
  --
  UserID : BIGINT <<FK>>
  TotalAmount : DECIMAL(10, 2)
  Type : VARCHAR(255)
}

entity "TransactionDetail" as TransactionDetail {
  * TransactionID : BIGINT <<PK, FK>>
  * GameID : BIGINT <<PK, FK>>
  --
  Price : DECIMAL(10, 2)
}

entity "Cart" as Cart {
  * UserID : BIGINT <<PK, FK>>
  * GameID : BIGINT <<PK, FK>>
  --
  DateAdded : DATE
}

entity "Library" as Library {
  * GameID : BIGINT <<PK, FK>>
  * UserID : BIGINT <<PK, FK>>
  --
  PlaytimeInMillis : BIGINT
}

entity "Review" as Review {
  * GameID : BIGINT <<PK, FK>>
  * UserID : BIGINT <<PK, FK>>
  --
  ReviewContent : TEXT
  IsRecommended : BOOLEAN
}

entity "Friendships" as Friendships {
  * User1ID : BIGINT <<PK, FK>>
  * User2ID : BIGINT <<PK, FK>>
}

entity "FriendRequests" as FriendRequests {
  * RequestID : BIGSERIAL
  --
  SenderID : BIGINT <<FK>>
  ReceiverID : BIGINT <<FK>>
}

entity "Conversations" as Conversations {
  * ConversationID : BIGSERIAL
  --
  UserID1 : BIGINT <<FK>>
  UserID2 : BIGINT <<FK>>
}

entity "Messages" as Messages {
  * MessageID : BIGSERIAL
  --
  ConversationID : BIGINT <<FK>>
  SenderID : BIGINT <<FK>>
  MessageContent : TEXT
}

Roles ||--o{ User
User ||--o| Publisher
Publisher ||--o{ Game
User ||--o{ Transaction
Transaction ||--|{ TransactionDetail
Game ||--o{ TransactionDetail
User ||--o{ Cart
Game ||--o{ Cart
User ||--o{ Library
Game ||--o{ Library
User ||--o{ Review
Game ||--o{ Review
User ||--o{ Friendships
User ||--o{ FriendRequests
User ||--o{ Conversations
Conversations ||--o{ Messages
@enduml
```

## screen_flows

```mermaid
graph TD
    Splash[Splash Screen] -->|Authenticated| Home
    Splash -->|Unauthenticated| Login

    %% Auth Flow
    Login[Login Screen] -->|Register| Register[Register Screen]
    Register --> VerifyEmail[Verify Email]
    VerifyEmail --> RegisterDetails[Register Details]
    Login --> ForgotPwd[Forgot Password]
    ForgotPwd --> ResetPwd[Reset Password]

    %% Main Shell
    subgraph Bottom Navigation Shell
        Home[Home Storefront]
        Cart[Cart Screen]
        Library[Library Screen]
        Chat[Chat List]
    end

    %% Store Interactions
    Home --> Search[Game Search]
    Home --> AllGames[All Games]
    Home --> GameDetail[Game Detail]
    Search --> GameDetail
    AllGames --> GameDetail

    %% Cart & Payment Flow
    GameDetail -->|Add to Cart| Cart
    Cart -->|Checkout| Payment[Payment WebView]
    Payment --> PaymentResult[Payment Result]

    %% Library & Community
    Library -->|Play/Review| GameDetail
    Chat --> ChatDetail[Chat Detail]

    %% Profile Flow
    Home --> Profile[User Profile]
    Profile --> Account[Account Detail]
    Account --> EditProfile[Edit Profile]
    Account --> Wallet[Wallet Screen]
    Wallet --> Payment
```

## actors

```plantuml
@startuml
actor "Guest" as Guest
actor "User" as User
actor "Publisher" as Publisher
actor "Admin" as Admin

Guest <|-- User
User <|-- Publisher
User <|-- Admin
@enduml
```

## guest_use_case

```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor Guest

rectangle "Centurion Store" {
  usecase "View Home Page" as UC1
  usecase "View About us" as UC2
  usecase "View Private Policy" as UC3
  usecase "View Terms of Use" as UC4
  usecase "Register" as UC5
  usecase "Download launcher" as UC6
  usecase "View Game list" as UC7
  usecase "Search Game" as UC8
  usecase "Filter Game" as UC9
  usecase "View Game Detail" as UC10
  usecase "View Review" as UC11
  usecase "View Rate" as UC12
}

Guest -- UC1
Guest -- UC2
Guest -- UC3
Guest -- UC4
Guest -- UC5
Guest -- UC6
Guest -- UC7
Guest -- UC8
Guest -- UC9
Guest -- UC10
Guest -- UC11
Guest -- UC12
@enduml
```

## user_use_case_1
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor User

rectangle "Centurion Store" #LightBlue {
  usecase "Login" as UC1
  usecase "Login with Google" as UC2
  usecase "Login with Username & Password" as UC3
  usecase "Forgot password" as UC4
  usecase "View Account info" as UC5
  usecase "Update info" as UC6
  usecase "Change Password" as UC7
  usecase "Update Avatar" as UC8
}

User -- UC1
User -- UC2
User -- UC3
User -- UC4
User -- UC5
User -- UC6
User -- UC7
User -- UC8
@enduml
```

## user_use_case_2
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor User

rectangle "Centurion Store" #LightBlue {
  usecase "View Transaction History" as UC9
  usecase "View Transaction Detail" as UC10
  usecase "Make Refunds" as UC11
  usecase "View Library" as UC12
  usecase "View Game Detail" as UC13
  usecase "View Wallet" as UC14
  usecase "Add funds" as UC15
  usecase "Update cart" as UC16
  usecase "View cart" as UC17
  usecase "Remove from cart" as UC18
  usecase "Checkout" as UC19
}

User -- UC9
User -- UC10
User -- UC11
User -- UC12
User -- UC13
User -- UC14
User -- UC15
User -- UC16
User -- UC17
User -- UC18
User -- UC19
@enduml
```

## user_use_case_3
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor User

rectangle "Centurion Store" #LightBlue {
  usecase "Make Review" as UC20
  usecase "View Review" as UC21
  usecase "Edit Review" as UC22
  usecase "Remove Review" as UC23
  usecase "Vote Review" as UC24
  usecase "View Notifications" as UC25
  usecase "Remove Notification" as UC26
  usecase "View other User profile" as UC27
  usecase "View other's Library" as UC28
}

User -- UC20
User -- UC21
User -- UC22
User -- UC23
User -- UC24
User -- UC25
User -- UC26
User -- UC27
User -- UC28
@enduml
```

## user_use_case_4
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor User

rectangle "Centurion Store" #LightBlue {
  usecase "Chat" as UC29
  usecase "Block" as UC30
  usecase "Add Friends" as UC31
  usecase "Unblock" as UC32
  usecase "Unfriend" as UC33
  usecase "View Friend List" as UC34
  usecase "Make Feedback" as UC35
  usecase "View Feedback List" as UC36
  usecase "View Feedback Detail" as UC37
  usecase "Remove Feedback" as UC38
  usecase "Apply Publisher" as UC39
}

User -- UC29
User -- UC30
User -- UC31
User -- UC32
User -- UC33
User -- UC34
User -- UC35
User -- UC36
User -- UC37
User -- UC38
User -- UC39
@enduml
```

## user_use_case_5
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor User
actor Guest

rectangle "Centurion Store" #LightBlue {
  usecase "Subscribe family plan" as UC40
  usecase "Create Family" as UC41
  usecase "Create Family Invitation" as UC42
  usecase "Cancel Family Invitation" as UC43
  usecase "Kick Family Members" as UC44
  usecase "Share Games" as UC45
  usecase "Join Family" as UC46
  usecase "Leave Family" as UC47
  usecase "View Threads" as UC48
  usecase "Create Thread" as UC49
  usecase "Edit Thread" as UC50
  usecase "Delete Thread" as UC51
  usecase "Comment Thread" as UC52
}

User -- UC40
User -- UC41
User -- UC42
User -- UC43
User -- UC44
User -- UC45
User -- UC46
User -- UC47
Guest -- UC48
User -- UC49
User -- UC50
User -- UC51
User -- UC52
@enduml
```

## publisher_use_case
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor Publisher

rectangle "Centurion Store" #LightBlue {
  usecase "View Owned Game list" as UC1
  usecase "Request updating game" as UC2
  usecase "Unlist game" as UC3
  usecase "View Game's news" as UC4
  usecase "List game" as UC5
  usecase "Request Adding game" as UC6
  usecase "View pending requests list" as UC7
  usecase "Cancel Request" as UC8
  usecase "View Decline Request list" as UC9
  usecase "Edit Request" as UC10
  usecase "Remove Request" as UC11
}

Publisher -- UC1
Publisher -- UC2
Publisher -- UC3
Publisher -- UC4
Publisher -- UC5
Publisher -- UC6
Publisher -- UC7
Publisher -- UC8
Publisher -- UC9
Publisher -- UC10
Publisher -- UC11
@enduml
```

## admin_use_case_1
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor Admin

rectangle "Centurion Store" #LightBlue {
  usecase "View Game Detail" as UC1
  usecase "View Game List" as UC2
  usecase "List game" as UC3
  usecase "Unlist game" as UC4
  usecase "View Request List" as UC5
  usecase "View Request Detail" as UC6
  usecase "Decline request" as UC7
  usecase "View Users List" as UC8
}

Admin -- UC1
Admin -- UC2
Admin -- UC3
Admin -- UC4
Admin -- UC5
Admin -- UC6
Admin -- UC7
Admin -- UC8
@enduml
```

## admin_use_case_2
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
actor Admin

rectangle "Centurion Store" #LightBlue {
  usecase "View User's Profile" as UC9
  usecase "Ban User" as UC10
  usecase "Unban User" as UC11
  usecase "View Report" as UC12
  usecase "View Feedback List" as UC13
  usecase "View Feedback Detail" as UC14
  usecase "Answer Feedback" as UC15
  usecase "Dismiss Feedback" as UC16
}

Admin -- UC9
Admin -- UC10
Admin -- UC11
Admin -- UC12
Admin -- UC13
Admin -- UC14
Admin -- UC15
Admin -- UC16
@enduml
```
