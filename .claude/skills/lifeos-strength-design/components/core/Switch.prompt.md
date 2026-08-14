# Switch

A setting that takes effect immediately. Used only inside `ListRow` in Settings — never as a
form field the user has to submit.

- The knob position plus its check glyph state the value; the lime fill is reinforcement, not the
  signal (C-4). Where the value needs a word, put it in the row's `value` prop.
- 52 x 32 track inside a 52px-tall row, so the whole row stays above the 44px minimum (C-5).
- Never use a switch for something destructive or something that costs a network round trip; those
  are buttons with confirmation.
