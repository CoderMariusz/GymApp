# Catalog build pipeline

`ARCHITECTURE.md` §10. Nothing here is implemented yet — the content track (C0–C5 in
`PLAN.md` §4) has not started, and `G-LIC` is open.

```
0-snapshot.ts   pin upstream repo + commit
1-select.ts     choose 200–250 movements
2-normalize.ts  normalise source fields
3-map-taxonomy.ts  movement_pattern, tracks, rest defaults
4-merge-curated.ts curated top 50 (form tips, common mistakes)
5-translate.ts  EN → PL
6-media.ts      REFUSES to package source photos without a machine-readable
                `media-approved` provenance artefact (§10.3)
7-build.ts      emits static client catalog AND Supabase seed from the SAME
                normalised object, so exercise UUIDs are identical (§10.4)
8-validate.ts   IDs stable, required fields, both locales, no unapproved media,
                checksum + version
```

**Two outputs, one source object.** If the static catalog and the seed are generated
separately, their UUIDs drift and every `workout_exercises.exercise_id` breaks. SPIKE-06
exists to prove they match.
