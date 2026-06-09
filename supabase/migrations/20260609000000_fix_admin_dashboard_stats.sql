-- Fix: get_admin_dashboard_stats() had 'c.name' where 'c' is a column alias, not a table.
-- This caused: missing FROM-clause entry for table "c"

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
