# UI kit — mobile app (390×844)

The v1.0 phone surface, recreated from `references/mockup-sheet-a.png` / `-b.png` and the screen
inventory in `docs/DESIGN-BRIEF.md` §7. Dark theme, because gyms are dim.

## Files

| File | Surface |
|---|---|
| `index.html` | Interactive click-through in a 390×844 frame |
| `shell.jsx` | Status bar, section label, avatar |
| `SignInScreen.jsx` | Email + password auth over the primary hero |
| `HomeScreen.jsx` | Returning user: repeat last workout, week strip, stats, recent activity, queued-sync banner. `empty` prop renders the new-user state |
| `WorkoutScreen.jsx` | The critical flow: set tables, one-tap confirm, docked stepper + quick-pick chips, rest timer |
| `ExercisesScreen.jsx` | Catalog with search, equipment filters, custom badge, no-results state |
| `ProgressScreen.jsx` | Estimated 1RM trend and volume bars, each with a tabular alternative; PR list |
| `SummaryScreen.jsx` | Records, and the sync progression queued → syncing → saved playing out live |

## Flow

Sign in → Home → **Repeat last workout** → confirm sets → Complete workout → Summary → Home.
Tabs reach Exercises and Progress. Settings is deliberately absent from the tab bar (C-2) — it
opens from the Home avatar, which is a stub here.

## Deliberately not built

Templates, CSV export and body measurements are out of v1.0 (PRD §3.2). Exercise-technique
imagery is out entirely (DESIGN-BRIEF §9.5). Settings subsections, history detail and
password-reset states are listed in the brief but not yet drawn — see the gaps note in the root readme.
