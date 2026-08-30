## 2. Implementation Plan (`.claude/plans/repos_prompt_plan.md`)

> **Agent Instruction:** *Execute the following tasks sequentially. You must stop at every "Review Point" and wait for my explicit human approval before moving to the next numbered task.*

1. **Task 1: Scaffold the Directory**
* **Target:** `lib/data/repos/`
* **Action:** Check if this directory path exists. If it does not, CREATE it. Do not create any `.dart` files yet.
* **Review Point:** Stop and confirm the directory is ready.


2. **Task 2: Implement AuthRepo**
* **Target:** `lib/data/repos/auth_repo.dart`
* **Action:** CREATE this file. Implement the `AuthRepo` class exactly as defined in `repos_spec.md` (Item 3). Ensure the `FirebaseFirestore` and `FirebaseAuth` instances are injected via the constructor.
* **Review Point:** Stop and output the generated code so I can review the Firebase error handling and user creation flow.


3. **Task 3: Implement MessRepo**
* **Target:** `lib/data/repos/mess_repo.dart`
* **Action:** CREATE this file. Implement the `MessRepo` class exactly as defined in `repos_spec.md` (Item 4). You must write a private helper function to generate the 6-character random alphanumeric `inviteCode` during mess creation.
* **Review Point:** Stop and output the generated code so I can verify the invite code generation logic.


4. **Task 4: Implement MenuRepo**
* **Target:** `lib/data/repos/menu_repo.dart`
* **Action:** CREATE this file. Implement the `MenuRepo` class exactly as defined in `repos_spec.md` (Item 5). Ensure date queries match the exact start and end of the specified `DateTime` day to avoid timezone matching errors.
* **Review Point:** Stop and output the generated code so I can review the date querying logic.


5. **Task 5: Implement AttendanceRepo**
* **Target:** `lib/data/repos/attendance_repo.dart`
* **Action:** CREATE this file. Implement the `AttendanceRepo` class exactly as defined in `repos_spec.md` (Item 6). Ensure `getLiveHeadCountStream` correctly aggregates boolean fields and `guestCount` maps across all attendance documents for the specified day.
* **Review Point:** Stop and output the generated code so I can review the real-time stream aggregation logic.


6. **Task 6: Export Barrel File**
* **Target:** `lib/data/repos/repos.dart`
* **Action:** CREATE this file. Add `export` statements for `auth_repo.dart`, `mess_repo.dart`, `menu_repo.dart`, and `attendance_repo.dart`.
* **Review Point:** Stop and confirm completion. The repositories phase is now finished.