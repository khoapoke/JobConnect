-- Fix recursive RLS policies on profiles
-- The previous migration used EXISTS(SELECT 1 FROM profiles ...) inside profiles policies,
-- which causes RLS recursion / query failure in PostgreSQL.
-- Replace with get_user_role() which is SECURITY DEFINER (bypasses RLS).

DROP POLICY IF EXISTS "Admin read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin update profiles" ON profiles;

CREATE POLICY "Admin read all profiles" ON profiles
  FOR SELECT USING (get_user_role(auth.uid()) = 'admin');

CREATE POLICY "Admin update profiles" ON profiles
  FOR UPDATE USING (get_user_role(auth.uid()) = 'admin');
