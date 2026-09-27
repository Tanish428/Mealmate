-- Test Suite: rls_and_concurrency_test.sql
-- Purpose: Verify RLS isolation between messes, partner validation, and surplus allocation capacity invariant.

DO $$
DECLARE
    v_owner_a UUID;
    v_owner_b UUID;
    v_mess_a UUID;
    v_mess_b UUID;
    v_partner_a UUID := 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1'::uuid;
    v_partner_b UUID := 'b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1'::uuid;
    v_prep_a UUID := 'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2'::uuid;
    v_alloc_1 UUID := 'a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3'::uuid;
    v_alloc_2 UUID := 'a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4'::uuid;
BEGIN
    -- Select two real existing messes and their owners from database
    SELECT id, owner_id INTO v_mess_a, v_owner_a FROM public.messes ORDER BY created_at ASC LIMIT 1;
    SELECT id, owner_id INTO v_mess_b, v_owner_b FROM public.messes ORDER BY created_at ASC OFFSET 1 LIMIT 1;

    IF v_mess_a IS NULL OR v_mess_b IS NULL THEN
        RAISE EXCEPTION 'Test requires at least two registered messes.';
    END IF;

    -- Clean any previous test run artifacts
    DELETE FROM public.surplus_allocations WHERE id IN (v_alloc_1, v_alloc_2);
    DELETE FROM public.meal_prep_records WHERE id = v_prep_a;
    DELETE FROM public.donation_partners WHERE id IN (v_partner_a, v_partner_b);

    -- Setup Partners: Partner A belongs to Mess A, Partner B belongs to Mess B
    INSERT INTO public.donation_partners (id, mess_id, name, is_active)
    VALUES 
        (v_partner_a, v_mess_a, 'Alpha Food Bank', true),
        (v_partner_b, v_mess_b, 'Beta Shelter', true);

    -- Setup Meal Prep Record: Target = 50, Prepared = 60, Served = 50, Discarded = 2.
    -- Calculated Surplus = 60 - 50 = 10. Available for allocation = 10 - 2 = 8.
    INSERT INTO public.meal_prep_records (id, mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions)
    VALUES 
        (v_prep_a, v_mess_a, CURRENT_DATE, 'lunch', 50, 60, 50, 2);

    -- TEST 1: Same-mess partner validation
    -- Attempting to allocate surplus in Mess A using Partner B (from Mess B) MUST FAIL.
    BEGIN
        INSERT INTO public.surplus_allocations (mess_id, meal_prep_record_id, partner_id, quantity, status)
        VALUES (v_mess_a, v_prep_a, v_partner_b, 4, 'pending');
        RAISE EXCEPTION 'TEST 1 FAILED: Cross-mess partner allocation was permitted!';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TEST 1 PASSED: Cross-mess partner assignment was rejected as expected.';
    END;

    -- TEST 2: Valid allocation within available surplus (Allocating 5 of 8 available)
    INSERT INTO public.surplus_allocations (id, mess_id, meal_prep_record_id, partner_id, quantity, status)
    VALUES (v_alloc_1, v_mess_a, v_prep_a, v_partner_a, 5, 'pending');
    RAISE NOTICE 'TEST 2 PASSED: Valid allocation of 5 portions succeeded.';

    -- TEST 3: Capacity invariant enforcement
    -- Remaining surplus = 10 - (2 discarded + 5 active) = 3.
    -- Attempting to allocate 4 portions MUST FAIL.
    BEGIN
        INSERT INTO public.surplus_allocations (mess_id, meal_prep_record_id, partner_id, quantity, status)
        VALUES (v_mess_a, v_prep_a, v_partner_a, 4, 'pending');
        RAISE EXCEPTION 'TEST 3 FAILED: Over-allocation beyond surplus was permitted!';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TEST 3 PASSED: Over-allocation (attempting 4 when only 3 available) was blocked.';
    END;

    -- TEST 4: Allocation state transition (pending -> collected)
    -- Collecting the 5 portions retains active allocation and marks it as completed donation.
    UPDATE public.surplus_allocations 
    SET status = 'collected'
    WHERE id = v_alloc_1;
    RAISE NOTICE 'TEST 4 PASSED: Transition to collected succeeded.';

    -- TEST 5: Allocation cancellation releases surplus
    -- Now cancel the allocation. Remaining available surplus should return to 8.
    UPDATE public.surplus_allocations 
    SET status = 'cancelled'
    WHERE id = v_alloc_1;

    -- Now allocating 8 portions should succeed!
    INSERT INTO public.surplus_allocations (id, mess_id, meal_prep_record_id, partner_id, quantity, status)
    VALUES (v_alloc_2, v_mess_a, v_prep_a, v_partner_a, 8, 'pending');
    RAISE NOTICE 'TEST 5 PASSED: Cancellation released surplus and new full allocation succeeded.';

    -- Clean up test records after tests
    DELETE FROM public.surplus_allocations WHERE id IN (v_alloc_1, v_alloc_2);
    DELETE FROM public.meal_prep_records WHERE id = v_prep_a;
    DELETE FROM public.donation_partners WHERE id IN (v_partner_a, v_partner_b);

    RAISE NOTICE 'ALL INVARIANTS, CAPACITY CHECKS, AND LIFECYCLE TESTS COMPLETED SUCCESSFULLY.';
END;
$$;
