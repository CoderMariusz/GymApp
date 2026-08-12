# LifeOS — Architecture

**Wersja:** 1.2 — po decyzjach właściciela z 2026-08-12  
**Data:** 2026-08-12  
**Status:** READY — po `G-LIC` i spike'ach M0  
**Stack:** Next.js + React + TypeScript · Supabase · PWA-first · Capacitor v1.1  
**Powiązane:** `01PRD_REVIEWED.md`, `03IMPLEMENTATIONPLAN_REVIEWED.md`

> Architektura jest kontraktem implementacyjnym. PRD mówi *co* ma działać; ten dokument określa granice systemu i invariants, których Agent OS/developer nie może lokalnie „uprościć”.

---

## 0. Najważniejsze korekty po red-team review

1. **Offline workout completion jest v1.0**, ale nie budujemy jeszcze uniwersalnego silnika synchronizacji wszystkich tabel.
2. Aktywny trening i kolejka zapisu są w **IndexedDB/Dexie**, nie w `localStorage`.
3. Workout zapisuje się na serwer **atomowo** jednym command/RPC, z client-generated IDs i idempotency key.
4. `navigator.onLine` jest tylko wskazówką. Nie jest źródłem prawdy o dostępności serwera.
5. Generic v1.1 sync **nie używa LWW po server `updated_at`**. Używa optimistic concurrency (`version`/`base_version`) i polityki konfliktu per encja.
6. TanStack Query cache jest cache'em, nie „źródłem prawdy”.
7. Static export **nie oznacza braku Server Components**; mogą wykonać się w buildzie. Zakazane są funkcje wymagające request-time Next server/runtime.
8. `@supabase/ssr` usunięte z browser-only app. Auth klienta używa `@supabase/supabase-js`, PKCE i jawnych redirect adapters.
9. `free-exercise-db` ma stabilne ID mapowane do tych samych rekordów w static catalog i PostgreSQL; source photos są wyłączone do potwierdzenia praw.
10. PR/volume nie są drugim niezależnym źródłem prawdy; są wyprowadzane z setów.
11. Dodano missing `workout_template_exercises`.
12. RLS ze starego projektu może być **referencją**, nigdy copy-paste bez testu A/B/anon.
13. Sentry/logging ma redaction health/mental content.
14. AgentOS Evaluation Profile izoluje external provisioning od capability score.

---

## 1. Architecture Decision Records

| ID | Decyzja | Status | Uzasadnienie / skutek |
|---|---|---|---|
| ADR-01 | Next.js App Router + React + strict TypeScript | Accepted | dojrzały web stack, static export, wspólna baza dla PWA/Capacitor |
| ADR-02 | `output: 'export'` dla aplikacji | Accepted | Capacitor może pakować static assets; brak zależności od Node request runtime |
| ADR-03 | Supabase Auth + PostgreSQL + RLS + Edge Functions/RPC | Accepted | jeden backend; silne granice danych użytkownika |
| ADR-04 | Capacitor w v1.1 | Accepted | native shell, notifications/haptics/storage/store distribution |
| ADR-05 | TanStack Query dla remote server state | Accepted | fetch/cache/retry; persisted cache jako convenience |
| ADR-06 | Dexie/IndexedDB dla durable local domain state | **Changed** | active workout + outbox + catalog; localStorage nie jest wystarczającym durable store |
| ADR-07 | Server canonical for synced records; local draft/outbox canonical only while unsynced | **Clarified** | eliminuje niejasne „cache jako źródło prawdy” |
| ADR-08 | Tailwind + shadcn/ui | Accepted | source-owned components, design tokens, accessibility control |
| ADR-09 | Zod at app boundaries | Accepted | runtime validation formularzy, importów, edge output; DB schema nadal canonical dla persistence |
| ADR-10 | Serwist service worker | Accepted, verify at M0 | precache/app-shell/runtime caching; pinned supported version |
| ADR-11 | next-intl, locale prefix, static-compatible routing | Accepted | EN/PL bez middleware dependence |
| ADR-12 | AI only through Supabase Edge Function | Accepted v1.1 | secret/rate/cost/schema boundary |
| ADR-13 | End-to-end encryption postponed | Accepted | poza v1.x |
| ADR-14 | Single app repository/package | Accepted | nie dzielimy bez drugiego realnego consumer |
| ADR-15 | New Supabase project | Accepted | zero inherited schema/history/secrets |
| ADR-16 | `free-exercise-db` for base data; media independently gated | **Changed** | repo/data license != proven photo provenance |
| ADR-17 | **Offline workout commit in v1.0** | Proposed-required | primary P1 use case |
| ADR-18 | Aggregate `CommitWorkout` command + atomic server transaction | **New/required** | eliminuje orphan sets i częściowy zapis |
| ADR-19 | Client UUIDv7 for user records; deterministic UUIDv5 for system catalog | **New/required** | offline creation + identical catalog IDs local/server |
| ADR-20 | Generic sync uses row version / base_version, not timestamp LWW | **New/required v1.1** | delayed offline mutation nie może nadpisać nowszego stanu tylko dlatego, że dotarła później |
| ADR-21 | `@supabase/supabase-js` browser client; no `@supabase/ssr` in app runtime | **Changed** | static browser app nie ma SSR auth layer |
| ADR-22 | Product auth and AgentOS eval auth are separate concerns | **New** | provider provisioning does not contaminate benchmark |
| ADR-23 | First-party minimal product metrics derived primarily from functional data | **New** | avoid unnecessary sensitive analytics payloads |
| ADR-24 | Exact store/payment policy rechecked at implementation time | **New** | rules are region/version dependent and v2 is far away |
| ADR-25 | **Wyłącznie darmowe progi usług w v1.0** | **New** | decyzja D-T. Konsekwencje: katalog ćwiczeń jest częścią paczki statycznej, nie Supabase Storage; maksymalnie dwa projekty Supabase (produkcja + środowisko benchmarku); **projekt wstrzymuje się po 7 dniach bez zapytań do bazy** i wymaga obsługi — patrz §24 |
| ADR-26 | **Logowanie wyłącznie e-mailem z hasłem w v1.0** | **New** | decyzja D-S. Google i Apple przeniesione do v1.0.1. `lib/auth/` zachowuje warstwę adapterów z §12.3, żeby dołożenie providerów było podmianą, nie przebudową |
| ADR-27 | **Szablony treningów poza v1.0** | **New** | decyzja D-S. Tabele `workout_templates` i `workout_template_exercises` **nie powstają w v1.0**. `workouts.template_id` pozostaje w schemacie jako pole opcjonalne bez klucza obcego do czasu v1.0.1 — dzięki temu migracja nie wymaga przebudowy tabeli treningów |

**Change control:** ADR change is committed before code that depends on it. Status: `proposed → accepted → implemented → superseded`.

---

## 2. Runtime topology

```text
                    ┌─────────────────────────────┐
                    │ Static host / CDN           │
                    │ HTML + JS + CSS + catalog   │
                    └──────────────┬──────────────┘
                                   │
                         install / fetch assets
                                   │
┌──────────────────────────────────▼─────────────────────────────────┐
│ Browser / Capacitor WebView                                        │
│                                                                    │
│ Next/React UI                                                      │
│ ├─ TanStack Query ── remote query cache                            │
│ ├─ Zustand ───────── ephemeral UI state only                       │
│ ├─ Dexie/IndexedDB                                                 │
│ │  ├─ catalog                                                      │
│ │  ├─ active_workout_draft                                         │
│ │  ├─ sync_outbox                                                  │
│ │  └─ optional query persister                                     │
│ └─ lib/mutations ─── only domain-write gateway                     │
└───────────────┬──────────────────────────┬─────────────────────────┘
                │ Supabase client          │ AI / privileged ops
                │                          │
        ┌───────▼──────────┐       ┌───────▼────────────┐
        │ Supabase Auth    │       │ Edge Functions     │
        │ PostgREST / RPC  │       │ ai-orchestrator    │
        └───────┬──────────┘       │ account/export     │
                │                  └────────┬───────────┘
                └──────────────┬────────────┘
                               ▼
                      PostgreSQL + RLS
```

### 2.1 Trust boundaries

- **Client is untrusted.** It may propose IDs/payloads; server validates auth, ownership, constraints and schema.
- RLS is authorization. Route guards are UX.
- Service-role/API provider keys exist only in server-side secrets.
- Local IndexedDB protects against accidental connectivity/reload loss, **not against a malicious device owner**.
- Mental/health raw text never enters ordinary telemetry.

---

## 3. Static export — exact constraints

`output: 'export'` produces static assets. Next.js Server Components may be executed at **build time** if they do not require request-time dynamic server features.

**Allowed:**
- file-based routes known at build,
- build-time data/constants,
- Client Components,
- static Server Components,
- static metadata/manifest,
- browser calls to Supabase,
- external Edge Functions.

**Do not depend on:**
- Next API routes requiring Node at runtime,
- middleware/proxy for locale/auth,
- request cookies/headers in a server-rendered route,
- dynamic server actions,
- request-time image optimization,
- rewrite-dependent localized pathnames.

### 3.1 Internationalization

Use locale-prefixed static paths: `/en/...`, `/pl/...`.

Because static export has no middleware locale detection:
- first landing can use a tiny client redirect/chooser at root or explicit locale links,
- supported locales are generated statically,
- `next-intl` config must stay compatible with static rendering,
- no critical business routing depends on middleware.

### 3.2 Images

Next request-time image optimizer is unavailable in static export. Project-owned images are preprocessed at build:
- deterministic filenames,
- WebP/AVIF where supported by pipeline,
- explicit width/height,
- responsive `<picture>`/static image strategy.

---

## 4. Repository structure

```text
/
├── app/
│   ├── [locale]/
│   │   ├── (auth)/
│   │   ├── (app)/
│   │   │   ├── layout.tsx
│   │   │   ├── dashboard/
│   │   │   ├── workout/
│   │   │   ├── exercises/
│   │   │   ├── templates/
│   │   │   ├── history/
│   │   │   ├── progress/
│   │   │   └── settings/
│   │   └── layout.tsx
│   └── manifest.ts
│
├── features/
│   ├── auth/
│   ├── exercises/
│   ├── workouts/
│   ├── templates/
│   ├── history/
│   ├── progress/
│   ├── measurements/
│   ├── settings/
│   ├── life-coach/          # v1.1
│   └── mind/                # v1.2
│
├── lib/
│   ├── supabase/
│   ├── local-db/
│   ├── mutations/
│   ├── sync/
│   ├── auth/
│   ├── i18n/
│   ├── format/
│   ├── analytics/
│   └── errors/
│
├── components/
│   ├── ui/
│   └── system/
├── messages/
├── data/
│   └── catalog/
├── scripts/
│   └── catalog/
├── supabase/
│   ├── migrations/
│   ├── seed/
│   ├── tests/
│   └── functions/
├── e2e/
├── eval/
│   ├── task-specs/
│   ├── fixtures/
│   └── design-baselines/
└── docs/
```

### 4.1 Feature boundary

Public imports cross feature boundaries through `features/<feature>/index.ts` or an explicit `api/` contract. A component in `history` nie importuje plików wewnętrznych `workouts/components/*`.

Enforce with ESLint boundaries.

### 4.2 State ownership

- **TanStack Query:** remote server state and read cache.
- **Dexie:** durable local domain state (catalog, active workout, outbox).
- **Zustand:** transient interaction state (open sheet, selected tab, in-memory view state); it may mirror a draft but is never its only durable copy.
- **React local state:** component-only state.
- **PostgreSQL:** canonical synced domain records.

---

## 5. Local data architecture

### 5.1 Dexie schema v1.0

```text
catalog_exercises
catalog_translations
catalog_meta

active_workout_drafts
  id
  user_id
  started_at
  template_id?
  payload
  revision
  updated_at_local

sync_outbox
  mutation_id
  user_id
  mutation_type
  payload
  status           queued | sending | failed | attention
  attempt_count
  next_attempt_at
  created_at_local
  last_error_code?

local_meta
  key
  value
```

`active_workout_drafts.payload` może być nested JSON, bo lokalnie jest agregatem odtwarzanym jako całość i nie wykonujemy po nim analitycznych zapytań. Server schema pozostaje znormalizowany.

### 5.2 Draft write contract

Każda zmiana set/exercise:
1. update UI,
2. write draft transactionally to Dexie,
3. only then show durable-local save state.

Debounce może łączyć bardzo szybkie zmiany, ale:
- flush on `visibilitychange`,
- flush on workout complete,
- deterministic recovery test kills page between edits.

### 5.3 No `localStorage` for workout data

`localStorage` pozostaje dopuszczalne dla małych non-sensitive UI hints, nie dla aktywnego treningu ani outbox.

---

## 6. Mutation gateway

**Żaden feature nie zapisuje bezpośrednio do Supabase.**

```ts
type MutationEnvelope<TPayload> = {
  mutationId: string;
  type: string;
  entityId?: string;
  baseVersion?: number;
  payload: TPayload;
  clientCreatedAt: string;
};

type MutationResult<T> =
  | { status: 'committed'; data: T }
  | { status: 'queued'; localId: string }
  | { status: 'conflict'; conflict: unknown }
  | { status: 'failed'; code: string; retryable: boolean };
```

### 6.1 Rules

- serializable payload only,
- stable mutation ID,
- validation before queue,
- network error classification,
- exact same mutation can be retried without duplicate side effect,
- rollback only if local operation itself is invalid; network failure queues where feature supports offline,
- UI status comes from mutation state, not assumptions.

### 6.2 `navigator.onLine`

May influence immediate UX, **never** decide that server definitely exists/doesn't. Online browsers may have captive portals, broken DNS, blocked Supabase, expired sessions.

Algorithm:
1. if feature has offline queue, persist command first;
2. attempt send if reasonable;
3. on retryable network error keep queued;
4. on auth/validation error mark attention and surface action.

---

## 7. Workout transaction — v1.0 critical path

### 7.1 Aggregate command

On completion client creates one `CommitWorkout`:

```text
mutation_id
workout:
  id
  started_at
  completed_at
  notes?
  template_id?
exercises[]:
  id
  exercise_id
  order_index
  notes?
  sets[]:
    id
    set_number
    weight_kg?
    reps?
    duration_seconds?
    distance_m?
    rpe?
    is_warmup
    rest_seconds?
```

No `user_id` from payload is trusted. Server derives user from auth context.

### 7.2 Server operation

Use a Postgres function/RPC (or Edge Function delegating to one DB transaction) that:

1. authenticates user,
2. validates envelope/schema,
3. checks `mutation_receipts` for `mutation_id`,
4. validates referenced system/custom exercise access,
5. inserts `workouts`,
6. inserts ordered `workout_exercises`,
7. inserts `workout_sets`,
8. records mutation receipt,
9. computes summary/new PR response,
10. commits atomically.

Any failure rolls back everything.

### 7.3 Idempotency

`mutation_receipts(user_id, mutation_id)` unique. Replayed `CommitWorkout` returns prior committed result or deterministic lookup instead of creating duplicates.

### 7.4 Why aggregate command

The old failure class “workout exists but sets lost/unlinked” becomes impossible under a successful transaction. Offline queue also carries one logical action instead of coordinating dozens of row mutations.

---

## 8. Generic sync v1.1

### 8.1 Timestamp LWW is forbidden as generic policy

If an offline edit made yesterday reaches server today, assigning a new server `updated_at` would make it appear “newer” than an actual edit from this morning. Therefore server arrival time cannot choose business truth.

### 8.2 Version contract

Every mutable syncable record:
- `version bigint not null default 1`,
- client mutation sends `base_version`,
- update executes `WHERE id = ? AND user_id = auth.uid() AND version = base_version`,
- success increments version,
- zero affected rows => conflict.

### 8.3 Per-entity policy

| Type | Policy |
|---|---|
| new workouts / append-only events | idempotent insert; no content conflict |
| user settings/preferences | optimistic concurrency; field-level/user-choice merge where useful |
| goals / plan tasks | version conflict surfaced; never silent overwrite |
| delete | tombstone + version |
| generated daily plan | immutable generation revision + explicit user edits |
| catalog system data | server/build versioning; no user conflict |

### 8.4 Sync worker

- queue order preserves dependencies,
- exponential backoff + jitter,
- max attempts before attention,
- lease/lock prevents two tabs/workers replaying same command concurrently,
- `BroadcastChannel` or equivalent coordinates tabs,
- sync events are observable without logging raw payload.

Capacitor may later substitute a native-aware scheduling trigger; domain queue contract remains.

---

## 9. Server data model

PostgreSQL migrations are the **only source of truth**. `docs/SCHEMA.md` is generated.

### 9.1 Global conventions

Mutable user-owned tables:
- `id uuid`,
- `user_id uuid not null`,
- `created_at timestamptz not null`,
- `updated_at timestamptz not null`,
- `deleted_at timestamptz null` where soft delete applies,
- `version bigint not null default 1`.

IDs:
- imported system exercise: deterministic UUIDv5 from stable namespace + source key,
- user-created entities: UUIDv7 client-side,
- no business entity depends on server-generated sequence to be created offline.

### 9.2 v1.0 tables

#### `user_profiles`
`id/user_id, full_name, avatar_path, date_of_birth?, gender?`

DOB/gender remain nullable until a real feature uses them.

#### `user_settings`
`user_id, locale, weight_unit, length_unit, distance_unit, theme`

v1.1 adds coaching preferences or splits them if lifecycle/security warrants.

#### `consents`
`user_id, purpose, status, policy_version, granted_at?, withdrawn_at?`

Introduced no later than first cross-module/AI health processing. May be created in v1.0 if privacy flow needs it.

#### `exercises`
```text
id
kind               system | custom
owner_id?           null for system, user for custom
source_key?
category
exercise_type
primary_muscles[]
secondary_muscles[]
equipment[]
movement_pattern
difficulty
is_compound
is_unilateral
tracks[]
default_rest_seconds
```

RLS:
- system: read all authenticated, no client write,
- custom: owner CRUD.

#### `exercise_translations`
`exercise_id, locale, name, description?, instructions[], form_tips[], common_mistakes[]`

System translations seeded. Custom translations can initially use one user-entered locale + fallback.

#### `exercise_favorites`
`user_id, exercise_id`, unique pair.

#### `workout_templates`
`id, user_id, name, description?, category?, source(system|custom), estimated_duration?`

Built-in templates can be seeded with system owner semantics or shipped as local presets converted to user template on edit.

#### `workout_template_exercises`
`id, template_id, exercise_id, order_index, target_sets?, target_rep_min?, target_rep_max?, target_rpe?, rest_seconds_override?`

Unique `(template_id, order_index)`.

#### `workouts`
`id, user_id, started_at, completed_at, template_id?, notes?`

Do **not** store canonical `total_volume`/PR/current duration if they are safely derivable. If a summary cache is later added, it is explicitly denormalized and rebuildable.

#### `workout_exercises`
`id, workout_id, exercise_id NOT NULL, order_index, notes?`

**No raw-name/null-FK escape hatch.** A custom exercise is created as a real exercise record before use.

#### `workout_sets`
`id, workout_exercise_id, set_number, weight_kg?, reps?, duration_seconds?, distance_m?, rpe?, is_warmup, rest_seconds?`

Check constraints enforce valid combinations/ranges as far as DB can.

#### `body_measurements`
Optional v1.0 depending product decision. Canonical SI fields.

#### `mutation_receipts`
`user_id, mutation_id, mutation_type, entity_id?, committed_at`, unique `(user_id, mutation_id)`.

#### `catalog_versions`
`version, checksum, created_at, source_snapshot_id`.

### 9.3 Derived views/queries

- workout volume,
- per-exercise estimated 1RM,
- current PR,
- weekly volume,
- recent/frequent exercises,
- workout duration.

If query performance later requires snapshots/materialization, architecture records invalidation/rebuild semantics first.

### 9.4 v1.1

`check_ins`, `goals`, `goal_progress`, `daily_plans`, `plan_tasks`, `daily_reflections`, `streaks`, `user_daily_metrics`, AI usage/audit tables.

### 9.5 v1.2

`mood_logs`, `breathing_sessions`, optional `mental_health_screenings` only after G-MH, `insights`, privacy/consent extensions.

---

## 10. Catalog build pipeline

```text
scripts/catalog/
├── 0-snapshot.ts
├── 1-select.ts
├── 2-normalize.ts
├── 3-map-taxonomy.ts
├── 4-merge-curated.ts
├── 5-translate.ts
├── 6-media.ts
├── 7-build.ts
└── 8-validate.ts
```

### 10.1 Provenance manifest

Each release records:
- upstream repository/snapshot commit,
- upstream license file checksum,
- selected source keys,
- transformation version,
- manual content version,
- translation version,
- media provenance status,
- output checksum.

### 10.2 Mapping

Use source values when available:
- muscles/equipment/level/instructions directly normalized,
- source `category` and `mechanic` inform our mapping,
- `movement_pattern` and `tracks` manually/rule-mapped with review,
- `default_rest_seconds` rule + review,
- no brittle substring categorization.

### 10.3 Media gate

`6-media.ts` refuses to package source photos unless a machine-readable `media-approved` provenance artifact exists.

This turns legal/content uncertainty into a build gate, not a note people forget.

### 10.4 Identical IDs

The build emits:
1. static client catalog,
2. SQL/seed payload for PostgreSQL,

from the **same normalized source object**, guaranteeing identical exercise UUIDs.

---

## 11. TanStack Query persistence

Use:
- `@tanstack/react-query`,
- persistence client,
- an **actual IndexedDB persister** (small custom adapter using IndexedDB/idb-keyval or Dexie).

Do not claim `query-sync-storage-persister` itself is IndexedDB.

### 11.1 Cache rules

- persisted query cache is versioned/buster-tagged by app/schema version,
- sensitive cache entries are explicitly reviewed; not every query must persist,
- cache can be discarded and rebuilt from server,
- catalog uses dedicated Dexie tables instead of query cache,
- active workout never lives only in query cache.

---

## 12. Authentication

### 12.1 Browser PWA

`@supabase/supabase-js`, `persistSession`, auto refresh, PKCE.

Flows w v1.0 (decyzja D-S / ADR-26):
- email/password,
- reset/recovery.

Przeniesione do v1.0.1:
- Google OAuth,
- Apple OAuth where required by product/store policy.

Warstwa adapterów z §12.3 powstaje jednak **od razu w v1.0**, mimo że ma tylko jedną implementację. Powód: jej brak oznacza rozsianie założeń o przekierowaniach przeglądarki po całym kodzie funkcji, co przy dokładaniu providerów i Capacitora w v1.1 wymusiłoby zmiany w wielu miejscach naraz.

Use a static callback route that completes PKCE client-side and then returns to locale/app route.

### 12.2 Production auth gates

Before external beta:
- custom SMTP for password/recovery mail,
- redirect allowlist narrowed to real environments,
- CAPTCHA/abuse controls evaluated,
- password policy configured; avoid bespoke “uppercase+special character” rules as the only security control,
- leaked-password protection/provider features enabled where available,
- OAuth credentials and consent screens validated.

### 12.3 Capacitor adapter

Do not scatter browser redirect assumptions through features. `lib/auth/` exposes platform-neutral methods:
- `signIn`,
- `signInWithProvider`,
- `signOut`,
- `getSession`,
- `handleCallback`.

v1.1 can implement native/deep-link specifics behind this adapter.

### 12.4 AgentOS eval

The benchmark starts from a pre-authenticated, isolated test account/storage state. The task being scored does not provision Google/Apple/SMTP.

No production auth bypass is compiled into a release build. CI asserts absence of eval-only routes/flags.

---

## 13. RLS and database security

### 13.1 Non-negotiable

- RLS enabled on every user table.
- Client never receives service-role key.
- `user_id` in mutation payload is ignored/derived where possible.
- Edge Functions validate JWT.
- DB constraints backstop app validation.
- generated TypeScript DB types come from schema.

### 13.2 RLS test matrix

For every user-owned table:

| Actor | Own row | Other user's row | System row |
|---|---:|---:|---:|
| anon | no | no | as explicitly allowed |
| user A | allowed operation | **denied** | read where intended |
| user B | own only | denied | read where intended |
| service role | server-only expected behavior | server-only | server-only |

Automated tests cover SELECT/INSERT/UPDATE/DELETE separately. Migrating an old policy without passing this matrix is forbidden.

### 13.3 Secret scanning

`gitleaks` blocks merge. Repository history containing prior compromised secrets is not imported into fresh repo.

---

## 14. Privacy and observability

### 14.1 Error telemetry

Sentry before-send hook removes:
- auth tokens,
- email/name where not essential,
- workout notes,
- mood/reflection/screening content,
- AI prompts/responses,
- raw IndexedDB payloads.

Breadcrumb allowlist, not blacklist.

### 14.2 Product measurement

Prefer deriving:
- activation/retention from `workouts.completed_at`,
- recent/frequent exercise from functional data,
- sync success from non-content mutation status.

Logging-interaction benchmark can use beta instrumentation:
`workout_id pseudonymous`, interaction durations, device class, app version — no set weights/reps or notes unless necessary and approved.

### 14.3 Privacy gates

Before Life Coach/Mind:
- data-flow map,
- purpose + lawful basis/Article 9 condition documented,
- consent enforcement where chosen,
- DPIA updated as required,
- AI provider/data retention reviewed,
- deletion/export coverage tests updated.

---

## 15. AI architecture v1.1

```text
client
  → ai-orchestrator Edge Function
    → validate JWT
    → privacy/consent check
    → per-user quota/rate policy
    → build versioned context
    → call provider
    → validate structured output
    → optional bounded repair
    → persist approved domain result
    → record provider/model/token/cost metadata
  ← structured plan OR typed fallback error
```

### 15.1 Context definition

Versioned server-side config, not hardcoded UI constants. Context builder retrieves only allowed fields.

### 15.2 Structured output

Zod/JSON schema validates:
- task count,
- categories,
- duration bounds,
- required rationale/reason codes,
- no unknown enum values.

Invalid output does not enter database.

### 15.3 Deterministic fallback

Fallback is local/server deterministic from user goals/preferences/capacity. AI outage never returns an empty day.

### 15.4 Safety

No mental-health diagnosis/treatment. System prompt alone is **not** a safety mechanism; feature scope, data contracts, output validation, UI copy and G-MH are also required.

---

## 16. PWA and browser storage

### 16.1 Cache strategy

| Resource | Strategy |
|---|---|
| versioned app shell/static JS/CSS | precache/versioned |
| catalog data | dedicated versioned local store |
| approved exercise media | cache-first with explicit quota/eviction policy |
| server query data | network-first/query cache; persistence only for selected queries |
| fonts | self-hosted/cache-first |
| active workout/outbox | IndexedDB domain store; never generic runtime cache |

### 16.2 Update

Service worker detects new release and displays “update available”. Update activation/reload waits until:
- no active workout, or
- user explicitly accepts after durable draft flush.

### 16.3 iOS correction

Do not encode “installed PWA loses storage after seven days” as a platform fact. Safari's browser storage behavior and Home Screen web-app storage are not identical; installed Home Screen apps have separate storage semantics.

Architecture consequence:
- test **Safari → Add to Home Screen → first standalone launch**,
- expect storage/session separation behavior to require explicit verification,
- design re-auth/recovery rather than assuming browser tab storage is inherited,
- server-synced records recover after auth,
- unsynced draft must be tested under actual installed PWA lifecycle/storage pressure.

`navigator.storage.persist()` may be requested where supported but never treated as guarantee.

---

## 17. Capacitor v1.1

### 17.1 Keep path open from day one

- relative/static-compatible navigation,
- safe-area tokens in design,
- touch targets ≥44 px,
- no request-time Next backend dependency,
- platform adapters for auth/haptics/notifications/storage,
- no direct browser-only API deep inside business logic.

### 17.2 Native value

Store wrapper must provide actual app-like utility and robust offline behavior. Candidate native features:
- local notifications,
- haptics,
- deep links/auth callback,
- secure storage for auth-sensitive platform data where appropriate,
- background-aware sync triggers where platform allows.

This supports quality/store review, but **does not guarantee approval**.

### 17.3 Mobile gate

Before submission:
- real iOS + Android device regression,
- offline/restart/upgrade tests,
- privacy labels/declarations,
- health-app declaration where required,
- current App Store/Google Play review/payment policy re-check,
- no stale web-only install UI in native shell.

---

## 18. Testing architecture

### 18.1 Test pyramid by failure class

| Layer | Tool | Must cover |
|---|---|---|
| pure domain | Vitest | Epley, volume, pattern selection, PR, unit conversions, sync conflict functions |
| schema/contracts | Vitest/Zod | mutation payloads, catalog, AI output |
| DB | Supabase local + SQL tests | constraints, RPC atomicity, idempotency, RLS matrix |
| components | Testing Library | forms, errors, empty/offline/queued states |
| integration | Vitest/MSW + real local DB where needed | Query/mutation gateway/retry |
| E2E | Playwright | critical user flows |
| visual | screenshot/VLM gate | frozen `DESIGN_ID` frames |
| accessibility | axe + manual | critical routes |
| PWA/device | browser/device smoke | install/update/offline lifecycle |

### 18.2 Critical deterministic tests

1. kill/reload active workout → exact draft recovered;
2. complete offline → one queued command;
3. replay same mutation 5× → one server workout;
4. force failure between workout/exercises/sets → transaction rolls back all;
5. edit/delete historical PR workout → derived PR becomes correct;
6. user A cannot read/write user B data;
7. service worker update during active workout → no forced reload;
8. catalog static ID equals server ID;
9. production bundle contains no provider/service key;
10. production build contains no eval bypass.

### 18.3 Coverage policy

No global vanity target that keeps CI permanently red.

- 100% branch coverage for small pure functions where corruption risk is high.
- Critical RPC/sync/RLS has explicit scenario coverage.
- Overall coverage is tracked as ratchet after baseline, not as substitute for behavior tests.

---

## 19. Build / verification pipeline

### 19.1 `verify`

- format check,
- lint/boundaries/forbidden imports,
- `tsc --noEmit`,
- unit + component tests,
- DB schema/RLS tests where environment available,
- catalog validation/provenance gate,
- secret scan,
- production bundle scan for eval-only markers,
- dependency audit policy,
- route bundle budgets.

### 19.2 `e2e`

Preview deployment or local static server:
- authenticated test state,
- critical flows,
- offline workout,
- retry/idempotency,
- axe,
- visual critical frames.

### 19.3 `device-smoke`

Human/automated where tooling permits:
- iOS installed PWA,
- Android installed PWA,
- update,
- offline/reopen,
- auth after install.

### 19.4 `deploy`

- preview per branch/task,
- production from protected main,
- DB migrations are separate controlled step,
- migration forward/backward compatibility checked before app deploy where necessary.

---

## 20. AgentOS implementation contract

Every autonomous task receives:

```yaml
task_id:
prd_ids: []
design_ids: []
architecture_refs: []
preconditions: []
scope:
forbidden_paths: []
schema_contract:
acceptance_criteria: []
required_tests: []
expected_artifacts: []
human_gates: []
budget:
```

### 20.1 Monotonicity rules

Agent may not:
- weaken tests to pass,
- remove RLS,
- disable lint/type/secret gates,
- change PRD priority,
- change ADR status,
- replace real persistence with fixtures,
- add production mock data,
- bypass mutation gateway,
- add new dependency without reason recorded in result.

### 20.2 Eval classification

External/provider failure → `infra_fail/provider_fail`.  
Acceptance criteria not met → `task_fail`.  
Deterministic gate fails after agent changes → `gate_fail`.  
Security zero violation → benchmark STOP per AgentOS test plan.

---

## 21. Design-facing technical constraints

Designer should assume:

- mobile primary, desktop fully usable,
- offline/sync status is a first-class component, not toast-only,
- active-workout screen must survive long sessions and one-handed use,
- bottom nav exactly 5 destinations,
- Settings not in bottom nav,
- all destructive actions need explicit recovery/confirmation semantics,
- timer must remain visible but not block set entry,
- long Polish strings are reference stress case,
- safe areas for future Capacitor from v1 design,
- charts need accessible tabular/summary alternative,
- color cannot be the only carrier of PR/error/sync state.

---

## 22. Pre-implementation spikes / gates

| ID | Task | Pass condition |
|---|---|---|
| SPIKE-01 | Static export + next-intl + Supabase auth callback | EN/PL static routes + PKCE sign-in/recovery work on preview |
| SPIKE-02 | Serwist + installed PWA | offline shell + controlled update works |
| SPIKE-03 | Dexie active workout | reload/kill recovery deterministic |
| SPIKE-04 | Atomic workout RPC | partial insert impossible; idempotent replay passes |
| SPIKE-05 | iOS add-to-home auth/storage | documented behavior on real device; recovery flow accepted |
| SPIKE-06 | Catalog identity | same deterministic IDs in static JSON and Supabase seed |
| SPIKE-07 | Source content/media | G-LIC result written; build blocks unapproved media |
| SPIKE-08 | Bundle/route baseline | budgets set from measured M0, not guessed |

M0 is not complete until SPIKE-01…06 pass. SPIKE-07 blocks catalog media release; SPIKE-08 sets ratchet.

---

## 23. Explicitly forbidden shortcuts

- direct Supabase writes from components/hooks outside mutation adapter,
- workout data only in Zustand/localStorage,
- separate row-by-row offline queue for workout aggregate in v1.0,
- generic LWW by `updated_at`,
- nullable `exercise_id` + raw name in `workout_exercises`,
- hand-maintained duplicate TypeScript DB types,
- source exercise photos without provenance gate,
- health/mental raw payload in Sentry,
- production auth bypass for benchmark,
- middleware-dependent locale/auth behavior under static export,
- calling query cache “source of truth”,
- declaring store/payment rules immutable years before implementation.

---

## 24. Ograniczenia darmowych progów — konsekwencje architektoniczne

Decyzja D-T (wyłącznie darmowe progi) nakłada twarde ograniczenia. Nie są to preferencje — złamanie któregoś kończy się rachunkiem albo przestojem.

| Ograniczenie | Konsekwencja architektoniczna |
|---|---|
| Baza 500 MB | Bez znaczenia w tej skali. Trening z osiemnastoma seriami to kilka kilobajtów |
| Pliki 1 GB | **Katalog ćwiczeń i wszelkie ilustracje idą w paczce statycznej**, nie przez Supabase Storage. Storage służy wyłącznie awatarom |
| Transfer z bazy 5 GB miesięcznie | Wzmacnia decyzję o katalogu offline w Dexie: przeglądanie katalogu nie generuje ruchu do bazy |
| Dwa aktywne projekty | Produkcja plus jedno środowisko dla benchmarku AgentOS. **Nie ma trzeciego środowiska** — testy bazy w procesie budowania używają lokalnego Supabase, nie zdalnego |
| **Wstrzymanie po 7 dniach bez zapytań** | Wymaga decyzji w M0. Dane są zachowane, ale wznowienie jest ręczne. Podczas bety oznacza to, że pierwszy tester po tygodniowej przerwie trafia na aplikację, która nie odpowiada. Opcje: lekkie zapytanie cykliczne z zewnętrznego zadania czasowego, albo świadoma akceptacja z komunikatem w interfejsie. **Otwarte: O-09** |

**Próg opłacalności.** Pierwszym powodem przejścia na plan płatny nie będzie rozmiar danych ani liczba użytkowników, tylko **wstrzymywanie projektu** i brak automatycznych kopii zapasowych. Warto to zaplanować na moment rozpoczęcia bety zewnętrznej, a nie odkryć w jej trakcie.

---

## Appendix A — v1.0 route/data ownership

| Route | Feature | Read | Write |
|---|---|---|---|
| dashboard | core/workouts | Query + local draft status | start/resume |
| workout | workouts | Dexie draft + catalog | Dexie draft → CommitWorkout |
| exercises | exercises | Dexie catalog + Query favorites/custom | mutation gateway |
| templates | templates | Query | mutation gateway |
| history | history | Query | mutation gateway (online v1.0 edit/delete) |
| progress | progress | Query/derived DB | measurements if shipped |
| settings | settings | Query/local display prefs | mutation gateway/local theme |
| auth | auth | Supabase session | Supabase Auth adapter |

**Offline v1.0 write scope is deliberately narrow:** complete/new workout aggregate. Offline edit/delete of old history, custom exercise creation and settings sync may require network until generic sync v1.1 unless separately promoted by PRD.

---

## Appendix B — implementation research basis

Architecture corrections were checked against current official documentation for:
- Next.js static export,
- next-intl static routing constraints,
- Supabase browser auth/PKCE/production auth guidance,
- TanStack Query persistence,
- WebKit website/Home Screen storage behavior,
- Chrome Lighthouse/PWA tooling,
- Apple/Google store policies.

Pin exact dependency versions in lockfile at M0 and verify APIs against current docs then; this document intentionally specifies contracts rather than assuming a future minor-version API.
