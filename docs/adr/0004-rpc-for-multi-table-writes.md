# ADR 0004 — Multi-table writes use Postgres RPC functions for atomicity

- **Status:** Accepted
- **Date:** 2026-05-25
- **Related tasks:** T-14 (Job Post create), T-15 (Edit Job Post), T-22 (Application status + note), T-23 (Interview schedule)

## Context

Creating a Job Post writes to three tables in one user action:

- `job_posts` (1 row)
- `job_locations` (1 row)
- `job_required_skills` (0–15 rows)

Supabase exposes the database via PostgREST, which does not support
multi-statement transactions over the wire. If the client issues three
sequential inserts and the second or third fails, the first commit has
already happened — leaving an orphan `job_posts` row that the recruiter
sees as a half-saved draft.

Several other tasks have the same shape:
- T-15 Edit Job Post (same three tables)
- T-22 Application status update + insert into `application_notes`
- T-23 Application status update + insert into `interview_schedules`

We need a pattern that holds across all of them.

## Decision

Multi-table writes are implemented as **Postgres functions** (PL/pgSQL),
invoked from Dart via `supabase.rpc('<function_name>', params)`. The function
body wraps all statements in an implicit transaction, so partial failure
is impossible.

Functions use `SECURITY INVOKER` (the default) so that RLS still applies as
if the caller had executed the statements directly. Explicit authorization
checks (e.g., `WHERE recruiter_id = auth.uid()`) are added as defense in
depth at the top of each function.

The first instance is `create_job_post(...)`, introduced alongside the
T-14 migration. Future multi-table writes follow the same pattern:

| Task | Function name |
|------|---------------|
| T-14 | `create_job_post(...)` |
| T-15 | `update_job_post(...)` |
| T-22 | `update_application_with_note(...)` |
| T-23 | `update_application_with_interview(...)` |

Single-table writes (e.g., adding a User Skill, toggling a Bookmark)
continue to use direct PostgREST inserts. The RPC overhead is only worth
paying when atomicity is at stake.

## Consequences

**Positive**

- Atomic by Postgres — no orphan rows ever, regardless of client-side
  failure mode (network drop, app crash mid-flight, etc.).
- One network roundtrip per logical write instead of three.
- Clean error contract: either the entire write succeeds and returns
  the new row's UUID, or it fails with a single `PostgrestException`.
- Pattern is uniform across all multi-table writes — future T-15, T-22,
  T-23 don't need to reinvent atomicity.

**Negative**

- Business logic that lives inside the function is harder to unit-test
  than Dart code. Mitigated by keeping functions limited to atomic write
  coordination — all validation (length checks, range rules,
  enum mapping) stays in Dart `Validators` before the call.
- Versioning is migration-driven. Updating a function means writing a
  new migration with `CREATE OR REPLACE FUNCTION`. Acceptable: every
  schema change in this project is migration-driven already.
- Future devs reading the Dart datasource see only `supabase.rpc('...')`
  and must look in `supabase/migrations/` to understand the write.
  Mitigated by this ADR.

**Follow-up**

- When T-15, T-22, T-23 are implemented, each adds its own RPC function
  in a focused migration.
- If we ever need cross-database orchestration (e.g., a write that spans
  Postgres + an external API), this pattern doesn't help; we'd need an
  Edge Function. Out of scope for current tasks.

## Alternatives considered

1. **Sequential inserts in Dart with manual rollback on failure.**
   Rejected because the rollback DELETE itself can fail (RLS, network,
   user closes app), leaving an orphan with no observable state. The
   "rollback" is a lie — only Postgres transactions are real.

2. **Edge Function (Deno) wrapping the writes.** Rejected because the
   Edge Function would itself need to call an RPC underneath to get
   transactionality — so this is the RPC approach with an extra hop
   and cold-start latency.

3. **Defer the decision; implement T-14 with sequential inserts and
   revisit if breakage appears.** Rejected because (a) T-15, T-22,
   T-23 are coming and will face the same problem, (b) orphan rows
   are silent failures that don't trigger "breakage" — they degrade
   trust quietly, and (c) the RPC pattern is cheap once established.
