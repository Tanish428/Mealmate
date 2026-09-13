## 1. Generic Image-to-Code Specification (`.claude/specs/ui_screen_spec.md`)

> **Agent Instruction:** *Read this document alongside the provided screen mockup image. This spec dictates the strict architectural rules and design system constraints for translating the image into Flutter code.*

1. **Architecture & Scope Rule:**
* Determine the appropriate feature folder based on the screen's context (e.g., `lib/ui/auth/`, `lib/ui/member/`, `lib/ui/owner/`).
* Never introduce business logic, API calls, or state management providers. Implement the screen using stateless or stateful widgets with empty callbacks (`() {}`).
* Break down complex UI structures in the image into smaller, private helper widgets within the same file to prevent deep nesting.


2. **Visual Translation & Theme Tokens:**
* Do not hardcode hex colors or explicit pixel font sizes based on the image.
* You must map the visual colors in the mockup to `Theme.of(context).colorScheme` or `AppColors`.
* You must map the text styles in the mockup to `Theme.of(context).textTheme` or `AppTextStyles`.
* Map the paddings and margins to standard constants like `AppSpacing.m` (16.0) or `AppSpacing.l` (24.0).


3. **Component Mapping Strategy:**
* Scan the image for buttons. Whenever a button is found, implement it exclusively using the existing `CustomButton` widget.
* Scan the image for form inputs. Implement them exclusively using the existing `CustomTextField` widget.
* Scan the image for data cards. Implement them exclusively using the existing `StatCard` or `AppCard` widgets.


4. **Layout Constraints:**
* The screen must be responsive. Always wrap the main body in a `SafeArea`.
* If the mockup implies scrolling or contains form fields, wrap the body in a `SingleChildScrollView` to prevent keyboard overflow.



---

