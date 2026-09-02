
## 2. Implementation Plan (`.claude/plans/services_prompt_plan.md`)

> **Agent Instruction:** *Execute the following tasks sequentially. You must stop at every "Review Point" and wait for my explicit human approval before moving to the next numbered task.*

1. **Task 1: Scaffold the Directory**
* **Target:** `lib/data/services/`
* **Action:** Check if this directory path exists. If it does not, CREATE it. Do not create any `.dart` files yet.
* **Review Point:** Stop and confirm the directory is ready.


2. **Task 2: Implement FirebaseAuthService**
* **Target:** `lib/data/services/firebase_auth_service.dart`
* **Action:** CREATE this file. Implement the `FirebaseAuthService` class exactly as defined in `services_spec.md` (Item 3). Ensure all methods include a `try-catch` block that throws a standard Dart `Exception` containing the underlying Firebase error message.
* **Review Point:** Stop and output the generated code so I can review the wrapper logic and error handling.


3. **Task 3: Implement NotificationService**
* **Target:** `lib/data/services/notification_service.dart`
* **Action:** CREATE this file. Implement the `NotificationService` class exactly as defined in `services_spec.md` (Item 4). Ensure `requestPermissions()` checks the authorization status and returns `true` only if authorized or provisionally authorized.
* **Review Point:** Stop and output the generated code so I can verify the permission handling and FCM token retrieval.


4. **Task 4: Export Barrel File**
* **Target:** `lib/data/services/services.dart`
* **Action:** CREATE this file. Add `export` statements for `firebase_auth_service.dart` and `notification_service.dart`.
* **Review Point:** Stop and confirm completion. The external services phase is now finished.