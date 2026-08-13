One-line: 56px screen header; title centres when a back control is present, otherwise it sits left with the avatar.

```jsx
<ScreenHeader title="Workout" onBack={back} right={<SyncBadge state="draft_local" compact />} />
```

Respects the top safe-area inset. Use `sticky` on long scrolling screens (catalog, history).
