# JobConnect UI System

## 1. Design North Star

**Modern Social Productivity Design**

JobConnect should feel like a premium mobile social feed built for career progress: **Instagram / Threads familiarity**, **Linear clarity**, and **Raycast speed**, wrapped in **Cinematic Minimalism**.

The app is **Job Seeker-first**. The emotional goal is not “corporate recruiting software”; it is:

> “I open this app and immediately feel that new opportunities are moving toward me.”

## 2. Style Keywords

- Modern Social Productivity Design
- Cinematic Minimalism UI/UX
- Hybrid Social-Productivity Interface
- Instagram × Linear × Raycast inspired
- Clean Cinematic Recruiter Experience
- Sophisticated minimalism with cinematic touch
- Social-inspired yet productivity-focused UI
- Premium dark/light career discovery
- Fluid, immersive, fast, lightweight

## 3. Product Personality

### Social-first
- Vertical feed like Threads / Instagram.
- Familiar scrolling rhythm.
- Cards feel human, not database-like.
- Quick save, apply, share, and follow actions.

### Productivity-focused
- Search behaves like Spotlight / Raycast.
- Filters are quick, lightweight, and always near the user.
- Information hierarchy is sharp and functional.
- No decorative complexity inside forms or utility flows.

### Professional
- Hiring content remains credible.
- Salary, company, role, skills, and status are always readable.
- Recruiter-facing screens use the same system with less glow and more structure.

## 4. Core Interaction Model

**Feed-first + Spotlight search**

The home experience:

1. Cinematic greeting/header.
2. Raycast-style spotlight search.
3. Social category tabs: For You, Following, Remote, Intern, Recent.
4. Compact AI insight capsule.
5. Mixed vertical job feed.
6. Bottom navigation.

Recommended bottom navigation:

- Jobs
- Saved
- Applications
- Messages
- Profile

## 5. Color System

### Chosen direction

**Blue × Violet Hybrid**

Blue provides trust and productivity. Violet provides AI/cinematic emotion. Cyan is a rare focus/glow accent.

### Dark default palette

| Token | Color | Use |
|---|---:|---|
| `background` | `#070A12` | Main dark canvas |
| `backgroundElevated` | `#0A0F1D` | Layered dark gradient base |
| `surface` | `#101522` | Cards, app bars, bottom nav |
| `surfaceGlass` | `rgba(255,255,255,0.065)` | Glass panels/cards |
| `outline` | `rgba(255,255,255,0.105)` | Borders/dividers |
| `textPrimary` | `#F8FAFC` | Main text |
| `textSecondary` | `rgba(248,250,252,0.66)` | Supporting text |
| `textTertiary` | `rgba(248,250,252,0.43)` | Metadata |
| `primary` | `#3B82F6` | Primary CTA, search, selected states |
| `primarySoft` | `#38BDF8` | Blue glow/highlight |
| `aiAccent` | `#8B5CF6` | AI insights, match explanation |
| `aiAccentStrong` | `#D946EF` | Rare cinematic AI gradient |
| `focusGlow` | `#22D3EE` | Search focus, command glow, shimmer |
| `success` | `#34D399` | Positive status |
| `warning` | `#FBBF24` | Missing skill, warning |
| `error` | `#FB7185` | Error/destructive state |

### Light refresh palette

Light mode is not a fallback. It is a **refreshing premium mode**.

| Token | Color | Use |
|---|---:|---|
| `backgroundLight` | `#F8FAFC` | Main light canvas |
| `backgroundLightTint` | `#EEF2FF` | Blue/violet atmospheric tint |
| `surfaceLight` | `#FFFFFF` | Cards and sheets |
| `surfaceLightSoft` | `#F1F5F9` | Secondary surfaces |
| `outlineLight` | `#E2E8F0` | Borders/dividers |
| `textPrimaryLight` | `#0F172A` | Main text |
| `textSecondaryLight` | `#475569` | Supporting text |
| `primaryLight` | `#2563EB` | Primary CTA |
| `aiAccentLight` | `#7C3AED` | AI moments |
| `focusGlowLight` | `#0891B2` | Search/focus accent |

### Color usage rules

- Blue is the only normal primary action color.
- Violet is reserved for AI/recommendation moments.
- Cyan is rare: search focus, active command, hero shimmer.
- 80-90% of each screen should be neutral surface and readable text.
- If everything glows, nothing feels premium.
- Status colors must include icon/text, never color alone.

## 6. Typography

### Chosen pairing

**Space Grotesk display + Inter UI/body**

Use Space Grotesk as cinematic spice, not the whole meal. Most UI remains Inter.

| Role | Font | Weight | Size guidance | Use |
|---|---|---:|---:|---|
| Display | Space Grotesk | 700 | 36-48sp mobile hero | Splash, onboarding, hero moments |
| Screen title | Inter | 800/900 | 28-34sp | Main page title |
| Section title | Inter | 800 | 20-24sp | Feed sections, form sections |
| Card title | Inter | 700 | 16-18sp | Job title, company title |
| Body | Inter | 400/500 | 14-16sp | Descriptions, details |
| Metadata | Inter | 500/600 | 12-13sp | Salary, location, tags |
| Button/chip | Inter | 700 | 12-14sp | Actions and labels |

Flutter note: because adding packages should be controlled, prefer bundling `.ttf` font files as assets unless the team approves `google_fonts`.

## 7. Spacing System

Use a 4/8dp rhythm.

| Token | Value | Use |
|---|---:|---|
| `space1` | 4dp | Tiny alignment, dense icon gaps |
| `space2` | 8dp | Label/icon gaps, compact padding |
| `space3` | 12dp | Chip padding, small card internals |
| `space4` | 16dp | Default card padding |
| `space5` | 20dp | Feed card internal rhythm |
| `space6` | 24dp | Screen horizontal padding, section spacing |
| `space8` | 32dp | Major vertical rhythm |
| `space10` | 40dp | Hero/large separation |
| `space12` | 48dp | Onboarding/splash composition |

Touch target minimum: **48dp** for important controls.

## 8. Radius & Elevation

### Radius

| Token | Value | Use |
|---|---:|---|
| `radiusSm` | 12dp | Small chips, badges |
| `radiusMd` | 16dp | Buttons, avatars |
| `radiusLg` | 24dp | Cards, search fields |
| `radiusXl` | 32dp | Featured cards, sheets |
| `radius2xl` | 40dp | Phone mockups, hero panels |

### Elevation

- Persistent lists: subtle surface separation and border.
- Featured cards: soft cinematic shadow.
- Search overlay/sheets: stronger blur + elevation.
- Forms: minimal shadows, prioritize readability.

Recommended shadow examples:

- Card: `0 16 50 rgba(0,0,0,.18)`
- Featured card: `0 28 90 rgba(59,130,246,.14)`
- Overlay: `0 34 100 rgba(0,0,0,.46)`

## 9. Expressiveness System

**Premium Expressive, Strictly Curated**

Use A-level cinematic ingredients with B-level discipline.

### Signature moments, expressive allowed

- Splash / launch animation
- Onboarding hero
- Job Seeker home header
- AI match insight
- Skill gap analysis
- Application success
- Profile completion milestone
- Empty states

Allowed:
- richer gradients
- glow
- glassmorphism
- subtle parallax
- shimmer
- cinematic shadows

### Core browsing, controlled

- Job feed
- Search results
- Saved jobs
- Applications list
- Company cards

Allowed:
- subtle glass
- light shadow
- tiny press lift
- match score glow only

Avoid:
- every card glowing
- animated backgrounds behind long lists
- excessive gradient text

### Utility/forms, minimal

- Login/register
- Resume builder
- Apply form
- Profile edit
- Recruiter job creation

Allowed:
- clean surfaces
- focused blue border
- subtle elevation
- one accent CTA

Avoid:
- shimmer everywhere
- glass inputs if readability suffers
- decorative animation

## 10. Motion System

Follow Material Motion principles: continuity, responsiveness, clarity.

| Token | Duration | Use |
|---|---:|---|
| `instant` | 80-120ms | Tap feedback |
| `fast` | 150-180ms | Button/chip state change |
| `base` | 220-260ms | Card lift, small reveal |
| `route` | 320-400ms | Card-to-detail transition |
| `splash` | 900-1400ms | Launch identity |
| `stagger` | 30-45ms | Feed item entrance |

### Motion rules

- Animate transform and opacity only where possible.
- Shared element transition from job card to job detail.
- Apply button: compress, glow, haptic, loading, success.
- Feed reveal: opacity + translateY, staggered lightly.
- Spotlight search: fade/scale from search field, instant results.
- Reduced motion: disable parallax, shimmer, particles, and stagger.

## 11. Mixed Feed Card System

### Feed composition

- First 1-2 roles: large cinematic/featured cards.
- Normal feed: clean social job cards.
- AI recommendation: violet insight card inserted naturally.
- Company highlight: editorial card, occasional.
- Saved/applied status: small badges, not large blocks.

### Job card content hierarchy

1. Company logo/avatar.
2. Match score or status badge.
3. Job title.
4. Company, location, work mode.
5. Salary if visible.
6. Skill tags / skill gap.
7. Save + Apply quick actions.

### Card rules

- Job title must be readable before visual effects.
- Match score glow is allowed, but only one glowing element per card.
- Cards can lift on press, but must not shift surrounding layout.
- Long descriptions belong on detail page, not feed card.

## 12. Spotlight Search

Search is the productivity layer.

### Behavior

- Accessible from home header and optionally bottom nav/search affordance.
- Opens fast overlay from the search field.
- Supports jobs, skills, companies, locations, filters.
- Shows recent searches and suggested commands.

### Visual style

- Glass/dark overlay in dark mode.
- Clean white/blur panel in light mode.
- Cyan focus glow used here more than anywhere else.
- Results are dense but readable.

## 13. Logo & Splash System

### Chosen logo direction

**Dual-mode logo: minimal static, cinematic animated**

### Static logo

- Minimal geometric connection-loop mark.
- Works as app icon, app bar mark, profile/avatar placeholder.
- Works in single color.
- No heavy glow.

### Animated splash

**Connection-loop symbol + JobConnect wordmark reveal**

Concept:

> A glowing blue-violet career path draws itself into a loop, connects two nodes, then reveals the JobConnect wordmark.

Meaning:

- Job Seeker ↔ Recruiter
- Career path
- AI matching
- Connection
- Forward motion

Sequence:

1. Background appears in current theme.
2. Thin cyan/blue stroke begins drawing a circular path.
3. Violet connection node pulses.
4. Loop completes with spring easing.
5. `JobConnect` wordmark fades/slides in.
6. Symbol scales down or dissolves into the home feed header/search glow.

Implementation note for Flutter:

- Use `CustomPainter` for the loop stroke.
- Animate with `AnimationController` and `PathMetric.extractPath`.
- Use `ShaderMask` or gradient paint for blue/violet/cyan stroke.
- Respect reduced motion: show static logo + fade only.

## 14. Component Principles

### Buttons

- One primary CTA per screen.
- Primary: blue gradient or solid blue depending on screen expressiveness.
- Secondary: neutral glass/surface.
- Destructive: red, visually separated.
- Loading state always visible.

### Chips

- Blue chips: filters/selected states.
- Violet chips: AI tags.
- Cyan chips: search/focus rare states.
- Neutral chips: metadata.

### Bottom navigation

- 5 items maximum.
- Icon + label.
- Active state uses blue surface highlight.
- Keep reachable above safe area.

### Sheets/dialogs

- Dark: glass/surface elevated.
- Light: clean white surface with subtle border.
- Forms in sheets should prioritize clarity over glass.

## 15. Accessibility & Performance Rules

- Text contrast: at least WCAG AA.
- Touch targets: minimum 48dp for core actions.
- Do not rely on color alone for status.
- Support system text scaling.
- Respect reduced motion.
- Avoid heavy blur behind long scrolling lists.
- Shimmer/skeleton only during loading, not as ambient decoration.
- Keep animations interruptible and under 400ms except splash.

## 16. Implementation Roadmap

1. Create Flutter theme tokens:
   - `AppColors`
   - `AppTextStyles`
   - `AppSpacing`
   - `AppRadii`
   - `AppDurations`
2. Add bundled fonts:
   - Inter
   - Space Grotesk
3. Build reusable primitives:
   - `JobConnectScaffold`
   - `GlassSurface`
   - `SpotlightSearchBar`
   - `JobFeedCard`
   - `FeaturedJobCard`
   - `AiInsightCard`
   - `ConnectionLoopLogo`
4. Implement splash animation.
5. Redesign Job Seeker home/feed first.
6. Apply system to job detail and apply flow.
7. Reduce effects for recruiter/admin utility screens.
