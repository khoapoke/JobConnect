CREATE POLICY "notifications.recruiter.insert"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'recruiter');

CREATE POLICY "notifications.admin.insert"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());
