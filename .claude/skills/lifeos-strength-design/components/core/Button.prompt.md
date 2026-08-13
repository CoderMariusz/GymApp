One-line: the system's action control — use `primary` for exactly one action per screen, `secondary` for the rest.

```jsx
<Button variant="primary" size="lg" shape="pill" block uppercase>Complete set</Button>
<Button variant="secondary" size="md" iconLeft="plus">Add exercise</Button>
<Button variant="ghost" size="sm">Skip</Button>
```

Variants: primary (lime, dark label) · secondary (raised graphite, hairline border) · ghost (text only) · danger (red, confirmation dialogs only). Sizes map to the hit-target tokens: md = 44px minimum, lg = 52px for the set-confirmation button. Never place two primary buttons in one view.
