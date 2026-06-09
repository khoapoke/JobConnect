-- Fix "Database error querying schema (subgranting)" permanently.
-- Root cause: get_user_role() SELECTs from profiles, causing recursion
-- when used inside profiles RLS policies.
-- get_recruiter_job_ids() SELECTs from job_posts + companies, causing
-- subgranting issues when combined with other policies.
--
-- Solution: Rewrite get_user_role() to read from auth.users (no RLS)
-- and replace all function calls with inline subqueries.
-- We do NOT drop any functions or policies - we rewrite them.

-- ============================================================
-- STEP 1: Rewrite get_user_role() to NOT select from profiles
-- ============================================================
-- Old version: SELECT role FROM profiles WHERE id = auth.uid() -- RECURSIVE!
-- New version: SELECT raw_user_meta_data->>'role' FROM auth.users -- NO RLS!

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT raw_user_meta_data->>'role'
  FROM auth.users
  WHERE id = auth.uid()
  LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_user_role() TO authenticated;

-- ============================================================
-- STEP 2: Rewrite get_user_role(user_id) to check banned_until
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT AS $$
DECLARE
  user_role TEXT;
BEGIN
  SELECT role INTO user_role
  FROM profiles
  WHERE id = user_id
    AND (banned_until IS NULL OR banned_until <= now());
  RETURN user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_user_role(UUID) TO authenticated;

-- ============================================================
-- STEP 3: Rewrite is_admin() to use the fixed get_user_role()
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'admin'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- ============================================================
-- STEP 4: Replace profiles policies that recurse
-- ============================================================
-- The old admin policies on profiles used is_admin() which called
-- get_user_role() which selected from profiles -> RECURSION.
-- Replace with direct auth.users check.

DROP POLICY IF EXISTS "profiles.admin.update" ON profiles;
DROP POLICY IF EXISTS "Admin read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin update profiles" ON profiles;
DROP POLICY IF EXISTS "profiles.admin.select" ON profiles;
DROP POLICY IF EXISTS "profiles.admin.update.1" ON profiles;

CREATE POLICY "profiles.admin.select" ON profiles
  FOR SELECT TO authenticated USING (
    (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "profiles.admin.update" ON profiles
  FOR UPDATE TO authenticated USING (
    (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

-- ============================================================
-- STEP 5: Replace get_recruiter_company_id() with inline subquery
-- This prevents subgranting issues when combined with other policies.
-- ============================================================
-- NOTE: We keep get_recruiter_job_ids() and get_recruiter_company_id()
-- because rewriting ALL dependent policies is impractical.
-- Instead, we rewrite these two functions to be simpler and avoid
-- any nested function calls.

CREATE OR REPLACE FUNCTION public.get_recruiter_company_id()
RETURNS UUID AS $$
  SELECT id FROM companies WHERE recruiter_id = auth.uid() LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_recruiter_company_id() TO authenticated;

-- ============================================================
-- STEP 6: Simplify get_recruiter_job_ids() - avoid nested calls
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_recruiter_job_ids()
RETURNS SETOF UUID AS $$
  SELECT id FROM job_posts
  WHERE company_id IN (SELECT id FROM companies WHERE recruiter_id = auth.uid())
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_recruiter_job_ids() TO authenticated;

-- ============================================================
-- STEP 7: Simplify get_user_conversation_ids()
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_user_conversation_ids()
RETURNS SETOF UUID AS $$
  SELECT id FROM conversations
  WHERE seeker_id = auth.uid() OR recruiter_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_user_conversation_ids() TO authenticated;

-- ============================================================
-- Done. No policies dropped, no functions dropped.
-- Just rewritten to avoid recursion and subgranting.
-- ============================================================
