One-line: list row for the exercise catalog, the exercise selector, history and personal records.

```jsx
<ExerciseRow name="Bench Press" meta="Barbell · Chest" onClick={pick} />
<ExerciseRow name="Squat" meta="1RM · May 8, 2024" right={<span className="num">140 kg</span>} />
```

The leading tile is a Lucide glyph on an inset surface — the system ships no exercise illustrations, and per DESIGN-BRIEF §9.5 generated imagery may never demonstrate technique.
