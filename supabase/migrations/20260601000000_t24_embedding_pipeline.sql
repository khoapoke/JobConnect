-- T-24: AI Embedding Pipeline — source_hash + ai_request_logs

-- 1. Add source_hash to profile_embeddings
ALTER TABLE profile_embeddings
  ADD COLUMN source_hash TEXT NOT NULL DEFAULT '';

-- 2. Add source_hash to job_embeddings
ALTER TABLE job_embeddings
  ADD COLUMN source_hash TEXT NOT NULL DEFAULT '';

-- 3. Create ai_request_logs for server-side rate limiting
CREATE TABLE ai_request_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  request_type TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. RLS
ALTER TABLE ai_request_logs ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read their own logs only.
-- Writes are service-role only (Edge Function bypasses RLS).
CREATE POLICY "ai_request_logs.owner.select" ON ai_request_logs
  FOR SELECT TO authenticated USING (user_id = auth.uid());
