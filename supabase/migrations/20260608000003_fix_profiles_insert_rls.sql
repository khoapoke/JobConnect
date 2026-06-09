-- Fix: The "new row violates RLS policy for table profiles" error on login.
-- This happens because handle_new_user() trigger INSERTs profiles during auth.users INSERT.
-- If a seeded user (inserted via SQL, not through Supabase Auth API) tries to login,
-- Supabase Auth may do an internal INSERT/upsert that fires handle_new_user again,
-- causing a duplicate key or RLS violation.
--
-- Fix 1: Make handle_new_user() idempotent — skip if profile already exists.
-- Fix 2: Drop the old admin RLS policies that may conflict.
-- Fix 3: Ensure profiles insert policy is clean.

-- 1. Fix handle_new_user to skip existing profiles (idempotent)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  requested_role TEXT;
BEGIN
  -- Skip if profile already exists (seeded users, re-login, etc.)
  IF EXISTS (SELECT 1 FROM public.profiles WHERE id = NEW.id) THEN
    RETURN NEW;
  END IF;

  requested_role := NEW.raw_user_meta_data->>'role';

  INSERT INTO public.profiles (id, role, full_name, avatar_url, is_onboarding_complete)
  VALUES (
    NEW.id,
    CASE
      WHEN requested_role IN ('seeker', 'recruiter', 'admin')
      THEN requested_role
      ELSE 'seeker'
    END,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      ''
    ),
    NEW.raw_user_meta_data->>'avatar_url',
    CASE
      WHEN requested_role IN ('seeker', 'recruiter', 'admin') THEN true
      ELSE false
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. The profiles.authenticated.select with USING(true) is fine.
-- But we need to make sure there are no conflicting admin policies.
-- Let's list and clean up any duplicate admin policies.

-- Drop any profiles admin policies that might conflict
DROP POLICY IF EXISTS "Admin read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin update profiles" ON profiles;
DROP POLICY IF EXISTS "profiles.admin.update" ON profiles;

-- Re-create clean admin policies using auth.users (no recursion)
CREATE POLICY "profiles.admin.select" ON profiles
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data->>'role' = 'admin'
    )
  );

CREATE POLICY "profiles.admin.update" ON profiles
  FOR UPDATE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
        AND raw_user_meta_data->>'role' = 'admin'
    )
  );

-- 3. Make sure the insert policy allows the trigger to work
-- The trigger runs as SECURITY DEFINER (postgres), which bypasses RLS,
-- so RLS policies don't affect it. But just in case, let's verify.
-- The existing "profiles.owner.insert" with CHECK(id = auth.uid()) is correct.
