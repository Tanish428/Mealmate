## 1. Specification Document (`.claude/specs/repos_spec.md`)

> **Agent Instruction:** *Read and retain this document as the absolute source of truth for the Phase 1 and Phase 2 database access layer. Do not deviate from these repository patterns, method signatures, or error-handling guidelines.*

1. **Architecture Rule:** All data access logic and Firebase interactions must reside strictly within the `lib/data/repos/` directory. UI and State providers must never import `cloud_firestore` or `firebase_auth` directly.
2. **Design Pattern & Error Handling:**
* Every repository must be a standard Dart class that injects its required Firebase instances (e.g., `FirebaseAuth`, `FirebaseFirestore`) via the constructor.
* Every asynchronous method must be wrapped in a `try-catch` block. Catch `FirebaseException` and rethrow clean, human-readable string messages (e.g., "Invalid invite code" or "Network error").


3. **AuthRepo Specification:**
* `signUp({required String email, required String password, required String name, required String role}) -> Future<UserModel>`: Creates a Firebase Auth user, writes the profile to the `users` Firestore collection, and returns the `UserModel`.
* `signIn({required String email, required String password}) -> Future<UserModel>`: Authenticates and fetches the user document.
* `signOut() -> Future<void>`: Clears the Firebase Auth session.
* `authStateChanges() -> Stream<User?>`: Exposes the underlying Firebase Auth state stream.
* `getCurrentUserData(String uid) -> Future<UserModel?>`: Fetches the user document from Firestore.


4. **MessRepo Specification:**
* `createMess(MessModel mess) -> Future<MessModel>`: Writes a new mess to the `messes` collection. Automatically generates a 6-character random alphanumeric string for the `inviteCode`.
* `getMessById(String messId) -> Future<MessModel?>`: Fetches a specific mess by its document ID.
* `getMessByInviteCode(String inviteCode) -> Future<MessModel?>`: Queries the `messes` collection where `inviteCode` matches.
* `joinMess({required String userId, required String messId}) -> Future<void>`: Updates the user's document to append the `messId` to their `messIds` array.


5. **MenuRepo Specification:**
* `publishMenu(MenuModel menu) -> Future<void>`: Writes the `MenuModel` to the `menus` collection.
* `getMenuForDate({required String messId, required DateTime date}) -> Future<MenuModel?>`: Queries the `menus` collection for a specific mess and date.


6. **AttendanceRepo Specification:**
* `updateAttendance({required String messId, required String userId, required DateTime date, bool? breakfast, bool? lunch, bool? dinner}) -> Future<void>`: Upserts a user's opt-in/opt-out status in the `attendance` collection.
* `getLiveHeadCountStream({required String messId, required DateTime date}) -> Stream<Map<String, int>>`: Returns a real-time stream calculating the total expected headcount for breakfast, lunch, and dinner.
---