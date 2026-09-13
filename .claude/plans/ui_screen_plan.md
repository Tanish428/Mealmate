
## 2. Generic Image-to-Code Implementation Plan (`.claude/plans/ui_screen_plan.md`)

> **Agent Instruction:** *Execute the following tasks sequentially to build the provided UI image. You must stop at every "Review Point" and wait for explicit human approval before moving to the next task.*

1. **Task 1: Image Analysis & Component Mapping**
* **Target:** Memory/Context
* **Action:** Analyze the provided screen mockup image. List out the layout structure (Rows, Columns, Stacks) and identify which visual elements map to the existing reusable widgets (`CustomButton`, `CustomTextField`, etc.).
* **Review Point:** Stop and output your breakdown. Do not write the Flutter code yet. Wait for my approval on your widget tree strategy.


2. **Task 2: Scaffold the Screen File**
* **Target:** `lib/ui//.dart`
* **Action:** CREATE the file in the appropriate directory. Write the base `StatelessWidget` or `StatefulWidget` containing the `Scaffold`, `SafeArea`, and top-level layout structure.
* **Review Point:** Stop and output the base scaffold code. Wait for my approval.


3. **Task 3: Implement Details & Theme Tokens**
* **Target:** `lib/ui//.dart`
* **Action:** Flesch out the full widget tree based on the image. Strictly apply the design tokens (`AppColors`, `AppSpacing`, `AppTextStyles`) to match the mockup's visual hierarchy.
* **Review Point:** Stop and output the final code for the screen. Wait for my approval.


4. **Task 4: Static Analysis & Polish**
* **Target:** Terminal
* **Action:** Run `flutter analyze` against the newly created file. Fix any unused imports, missing const modifiers, or potential layout overflows.
* **Review Point:** Stop and confirm the screen is complete and warning-free.



---