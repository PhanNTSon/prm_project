# System Diagrams List

## package_diagram

```mermaid
graph TD
    lib["lib/"] --> core["core/ (Shared Infrastructure - Tech Lead)"]
    lib --> features["features/ (Feature-First Modules)"]
    lib --> main["main.dart"]

    core --> network["network/ (Dio, AuthInterceptor, WebSocketService)"]
    core --> router["router/ (GoRouter, AuthGuard, ShellRoute)"]
    core --> theme["theme/ (AppTheme, AppColors)"]
    core --> utils["utils/ (JwtDecoder)"]
    core --> widgets["widgets/ (Common UI Kit)"]

    features --> auth["auth/ (Dev A)"]
    features --> profile["profile/ (Dev A)"]
    features --> storefront["storefront/ (Dev B)"]
    features --> cart_payment["cart_payment/ (Dev C)"]
    features --> library["library/ (Dev D)"]
    features --> community["community/ (Tech Lead - Sơn)"]

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
    A <-->|HTTP/REST API<br>JSON payloads via Dio| B
    A <-->|WebSocket STOMP<br>SockJS /ws real-time| B
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

Guest <|-- User
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
  usecase "Register" as UC5
  usecase "View Game list" as UC7
  usecase "Search Game" as UC8
  usecase "Filter Game" as UC9
  usecase "View Game Detail" as UC10
  usecase "View Review" as UC11
  usecase "View Rate" as UC12
}

Guest -- UC1
Guest -- UC5
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
  usecase "Login with Username & Password" as UC3
  usecase "Forgot password" as UC4
  usecase "View Account info" as UC5
  usecase "Update info" as UC6
  usecase "Update Avatar" as UC8
}

User -- UC1
User -- UC3
User -- UC4
User -- UC5
User -- UC6
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
  usecase "View Review" as UC21
  usecase "View other User profile" as UC27
}

User -- UC21
User -- UC27
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
  usecase "Add Friends" as UC31
  usecase "Unfriend" as UC33
  usecase "View Friend List" as UC34
}

User -- UC29
User -- UC31
User -- UC33
User -- UC34
@enduml
```


