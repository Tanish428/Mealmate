# SPEC_CONFIGURABLE_MEALS.md

## 1. Scope & Database Context

MealMate dynamically adapts to the specific meal services configured by each mess (`breakfast`, `lunch`, `dinner`). Database constraints already enforce:

* `public.messes.served_meals`: Array of active meals (`TEXT[]`), must not be empty.
* `public.skips`: Composite unique constraint `(member_id, skip_date, meal_type)`.

---

## 2. Cutoff Timings & View Rules

| Meal | Serving Time | Cutoff Lock Time | Condition (Today) |
| --- | --- | --- | --- |
| **Breakfast** | 07:30 AM – 09:30 AM | **07:00 AM** | `hour >= 7` |
| **Lunch** | 12:30 PM – 02:30 PM | **10:00 AM** | `hour >= 10` |
| **Dinner** | 07:30 PM – 09:30 PM | **07:00 PM** | `hour >= 19` |

* **Today Section:** Only renders meals present in `messes.served_meals`. When all configured meals for today pass their cutoff, the "Today" block collapses completely.
* **Tomorrow Section:** Always shows all configured `served_meals` with active toggles ("Opens Tomorrow").
* **Cutoff Guard:** Future dates are never locked.

---

## 3. Mathematical Formula (No Streaks)

Let $N = \vert{}\text{served\_meals}\vert{}$ (where $1 \le N \le 3$):

$$\text{Total Enrolled Days} = (\text{Today} - \text{Join Date}) + 1$$

$$\text{Total Expected Meals} = \text{Total Enrolled Days} \times N$$

$$\text{Attendance \%} = \left(\frac{\text{Total Expected Meals} - \text{Past Valid Skips}}{\text{Total Expected Meals}}\right) \times 100$$

* `Past Valid Skips`: Count of records in `skips` where `skip_date < Today` OR (`skip_date == Today` AND meal cutoff has passed).
* Clamped between `0.0` and `100.0`. Defaults to `100.0%` if enrolled days is 0.

---

## 4. Operational Requirements

### 4.1. Mess Owner Experience

* **Mess Creation (`create_mess_screen.dart`):**
* Three selectable chips: Breakfast, Lunch, Dinner.
* **Default state:** All unselected (`selectedMeals = {}`).
* **Validation:** Submitting with 0 selected blocks navigation and triggers validation: *"Select at least one meal service."*


* **Menu Manager (`menu_manager_screen.dart`):**
* Tabs generate dynamically from `served_meals`. Unoffered meals are completely omitted.



### 4.2. Member Experience (`attendance_toggle_screen.dart`)

* **Header & Banner:**
* Title: "Manage **Attendance**" (terracotta `#C84B31`).
* Top-right calendar icon button for multi-day leave picker.
* Eco Banner: Soft green pill container with leaf icons and waste-reduction notice.


* **Meal Cards:**
* Built only for active meals in `served_meals`.
* Left meal icon (Sun / Fork & Knife / Moon) + serving time.
* Top-right status pill (`Locks in Xh Ym`, `Cutoff Passed`, or `Opens Tomorrow`).
* Left body: Menu item checklist with green checkmark icons (or *"Menu to be announced"*).
* Right body: Rounded food thumbnail.
* Bottom toggle bar: Segmented button `[ (✓) Attending ]` (Coral `#C84B31`) vs `[ (✕) Opt Out ]` (Slate `#5A5A5A`).
* Cutoff passed $\rightarrow$ Interaction disabled with lock indicator.


* **Multi-Day Leave:**
* Date range picker generates and batch-upserts $D \times N$ records into `skips`.



---

## 5. File Architecture

* **`lib/data/models/mess_model.dart`**: Parse `served_meals` (`List`).
* **`lib/data/models/skip_model.dart`**: Include `mealType` in serialization.
* **`lib/data/repos/mess_repo.dart`**: Save `served_meals` during mess creation.
* **`lib/data/repos/profile_repo.dart`**: Join `messes(served_meals)` when fetching member profile.
* **`lib/data/repos/attendance_repo.dart`**:
* `toggleMealSkip`: Upsert/delete by `(mess_id, member_id, skip_date, meal_type)`.
* `addDateRangeSkips`: Generate discrete rows strictly for `activeMeals`.


* **`lib/logic/controllers/member_dashboard_controller.dart`**: Holds `servedMeals`, enforces 7 AM / 10 AM / 7 PM cutoffs, calculates $N$-scaled attendance rate.
* **`lib/ui/member/attendance_toggle_screen.dart`**: Card-based dynamic feed matching design reference.

---

## 6. Acceptance Criteria

* [ ] Mess creation fails if no meal chip is checked.
* [ ] Owner menu management renders only tabs for selected meals.
* [ ] Member attendance feed renders cards exclusively for selected meals.
* [ ] Dinner cutoff strictly locks at 07:00 PM (19:00).
* [ ] After all today's configured meals pass cutoff, "Today" hides and "Tomorrow" becomes primary.
* [ ] Multi-day leave creates $D \times N$ rows in `public.skips`.
* [ ] Attendance percentage scales with $N \times \text{days}$ with zero streak logic.