One-line: renders a Lucide glyph tinted by any colour token — the only icon primitive in the system; never hand-roll an SVG.

```jsx
<Icon name="dumbbell" size={24} color="var(--action-primary)" />
<Icon name="cloud-off" size={16} title="Offline" />
```

Notes: stroke weight is fixed at Lucide's 2px (mask rendering, so `strokeWidth` cannot be overridden). Decorative icons must stay unlabelled — pass `title` only when the icon is the sole carrier of meaning (DESIGN-BRIEF C-4 requires a text label in that case anyway).
