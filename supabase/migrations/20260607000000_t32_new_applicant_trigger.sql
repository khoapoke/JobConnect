-- T-32: Trigger notification for recruiter when new application is submitted

CREATE OR REPLACE FUNCTION notify_recruiter_on_new_application()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_recruiter_id UUID;
  v_job_title TEXT;
  v_seeker_name TEXT;
BEGIN
  -- Get recruiter_id and job title
  SELECT c.recruiter_id, j.title
  INTO v_recruiter_id, v_job_title
  FROM job_posts j
  JOIN companies c ON c.id = j.company_id
  WHERE j.id = NEW.job_id;

  -- Get seeker name
  SELECT full_name INTO v_seeker_name
  FROM profiles
  WHERE id = NEW.seeker_id;

  -- Insert notification for recruiter
  IF v_recruiter_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, type, title, body, data_json)
    VALUES (
      v_recruiter_id,
      'new_applicant',
      'Ứng viên mới',
      coalesce(v_seeker_name, 'Một ứng viên') || ' đã ứng tuyển vào "' || v_job_title || '".',
      jsonb_build_object('application_id', NEW.id, 'job_id', NEW.job_id)
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_notify_recruiter_on_new_application
  AFTER INSERT ON applications
  FOR EACH ROW
  EXECUTE FUNCTION notify_recruiter_on_new_application();
