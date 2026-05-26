# ADR 0002 — `is_required` toggle deferred; all picked skills write `true`

- **Status:** Accepted
- **Date:** 2026-05-20
- **Related tasks:** T-14 (Job Post creation), T-15 (Edit Job Post), T-27 (Skill Gap)

## Context

`job_required_skills.is_required BOOLEAN DEFAULT true` exists in the schema to
distinguish **must-have** from **nice-to-have** skills on a Job Post. The
Seeker-side consumer of that distinction is T-27 Skill Gap Analysis, which
shows "skills you're missing" with stronger weight on required skills.

T-14 (Recruiter creates Job Post) needs a skill picker. We had to decide
whether to surface the required/preferred split now or defer it.

## Decision

For T-14 and T-15 MVP, the picker writes `is_required = true` for every
selected skill. The column stays in the schema and is read correctly by any
future consumer; the app simply never sets `false`.

The skill picker reuses `SkillPickerSheet` from T-12 unchanged — same
filter-out-already-picked behaviour, no per-skill toggle UI.

## When to revisit

At the T-27 (Skill Gap) grill session. By then the consumer UX is visible, so
the toggle design can be informed by how gaps are presented to Seekers rather
than guessed in advance.

When we do introduce the toggle:

- The toggle lives in **T-15 EditJobPostPage**, not `CreateJobPostPage`.
- Rationale: *create* should be a fast path (pick skills, ship the post);
  *edit* is where the recruiter refines details after seeing the post live.

## Consequences

**Positive**

- T-14 ships sooner with a familiar picker.
- We avoid designing a per-skill toggle without seeing the Seeker-side cost
  of getting it wrong.

**Negative**

- T-27 Skill Gap, when implemented before this is revisited, treats every
  `job_required_skills` row as a hard gap — no soft/preferred distinction.
  This is acceptable: it's the strict reading of `DEFAULT true`, and
  T-27 is itself an MVP feature.

**Follow-up**

- Flag in TASKS.md T-27: dependency note on this ADR so the grill remembers
  to reconsider the picker UX.

## Alternatives considered

1. **Two pickers (required + preferred) now.** Rejected: designing the split
   before the consumer (T-27) exists is speculative. Risk of building the
   wrong distinction.

2. **Single picker with per-skill toggle in T-14.** Rejected as worst of both
   worlds: hidden toggles inside chips are a known footgun, and the toggle is
   doing work the consumer doesn't need yet.
