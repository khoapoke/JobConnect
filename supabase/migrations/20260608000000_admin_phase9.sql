-- Phase 9: Admin Dashboard, Reports, Ban System, Invite Codes

-- 1. Add banned_until to profiles (replace binary is_banned with time-based)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS banned_until TIMESTAMPTZ;

-- Migrate existing banned users
UPDATE profiles SET banned_until = '2099-12-31T23:59:59Z' WHERE is_banned = true;

-- 2. New table: admin_invites
CREATE TABLE IF NOT EXISTS admin_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  created_by UUID NOT NULL REFERENCES profiles(id),
  used_by UUID REFERENCES profiles(id),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Unique constraint on reports (prevent duplicate reports)
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_unique_per_user;
ALTER TABLE reports ADD CONSTRAINT reports_unique_per_user
  UNIQUE (reporter_id, target_type, target_id);

-- 4. Add target_snapshot to reports (frozen JSONB copy at time of report)
ALTER TABLE reports ADD COLUMN IF NOT EXISTS target_snapshot JSONB;

-- 5. Update get_user_role() function to check banned_until
CREATE OR REPLACE FUNCTION get_user_role(user_id UUID)
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

-- 6. RPC: get_admin_dashboard_stats
CREATE OR REPLACE FUNCTION get_admin_dashboard_stats()
RETURNS JSONB AS $$
DECLARE
  result JSONB;
  total_seekers BIGINT;
  total_recruiters BIGINT;
  total_active_posts BIGINT;
  total_applications BIGINT;
  apps_per_day JSONB;
  posts_by_category JSONB;
BEGIN
  SELECT COUNT(*) INTO total_seekers FROM profiles WHERE role = 'seeker';
  SELECT COUNT(*) INTO total_recruiters FROM profiles WHERE role = 'recruiter';
  SELECT COUNT(*) INTO total_active_posts FROM job_posts WHERE status = 'active';
  SELECT COUNT(*) INTO total_applications FROM applications;

  SELECT jsonb_agg(
    jsonb_build_object(
      'date', date_trunc('day', created_at)::date,
      'count', cnt
    )
  ) INTO apps_per_day
  FROM (
    SELECT date_trunc('day', created_at) AS created_at, COUNT(*) AS cnt
    FROM applications
    WHERE created_at >= now() - interval '7 days'
    GROUP BY date_trunc('day', created_at)
    ORDER BY created_at
  ) sub;

  SELECT jsonb_agg(
    jsonb_build_object(
      'category', c,
      'count', cnt
    )
  ) INTO posts_by_category
  FROM (
    SELECT jc.name AS c, COUNT(*) AS cnt
    FROM job_posts jp
    JOIN job_categories jc ON jc.id = jp.category_id
    WHERE jp.status = 'active'
    GROUP BY jc.name
  ) sub2(c, cnt);

  result := jsonb_build_object(
    'total_seekers', COALESCE(total_seekers, 0),
    'total_recruiters', COALESCE(total_recruiters, 0),
    'total_active_posts', COALESCE(total_active_posts, 0),
    'total_applications', COALESCE(total_applications, 0),
    'applications_per_day', COALESCE(apps_per_day, '[]'::jsonb),
    'posts_by_category', COALESCE(posts_by_category, '[]'::jsonb)
  );

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. RLS policies for admin_invites
ALTER TABLE admin_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read invites" ON admin_invites
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can create invites" ON admin_invites
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Anyone can update used_by on invite" ON admin_invites
  FOR UPDATE USING (true)
  WITH CHECK (true);

-- 8. RLS policies for reports (admin can read all, users can read own)
CREATE POLICY "Admins can read all reports" ON reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can read own reports" ON reports
  FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Users can create reports" ON reports
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Admins can update reports" ON reports
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- 9. Update profiles RLS to allow admin read all
CREATE POLICY "Admin read all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admin update profiles" ON profiles
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
