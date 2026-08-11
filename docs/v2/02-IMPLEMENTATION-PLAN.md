<!-- AI-INDEX: plan-implementacji, architektura, stack, fazy, milestones, model-danych, testy, ci, definition-of-done -->

# LifeOS — Plan implementacji v2

**Status:** Draft do przeglądu
**Data:** 2026-08-11
**Podstawa:** `01-PRD.md` (wymagania) + `00-ANALYSIS-FINDINGS.md` (czego nie powtarzać)

---

## 1. Zasada nadrzędna: walking skeleton przed architekturą

**Milestone 0 blokuje wszystko pozostałe.** Zanim powstanie druga funkcja, musi działać pełna ścieżka:

```
flutter run → logowanie → bottom nav → zapis treningu → restart aplikacji
           → trening widoczny z kompletem serii → zielone CI
```

W v1 zbudowano 13 decyzji architektonicznych, 206 dokumentów, 36 tabel i 380-linijkowy pipeline CI, po czym okazało się, że ~200 z 217 plików jest nieosiągalnych z interfejsu. Kolejność „funkcje najpierw, integracja później" była głównym mechanizmem porażki. Ten plan ją odwraca.

---

## 2. Stack

Cel: **z 42 do ~20 zależności produkcyjnych.**

### 2.1 Zostaje

| Warstwa | Wybór | Uwaga |
|---|---|---|
| Framework | Flutter, Dart | **Wersje przypięte dokładnie**, nie zakresem |
| Stan i DI | Riverpod 3.x | **Wyłącznie codegen (`@riverpod`).** Zero ręcznych `Provider<>` |
| Baza lokalna | Drift | Z prawdziwymi kluczami obcymi |
| Backend | Supabase | Auth + Postgres + RLS + Edge Functions |
| Nawigacja | go_router | **Jeden plik**, `StatefulShellRoute` dla bottom nav |
| Modele | freezed 3.x | Pattern matching Dart 3 (`switch`), **nigdy `when`/`map`** |
| HTTP | dio | `http` usunięty |
| Wykresy | fl_chart | |
| Testy | mocktail | `mockito` usunięty (nie wymaga codegenu) |
| i18n | flutter_localizations + ARB | **Od pierwszego commita** |

### 2.2 Wypada z v1.0

`posthog_flutter`, `flutter_stripe`, `in_app_purchase`, `encrypt`, `firebase_*`, `just_audio` + `audio_service` + `just_audio_background` + `audio_session`, `lottie`, `shimmer`, `flutter_animate`, `http`, `mockito`.

Pięć pierwszych miało w v1 **zero użyć w kodzie**. Zależność wraca w wersji, w której powstaje funkcja jej używająca — nie wcześniej.

### 2.3 Decyzje architektoniczne — werdykt wobec v1

| v1 | Werdykt | Uzasadnienie |
|---|---|---|
| D1 Clean Architecture per feature | **Powtórzyć**, wymusić jedną konwencję w CI | W v1 współistniały 4 warianty układu folderów |
| D2 Wspólny model + mirror w Drift | **Przemyśleć** — mirror generowany, nie pisany ręcznie | 36 tabel w Postgresie vs 20 w Drifcie o innych nazwach |
| D3 Offline sync własny | **Zmienić realizację** — patrz §5 | 800 linii martwego kodu, 1 tabela z 6, bug runtime |
| D4 AI przez Edge Function | **Powtórzyć decyzję, odrzucić implementację** | Funkcja nigdy nie powstała; klucz trafiał do binarki |
| D5 E2EE | **Odłożyć do v2.0**, model key-wrapping | Nie istniał; kolidował z odzyskiwaniem hasła |
| D6 Feature-first providery | **Zmienić** — provider definiowany dokładnie raz | Dwie instancje SQLite w jednym procesie |
| D7 Shared core + rozszerzenia modułów | **Powtórzyć** | |
| D8 Bezpośredni CRUD + Edge Functions do logiki | **Powtórzyć** | Sensowny, tani model |
| D9 Motyw per moduł | **Zmienić** — jeden design system, akcent kolorystyczny per moduł | Komplikacja bez wartości |
| D10 Feature flags jako enum | **Zmienić** na flagi zdalne | Enum kompilowany wymaga release'u |
| D11 Sync oportunistyczny | **Powtórzyć** | |
| D12 FCM | **Odłożyć** — przypomnienia lokalne w v1.1 | Firebase był i tak zakomentowany |
| D13 Własny LRU cache | **Zmienić** — biblioteka + limit katalogu | Overengineering |

---

## 3. Struktura projektu — jedna konwencja

```
lib/
├── main.dart
├── app.dart                        ← MaterialApp.router, JEDEN router
├── l10n/                           ← ARB, EN + PL od dnia 1
├── core/
│   ├── database/                   ← Drift, JEDEN appDatabaseProvider
│   ├── network/                    ← dio + klient Supabase
│   ├── error/                      ← JEDEN Result<T>, sealed
│   ├── router/                     ← JEDEN plik, StatefulShellRoute
│   ├── theme/
│   ├── auth/
│   ├── settings/                   ← UserSettings jako współdzielona infrastruktura
│   ├── sync/
│   └── format/                     ← UnitFormatter, DateFormatter
└── features/<nazwa>/
    ├── data/{models,datasources,repositories}
    ├── domain/{entities,repositories,usecases}
    └── presentation/{pages,providers,widgets}
```

**Zasady egzekwowane w CI, nie w code review:**

| Reguła | Kontrola |
|---|---|
| Zero klas `Mock*` w `lib/` | `grep -rn "class Mock" lib/ && exit 1` |
| Zero `TODO` w ścieżkach zapisu | Lista wyjątków w pliku, reszta blokuje merge |
| `presentation/pages/`, nigdy `screens/` | Sprawdzenie struktury katalogów |
| Zero podfolderów feature-w-feature | jw. |
| Provider zdefiniowany raz, nazwa unikalna globalnie | Detekcja duplikatów |
| Zero sekretów | `gitleaks` |
| `flutter analyze` = **0 błędów** | Warunek merge'u |

Ostatnia reguła jest kluczowa: w v1 projekt osiągnął **728 błędów analizatora** i nikt tego nie zauważył, bo CI i tak było czerwone i przestano na nie patrzeć.

---

## 4. Model danych

`[Z]` **PostgreSQL (migracje SQL) jest jedynym źródłem prawdy.** Schemat Drift weryfikowany względem niego w CI, nigdy pisany niezależnie. Dokumentacja schematu **generowana**, nie pisana ręcznie.

### 4.1 Zasady

1. **Prawdziwe klucze obce** w Drifcie (`references()`), nie luźne kolumny tekstowe.
2. **`user_id` obowiązkowo** na każdej tabeli użytkownika. W v1 brakowało w `daily_plans` — tabela była niesynchronizowalna z RLS.
3. **Jednolite metadane sync** na każdej synchronizowanej tabeli: `updated_at`, `is_synced`, `deleted_at`. Bez wyjątków — w v1 istniały trzy różne warianty i tabela bez `updated_at`, przez co last-write-wins nie działał.
4. **Koniec z JSON-w-stringu** dla danych, po których się filtruje. JSON wyłącznie dla treści append-only (wiadomości czatu).
5. **Jedna migracja `0001_init.sql`** na start. Skasować `migrations/sprint-0/`, drugi initial schema i skrypty Node.
6. **Przenieść 66 polityk RLS** z v1 — najcenniejszy istniejący artefakt techniczny.

### 4.2 Tabele v1.0 — 11 sztuk

| Tabela | Rola | Kluczowe pola |
|---|---|---|
| `user_profiles` | profil | full_name, avatar_url, date_of_birth, gender |
| `user_settings` | **wszystkie ustawienia w jednym miejscu** | jednostki, motyw, locale, prywatność, preferencje coachingowe |
| `exercises` | katalog | category, exercise_type, primary/secondary_muscles[], equipment[], movement_pattern, difficulty, tracks, default_rest_seconds, is_custom, created_by |
| `exercise_translations` | i18n | exercise_id, locale, name, description, instructions, form_tips[], common_mistakes[] |
| `exercise_favorites` | ulubione | unique(user_id, exercise_id) |
| `workouts` | sesja | started_at, completed_at, duration, total_volume, template_id? |
| `workout_exercises` | ćwiczenie w sesji | workout_id, **exercise_id (FK)**, order_index, notes |
| `workout_sets` | seria | workout_exercise_id, set_number, weight, reps, duration, rpe, is_warmup, rest_seconds |
| `personal_records` | rekordy | user_id, exercise_id, estimated_1rm, achieved_at, workout_id |
| `body_measurements` | pomiary | 10 pól + notatka |
| `workout_templates` | szablony | name, category, difficulty, estimated_duration |
| `sync_outbox` | kolejka | table_name, record_id, operation, payload, priority, retry_count, next_attempt_at |

**Kluczowa zmiana wobec v1:** trójpoziomowa struktura `workouts → workout_exercises → workout_sets` z **kluczem obcym do katalogu ćwiczeń**. W v1 była płaska `WorkoutLogs → ExerciseSets` z nazwą ćwiczenia jako wolnym tekstem. To była przyczyna źródłowa co najmniej sześciu osobnych luk: rozbita historia, niedziałający pre-fill, niemożliwa detekcja PR, brak statystyk per partia mięśniowa, brak filtrowania historii, kruche szablony.

**Kompromis dla szybkiego logowania:** dopuszczamy `exercise_id NULL + exercise_name_raw` dla ćwiczeń wpisanych ad hoc, z późniejszym scaleniem. Ale ścieżka domyślna to wybór z katalogu.

### 4.3 Tabele dokładane w kolejnych wersjach

**v1.1:** `check_ins`, `goals`, `goal_progress`, `daily_plans`, `plan_tasks`, `streaks`, `user_daily_metrics`
**v1.2:** `mood_logs`, `breathing_sessions`, `mental_health_screenings`, `insights`

Tabela powstaje w wersji, w której powstaje funkcja jej używająca. W v1 istniało 36 tabel, z których większość nigdy nie została zapisana ani odczytana.

---

## 5. Offline i synchronizacja

`[Z-1]` przesądza, że offline-write jest wymagane. Pytanie brzmi: jak.

| Opcja | Ocena |
|---|---|
| **A. Gotowa biblioteka** (PowerSync / Brick) | **Rekomendowana.** Rozwiązuje dokładnie problem, na którym v1 poległo. Koszt: zależność + krzywa uczenia. Wymaga tygodnia spike'u przed decyzją |
| B. Minimalny własny outbox | Akceptowalna, jeśli spike wypadnie źle. Zakres ograniczony do tabel fitness w v1.0 |
| C. Własny sync jak w v1 | **Odrzucona.** Poprzednia próba: 800 linii, 1 obsłużona tabela z 6, bug runtime, zero działania |

**Jeśli B — wymagania minimalne:**
outbox zasilany **z repozytoriów, nie z UI** · priorytety (0 = auth, 1 = treningi, 2 = reszta) · backoff wykładniczy z limitem retry i przejściem do stanu „wymaga uwagi" · `updated_at` ustawiany po stronie serwera · **test integracyjny per synchronizowana tabela** · widoczny stan synchronizacji w interfejsie.

Z v1 przenosimy `ConflictResolver` (3 strategie, ~121 linii) — jedyny naprawdę dobrze napisany plik tamtego modułu.

---

## 6. Warstwa AI

Zaczyna się w **v1.1**, nie wcześniej. Wtedy pierwszym zadaniem — przed jakąkolwiek funkcją Life Coacha — jest Edge Function `ai-orchestrator`.

**Minimalny zakres (~100 linii TypeScript):**
weryfikacja JWT → sprawdzenie dziennego limitu w tabeli → wywołanie modelu → zapis zużycia tokenów i kosztu → inkrementacja licznika → zwrot odpowiedzi.

**Konsekwencje architektoniczne:**
- Klucze API **wyłącznie** jako sekrety funkcji. Zero kluczy w kliencie, zero w assetach.
- Limity dzienne (biznesowe) po stronie serwera; rate limiting (anty-nadużycie) po stronie klienta. W v1 istniał tylko drugi rodzaj, mylnie traktowany jako pierwszy.
- **Prompty w bazie danych, nie w binarce.** W v1 prompt był stałą w Darcie — zmiana wymagała wydania nowej wersji aplikacji.
- Wymuszony `response_format: json_object`. W v1 poprawność parsowania opierała się wyłącznie na instrukcji tekstowej.
- Jeden dostawca (OpenAI) w v1.1. Routing per tier i fallback do innych modeli — dopiero gdy istnieje monetyzacja, która to uzasadnia. Deklarowany w v1 „Hybrid AI" jako differentiator nigdy nie istniał w kodzie.

---

## 7. Fazy

Estymaty w tygodniach pracy jednej osoby. Zakładam **zero przenoszenia kodu z v1** poza wskazanymi artefaktami.

### M0 — Walking skeleton · 2 tyg. · BLOKUJE WSZYSTKO

Nowy projekt · przypięte wersje · analysis_options ze `strict-casts` · i18n (EN+PL) z jednym stringiem na dowód działania · Supabase z **zrotowanymi kluczami** · `0001_init.sql` z RLS · Drift z 3 tabelami · auth (email + Google + Apple) · **jeden router z bottom nav** · ekran ustawień ze zmianą motywu i języka · CI: analyze (0 błędów) + test + gitleaks.

**Wyjście:** logowanie → nawigacja → zmiana motywu utrwalona po restarcie → zielone CI.

### M1 — Katalog ćwiczeń · 2 tyg.

Schemat z pełną taksonomią · bundled JSON (200–250 pozycji, EN+PL) + seeding z wersjonowaniem · FTS5 + debounce · filtry z interfejsem · szczegóły · ulubione · CRUD ćwiczeń własnych · tryb pickera.

**Wyjście:** katalog przeszukiwalny **z wyłączonym internetem**, wynik < 200 ms.

**Uwaga:** produkcja treści (200–250 ćwiczeń × 2 języki) to zadanie **contentowe, nie programistyczne**. Musi mieć osobnego właściciela i biec równolegle od M0, inaczej stanie się ścieżką krytyczną. W v1 „20+ szablonów" figurowało jako „In Progress" przez trzy sprinty przy zerowym postępie właśnie dlatego.

### M2 — Logowanie treningu · 3 tyg.

Struktura `workouts → workout_exercises → workout_sets` · wybór ćwiczenia z katalogu · pola zależne od `tracks` · **Smart Pattern Memory jako automatyczny pre-fill** · timer przerwy z auto-startem, haptyką i dźwiękiem · serie rozgrzewkowe · pomiar czasu sesji · **detekcja PR** · ekran podsumowania · Quick Log.

**Wyjście:** trening zalogowany offline w < 60 s, po restarcie widoczny **z kompletem serii**. W v1 serie zapisywano z pustym `workoutLogId` — trening był formalnie zapisany, a jego zawartość nieodzyskiwalna.

### M3 — Historia i postęp · 2 tyg.

Lista historii + filtr po ćwiczeniu + szczegóły · edycja i soft delete · wykresy (1RM, objętość tygodniowa, oś PR) z filtrami czasu · pomiary ciała z pełnym formularzem i trendami · `UnitFormatter` wpięty wszędzie · eksport CSV.

**Wyjście:** wykresy na **realnych danych użytkownika**. Zero mocków w `lib/` — weryfikowane w CI.

### M4 — Domknięcie v1.0 · 2 tyg.

Szablony (presety + tworzenie z treningu + start z szablonu) · synchronizacja wg §5 · pełny ekran ustawień · GDPR (eksport, usunięcie konta z rate limitem serwerowym) · disclaimer i zasoby kryzysowe · przegląd dostępności · testy integracyjne · beta.

**v1.0 = ~11 tygodni.**

### M5 — Life Coach · 4 tyg. · v1.1

`ai-orchestrator` **przed czymkolwiek innym** · poranny check-in (nastrój, energia, jakość snu, godziny snu) z CTA · generowanie planu + **deterministyczny plan awaryjny** · realizacja zadań · wieczorna refleksja z przeglądem planu · cele z UI postępu · preferencje w bazie · streak · zapis metryk dziennych.

**Wyjście:** pełna pętla działa 7 dni z rzędu; plan awaryjny działa przy odciętym API; **żaden klucz API nie występuje w binarce** (weryfikowane rozpakowaniem APK).

### M6 — Mind + cross-module regułowy · 3 tyg. · v1.2

Mood i stress tracking · 5 technik oddechowych z animacją i haptyką · GAD-7/PHQ-9 z progami kryzysowymi · wykres trendu · 4 reguły cross-module · **toggle prywatności realnie blokujący zapis metryk**.

**Wyjście:** insight pojawia się po 7 dniach danych z 2 modułów.

---

## 8. Kolejność zależności

```
M0 fundament
 ├─→ M1 katalog ćwiczeń ──→ M2 logowanie ──→ M3 historia i postęp ──→ M4 v1.0
 │        ↑                                                              │
 │   produkcja treści (równolegle od M0)                                 │
 └─→ core/settings (w M0, bo konsumowany przez wszystko)                 │
                                                                         ↓
                                              M5 Life Coach (v1.1) ──→ M6 Mind (v1.2)
                                                    ↑
                                              ai-orchestrator
```

**Dwie zależności, które w v1 odwrócono z fatalnym skutkiem:**
1. **Ustawienia przed modułami**, które z nich korzystają. W v1 `UserPreferences` był mockiem karmiącym generator planów AI — każdy użytkownik dostawał plan pod godziny 09:00–17:00.
2. **Katalog ćwiczeń przed logowaniem treningu.** W v1 logowanie powstało pierwsze i użyło wolnego tekstu; katalog powstał później jako moduł-sierota bez jednej referencji z zewnątrz.

---

## 9. Testy

Zamiast progu 75% (nieosiągalnego, powodującego czerwone CI, a w efekcie ignorowanie CI):

| Faza | Wymaganie |
|---|---|
| Od M0 | **CI zielone.** `flutter analyze` = 0 błędów, `flutter test` przechodzi |
| M0 | 1 test E2E: logowanie → nawigacja → zapis → restart → odczyt |
| Od M2 | 100% use case'ów i repozytoriów (czysta logika, tanie testy) |
| Od M3 | Próg pokrycia **50%**, podnoszony co wersję |

**Zawsze wymagany test:** migracje bazy · rozwiązywanie konfliktów sync · **obliczenia 1RM i detekcja PR** · parsowanie odpowiedzi AI · konwersja jednostek.

W v1 cztery z ośmiu testów killer feature'u miały **puste ciała z komentarzem** — cała logika progresji była nieprzetestowana przy deklarowanym celu 85% pokrycia. Dodatkowo `test/widget_test.dart` był niezmienionym szablonem odwołującym się do nieistniejącej klasy `MyApp`, co blokowało `flutter test` w całości.

---

## 10. CI

Z 10 jobów do 3. Poprzedni pipeline (Trivy, pana, analiza rozmiaru APK, build iOS na macOS) był droższy niż projekt i tak nie przechodził.

| Job | Zawartość |
|---|---|
| `analyze` | `dart format --set-exit-if-changed` · `build_runner` · `flutter analyze` (**0 błędów = warunek merge**) · `gitleaks` · reguły strukturalne z §3 |
| `test` | `flutter test --coverage`, próg wg §9 |
| `build-android` | debug APK na PR |

Build iOS, testy integracyjne na symulatorze i skanowanie bezpieczeństwa — dopiero przy realnym wydawaniu. Akcje w aktualnych wersjach, `dart run` zamiast `flutter pub run`.

---

## 11. Dokumentacja

Z 206 plików do 8. Struktura BMAD dała hierarchię, ale zachęciła do produkowania dokumentów szybciej niż kodu — 84% wylądowało w archiwum, a trzy sprzeczne audyty powstały w tym samym miesiącu.

```
README.md              ← setup, uruchomienie, komendy
CLAUDE.md              ← kontekst dla AI (v1 miał dobry, zachować)
docs/PRD.md            ← 01-PRD.md
docs/NFR.md            ← wydzielone z PRD, gdy urośnie
docs/ARCHITECTURE.md   ← jeden plik: stack, warstwy, decyzje ze statusem
docs/SCHEMA.md         ← generowany z migracji
docs/DECISIONS.md      ← ADR: data, kontekst, decyzja, konsekwencje, status
docs/BACKLOG.md        ← jedna lista, jeden status na pozycję
```

**Zasady zapobiegające powtórce:**
- **Każda decyzja architektoniczna ma status:** `Proposed` / `Accepted` / `Implemented` / `Superseded`. Decyzje D1–D13 w v1 nigdy nie miały statusu, więc sześć z nich latami figurowało jako zatwierdzone, nie istniejąc w kodzie.
- **Status wywodzi się z kodu.** Pozycja w backlogu jest odhaczana przy merge'u, nie przy planowaniu.
- **Zero plików MD w katalogu głównym** poza README i CLAUDE. W v1 było ich 12, w tym `EPIC_IMPLEMENTATION_STATUS.md` na 27 KB.
- **Nie archiwizuj — usuwaj.** Git pamięta. `5-ARCHIVE/` ze 163 plikami to koszt bez wartości.
- **Nie pisz dokumentu opisującego kod, którego nie ma.** `ARCH-ai-infrastructure.md` miał 439 linii opisu Edge Function, która nigdy nie powstała — i przez rok wyglądała jak zrealizowana architektura.

---

## 12. Zadania do wykonania przed pierwszym commitem

| # | Zadanie | Powód |
|---|---|---|
| 1 | **Rotacja klucza `service_role` i anon key Supabase** | Klucz omijający wszystkie 66 polityk RLS jest w historii Git |
| 2 | **Rotacja klucza OpenAI** | Był dystrybuowany w assetach aplikacji |
| 3 | Decyzja: import katalogu ćwiczeń z otwartej bazy vs produkcja własna | Ścieżka krytyczna M1; wymaga weryfikacji licencji |
| 4 | Spike na PowerSync/Brick (1 tydz.) | Przesądza opcję A lub B w §5 |
| 5 | Potwierdzenie założeń `[Z-1]`…`[Z-12]` z `01-PRD.md` | Zmiana teraz jest tania |
| 6 | Wyznaczenie właściciela produkcji treści | W v1 zadania contentowe wisiały sprintami bez właściciela |

---

## 13. Podsumowanie harmonogramu

| Wersja | Zakres | Czas | Skumulowany |
|---|---|---|---|
| v1.0 | Fundament + Exercise + Fitness + Settings | ~11 tyg. | 11 tyg. |
| v1.1 | Life Coach + AI przez serwer | ~4 tyg. | 15 tyg. |
| v1.2 | Mind + cross-module regułowy | ~3 tyg. | 18 tyg. |

Nie zawiera: produkcji treści (równolegle), buforu na nieprzewidziane (~20%), procesu wydawniczego w sklepach.

**Punkt kontrolny po v1.0:** jeśli retencja D30 < 3%, kolejne funkcje nie są odpowiedzią. Odpowiedzią jest zmiana produktu.
