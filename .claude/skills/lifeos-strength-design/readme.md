# LifeOS Strength — Design System

> **The product name is not final.** `LifeOS` is the repository name and the working label used
> throughout this system. PRD decision **D-Q** dropped it for public use (store collisions);
> shipping candidates are **Datum**, **Rung** and **Ballast**, and gate **BRAND-01** (UK IPO
> classes 9 and 42) is still open. Rename the wordmark in one place — `guidelines/brand-wordmark.card.html`,
> `thumbnail.html` and the two UI kit shells — when the decision lands.

---

## 1. What the product is

A **strength-training log**. One sentence from the brief drives every decision in here:

> **The user is not looking at this screen. They are glancing at it.**

The user is standing at a squat rack between sets, breathing hard, holding a phone in one hand.
They want to record the set they just finished and put the phone away. A standard session —
6 exercises, 18 working sets, all previously performed — must be logged in **under 60 seconds of
cumulative active interaction**, roughly **two seconds per set**. That budget, not taste, decides
layout density, hit-target size and how many taps a control costs.

It is not a coach, a social network or a nutrition tracker. v1.0 is: email auth, five-tab shell,
Home, active workout, exercise catalog, history, progress, settings, and a complete set of system
states. Templates, CSV export and body measurements were cut to v1.0.1. Google/Apple sign-in too.

**Primary persona — Marek/Mariusz, 31.** Trains 3–4×/week, knows progressive overload, trains
somewhere with poor mobile signal, currently uses a spreadsheet. His pains, in order: re-typing
last week's numbers; not being sure the session saved; too many taps; checking progress is harder
than it should be.

### Surfaces in this system

| Surface | Where | Reference size |
|---|---|---|
| Mobile app (PWA, later native shell) | `ui_kits/mobile-app/` | 390 × 844 |
| Desktop app | `ui_kits/desktop/` | 1440 wide, content capped at 1160 |

There is no marketing site in scope, so none is recreated here.

### Sources this system was built from

- **Codebase / docs**: local folder `life/` → `life/lifeosrebuilddocs.zip`, extracted to `docs/`
  (`PRD.md`, `ARCHITECTURE.md`, `PLAN.md`, `DESIGN-BRIEF.md`, `DECISIONS.md`, `reviews/`).
  **`docs/DESIGN-BRIEF.md` is the authority** for everything below; constraint IDs (C-1 … C-10)
  cited in component docs come from its §3.
- **Design mockups** (the colour and layout source): `life/ChatGPT Image … (1).png` and `(2).png`
  → `references/mockup-sheet-a.png`, `references/mockup-sheet-b.png`.
- **Approved photography**: `life/ChatGPT Image … 12_35_49.png` → `assets/imagery/hero-dumbbell.png`,
  plus two dark gym body shots cropped from mockup sheet A.
- **Competitor / moodboard references** (read for direction, never copied): `life/gym.png`
  (HealthPulse neon-green), `life/gym 2.webp` (green-navy fitness), `life/gym3.webp`
  (three dark fitness phones — the brief's highest-rated reference at 9.0), `life/listyle.gif`.
  The brief specifies the blend: **70% dark-fitness-phones, 25% green-navy, 5% other.**
- No Figma file, no component library, no font binaries and **no logo** were provided.

---

## 2. Content fundamentals

**Voice: a trustworthy ledger, not a coach.** The product records what happened and says exactly
where the data is. It never motivates, congratulates or instructs.

| Rule | Do | Don't |
|---|---|---|
| Plain, literal, present tense | "Waiting for connection" | "Oops! Something went wrong 😅" |
| Name the state, then the consequence | "Saved on this device. Waiting for a connection — nothing is lost." | "Syncing…" |
| Never overstate where data lives | "On the server" only when confirmed | "Saved to the cloud" while queued |
| Recall beats instruction | "Last time: 80 kg × 8, 5 days ago" | "Try adding 2.5 kg this week!" |
| Destructive actions name the loss and the recovery | "18 sets and 12,450 kg of volume will be removed. Records are recalculated. This cannot be undone." | "Are you sure?" |
| Empty states say what will appear and how | "Finished sessions land here — volume, records and dates." | "Nothing here yet" |
| No exclamation marks, no confetti, no streak-shaming | — | "Great job!!" / "You broke your streak" |

**Casing.** Sentence case everywhere — labels, headings, buttons. Uppercase with `.04–.08em`
tracking is reserved for two things: the primary action label (`COMPLETE SET`, `RESUME`) and
eyebrow/section labels at 11px (`TODAY`, `LAST WORKOUT`, `PERSONAL RECORDS`).

**Person.** Address the user as *you*; the system speaks as *we* only about its own work
("We'll sync when you're back online"). The greeting uses their first name: "Good morning, Mariusz".

**Emoji: no.** The v1.0 mockups contain one waving hand in an early frame; it was dropped from the
later sheet and should not return. Icons carry that job.

**Numbers.** Always with a unit and, where a comparison is implied, its basis: "12,450 kg",
"+8% vs last week", "102.5 kg estimated 1RM". Weights use one decimal only when the plate maths
needs it (107.5, not 107.50). Dates are written out ("May 10, 2024"), durations as `45:12`.

**Bilingual from the first commit — EN + PL.** Polish is the layout stress case: it runs 20–30%
longer (*Rest → Przerwa*, +100%; *Workout summary → Podsumowanie treningu*, +57%) and its
diacritics (ą, ę) drop below the baseline, so dense numeric rows need the line-height headroom
already built into the type tokens. If a string fits in Polish it fits everywhere.
See `guidelines/type-polish.card.html`.

---

## 3. Visual foundations

**Colour vibe.** A cool near-black world — navy-graphite, not neutral grey, and never pure black
except behind the device. Sampled from the mockups: screen `#070a0f`, card `#0c0f15`,
raised `#12161d`. One accent: **lime `#90d850`**. It is punctuation — the single primary action,
the active set, a record, a chart line. A second, colder accent (blue `#4c8df6`) exists only for
"in transit". Amber warns, red destroys. Two background colours per screen, maximum.

**Colour never carries meaning alone (C-4).** Gym lighting is unreliable. Every state that matters
pairs colour with an icon *and* a word: records show a trophy plus "PR", sync states show a glyph
plus a literal sentence, errors show an alert glyph plus the message.

**Type.** Two families. **Archivo** for display, headings and every numeral — flat, athletic, and
carrying true tabular figures so a column of weights does not jitter. **Manrope** for body, labels
and captions. Display 34/38 at -.02em; body 15/21; caption 11/14 at .06em uppercase. Numerals go
big: 44px for the value being edited, 28px for a metric, 30px for the rest timer, all tabular.
*Both are Google Fonts substitutions — see §7.*

**Spacing.** 4px base. 16px screen gutter, 16px card padding, 12px between stacked cards, 24px
between sections. Interactive minimum 44px (C-5), 52px for set confirmation, 56px for tab bar and
FAB, and 56px steppers inside a live workout.

**Corner radii.** 18px cards, 14px buttons and set rows, 10px inputs, 24px hero/photo cards,
32px sheet tops, full pills for chips, badges and the primary action. Nothing is square.

**Cards** are a surface step plus a 7%-white hairline — no drop shadow. Shadow appears only where
something genuinely floats: sheets, dialogs, and the lime FAB (which carries a lime-tinted glow
rather than a black one). Focus and active states use a lime ring, not a shadow.

**Backgrounds and imagery.** Flat surfaces, no gradients as decoration; the only gradients in the
system are photographic scrims and chart fills. Photography is premium, cinematic, dark athletic
editorial — black/deep-navy/graphite, subject off-centre, generous negative space, no visible
brand logos, no technique demonstration. **Every hero carries `--scrim-strong` or `--scrim-side`**
so cards and copy stay legible; an image with detail edge-to-edge is unusable regardless of
quality. No illustrations, no patterns, no textures, no grain overlay.

**Transparency and blur** are used in exactly one place: the bottom nav and sticky headers, which
sit at 86% surface with an 18px blur so content scrolls under them. Nothing else is translucent.
Long scrolling screens end in a fade-to-surface protection gradient behind the docked set controls
— a capsule would cover input the user needs.

**Motion.** Short, flat, functional: 80ms for a tick, 140ms press, 200ms state change, 320ms sheet.
One curve, `cubic-bezier(.2,0,.2,1)`. **Nothing bounces and nothing celebrates** — no confetti, no
badge animation; a record is a badge, not an event. Press is a 3% scale-down plus a darker fill.
Hover (desktop only) lifts the surface one step; it never changes accent colour. All of it collapses
under `prefers-reduced-motion`.

**Layout rules.** Mobile: 44px status bar, 56px header, content column at 16px gutters, 64px nav
docked with safe-area inset (C-6), set controls docked above it and never overlaying the rows the
user is reading (C-7). Desktop: 248px sidebar carrying all five destinations, content capped at
1160px, set entry in a sticky right rail.

**Charts.** One lime line or bar series on a 6%-white grid, gradient fill fading to nothing, axis
labels at 11px tertiary. Every chart ships a tabular alternative in a `<details>` disclosure (C-9).

---

## 4. Iconography

**Lucide, 2px stroke, 20px default** — 24px in the nav, 16px inline with label text. The source
repository ships **no icon assets** (no font, no sprite, no SVG set), so this is a flagged
substitution chosen to match the line weight and rounded terminals visible in the mockups.

Icons are loaded from CDN (`unpkg.com/lucide-static/icons/<name>.svg`) and tinted through a CSS
mask by the `Icon` component, so a glyph inherits any colour token. Never paste raw SVG into a
design and never draw one by hand.

- **No emoji**, ever, in product UI.
- **No unicode characters used as icons** — no ✓, ✗, →. The one exception is the multiplication
  sign in set notation ("100 kg × 8") and the middle dot as a meta separator ("Barbell · Chest").
- **No exercise illustrations or technique diagrams.** Generated imagery may never demonstrate
  movement (DESIGN-BRIEF §9.5) — a beautifully lit wrong hip hinge is a safety defect. Exercise
  rows use a neutral `dumbbell` glyph on an inset tile until verified instructional media exists.
- Icons that are the sole carrier of meaning get an accessible name; decorative ones are hidden.

Working glyph set: `house dumbbell list history chart-column plus minus check chevron-left
chevron-right chevron-down ellipsis play pause trophy trending-up calendar clock cloud-off wifi-off
refresh-cw rotate-ccw git-merge smartphone download search search-x filter sliders-horizontal
user settings bell mail lock trash-2 circle-alert alert-circle signal wifi battery-full`.

---

## 5. Index

### Root

| File | What |
|---|---|
| `styles.css` | The one stylesheet consumers link — `@import` list only |
| `readme.md` | This document |
| `SKILL.md` | Agent Skills front-matter wrapper |
| `thumbnail.html` | Homepage tile |
| `tokens/` | `fonts` · `colors` · `typography` · `spacing` · `radius` · `elevation` · `motion` · `base` |
| `guidelines/` | 19 foundation specimen cards (Colors, Type, Spacing, Brand) |
| `screens/` | Standalone screen files with their states — see `screens/README.md` |
| `assets/imagery/` | `hero-dumbbell.png` (primary hero), `hero-back-rack.png`, `hero-core-front.png` |
| `references/` | The original mockup sheets and competitor reference, for cross-checking |
| `docs/` | The unmodified project documents extracted from the provided zip |

### Components

**core** — `Button` · `IconButton` · `Icon` · `Card` · `Badge` · `Chip` · `SegmentedControl` ·
`Input` · `Select` · `Stepper`

**fitness** — `SetRow` · `RestTimer` · `SyncBadge` · `PRBadge` · `ExerciseRow` · `StatCard` ·
`WeekDots` · `VolumeBars` · `TrendChart`

**navigation** — `BottomNav` · `ScreenHeader`

**feedback** — `Banner` · `EmptyState` · `ConfirmDialog`

Each component directory holds `<Name>.jsx`, `<Name>.d.ts`, `<Name>.prompt.md` and one
`@dsCard` HTML showing its states.

**Component inventory note.** No component library was provided — the source is a text brief plus
mockups, and the implementation target is Tailwind + shadcn/ui. This inventory is therefore derived
from what the mockups and the §7 screen inventory actually contain, not from a shadcn checklist.
`Icon` is an **intentional addition**: a glyph wrapper is needed because no icon assets exist.
Deliberately absent: Toast (C-3 forbids sync-by-toast — use `Banner`), Avatar, Tabs, Tooltip,
Switch, Checkbox, Radio — the last four belong to Settings screens that have not been designed yet.

### UI kits

| Kit | Screens |
|---|---|
| `ui_kits/mobile-app/` | Sign in · Home (returning + empty) · Active workout · Exercises · Progress · Summary |
| `ui_kits/desktop/` | Dashboard · Active workout · Progress · Exercise catalog |

### Screens (batch 2 — states, not a click-through)

| Directory | Frames |
|---|---|
| `screens/history/` | List · filtered by exercise · **exercise progress over time** · workout detail · editing · delete confirmation · empty |
| `screens/catalog/` | Exercise detail (full, minimal, custom) · custom editor create/edit · validation error · delete confirmation |
| `screens/selector/` | Add-exercise sheet: recent + most used · search results · filters active · no results |
| `screens/auth/` | Sign up (default, invalid, email taken, success) · password reset (request, sent, new password, expired link) |
| `screens/desktop/` | All four groups at 1440, dark and light |

---

## 6. Non-negotiables to design against

Straight from the brief. Breaking one of these is a defect, not a preference.

1. Five bottom destinations, no sixth. Settings is not a tab (C-1, C-2).
2. Sync state is visible on the surface, never only a toast (C-3).
3. Colour alone never carries meaning (C-4).
4. 44px minimum touch target (C-5); safe-area insets designed in (C-6).
5. The rest timer stays visible and never blocks set entry (C-7).
6. Destructive actions confirm explicitly and describe recovery (C-8).
7. Every chart has a tabular alternative (C-9).
8. Polish is the layout test (C-10).
9. Pre-filled values must read as *proposals*, not recorded facts.
10. `queued` reads as normal, not as an error. `draft_local` ≠ `queued`.
11. An update never interrupts an active workout.
12. Dark theme is designed, not an inversion of light.

---

## 7. Substitutions and gaps — please confirm

| Item | What was done | Needs |
|---|---|---|
| **Fonts** | No binaries in source. **Archivo** (display + numerals) and **Manrope** (UI) pulled from Google Fonts, chosen for tabular figures and a flat athletic voice | Licensed brand fonts, or confirmation of these two |
| **Icons** | No icon assets in source. **Lucide** via CDN, masked for tinting | Confirmation, or the real icon set |
| **Logo** | None provided — **none drawn**. The name is set in Archivo ExtraBold with a lime full stop | A real mark, once BRAND-01 resolves the name |
| **Product name** | `LifeOS` used as the working label | The BRAND-01 decision (Datum / Rung / Ballast) |
| **Screens not yet drawn** | Settings and its subsections; set-editor field layouts for bodyweight / timed / distance exercises; system states (fatal error, offline, update available, loading skeletons) | Say which to build next |
| **Photography** | Three approved dark gym images extracted from the provided sheets | The §9.6 shoot list — the *moment of use* (phone in hand between sets) is missing from every asset |
