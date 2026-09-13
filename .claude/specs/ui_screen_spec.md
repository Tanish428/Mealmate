> **Agent Instruction:** Read this document alongside the provided screen mockup image(s). This spec dictates the strict architectural rules and design system constraints for translating the image into Flutter code.

1. **Architecture & Scope Rule:**
   * Determine the appropriate feature folder based on the screen's context.
   * Never introduce business logic, API calls, or state management providers. Implement the screen using stateless or stateful widgets with empty callbacks (`() {}`).
   * Break down complex UI structures in the image into smaller, private helper widgets within the same file to prevent deep nesting.
2. **Visual Translation & Theme Tokens:**
   * Do not hardcode hex colors or explicit pixel font sizes based on the image. 
   * You must map the visual colors in the mockup to `Theme.of(context).colorScheme` or `AppColors`.
   * You must map the text styles in the mockup to `Theme.of(context).textTheme` or `AppTextStyles`.
   * Map paddings and margins to standard constants (e.g., `AppSpacing.m` for 16.0, `AppSpacing.l` for 24.0).
3. **Component Mapping Strategy:**
   * Implement all buttons exclusively using the existing `CustomButton` widget.
   * Implement all form inputs exclusively using the existing `CustomTextField` widget.
   * For custom local assets (e.g., logos), use `Image.asset('assets/images/filename.png')` and ensure precise alignment using `Row` or `Stack` layouts. Scale the asset properly so it does not overflow its container.
4. **Layout Constraints:**
   * Wrap the main body in a `SafeArea`.
   * Wrap the body in a `SingleChildScrollView` with padding to prevent keyboard overflow.