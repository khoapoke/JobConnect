-- Drop the enforce_role_immutable trigger to allow admin promotion via RPC
-- The trigger was blocking ALL role changes including admin-to-user promotions.
-- RLS policies are sufficient protection now.

DROP TRIGGER IF EXISTS enforce_role_immutable ON profiles;
