-- Security fix: promote_to_admin() and change_user_role() are SECURITY DEFINER
-- and were callable by ANY authenticated user — a seeker could promote themselves
-- to admin via supabase.rpc(). Add an is_admin() guard inside both functions.

CREATE OR REPLACE FUNCTION promote_to_admin(target_user_id UUID)
RETURNS void AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Chỉ Admin mới được thay đổi vai trò người dùng';
  END IF;

  UPDATE profiles SET role = 'admin' WHERE id = target_user_id;

  UPDATE auth.users
  SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role": "admin"}'::jsonb
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION change_user_role(target_user_id UUID, new_role TEXT)
RETURNS void AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Chỉ Admin mới được thay đổi vai trò người dùng';
  END IF;

  IF new_role NOT IN ('seeker', 'recruiter', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;

  UPDATE profiles SET role = new_role WHERE id = target_user_id;

  UPDATE auth.users
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    to_jsonb(new_role)
  )
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
