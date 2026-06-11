# JobConnect UI System — Light Minimal

> **Ratified 2026-06-11.** This document supersedes the previous "Modern Social Productivity" system (dark-default, Blue × Violet, cinematic glow). The visual contract is the approved prototype: `docs/design/jobconnect_light_minimal_prototype.html` — when this doc and the prototype disagree, the prototype wins.
>
> Old explorations (`jobconnect_social_productivity_exploration.html`, `jobconnect_style_exploration.html`, `jobconnect_seeker_bright_prototypes.html`) are historical and must not be used as reference.

## 1. Design North Star

**Light Minimalism, typography-first.**

JobConnect feels like a calm, confident editorial product: off-white canvas, ink typography, generous whitespace, hairline borders — and exactly **one** color. The app is quiet so the opportunities are loud.

Keywords: modern, minimalism, typography, smooth, light-first, harmonious.

Anti-keywords (banned): glow, glassmorphism, gradients, cinematic, neon, shimmer-as-decoration.

### Core principle

> **Harmony over highlights.** No screen is "the cool one" while others are boring. Everything shares one language; only four signature animations are allowed to perform.

## 2. Color System

### Light palette (default)

| Token | Value | Use |
|---|---:|---|
| `canvas` | `#FAFAFA` | Main background |
| `surface` | `#FFFFFF` | Cards, sheets, app bars, bottom nav |
| `surfaceVariant` | `#F4F4F5` | Secondary buttons, input fills, tags |
| `ink` | `#111113` | Primary text, sent chat bubbles, selected filter chips |
| `gray600` | `#52525B` | Supporting text |
| `gray400` | `#A1A1AA` | Metadata, placeholders, inactive nav |
| `hairline` | `#E4E4E7` | All borders and dividers (1px) |
| `accent` | `#F97316` | THE brand color — see usage rules |
| `accentSoft` | `#FFF4EA` | Rare tinted fill (AI icon background) |
| `success` | `#059669` | Status dot only |
| `error` | `#DC2626` | Status dot + destructive text |
| `warning` | `#D97706` | Amber — text only, never filled |

### Dark palette (pure derivation — "lights off, not energy off")

| Token | Value |
|---|---:|
| `canvas` | `#0F0F0F` (warm near-black, NOT blue-black) |
| `surface` | `#1A1A1A` |
| `surfaceVariant` | `#242427` |
| `ink` | `#F5F5F5` |
| `gray600` | `#B0B0B8` |
| `gray400` | `#6E6E76` |
| `hairline` | `rgba(255,255,255,0.09)` |
| `accent` | `#F97316` — **identical**, full saturation |
| `success` / `error` / `warning` | `#10B981` / `#F87171` / `#F59E0B` (lifted brightness) |

Dark mode rules:
- Zero new design decisions. Dark is the same app with the lights off.
- The brand must NOT feel dimmed: orange stays full-saturation, text stays high-contrast, surfaces stay clearly layered.
- Behavior: follow system setting by default + manual override in Profile/Settings.

### The orange rule (most important rule in the system)

`accent` orange may appear ONLY as:

1. **Primary action** — filled primary button (max one per screen), send button, FAB-equivalent
2. **Active navigation** — selected bottom-nav icon + label
3. **AI / match moments** — match score, ✦ AI insight accents, match ring
4. **Brand** — logo stroke, unread dots, links/ghost actions

Everything else is ink/gray. Status is never orange. Warnings are never orange (amber text only). If a screen has orange in more than ~3 places, it is wrong.

## 3. Typography

**Inter (UI/body) + Lora (display serif)** — bundled `.ttf` under `assets/fonts/`, no `google_fonts` package. Both files MUST include Vietnamese diacritics (verify "Chào buổi sáng", "Dành cho bạn" render natively before locking assets). Space Grotesk is retired.

Lora is reserved for exactly **two hero moments** — never body copy, never buttons, never nav:
1. Launch wordmark + auth screen titles
2. Hero greetings & identity ("Chào buổi sáng, Khoa", profile name)

| Role | Font | Weight | Size | Notes |
|---|---|---:|---:|---|
| Display / hero | Lora | 600 | 27–38sp | The two hero moments only |
| Page title | Inter | 800 | 24sp | letter-spacing −2% |
| Section title | Inter | 700 | 16sp | |
| Card title | Inter | 700 | 16–17sp | Job titles |
| Body | Inter | 400/500 | 14–15sp | line-height 1.5–1.6 |
| Metadata | Inter | 500 | 12–13sp | gray600/gray400 |
| Button | Inter | 700 | 13–15sp | |
| Numbers | Inter | 700/800 | — | **tabular numerals** (salary, stats, match %) |

Numbers are a typographic feature: match scores and dashboard stats are big, bold, tabular — that is their "decoration".

## 4. Spacing

Unchanged 4/8dp rhythm: 4, 8, 12, 16, 20, 24, 32, 40, 48. Screen horizontal padding: 20dp. Touch targets ≥ 48dp.

## 5. Surfaces, Radius & Elevation

- Cards: `surface` + 1px `hairline` border + radius **18** + shadow `0 1px 2px rgba(17,17,19,.04)` — that is the maximum elevation for persistent UI.
- Buttons/inputs: radius **14**. Pills/tags: radius **999/8**. Sheets: radius **28** top corners.
- Bottom sheets and dialogs: plain `surface`, hairline border, no blur, no glass. (Supersedes old `surfaceVariant` bottom-sheet rule — token names are reused with new values, see §12.)
- **Retired:** glassmorphism, gradient backgrounds, glow shadows, blur overlays.

## 6. Buttons & Actions — 4 tiers

| Tier | Style | Use | Rule |
|---|---|---|---|
| Primary | Filled `accent`, white text | The screen's single purpose: Ứng tuyển, Gửi, Lưu, Đăng tin | **Max one per screen** |
| Secondary | `surfaceVariant` fill, ink text, no border | Coexisting actions: Nhắn tin, Chỉnh sửa, Xem CV | |
| Ghost | Plain `accent` text | Low-commitment: Xem tất cả, +Thêm, dialog cancel | |
| Destructive | Plain `error` text — **never filled red** | Rút đơn, Xóa, Khóa, Từ chối | Always behind a confirm dialog; in dialogs the safe action is the bolder default |

Placement rules (mapped to features):
- **Job card (feed/search):** whole card → detail; bookmark icon top-right; **no Apply button on cards**.
- **Job detail:** sticky bottom bar = full-width primary Apply + message/bookmark icon buttons.
- **Applicant management:** horizontal row Secondary (Xem CV) · Secondary (Shortlist/Mời PV) · Destructive text (Từ chối) — mirrors the domain flow Shortlist → Invite → Reject.
- **Admin tables:** row actions are ghost/destructive text only, never filled chips.

## 7. Status System

Statuses are **quiet pills**: `surfaceVariant` pill + 6px colored dot + gray600 label. Never filled color chips, never color-alone (dot + text always together).

| Dot | Statuses |
|---|---|
| gray | pending (Đang chờ), draft, withdrawn, Mới |
| amber | reviewing (Đang xem xét) |
| ink | interview (Phỏng vấn) |
| green | accepted (Đã nhận), active (Hoạt động) |
| red | rejected (Từ chối), banned (Đã khóa), closed |

Skill gap uses the same language: owned skill = pill + green dot, missing = pill + amber dot, plus an amber text summary line ("2 kỹ năng còn thiếu").

## 8. Navigation

Tab structure is unchanged for all three roles (Seeker 5 / Recruiter 4 / Admin 4).

Style:
- `surface` bar, 1px hairline top border, **pinned** — the scroll-hide behavior is retired.
- Outline icons, gray400 inactive; active = `accent` icon + label. Labels always visible.
- Only Inter on the bar. 150–200ms color transition on switch.
- Notifications stay off-tab: bell in app header with orange unread dot.

## 9. Motion System

**One harmonized language** (everything responds, nothing performs):

| Token | Value | Use |
|---|---:|---|
| `press` | 120ms, scale 0.97 | Every pressable: cards, buttons, chips |
| `state` | 200ms ease-out | Tab switch, toggle, chip select, theme change |
| `stagger` | 30ms | List item fade-up, first load only |
| `route` | 300ms slide-fade | Page transitions, consistent direction |

Easing everywhere: `cubic-bezier(.25,.8,.35,1)`.

**Exactly four signature animations** — all built from the loop mark, nothing else gets to perform:

1. **Launch** — loop draws itself in orange (~750ms), nodes pop with spring, Lora wordmark fades up. Total ≤ 1.4s.
2. **Match score reveal** — orange ring draws around the score while the number counts 0→N% in tabular numerals (~1.1s, ease-out cubic).
3. **Apply success** — the loop draws and closes at the moment the Application is created: "connection made". No confetti.
4. **Pull-to-refresh** — the loop spins in place of the stock spinner.

Reduced motion: static logo + fade for launch; ring renders at final state; numbers appear without count-up; stagger/spin disabled.

## 10. Logo & Launch

- Mark: the **connection loop** — a single circle stroke with two nodes (Seeker ↔ Recruiter). Redrawn as one clean `accent` orange stroke, one weight, no gradient, no glow. Works single-color at any size (app icon, app bar, empty states).
- Launch screen: Threads-style — blank canvas, mark center, draw-in animation, Lora "JobConnect" wordmark, small gray caption bottom ("Kết nối cơ hội của bạn").
- Flutter: `CustomPainter` + `AnimationController` + `PathMetric.extractPath`, flat orange paint.

## 11. Screen Tiers

**Signature** (the 4 animations live here, still on the same quiet canvas): Launch, Seeker Home feed, Job Detail (match ring + skill gap), Apply success.

**Core** (daily use, calm): Search/filters, My Applications, Chat, Profile, Notifications, Bookmarks.

**Utility** (maximum restraint): Auth, CV builder, all forms, Recruiter screens, Admin screens. Admin charts: gray bars + one orange highlight bar, hairline tables, text row-actions.

Chat specifics: sent bubble = ink fill (inverts in dark), received = `surfaceVariant`. Orange appears only on the send button.

## 12. Flutter Migration Map

The redesign rolls out as TASKS.md Phase 9.5 (UI-10 → UI-14). Because UI-01→09 funneled styling through `core/theme/` and shared primitives, most of the look arrives via token + primitive swaps.

| Existing | Fate |
|---|---|
| `AppColors` | Re-tokened: light-first values from §2, dark derivation |
| `AppTextStyles` | Inter roles from §3; display roles move Space Grotesk → Lora |
| `AppGradients` | **Retired** (delete usages) |
| `AppShadows` | Single card shadow + overlay shadow only |
| `GlassSurface` | **Retired** → plain bordered `surface` card |
| `PremiumButton` | Rework into the 4-tier button set |
| `StatusChip` | Rework into dot-pill (§7) |
| `SpotlightSearchBar` | Simplify: filled field, orange focus border, no glow |
| `ScrollAwareBottomNavScaffold` | Replace with pinned nav bar |
| `ConnectionLoopLogo` | Redraw: single orange stroke, new draw-in timing |
| `AppSkeleton`, `AnimatedPressable` | Keep; retune to §9 tokens |
| Fonts | Add Lora (Vietnamese subset verified); Space Grotesk may be removed once no references remain |

## 13. Accessibility & Performance

- Text contrast ≥ WCAG AA in both modes (verify orange-on-white for small text; use ink for small text, orange for ≥14sp bold/large elements).
- Touch targets ≥ 48dp. Status never color-alone (dot + label). Support system text scaling.
- Respect reduced motion (§9). Animate transform/opacity only. No blur behind scrolling lists. Skeletons only while loading.
