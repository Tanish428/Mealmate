-- Migration: 20261002120000_add_cost_per_meal_and_analytics_indices.sql
-- Description: Adds cost_per_meal configuration to messes table and indices for high-performance analytics queries.

-- 1. Add cost_per_meal column to messes table (default 50 INR per meal)
ALTER TABLE IF EXISTS public.messes 
ADD COLUMN IF NOT EXISTS cost_per_meal INT NOT NULL DEFAULT 50 CHECK (cost_per_meal > 0);

-- 2. Performance index on skips table for quick aggregation of ghost meals prevented by timeframe
CREATE INDEX IF NOT EXISTS idx_skips_mess_date 
ON public.skips (mess_id, skip_date);

-- 3. Composite index on meal_prep_records for date-range aggregations
CREATE INDEX IF NOT EXISTS idx_meal_prep_mess_date_portions 
ON public.meal_prep_records (mess_id, prep_date, prepared_portions, served_portions, discarded_portions);
