-- T-15: Job Post Edit + Status Transitions
-- Concern 1: Atomic multi-table update via RPC (ADR-0004)
-- Concern 2: Status transitions (auto-publish, skip pending_review)

-- Concern 1: RPC function for atomic job post update across 3 tables
CREATE OR REPLACE FUNCTION update_job_post(
  p_job_id UUID,
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
) RETURNS VOID LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE
  v_company_id UUID;
BEGIN
  -- Authorization check: caller must own the company that owns this job post
  SELECT company_id INTO v_company_id
  FROM job_posts
  WHERE id = p_job_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Job post not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM companies
    WHERE id = v_company_id AND recruiter_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to edit this job post';
  END IF;

  -- Check if job post is editable (not closed)
  IF EXISTS (
    SELECT 1 FROM job_posts
    WHERE id = p_job_id AND status = 'closed'
  ) THEN
    RAISE EXCEPTION 'Cannot edit a closed job post';
  END IF;

  -- Update job post
  UPDATE job_posts SET
    title = p_title,
    description = p_description,
    requirements = p_requirements,
    salary_min = p_salary_min,
    salary_max = p_salary_max,
    is_salary_visible = p_is_salary_visible,
    type = p_type,
    category_id = p_category_id,
    expires_at = p_expires_at,
    updated_at = now()
  WHERE id = p_job_id;

  -- Update job location (delete and re-insert for simplicity)
  DELETE FROM job_locations WHERE job_id = p_job_id;
  INSERT INTO job_locations (
    job_id, province, district, address, is_remote
  ) VALUES (
    p_job_id, p_province, p_district, p_address, p_is_remote
  );

  -- Update required skills (delete and re-insert)
  DELETE FROM job_required_skills WHERE job_id = p_job_id;
  IF array_length(p_skill_ids, 1) > 0 THEN
    INSERT INTO job_required_skills (job_id, skill_id, is_required)
    SELECT p_job_id, unnest(p_skill_ids), true;
  END IF;
END;
$$;

-- Concern 2: RPC function for status transitions
CREATE OR REPLACE FUNCTION update_job_post_status(
  p_job_id UUID,
  p_new_status TEXT
) RETURNS VOID LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE
  v_company_id UUID;
  v_current_status TEXT;
BEGIN
  -- Authorization check: caller must own the company that owns this job post
  SELECT company_id, status INTO v_company_id, v_current_status
  FROM job_posts
  WHERE id = p_job_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Job post not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM companies
    WHERE id = v_company_id AND recruiter_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not authorized to update this job post';
  END IF;

  -- Validate status transition
  -- Allowed transitions:
  -- draft -> active (publish)
  -- draft -> closed (discard)
  -- active -> closed (close)
  -- rejected -> draft (pull back to edit)
  -- rejected -> active (resubmit)
  IF NOT (
    (v_current_status = 'draft' AND p_new_status IN ('active', 'closed')) OR
    (v_current_status = 'active' AND p_new_status = 'closed') OR
    (v_current_status = 'rejected' AND p_new_status IN ('draft', 'active'))
  ) THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', v_current_status, p_new_status;
  END IF;

  -- For publishing (draft/rejected -> active), validate required fields
  IF p_new_status = 'active' THEN
    IF EXISTS (
      SELECT 1 FROM job_posts
      WHERE id = p_job_id AND (
        description IS NULL OR description = '' OR
        requirements IS NULL OR requirements = '' OR
        category_id IS NULL OR
        expires_at IS NULL
      )
    ) THEN
      RAISE EXCEPTION 'Cannot publish: missing required fields (description, requirements, category, or expiry date)';
    END IF;

    -- Check if expiry date is in the future
    IF EXISTS (
      SELECT 1 FROM job_posts
      WHERE id = p_job_id AND expires_at < now()
    ) THEN
      RAISE EXCEPTION 'Cannot publish: expiry date must be in the future';
    END IF;
  END IF;

  -- Update status
  UPDATE job_posts SET
    status = p_new_status,
    updated_at = now()
  WHERE id = p_job_id;
END;
$$;
