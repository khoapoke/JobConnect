-- General role change RPC for admin use
-- Updates both profiles.role and auth.users.raw_user_meta_data

CREATE OR REPLACE FUNCTION change_user_role(target_user_id UUID, new_role TEXT)
RETURNS void AS $$
BEGIN
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
