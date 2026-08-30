## 1. Specification Document (`docs/models_spec.md`)

> **Agent Instruction:** *Read and retain this document as the absolute source of truth for the Phase 1 database schema. Do not deviate from these data types or naming conventions.*

1. **Architecture Rule:** All data models must reside strictly within the `lib/data/models/` directory.
2. **Immutability & Serialization:** Every model must be an immutable Dart class with `final` properties. Every class must include:
* A constructor with appropriate `required` modifiers.
* A `copyWith()` method for state cloning.
* `toMap()` and `fromMap(Map<String, dynamic> map)` for Firestore serialization.


3. **UserModel Schema:**
* `userId` (String, required)
* `name` (String, required)
* `email` (String, required)
* `phone` (String, nullable)
* `role` (String: 'owner' or 'member', required)
* `messIds` (List, required, default to empty list)


4. **MessModel Schema:**
* `messId` (String, required)
* `name` (String, required)
* `createdBy` (String, required) - represents the owner's userId
* `inviteCode` (String, required) - 6-character string
* `billingEnabled` (bool, required, default to `false`)
* `perDayRate` (double, nullable)


5. **MenuModel Schema:**
* `menuId` (String, required)
* `messId` (String, required)
* `date` (DateTime, required) - must handle Firestore Timestamp conversion in `fromMap`.
* `breakfastItems` (List<Map<String, dynamic>>, required, default empty)
* `lunchItems` (List<Map<String, dynamic>>, required, default empty)
* `dinnerItems` (List<Map<String, dynamic>>, required, default empty)
---