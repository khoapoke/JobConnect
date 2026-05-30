-- Fix notification type in update_application_with_interview RPC.
-- 'interview_schedule' violates check constraint; use allowed value 'interview'.

CREATE OR REPLACE FUNCTION update_application_with_interview(
  p_application_id UUID,
  p_scheduled_at TIMESTAMPTZ,
  p_location TEXT,
  p_note TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_updated_id UUID;
  v_schedule_id UUID;
  v_seeker_id UUID;
  v_job_title TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM applications a
    WHERE a.id = p_application_id
      AND a.job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
  ) THEN
    RAISE EXCEPTION 'Bạn không có quyền cập nhật Application này';
  END IF;

  UPDATE applications
  SET status = 'interview',
      updated_at = now()
  WHERE id = p_application_id
  RETURNING id INTO v_updated_id;

  IF v_updated_id IS NULL THEN
    RAISE EXCEPTION 'Không thể cập nhật trạng thái Application';
  END IF;

  SELECT a.seeker_id, j.title
  INTO v_seeker_id, v_job_title
  FROM applications a
  JOIN job_posts j ON j.id = a.job_id
  WHERE a.id = p_application_id;

  SELECT id
  INTO v_schedule_id
  FROM interview_schedules
  WHERE application_id = p_application_id
  ORDER BY updated_at DESC
  LIMIT 1;

  IF v_schedule_id IS NULL THEN
    INSERT INTO interview_schedules (
      application_id,
      scheduled_at,
      location,
      note,
      status
    )
    VALUES (
      p_application_id,
      p_scheduled_at,
      nullif(btrim(p_location), ''),
      nullif(btrim(p_note), ''),
      'scheduled'
    );
  ELSE
    UPDATE interview_schedules
    SET scheduled_at = p_scheduled_at,
        location = nullif(btrim(p_location), ''),
        note = nullif(btrim(p_note), ''),
        status = 'scheduled',
        updated_at = now()
    WHERE id = v_schedule_id;
  END IF;

  INSERT INTO notifications (user_id, type, title, body, data_json)
  VALUES (
    v_seeker_id,
    'interview',
    'Lịch phỏng vấn mới',
    'Recruiter đã cập nhật lịch phỏng vấn cho "' || v_job_title || '"',
    jsonb_build_object(
      'application_id', p_application_id,
      'scheduled_at', p_scheduled_at,
      'location', nullif(btrim(p_location), '')
    )
  );
END;
$$;
