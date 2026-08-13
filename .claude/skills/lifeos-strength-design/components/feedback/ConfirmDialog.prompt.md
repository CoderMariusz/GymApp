One-line: explicit confirmation for destructive actions, with the consequence and the recovery path spelled out.

```jsx
<ConfirmDialog
  title="Delete this workout?"
  description="18 sets and 12,450 kg of volume will be removed."
  recovery="Personal records derived from this session are recalculated. This cannot be undone."
  confirmLabel="Delete workout" />
```

Cancel sits left and is the safe default. Never auto-dismiss; never rely on an undo toast.
