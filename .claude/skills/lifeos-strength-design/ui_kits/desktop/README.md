# UI kit — desktop (1440)

The 1440 reference required by `docs/DESIGN-BRIEF.md` §12. Not a stretched phone: a persistent
248px sidebar carries all five destinations plus the profile/settings entry, and the workout view
splits into a scrolling exercise column and a sticky set-entry rail.

## Files

| File | Surface |
|---|---|
| `index.html` | Click-through shell; sidebar switches views |
| `DesktopShell.jsx` | Sidebar nav, wordmark, sync state, profile row — plus the exercise catalog view |
| `DashboardView.jsx` | Repeat-last-workout hero, stats, week strip, queued banner, activity and records columns |
| `WorkoutView.jsx` | Set tables left, sticky current-set panel + rest timer + session totals right |
| `ProgressView.jsx` | 1RM trend with tabular alternative, weekly volume, top lifts |

## What desktop changes

- Five destinations move from the bottom bar to the sidebar; the centre FAB becomes a
  full-width **Start workout** button.
- Set entry gets a permanent rail instead of a docked strip — no overlay, ever.
- Content is capped at 1160px so line lengths stay readable at 1440 and above.
