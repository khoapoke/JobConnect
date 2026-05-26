# Handoff — T-14 Job Post Creation

> **From:** Opus 4.7 grill session (2026-05-25)
> **To:** Sonnet 4.6 (High) for implementation
> **Status:** Decisions locked. No code written yet. Ready to scaffold + implement.

## What this is

A grill session walked the design tree for **T-14: Đăng tin tuyển dụng**
(`TASKS.md` Phase 3). All 14 design decisions are resolved. Two new ADRs
were written. Your job is to implement T-14 end-to-end without
re-litigating these decisions.

**If something here contradicts a project rule, the project rule wins —
flag the contradiction back, don't silently deviate.**

## Read first (in this order)

1. `CLAUDE.md` — code style, architecture rules, forbidden patterns
2. `CONTEXT.md` — domain terms (Job Post, Job Location, Required Skill, etc.)
3. `docs/adr/0001-remote-work-canonical-flag.md` — `is_remote` is canonical;
   `job_posts.type` is employment category only (full_time/part_time/
   contract/internship — never `remote` or `hybrid`)
4. `docs/adr/0002-required-skills-deferred-toggle.md` — reuse `SkillPickerSheet`
   from T-12 unchanged; all selected skills write `is_required=true`
5. `docs/adr/0003-salary-mandatory-optional-display.md` — **new in this grill**
6. `docs/adr/0004-rpc-for-multi-table-writes.md` — **new in this grill**
7. `TASKS.md` § T-14 — original task description

## Locked decisions (14)

| # | Topic | Decision |
|---|---|---|
| 1 | Status flow | Draft-only on create. Single CTA "Lưu nháp" → `status='draft'`. Submit-for-review is T-15's responsibility. |
| 2 | Location subform | Inline (not separate sheet). `is_remote` Switch. Remote-with-HQ semantics: province required regardless of remote flag; district + address always optional. |
| 3 | Salary | Both `salary_min` and `salary_max` mandatory. New `is_salary_visible` Switch (default true). Hidden-display placeholder = `'Bạn sẽ thích nó!'`. Input UI in millions VND (recruiter types `15`), stored in raw VND (DB has `15000000`). See ADR-0003. |
| 4 | Draft vs publish validation | Save-draft requires: title (≥3), salary numbers, province, type. Description/requirements/category/skills required only for publish (T-15). |
| 5 | Company gating | Hard route guard. No Company → redirect to `/recruiter/company/edit?onboarding=true` with snackbar. CTA visible always (no hiding). |
| 6 | Description / Requirements | Plain text + line breaks. `description` ≤5000 chars, ≥50 for publish. `requirements` ≤3000 chars, ≥30 for publish. **No `benefits` column** — recruiter writes "Quyền lợi:" inside description. |
| 7 | Category | Single FK (schema-locked). Required only for publish. New `CategoryPickerSheet` modeled on `SkillPickerSheet`. 11 categories already seeded. |
| 8 | Required skills | Reuse `SkillPickerSheet` from T-12 unchanged (per ADR-0002). All rows write `is_required=true`. Max 15. Cross-category allowed. ≥1 for publish, 0 for draft. |
| 9 | Title | Trim on save. 3–100 chars. No language/emoji restriction. App-level only; no DB CHECK. |
| 10 | `expires_at` | Show in form with default `now + 30d`. Range `[+1d, +90d]`. NULL allowed for draft, required for publish. T-16 will filter expired at read-time (`WHERE expires_at IS NULL OR expires_at > now()`). **No background job.** |
| 11 | Transactionality | Postgres RPC `create_job_post(...)` — single atomic call across 3 tables. See ADR-0004. |
| 12 | Route + entry | Push route `/recruiter/posts/new` (outside shell, hides bottom nav). FAB on existing `/recruiter/posts` placeholder. After save → `context.pop()` + snackbar "Đã lưu nháp." |
| 13 | Provider shape | `ConsumerStatefulWidget` + `TextEditingController`s + local non-text state. **Matches T-13 `EditCompanyPage` exactly** — read it first to copy the pattern. Action-only `@riverpod class JobPostNotifier` (no auto-fetch). `PopScope` confirm-dialog on back nav when form has unsaved changes. |
| 14 | CHECK constraint cleanup | Skip. Keep ADR-0001's discipline. Dead `'remote'`/`'hybrid'` values stay in `job_posts.type` CHECK. |

## What to build

### 1. Migration

**Path:** `supabase/migrations/20260525000000_t14_job_post_create.sql`

Two concerns in one focused migration (both from T-14 grill):

```sql
-- Concern 1: Salary becomes mandatory data (ADR-0003)
ALTER TABLE job_posts ALTER COLUMN salary_min SET NOT NULL;
ALTER TABLE job_posts ALTER COLUMN salary_max SET NOT NULL;
ALTER TABLE job_posts ADD COLUMN is_salary_visible BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE job_posts ADD CONSTRAINT salary_range_valid CHECK (salary_min <= salary_max);
ALTER TABLE job_posts ADD CONSTRAINT salary_non_negative CHECK (salary_min >= 0);

-- Concern 2: Atomic multi-table write (ADR-0004)
CREATE OR REPLACE FUNCTION create_job_post(
  p_company_id UUID, p_title TEXT, p_description TEXT, p_requirements TEXT,
  p_salary_min INTEGER, p_salary_max INTEGER, p_is_salary_visible BOOLEAN,
  p_type TEXT, p_category_id UUID, p_expires_at TIMESTAMPTZ,
  p_province TEXT, p_district TEXT, p_address TEXT, p_is_remote BOOLEAN,
  p_skill_ids UUID[]
) RETURNS UUID LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE v_job_id UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM companies WHERE id = p_company_id AND recruiter_id = auth.uid()) THEN
    RAISE EXCEPTION 'Not authorized to post for this company';
  END IF;
  INSERT INTO job_posts (company_id, title, description, requirements,
    salary_min, salary_max, is_salary_visible, type, category_id, expires_at, status)
  VALUES (p_company_id, p_title, p_description, p_requirements,
    p_salary_min, p_salary_max, p_is_salary_visible, p_type, p_category_id, p_expires_at, 'draft')
  RETURNING id INTO v_job_id;
  INSERT INTO job_locations (job_id, province, district, address, is_remote)
  VALUES (v_job_id, p_province, p_district, p_address, p_is_remote);
  IF array_length(p_skill_ids, 1) > 0 THEN
    INSERT INTO job_required_skills (job_id, skill_id, is_required)
    SELECT v_job_id, unnest(p_skill_ids), true;
  END IF;
  RETURN v_job_id;
END; $$;
```

Apply via Supabase MCP plugin (`mcp__plugin_supabase_supabase__apply_migration`)
or the Supabase CLI. **After applying, also update `docs/BRIEF.md` §7** —
schema block must reflect `salary_min/max NOT NULL` and `is_salary_visible`.

### 2. Files to create

**Data layer (`lib/features/recruiter/data/`):**
- `datasources/job_post_datasource.dart` — single `createJobPost(payload)`
  calling `supabase.rpc('create_job_post', ...)`
- `models/create_job_post_payload.dart` — Freezed; field names mirror the
  RPC params
- `repositories/job_post_repository_impl.dart` — wraps datasource, returns
  `Either<Failure, String>` (the new job's UUID)

**Domain layer:**
- `domain/repositories/job_post_repository.dart` — abstract interface
- `domain/entities/create_job_post_input.dart` — pure Dart, no Freezed
  annotation
- **No use case** — pure CRUD, single repo call, per
  CLAUDE.md "Usecase Exception Rule"

**Presentation layer:**
- `presentation/pages/create_job_post_page.dart` — `ConsumerStatefulWidget`
  with TextEditingControllers; structure mirrors
  `edit_company_page.dart`
- `presentation/providers/job_post_provider.dart` — `@riverpod class
  JobPostNotifier` exposing `Future<Either<Failure, String>> create(...)`.
  Override `build()` returns void (action-only notifier)
- `presentation/widgets/category_picker_sheet.dart` — modeled on
  `lib/features/profile/presentation/widgets/skill_picker_sheet.dart`
- `presentation/widgets/expires_at_picker.dart` — wraps `showDatePicker`
  with `firstDate: now+1d`, `lastDate: now+90d`

### 3. Files to modify

- `lib/core/constants/app_strings.dart` — add:
  - `salaryHidden = 'Bạn sẽ thích nó!'`
  - Form labels (Vietnamese): "Đăng tin tuyển dụng", "Lưu nháp",
    "Tên tin tuyển dụng", "Mô tả công việc", "Yêu cầu ứng viên",
    "Mức lương", "Thỏa thuận" (no longer used — drop if exists),
    "Hiển thị mức lương cho ứng viên", "Ngành nghề", "Kỹ năng yêu cầu",
    "Thêm kỹ năng", "Địa điểm làm việc", "Làm việc từ xa", "Hạn nộp hồ sơ",
    etc.
- `lib/core/constants/job_post_types.dart` — verify this file exists per
  ADR-0001; enum should have exactly: `fullTime`, `partTime`, `contract`,
  `internship`. If missing, create it.
- `lib/core/utils/validators.dart` — add:
  - `jobTitle(String?)` → 3–100 chars after trim
  - `jobDescription(String?, {required bool forPublish})` → ≤5000;
    ≥50 when `forPublish`
  - `jobRequirements(String?, {required bool forPublish})` → ≤3000;
    ≥30 when `forPublish`
  - `salaryRange(int? min, int? max)` → both non-null, `min ≤ max`,
    both ≥ 0
  - `expiresAtForPublish(DateTime?)` → in `[now+1d, now+90d]`
- `lib/core/router/app_router.dart`:
  - Add push route `GoRoute(path: '/recruiter/posts/new', builder: ...)`
  - Add Company guard in `redirect:` — if matched and no company → redirect
    to `/recruiter/company/edit?onboarding=true`
- `lib/core/router/app_router.dart` recruiter shell — wrap `/recruiter/posts`
  placeholder with a `Scaffold` that adds a `FloatingActionButton` →
  `context.push('/recruiter/posts/new')`
- `docs/BRIEF.md` §7 — update schema block (concern 1 of migration)
- `TASKS.md` — tick T-14 ☑ after review passes

### 4. Validation rules summary (for `Validators`)

| Field | Draft rule | Publish rule (T-15) |
|---|---|---|
| title | trim, 3–100 chars | same |
| description | ≤5000 | also ≥50 |
| requirements | ≤3000 | also ≥30 |
| salary_min, salary_max | both required, integer ≥0, min≤max | same |
| is_salary_visible | bool, defaults true | same |
| type | required, one of `JobPostType` enum | same |
| category_id | optional | required |
| expires_at | optional | required, in [+1d, +90d] |
| province | required | same |
| district, address | optional | same |
| is_remote | bool, defaults false | same |
| skills | 0–15 | 1–15 |

T-14 only saves drafts, so use the draft rules. The publish rules are
documented here for T-15 to inherit. The `Validators` methods should
already accept the `{required bool forPublish}` flag so T-15 reuses them
unchanged.

## Form layout (concrete)

Sections top-to-bottom:

1. **Tên tin tuyển dụng** — single-line TextField, max 100 + counter
2. **Mô tả công việc** — multiline TextField, min 6 lines, max 5000 +
   counter, hint mentions "Quyền lợi:" sub-heading
3. **Yêu cầu ứng viên** — multiline TextField, min 4 lines, max 3000 +
   counter
4. **Loại hình** — `SegmentedButton<JobPostType>` (4 options)
5. **Ngành nghề** — ListTile-style row → `CategoryPickerSheet`
6. **Mức lương** — two integer fields ("Từ" / "Đến"), suffix
   "triệu/tháng" + Switch "Hiển thị mức lương cho ứng viên" (default ON)
7. **Địa điểm làm việc** — Switch "Làm việc từ xa" + Province picker (row
   that opens `province_picker_sheet`, already exists from T-13) +
   District TextField + Address TextField (multiline)
8. **Kỹ năng yêu cầu** — Wrap of skill chips with X + "+ Thêm kỹ năng"
   button → `SkillPickerSheet` + counter `n / 15`
9. **Hạn nộp hồ sơ** — ListTile row showing date → `expires_at_picker`

Bottom: primary button "Lưu nháp" (full-width, AppColors.primary). Disabled
until draft-validation passes. `_isSaving` local bool gates the submit.

## Pattern to follow

**Read `lib/features/recruiter/presentation/pages/edit_company_page.dart`
first.** Copy its exact pattern:
- `ConsumerStatefulWidget` structure
- `initState` reading providers once via `ref.read` (never in build)
- Late-init `TextEditingController`s + proper `dispose`
- `_formKey` + `Validators` + `_formKey.currentState!.validate()`
- `_isSaving` bool around the async call
- Snackbar + `context.pop()` on success
- Error surfacing via `result.fold((failure) => snackbar, (id) => pop)`

Deviating from this pattern (e.g., using a state-holding `AsyncNotifier`
for form state) needs justification. The grill explicitly chose
consistency with T-13.

## Out of scope for T-14 (don't build these)

- `MyJobPostsPage` (T-15's job — just add the FAB to the existing
  placeholder)
- Edit / submit-for-review / close (T-15)
- Admin moderation flow (T-34) — during dev, flip status manually in
  Supabase dashboard
- Background expiry job (none needed — T-16 read-time filter)
- Bottom nav redesign

## How to verify

1. `dart run build_runner build --delete-conflicting-outputs` — codegen
   for Freezed + Riverpod
2. `flutter analyze` — zero warnings (per CLAUDE.md DO NOT)
3. Manual test on a recruiter account:
   - With Company → tap FAB on `/recruiter/posts` → fill minimum
     fields → save → snackbar appears, returns to posts tab
   - Without Company → tap FAB → redirected to `EditCompanyPage`
     with onboarding snackbar
   - Verify in Supabase dashboard: one row in each of `job_posts`,
     `job_locations`, `job_required_skills`
   - Test the atomicity: pass an invalid `skill_id` in payload via DB
     inspector — confirm NO `job_posts` row gets created
4. Test `PopScope` confirmation: fill fields, tap back → dialog appears

## Suggested skills

In order:

1. **`/scaffold`** — generate the file skeleton for the data/domain/
   presentation layers under `lib/features/recruiter/`. Don't implement
   logic, just create empty correctly-typed files.
2. **`/supa`** — for the migration file. Use the migration SQL from
   the "Migration" section above.
3. **`/feature`** — implement all logic. Reference this handoff doc and
   the locked decisions table. Read `edit_company_page.dart` first.
4. **`/review`** — before commit. Catches CLAUDE.md rule violations.

After `/review` passes:

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

Then commit per CLAUDE.md Git Convention:

```
feat(jobs): add job post creation with draft save and atomic RPC
```

Tick T-14 ☑ in `TASKS.md`.

## Suggested commit boundaries

Split into 2 commits if review is cleaner that way, 1 commit otherwise:

1. `feat(db): salary mandatory + create_job_post RPC` — migration only
2. `feat(jobs): add CreateJobPostPage with draft save` — Dart code

## Open follow-ups (not for this session)

- T-15 grill should explicitly revisit whether to add per-skill
  `is_required` toggle (ADR-0002's deferred question still deferred)
- T-27 will re-open ADR-0002 once Skill Gap UX is visible
- When T-16 builds the search, remember the read-time `expires_at` filter
  (locked in Q10)

## Sensitive info redaction

None in this doc. All API keys, Supabase URLs, FCM tokens stay in
`--dart-define` per CLAUDE.md.
