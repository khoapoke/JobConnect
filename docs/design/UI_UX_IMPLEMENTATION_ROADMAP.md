# JobConnect UI/UX Implementation Roadmap

> Purpose: keep the new UI/UX direction visible while feature development continues. This is the design implementation companion to `TASKS.md`.

## Locked UI Direction

- **Audience anchor:** Job Seeker-first
- **Design style:** Modern Social Productivity Design
- **Mood:** Cinematic Minimalism
- **Inspired by:** Instagram / Threads × Linear × Raycast
- **Interaction model:** Feed-first + Spotlight search
- **Color direction:** Blue × Violet Hybrid
- **Typography:** Space Grotesk display + Inter UI/body
- **Theme:** Dark default + refreshing premium light mode
- **Expressiveness:** Premium expressive, strictly curated
- **Feed:** Mixed feed card system
- **Logo:** Dual-mode connection-loop logo

Full design system: `docs/design/JOB_CONNECT_UI_SYSTEM.md`

Visual preview: `docs/design/jobconnect_social_productivity_exploration.html`

## Core Principle

> CRUD should feel invisible. Core features should feel memorable.

### Minimal/basic functions

Keep these clean, fast, and low-animation:

- Bookmark
- Edit profile
- Add/edit/delete education
- Add/edit/delete work experience
- Upload CV
- Basic filters
- Settings
- Recruiter job/company forms
- Admin tables/forms

Allowed:

- subtle press feedback
- loading state
- success/error toast
- small icon scale/fill animation
- clean blue focus state

Avoid:

- heavy gradients
- unnecessary glow
- parallax
- decorative shimmer

### Addictive/core features

These should receive premium motion and cinematic treatment:

- Job feed discovery
- Spotlight search
- AI job match
- Match explanation
- Skill gap analysis
- Job detail transition
- Apply success
- Profile completion/career readiness
- Splash/launch identity

Allowed:

- shared element transitions
- animated match score
- blue/violet gradients
- subtle glassmorphism
- haptic feedback
- shimmer skeletons
- meaningful reveal animations

## UI Implementation Track

This track should happen **before Phase 6 AI UI work** and then continue alongside future feature phases.

### UI-01 — Design foundation tokens + font assets

Create/update:

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_theme.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_radii.dart
lib/core/theme/app_durations.dart
lib/core/theme/app_gradients.dart
lib/core/theme/app_shadows.dart
```

Requirements:

- Dark default + polished light mode.
- Blue × Violet Hybrid tokens.
- No raw hex colors in feature widgets after migration.
- Use semantic tokens, not one-off colors.
- Bundle fonts, no `google_fonts` dependency unless approved separately.
- Register Inter and Space Grotesk in `pubspec.yaml`.

```text
assets/fonts/inter/
assets/fonts/space_grotesk/
```

### UI-02 — Shared feed-ready primitives + scroll-aware nav foundation

Create reusable widgets in:

```text
lib/shared/presentation/widgets/
```

Mandatory first-pass widgets:

```text
app_gradient_background.dart
glass_surface.dart
premium_button.dart
status_chip.dart
spotlight_search_bar.dart
animated_pressable.dart
app_skeleton.dart
connection_loop_logo.dart
scroll_aware_bottom_nav_scaffold.dart
```

Rules:

- Do not hardcode gradients/shadows inside feature pages.
- Feature widgets compose shared primitives.
- Components must support dark/light theme.
- Components must respect reduced motion where relevant.

### UI-03 — Global theme replacement

Apply the new theme globally:

- Material `ThemeData`
- AppBar
- BottomNavigationBar / NavigationBar
- Buttons
- Inputs
- Chips
- Cards
- Dialogs
- Bottom sheets
- Snackbars

Guardrail:

- Global tokens change everywhere.
- Expressive effects do **not** appear everywhere.
- CRUD remains minimal.

### UI-04 — Job Seeker Home / Feed redesign

First flagship page after foundation.

Implement:

- Feed-first home structure.
- Spotlight search entry.
- Social category tabs.
- Mixed feed cards.
- Featured cinematic job card.
- Normal compact social job card.
- AI insight placeholder card for future Phase 6.
- Minimal bookmark behavior.

### UI-05 — Job Detail and Apply flow polish

Implement:

- Card-to-detail shared element concept where practical.
- Premium job header.
- Clear salary/location/company hierarchy.
- Apply CTA with polished loading/success state.
- Apply form remains clean/minimal.

### UI-06 — Splash/logo integration

After foundation + feed are stable:

- Wire `ConnectionLoopLogo` into splash/onboarding flow.
- Animated launch: connection loop draw + node pulse + wordmark reveal.
- Reduced motion: static mark + fade only.

### UI-07+ — Future phase UI companions

Future UI work is now explicitly tracked in `TASKS.md`:

- `UI-07`: AI match + skill gap delightful UI after Phase 6.
- `UI-08`: Chat interface polish after Phase 7.
- `UI-09`: Notification center polish after Phase 8.
- `UI-10`: Admin/recruiter utility polish after Phase 9.
- `UI-11`: Saved search + alert experience polish after Phase 10.

### Ongoing phase-by-phase UI rule

For every future feature task:

1. Implement logic with architecture rules.
2. Use existing design primitives.
3. If a new component is reusable, put it in `shared/presentation/widgets/`.
4. If it is feature-specific, keep it inside the feature.
5. Avoid hardcoded colors, radii, spacing, shadows, durations.
6. Decide expressiveness level:
   - CRUD/basic: minimal.
   - Core/product-defining: delightful.

## Handoff Reminder

Any model implementing UI should read these first:

1. `CLAUDE.md`
2. `docs/design/JOB_CONNECT_UI_SYSTEM.md`
3. `docs/design/UI_UX_IMPLEMENTATION_ROADMAP.md`
4. `TASKS.md`

Then implement the next unchecked UI task before continuing feature work.
