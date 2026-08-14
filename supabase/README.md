# Supabase

**New project (ADR-15).** Nothing is inherited from the previous Flutter implementation —
no schema, no history, no secrets. RLS policies from the old project may be read as a
**reference**, never copy-pasted without passing the A/B/anon matrix in `ARCHITECTURE.md` §13.2.

```
migrations/   the ONLY source of truth for the server schema (§9)
seed/         catalog seed emitted by scripts/catalog/7-build.ts
tests/        constraints, RPC atomicity, idempotency, RLS matrix
functions/    Edge Functions (ai-orchestrator is v1.1; account/export earlier)
```

## Free-tier constraints that are not preferences — §24

- Project **pauses after 7 days without database queries**. There is deliberately no
  keep-alive mechanism (O-09 rejected): a mechanism existing only to dodge a provider's
  free-plan policy is not a product feature. Manual resume is documented in `PLAN.md`.
- **No automatic backups.** `G-BACKUP` requires `supabase db dump` stored off-platform,
  7–14 retained copies, a dump before every risky migration, and a **documented restore
  attempt** — a backup never restored is an assumption, not a safeguard. This gate blocks
  the first external tester.
- Exercise catalog ships in the static bundle, not Storage. Storage is for avatars only.
