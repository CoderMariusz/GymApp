One-line: persistent inline notice for sync, offline and update-available states — the durable alternative to a toast.

```jsx
<Banner icon="cloud-off" title="2 workouts waiting to sync" description="We'll sync when you're back online." onClick={openQueue} />
<Banner icon="download" tone="info" title="Update available" description="Installs after your workout." />
```

Queued sync uses the neutral tone: it is the expected state in a gym basement, not a warning. Reserve `danger` for conflicts that genuinely need a decision.
