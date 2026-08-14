# AgentOS evaluation

`ARCHITECTURE.md` §20, `PLAN.md` §5–6. Product success and AgentOS success are separate
measures: a provider outage or a store review is **not** evidence that the builder cannot
implement a feature.

```
task-specs/        frozen TASK_SPEC per scored task (schema must not change between runs)
fixtures/          pre-authenticated, isolated test state
design-baselines/  immutable, hashable frames for the visual gate
```

No production auth bypass is compiled into a release build. CI asserts the absence of
eval-only routes and flags (§12.4).

**Frozen order** (D-S, and the T01/T02 swap agreed 2026-08-14 — T01's settings screens are
the only ones the design system has not drawn):

`T02 → T01 → T04 → T07 → T05 → T06`, then in v1.0.1 `T03 → T08`.

Nothing scored starts before `G-DESIGN-SYSTEM` is green and M0 has stayed green for 48 h.
