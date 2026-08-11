# LifeOS — Architektura (PWA, Next.js + Supabase)

**Wersja dokumentu:** 1.0
**Data:** 2026-08-11
**Status:** Draft do przeglądu
**Powiązane:** `01-PRD.md` (co budujemy) · `03-IMPLEMENTATION-PLAN.md` (w jakiej kolejności)

---

## 1. Decyzje architektoniczne

Każda decyzja ma status. W poprzedniej wersji projektu istniało trzynaście decyzji architektonicznych bez statusu, przez co sześć z nich latami figurowało jako zatwierdzone, nie istniejąc w kodzie.

| ID | Decyzja | Status | Uzasadnienie |
|---|---|---|---|
| **D-01** | **Next.js (App Router) + React + TypeScript** | Accepted | Najdojrzalszy ekosystem PWA, najlepsze biblioteki do pracy offline, największa pula developerów i materiałów. Otwiera obie ścieżki na mobile: Capacitor i React Native |
| **D-02** | **Statyczny eksport (`output: 'export'`), pobieranie danych po stronie klienta** | Accepted | Patrz §2 — to najważniejsza decyzja techniczna tego projektu |
| **D-03** | **Supabase: Auth, PostgreSQL, reguły dostępu, funkcje brzegowe** | Accepted | Auth, baza i autoryzacja w jednym. Z poprzedniej wersji da się przenieść 66 reguł dostępu i pięć funkcji zgodności RODO — to realny dorobek. **Wymaga rotacji kluczy przed startem** |
| **D-04** | **Capacitor jako ścieżka na mobile, wdrożenie w v1.1** | Accepted | Ten sam kod trafia do sklepów. Odblokowuje powiadomienia, trwałe przechowywanie danych i biometrię. Koszt liczony w dniach |
| **D-05** | **TanStack Query jako warstwa danych, z zapisem cache w IndexedDB** | Accepted | Daje odczyt offline bez pisania własnego cache. Kluczowe: **wszystkie zapisy przechodzą przez jedną warstwę mutacji**, którą w v1.1 podmienimy na kolejkę offline |
| **D-06** | **Serwer jest źródłem prawdy; przeglądarka trzyma cache** | Accepted | W v1.1 to się zmienia dla danych treningowych — patrz §5 |
| **D-07** | **Tailwind CSS + shadcn/ui** | Accepted | Komponenty jako kod w repozytorium, nie zależność. Pełna kontrola nad dostępnością i motywem. Zero narzutu w czasie wykonania |
| **D-08** | **Zod jako jedno źródło definicji kształtu danych** | Accepted | Walidacja formularzy, walidacja odpowiedzi API i typy TypeScript z jednej definicji. Eliminuje rozjazd typów, który w poprzedniej wersji dał 728 błędów kompilacji |
| **D-09** | **Serwis roboczy: Serwist** | Accepted | Aktywnie utrzymywany następca `next-pwa`, dobra integracja z App Routerem |
| **D-10** | **next-intl dla EN i PL, od pierwszego commita** | Accepted | Dołożenie tłumaczeń później do katalogu dwustu ćwiczeń jest wielokrotnie droższe |
| **D-11** | **Wywołania AI wyłącznie przez funkcję brzegową** | Accepted (wdrożenie v1.1) | Bez tego nie da się chronić klucza, egzekwować limitów ani mierzyć kosztów |
| **D-12** | **Szyfrowanie end-to-end odłożone do v2.0** | Accepted | Model z opakowaniem klucza i kodem odzyskiwania. Poprzednia wersja miała klucz pochodzący wprost z hasła, co oznaczało utratę danych przy resecie hasła |
| **D-13** | **Monorepo jednopakietowe na start** | Accepted | Podział na pakiety dopiero gdy pojawi się drugi konsument logiki (aplikacja mobilna w React Native). Przedwczesny podział to koszt bez korzyści |

---

## 2. Kluczowa decyzja: statyczny eksport zamiast renderowania serwerowego

To jest decyzja, która determinuje resztę architektury, więc wymaga osobnego uzasadnienia.

**Problem.** Capacitor pakuje aplikację jako **statyczne zasoby** ładowane z urządzenia. Next.js z renderowaniem serwerowym i komponentami serwerowymi wymaga działającego serwera Node. Te dwie rzeczy są w konflikcie. Można wskazać Capacitorowi zdalny adres, ale wtedy aplikacja nie działa offline i ryzykuje odrzuceniem w App Store jako „cienka nakładka na stronę".

**Decyzja.** Budujemy w trybie `output: 'export'`. Cała aplikacja to statyczne pliki, dane pobierane po stronie klienta bezpośrednio z Supabase, autoryzacja przez sesję w przeglądarce.

**Co tracimy:** renderowanie serwerowe, komponenty serwerowe, optymalizację obrazów Next.js (zastąpiona statycznymi zasobami), trasy API (zastąpione funkcjami brzegowymi Supabase).

**Dlaczego to nie boli.** Cała aplikacja jest za logowaniem. Renderowanie serwerowe służy przede wszystkim indeksowaniu w wyszukiwarkach i szybkiemu pierwszemu wyświetleniu treści publicznej — tutaj nie ma treści publicznej. Powłoka aplikacji jest cache'owana przez serwis roboczy, więc ponowne wejście jest szybsze niż przy renderowaniu serwerowym.

**Konsekwencja praktyczna:** strona marketingowa (landing, cennik, polityka prywatności) to **osobny projekt** — może być statyczna, może być renderowana serwerowo, nie ma znaczenia. Aplikacja żyje pod adresem `app.domena` i jest w całości statyczna.

**Warunek brzegowy:** jeśli zapadnie decyzja o rezygnacji z Capacitora i pozostaniu przy samej PWA, decyzję D-02 można odwrócić — ale wtedy trzeba to zrobić **przed** M2, nie po.

---

## 3. Stack

### 3.1 Zależności produkcyjne

| Obszar | Wybór | Rola |
|---|---|---|
| Framework | `next` | App Router, tryb statycznego eksportu |
| Język | `typescript` | Tryb ścisły, `noUncheckedIndexedAccess` włączone |
| UI | `react`, `tailwindcss`, `shadcn/ui`, `lucide-react` | Komponenty jako kod w repozytorium |
| Dane serwerowe | `@tanstack/react-query` + `@tanstack/query-sync-storage-persister` | Cache, ponawianie, zapis do IndexedDB |
| Przechowywanie lokalne | `dexie` | Katalog ćwiczeń i cache zapytań |
| Backend | `@supabase/supabase-js`, `@supabase/ssr` | Baza, autoryzacja, funkcje brzegowe |
| Formularze | `react-hook-form` + `zod` + `@hookform/resolvers` | |
| Schematy | `zod` | Jedno źródło typów i walidacji |
| Wykresy | `recharts` | Prostsze niż visx, wystarczające dla trzech typów wykresów |
| Tłumaczenia | `next-intl` | EN i PL |
| Daty | `date-fns` | Lżejsze niż alternatywy, obsługa lokalizacji |
| Stan klienta | `zustand` | Wyłącznie stan interfejsu (aktywny trening, otwarte panele). Stan serwerowy należy do TanStack Query |
| Serwis roboczy | `@serwist/next` | Cache powłoki i zasobów |
| Monitoring | `@sentry/nextjs` | Błędy w czasie wykonania |

**Zasada:** zależność wchodzi do projektu w tej wersji, w której powstaje funkcja jej używająca. W poprzedniej wersji pięć bibliotek produkcyjnych miało **zero użyć w kodzie**, powiększając paczkę i powierzchnię ataku.

### 3.2 Narzędzia deweloperskie

`vitest` + `@testing-library/react` (testy jednostkowe i komponentów) · `playwright` (testy end-to-end) · `msw` (mockowanie sieci **wyłącznie w testach**) · `eslint` + `@typescript-eslint` · `prettier` · `supabase` CLI (migracje lokalne) · `gitleaks` (skanowanie sekretów).

---

## 4. Struktura projektu

```
/
├── app/                          ← Next.js App Router
│   ├── [locale]/
│   │   ├── (auth)/               ← logowanie, rejestracja, reset hasła
│   │   ├── (app)/                ← aplikacja za logowaniem
│   │   │   ├── layout.tsx        ← nawigacja dolna, wspólna powłoka
│   │   │   ├── dashboard/
│   │   │   ├── workout/
│   │   │   ├── exercises/
│   │   │   ├── history/
│   │   │   ├── progress/
│   │   │   └── settings/
│   │   └── layout.tsx
│   └── manifest.ts               ← manifest PWA
│
├── features/                     ← logika biznesowa, jedna konwencja
│   ├── exercises/
│   │   ├── api/                  ← zapytania i mutacje (TanStack Query)
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── schemas/              ← Zod
│   │   └── lib/                  ← czysta logika, testowalna bez Reacta
│   ├── workouts/
│   │   └── lib/
│   │       ├── one-rep-max.ts    ← wzór Epleya
│   │       ├── pattern-memory.ts ← pamięć wzorca
│   │       ├── pr-detection.ts   ← wykrywanie rekordów
│   │       └── progression.ts    ← podwójna progresja (v1.1)
│   ├── measurements/
│   ├── settings/
│   ├── life-coach/               ← v1.1
│   └── mind/                     ← v1.2
│
├── lib/
│   ├── supabase/                 ← klient, typy generowane ze schematu
│   ├── db/                       ← Dexie: katalog, cache
│   ├── mutations/                ← ⚠ JEDNA WARSTWA ZAPISU — patrz §5
│   ├── format/                   ← jednostki, daty, liczby
│   ├── i18n/
│   └── errors/
│
├── components/ui/                ← shadcn/ui
├── messages/                     ← en.json, pl.json
├── data/exercises/               ← katalog jako dane statyczne + wersja
├── supabase/
│   ├── migrations/               ← JEDNO źródło prawdy o schemacie
│   └── functions/                ← funkcje brzegowe
├── e2e/                          ← Playwright
└── docs/
```

**Zasady egzekwowane automatycznie, nie w przeglądzie kodu:**

| Reguła | Kontrola |
|---|---|
| Zero danych testowych w kodzie produkcyjnym | `msw` i `*.mock.ts` dozwolone wyłącznie w `**/__tests__/**` i `e2e/` — reguła ESLint |
| Zero `TODO` w ścieżkach zapisu | Lista wyjątków w pliku; reszta blokuje scalenie |
| Import między modułami tylko przez `features/<x>/api` | `eslint-plugin-boundaries` |
| Zero sekretów | `gitleaks` |
| Zero błędów typów | `tsc --noEmit` jako warunek scalenia |
| Rozmiar paczki | Budżet w `size-limit`, przekroczenie blokuje |

Ostatnia reguła o zerowej liczbie błędów typów jest kluczowa: poprzednia wersja projektu osiągnęła **728 błędów analizatora** i nikt tego nie zauważył, bo proces budowania i tak był czerwony, więc przestano na niego patrzeć.

---

## 5. Warstwa danych — najważniejszy szczegół implementacyjny

`[Z-1]` w PRD przesądza, że v1.0 ma offline tylko do odczytu, a zapis offline wchodzi w v1.1. **Cała ta sekcja istnieje po to, żeby ta zmiana kosztowała podmianę jednego modułu, a nie przebudowę aplikacji.**

### 5.1 Odczyt

```
Komponent → useQuery (TanStack Query) → Supabase
                    ↓
            cache w pamięci
                    ↓
            zapis do IndexedDB (persister)
```

Cache przeżywa odświeżenie strony i zamknięcie karty. Przy braku sieci zapytania zwracają dane z cache i oznaczają je jako nieaktualne. Katalog ćwiczeń jest osobnym przypadkiem — leży w Dexie na stałe, nie w cache zapytań, bo jest duży i praktycznie niezmienny.

### 5.2 Zapis — jedna brama

**Każdy zapis w aplikacji przechodzi przez `lib/mutations/`. Żaden komponent i żaden hook nie wywołuje Supabase bezpośrednio w celu zapisu.** To jest reguła egzekwowana lintem.

```ts
// lib/mutations/index.ts — v1.0
export async function executeMutation<T>(m: Mutation<T>): Promise<Result<T>> {
  if (!navigator.onLine) {
    // v1.0: odmowa z zachowaniem danych w szkicu (patrz 5.3)
    return { ok: false, error: 'offline' }
  }
  return runOnServer(m)
}
```

```ts
// lib/mutations/index.ts — v1.1, po podmianie
export async function executeMutation<T>(m: Mutation<T>): Promise<Result<T>> {
  await writeLocal(m)          // zapis lokalny natychmiast
  await outbox.enqueue(m)      // kolejka do wysyłki
  return { ok: true, data: optimistic(m) }
}
```

Reszta aplikacji nie zmienia się ani o linijkę. To jest cała różnica między „dołożymy offline w v1.1" a „przepiszemy aplikację w v1.1".

**Wymagania dla mutacji od pierwszego dnia:**
- Każda mutacja jest **idempotentna** i ma identyfikator generowany po stronie klienta (UUID v7 — sortowalny po czasie). Bez tego kolejka w v1.1 będzie duplikować rekordy przy ponowieniach.
- Każda mutacja jest **serializowalna** (zwykły obiekt, bez domknięć i referencji). Bez tego nie da się jej zapisać w kolejce.
- Aktualizacje optymistyczne z wycofaniem przy błędzie — to daje odczucie zapisu poniżej 100 ms.

### 5.3 Zabezpieczenie przed utratą pracy w v1.0

Aktywny trening jest trzymany w Zustand z zapisem do `localStorage` przy każdej zmianie. Przy braku sieci:
1. Użytkownik widzi wyraźny baner „Brak połączenia — trening zapisany lokalnie, wyślemy go automatycznie".
2. Dane pozostają w przeglądarce po zamknięciu karty.
3. Po powrocie sieci aplikacja proponuje wysłanie.

To nie jest pełna kolejka synchronizacji — nie obsługuje konfliktów ani wielu urządzeń. To zabezpieczenie przed najgorszym scenariuszem: użytkownik traci godzinę pracy, bo w siłowni nie było zasięgu.

### 5.4 Konflikty

W v1.1, gdy wchodzi zapis offline: **wygrywa ostatni zapis, porównanie po `updated_at` ustawianym przez serwer**. Każda synchronizowana tabela ma `updated_at`, `deleted_at` — bez wyjątków. W poprzedniej wersji jedna z tabel nie miała `updated_at`, przez co mechanizm rozstrzygania konfliktów zawsze przegrywał po pierwszej edycji lokalnej.

---

## 6. Model danych

**PostgreSQL (migracje SQL) jest jedynym źródłem prawdy.** Typy TypeScript są **generowane** ze schematu (`supabase gen types`), nigdy pisane ręcznie. Dokumentacja schematu jest generowana, nie pisana.

W poprzedniej wersji istniały trzy niezgodne opisy schematu: 36 tabel w bazie serwerowej, 20 w lokalnej o innych nazwach i kształcie, plus trzecia wersja w dokumentacji.

### 6.1 Zasady

1. **Prawdziwe klucze obce.** Ćwiczenie w serii jest referencją do katalogu, nie tekstem.
2. **Identyfikator użytkownika obowiązkowo** na każdej tabeli użytkownika. W poprzedniej wersji brakowało go w tabeli planów dnia, przez co była niesynchronizowalna z regułami dostępu.
3. **Jednolite metadane** na każdej tabeli: `created_at`, `updated_at`, `deleted_at`. Bez wyjątków.
4. **Koniec z JSON-em w polu tekstowym** dla danych, po których się filtruje. JSON wyłącznie dla treści dopisywanej (historia wiadomości).
5. **Jedna migracja początkowa.** Reguły dostępu przenoszone z poprzedniej wersji — to najcenniejszy istniejący artefakt techniczny.
6. **Identyfikatory generowane po stronie klienta** (UUID v7), nie przez bazę. Warunek konieczny dla aktualizacji optymistycznych i dla kolejki offline.

### 6.2 Tabele v1.0

| Tabela | Rola | Kluczowe pola |
|---|---|---|
| `user_profiles` | profil | full_name, avatar_url, date_of_birth, gender |
| `user_settings` | **wszystkie ustawienia w jednym miejscu** | jednostki, motyw, język, prywatność, preferencje coachingowe |
| `exercises` | katalog | category, exercise_type, primary_muscles[], secondary_muscles[], equipment[], movement_pattern, difficulty, tracks, default_rest_seconds, is_custom, created_by |
| `exercise_translations` | tłumaczenia | exercise_id, locale, name, description, instructions, form_tips[], common_mistakes[] |
| `exercise_favorites` | ulubione | unikalne (user_id, exercise_id) |
| `workouts` | sesja treningowa | started_at, completed_at, duration, total_volume, template_id |
| `workout_exercises` | ćwiczenie w sesji | workout_id, **exercise_id (klucz obcy)**, order_index, notes |
| `workout_sets` | seria | workout_exercise_id, set_number, weight, reps, duration, rpe, is_warmup, rest_seconds |
| `personal_records` | rekordy | user_id, exercise_id, estimated_1rm, achieved_at, workout_id |
| `body_measurements` | pomiary | dziesięć pól plus notatka |
| `workout_templates` | szablony | name, category, difficulty, estimated_duration |

**Kluczowa zmiana:** trójpoziomowa struktura `workouts → workout_exercises → workout_sets` z **kluczem obcym do katalogu**. Poprzednia wersja miała płaską strukturę z nazwą ćwiczenia jako wolnym tekstem. To była przyczyna źródłowa co najmniej sześciu osobnych problemów: rozbita historia, niedziałająca pamięć wzorca, niemożliwe wykrywanie rekordów, brak statystyk per partia mięśniowa, brak filtrowania historii, kruche szablony.

**Kompromis dla szybkiego logowania:** dopuszczamy pusty `exercise_id` z zapisaną nazwą surową dla ćwiczeń wpisanych doraźnie, z późniejszym scaleniem. Ale ścieżka domyślna to wybór z katalogu.

### 6.3 Tabele dokładane później

**v1.1:** `check_ins`, `goals`, `goal_progress`, `daily_plans`, `plan_tasks`, `streaks`, `user_daily_metrics`, `sync_outbox`
**v1.2:** `mood_logs`, `breathing_sessions`, `mental_health_screenings`, `insights`

Tabela powstaje w wersji, w której powstaje funkcja jej używająca. Poprzednia wersja miała 36 tabel, z których większość nigdy nie została ani zapisana, ani odczytana.

---

## 7. Autoryzacja i bezpieczeństwo

### 7.1 Sesja

Supabase Auth z sesją po stronie klienta (`localStorage`), automatyczne odświeżanie tokenu. Trasy chronione przez komponent-strażnik w układzie `(app)` — przy statycznym eksporcie nie ma pośrednika serwerowego, więc ochrona jest po stronie klienta **plus reguły dostępu w bazie**. To jest bezpieczne, bo prawdziwa autoryzacja dzieje się w bazie, a nie w interfejsie.

Metody: e-mail z hasłem, Google, Apple. Ostatnia jest wymagana, jeśli aplikacja trafi do App Store z logowaniem społecznościowym.

### 7.2 Reguły niepodlegające negocjacji

1. **Żaden klucz z uprawnieniami administracyjnymi nie może istnieć w kodzie klienta.** Wyłącznie jako sekret funkcji brzegowej. W poprzedniej wersji taki klucz — omijający wszystkie reguły dostępu — znajdował się w kodzie i w historii repozytorium.
2. **Żaden klucz API dostawcy AI nie może istnieć w kodzie klienta.** W poprzedniej wersji klucz był dołączany do paczki aplikacji.
3. **Konfiguracja wyłącznie przez zmienne środowiskowe.** Klucz publiczny Supabase może być w kliencie — taka jest jego rola, chroni go warstwa reguł dostępu.
4. **Reguły dostępu włączone na każdej tabeli użytkownika**, bez wyjątku, weryfikowane testem.
5. **Skanowanie sekretów** jako blokujący krok procesu budowania.

### 7.3 Warstwa AI (v1.1)

Funkcja brzegowa `ai-orchestrator`, około stu linii:

```
weryfikacja tokenu → sprawdzenie dziennego limitu → wywołanie modelu
   → zapis zużycia i kosztu → zwiększenie licznika → zwrot odpowiedzi
```

**Konsekwencje:**
- Klucze API wyłącznie jako sekrety funkcji.
- Limity dzienne (biznesowe) po stronie serwera; ograniczanie częstotliwości (przeciw nadużyciom) po stronie klienta. Poprzednia wersja miała tylko to drugie, myląc je z pierwszym.
- **Definicje kontekstu w bazie danych, nie w kodzie.** W poprzedniej wersji były stałą w kodzie — zmiana wymagała wydania nowej wersji aplikacji.
- Wymuszony format odpowiedzi JSON. Poprzednia wersja polegała wyłącznie na instrukcji tekstowej, co było głównym źródłem błędów przetwarzania.
- Jeden dostawca na start. Routing między modelami dopiero gdy istnieje monetyzacja, która to uzasadnia.

---

## 8. PWA

### 8.1 Manifest i instalacja

Tryb pełnoekranowy, orientacja pionowa, ikony w wymaganych rozmiarach, ekran startowy. **Zachęta do instalacji pojawia się kontekstowo — po pierwszym zapisanym treningu, nie przy pierwszym wejściu.** Prośba o instalację, zanim użytkownik zobaczył wartość, obniża konwersję.

### 8.2 Strategie cache'owania

| Zasób | Strategia |
|---|---|
| Powłoka aplikacji (HTML, JS, CSS) | Precache przy instalacji, aktualizacja przy nowej wersji |
| Katalog ćwiczeń (dane statyczne) | Precache, wersjonowany |
| Ilustracje ćwiczeń | Cache-first z limitem rozmiaru |
| Dane użytkownika z Supabase | Network-first, cache jako zapas; źródłem prawdy jest cache TanStack Query w IndexedDB |
| Czcionki | Cache-first, hostowane lokalnie (nie z zewnętrznego CDN — prywatność i niezawodność) |

### 8.3 Aktualizacje

Wykrycie nowej wersji pokazuje nienachalny pasek „Dostępna nowa wersja — odśwież". Nigdy automatyczne przeładowanie w trakcie pracy — użytkownik może być w środku logowania treningu.

### 8.4 Ograniczenia iOS do odnotowania

Safari na iOS może usunąć dane lokalne po około siedmiu dniach nieużywania. `navigator.storage.persist()` jest przyznawany wybiórczo — wywołujemy go po instalacji i po pierwszym treningu. Powiadomienia web push wymagają iOS 16.4+ **i** dodania do ekranu głównego. Wszystkie te ograniczenia znikają po przejściu na Capacitora w v1.1.

---

## 9. Ścieżka na mobile (Capacitor, v1.1)

Warunki, które trzeba respektować **od pierwszego dnia**, żeby ta ścieżka pozostała otwarta:

| Warunek | Dlaczego |
|---|---|
| Statyczny eksport (D-02) | Capacitor ładuje pliki z urządzenia |
| Zero zależności od tras API Next.js | Nie istnieją w trybie statycznym; logika serwerowa idzie do funkcji brzegowych |
| Nawigacja bez `next/navigation` w warstwie krytycznej | Routing oparty na plikach działa, ale ścieżki muszą być względne |
| Odwołania do `window` i `document` zabezpieczone | Kod musi znieść środowisko bez DOM podczas budowania |
| Bezpieczne obszary ekranu w układzie | Wycięcia i pasek gestów na iOS |
| Cele dotykowe minimum 44 px | Wymóg wytycznych obu platform |

Co Capacitor dodaje w v1.1: trwałe przechowywanie danych bez ryzyka usunięcia · powiadomienia lokalne i push · biometria · dostęp do danych zdrowotnych (v2.0) · obecność w sklepach.

Co dochodzi jako koszt: proces wydawniczy w dwóch sklepach · natywne zakupy zamiast płatności webowych w wersji sklepowej · testy na realnych urządzeniach.

---

## 10. Testy

| Poziom | Narzędzie | Zakres |
|---|---|---|
| Czysta logika | Vitest | **Obowiązkowo:** wzór 1RM, wykrywanie rekordów, pamięć wzorca, przeliczanie jednostek, agregacja objętości. To są funkcje bez zależności — testy są tanie, a błąd tutaj psuje dane użytkownika |
| Komponenty | Vitest + Testing Library | Formularze, walidacja, stany błędów i pustych list |
| Integracja danych | Vitest + MSW | Zapytania i mutacje, zachowanie przy braku sieci |
| End-to-end | Playwright | Ścieżki krytyczne, w tym **jedna z wyłączoną siecią** |
| Dostępność | axe w testach Playwright | Automatyczne wykrywanie naruszeń |

**Zamiast progu pokrycia od pierwszego dnia** (poprzednia wersja miała próg 75% przy realnych 12%, przez co proces budowania był stale czerwony i przestano na niego patrzeć):

| Etap | Wymaganie |
|---|---|
| Od M0 | **Zielony proces budowania.** Zero błędów typów, testy przechodzą |
| M0 | Jeden test end-to-end: logowanie → nawigacja → zapis → odświeżenie → odczyt |
| Od M2 | 100% pokrycia dla czystej logiki w `features/*/lib/` |
| Od M3 | Próg pokrycia 50%, podnoszony co wersję |

---

## 11. Proces budowania i wdrożenia

Trzy zadania zamiast dziesięciu. Poprzednia wersja miała pipeline droższy niż projekt, który i tak nie przechodził.

| Zadanie | Zawartość |
|---|---|
| `verify` | Formatowanie · lint z regułami granic modułów · `tsc --noEmit` (**zero błędów jako warunek scalenia**) · testy jednostkowe · `gitleaks` · budżet rozmiaru paczki |
| `e2e` | Playwright na wersji podglądowej, w tym scenariusz offline |
| `deploy` | Wersja podglądowa dla każdej gałęzi, produkcja z gałęzi głównej |

Hosting: Vercel albo Cloudflare Pages — przy statycznym eksporcie różnica jest kosmetyczna. Migracje bazy przez Supabase CLI w osobnym, ręcznie zatwierdzanym kroku.

---

## 12. Zadania do wykonania przed pierwszym commitem

| # | Zadanie | Powód |
|---|---|---|
| 1 | **Rotacja klucza administracyjnego i publicznego Supabase** | Klucz omijający wszystkie reguły dostępu znajduje się w historii repozytorium poprzedniej wersji |
| 2 | **Rotacja klucza OpenAI** | Był dołączany do paczki aplikacji |
| 3 | Decyzja: import katalogu ćwiczeń z otwartej bazy czy produkcja własna | Ścieżka krytyczna; wymaga weryfikacji licencji |
| 4 | Wyznaczenie właściciela produkcji treści | W poprzedniej wersji zadania contentowe wisiały sprintami bez właściciela |
| 5 | Potwierdzenie założeń `[Z-1]`…`[Z-12]` z PRD | Zmiana teraz kosztuje akapit, później migrację danych |
| 6 | Rejestracja domeny i rozdzielenie `app.` od strony marketingowej | Wynika z decyzji D-02 |

---

## 13. Czego świadomie nie robimy

**Renderowania serwerowego i komponentów serwerowych** — konflikt z Capacitorem, zerowa korzyść dla aplikacji za logowaniem.
**Własnej warstwy synchronizacji w v1.0** — poprzednia próba dała osiemset linii martwego kodu obsługującego jedną tabelę z sześciu.
**Podziału na pakiety monorepo** — dopóki nie ma drugiego konsumenta logiki, to koszt bez korzyści.
**Biblioteki komponentów jako zależności** — shadcn/ui daje kod w repozytorium, więc dostępność i motyw są pod pełną kontrolą.
**Własnego systemu tłumaczeń** — `next-intl` wystarcza i jest utrzymywany.
**Analityki w v1.0** — poza jedną metryką: mediana czasu logowania treningu. To metryka funkcji kluczowej i musi być mierzona od pierwszego dnia. Reszta dochodzi, gdy będzie co analizować.
