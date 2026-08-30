## 2. Implementation Plan (`docs/models_prompt_plan.md`)

> **Agent Instruction:** *Execute the following tasks sequentially. You must stop at every "Review Point" and wait for my explicit human approval before moving to the next numbered task.*

1. **Task 1: Scaffold the Directory**
* **Target:** `lib/data/models/`
* **Action:** Check if this directory path exists. If it does not, CREATE it. Do not create any `.dart` files yet.
* **Review Point:** Stop and confirm the directory is ready.


2. **Task 2: Implement UserModel**
* **Target:** `lib/data/models/user_model.dart`
* **Action:** CREATE this file. Write the `UserModel` class exactly as defined in `models_spec.md` (Item 3). Ensure the `copyWith`, `toMap`, and `fromMap` methods are fully fleshed out and type-safe.
* **Review Point:** Stop and output the generated code so I can review the field nullability.


3. **Task 3: Implement MessModel**
* **Target:** `lib/data/models/mess_model.dart`
* **Action:** CREATE this file. Write the `MessModel` class exactly as defined in `models_spec.md` (Item 4). Ensure `billingEnabled` defaults to `false` if not provided in the `fromMap` factory.
* **Review Point:** Stop and output the generated code so I can review the default values.


4. **Task 4: Implement MenuModel**
* **Target:** `lib/data/models/menu_model.dart`
* **Action:** CREATE this file. Write the `MenuModel` class exactly as defined in `models_spec.md` (Item 5).
* **Critical Constraint:** In the `fromMap` method, write a parsing safety check to convert the incoming `date` field from a Firebase `Timestamp` into a standard Dart `DateTime` object.
* **Review Point:** Stop and output the generated code so I can review the Timestamp parsing logic.


5. **Task 5: Export Barrel File**
* **Target:** `lib/data/models/models.dart`
* **Action:** CREATE this file. Add `export` statements for `user_model.dart`, `mess_model.dart`, and `menu_model.dart`.
* **Review Point:** Stop and confirm completion. The models phase is now finished.