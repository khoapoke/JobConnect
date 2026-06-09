-- Expand admin_invites to support invite codes for any role

ALTER TABLE admin_invites
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'admin';
