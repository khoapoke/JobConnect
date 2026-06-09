# JobConnect — Handoff: Phase 9 Implementation (Partial)

> Date: 2026-06-08
> Status: Core features scaffolded + implemented. Admin login working. Known bugs remain.
> Next session focus: Fix admin dashboard stats, report handling, recruiter home data loading, and UI polish.

---

## 🎯 What Was Implemented

### 1. Database Schema (Supabase)

**Migration files created:**
- `supabase/migrations/20260608000000_admin_phase9.sql` — Core schema changes
- `supabase/migrations/20260608000001_fix_profiles_rls.sql` — RLS fix attempt
- `supabase/migrations/20260608000002_fix_admin_rls_recursion.sql` — RLS fix attempt
- `supabase/migrations/20260608000003_fix_profiles_insert_rls.sql` — Trigger idempotency fix
- `supabase/migrations/20260608000005_remove_rls_functions.sql` — FINAL RLS rewrite (pushed successfully)

**Schema changes applied:**
| Change | Table/Column | Status |
|--------|-------------|--------|
| `banned_until TIMESTAMPTZ` | `profiles` | ✅ Applied |
| `admin_invites` | New table | ✅ Applied |
| `target_snapshot JSONB` | `reports` | ✅ Applied |
| `reports_unique_per_user` | Unique constraint | ✅ Applied |
| `get_admin_dashboard_stats()` | RPC function | ✅ Applied |
| `get_user_role()` rewritten | No recursion | ✅ Applied |

**RLS State:** `get_user_role()` now reads from `auth.users` (not `profiles`), eliminating recursion. All policies recreated with inline subqueries. Admin login works.

### 2. Admin Feature (`lib/features/admin/`)

**Data Layer:**
- `admin_datasource.dart` — `getDashboardStats()`, `getUsers()`, `getReports()`, `banUser()`, `sendWarning()`, `closeJobPost()`, `createInviteCode()`, `getInviteCodes()`
- `admin_stats_model.dart` — Freezed model with `AdminStatsModel`, `DayCountModel`, `CategoryCountModel`
- `admin_repository_impl.dart` — Full repository implementation

**Domain Layer:**
- `admin_stats.dart` — Pure Dart entities: `AdminStats`, `DayCount`, `CategoryCount`
- `admin_repository.dart` — Abstract repository interface

**Presentation Layer:**
- `admin_dashboard_page.dart` — Stat cards + fl_chart line chart (apps/7d) + bar chart (posts by category)
- `admin_users_page.dart` — Search + segmented filter (all/seeker/recruiter/banned) + user cards
- `admin_user_detail_page.dart` — Avatar, role badge, ban actions (⚠️ Cảnh cáo / ⏸️ Tạm khóa / 🚫 Khóa vĩnh viễn / Mở khóa)
- `admin_reports_page.dart` — Filtered report list (pending/resolved/dismissed/all)
- `admin_report_detail_page.dart` — Report details + actions (Đóng tin / Cảnh cáo / Xử lý / Bỏ qua)
- `admin_profile_page.dart` — Invite code generation + management + logout

**Widgets:**
- `stat_card.dart` — Reusable stat card with icon + color
- `user_card.dart` — Avatar + name + email + role badge + status indicator
- `report_card.dart` — Target type icon + reason + status chip

**Providers:**
- `admin_dashboard_provider.dart` — `adminDashboardStatsProvider`, `adminInviteCodesProvider`
- `admin_users_provider.dart` — `adminUserFilter`, `adminUserSearch`, `adminUsersProvider`
- `admin_reports_provider.dart` — `adminReportFilter`, `adminReportsProvider`, `adminReportDetailProvider`

### 3. Report Feature (`lib/features/report/`)

**Data Layer:**
- `report_datasource.dart` — `submitReport()`, `checkDuplicate()`
- `report_model.dart` — Freezed model with `target_snapshot`
- `report_repository_impl.dart` — Repository implementation

**Domain Layer:**
- `report_repository.dart` — Abstract interface

**Presentation Layer:**
- `report_provider.dart` — `reportNotifierProvider` with duplicate prevention
- `report_bottom_sheet.dart` — Bottom sheet with 5 pre-defined reason chips + optional details field

**Integration:** Report button added to:
- `JobDetailPage` — "Báo cáo tin tuyển dụng" in overflow menu
- `ChatPage` — "Báo cáo người dùng" in overflow menu

### 4. Recruiter Home (`lib/features/recruiter/presentation/pages/recruiter_home_page.dart`)

Replaced placeholder with full command center:
- Header: "Xin chào, {company}" + company logo
- Quick actions: "+ Đăng tin mới", "Xem tin nhắn" (with unread badge)
- Stat cards: Tin đang tuyển / Ứng viên mới / Lịch phỏng vấn
- Ứng viên gần đây: Last 5 pending applicants with avatar + name + job title
- Tin tuyển dụng: Active posts with applicant count

**Provider:** `recruiter_stats_provider.dart` — Queries active posts, pending applications, upcoming interviews

### 5. Ban System

- `banned_page.dart` — Shows ban status with countdown timer (temp) or "Vĩnh viễn" (perm), force logout button
- `AuthAuthenticated` has `bannedUntil` + `isBanned` getter
- Router redirect: banned users → `/banned`
- `_fetchProfile` auto-signs-out on error instead of getting stuck

### 6. Invite Code Flow

- `RegisterPage` shows "Mã mời Admin" field when Admin role selected
- `AuthDatasource` validates code (exists, unused, not expired), marks `used_by` after signup
- `AdminProfilePage` generates 8-char alphanumeric codes, lists with status

### 7. Router Updates (`lib/core/router/app_router.dart`)

- New `AdminShell` with 4 tabs: Dashboard / Quản lý / Báo cáo / Profile
- Admin routes: `/admin/dashboard`, `/admin/users`, `/admin/reports`, `/admin/profile`
- Admin push routes: `/admin/users/:id`, `/admin/reports/:id`
- `/banned` route for banned users
- Redirect: admin → `/admin/dashboard`, banned → `/banned`

### 8. Auth Updates

- `ProfileModel` / `UserProfile`: added `bannedUntil`
- `AuthState` / `AuthAuthenticated`: added `bannedUntil` + `isBanned`
- `RegisterUseCase` / `AuthRepository` / `AuthDatasource`: accept optional `inviteCode`
- `AuthErrorMapper`: now shows raw error details when message not recognized
- `validators.dart`: email regex fixed `{2,4}` → `{2,}` to allow `.local`, `.software`, etc.

---

## 🐛 Known Bugs (To Fix in Next Session)

### Bug 1: Admin Dashboard Stats Not Loading
**Symptom:** Dashboard shows "Lỗi: ..." or empty charts.
**Likely cause:** `get_admin_dashboard_stats()` RPC may return data in a format that `AdminStatsModel.fromJson` doesn't parse correctly. The `applications_per_day` and `posts_by_category` fields are `JSONB` arrays — the model expects `List<DayCountModel>` / `List<CategoryCountModel>` but the RPC returns raw JSONB.

**Files to investigate:**
- `lib/features/admin/data/models/admin_stats_model.dart` — Check `fromJson` mapping
- `lib/features/admin/data/datasources/admin_datasource.dart` — Check `getDashboardStats()` response handling
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart` — Check `adminDashboardStatsProvider` usage

**Fix approach:** Either:
- a) Change RPC to return typed columns instead of JSONB
- b) Add custom `fromJson` in model that handles raw JSONB
- c) Parse JSONB manually in datasource before passing to model

### Bug 2: Admin Reports Page Not Loading
**Symptom:** Reports tab shows error or empty list.
**Likely cause:** `AdminDatasource.getReports()` uses a complex join (`reporter:profiles!reports_reporter_id_fkey`) that may fail if the foreign key relationship isn't set up correctly, or RLS may block the admin from reading reports.

**Files to investigate:**
- `lib/features/admin/data/datasources/admin_datasource.dart` — `getReports()` query
- `lib/features/admin/presentation/providers/admin_reports_provider.dart`
- Supabase RLS policies on `reports` table

**Fix approach:**
- Simplify the Supabase query (remove nested joins, do separate queries)
- Verify admin can read reports: test `SELECT * FROM reports` as authenticated admin

### Bug 3: Recruiter Home Stats Not Loading
**Symptom:** Recruiter home shows skeleton loaders or empty data.
**Likely cause:** `recruiter_stats_provider.dart` uses `.inFilter()` with nested subqueries that may not execute correctly in Supabase Dart client. The `inFilter` expects a `List<dynamic>` but receives a `PostgrestFilterBuilder`.

**Files to investigate:**
- `lib/features/recruiter/presentation/providers/recruiter_stats_provider.dart`
- The `inFilter` calls on `companies` and `job_posts` may need to be rewritten as two-step queries

**Fix approach:**
- Break into separate queries: first get company IDs, then use those IDs in subsequent queries
- Or use RPC instead of complex nested `inFilter`

### Bug 4: Admin User Detail Page Actions May Not Work
**Symptom:** Ban/warning buttons may not persist changes.
**Likely cause:** `AdminUserDetailPage` calls `ref.invalidate(adminUsersProvider)` after ban, but the detail page loads from `adminUsersProvider` which may not include the banned user if filter excludes them.

**Files to investigate:**
- `lib/features/admin/presentation/pages/admin_user_detail_page.dart`
- `lib/features/admin/presentation/providers/admin_users_provider.dart`

### Bug 5: Report Target Snapshot May Be Null
**Symptom:** Report detail page shows empty snapshot.
**Likely cause:** `target_snapshot` is optional in the model but the UI assumes it exists.

---

## 📁 Files Created (New)

```
lib/features/admin/
├── data/
│   ├── datasources/admin_datasource.dart
│   ├── models/admin_stats_model.dart
│   └── repositories/admin_repository_impl.dart
├── domain/
│   ├── entities/admin_stats.dart
│   └── repositories/admin_repository.dart
└── presentation/
    ├── providers/
    │   ├── admin_dashboard_provider.dart
    │   ├── admin_reports_provider.dart
    │   └── admin_users_provider.dart
    ├── pages/
    │   ├── admin_dashboard_page.dart
    │   ├── admin_users_page.dart
    │   ├── admin_user_detail_page.dart
    │   ├── admin_reports_page.dart
    │   ├── admin_report_detail_page.dart
    │   └── admin_profile_page.dart
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
│   └── repositories/report_repository.dart
└── presentation/
    ├── providers/report_provider.dart
    └── widgets/report_bottom_sheet.dart

lib/features/auth/presentation/pages/banned_page.dart
lib/features/recruiter/presentation/pages/recruiter_home_page.dart
lib/features/recruiter/presentation/providers/recruiter_stats_provider.dart
lib/shared/widgets/admin_shell.dart
```

## 📁 Files Modified

```
lib/core/router/app_router.dart
lib/core/utils/validators.dart
lib/features/auth/data/datasources/auth_datasource.dart
lib/features/auth/data/mappers/auth_error_mapper.dart
lib/features/auth/data/models/profile_model.dart
lib/features/auth/data/repositories/auth_repository_impl.dart
lib/features/auth/domain/entities/auth_state.dart
lib/features/auth/domain/repositories/auth_repository.dart
lib/features/auth/domain/usecases/register_usecase.dart
lib/features/auth/presentation/pages/login_page.dart
lib/features/auth/presentation/pages/register_page.dart
lib/features/auth/presentation/providers/auth_provider.dart
lib/features/chat/presentation/pages/chat_page.dart
lib/features/jobs/presentation/pages/job_detail_page.dart
lib/shared/domain/entities/user_profile.dart
pubspec.yaml
```

## 🗄️ Supabase State

**Migration history (remote):**
- `20260608000000_admin_phase9.sql` — Core schema ✅
- `20260608000001_fix_profiles_rls.sql` — RLS fix attempt ✅
- `20260608000002_fix_admin_rls_recursion.sql` — RLS fix attempt ✅
- `20260608000003_fix_profiles_insert_rls.sql` — Trigger fix ✅
- `20260608000005_remove_rls_functions.sql` — FINAL RLS rewrite ✅

**Current `get_user_role()` implementation:**
```sql
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT raw_user_meta_data->>'role'
  FROM auth.users
  WHERE id = auth.uid()
  LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Admin user credentials (working):**
- Email: `admin@gmail.com` (or whatever email you promoted)
- Password: your normal password
- Role: `admin` in both `profiles` and `auth.users.raw_user_meta_data`

**Note:** `admin@jobconnect.local` (seeded user) still has login issues due to Supabase Auth password hashing mismatch with `crypt()`. Use the promoted `admin@gmail.com` account instead.

## 🎯 Suggested Next Session Skills

| Skill | Purpose |
|-------|---------|
| `/diagnose` | Systematically debug the 4 known bugs above |
| `/review` | Review admin/report feature code for architecture violations |
| `/impeccable` | Polish admin UI (spacing, colors, empty states, loading states) |
| `/supa` | Fix RPC return format, simplify complex queries |

## 🚀 Quick Start for Next Agent

1. **Read this handoff** + `handoff-phase9-admin-grill.md` for decisions
2. **Run app:** `flutter run`
3. **Login as admin:** use `admin@gmail.com` (or your promoted admin email)
4. **Test dashboard:** Check if stats load, identify exact error
5. **Use `/diagnose`** to systematically fix each bug

## ⚠️ Important Notes

- **DO NOT** run `supabase db reset` — it will wipe the promoted admin user
- **DO NOT** create more migrations for RLS — current state is stable
- **DO** test with `flutter run` in debug mode to see console errors
- The `fl_chart` package is already in `pubspec.yaml` and working
- Build runner has been run — `.g.dart` files are up to date
