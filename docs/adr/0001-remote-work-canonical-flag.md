# ADR 0001 — `job_locations.is_remote` is the canonical "remote work" flag

- **Status:** Accepted
- **Date:** 2026-05-20
- **Related task:** T-14 (Job Post creation)

## Context

The schema (migration `20260511000000_initial_schema.sql`) expresses
"remote work" in two places:

- `job_posts.type` CHECK constraint allows `'remote'` and `'hybrid'` alongside
  the employment-category values (`full_time`, `part_time`, `contract`, `internship`).
- `job_locations.is_remote BOOLEAN` is a per-location flag.

This is redundant. When implementing T-14 (`CreateJobPostPage`) we had to pick a
single source of truth so the form, filter logic (T-16), and AI embedding
pipeline (T-24) don't disagree about what "remote" means.

## Decision

`job_locations.is_remote` is the **canonical** flag for "this Job Post allows
remote work."

`job_posts.type` is treated as **employment category only**. The app uses
exactly four of its CHECK-allowed values:

- `full_time` · Toàn thời gian
- `part_time` · Bán thời gian
- `contract`  · Hợp đồng
- `internship` · Thực tập

The values `'remote'` and `'hybrid'` remain in the DB CHECK constraint (no
migration to remove them — too disruptive for a small win) but the Flutter app
**never writes them** and **never reads them as employment categories**. The
`JobPostType` enum in `core/constants/job_post_types.dart` lists only the four
above; `JobPostType.fromValue('remote')` returns `null`.

## Consequences

**Positive**

- One axis per concept: T-16 search can filter by employment type *and* remote
  independently, matching how LinkedIn/VietnamWorks present the choice to users.
- Form UX in T-14 is unambiguous: a dropdown for type, a separate Switch for remote.
- T-24 embedding text can include "remote" as a feature signal regardless of
  employment type.

**Negative**

- The schema's CHECK constraint is wider than the domain actually uses. A future
  reader looking at raw SQL will wonder why two values are allowed but never
  appear in the data. Mitigated by this ADR and a comment in the migration.
- Any post imported from an external source with `type='remote'` would not be
  representable by the current enum. Not a concern — no imports planned.

**Follow-up**

- If we ever clean the CHECK constraint, that would be a separate migration
  + ADR after verifying no rows hold the unused values.

## Alternatives considered

1. **`job_posts.type` as canonical (use `'remote'`/`'hybrid'` values).**
   Rejected: it collapses two orthogonal axes (employment category × work mode)
   into one. A "part-time remote internship" can't be expressed.

2. **Both fields, kept in sync by the app.**
   Rejected: two writers means inevitable drift; either field could win after a
   bug and there's no way to tell which is "right."
