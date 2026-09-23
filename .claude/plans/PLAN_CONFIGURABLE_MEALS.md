# PLAN_CONFIGURABLE_MEALS.md

## 1. Execution Overview

Implement configurable meal offerings across five clean-architecture phases. Database migrations are already applied; focus exclusively on data models, repositories, controllers, and UI screens.

---

## Phase 1: Domain Models

### 1.1. `lib/data/models/mess_model.dart`

* Add field: `final List servedMeals;`
* Update `fromJson`: `servedMeals: List.from(json['served_meals'] ?? const [])`
* Update `toJson`: `'served_meals': servedMeals`

### 1.2. `lib/data/models/skip_model.dart`

* Ensure field exists: `final String mealType;`
* Update `fromJson`: `mealType: json['meal_type']?.toString().toLowerCase() ?? 'lunch'`
* Update `toJson`: `'meal_type': mealType.toLowerCase()`

---

## Phase 2: Data Repositories

### 2.1. `lib/data/repos/mess_repo.dart`

* Update `createMess`:
* Add required parameter `List servedMeals`.
* Include `'served_meals': servedMeals` in Supabase insert payload.


* Update mess fetch methods to include `served_meals`.

### 2.2. `lib/data/repos/profile_repo.dart`

* Update `getMemberProfileDetails`:
* Perform relational query: `.select('*, messes:mess_id(served_meals)')`.
* Expose `served_meals` in the returned map.



### 2.3. `lib/data/repos/attendance_repo.dart`

* Refactor `toggleMealSkip({required String messId, required DateTime date, required String mealType, required bool shouldSkip})`:
* If `shouldSkip`: Upsert `(mess_id, member_id, skip_date, meal_type)` with `onConflict: 'member_id,skip_date,meal_type'`.
* If `!shouldSkip`: Delete record matching `member_id`, `skip_date`, and `meal_type`.


* Refactor `addDateRangeSkips({required String messId, required DateTime startDate, required DateTime endDate, required List activeMeals})`:
* Loop through each date in the range.
* For each date, loop only over `activeMeals` (e.g. `['lunch', 'dinner']`).
* Batch upsert payload to `public.skips`.



---

## Phase 3: Controllers & Logic

### 3.1. `lib/logic/controllers/menu_manager_controller.dart`

* Add state: `List servedMeals = [];`
* Populate `servedMeals` from the mess profile on initialization.
* Expose dynamic tabs matching only items in `servedMeals`.

### 3.2. `lib/logic/controllers/member_dashboard_controller.dart`

* Add state: `List servedMeals = [];`
* Update `isCutoffPassed(DateTime date, String mealType)`:
* Breakfast: `hour >= 7`
* Lunch: `hour >= 10`
* Dinner: `hour >= 19`
* Future dates: Always `false`.


* Update `loadAttendanceData()`:
* Parse `served_meals` from joined profile query.
* Dynamically scale denominator:
```dart
final int mealsPerDay = servedMeals.isNotEmpty ? servedMeals.length : 1;
final int totalPossibleMeals = ((now.difference(profileCreatedAt).inDays) + 1) * mealsPerDay;

```


* Calculate attendance percentage clamped to `[0.0, 100.0]`. No streak calculation.


* Update `planMultiDayLeave(DateTimeRange range)`:
* Pass `activeMeals: servedMeals` to `attendanceRepo.addDateRangeSkips`.



---

## Phase 4: Owner UI

### 4.1. `lib/ui/owner/create_mess_screen.dart`

* Add state: `final Set _selectedMeals = {};`
* Render "Meal Services Offered" section with three `FilterChip` items:
* **Breakfast** (`breakfast`)
* **Lunch** (`lunch`)
* **Dinner** (`dinner`)


* Initialize all chips as **unselected**.
* Validation: Block submission if `_selectedMeals.isEmpty` with error: *"Select at least one meal service."*
* Pass `_selectedMeals.toList()` into `messRepo.createMess`.

### 4.2. `lib/ui/owner/menu_manager_screen.dart`

* Dynamically build the meal selector / `TabBar` using `controller.servedMeals`.
* Remove static 3-tab assumptions.

---

## Phase 5: Member UI

### 5.1. `lib/ui/member/attendance_toggle_screen.dart`

* **Header:** "Manage Attendance" with calendar icon button opening `showDateRangePicker`.
* **Eco Banner:** Light-green container with leaf icons: *"Your updates help reduce food waste. Thank you!"*
* **Dynamic Meal Feed:**
* Iterate strictly over `controller.servedMeals`.
* **Today Section:**
* Display cards for active meals whose cutoff has not passed.
* If all active meals for today have passed cutoff, collapse and hide the "Today" section entirely.


* **Tomorrow Section:**
* Render cards for all `servedMeals` with status badge *"Opens Tomorrow"*.
* Promoted to primary section if "Today" is collapsed.




* **Meal Card Structure:**
* Leading Icon: Sun (Breakfast), Fork & Knife (Lunch), Moon (Dinner).
* Title, operational window, cutoff badge.
* Left column: Menu item list from `MenuRepo` with green checkmark icons.
* Right column: Rounded food thumbnail.
* Bottom Action: Segmented toggle `[ (✓) Attending ]` (#C84B31) vs `[ (✕) Opt Out ]` (#5A5A5A). Disable with lock label when cutoff has passed.



---

## Phase 6: Verification Checklist

* [ ] Mess creation blocks submission if no chips are selected.
* [ ] Mess creation with `['lunch', 'dinner']` persists array to Supabase.
* [ ] Owner Menu Manager only displays tabs for active meals.
* [ ] Member Attendance feed renders cards only for active meals.
* [ ] After 7:00 PM (19:00), Today's Dinner locks; Today section hides on reload.
* [ ] Leave picker generates exactly $D \times \vert{}\text{served\_meals}\vert{}$ rows in `public.skips`.
* [ ] Attendance percentage reflects $N$-scaled calculation without streaks.