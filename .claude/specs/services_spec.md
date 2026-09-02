## 1. Specification Document (`.claude/specs/services_spec.md`)

> **Agent Instruction:** *Read and retain this document as the absolute source of truth for the External Services layer. Do not deviate from these wrappers, method signatures, or initialization patterns.*

1. **Architecture Rule:** All direct interactions with external hardware SDKs or third-party APIs (excluding Firestore, which is handled in Repositories) must reside strictly within the `lib/data/services/` directory.
2. **Design Pattern & Separation of Concerns:**
* Services are low-level wrappers. They must not contain application business logic or interact with custom data models (`UserModel`, etc.).
* They return raw data (e.g., Firebase `User` objects, FCM token strings) to be consumed and processed by the Repository or Provider layers.


3. **FirebaseAuthService Specification:**
* **Purpose:** Acts as a clean wrapper around the `FirebaseAuth` SDK.
* **Dependencies:** Requires `FirebaseAuth` instance via constructor injection.
* **Methods:**
* `signInWithEmail({required String email, required String password}) -> Future<User?>`: Authenticates and returns the raw Firebase User.
* `registerWithEmail({required String email, required String password}) -> Future<User?>`: Creates an account and returns the raw Firebase User.
* `signOut() -> Future<void>`: Calls the SDK sign-out method.
* `get authStateChanges -> Stream<User?>`: Exposes the raw authentication state stream.




4. **NotificationService Specification:**
* **Purpose:** Handles Firebase Cloud Messaging (FCM) permissions, token generation, and local notification setup.
* **Dependencies:** Requires `FirebaseMessaging` instance.
* **Methods:**
* `requestPermissions() -> Future<bool>`: Requests notification permissions from the OS (essential for iOS).
* `getDeviceToken() -> Future<String?>`: Fetches the FCM token to be saved to the user's database profile.
* `initializeForegroundListeners() -> void`: Sets up the `FirebaseMessaging.onMessage` listener to handle push notifications while the app is actively open.





---
