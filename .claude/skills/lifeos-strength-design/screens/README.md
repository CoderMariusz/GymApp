# Screens — batch 2

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
