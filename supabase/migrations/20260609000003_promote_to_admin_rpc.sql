-- RPC: Promote a user to admin role
-- Updates both profiles.role and auth.users.raw_user_meta_data

CREATE OR REPLACE FUNCTION promote_to_admin(target_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Update profiles table
  UPDATE profiles SET role = 'admin' WHERE id = target_user_id;

  -- Update auth.users metadata
  UPDATE auth.users
  SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role": "admin"}'::jsonb
  WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
