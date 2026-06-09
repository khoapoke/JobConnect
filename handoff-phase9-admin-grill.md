# JobConnect — Handoff: Phase 9 Admin Grill Session

> Date: 2026-06-08
> Session type: /grill-me — decision-making only, no code written
> Next session: Implement Phase 9 (T-33, T-34, T-35, UI-10) + Recruiter Home

---

## 📋 Decisions Made

### 1. Admin Account Creation — Invite Code System

**Decision:** Seeded admin + invite code flow (Option A+B hybrid)

- One admin account is **seeded** in the database (already exists: `admin@jobconnect.local`)
- That admin can generate **invite codes** from the admin Profile tab
- New table: `admin_invites` with `code` (unique, 8-char alphanumeric), `created_by`, `used_by`, `expires_at`
- During registration, if a valid invite code is entered → `role = 'admin'`
- Codes are **single-use** and **expire after 24h**
- **Rationale:** Gives a good answer for lecturer Q&A ("How are admins created?") without being hardcoded

### 2. Admin Shell — 4 Tabs

| Tab | Icon | Content |
|-----|------|---------|
| 📊 Dashboard | chart icon | Stats + charts (T-33) |
| 👥 Quản lý | people icon | User management + job moderation (T-34) |
| 🚨 Báo cáo | flag/report icon | Report handling (T-35) |
| 👤 Profile | person icon | Admin profile + invite code management + logout |

- Needs a new `AdminShell` widget (similar to `RecruiterShell`)
- New `StatefulShellRoute` in `app_router.dart`, replacing the current seeker-shell-borrowing hack
- Auth redirect for admin role → `/admin/dashboard`

### 3. Admin Dashboard (T-33)

**Summary cards (top row):**
- Total Seekers
- Total Recruiters
- Total Active Job Posts
- Total Applications

**Charts (using `fl_chart` — NEW package to add):**
- 📈 Line chart: Applications over last **7 days**
- 📊 Bar chart: Job Posts by Category

**Recent activity feed (bottom):**
- Latest pending reports (quick link to Báo cáo tab)
- Latest published Job Posts (quick link to Quản lý tab)

**Data source:** Single Supabase RPC `get_admin_dashboard_stats` returning all aggregates in one call.

### 4. Job Moderation — Reactive, NOT Pre-approval

**Decision:** Keep auto-publish flow. NO `pending_review` enforcement.

**Flow:**
> Recruiter posts → auto `active` → Seeker finds abuse → 🚩 Report → Admin reviews → dismisses or takes action

**Rationale:** Smoother demo, no admin bottleneck. Consistent with how real platforms (YouTube, LinkedIn) work. The report system IS the moderation system. User's own argument: "Recruiter could post shit posts, if user finds it illegal, they report, admin considers."

**ADR-0005 remains valid** — auto-publish stays.

### 5. Ban System — 3 Tiers with `banned_until` Timestamp

**Decision:** Replace binary `is_banned` with time-based `banned_until`.

| Admin Action | Label (Vietnamese) | Effect |
|---|---|---|
| ⚠️ Warning | Cảnh cáo | System notification sent to user. No restriction. |
| ⏸️ Suspend | Tạm khóa | `banned_until` set to now + chosen duration (1h / 24h / 7 days) |
| 🚫 Permanent ban | Khóa vĩnh viễn | `banned_until` set to far future (e.g., 2099-12-31) |

**App behavior:** On login / app resume → check `banned_until` → if active, show "Tài khoản bị tạm khóa" screen with countdown → force logout. Auto-unblocks when time passes.

**No auto-escalation / strike system.** Admin makes manual judgment calls. If they see 5 reports against one user, they decide severity themselves.

**RLS change:** Modify `get_user_role()` function to check `banned_until IS NOT NULL AND banned_until > now()` instead of `is_banned = true`. One function change, auto-expiry works at both app and database level.

### 6. Report System — Seeker/Recruiter Side

**Report button placement (hidden in overflow menus ⋮):**

| Screen | Target type | Menu label |
|--------|------------|------------|
| `JobDetailPage` | `job_post` | "Báo cáo tin tuyển dụng" |
| `ChatPage` | `user` | "Báo cáo người dùng" |
| Company profile view | `company` | "Báo cáo công ty" |

**NOT on `JobCard` in feed** — only on detail/full screens.

**Submission UI — simple bottom sheet:**
1. Pre-defined reason chips (pick one):
   - "Nội dung lừa đảo / scam"
   - "Thông tin sai lệch"
   - "Nội dung không phù hợp"
   - "Spam"
   - "Khác"
2. Optional text field for additional details
3. Submit → create report with `target_snapshot` (frozen JSONB copy of reported content)

**Duplicate prevention:** `UNIQUE(reporter_id, target_type, target_id)` constraint on `reports` table.

### 7. Admin Report Handling (T-35)

- List pending reports with target preview
- Tap → detail screen showing:
  - `target_snapshot` content (what was reported, frozen at time of report)
  - Reporter info
  - Reported user info + past report count
- Action buttons: ⚠️ Cảnh cáo / ⏸️ Tạm khóa (duration picker) / 🚫 Khóa vĩnh viễn
- If target is a job post → additional "Đóng tin" button (set post status → `closed`)
- Mark report as `resolved` (action taken) or `dismissed`

### 8. Admin User Management (T-34)

**Layout:** Segmented control at top: "Tất cả" / "Seeker" / "Recruiter" / "Đã khóa"

**User card shows:**
- Avatar + full_name + email
- Role badge
- Status indicator (active / suspended / banned)
- Joined date
- Report count (if any)

**Tap → User Detail screen:**
- Profile info
- Report history against this user
- If recruiter: link to their job posts
- Action buttons: ⚠️ / ⏸️ / 🚫
- **NO chat message viewing** (privacy — if chat is reported, `target_snapshot` has evidence)

**Searchable** by name/email.

### 9. Recruiter Home — Replace Placeholder

**Decision:** Build alongside Phase 9, not deferred to 9.5. The placeholder is embarrassing for demo.

| Section | Content |
|---------|---------|
| **Header** | "Xin chào, {name}" + company logo/name |
| **Quick actions row** | "+ Đăng tin mới" button, "Xem tin nhắn" button |
| **Stat cards** | Tin đang tuyển (active posts) · Ứng viên mới (pending applications) · Lịch phỏng vấn (upcoming interviews) |
| **Ứng viên gần đây** | Last 5 new applications — tap → applicant detail |
| **Tin tuyển dụng** | Active job posts with applicant count — tap → applicants page |

**No charts for recruiter** — charts are admin territory. This is a command center: "what needs my attention?"

---

## 🗄️ Database Migration Required

```sql
-- 1. New table: admin_invites
CREATE TABLE admin_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,  -- 8-char alphanumeric
  created_by UUID NOT NULL REFERENCES profiles(id),
  used_by UUID REFERENCES profiles(id),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Add banned_until to profiles
ALTER TABLE profiles ADD COLUMN banned_until TIMESTAMPTZ;
-- Migrate existing data: UPDATE profiles SET banned_until = '2099-12-31' WHERE is_banned = true;
-- Then drop is_banned + banned_at (or keep for backwards compat during transition)

-- 3. Modify get_user_role() RLS function
-- Change: is_banned = true  →  banned_until IS NOT NULL AND banned_until > now()

-- 4. Unique constraint on reports
ALTER TABLE reports ADD CONSTRAINT reports_unique_per_user
  UNIQUE (reporter_id, target_type, target_id);

-- 5. RPC: get_admin_dashboard_stats
-- Returns: total_seekers, total_recruiters, total_active_posts,
--          total_applications, applications_per_day (7 days), posts_by_category

-- 6. RLS policies for admin_invites
-- Admin can SELECT, INSERT. Used_by update on registration.
```

---

## 📦 New Package

```yaml
fl_chart: ^0.70.0  # Line + Bar charts for admin dashboard
```

> ⚠️ Not in AGENTS.md approved list — user explicitly approved adding it.

---

## 📁 New Files to Create (scaffold)

```
lib/features/admin/
├── data/
│   ├── datasources/admin_datasource.dart
│   ├── models/admin_stats_model.dart
│   └── repositories/admin_repository_impl.dart
├── domain/
│   ├── entities/admin_stats.dart
│   ├── repositories/admin_repository.dart
│   └── usecases/
└── presentation/
    ├── providers/admin_dashboard_provider.dart
    ├── pages/
    │   ├── admin_dashboard_page.dart
    │   ├── admin_users_page.dart
    │   ├── admin_user_detail_page.dart
    │   ├── admin_reports_page.dart
    │   └── admin_report_detail_page.dart
    └── widgets/
        ├── stat_card.dart
        ├── user_card.dart
        └── report_card.dart

lib/features/report/
├── data/
│   ├── datasources/report_datasource.dart
│   ├── models/report_model.dart
│   └── repositories/report_repository_impl.dart
├── domain/
│   ├── entities/report.dart
│   └── repositories/report_repository.dart
└── presentation/
    ├── providers/report_provider.dart
    └── widgets/report_bottom_sheet.dart

lib/shared/widgets/admin_shell.dart          # New admin shell
lib/features/recruiter/presentation/pages/recruiter_home_page.dart  # Replace placeholder
```

---

## 🔀 Files to Modify

| File | Change |
|------|--------|
| `lib/core/router/app_router.dart` | Add admin shell route, admin routes, fix admin redirect |
| `lib/features/auth/presentation/pages/register_page.dart` | Add invite code field (conditional) |
| `lib/features/jobs/presentation/pages/job_detail_page.dart` | Add report overflow menu item |
| `lib/features/chat/presentation/pages/chat_page.dart` | Add report overflow menu item |
| `lib/shared/widgets/recruiter_shell.dart` | Possibly upgrade to `ScrollAwareBottomNavScaffold` |
| `pubspec.yaml` | Add `fl_chart` dependency |

---

## ❌ Explicitly NOT in Scope

- Auto-escalation / strike system — admin uses manual judgment
- `pending_review` enforcement — auto-publish stays (ADR-0005 valid)
- Chat message surveillance from admin panel — privacy concern
- Phase 10 (Job Alert / Saved Search) — grill separately
- Phase 11 (Polish) — after all features done

---

## 🎯 Suggested Skills for Next Session

| Order | Skill | Purpose |
|-------|-------|---------|
| 1 | `/supa` | Create migration: `admin_invites` table, `banned_until` column, reports constraint, dashboard RPC, RLS policies |
| 2 | `/scaffold` | Scaffold `admin/` and `report/` feature directories |
| 3 | `/feature` | Implement T-33, T-34, T-35, report submission, recruiter home |
| 4 | `/impeccable` | Polish admin + recruiter UI (Phase 9.5 / UI-10) |
| 5 | `/review` | Final review before commit |

---

## 🚀 Recommended Implementation Order

1. **DB migration** (supa) — foundation for everything
2. **Report feature** (scaffold + feature) — small, shared by both sides
3. **Admin shell + routes** — navigation infrastructure
4. **T-33: Dashboard** — first admin screen, most visual impact
5. **T-34: User Management** — search + ban actions
6. **T-35: Report Handling** — consumes report data
7. **Recruiter Home** — replace placeholder
8. **UI-10: Polish pass** — impeccable on admin + recruiter screens
9. **Admin invite flow** — wire into registration

---

*Generated from grill session. No code written — decisions only. Ready for implementation pickup.*
