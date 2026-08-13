One-line: the surface container everything in the app sits on — 18px radius, hairline border, no drop shadow.

```jsx
<Card tone="default" pad="default">…</Card>
<Card tone="accent" pad="tight">active set</Card>
```

Cards separate by surface step and a 7%-white hairline, never by shadow. Use `radius="xl"` for hero/photo cards, `tone="accent"` only for the currently active set or exercise.
