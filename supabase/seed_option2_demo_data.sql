-- ============================================================================
-- Seed Script: seed_option2_demo_data.sql
-- Purpose: Seeds 2-3 days of realistic kitchen portions, session costs,
--          surplus allocations, and member skips to test Option 2 & Analytics.
--
-- Instructions:
--   1. Open the Supabase Dashboard -> SQL Editor.
--   2. Paste and run this script.
--   3. It automatically detects your active mess and populates data for
--      Day 1 (2 days ago), Day 2 (yesterday), and today's breakfast,
--      leaving today's lunch & dinner open for interactive manual UI testing.
-- ============================================================================

DO $$
DECLARE
    v_mess_id UUID;
    v_mess_name TEXT;
    v_partner_akshaya UUID;
    v_partner_robin UUID;
    v_prep_d1_bf UUID;
    v_prep_d1_lu UUID;
    v_prep_d1_di UUID;
    v_prep_d2_bf UUID;
    v_prep_d2_lu UUID;
    v_prep_d2_di UUID;
    v_prep_d3_bf UUID;
    v_member_rec RECORD;
    v_member_count INT := 0;
    v_date_d1 DATE := CURRENT_DATE - INTERVAL '2 days';
    v_date_d2 DATE := CURRENT_DATE - INTERVAL '1 day';
    v_date_d3 DATE := CURRENT_DATE;
BEGIN
    -- 1. Identify the target mess (latest active mess in database)
    SELECT id, mess_name INTO v_mess_id, v_mess_name 
    FROM public.messes 
    ORDER BY created_at DESC 
    LIMIT 1;

    IF v_mess_id IS NULL THEN
        RAISE EXCEPTION 'No mess found. Please create a mess in Mealmate first before running this seed script.';
    END IF;

    RAISE NOTICE '==> Seeding Demo Data for Mess: "%" (ID: %)', v_mess_name, v_mess_id;

    -- Ensure baseline settings are active
    UPDATE public.messes 
    SET cost_per_meal = COALESCE(cost_per_meal, 50),
        meal_timings = COALESCE(meal_timings, '{
            "breakfast": {"start": "06:45", "end": "09:00", "cutoff": "05:00"},
            "lunch": {"start": "12:30", "end": "14:30", "cutoff": "10:00"},
            "dinner": {"start": "19:00", "end": "20:30", "cutoff": "16:00"}
        }'::jsonb)
    WHERE id = v_mess_id;

    -- 2. Cleanup previous seed records in this 3-day test window to maintain idempotence
    DELETE FROM public.surplus_allocations 
    WHERE mess_id = v_mess_id 
      AND created_at >= (v_date_d1::timestamptz);

    DELETE FROM public.meal_prep_records 
    WHERE mess_id = v_mess_id 
      AND prep_date >= v_date_d1;

    DELETE FROM public.skips 
    WHERE mess_id = v_mess_id 
      AND skip_date >= v_date_d1;

    -- 3. Upsert Verified NGO Partners
    SELECT id INTO v_partner_akshaya 
    FROM public.donation_partners 
    WHERE mess_id = v_mess_id AND name = 'Akshaya Patra Foundation'
    LIMIT 1;

    IF v_partner_akshaya IS NULL THEN
        INSERT INTO public.donation_partners (
            mess_id, name, contact_phone, contact_person, address, notes, is_active
        ) VALUES (
            v_mess_id,
            'Akshaya Patra Foundation',
            '+91 98765 43210',
            'Sunil Verma (Food Relief)',
            'Sector 14 Distribution Hub',
            'Accepts hot cooked food within 3 hours of preparation',
            true
        ) RETURNING id INTO v_partner_akshaya;
    ELSE
        UPDATE public.donation_partners SET is_active = true WHERE id = v_partner_akshaya;
    END IF;

    SELECT id INTO v_partner_robin 
    FROM public.donation_partners 
    WHERE mess_id = v_mess_id AND name = 'Robin Hood Army - Campus Chapter'
    LIMIT 1;

    IF v_partner_robin IS NULL THEN
        INSERT INTO public.donation_partners (
            mess_id, name, contact_phone, contact_person, address, notes, is_active
        ) VALUES (
            v_mess_id,
            'Robin Hood Army - Campus Chapter',
            '+91 91234 56789',
            'Priya Sharma (Volunteer Lead)',
            'Hostel Gate 2 Collection Point',
            'Student volunteers distributing dinner surplus to night shelters',
            true
        ) RETURNING id INTO v_partner_robin;
    ELSE
        UPDATE public.donation_partners SET is_active = true WHERE id = v_partner_robin;
    END IF;

    -- 4. Insert 2-3 Days of Meal Prep Records with Option 2 Per-Session Costs

    -- === DAY 1 (2 Days Ago) ===
    -- Breakfast: ₹40/plate, 100 prepared, 95 served, 0 discarded => Surplus = 5
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d1, 'breakfast', 105, 100, 95, 0, 40
    ) RETURNING id INTO v_prep_d1_bf;

    -- Lunch: ₹55/plate, 120 prepared, 110 served, 2 discarded => Surplus = 10
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d1, 'lunch', 125, 120, 110, 2, 55
    ) RETURNING id INTO v_prep_d1_lu;

    -- Dinner: ₹85/plate (Special Festive Meal), 140 prepared, 125 served, 5 discarded => Surplus = 15
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d1, 'dinner', 145, 140, 125, 5, 85
    ) RETURNING id INTO v_prep_d1_di;

    -- === DAY 2 (Yesterday) ===
    -- Breakfast: ₹45/plate, 100 prepared, 92 served, 0 discarded => Surplus = 8
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d2, 'breakfast', 100, 100, 92, 0, 45
    ) RETURNING id INTO v_prep_d2_bf;

    -- Lunch: ₹50/plate, 120 prepared, 105 served, 3 discarded => Surplus = 15
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d2, 'lunch', 120, 120, 105, 3, 50
    ) RETURNING id INTO v_prep_d2_lu;

    -- Dinner: ₹70/plate, 130 prepared, 116 served, 4 discarded => Surplus = 14
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d2, 'dinner', 135, 130, 116, 4, 70
    ) RETURNING id INTO v_prep_d2_di;

    -- === DAY 3 (Today) ===
    -- Breakfast: ₹45/plate, 100 prepared, 94 served, 1 discarded => Surplus = 5
    INSERT INTO public.meal_prep_records (
        mess_id, prep_date, meal_type, target_portions, prepared_portions, served_portions, discarded_portions, cost_per_meal
    ) VALUES (
        v_mess_id, v_date_d3, 'breakfast', 102, 100, 94, 1, 45
    ) RETURNING id INTO v_prep_d3_bf;

    -- Note: Today's Lunch and Dinner are deliberately omitted so you can test logging them live!

    -- 5. Insert Surplus Allocations (Completed Donations)
    -- Day 1 Lunch: Allocate 8 portions to Akshaya Patra (Collected)
    INSERT INTO public.surplus_allocations (
        mess_id, meal_prep_record_id, partner_id, quantity, status, notes, created_at
    ) VALUES (
        v_mess_id, v_prep_d1_lu, v_partner_akshaya, 8, 'collected', 'Picked up by vehicle DL-01-4432', v_date_d1::timestamptz + INTERVAL '15 hours'
    );

    -- Day 1 Dinner: Allocate 10 portions to Robin Hood Army (Collected)
    INSERT INTO public.surplus_allocations (
        mess_id, meal_prep_record_id, partner_id, quantity, status, notes, created_at
    ) VALUES (
        v_mess_id, v_prep_d1_di, v_partner_robin, 10, 'collected', 'Night shelter distribution drive', v_date_d1::timestamptz + INTERVAL '21 hours'
    );

    -- Day 2 Breakfast: Allocate 8 portions to Robin Hood Army (Collected)
    INSERT INTO public.surplus_allocations (
        mess_id, meal_prep_record_id, partner_id, quantity, status, notes, created_at
    ) VALUES (
        v_mess_id, v_prep_d2_bf, v_partner_robin, 8, 'collected', 'Morning community center meal', v_date_d2::timestamptz + INTERVAL '10 hours'
    );

    -- Day 2 Lunch: Allocate 10 portions to Akshaya Patra (Collected)
    INSERT INTO public.surplus_allocations (
        mess_id, meal_prep_record_id, partner_id, quantity, status, notes, created_at
    ) VALUES (
        v_mess_id, v_prep_d2_lu, v_partner_akshaya, 10, 'collected', 'Regular afternoon pickup', v_date_d2::timestamptz + INTERVAL '15 hours'
    );

    -- Day 2 Dinner: Allocate 8 portions to Robin Hood Army (Collected)
    INSERT INTO public.surplus_allocations (
        mess_id, meal_prep_record_id, partner_id, quantity, status, notes, created_at
    ) VALUES (
        v_mess_id, v_prep_d2_di, v_partner_robin, 8, 'collected', 'Hostel surplus delivery', v_date_d2::timestamptz + INTERVAL '21 hours'
    );

    -- 6. Insert Member Skips across the 3 days to drive "Cost Saved" ROI metrics
    FOR v_member_rec IN (
        SELECT id FROM public.profiles WHERE mess_id = v_mess_id OR id IS NOT NULL LIMIT 10
    ) LOOP
        v_member_count := v_member_count + 1;

        -- Day 1 Skips
        INSERT INTO public.skips (mess_id, member_id, skip_date, meal_type)
        VALUES 
            (v_mess_id, v_member_rec.id, v_date_d1, 'breakfast'),
            (v_mess_id, v_member_rec.id, v_date_d1, 'dinner')
        ON CONFLICT DO NOTHING;

        -- Day 2 Skips
        INSERT INTO public.skips (mess_id, member_id, skip_date, meal_type)
        VALUES 
            (v_mess_id, v_member_rec.id, v_date_d2, 'lunch'),
            (v_mess_id, v_member_rec.id, v_date_d2, 'dinner')
        ON CONFLICT DO NOTHING;

        -- Day 3 (Today) Skips
        INSERT INTO public.skips (mess_id, member_id, skip_date, meal_type)
        VALUES 
            (v_mess_id, v_member_rec.id, v_date_d3, 'dinner')
        ON CONFLICT DO NOTHING;
    END LOOP;

    RAISE NOTICE '==> Seed Completed Successfully!';
    RAISE NOTICE '    - Mess: %', v_mess_name;
    RAISE NOTICE '    - Day 1: Breakfast (₹40), Lunch (₹55), Dinner (₹85)';
    RAISE NOTICE '    - Day 2: Breakfast (₹45), Lunch (₹50), Dinner (₹70)';
    RAISE NOTICE '    - Day 3: Breakfast (₹45) [Lunch & Dinner ready for live test]';
    RAISE NOTICE '    - Active NGO Partners: Akshaya Patra & Robin Hood Army';
    RAISE NOTICE '    - Skips linked for % member profiles.', v_member_count;
END $$;

