One-line: the fixed bottom shell — Home, Workout, centre start action, Exercises, Progress.

```jsx
<BottomNav active="workout" onSelect={go} onAdd={startWorkout} />
```

Never add a sixth destination and never put Settings here — it lives behind the Home avatar. The bar is translucent with a blur so content scrolls under it, and it respects the bottom safe-area inset.
