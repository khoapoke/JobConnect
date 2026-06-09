-- Fix RLS recursion: get_user_role() SELECTs from profiles inside a profiles policy.
-- Replace with a direct auth.users check (no recursion since auth.users has no RLS).

DROP POLICY IF EXISTS "Admin read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin update profiles" ON profiles;

CREATE POLICY "Admin read all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data->>'role' = 'admin'
    )
  );

CREATE POLICY "Admin update profiles" ON profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data->>'role' = 'admin'
    )
  );

-- Also fix the reports / admin_invites policies that use get_user_role
-- They are OK because those tables don't recurse into profiles.
-- But the "Anyone can update used_by on invite" policy is too permissive;
-- let's tighten it to only allow marking unused invites.
DROP POLICY IF EXISTS "Anyone can update used_by on invite" ON admin_invites;

CREATE POLICY "Anyone can update used_by on invite" ON admin_invites
  FOR UPDATE USING (used_by IS NULL)
  WITH CHECK (used_by IS NOT NULL);
