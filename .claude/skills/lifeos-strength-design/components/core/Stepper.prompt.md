One-line: minus / value / plus control that lets a user change a weight or rep count without a keyboard.

```jsx
<Stepper size="lg" value={105} step={2.5} unit="kg" onChange={setWeight} />
<Stepper value={8} step={1} unit="reps" onChange={setReps} />
```

Targets are 56px at `size="lg"` because the user is holding a barbell collar. Pair with quick-pick `Chip`s for jumps larger than one step.
