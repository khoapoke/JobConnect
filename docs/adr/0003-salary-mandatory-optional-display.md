# ADR 0003 — Salary is mandatory data, optional display

- **Status:** Accepted
- **Date:** 2026-05-25
- **Related tasks:** T-14 (Job Post creation), T-15 (Edit Job Post), T-16 (Job Search filter), T-24 (Embedding pipeline)

## Context

The initial schema makes `job_posts.salary_min` and `salary_max` nullable
`INTEGER` columns. The grill on T-14 surfaced a real tension between two
behaviors recruiters want:

1. Some recruiters want to **express a budget freely** ("Cạnh tranh", "Hấp dẫn",
   "Bạn sẽ thích nó!") — common on VN job boards.
2. The app needs **structured, queryable data** for T-16 salary filtering and
   T-25 AI ranking.

A free-text salary column would satisfy (1) but defeat (2): posts with only
free-text could not participate in numeric filters or ranking, and recruiters
who put effort into "Up to 30tr" prose would be ranked identically to those
who entered "Thỏa thuận."

## Decision

Salary is **mandatory data** at the schema level and **optional display** at
the UI level.

- `salary_min` and `salary_max` become `NOT NULL`.
- A new column `is_salary_visible BOOLEAN NOT NULL DEFAULT true` controls
  whether the Seeker UI shows the numeric range or a fixed placeholder string.
- A CHECK constraint enforces `salary_min <= salary_max` and
  `salary_min >= 0` at the database.
- The placeholder string is a single app-wide constant
  (`AppStrings.salaryHidden = 'Bạn sẽ thích nó!'`) — not recruiter-editable.

JobConnect's product stance: every post has a budget; recruiters choose
visibility, not existence.

### Filter and ranking behavior

T-16's salary filter queries the numeric columns directly, regardless of
`is_salary_visible`. A post hidden from display still participates in
"salary ≥ 15tr" results. The Seeker sees the placeholder copy, not the number,
but the post is in the result set because it qualified numerically.

T-24 embedding reads the numeric values as a feature signal; visibility
does not affect the embedding.

### Default visibility

`is_salary_visible` defaults to `true` (transparent by default, opt-out).
This aligns with JobConnect's brand principle of clarity and with the global
trend toward forced salary transparency (US/EU regulatory direction).

## Consequences

**Positive**

- T-16 numeric filter works on every post — no "free-text orphans" excluded
  from filters.
- T-25 AI ranking can rank every post by salary if it chooses to.
- Recruiter discretion is preserved at the surface where they want it: the
  Seeker-facing display.
- Single placeholder copy means consistent Seeker experience and easy
  localization.

**Negative**

- Recruiters who genuinely don't know their budget (rare in professional
  hiring) can't post. Acceptable: JobConnect is positioned as
  professional-tier; freelance/casual posting belongs on social media.
- Schema migration changes nullability — irreversible without backfill
  ceremony if we change our minds.

**Follow-up**

- Migration `20260525000000_salary_required_with_visibility.sql` implements
  this decision.
- The placeholder copy lives in `core/constants/app_strings.dart`. Future
  changes to the copy are app-only, not schema.

## Alternatives considered

1. **Free-text `salary_note TEXT` column alongside numeric.** Rejected
   because it splits the data: posts using free-text would be unrankable and
   unfilterable, creating a two-tier visibility problem and rewarding the
   wrong recruiter behavior.

2. **Three-mode segmented control (numeric | custom text | Thỏa thuận),
   mutually exclusive.** Rejected because mode 2 (custom text) still excludes
   posts from numeric filters. Same underlying problem as alternative 1,
   wrapped in different UI.

3. **Numeric only, no hiding mechanism.** Rejected because some recruiters
   have legitimate reasons to negotiate publicly (executive roles, equity-
   heavy startup compensation). Forcing display creates a wall some real
   posts can't climb.

4. **Default `is_salary_visible = false`.** Rejected because defaults shape
   culture. A platform defaulting to hidden salaries would become a platform
   of hidden salaries, contradicting the brand principle of clarity.
