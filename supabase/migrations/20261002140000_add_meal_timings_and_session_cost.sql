-- Migration: 20261002140000_add_meal_timings_and_session_cost.sql
-- Description: Adds meal_timings JSONB to messes table and cost_per_meal override to meal_prep_records.

-- 1. Add meal_timings to messes table
ALTER TABLE IF EXISTS public.messes 
ADD COLUMN IF NOT EXISTS meal_timings JSONB DEFAULT '{
  "breakfast": {"start": "06:45", "end": "09:00", "cutoff": "05:00"},
  "lunch": {"start": "12:30", "end": "14:30", "cutoff": "10:00"},
  "dinner": {"start": "19:00", "end": "20:30", "cutoff": "16:00"}
}'::jsonb;

-- 2. Add per-session cost_per_meal override to meal_prep_records (Option 2)
ALTER TABLE IF EXISTS public.meal_prep_records
ADD COLUMN IF NOT EXISTS cost_per_meal INT CHECK (cost_per_meal IS NULL OR cost_per_meal > 0);
