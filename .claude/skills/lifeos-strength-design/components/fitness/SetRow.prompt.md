One-line: a single set in the workout table, in one of three states — the distinction between a *proposal* and a *recorded fact* is the whole point.

```jsx
<SetRow index={1} weight={100} reps={8} rir={2} rest="2:00" state="logged" />
<SetRow index={3} weight={105} reps={8} rir={2} rest="1:45" state="active" />
<SetRow index={4} weight={105} reps={8} rir={2} rest="-" state="proposed" />
<SetRow index={1} weight={60} reps={10} warmup state="logged" />
```

Proposed values are grey with an empty ring; logged values are white with a lime tick. Never colour-only: the tick and the value weight both change.
