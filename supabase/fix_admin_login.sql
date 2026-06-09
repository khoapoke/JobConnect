-- PRAGMATIC FIX: Promote existing user to admin + fix RLS
-- Run this in Supabase Dashboard → SQL Editor

-- 1. Temporarily replace prevent_role_change() with a no-op
--    so we can update role to 'admin' without it blocking us
CREATE OR REPLACE FUNCTION public.prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Remove broken recursive admin policies
DROP POLICY IF EXISTS "profiles.admin.select" ON profiles;
DROP POLICY IF EXISTS "Admin read all profiles" ON profiles;
DROP POLICY IF EXISTS "profiles.admin.select.1" ON profiles;
DROP POLICY IF EXISTS "profiles.admin.update.1" ON profiles;

-- 3. Make profiles readable by all
DROP POLICY IF EXISTS "profiles.select.all" ON profiles;
CREATE POLICY "profiles.select.all" ON profiles
  FOR SELECT TO authenticated USING (true);

-- 4. Promote your user to admin
DO $$
DECLARE
  target_user_id UUID;
BEGIN
  SELECT id INTO target_user_id FROM auth.users WHERE email = 'admin@gmail.com';

  IF target_user_id IS NULL THEN
    RAISE EXCEPTION 'User admin@gmail.com not found in auth.users';
  END IF;

  UPDATE profiles
  SET role = 'admin', is_onboarding_complete = true
  WHERE id = target_user_id;

  UPDATE auth.users
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'),
    '{role}',
    '"admin"'
  )
  WHERE id = target_user_id;

  RAISE NOTICE 'Promoted user % to admin', target_user_id;
END $$;

-- 5. Restore the original prevent_role_change() function
CREATE OR REPLACE FUNCTION public.prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Check 1: admin role can NEVER be self-assigned
  IF NEW.role = 'admin' AND OLD.role != 'admin' THEN
    RAISE EXCEPTION 'Cannot self-assign admin role.';
  END IF;

  -- Check 2: role is immutable after onboarding complete
  IF NEW.role <> OLD.role AND OLD.is_onboarding_complete = true THEN
    RAISE EXCEPTION 'Role changes are not permitted. Contact an administrator.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Verify it worked
SELECT
  u.email,
  p.role as profile_role,
  p.is_onboarding_complete,
  u.raw_user_meta_data->>'role' as auth_role
FROM profiles p
JOIN auth.users u ON u.id = p.id
WHERE u.email = 'admin@gmail.com';
