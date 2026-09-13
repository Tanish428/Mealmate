> **Agent Instruction:** Execute the following tasks sequentially to build the provided UI image. You must stop at every "Review Point" and wait for explicit human approval before moving to the next task.

1. **Task 1: Image Analysis & Component Mapping**
   * **Target:** Memory/Context
   * **Action:** Analyze the provided screen mockup image. List the layout structure and identify which visual elements map to the existing reusable widgets (`CustomButton`, `CustomTextField`) and which require local image assets.
   * **Review Point:** Stop and output your breakdown. Do not write the Flutter code yet. Wait for my approval.

2. **Task 2: Scaffold the Screen File**
   * **Target:** `lib/ui//.dart`
   * **Action:** CREATE the file. Write the base `StatelessWidget` or `StatefulWidget` containing the `Scaffold`, `SafeArea`, and top-level layout structure.
   * **Review Point:** Stop and output the base scaffold code. Wait for my approval.

3. **Task 3: Implement Details & Theme Tokens**
   * **Target:** `lib/ui//.dart`
   * **Action:** Flesh out the full widget tree based on the image. Strictly apply the design tokens and insert any local assets at their exact positions.
   * **Review Point:** Stop and output the final code for the screen. Wait for my approval.

4. **Task 4: Static Analysis & Polish**
   * **Target:** Terminal
   * **Action:** Run `flutter analyze` against the newly created file. Fix any unused imports or potential layout overflows. 
   * **Review Point:** Stop and confirm the screen is complete and warning-free.