## **3\. Requirement Appendix**

### **3.1 Business Rules**

| ID | Rule Definition | Type of Rule | Static or Dynamic |
| :---- | :---- | :---- | :---- |
| BR-01 | Passwords must be at least 8 characters long and include one uppercase letter, one number and one special character. | Constraint | Static |
| BR-02 | Email address must be unique in the system and cannot be duplicated with existing accounts. | Constraint | Static |
| BR-03 | Username must be unique across all users in the system. | Constraint | Static |
| BR-04 | OTP verification is required via email before account creation can be completed. | Process | Static |
| BR-05 | Password reset requires email verification and valid OTP confirmation. | Process | Static |
| BR-06 | Login-Required Actions | Authorization | Static |
| BR-07 | Banned-User lose all interactive privileges (Reviews, chat, group management, major actions) | Authorization | Dynamic |
| BR-08 | Account balance must be sufficient for checkout, otherwise redirect to top-up page. | Business Logic | Dynamic |
| BR-09 | Users can only write reviews for games they own in their library. | Authorization | Dynamic |
| BR-10 | Review content must comply with community standards or will be rejected. | Content Validation | Dynamic |
| BR-11 | Review content and recommendation (Recommend/Not recommend) fields are mandatory. | Constraint | Static |
| BR-12 | Review content must not exceed 8000 words. | Constraint | Static |
| BR-13 | Refunds allowed within 7 days of purchase AND if playtime \< 2 hours | Business Logic | Dynamic |
| BR-14 | All required fields must be completed in a Form of Request or Thread | Constraint | Static |
| BR-15 | Publisher Serial ID must be exactly 12 numeric characters. | Constraint | Static |
| BR-16 | Only Publishers can create game addition requests. | Authorization | Static |
| BR-17 | Publishers can only manage games that have been approved and belong to them. | Authorization | Dynamic |
| BR-18 | Game price field must contain only numeric values. | Constraint | Static |
| BR-19 | Game tags must be selected from predefined available options. | Constraint | Static |
| BR-20 | Memory requirements must be entered as a number followed by "GB" (e.g., 8GB). | Constraint | Static |
| BR-21 | Game submission must include at least one image asset. | Constraint | Static |
| BR-22 | Game files must be submitted in .zip format only. | Constraint | Static |
| BR-23 | Game .zip file must contain launcher.exe file. | Constraint | Static |
| BR-24 | Listed state can only be changed if currently opposite | Business Logic | Dynamic |
| BR-25 | Game updates must follow the same rules as new game submissions. | Process | Static |
| BR-26 | Friend Code search field accepts only numeric characters. | Constraint | Static |
| BR-27 | Users cannot have more than 285 friends. | Constraint | Static |
| BR-28 | Mutual block status prevents request | Authorization | Dynamic |
| BR-29 | Users can create maximum 10 group chats. | Constraint | Static |
| BR-30 | Each group chat can have maximum 50 members including the owner. | Constraint | Static |
| BR-31 | Group chat creation requires group name and minimum 2 initial members including owner. | Constraint | Static |
| BR-32 | Chat messages cannot exceed 8000 words. | Constraint | Static |
| BR-33 | Admin accounts are unique and can only be added through direct database insertion. | Constraint | Static |
| BR-34 | Admin can only ban users who are not currently banned. | Authorization | Dynamic |
| BR-35 | Admin can only unban users who are currently banned. | Authorization | Dynamic |
| BR-36 | Admin can only list games that are currently unlisted. | Authorization | Dynamic |
| BR-37 | Admin can only unlist games that are currently listed. | Authorization | Dynamic |
| BR-38 | New family creation requires subscription to a subscription plan. | Business Logic | Static |
| BR-39 | Family can have maximum 5 members including the owner. | Constraint | Static |
| BR-40 | Total invitations is equal or less than total remain slots in Family members | Constraint | Static |
| BR-41 | Only family owner can share games with family members. | Authorization | Static |
| BR-42 | Game sharing availability depends on the current subscription plan (4 plans total). | Business Logic | Dynamic |
| BR-43 | Only family owner can extend plan by subscribing to new plan when expired or upgrading current plan. | Authorization | Static |
| BR-44 | Only family owner can make changes in family. | Authorization | Static |
| BR-45 | Users can only join family through invitation. | Authorization | Static |
| BR-46 | Cannot purchase lower tier subscription plan if current plan is still active. | Business Logic | Dynamic |
| BR-47 | All shared games become unplayable when family subscription expires. | Business Logic | Dynamic |
| BR-48 | Email address must follow the format: \<\>@domain | Business Logic | Static |
| BR-49 | Users are not allowed to add a game that is already in their Library to the Cart. Call the API `/user/library/contain/{gameId}` to verify ownership before displaying the "Add to Cart" button. | Business Logic | Dynamic |


### **3.2 Common Requirements**
- All API calls must configure a timeout limit of 10 seconds.
- Display a Loading Spinner while fetching data from the server.

### **3.3 Application Messages List**
- "Registration successful!"
- "Invalid username or password."
- "OTP verified successfully."
- "Adding game to cart successfully."
- "Checkout successfully."

### **3.4 Other Requirements…**
- No other special requirements.
