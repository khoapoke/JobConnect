CREATE POLICY "private_files_recruiter_resume_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'private-files'
    AND (storage.foldername(name))[1] = 'resumes'
    AND get_user_role() = 'recruiter'
    AND EXISTS (
      SELECT 1
      FROM applications
      WHERE applications.resume_url = name
        AND applications.job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
    )
  );

CREATE POLICY "private_files_admin_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'private-files'
    AND is_admin()
  );
