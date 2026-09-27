-- Migration: 20260927120000_surplus_prep_waste_phase1.sql
-- Description: Phase 1 schema for Meal Preparation Logging, Surplus Tracking, and Donation Allocations.
-- Invariants enforced:
--   1. Target portions (planner) kept strictly separate from prepared portions (kitchen).
--   2. Surplus portions = prepared_portions - served_portions (prepared >= served).
--   3. Active allocations (pending + collected) + discarded_portions <= surplus_portions (enforced with FOR UPDATE row locks).
--   4. Partner must belong to the exact same mess (enforced via composite FK and trigger).
--   5. Only authenticated mess owner can read/write data for their mess.

-- ============================================================================
-- 1. Helper function for updated_at timestamps
-- ============================================================================
CREATE OR REPLACE FUNCTION set_updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. Table: meal_prep_records
-- Records target, actual cooked (prepared), actual served, and discarded portions.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.meal_prep_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mess_id UUID NOT NULL REFERENCES public.messes(id) ON DELETE CASCADE,
    prep_date DATE NOT NULL,
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner')),
    target_portions INT NOT NULL DEFAULT 0 CHECK (target_portions >= 0),
    prepared_portions INT NOT NULL DEFAULT 0 CHECK (prepared_portions >= 0),
    served_portions INT NOT NULL DEFAULT 0 CHECK (served_portions >= 0),
    discarded_portions INT NOT NULL DEFAULT 0 CHECK (discarded_portions >= 0),
    surplus_portions INT GENERATED ALWAYS AS (prepared_portions - served_portions) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    CONSTRAINT uq_meal_prep_mess_date_meal UNIQUE (mess_id, prep_date, meal_type),
    CONSTRAINT uq_meal_prep_id_mess UNIQUE (id, mess_id),
    CONSTRAINT chk_meal_prep_prepared_gte_served CHECK (prepared_portions >= served_portions)
);

CREATE INDEX IF NOT EXISTS idx_meal_prep_mess_date 
ON public.meal_prep_records (mess_id, prep_date);

CREATE TRIGGER trg_meal_prep_records_updated_at
BEFORE UPDATE ON public.meal_prep_records
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();

-- ============================================================================
-- 3. Table: donation_partners
-- Real verified local food banks / volunteers belonging to a specific mess.
-- NO sample partners or guessed mock data.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.donation_partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mess_id UUID NOT NULL REFERENCES public.messes(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    contact_phone TEXT,
    contact_person TEXT,
    address TEXT,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_donation_partner_id_mess UNIQUE (id, mess_id)
);

CREATE INDEX IF NOT EXISTS idx_donation_partners_mess_active 
ON public.donation_partners (mess_id, is_active);

CREATE TRIGGER trg_donation_partners_updated_at
BEFORE UPDATE ON public.donation_partners
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();

-- ============================================================================
-- 4. Table: surplus_allocations
-- Tracks allocations of surplus food to partners with quantity and lifecycle states.
-- States: 'pending' (reserved), 'collected' (completed donation), 'cancelled'.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.surplus_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mess_id UUID NOT NULL REFERENCES public.messes(id) ON DELETE CASCADE,
    meal_prep_record_id UUID NOT NULL,
    partner_id UUID,
    quantity INT NOT NULL CHECK (quantity > 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'collected', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Composite foreign keys guarantee same-mess relational integrity
    CONSTRAINT fk_surplus_allocations_meal_prep 
        FOREIGN KEY (meal_prep_record_id, mess_id) 
        REFERENCES public.meal_prep_records(id, mess_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_surplus_allocations_partner 
        FOREIGN KEY (partner_id, mess_id) 
        REFERENCES public.donation_partners(id, mess_id) 
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_surplus_allocations_prep_status 
ON public.surplus_allocations (meal_prep_record_id, status);

CREATE INDEX IF NOT EXISTS idx_surplus_allocations_mess_status 
ON public.surplus_allocations (mess_id, status);

CREATE TRIGGER trg_surplus_allocations_updated_at
BEFORE UPDATE ON public.surplus_allocations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();

-- ============================================================================
-- 5. Concurrency-Safe Invariant Enforcement Triggers
-- Enforces: Active Allocations + Discarded Portions <= Surplus
-- Serializes concurrent allocation requests with row-level locking (FOR UPDATE).
-- ============================================================================
CREATE OR REPLACE FUNCTION check_surplus_allocation_capacity()
RETURNS TRIGGER AS $$
DECLARE
    v_prepared INT;
    v_served INT;
    v_discarded INT;
    v_surplus INT;
    v_other_active_allocated INT;
    v_total_active INT;
BEGIN
    -- ROW-LEVEL LOCK: Acquire exclusive row lock on the parent meal_prep_record.
    -- Any concurrent transaction allocating or modifying this meal's surplus will wait here.
    SELECT prepared_portions, served_portions, discarded_portions
    INTO v_prepared, v_served, v_discarded
    FROM public.meal_prep_records
    WHERE id = NEW.meal_prep_record_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meal prep record % does not exist', NEW.meal_prep_record_id;
    END IF;

    -- Verify active partner if partner_id is provided
    IF NEW.partner_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.donation_partners
            WHERE id = NEW.partner_id 
              AND mess_id = NEW.mess_id 
              AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Selected donation partner % is either inactive or does not belong to mess %', 
                NEW.partner_id, NEW.mess_id;
        END IF;
    END IF;

    v_surplus := v_prepared - v_served;

    -- Calculate all other active allocations (pending or collected) excluding current row
    SELECT COALESCE(SUM(quantity), 0)
    INTO v_other_active_allocated
    FROM public.surplus_allocations
    WHERE meal_prep_record_id = NEW.meal_prep_record_id
      AND status IN ('pending', 'collected')
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid);

    -- Calculate total active if NEW row is active
    IF NEW.status IN ('pending', 'collected') THEN
        v_total_active := v_other_active_allocated + NEW.quantity;
    ELSE
        v_total_active := v_other_active_allocated;
    END IF;

    -- Invariant check
    IF (v_total_active + v_discarded) > v_surplus THEN
        RAISE EXCEPTION 'Allocation exceeds available surplus. Total Surplus: %, Active Allocations: %, Discarded: %, Attempted: %',
            v_surplus, v_other_active_allocated, v_discarded, (CASE WHEN NEW.status IN ('pending', 'collected') THEN NEW.quantity ELSE 0 END);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_surplus_allocation_capacity
BEFORE INSERT OR UPDATE ON public.surplus_allocations
FOR EACH ROW
EXECUTE FUNCTION check_surplus_allocation_capacity();

-- Trigger on meal_prep_records to prevent adjusting prepared/served/discarded
-- in a way that violates existing active allocations.
CREATE OR REPLACE FUNCTION check_meal_prep_record_limits()
RETURNS TRIGGER AS $$
DECLARE
    v_surplus INT;
    v_active_allocated INT;
BEGIN
    v_surplus := NEW.prepared_portions - NEW.served_portions;

    SELECT COALESCE(SUM(quantity), 0)
    INTO v_active_allocated
    FROM public.surplus_allocations
    WHERE meal_prep_record_id = NEW.id
      AND status IN ('pending', 'collected');

    IF (v_active_allocated + NEW.discarded_portions) > v_surplus THEN
        RAISE EXCEPTION 'Existing active allocations (%) plus discarded portions (%) would exceed new surplus (%)',
            v_active_allocated, NEW.discarded_portions, v_surplus;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_meal_prep_record_limits
BEFORE UPDATE OF prepared_portions, served_portions, discarded_portions ON public.meal_prep_records
FOR EACH ROW
EXECUTE FUNCTION check_meal_prep_record_limits();

-- ============================================================================
-- 6. Row Level Security (RLS) Policies
-- Strict access control: Only the authenticated owner of the matching mess row
-- can read, insert, update, or delete records.
-- ============================================================================

-- A. meal_prep_records RLS
ALTER TABLE public.meal_prep_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "meal_prep_owner_select"
ON public.meal_prep_records FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = meal_prep_records.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "meal_prep_owner_insert"
ON public.meal_prep_records FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = meal_prep_records.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "meal_prep_owner_update"
ON public.meal_prep_records FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = meal_prep_records.mess_id
          AND messes.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = meal_prep_records.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "meal_prep_owner_delete"
ON public.meal_prep_records FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = meal_prep_records.mess_id
          AND messes.owner_id = auth.uid()
    )
);

-- B. donation_partners RLS
ALTER TABLE public.donation_partners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "donation_partners_owner_select"
ON public.donation_partners FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = donation_partners.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "donation_partners_owner_insert"
ON public.donation_partners FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = donation_partners.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "donation_partners_owner_update"
ON public.donation_partners FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = donation_partners.mess_id
          AND messes.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = donation_partners.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "donation_partners_owner_delete"
ON public.donation_partners FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = donation_partners.mess_id
          AND messes.owner_id = auth.uid()
    )
);

-- C. surplus_allocations RLS
ALTER TABLE public.surplus_allocations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "surplus_allocations_owner_select"
ON public.surplus_allocations FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = surplus_allocations.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "surplus_allocations_owner_insert"
ON public.surplus_allocations FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = surplus_allocations.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "surplus_allocations_owner_update"
ON public.surplus_allocations FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = surplus_allocations.mess_id
          AND messes.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = surplus_allocations.mess_id
          AND messes.owner_id = auth.uid()
    )
);

CREATE POLICY "surplus_allocations_owner_delete"
ON public.surplus_allocations FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messes
        WHERE messes.id = surplus_allocations.mess_id
          AND messes.owner_id = auth.uid()
    )
);
