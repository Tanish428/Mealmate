# PLAN_SURPLUS_PREP_WASTE.md

## 1. Scope & Execution Rules

This document establishes the architecture, database schema, mathematical invariants, and repository specifications for **Surplus Allocation**, **Preparation Logging**, and **Waste Tracking** in MealMate.

---

## 2. Actual Prepared vs Served vs Target Formulation

1. **Target Portions (`target_portions`):**
   - The projected plate count calculated by `PreparationPlannerController` (attending headcount + extra plates + safety buffer).
   - Maintained **strictly separate** from actual food cooked in the kitchen.
2. **Prepared Portions (`prepared_portions`):**
   - The actual quantity of plates/portions cooked by the kitchen staff.
3. **Served Portions (`served_portions`):**
   - The actual quantity of plates/portions consumed by attending members and guests.
4. **Surplus Portions (`surplus_portions`):**
   $$\text{Surplus Portions} = \text{Prepared Portions} - \text{Served Portions}$$
   - Must be non-negative ($\text{Prepared} \ge \text{Served}$).
5. **Discarded Portions (`discarded_portions`):**
   - Portions that spoiled or were thrown away / composted rather than donated.
   - Tracked as a distinct operational metric.

---

## 3. Allocation States & Concurrency Invariant

### 3.1 Allocation States
An allocation has one of three immutable/valid states:
- `pending`: Allocated to a partner and awaiting pickup/handover. (Active allocation; reserves surplus).
- `collected`: Food was successfully picked up and delivered to the donation partner. (Active allocation; **counts as a completed donation**).
- `cancelled`: Allocation was cancelled prior to collection. (Releases surplus back; **does not count as a completed donation**).

> **Critical Rule:** Only allocations with `status = 'collected'` are counted toward completed donations and positive community impact metrics. A notification or pending allocation is NOT a completed donation.

### 3.2 Concurrency & Capacity Invariant
At all times and across concurrent requests, the system enforces:
$$\sum_{\text{status} \in \{\text{'pending'}, \text{'collected'}\}} \text{Allocation Quantity} + \text{Discarded Portions} \le \text{Surplus Portions}$$

- Enforced in PostgreSQL via a row-level lock (`SELECT ... FOR UPDATE` on `meal_prep_records`) inside the `check_surplus_allocation_capacity` trigger.
- Concurrent requests are serialized, preventing race-condition over-allocation.

---

## 4. Multi-Tenant Security & Isolation (RLS)

1. **Owner-Only Scoping:**
   - All reads (`SELECT`) and writes (`INSERT`, `UPDATE`, `DELETE`) on `meal_prep_records`, `donation_partners`, and `surplus_allocations` are strictly restricted to the authenticated owner of the mess (`messes.owner_id = auth.uid()`).
2. **Same-Mess Partner Guarantee:**
   - Composite foreign key: `(partner_id, mess_id) REFERENCES donation_partners(id, mess_id)` guarantees that an allocation cannot select a donation partner belonging to another mess.
3. **No Fake Data:**
   - No mock partners, guessed kilometer distances, or fake availability claims are inserted. If an owner has registered 0 partners, the list is empty.

---

## 5. Implementation Phases

- **Phase 1: Database Migration & Data Repositories** (Current Scope)
  - `supabase/migrations/20260927120000_surplus_prep_waste_phase1.sql`
  - `supabase/tests/rls_and_concurrency_test.sql`
  - `lib/data/models/meal_prep_record_model.dart`
  - `lib/data/models/donation_partner_model.dart`
  - `lib/data/models/surplus_allocation_model.dart`
  - `lib/data/repos/surplus_repo.dart`
  - Unit tests in `test/surplus_models_and_repo_test.dart`
- **Phase 2: Controller Layer** (Subsequent Scope)
  - Connect `SurplusController` to `SurplusRepository`.
  - Connect `PreparationPlannerController` to record targets and prepared counts.
  - Connect `AnalyticsController` to compute real statistics from database records.
- **Phase 3: UI Integration** (Subsequent Scope)
  - Update `surplus_allocation_screen.dart`.
  - Update `waste_reports_screen.dart`.
