# LifeOS — Implementation Plan

**Wersja:** 1.2 — po decyzjach właściciela z 2026-08-12  
**Data:** 2026-08-12  
**Status:** **G-PROD zamknięte** (D-U…D-X). **GO dla M0** · **NO-GO dla mierzonych `LIFE-Txx`** — pozostają `G-DESIGN` (design nie istnieje) i `G-BACKUP`. Stan bramek: `DECISIONS.md`  
**Tryb pracy:** greenfield · jedna osoba + Agent OS/AI · ok. 20 h/tydzień czasu właściciela  
**Powiązane:** `PRD.md`, `ARCHITECTURE.md`, `DESIGN-BRIEF.md`, `DECISIONS.md`

> Ten plan nie zakłada, że obecna koncepcja jest poprawna tylko dlatego, że jest opisana. Najpierw usuwa ryzyka, które mogą unieważnić test, potem buduje walking skeleton, a dopiero potem osiem pionowych feature packages używanych jako benchmark Agent OS.

---

## 0. Zasady nadrzędne

### 0.1 Dwie miary sukcesu

**Product success** i **AgentOS success** są oddzielne.

Product:
- użytkownik potrafi zalogować realny trening szybko i bez utraty danych,
- działa offline w głównym use case,
- wraca do produktu,
- rozumie dane i ufa stanowi sync.

AgentOS:
- dostaje zamrożony feature contract,
- implementuje UI + persistence + wiring + tests,
- przechodzi critic/gates,
- oddaje `READY_FOR_HUMAN`,
- nie narusza sandbox/forbidden/security.

Awaria OAuth providera albo store review **nie jest** dowodem, że builder nie umie implementować feature'u.

### 0.2 Walking skeleton przed szerokością

M0 musi udowodnić:

```text
static build
→ real Supabase session
→ protected app shell
→ one real DB read/write
→ Dexie durable draft
→ atomic CommitWorkout proof
→ reload/reopen
→ preview deploy
→ green verify/e2e
```

Dopiero wtedy rusza bateria feature'ów.

### 0.3 Vertical slice Definition of Done

Każdy feature task jest DONE tylko gdy:

1. ma `prd_ids` i `design_ids`,
2. jest osiągalny z normalnej nawigacji,
3. używa realnego modelu danych / approved test DB,
4. persistence przeżywa reload zgodnie z wymaganiem,
5. offline state działa, jeśli feature go deklaruje,
6. UI ma loading/empty/error/disabled/offline/queued states tam, gdzie potrzebne,
7. wymagane unit/component/DB/E2E przechodzą,
8. visual gate przechodzi na zamrożonych frame'ach,
9. accessibility gate przechodzi,
10. nie ma production mock data,
11. `verify` i `e2e` są zielone,
12. result.json uczciwie raportuje ograniczenia.

### 0.4 Nie liczymy „AI speedup” w baseline

Estymaty są **human-equivalent engineering effort ranges**, nie obietnicą kalendarzową. Agent OS może je skompresować, ale współczynnik wyliczamy dopiero po M0 + pierwszych 3 feature'ach. Nie odejmujemy z góry 25%, żeby harmonogram wyglądał lepiej.

### 0.5 Buffer jest jawny

Baseline nie zawiera 20% contingency. Release forecast pokazuje również zakres z buforem.

---

## 1. P0 — decision/research gates przed pełnym startem

Część tych prac może biec równolegle z M0, ale nie wolno ignorować ich przed odpowiadającym gate'em.

| ID | Zadanie | Owner | Blocking |
|---|---|---|---|
| ~~P0.1~~ | ~~Offline completion~~ — **ZAMKNIĘTE 2026-08-12 (D-U): TAK.** FIT-23 MUST v1.0, ADR-17 Accepted, G-PROD zielone | Product owner | ✅ |
| ~~P0.2~~ | ~~Ratify adult 18+ v1.x + provisional screening policy~~ — **ZAMKNIĘTE**, Z-AGE i R-04 ratyfikowane; G-PROD zielone | Product owner | ✅ |
| P0.3 | **ZAMKNIĘTE decyzją D-Q** — „LifeOS" porzucone. Pozostaje wybór nazwy z §1.4 PRD + badanie UK IPO klasy 9 i 42 | Product + brand/legal | BRAND-01 |
| P0.4 | Verify `free-exercise-db` data license + separate media provenance | Content/legal review | **catalog media** |
| P0.5 | 5–8 interviews/observations z P1; zmierzyć obecny logging workflow. **Dostęp do testerów potwierdzony (D-R)** | Product | G-UXR before F4 beta |
| P0.6 | Zdefiniować referencyjny 6-exercise/18-set benchmark | Product/testing | before F4 |
| P0.7 | Nowy projekt Supabase + rotacja sekretów. **Plan darmowy (D-T).** O-09 zamknięte — bez systemu podtrzymującego; procedura ręcznego wznowienia + stan `backend-unavailable` | Human gate | M0 |
| P0.8 | Confirm eval infrastructure: test user, sandbox secrets, Supabase test environment | AgentOS owner | B6 feature battery |
| P0.9 | Dependency/version spike against current Next/Supabase/Serwist/next-intl docs | Architecture | M0 |
| P0.10 | ~~Create `DECISIONS.md`~~ — **ZROBIONE**, zawiera też hierarchię precedencji dokumentów | Architecture | first code |
| **P0.11** | **`G-BACKUP`: `supabase db dump` poza platformą, retencja 7–14, kopia przed migracją oraz udokumentowana próba odtworzenia do pustej bazy.** Darmowy plan nie ma automatycznych kopii | Architecture | **pierwszy zewnętrzny tester** |
| **P0.12** | Wybór nazwy z krótkiej listy + badanie UK IPO klasy 9 i 42 | Product owner | BRAND-01 |

### Exit G-PROD

- ~~R-01 ratified or explicitly rejected~~ — **ratyfikowane 2026-08-12 (D-U)**; PRD spójny.
- Adult target ratified.
- No unresolved contradiction between PRD and architecture.
- Brand risk has an owner (does not need final trademark registration to build UX).

**If R-01 is rejected:** F4 must be rewritten and the project loses the current P1 positioning. Do not quietly implement old v1.0 behavior while keeping „offline trust” in the PRD.

---

## 2. Design track — właściciel wyznaczony (decyzja D-O)

**Właściciel:** właściciel produktu, pracujący w narzędziu projektowym na podstawie specyfikacji.
**Wejście:** `DESIGN-BRIEF.md` — dokument samowystarczalny, nie wymaga czytania PRD ani architektury.

> **`G-DESIGN` jest obecnie NO-GO.** Brief nie jest designem — jest kontraktem wejściowym do jego wykonania. Bramka przechodzi dopiero, gdy istnieje i został zaakceptowany pakiet graficzny. Żadne mierzone zadanie `LIFE-Txx` nie startuje wcześniej.
**Nakład:** 25–40 h pracy właściciela, poza budżetem inżynierskim.

Specyfikacja zawiera inwentarz ekranów i stanów, ograniczenia twarde z uzasadnieniem, przypadki testowe długich polskich napisów oraz jawną listę tego, co pozostawiono decyzji projektanta. Kryterium odbioru to **kompletność inwentarza stanów z §7 specyfikacji**, nie estetyka klatek.

**Zmiana względem wersji 1.1 tego planu:** `G-DESIGN` nie wymaga już niezmiennych, hashowalnych plików referencyjnych dla wszystkich ekranów — tylko dla klatek używanych w bramce wizualnej benchmarku (ścieżka aktywnego treningu, katalog, historia). Wymóg zamrożenia wszystkiego był kosztem bez pokrycia przy jednoosobowym zespole projektowym.

### 2.1 Podział bramki: system designu osobno, ekrany per zadanie

**Zmiana po recenzji.** Wcześniej `G-DESIGN` był jedną bramką blokującą **wszystkie** mierzone zadania do czasu ukończenia całego pakietu v1.0. Jest to bezpieczne dla spójności, ale kosztowne kalendarzowo bez potrzeby: zamrażanie panelu postępu trzy tygodnie wcześniej tylko po to, żeby agent mógł zacząć ustawienia, jest czystą stratą.

| Bramka | Zawartość | Co odblokowuje |
|---|---|---|
| **`G-DESIGN-SYSTEM`** | tokeny, typografia, siatka i odstępy, powłoka pięciu zakładek, komponenty bazowe, stany globalne (ładowanie, pusty, błąd, offline), **komplet stanów synchronizacji z `draft_local` włącznie**, reguły dostępności, obie motywy, przebieg długich napisów PL | Warunek konieczny dla **wszystkich** zadań. Nic mierzonego nie startuje wcześniej |
| **`G-DESIGN-T01`** | ekrany ustawień i kont | LIFE-T01 |
| **`G-DESIGN-T02`** | katalog, selektor, szczegóły ćwiczenia | LIFE-T02 |
| **`G-DESIGN-T04`** | pełna ścieżka treningu, **w tym „powtórz ostatni trening"** i stany `draft_local`/kolejki | LIFE-T04 |
| **`G-DESIGN-T05/T06/T07`** | historia, postęp, timer | odpowiednie zadania |

**Dlaczego to nie psuje benchmarku.** Porównywalność wymaga, żeby projekt dla konkretnego zadania był **zamrożony przed startem tego zadania** — nie żeby cały pakiet v1.0 był zamrożony przed startem pierwszego. Warunek zostaje spełniony w obu wariantach.

**Co to daje.** Realną równoległość: gdy skończysz system designu oraz ekrany T01 i T02, AgentOS implementuje te zadania, podczas gdy Ty projektujesz ścieżkę treningu. Przy jednoosobowym zespole to jest jedyne miejsce w całym planie, gdzie da się skrócić kalendarz **bez cięcia zakresu**.

**Ryzyko, które przyjmujemy świadomie:** projektowanie ekranów treningu po zamrożeniu systemu designu może ujawnić braki w komponentach bazowych. Łagodzi to kolejność — ścieżka treningu jest najbardziej wymagająca, więc system designu powstaje z jej wymaganiami na biurku, nawet jeśli same klatki przychodzą później.

### 2.2 Required design package

`G-DESIGN` (suma powyższych bramek) requires:

- mobile 390×844 reference,
- desktop 1440 reference,
- design tokens,
- 5-tab shell,
- full active workout flow **including "repeat last workout" (FIT-24)**,
- Exercise selector/detail,
- History,
- Progress,
- Settings,
- light/dark,
- PL long-string pass,
- **`draft_local`/offline/queued/syncing/sync-failed/conflict states — wszystkie sześć**,
- loading/empty/error,
- destructive dialogs,
- focus/accessibility annotations for critical paths,
- stable `DESIGN_ID` per tested frame,
- exportable assets rules.

### 2.3 No fake design freeze

A screenshot labeled „final” is not enough. `G-DESIGN` is green only when:
- every v1.0 product task (T01, T02, T04, T05, T06, T07) has at least one mapped frame or an explicit `design-not-required`,
- component states are defined,
- visual reference files are immutable/hashable for the benchmark.

### 2.4 Brand can remain neutral

If BRAND-01 is unresolved, designer uses `LifeOS` as **project label** but does not spend irreversible effort on logo/trademark-dependent identity. UX/design system can proceed.

---

## 3. M0 — engineering substrate / walking skeleton

**Reference effort:** 55–80 h  
**AgentOS benchmark score:** foundation may be agent-built, but external/provider failures are **not** scored as B6 feature capability.

### M0.1 Repository and policy

- Next.js/TS strict.
- `output: 'export'`.
- Tailwind + shadcn.
- lockfile committed.
- lint/boundaries.
- Prettier.
- Vitest/Testing Library/Playwright.
- gitleaks.
- no production fixture rule.
- `DECISIONS.md`.

**AC:** empty app builds statically; `verify` green.

### M0.2 Static i18n spike — SPIKE-01 part A

- `[locale]` routes EN/PL.
- no middleware dependency.
- fallback strategy.
- one screen fully translated.
- production root behavior documented.

**AC:** `/en/...` and `/pl/...` work from static preview and direct reload.

### M0.3 Supabase schema/Auth — SPIKE-01 part B

Initial migrations:
- profiles/settings,
- minimal exercise seed,
- minimal workout aggregate tables,
- mutation receipts.
- RLS matrix.

Auth:
- email/password and recovery in code,
- Google/Apple adapters **poza v1.0** (ADR-26); warstwa adapterów powstaje z jedną implementacją,
- provider dashboard provisioning human-gated,
- PKCE callback works.

**AC:** test user sign-in → protected route → sign-out; user A/B isolation tests pass.

### M0.4 App shell

Mobile bottom nav:
Home · Workout · Exercises · History · Progress.  
Settings via avatar/gear.

All destinations exist and show real empty states.

**AC:** no orphan routes needed for critical navigation.

### M0.5 Durable local DB — SPIKE-03

Dexie:
- active_workout_drafts,
- sync_outbox,
- catalog/meta.

Proof UI writes a minimal draft.

**AC:** change → hard reload → exact value recovers.

### M0.6 Atomic workout RPC — SPIKE-04

Minimal `CommitWorkout` with one exercise/set:
- client IDs,
- mutation ID,
- transaction,
- idempotency receipt,
- rollback.

**AC:**
- replay same command 5× = one workout,
- induced child insert failure = zero parent/child rows,
- user B cannot reference user A custom exercise.

### M0.7 Query persistence

TanStack Query + actual IndexedDB persister for selected cache entries. Version buster.

**AC:** cached safe query survives reload/offline; clearing cache does not destroy active draft.

### M0.8 PWA shell — SPIKE-02

- manifest,
- icons,
- service worker,
- install smoke,
- offline shell,
- update notification.

**AC:** no Lighthouse PWA score. Manual/automated capability checklist passes.

### M0.9 iOS lifecycle — SPIKE-05

Real device:
Safari auth → add Home Screen → standalone launch → auth/session/draft behavior.

**AC:** behavior documented; any re-auth/recovery UX is designed before F4.

### M0.10 Catalog identity — SPIKE-06

One source record transformed into:
- static catalog row,
- Supabase seed row,

with identical deterministic ID.

**AC:** automated equality test.

### M0.11 Observability / redaction

Sentry or equivalent error telemetry.
- scrubber allowlist,
- no raw draft/notes/auth token.

**AC:** seeded sensitive string does not appear in captured test event.

### M0.12 CI/deploy

Jobs:
- `verify`,
- `e2e`,
- preview deploy.
Device smoke can remain a separate manually triggered gate.

**M0 exit:**
- public/preview URL works,
- app shell installable,
- auth test state works,
- durable draft survives,
- atomic mutation proof works,
- green pipeline.

**STOP RULE:** if M0 cannot stay green for 48 h / repeated clean builds, feature battery does not start.

---

## 4. Content track

Runs in parallel but has its own gates. **Reference effort:** 60–100 h owner/content work, not included in engineering total.

### C0 — source/legal

- snapshot upstream repo/commit,
- verify Unlicense/data terms,
- separately resolve media provenance,
- provenance manifest.

If media unresolved: `media-approved=false`; build excludes source images.

### C1 — select 200–250

Selection criteria:
- common strength movements,
- equipment coverage,
- muscle coverage,
- reduce near-duplicates,
- custom exercise fills gaps.

### C2 — normalize/map

Automated normalization + review:
- category,
- mechanic/source hints,
- movement pattern,
- tracks,
- rest default,
- equipment.

### C3 — bilingual base

- EN source cleaned,
- PL translation,
- terminology review.

### C4 — curated top 50

Only launch-critical top 50 require reviewed:
- form tips,
- common mistakes.

Expansion beyond top 50 is post-launch content backlog, not code blocker.

### C5 — validate/build

Build gate checks:
- IDs stable,
- required fields,
- both locales,
- no unapproved media,
- checksum/version.

---

## 5. AgentOS feature battery — LIFE-T01…T08

### 5.0 Zakres baterii po przycięciu (decyzja D-S)

**Bateria v1.0 liczy sześć zadań, nie osiem.** LIFE-T03 (szablony) i LIFE-T08 (eksport CSV) przechodzą do v1.0.1.

To jest **świadomy koszt dla benchmarku**: sześć prób zamiast ośmiu daje słabszą podstawę statystyczną. Rozstrzygnięcie: T03 i T08 pozostają w baterii jako **kontynuacja w v1.0.1**, więc docelowo prób jest osiem — tylko rozłożonych w czasie. Porównywalność wymaga, żeby oba zadania używały tej samej wersji schematu `TASK_SPEC` co pierwsza szóstka; zmiana schematu między turami unieważnia porównanie.

**Kolejność zamrożona przed pierwszym mierzonym przebiegiem:**
`T01 → T02 → T04 → T07 → T05 → T06` *(następnie w v1.0.1: T03 → T08)*

Uwaga do kolejności: T01 przed T04 to **kolejność benchmarku, nie kolejność redukcji ryzyka produktowego**. Ryzyko produktowe skupia się w T04, a rozgrzewka na ustawieniach je odracza. Łagodzi to M0, które udowadnia trwały zapis roboczy i atomowy zapis na serwer, zanim T01 w ogóle ruszy. Właściciel akceptuje tę kolejność świadomie, wybierając porównywalność (decyzja D-M).

### 5.0.1 Preconditions

Before B6-style execution:
- M0 green,
- G-DESIGN green,
- eval test user/database fixture ready,
- TASK_SPEC schema frozen,
- task order frozen,
- each task has PRD IDs + design IDs + acceptance tests,
- reference baseline commit/tag created.

External OAuth/DNS/store work is outside task scope.

---

### LIFE-T01 — Profile & Settings

**PRD:** CORE-03, SET-01, SET-02, SET-03, SET-04, SET-05, SET-06, SET-07, SET-08, SET-09  
**Reference effort:** 30–45 h

**Scope:**
- Settings sections,
- units/theme/language,
- profile,
- data/privacy entry points,
- about/version,
- logout.

**Hard AC:**
1. settings reachable from shell,
2. theme/language survive reload,
3. unit conversion changes display only, canonical data unchanged,
4. profile mutation persists real DB,
5. logout invalidates protected UI,
6. export/delete actions have real wired command or explicitly staged server handler — no fake success toast,
7. EN/PL design frames pass,
8. E2E reload symmetry.

**Not in scored task:** configure Apple/Google console, custom SMTP.

---

### LIFE-T02 — Exercise Catalog

**PRD:** EX-01, EX-02, EX-03, EX-04, EX-05, EX-06, EX-07, EX-08, EX-09, EX-10  
**Reference effort:** 55–80 h engineering + content track

**Hard AC:**
1. catalog browsable/searchable with network disabled after bootstrap,
2. p95 search <200 ms reference profile,
3. all four filters settable from UI,
4. browse/select reuse same feature contract,
5. favorite persists and reloads,
6. custom exercise real CRUD,
7. system exercise immutable,
8. EN/PL search + fallback,
9. no source photo packages unless media gate passes,
10. static exercise ID matches server FK seed.

**Negative control:** typo/substring must not recategorize exercise.

---

### LIFE-T03 — Workout Template Builder — **PRZENIESIONE DO v1.0.1**

**PRD:** FIT-15  
**Reference effort:** 25–40 h · *poza v1.0 decyzją D-S; pozostaje w baterii jako kontynuacja*

**Hard AC:**
1. built-in preset can start a user-editable copy or workout,
2. create/edit/delete custom template,
3. add/remove/reorder exercises,
4. target set/reps/rest fields persist,
5. template survives reload,
6. create template from completed workout,
7. start workout from template produces durable draft,
8. no duplicate exercise/order corruption after reorder.

---

### LIFE-T04 — Workout Logging + Offline Durable Completion

**PRD:** CORE-06, CORE-07, CORE-08, FIT-01, FIT-02, FIT-03, FIT-04, FIT-05, FIT-07, FIT-08, FIT-23, **FIT-24**  
**Reference effort:** **83–124 h** (75–110 h + 8–14 h za FIT-24, decyzja D-V)  
**THIS IS THE PRODUCT HEART.**

**Hard AC:**
1. start blank **lub „repeat last workout" (FIT-24)**,
2. add/reorder/remove exercise,
3. fields reflect `tracks`,
4. pattern memory fills from last completed workout,
5. bodyweight/timed/warmup cases correct,
6. every edit durable in Dexie,
7. hard reload/reopen restores exact active draft,
8. complete with network OFF creates exactly one queued CommitWorkout,
9. reconnect syncs exactly once,
10. replay/retry does not duplicate,
11. summary distinguishes local queued vs server committed,
12. server workout returns with all exercises/sets after fresh login,
13. active interaction timer emits benchmark measurement without raw workout content,
14. **„repeat last workout" tworzy nowy szkic o strukturze ostatniego zakończonego treningu** — te same ćwiczenia, kolejność i liczba serii, z wartościami poprzedniej sesji jako wstępnie wypełnionymi,
15. **powtórzenie nie tworzy żadnej encji szablonu** i nie zapisuje niczego wielokrotnego użytku; efektem jest zwykły `draft_local`,
16. **powtórzenie działa bez sieci**, jeśli ostatni trening jest w lokalnym magazynie,
17. **obie ścieżki startu mierzone osobno** wobec progów z PRD §7.3 (powtórzenie <60 s, od pustego <120 s).

**Failure injection required:**
- kill page after set edit,
- network drop on commit,
- server 500,
- expired session,
- duplicate replay.

**STOP RULE:** any unrecoverable workout loss blocks all later product feature work.

---

### LIFE-T05 — Workout History

**PRD:** FIT-10, FIT-11  
**Reference effort:** 25–40 h

**Hard AC:**
1. list uses real server data,
2. filter by exercise,
3. detail shows exact sets/order,
4. edit persists,
5. soft delete removes from normal history,
6. editing/deleting affects derived progress,
7. 90-day p95 <1 s on seeded reference volume,
8. no access to other user data.

Offline read allowed for previously cached data; offline edit/delete is not v1.0 MUST.

---

### LIFE-T06 — Progress Dashboard

**PRD:** FIT-12 (FIT-13 zamknięte decyzją D-S: v1.0.1)  
**Reference effort:** **28–45 h** po wyjęciu pomiarów ciała

**Hard AC:**
1. estimated 1RM per exercise uses Epley,
2. weekly volume excludes warmups,
3. time ranges work,
4. PR timeline derived from valid history,
5. deleting old best set changes current PR correctly,
6. charts have accessible summary/table alternative,
7. empty/insufficient-data state designed,
8. no hard-coded demo series in production.

If FIT-13 deferred, benchmark task still passes with strength/volume/PR progress only.

---

### LIFE-T07 — Rest Timer + PR Detection

**PRD:** FIT-06, FIT-09  
**Reference effort:** 30–45 h

**Hard AC:**
1. timer auto-starts after working/warmup set per accepted UX,
2. default from exercise; user can change/skip,
3. background/tab lifecycle does not make elapsed time drift materially,
4. haptic/audio is capability-aware and non-blocking,
5. PR uses eligible working sets,
6. `reps=1` exact weight,
7. warmup excluded,
8. new PR highlighted on summary,
9. retrying workout commit does not duplicate PR signal/event,
10. edit/delete recomputation remains correct.

---

### LIFE-T08 — CSV / User Data Export — **CZĘŚCIOWO PRZENIESIONE DO v1.0.1**

**PRD:** FIT-16 (v1.0.1), SET-06 (**pozostaje v1.0**)  
**Reference effort:** 15–25 h, z czego **8–14 h pozostaje w v1.0** i jest realizowane w ramach LIFE-T01.

**Co zostaje w v1.0:** eksport pełnych danych użytkownika i usunięcie konta — wymóg UK GDPR, nie funkcja produktowa. Bez wygodnego eksportu CSV historii treningów, bez oddzielnego ekranu.
**Co przechodzi do v1.0.1:** eksport CSV historii z udokumentowanymi kolumnami i jednostkami.

**Hard AC:**
1. *(CSV historii — v1.0.1)*
2. full data export includes owned domain data in JSON,
3. user A cannot export B,
4. server-side throttling,
5. file generation failure gives retryable error,
6. no secret/internal fields,
7. EN/PL UI,
8. E2E validates non-empty export after seeded workout.

---

## 6. Benchmark execution rules

These extend, not replace, `plan-testow-v2.md`.

### 6.1 Every TASK_SPEC contains

```yaml
task_id: LIFE-T0X
prd_ids: [...]
design_ids: [...]
architecture_refs: [...]
base_sha:
preconditions:
scope:
non_goals:
forbidden_paths:
allowed_migrations:
schema_contract:
acceptance_criteria:
required_tests:
visual_checks:
accessibility_checks:
failure_injection:
expected_artifacts:
human_gates:
budget:
```

### 6.2 Critic ground truth

For capability benchmarking:
- seeded defect trials remain in Poligon-A as defined by AgentOS test plan,
- LifeOS evaluates feature delivery/acceptance, not critic precision ground truth by itself,
- do not turn subjective product feedback into fake critic recall statistic.

### 6.3 Scored vs not scored

**Scored:** feature implementation, wiring, tests, regression, design parity, DB correctness, offline behavior.  
**Not scored:** provider outage, unavailable Apple console, DNS, store review, legal approval. Logged separately.

### 6.4 Frozen task semantics

Agent may not change:
- PRD priority,
- design meaning,
- Definition of Done,
- safety/integrity gates,
- forbidden paths.

If task is impossible because docs conflict, expected outcome is `blocked_spec_conflict`, not silently rewriting architecture.

---

## 7. R1 — v1.0 integration/hardening/release

**Reference effort:** 50–80 h

After the six v1.0 product tasks (T01, T02, T04, T05, T06, T07) — **not T03/T08, które są v1.0.1**:

### R1.1 End-to-end product flow

Fresh user:
sign in → settings basics → start workout (blank **lub „repeat last", FIT-24**) → workout → **offline completion (FIT-23)** → reconnect → history → progress.

*Bez szablonów i eksportu CSV — v1.0.1.*

### R1.2 Performance

Measure, then optimize:
- Core Web Vitals lab/field where possible,
- route bundle budgets,
- catalog bootstrap,
- pattern memory,
- history query.

### R1.3 Accessibility

- axe,
- keyboard,
- screen reader critical flow,
- 200% zoom,
- long Polish strings,
- touch targets.

### R1.4 PWA/device

- Android install/launch/offline/update,
- iOS Home Screen install/launch/auth/offline/update,
- desktop.

### R1.5 Security/privacy

- RLS matrix,
- export/delete,
- secret scan,
- Sentry redaction,
- production eval-marker scan,
- dependency review,
- no unapproved media.

### R1.6 Beta instrumentation

Logging benchmark and product behavior with approved minimal instrumentation.

### R1.7 Beta

Start with **10 target P1 testers** before broad launch.

Early value checkpoint:
- ≥7/10 complete first workout,
- ≥5/10 complete at least 3 workouts in 14 days,
- median benchmark interaction <60 s among users with prior-session data,
- **0 unrecoverable workout losses**.

These are **early product hypotheses**, not universal benchmarks. Failure triggers interviews and workflow correction before v1.1.

---

## 8. v1.0 effort / calendar

### 8.1 Engineering

| Praca | Zakres | Zmiana po D-S |
|---|---:|---|
| M0 substrate | 55–80 h | — |
| LIFE-T01 (z minimalnym eksportem RODO) | 38–59 h | +8–14 h przeniesione z T08 |
| LIFE-T02 | 55–80 h | — |
| ~~LIFE-T03~~ | ~~25–40 h~~ | **przeniesione do v1.0.1** |
| LIFE-T04 | **83–124 h** | **+8–14 h** (FIT-24, D-V) |
| LIFE-T05 | 25–40 h | — |
| LIFE-T06 | 28–45 h | −7–10 h (bez pomiarów ciała) |
| LIFE-T07 | 30–45 h | — |
| ~~LIFE-T08~~ | ~~15–25 h~~ | **częściowo przeniesione**, reszta w T01 |
| R1 hardening | 42–68 h | −8–12 h (mniejsza powierzchnia) |
| **Suma inżynierii** | **356–541 h** | |
| +20% rezerwy | **427–649 h** | |

Przy 20 h tygodniowo: **21–32 tygodnie z rezerwą**, czyli około pięciu do ośmiu miesięcy. Decyzja D-V nie zmienia tego przedziału w sposób odczuwalny.

### 8.1.1 Uczciwa uwaga o skali oszczędności

Przycięcie zakresu (D-S) oszczędza **47–73 h bazowo**, a po dodaniu FIT-24 (D-V) netto **39–59 h** — mniej więcej dwa do trzech tygodni kalendarzowych. To znacznie mniej, niż sugerowano przy podejmowaniu decyzji.

Powód jest strukturalny i wart odnotowania: **dwie trzecie nakładu leży w czterech pozycjach — M0, katalog, logowanie i utwardzanie przed wydaniem — których nie da się wyciąć, nie wycinając produktu.** Szablony, eksport CSV, pomiary ciała i logowanie społecznościowe były w sumie mniejsze niż sam etap M0.

Jeśli celem jest kalendarz rzędu piętnastu tygodni, musi paść jedna z czterech dużych pozycji. Możliwości, w kolejności od najmniej bolesnej:

| Cięcie | Oszczędność | Koszt |
|---|---:|---|
| Katalog 50 ćwiczeń zamiast 200–250, bez własnych ćwiczeń użytkownika | 20–30 h | Użytkownik szybko trafi na brak swojego ćwiczenia i nie będzie mógł go dodać. **Prawdopodobnie zabija test wedge** |
| Rezygnacja z kolejki offline (FIT-23), zostawiając trwały zapis roboczy i atomowy zapis serwerowy | 20–30 h | Trening trzeba dokończyć przy zasięgu. Traci się główny ból persony P1 — patrz otwarta decyzja O-08 |
| LIFE-T06 tylko jeden wykres siły, bez objętości i osi rekordów | 15–25 h | Postęp staje się szczątkowy; to jedna z rzeczy, po które ludzie wracają |
| Skrócenie R1 do testów krytycznych, bez pełnego przeglądu dostępności | 15–25 h | **Odradzam.** Dostępność dołożona po fakcie kosztuje wielokrotnie więcej |

**Rekomendacja:** nie tnij dalej. Pięć do ośmiu miesięcy przy dwudziestu godzinach tygodniowo jest uczciwą ceną tego zakresu, a każde z powyższych cięć uderza w coś, co decyduje o tym, czy ktokolwiek użyje produktu drugi raz.

### 8.1.2 Koszt infrastruktury pomiarowej AgentOS (decyzja D-M)

Właściciel zaakceptował narzut równorzędnej roli benchmarku. Poniżej jego cena, wyliczona jawnie, żeby była widoczna przy każdym przeglądzie:

| Pozycja | Nakład |
|---|---:|
| Pisanie `TASK_SPEC` dla sześciu zadań | 12–18 h |
| Środowisko ewaluacyjne: użytkownik testowy, dane wejściowe, izolowana baza | 8–12 h |
| Infrastruktura bramki wizualnej | 10–16 h |
| Zamrażanie i hashowanie klatek referencyjnych | 6–10 h |
| Przechwytywanie wyników, klasyfikacja, raportowanie | 8–12 h |
| Dyscyplina `base_sha`, polityka WIP, rebasing przy nieaktualnych zadaniach | 6–10 h |
| Niemierzony przebieg próbny | 4–6 h |
| **Razem** | **54–84 h** |

To jest **15–24% ponad nakład inżynierii produktowej**, czyli około trzech do czterech tygodni kalendarzowych. Nie jest wliczone w 356–541 h powyżej.

**Łączny nakład v1.0 razem z benchmarkiem: 410–625 h bazowo, 492–750 h z rezerwą — czyli 25–38 tygodni.**

### 8.2 Poza budżetem inżynierskim — rachunek pełny

Wszystko poniżej wykonuje **ta sama osoba**, więc nie biegnie równolegle w sensie kalendarzowym.

| Pozycja | Nakład | Uwaga |
|---|---:|---|
| Projekt graficzny (D-O) | 25–40 h | Właściciel w narzędziu projektowym wg `DESIGN-BRIEF.md`; podzielone na `G-DESIGN-SYSTEM` + zamrożenia per zadanie (§7.4) |
| Treść katalogu | 60–100 h | Faza F1–F3 przed LIFE-T02 |
| Wywiady z użytkownikami i obserwacja (D-R) | 15–25 h | Pięć do ośmiu osób, plus opracowanie |
| Rekrutacja i prowadzenie bety | 10–20 h | Dziesięciu testerów |
| Przeglądy prawne, marki i prywatności | 10–20 h | Badanie znaków towarowych, G-PRIV |
| **Razem poza inżynierią** | **120–205 h** | |

**Całkowity rachunek v1.0: 530–830 h bazowo, 612–955 h z rezerwą.**
Przy 20 h tygodniowo: **31–48 tygodni, czyli siedem do jedenastu miesięcy do bety z dziesięcioma użytkownikami.**

| Składnik | Zakres |
|---|---:|
| Inżynieria produktowa | 356–541 h |
| Narzut benchmarku AgentOS | 54–84 h |
| **Baza** | **410–625 h** |
| +20% rezerwy | **492–750 h** |
| Praca właściciela poza inżynierią | 120–205 h |
| **Pełny v1.0** | **612–955 h** |

To jest wariant skrajnie konserwatywny i **nie jest prognozą**, że projekt potrwa 48 tygodni. Właśnie po to istnieje warstwa AgentOS: żeby zmierzyć rzeczywistą kompresję względem tego baseline'u. Ale sam baseline musi być matematycznie spójny, inaczej pomiar nie ma punktu odniesienia.

Ta liczba nigdzie się już nie chowa. Jest większa niż w wersji 1.1 tego planu nie dlatego, że zakres urósł — zakres zmalał — tylko dlatego, że po raz pierwszy zsumowano wszystko, co wykonuje ta sama osoba.

### 8.3 Re-estimation points

Re-estimate after:
1. M0,
2. T01, T02, T04 — pierwsze trzy zadania produktu v1.0,
3. T04,
4. first 10-user beta.

Report actual hours/agent cost/iterations vs baseline.

---

## 9. v1.1

**Kolejność ustalona decyzją D-X (2026-08-12): Life Coach idzie pierwszy, infrastruktura po nim.**

| | Etap | Nakład |
|---|---|---|
| **M5** | **Life Coach — PWA online-first** | 120–180 h |
| M6 | Generic multi-entity sync | 80–120 h |
| M7 | Capacitor | 50–90 h + czas sklepów |

**Dlaczego odwrócenie.** Wersja 1.0 dostarcza już trwały szkic, kolejkę wysyłkową, bramkę mutacji i atomowy zapis agregatu, więc generic sync **nie jest warunkiem** działania Life Coacha w trybie online-first. Odwrócenie sprawdza właściwą długoterminową tezę produktu o **130–210 h wcześniej** — a to jest teza, na której stoi sens projektu, skoro wyróżnik v1.0 jest cienki i zajęty (PRD §1.2). Testowanie jej po pół roku budowania infrastruktury byłoby odwróceniem porządku ryzyka.

**Czego to nie zmienia.** Life Coach w M5 jest **online-first**: check-in i plan wymagają sieci. To jest akceptowalne, ponieważ inaczej niż trening, poranny check-in nie odbywa się w piwnicy bez zasięgu. Trening pozostaje jedynym przepływem działającym w pełni offline aż do M6.

### ⚠️ Konsekwencja, którą trzeba przyjąć świadomie: częściowe uchylenie D-T

Decyzja D-T mówiła „wyłącznie darmowe progi usług". **Life Coach wymaga API modelu językowego, a ono kosztuje** — nie ma tu darmowego progu produkcyjnego. Postawienie Life Coacha przed infrastrukturą oznacza więc, że **pierwszy stały koszt projektu pojawia się o 130–210 h wcześniej, niż zakładano.**

| | |
|---|---|
| Skala przy 10 testerach | rząd kilku funtów miesięcznie |
| Kiedy | od początku M5, nie od v1.2 |
| Status D-T | **obowiązuje dla v1.0**; od M5 uchylone w części dotyczącej API modelu |
| Wymagane przed M5 | twardy limit wydatków, alert budżetowy, deterministyczny plan zapasowy przy braku środków lub awarii |

Deterministyczny plan zapasowy jest tu ważniejszy niż zwykle: przy braku środków na koncie API produkt musi degradować się do planu bez modelu, a nie przestawać działać. Ten wymóg był już w kolejności prac; D-X podnosi jego wagę.

Starts only if v1.0 value checkpoint does not demand a product reset.

### M5 — Life Coach (online-first) — PIERWSZY

**120–180 h**

Mapping:
- LC-01, LC-02, LC-03, LC-04, LC-05,
- LC-06, LC-07, LC-08, LC-09, LC-10,
- LC-11, LC-12, LC-13,
- SET-11, SET-12.

Order:
1. DB/consent/context contracts,
2. manual check-in and plan data model,
3. deterministic fallback plan,
4. AI broker,
5. structured generation,
6. edit/outcomes,
7. reflection,
8. 7-day loop test.

**No chat before closed loop.**

**AC dodatkowe wynikające z D-X (online-first):**
- brak sieci przy check-inie daje jawny, zrozumiały stan — nie pustą kartę i nie fałszywy plan,
- awaria lub wyczerpany budżet API zwraca deterministyczny plan zapasowy,
- twardy limit wydatków i alert budżetowy działają **przed** pierwszym wywołaniem produkcyjnym,
- trening pozostaje w pełni offline; generic sync nadal nie istnieje i nie wolno go tu po cichu wprowadzać.

### M6 — Generic multi-entity sync

**80–120 h**

PRD: CORE-07, SET-14 plus sync requirements supporting v1.1 entities.

Tasks:
- version/base_version,
- conflict objects/UI,
- local queue dependencies,
- multi-tab lock/lease,
- tombstones,
- settings/goals/task sync policies,
- conflict tests,
- instrumentation.

**AC:** no generic timestamp LWW; deterministic conflict test passes. Encje Life Coacha z M5 wchodzą do generic sync **tutaj** — do tego czasu są online-first.

### M7 — Capacitor

**50–90 h + store external time**

- iOS/Android projects,
- auth deep-link/platform adapter,
- safe areas,
- local notifications,
- haptics,
- storage lifecycle,
- native build CI where possible,
- real-device matrix,
- current store declarations/review.

**AC:** not merely „website in wrapper”; primary flows work offline/restart and native-specific features are integrated.

### v1.1 exit

- new workout offline and generic sync coexist,
- no unresolved sync conflicts hidden,
- 7 consecutive day loop succeeds,
- AI outage returns fallback,
- Capacitor builds pass device smoke,
- privacy/DPIA/store gates updated.

---

## 10. v1.2 — Mind + rule insights

### M8 — Mind base

**60–90 h**
- MND-01 mood/stress,
- MND-02 breathing,
- MND-04 trends,
- MND-09 resource registry,
- SET-13 enforced privacy.

### M9 — Rule insights

**30–50 h**
- cross-module rule engine,
- reason codes,
- max 1/day,
- privacy source checks,
- dismiss/save/action.

### M10 — Screening, only if G-MH passes

**30–60 h engineering + external review time**
- MND-03,
- MND-10,
- exact validated questionnaire versions,
- separate safety flow,
- copy/resource tests.

If G-MH fails or is delayed, M10 is omitted. **v1.2 does not wait for it** unless product owner explicitly redefines scope.

### v1.2 baseline

**90–200 h engineering** depending on screening inclusion, plus clinical/regulatory/privacy review.

---

## 11. Traceability matrix

This is the machine-readable planning spine. No requirement may be considered implemented if it has no task/milestone.

### CORE

| Requirement | Task |
|---|---|
| CORE-01 | M0.4 |
| CORE-02 | M0.3 + production human gates |
| CORE-03 | M0.2 + LIFE-T01 |
| CORE-04 | M0.8 + R1.4 |
| CORE-05 | M0.8 + R1.4 |
| CORE-06 | M0.5 + LIFE-T04 |
| CORE-07 | LIFE-T04; expanded M5 |
| CORE-08 | M0.6 + LIFE-T04 |
| CORE-09 | M0.8 + R1.4 |
| CORE-10 | M0.12 + LIFE-T01/About |
| CORE-11 | all tasks + R1.3 |
| CORE-12 | M0.11 + R1.5 |

### EXERCISE

| Requirement | Task |
|---|---|
| EX-01 | C1–C5 + LIFE-T02 |
| EX-02 | M0.10 + C5 + LIFE-T02 |
| EX-03 | LIFE-T02 |
| EX-04 | LIFE-T02 |
| EX-05 | C3–C4 + LIFE-T02 |
| EX-06 | LIFE-T02 |
| EX-07 | LIFE-T02 |
| EX-08 | LIFE-T02 |
| EX-09 | LIFE-T02 |
| EX-10 | C3 + LIFE-T02 |
| EX-11 | G-LIC/design/content; SHOULD |
| EX-12 | post-v1.0 v1.1 backlog |
| EX-13 | WON'T |

### FITNESS

| Requirement | Task |
|---|---|
| FIT-01 | LIFE-T04 |
| FIT-02 | LIFE-T04 |
| FIT-03 | LIFE-T04 |
| FIT-04 | LIFE-T04 |
| FIT-05 | LIFE-T04 |
| FIT-06 | LIFE-T07 |
| FIT-07 | LIFE-T04 |
| FIT-08 | LIFE-T04 |
| FIT-09 | LIFE-T07 |
| FIT-10 | LIFE-T05 |
| FIT-11 | LIFE-T05 |
| FIT-12 | LIFE-T06 |
| FIT-13 | **v1.0.1** — poza LIFE-T06 w v1.0 |
| FIT-14 | WON'T — core logging is fast path |
| FIT-15 | LIFE-T03 |
| FIT-16 | LIFE-T08 |
| FIT-17 | v1.1 follow-up after M7 core |
| FIT-18 | v1.1 |
| FIT-19 | WON'T |
| FIT-20 | WON'T |
| FIT-21 | WON'T |
| FIT-22 | WON'T |
| FIT-23 | M0.5/M0.6 + LIFE-T04 |

### SETTINGS

| Requirement | Task |
|---|---|
| SET-01 | LIFE-T01 |
| SET-02 | LIFE-T01 |
| SET-03 | LIFE-T01 |
| SET-04 | M0.2 + LIFE-T01 |
| SET-05 | LIFE-T01 |
| SET-06 | LIFE-T01 + LIFE-T08 |
| SET-07 | LIFE-T01; region registry expanded M8 |
| SET-08 | LIFE-T01 |
| SET-09 | LIFE-T01 |
| SET-10 | R1.4 |
| SET-11 | M6/M7 |
| SET-12 | M7 |
| SET-13 | M8 |
| SET-14 | M5 |
| SET-15 | WON'T v1.x |

### LIFE COACH

| Requirement | Task |
|---|---|
| LC-01 | M7 |
| LC-02 | M7 |
| LC-03 | M7 |
| LC-04 | M7 SHOULD |
| LC-05 | M7 |
| LC-06 | M7 |
| LC-07 | M7 |
| LC-08 | M7 |
| LC-09 | M7 |
| LC-10 | M7 |
| LC-11 | M7 |
| LC-12 | M7 |
| LC-13 | M7 SHOULD |
| LC-14 | v1.2 backlog after separate safety scope |
| LC-15 | v1.2 backlog |
| LC-16 | v1.2 COULD |
| LC-17 | WON'T |
| LC-18 | WON'T |
| LC-19 | WON'T |
| LC-20 | WON'T |

### MIND

| Requirement | Task |
|---|---|
| MND-01 | M8 |
| MND-02 | M8 |
| MND-03 | M10 only after G-MH |
| MND-04 | M8 |
| MND-05 | WON'T |
| MND-06 | WON'T |
| MND-07 | WON'T |
| MND-08 | WON'T |
| MND-09 | M8 |
| MND-10 | M10 / safety gate |

---

## 12. Release and product gates

### G0 — M0 engineering

PASS:
- walking skeleton,
- durable draft,
- atomic idempotent commit,
- static i18n/auth proof,
- installed PWA smoke,
- green CI.

### G1 — Design / benchmark readiness

PASS:
- `G-DESIGN`,
- task specs frozen,
- visual baselines hashable,
- eval test env isolated.

### G2 — Core product after LIFE-T04

PASS:
- standard benchmark <60 s median in controlled user test or clearly trending after UX learning,
- zero deterministic data-loss scenarios,
- offline completion/reconnect works.

If fail: **optimize logging before History/Progress polish**.

### G3 — v1.0 beta

PASS for expansion:
- 10 P1 users,
- ≥7 activate,
- ≥5 complete 3 workouts/14d,
- 0 unrecoverable data-loss,
- critical user feedback triaged.

If fail: product review before v1.1.

### G4 — D30 interpretation

D30 is not judged from 10 people. Report:
- activated cohort denominator,
- confidence interval,
- activation rate,
- repeated cohort behavior.

Do not trigger a major pivot from a single-digit sample. Use D30 target ≥5% once sample is meaningful (preferably ≥100 activated or repeated cohorts).

### G5 — v1.1

PASS:
- generic sync conflicts safe,
- 7-day coach loop,
- Capacitor device gate,
- privacy review updated.

### G6 — v1.2

PASS:
- rule insight traceable,
- privacy enforcement,
- G-MH passed for any screeners included.

---

## 13. Risks — challenged version

| Risk | P | Impact | Mitigation / gate |
|---|---|---|---|
| v1.0 wedge still too similar to Hevy/Strong | High | High | user interviews + logging benchmark + offline reliability as wedge |
| LifeOS naming collision | High | High for public brand | BRAND-01 before irreversible brand spend |
| source image rights unclear | High enough to block | Medium/High | build excludes media until G-LIC |
| content enrichment becomes critical path | Medium | High | top-50 curated only; base 200–250 can ship without full tips |
| offline queue corrupts/duplicates workouts | Medium | Critical | aggregate command + idempotency + failure injection |
| generic sync silently overwrites | Medium | High | version/base_version, no LWW |
| PWA iOS behavior differs from browser assumptions | Medium | High | M0 real-device spike |
| auth provider/setup contaminates AgentOS score | High | Medium | pre-provision; classify infra/human gate separately |
| Agent optimizes for green test by weakening test | Medium | Critical for benchmark | monotonicity/forbidden rules |
| design arrives incomplete for edge states | High | Medium | G-DESIGN state inventory |
| solo owner becomes bottleneck despite autonomous agents | High | High | acceptance batches, frozen specs, max WIP |
| mental-health feature crosses regulatory boundary | Medium | Critical | MND-03 provisional + G-MH |
| health data leaks through logs | Medium | Critical | allowlist telemetry/redaction tests |
| over-optimistic timeline due AI assumptions | High | Medium | range baseline + actual re-estimation |
| scope creep returns | High | High | PRD ID + traceability + tradeoff required |

---

## 14. Work-in-progress policy for autonomous execution

Autonomy fails if eight agents create eight incompatible branches.

### 14.1 WIP

- one schema-changing feature at a time unless migrations proven independent,
- max 2 implementation tasks in parallel,
- single writer/merge owner per shared integration branch,
- critic/verifier may run parallel read-only,
- every task begins from recorded base SHA,
- stale task rebases/re-provisions; it does not freestyle merge.

### 14.2 Dependency order

**Product v1.0 — sześć zadań:**
`T01 → T02 → T04 → T07 → T05 → T06`

**AgentOS GO-A — kontynuacja w v1.0.1, do ośmiu próbek:**
`… → T03 → T08`

Why:
- settings/shell first,
- catalog before any workout references,
- logging creates truth for timer/history/progress,
- templates and export land last on a schema that is already stable.

Ta kolejność jest jedynym obowiązującym źródłem. Wcześniejsza wersja tego dokumentu podawała w tym miejscu ciąg ośmioelementowy z T03 i T08 wewnątrz v1.0 — jest nieaktualna po decyzji D-S.

For benchmark comparability freeze this order before first measured run.

### 14.3 Migration rule

TASK_SPEC explicitly states `allowed_migrations`. A task without migration permission cannot modify DB schema to make its implementation easier.

---

## 15. Documentation set

Keep documentation small but sufficient:

```text
README.md
docs/
  PRD.md
  ARCHITECTURE.md
  PLAN.md
  DECISIONS.md
  BACKLOG.md
  CONTENT.md
  DESIGN-HANDOFF.md
  SCHEMA.md          # generated
eval/
  task-specs/
  design-baselines/
  manifests/
```

### Rules

- no duplicate handwritten schema,
- no status claimed from documentation alone,
- backlog status changes at accepted merge,
- superseded decision remains as one small ADR entry, not copied archive trees,
- implementation result links `task_id`, commit SHA, PRD IDs, design IDs, tests/gates.

---

## 16. Backlog item schema

```yaml
id: LIFE-T04
title: Workout logging + offline completion
version: v1.0
prd_ids:
  - FIT-01
  - FIT-02
  - FIT-03
  - FIT-04
  - FIT-05
  - FIT-07
  - FIT-08
  - FIT-23
status: ready
depends_on:
  - M0
  - LIFE-T02
design_ids: []
architecture_refs:
  - ADR-17
  - ADR-18
risk: critical
owner: agent-os
human_gate:
acceptance_ref:
base_sha:
result_sha:
```

Allowed statuses:
`blocked · ready · in_progress · verify · ready_for_human · accepted · rejected`.

No percentage-complete field.

---

## 17. First practical execution sequence

### Block A — freeze and provision

1. owner reviews R-01/R-04/age/name gates,
2. create clean repo,
3. new Supabase,
4. secret rotation,
5. freeze dependency versions,
6. create docs/decisions.

### Block B — M0

Execute SPIKE-01…06 and green pipeline.

### Block C — design

While M0 runs, designer builds v1.0 UX. Do not start scored feature battery until design state inventory is frozen.

### Block D — benchmark preflight

- eval user,
- DB fixture,
- base SHA,
- TASK_SPEC validation,
- visual hashes,
- forbidden paths,
- one non-scored dry run.

### Block E — LIFE-T01…T08

Run according to AgentOS B6 rules, preserving:
- per-task result,
- cost,
- iterations,
- critic/gate outcome,
- human acceptance,
- regression status.

### Block F — R1

Integrated app/device/beta hardening.

### Block G — product decision

Only after real beta decide:
- continue v1.1,
- revise wedge,
- cut scope,
- stop.

---

## 18. What this plan explicitly does NOT promise

- App Store/Play approval by a date.
- A fixed 4-month v1.0.
- 25% productivity improvement from AI.
- That 200–250 source images are legally reusable.
- That „LifeOS” is clear as a public brand.
- That PHQ/GAD can ship safely just because questionnaires are available.
- That static export removes all Server Components.
- That PWA storage behaves identically in Safari tab and installed Home Screen app.
- That one generic timestamp conflict rule can solve offline sync.
- That a green autonomous benchmark equals product-market fit.

---

## 19. Readiness verdict encoded in the plan

### Documentation readiness after this review

- **PRD:** implementation-grade after G-PROD decisions.
- **Architecture:** implementation-grade after M0 spikes validate current library/platform assumptions.
- **Implementation plan:** taskable and traceable; AgentOS feature battery has explicit boundaries.
- **Visual design:** still missing; **G-DESIGN blocks scored feature implementation.**

### Overall

**CONDITIONAL GO to M0.**  
**NO-GO to full feature implementation until G-PROD + G-DESIGN.**  
**NO-GO to public mental-health screening until G-MH.**  
**NO-GO to source photos until G-LIC.**

This is deliberate. „Ready to build foundation” and „ready to autonomously implement the full product” are different states.
