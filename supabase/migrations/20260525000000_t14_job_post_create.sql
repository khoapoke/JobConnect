-- T-14: Job Post Create
-- Concern 1: Salary becomes mandatory data (ADR-0003)
-- Concern 2: Atomic multi-table write via RPC (ADR-0004)

-- Concern 1: Salary columns become NOT NULL with visibility flag
ALTER TABLE job_posts ALTER COLUMN salary_min SET NOT NULL;
ALTER TABLE job_posts ALTER COLUMN salary_max SET NOT NULL;
ALTER TABLE job_posts ADD COLUMN IF NOT EXISTS is_salary_visible BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE job_posts ADD CONSTRAINT salary_range_valid CHECK (salary_min <= salary_max);
ALTER TABLE job_posts ADD CONSTRAINT salary_non_negative CHECK (salary_min >= 0);

-- Concern 2: RPC function for atomic job post creation across 3 tables
CREATE OR REPLACE FUNCTION create_job_post(
  p_company_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_requirements TEXT,
  p_salary_min INTEGER,
  p_salary_max INTEGER,
  p_is_salary_visible BOOLEAN,
  p_type TEXT,
  p_category_id UUID,
  p_expires_at TIMESTAMPTZ,
  p_province TEXT,
  p_district TEXT,
  p_address TEXT,
  p_is_remote BOOLEAN,
  p_skill_ids UUID[]
) RETURNS UUID LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE
  v_job_id UUID;
BEGIN
  -- Authorization check: caller must own the company
  IF NOT EXISTS (
    SELECT 1 FROM companies
    WHERE id = p_company_id AND recruiter_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to post for this company';
  END IF;

  -- Insert job post (always draft status)
  INSERT INTO job_posts (
    company_id, title, description, requirements,
    salary_min, salary_max, is_salary_visible, type,
    category_id, expires_at, status
  ) VALUES (
    p_company_id, p_title, p_description, p_requirements,
    p_salary_min, p_salary_max, p_is_salary_visible, p_type,
    p_category_id, p_expires_at, 'draft'
  ) RETURNING id INTO v_job_id;

  -- Insert job location
  INSERT INTO job_locations (
    job_id, province, district, address, is_remote
  ) VALUES (
    v_job_id, p_province, p_district, p_address, p_is_remote
  );

  -- Insert required skills (if any)
  IF array_length(p_skill_ids, 1) > 0 THEN
    INSERT INTO job_required_skills (job_id, skill_id, is_required)
    SELECT v_job_id, unnest(p_skill_ids), true;
  END IF;

  RETURN v_job_id;
END;
$$;
