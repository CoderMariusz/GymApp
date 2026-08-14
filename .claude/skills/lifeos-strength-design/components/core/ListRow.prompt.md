# ListRow

Every Settings line is one of these: a navigating row (icon, label, current value, chevron) or a
row that holds a control (a `Switch`, a `Badge`, a small `Button`).

- A navigating row **always states its current value** — the user should not have to open a
  subsection to see what the unit is set to.
- Rows are separate surfaces stacked with an 8px gap under an `Eyebrow`, not a boxed list with
  dividers; the gap keeps the 52px hit target readable in gym lighting.
- `tone="danger"` for sign out, delete local data, delete account. A danger row never navigates
  silently — it opens a `ConfirmDialog` (C-8).
- `disabled` rows keep their value visible and pair with a `Badge` saying why (e.g. "1.0.1").
