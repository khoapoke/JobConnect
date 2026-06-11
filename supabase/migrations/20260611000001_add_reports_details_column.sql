-- Catch-up migration: BRIEF.md §7 and ReportDatasource.submitReport already
-- use reports.details, but no migration ever created the column.
-- IF NOT EXISTS keeps this safe if it was added manually via Dashboard.

ALTER TABLE reports ADD COLUMN IF NOT EXISTS details TEXT;
