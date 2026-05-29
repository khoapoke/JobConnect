# ADR 0005 — Auto-publish: Skip `pending_review` for Job Posts

- **Status:** Accepted
- **Date:** 2026-05-29
- **Related tasks:** T-15 (Job Post edit + list)

## Context

The original schema (BRIEF.md §3.5, CONTEXT.md) defined a Job Post lifecycle
that included admin pre-moderation:

```
Draft → Pending Review → Active (admin approves) → Closed
                              ↓
                          Rejected (admin rejects)
```

During the T-15 grill session, we identified that pre-moderation creates a
bottleneck:

1. **Demo friction:** Recruiter creates a post, then must switch to admin,
   approve it, then switch to seeker to see it. Three role switches for one
   user action.
2. **Admin availability:** In production, admin must be available 24/7 or posts
   sit in limbo.
3. **Industry mismatch:** Most modern job boards (LinkedIn, Indeed, TopCV)
   publish immediately and moderate *after* via reports — not before.

## Decision

Job Posts skip `pending_review` entirely. Recruiters publish directly from
`draft` to `active`:

```
Draft → Active (immediate) → Closed
   ↑                              ↓
Rejected ←────────────── Admin takes down via Reports (T-35)
```

The `pending_review` status remains in the DB CHECK constraint (no migration
to remove it — too disruptive for a small win) but the Flutter app **never
writes it** and **never reads it as a transition target**.

### Recruiter-triggered transitions

| From → To | Action | Trigger |
|---|---|---|
| `draft` → `draft` | Save edit | Edit page "Save" button |
| `draft` → `active` | Publish | Edit page "Publish" button |
| `draft` → `closed` | Discard | List card "Discard" action |
| `active` → `active` | Save edit | Edit page "Save" button |
| `active` → `closed` | Close | Edit page or list card action |
| `rejected` → `draft` | Pull back to edit | Edit page |
| `rejected` → `active` | Resubmit | Edit page "Resubmit" button |

### Edit permissions

| Status | Editable? |
|---|---|
| `draft` | ✅ Yes |
| `active` | ✅ Yes (changes go live immediately) |
| `closed` | ❌ No (read-only) |
| `rejected` | ✅ Yes (fix and resubmit) |

### Admin moderation (Phase 9)

Admin moderates via **post-moderation** using the Reports system (T-35):
- Users report problematic posts
- Admin reviews reports and can take down posts (`active` → `rejected`)
- Admin can also lock user accounts for repeat offenders

## Consequences

**Positive**

- Demo flow is smooth: recruiter publishes → seeker sees it immediately.
- No admin bottleneck for recruiters to get posts live.
- Matches real-world job board behavior (LinkedIn, Indeed model).
- Simpler implementation — no admin approval queue needed in T-15.

**Negative**

- Problematic posts are visible until someone reports them. Mitigated by
  the Reports system (T-35) and admin dashboard (T-33).
- The schema's CHECK constraint is wider than the domain actually uses.
  A future reader looking at raw SQL will wonder why `pending_review` is
  allowed but never appears in the data. Mitigated by this ADR.

**Follow-up**

- If we ever need pre-moderation (e.g., for a regulated industry client),
  the `pending_review` status is already in the schema. We'd add an
  admin approval flow in a separate task + ADR.

## Alternatives considered

1. **Keep pre-moderation (`draft` → `pending_review` → `active`).**
   Rejected: creates demo friction and admin bottleneck. Not aligned with
   modern job board UX.

2. **Hybrid: auto-publish for trusted recruiters, pre-moderation for new ones.**
   Rejected: adds complexity (trust scoring, admin trust management) that
   is out of scope for MVP. Could be revisited post-launch.

3. **Remove `pending_review` from the schema entirely.**
   Rejected: too disruptive for a small win. The status is harmless in the
   CHECK constraint and documents the original intent.
