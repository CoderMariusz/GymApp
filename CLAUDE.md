# Repozytorium `lifeos` — instrukcja dla agentów

> **Zanim napiszesz linijkę kodu, przeczytaj `docs/DECISIONS.md`.** Ustala hierarchię
> dokumentów i mówi, co wolno robić teraz, a co jest zablokowane bramką.

## Czym to jest

**Dziennik treningu siłowego.** Nie coach, nie sieć społecznościowa, nie licznik kalorii.
Jedno zdanie, które rozstrzyga spory projektowe:

> Użytkownik nie patrzy na ten ekran. On na niego **zerka** — stojąc przy stojaku, między
> seriami, z telefonem w jednej ręce.

Budżet: sesja 6 ćwiczeń / 18 serii zapisana w **poniżej 60 sekund** aktywnej interakcji.

`LifeOS` to **nazwa repozytorium, nie nazwa produktu.** Decyzja D-Q ją porzuciła (kolizje w
sklepach). Kandydaci: Datum, Rung, Ballast. Bramka BRAND-01 otwarta — w kodzie i dokumentach
używaj znacznika `PRODUCT_NAME`, nie wpisuj nazwy na stałe.

## Hierarchia dokumentów — przy konflikcie wygrywa wyższy

```
1. docs/DECISIONS.md      ← decyzje i ich status
2. docs/PRD.md            ← co ma działać
3. docs/ARCHITECTURE.md   ← jak wolno to zbudować
4. zaakceptowany DESIGN   ← .claude/skills/lifeos-strength-design/
5. TASK_SPEC              ← zamrożony kontrakt jednego zadania
6. docs/PLAN.md           ← kolejność i nakład
```

`docs/reviews/` **nigdy** nie rozstrzyga konfliktu — jest historyczny i niewiążący.
`docs/DESIGN-BRIEF.md` jest **wejściem do designu, nie designem**.

## Stack — nie negocjuj go lokalnie

| Warstwa             | Wybór                                              | ADR            |
| ------------------- | -------------------------------------------------- | -------------- |
| Framework           | Next.js 16 App Router, React 19, TypeScript strict | ADR-01         |
| Build               | `output: 'export'` — statyczny, zero runtime Node  | ADR-02         |
| Backend             | Supabase: Auth + PostgreSQL + RLS + Edge Functions | ADR-03         |
| Stan zdalny         | TanStack Query (to **cache**, nie źródło prawdy)   | ADR-05, ADR-07 |
| Stan lokalny trwały | Dexie/IndexedDB — aktywny trening, outbox, katalog | ADR-06         |
| Stan ulotny         | Zustand — wyłącznie interakcja UI                  | §4.2           |
| Style               | Tailwind 4 + tokeny systemu designu                | ADR-08         |
| Walidacja           | Zod na granicach aplikacji                         | ADR-09         |
| PWA                 | Serwist                                            | ADR-10         |
| i18n                | next-intl, ścieżki `/en`, `/pl`, bez middleware    | ADR-11         |
| Natywne             | Capacitor — **dopiero v1.1**                       | ADR-04         |

**TypeScript jest przypięty na 6.0.3, nie 7.** TS 7 wywraca `typescript-eslint`
(wspiera `>=4.8.4 <6.1.0`). ESLint na 9.x z tego samego powodu. Nie podbijaj bez sprawdzenia.

## Czego nie wolno — `ARCHITECTURE.md` §23

- zapisu do Supabase z komponentu lub hooka **poza `lib/mutations/`**,
- danych treningu wyłącznie w Zustand albo `localStorage`,
- kolejki offline wiersz po wierszu dla agregatu treningu w v1.0,
- generycznego LWW po `updated_at`,
- `exercise_id` jako nullable + surowa nazwa w `workout_exercises`,
- ręcznie utrzymywanych typów TS dla bazy (mają być generowane),
- zdjęć ćwiczeń ze źródła bez bramki proweniencji,
- surowych treści zdrowotnych/mentalnych w Sentry,
- obejścia autoryzacji dla benchmarku w buildzie produkcyjnym,
- zależności od middleware przy `output: 'export'`,
- nazywania cache'u TanStack Query „źródłem prawdy".

**Nie twórz katalogów dla funkcji, które nie istnieją** (ADR-27). W v1.0 **nie ma**
`features/templates/`, `features/measurements/`, `app/[locale]/(app)/templates/`,
kolumny `workouts.template_id` ani `features/life-coach/` i `features/mind/`.
Git ma pokazywać prawdę.

## Sześć stanów synchronizacji — CORE-07

`draft_local` → `queued` → `syncing` → `saved`, z `failed` i `conflict` jako gałęziami.

**`draft_local` ≠ `queued`.** Pierwszy znaczy „trening w toku, bezpiecznie na urządzeniu,
celowo jeszcze niewysłany". Pokazanie przy nim „czeka na wysłanie" sugeruje awarię tam,
gdzie system działa poprawnie. Nazwy są dokładnie te — tak samo w PRD, w systemie designu
(`SyncBadge`) i w `messages/*.json`. Test `lib/i18n/messages.test.ts` tego pilnuje.

Uwaga: `sync_outbox.status` w Dexie (`queued | sending | failed | attention`) to **mechanika
kolejki**, osobna od stanu UI. Nie mieszaj tych dwóch słowników.

## Agregat treningu — najważniejszy kontrakt w projekcie

Trening zapisuje się **jednym atomowym poleceniem**, nigdy zestawem żądań:

- `CommitWorkout` — utworzenie (ADR-18),
- `UpdateWorkoutAggregate` — edycja, **pełne zastąpienie dzieci**, `base_version` (ADR-28),
- `DeleteWorkout` — miękkie usunięcie + przeliczenie rekordów (ADR-28).

Dzieci agregatu (`workout_exercises`, `workout_sets`) **nie mają własnego `user_id` ani
`version`** — autoryzacja i współbieżność idą przez korzeń (ADR-29). RLS na dzieciach
sprawdza własność złączeniem z korzeniem.

Funkcje RPC domyślnie `SECURITY INVOKER`. `SECURITY DEFINER` tylko z ustawionym
`search_path` i `EXECUTE` odebranym `PUBLIC` (ADR-30).

## Design

Autorytetem jest skill **`.claude/skills/lifeos-strength-design/`** — wywołaj go przez
`/lifeos-strength-design`. Zawiera tokeny, 24 komponenty React, ekrany i reguły marki.
Tokeny CSS są skopiowane do `styles/tokens/` i ładowane w `app/globals.css`; **nie edytuj
ich ręcznie** — zmieniaj w skillu i kopiuj ponownie.

Dwanaście rzeczy, których złamanie jest defektem, a nie preferencją, jest w `readme.md`
tego skilla, §6. Najczęściej łamane: pięć zakładek i ani jednej więcej, Ustawienia **nie
są** zakładką, kolor nigdy nie niesie znaczenia sam, 44 px minimum, timer nie zasłania pola
wprowadzania, `queued` czyta się jako norma a nie błąd.

## Struktura

```
app/[locale]/(auth|app)/   trasy; layout w [locale] jest layoutem korzenia
features/<nazwa>/          import wyłącznie przez index.ts — ESLint tego pilnuje
lib/                       supabase · local-db · mutations · sync · auth · i18n · format · analytics · errors
components/{ui,system}     wspólne komponenty
messages/                  en.json · pl.json — klucze muszą być identyczne
data/catalog/              zbudowany katalog ćwiczeń (paczka statyczna, nie Storage)
scripts/catalog/           potok 0-snapshot → 8-validate
supabase/                  migrations · seed · tests · functions
e2e/                       Playwright — przeciw statycznemu buildowi, nie dev serverowi
eval/                      task-specs · fixtures · design-baselines (benchmark AgentOS)
```

## Polecenia

```bash
npm run dev         # serwer deweloperski
npm run build       # statyczny eksport do out/
npm run verify      # format + lint + typecheck + testy + katalog + skan sekretów
npm run test        # Vitest
npm run e2e         # Playwright przeciw out/
```

## Zasada dowodu

Wyrenderowana strona nie jest dowodem — strona otwiera się też wtedy, gdy funkcja pod spodem
jest zepsuta. Dowodem jest **trwały stan**: wiersz w bazie, wpis w IndexedDB, plik na dysku.

Zanim uznasz test za bramkę, **zobacz go na czerwono**: zepsuj to, czego pilnuje, i sprawdź,
że pada. Bramka, która nie umie się zaczerwienić, melduje bezpieczeństwo, którego nie ma.

## Język

Odpowiadaj po polsku. Kod, nazwy, komentarze w kodzie i dokumenty w `docs/` — po angielsku,
zgodnie z tym, co już tam jest.
