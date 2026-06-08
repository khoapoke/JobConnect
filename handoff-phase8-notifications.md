# JobConnect — Handoff Document: Phase 8 Complete

> Date: 2026-06-07
> Last Session: Phase 8 Notifications + Bug Fixes

---

## ✅ Completed in This Session

### Phase 8 — Notifications (T-30, T-31, T-32, UI-09)

| Task | Status | Summary |
|------|--------|---------|
| **T-30** | ✅ | FCM setup + device token lifecycle |
| **T-31** | ✅ | In-app notification list page |
| **T-32** | ✅ | Supabase triggers for application status + new applicant |
| **UI-09** | ✅ | Notification center polish |

### Files Created (Phase 8)

```
lib/features/notification/
├── data/
│   ├── datasources/notification_datasource.dart
│   ├── models/notification_model.dart
│   └── repositories/notification_repository_impl.dart
├── domain/
│   ├── entities/notification.dart
│   ├── repositories/notification_repository.dart
│   └── usecases/
└── presentation/
    ├── providers/
    │   ├── notification_provider.dart
    │   └── notification_setup_provider.dart
    ├── pages/
    │   └── notifications_page.dart
    └── widgets/
        └── notification_card.dart

supabase/migrations/
└── 20260607000000_t32_new_applicant_trigger.sql
```

### Key Implementation Details

- **FCM token**: Saved to `device_tokens` on login via `notificationSetupProvider` (watches `authProvider`). Deleted on logout via `ProfilePage._handleLogout()`.
- **Foreground notifications**: `FirebaseMessaging.onMessage` → `flutter_local_notifications` banner via `AndroidNotificationChannel`.
- **In-app list**: `NotificationsPage` with pull-to-refresh, mark single read, mark all read. Tap navigates to target page based on `data_json`.
- **Triggers**: `update_application_with_note` RPC creates seeker notifications on status changes. New trigger `notify_recruiter_on_new_application` fires `AFTER INSERT ON applications`.
- **Badge**: Red dot on **Messages** nav icon (bottom bar) — NOT on Home icon. Uses `conversationUnreadCountProvider` (sums unread messages across all conversations).

---

## 🔧 Bug Fixes in This Session

### 1. iOS Deployment Target (Firebase)

Firebase packages require iOS 15.0+.

**Fixed:**
- `ios/Podfile`: `platform :ios, '13.0'` → `'15.0'`
- `ios/Podfile`: `post_install` deployment target → `'15.0'`
- `ios/Runner.xcodeproj/project.pbxproj`: 3 `IPHONEOS_DEPLOYMENT_TARGET` entries → `15.0`

**⚠️ Required after pulling:** Run `cd ios && rm -rf Pods Podfile.lock && cd .. && flutter clean && flutter pub get`

### 2. ChatPage Disposed Widget Ref Errors

**Root cause:** `ref.invalidate()` in `dispose()` + `ref.listen` callback calling async `_markAsRead()` synchronously.

**Fixed:**
- Removed `ref.invalidate(conversationListNotifierProvider)` from `dispose()`
- Wrapped `_markAsRead()` call in `WidgetsBinding.instance.addPostFrameCallback` inside `ref.listen`
- Added `mounted` guards in `_markAsRead()`

---

## 📊 Current Project State

### Task Progress (51 total tasks)

| Phase | Tasks | Status |
|-------|-------|--------|
| 0 — Foundation | T-00 → T-05 | ✅ Done |
| 1 — Auth | T-06 → T-09 | ✅ Done |
| 2 — Seeker Profile | T-10 → T-12 | ✅ Done |
| 3 — Recruiter Setup | T-13 → T-15 | ✅ Done |
| 4 — Job Discovery | T-16 → T-18 | ✅ Done |
| 5 — Application | T-19 → T-23 | ✅ Done |
| 5.5 — UI/UX | UI-01 → UI-06 | ✅ Done |
| 6 — AI | T-24 → T-27 | ✅ Done |
| 6.5 — AI UI | UI-07 | ✅ Done |
| 7 — Chat | T-28 → T-29 | ✅ Done |
| 7.5 — Chat UI | UI-08 | ✅ Done |
| **8 — Notification** | **T-30 → T-32** | **✅ Done** |
| **8.5 — Notif UI** | **UI-09** | **✅ Done** |
| 9 — Admin | T-33 → T-35 | ⬜ **Next** |
| 9.5 — Utility UI | UI-10 | ⬜ |
| 10 — Job Alert | T-36 → T-37 | ⬜ |
| 10.5 — Job Alert UI | UI-11 | ⬜ |
| 11 — Polish | T-38 → T-39 | ⬜ |

**Completed: 36/51 tasks (70%)**

---

### Package Dependencies (Current)

```yaml
# Firebase (added in Phase 8)
firebase_core: ^4.10.0
firebase_messaging: ^16.3.0
flutter_local_notifications: ^17.0.0

# Existing (all phases)
flutter_riverpod, riverpod_annotation, go_router, supabase_flutter,
freezed_annotation, json_annotation, dio, flutter_secure_storage,
cached_network_image, file_picker, flutter_svg, intl, equatable,
image_picker, pdf, printing
```

---

### Navigation Bar Badge Summary

| Icon | Badge Source | Meaning |
|------|-------------|---------|
| 💬 Messages (tab 3) | `conversationUnreadCountProvider` | Unread chat messages from others |
| 🔔 Notifications (header) | *none* | Removed — navigate via `/notifications` push route |

The `UnreadCount` provider still polls every 30s for in-app notifications (notification list page), but the **bottom nav badge** tracks only **chat messages**.

---

### Known Limitations / TODOs

1. **Firebase platform config**: `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are NOT in the repo. Firebase init is guarded with try/catch — app works without them but no push notifications.
2. **Recruiter Home page**: Currently `PlaceholderPage`. Recruiter shell is functional but the home tab is empty.
3. **Admin shell**: Borrowing Seeker shell temporarily — needs proper `AdminShell` with T-33.
4. **Job Alert**: Edge Function for daily schedule not yet built (Phase 10).

---

### Database Triggers in Place

```sql
-- Application status changes → seeker notification
update_application_with_note      (RPC)
update_application_with_interview   (RPC)

-- New application → recruiter notification
notify_recruiter_on_new_application (AFTER INSERT ON applications)
```

---

### Next Recommended Work

The **highest impact** next step is:

> **Phase 9 — Admin** (T-33 → T-35) or **Recruiter Home** polish

Recruiter is currently the weakest UX flow (placeholder home, empty dashboard). Consider grilling on:
- What should the recruiter see on login? (applicant stats, recent activity, quick actions?)
- Should admin be built before or after recruiter home improvement?

---

## 🚀 Quick Start for Next Session

```bash
# After pulling changes:
cd /Users/khoado/code/JobConnect
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# If iOS build fails:
cd ios && rm -rf Pods Podfile.lock && cd ..
flutter clean
flutter pub get
flutter run

# Verify
flutter analyze  # Should be: No issues found!
```

---

*Generated by pi agent. Ready for next developer pickup.*
