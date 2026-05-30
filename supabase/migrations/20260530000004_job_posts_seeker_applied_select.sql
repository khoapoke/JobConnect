-- Allow seekers to read job_posts they've applied to,
-- regardless of status (e.g., closed). Prevents applications
-- from disappearing on My Applications page when recruiter closes a job.

CREATE POLICY "job_posts.seeker.applied.select" ON job_posts
  FOR SELECT TO authenticated
  USING (
    get_user_role() = 'seeker'
    AND EXISTS (
      SELECT 1 FROM applications
      WHERE applications.job_id = job_posts.id
        AND applications.seeker_id = auth.uid()
    )
  );
