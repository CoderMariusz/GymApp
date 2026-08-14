# Screens — batches 2 and 3

Standalone screen files (not the clickable kits) covering the state inventory in
`docs/DESIGN-BRIEF.md` §7. Every frame is a real render of the design-system components;
each file shows the default plus its key states, dark first, then light pairs for the states
where the light theme changes something.

| File | Group | Frames |
|---|---|---|
| `history/index.html` | History, mobile | list · filtered by exercise · exercise progress over time · workout detail · editing · delete confirmation · empty · light pairs |
| `catalog/index.html` | Exercise detail, mobile | full content · minimal content · custom · create · validation error · edit · delete confirmation · light pairs |
| `selector/index.html` | Exercise selector, mobile | recent + most used · search results · filters active · no results · light pairs |
| `auth/index.html` | Auth, mobile | sign up · validation error · email taken · success · reset request · sent · new password · expired link · light pairs |
| `desktop/index.html` | All four, 1440 | history master/detail · delete · catalog + detail · custom editor · selector modal · auth split · light pairs |
| `settings/index.html` | Settings, mobile | root · account · units & display · workout defaults · notifications (+ blocked by system) · data & sync · sign out · delete account · light pairs |
| `set-editor/index.html` | Set entry, mobile | weight × reps · bodyweight · timed (before + running) · distance · light pairs |
| `system/index.html` | System states, mobile | fatal error · offline browsing · offline logging · update available · update deferred · loading skeletons (Home, history, detail) · light pairs |
| `_frame.jsx` | — | Shared frame, status bar, sheet, overlay and list-row helpers |

## Decisions taken here

- **History filters and per-exercise progress are the same screen family.** Filtering the list by
  exercise and opening that exercise's trend over time are two steps of one flow, so the filter
  chip row leads into the *Bench Press — history* screen with the 1RM chart, a per-session table,
  and every session listed underneath. Both carry the tabular alternative required by C-9.
- **Numeric entry stays stepper + quick-pick chips** as confirmed; nothing in this batch introduces
  a second numeric mechanism.
- **The selector is a bottom sheet on mobile, a centred modal on desktop** — the workout stays
  visible behind it in both, because the user is mid-session.
- **Password reset never reveals whether an account exists** ("If an account exists for …").
- **Custom exercise `tracks` chips are labelled as layout-changing** — they decide which of the
  four set-editor layouts that exercise gets.

## Decisions taken in batch 3

- **Settings is reached from the user's name on Home, never from the tab bar** (C-1, C-2). Every
  navigating row states its current value, so the root screen answers "what is my unit set to?"
  without opening anything.
- **Four set-editor layouts, chosen by what the exercise tracks** — weight × reps, reps + added
  weight, duration + load, distance + duration. The docked entry, the rest timer and the primary
  action stay in identical positions across all four; only the columns and the steppers change, so
  the two-second-per-set budget survives a change of exercise type.
- **Pace is calculated, never typed.** Any value the system can derive is shown read-only.
- **Offline is two screens, not one.** Browsing degrades (server history unavailable, local 30
  sessions shown); logging does not degrade at all. Both name where the data is (C-3).
- **An update is offered only when the app is idle.** Mid-workout it becomes a quiet info banner
  that states when it will install, and it never takes the primary action slot.
- **Skeletons mirror the real card heights and row counts**, so nothing shifts when data lands. A
  wait longer than about three seconds stops being a skeleton and becomes a banner that names it.
- **Fatal error has one way out and no bottom nav.** It states where the unsaved workout is before
  it offers the reload, and the error id is copyable.
