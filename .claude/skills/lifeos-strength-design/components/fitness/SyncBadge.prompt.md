One-line: shows where a workout actually lives — device, queue, in transit, server — in one pill.

```jsx
<SyncBadge state="draft_local" />
<SyncBadge state="queued" label="Oczekiwanie na połączenie" />
```

Never say "saved to the cloud" while the data is only on the device. `draft_local` means the session is still running and nothing should have been sent; `queued` is normal, not an error — keep it neutral grey, never amber or red. Requires the `lifeos-spin` keyframe for the syncing state.
