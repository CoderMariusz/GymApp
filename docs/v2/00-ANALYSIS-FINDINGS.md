<!-- AI-INDEX: analiza, audyt, findings, lessons-learned, dług-techniczny, rozjazd-dokumentacji, przebudowa -->

# Analiza projektu LifeOS v1 — ustalenia przed przebudową

**Data:** 2026-08-11
**Metoda:** 5 równoległych analiz (Fitness, Life Coach, Exercise+Settings, Mind+przekrojowe, Architektura) na pełnym drzewie `lib/` (217 plików Dart), `docs/` (194 pliki MD), `supabase/migrations/` (15 plików SQL), `test/` (27 plików).
**Cel:** wyciągnąć założenia produktowe warte przeniesienia i zidentyfikować mechanizmy porażki, których nie wolno powtórzyć. To nie jest code review — kod jest porzucany.

---

## 1. Diagnoza w jednym zdaniu

Projekt nie upadł na złych decyzjach architektonicznych. Upadł na tym, że zbudowano **13 decyzji architektonicznych, 206 dokumentów, 36 tabel PostgreSQL, 66 polityk RLS i 380-linijkowy pipeline CI dla aplikacji, która nigdy nie miała działającego ekranu głównego.**

Trasa `/home` prowadzi do klasy `HomePlaceholder` renderującej `Text('Home Screen - See other feature branches')`. Klasa `HomeScreen` z `BottomNavigationBar` nie jest referencjonowana z żadnego miejsca w kodzie. **Około 200 z 217 plików Dart jest nieosiągalnych z poziomu interfejsu.**

---

## 2. Stan faktyczny vs deklarowany

| Moduł | Deklaracja w dokumentacji | Stan faktyczny |
|---|---|---|
| Fitness | 82–90% ("najlepszy moduł") | UI istnieje, ale killer feature na mocku, serie zapisywane jako sieroty, brak trasy |
| Life Coach | 55–75% (6/10 stories ✅ Done) | Nie kompiluje się (niezgodności typów), brak trasy, check-in nie zbiera danych o śnie |
| Mind | 25–40% | ~4 z 30 wymagań działa |
| Exercise | 20% | Moduł-sierota, zero integracji z fitness, tworzenie ćwiczeń pokazuje fałszywy komunikat sukcesu |
| Settings | 25–80% (epic mówi 80%) | To nie jest moduł ustawień — zawiera wyłącznie GDPR. Zero z 20 kluczy ustawień ma model Dart |
| Onboarding | 7/7 stories "Complete" | `OnboardingPlaceholder` z tekstem "To be implemented in Epic 7" |
| Gamifikacja | 83% | 5% — istnieje sama tabela `Streaks` |
| Cross-Module Intelligence | jednocześnie "Deferred" i "kryterium sukcesu MVP" | 5% — istnieje sama tabela `UserDailyMetrics` |
| Powiadomienia | 0% | 0% — jedyny obszar, gdzie dokumentacja jest zgodna z kodem |

**Trzy pokolenia sprzecznych audytów.** `MVP-SCOPE-ANALYSIS.md` otwiera się nagłówkiem *„poprzedni audit był częściowo błędny"* i koryguje `MVP-AUDIT-REPORT.md`. Ten drugi pozostał niezmieniony i nadal jest linkowany z `project-status.md` jako źródło prawdy. Oba są dziś nieaktualne — twierdzą, że `meditation_player_screen.dart` nie istnieje, podczas gdy plik ma 471 linii.

**Wniosek metodologiczny:** statusy przypisywano na podstawie **istnienia pliku**, a nie działającej ścieżki użytkownika. To jedyna przyczyna, dla której projekt przez rok raportował 45–66% gotowości przy zerowej liczbie funkcji osiągalnych z aplikacji.

---

## 3. Blokery bezpieczeństwa — do naprawy niezależnie od przebudowy

| # | Problem | Lokalizacja | Skutek |
|---|---|---|---|
| S1 | **Klucz `service_role` Supabase w kodzie klienta** | `lib/core/config/supabase_config.dart`, jako `defaultValue` w `String.fromEnvironment` | Omija wszystkie 66 polityk RLS. Jest w historii Git. **Wymaga natychmiastowej rotacji** |
| S2 | **Anon key + URL projektu w repo** | jw. | Rotacja |
| S3 | **Klucz OpenAI dystrybuowany z aplikacją** | `.env` wpisany w `pubspec.yaml:118` jako asset Fluttera | Możliwy do wydobycia z APK/IPA. Rotacja + przeniesienie na serwer |

Punkt S3 jest bezpośrednim złamaniem własnej decyzji architektonicznej D4 („API keys never exposed to client"). Deklarowana Edge Function `ai-orchestrator`, która miała to realizować, **nigdy nie powstała**.

---

## 4. Mechanizmy porażki — czego nie powtarzać

### 4.1 Mocki w ścieżkach produkcyjnych
Cztery mocki zasilały produkcyjny kod:
- `MockWorkoutRepository` → **Smart Pattern Memory i wszystkie trzy wykresy postępu**. Mock generuje syntetyczną progresję (+2,5 kg co sesję) i sztywne PR-y. To jest killer feature produktu działający na wymyślonych danych.
- `MockPreferencesRepository` → `DailyPlanGenerator` i `GoalSuggester`. Każdy użytkownik dostaje plan zbudowany pod godziny pracy 09:00–17:00 i obszary fitness/productivity/wellness.
- `MockCheckInRepository` → jedyne źródło danych o śnie w całej aplikacji, zwracające na sztywno `mood: 7, energy: 8, sleepQuality: 7`.
- `MockGoalsRepository` → część metod rzuca `UnimplementedError`.

Mocki mieszkały w warstwie `domain/repositories/` — gotowe do przypadkowego użycia.

**Zasada na przyszłość:** żadna klasa `Mock*` poza `test/`. Egzekwowane w CI: `grep -r "class Mock" lib/ && exit 1`.

### 4.2 Migracja majorów bez migracji call-site'ów
Zakomitowane logi analizatora pokazują **1 454 issues, w tym 728 błędów**. Przyczyna nie jest brakiem codegenu (tylko 12 błędów to `uri_has_not_been_generated`), lecz podbiciem `riverpod` 2→3 i `freezed` 2→3 bez migracji kodu. `freezed` 3.0 usunął `when`/`map`, `riverpod_generator` 3.0 usunął typowane `Ref`.

**Zasada:** przypięte wersje major, migracja jako osobne, świadome zadanie z zielonym CI na końcu.

### 4.3 Duplikacja definicji
- `appDatabaseProvider` zdefiniowany **dwa razy** (`@riverpod` w core + ręczny `Provider` w `meditation_providers.dart`) → **dwie niezależne instancje SQLite w jednym procesie**.
- `goalsRepository` i `checkInRepository` zdefiniowane równolegle w dwóch miejscach.
- Dwa routery (`app_router.dart` używany, `router.dart` martwy).
- Dwie klasy o nazwie `WorkoutLog` bez mapperów.
- Dwa katalogi ekranów w module exercise (`screens/` z implementacją, `presentation/pages/` ze stubami).
- Dwa klienty HTTP (`http` + `dio`), dwie biblioteki mockujące (`mockito` + `mocktail`).
- Trzy systemy migracji (`supabase/migrations/` z **dwoma** initial schema, `migrations/sprint-0/`, skrypty Node w roocie).

Źródło: mieszanie dwóch stylów DI — **67 adnotacji `@riverpod` i 56 ręcznych `Provider<>`**.

### 4.4 Schemat bez jednego źródła prawdy
36 tabel w PostgreSQL, 20 w Drifcie, trzecia wersja w dokumentacji — o różnych nazwach i kształcie. „Drift mirror" nie jest mirrorem.

Konsekwencje:
- `ExerciseSets.exerciseName` to **wolny tekst**, nie FK. Literówka rozbija historię, statystyki, pre-fill i PR-y.
- `DailyPlans` **nie ma kolumny `user_id`** → niemożliwe do synchronizacji z RLS.
- Polityka RLS z dokumentacji odwołuje się do kolumny `user_id` w tabeli `exercises`, gdzie faktycznie jest `created_by` → polityka by nie zadziałała.
- Brak `updated_at` w `mood_logs`, więc last-write-wins używa `created_at` jako fallbacku i zawsze przegrywa po pierwszej edycji lokalnej.
- Ciężkie użycie JSON-w-stringu (`exercises`, `tasks_json`, `messages_json`) omijające typowanie i uniemożliwiające filtrowanie.

### 4.5 Sync jako martwy kod
~800 linii, z czego działa: nic.
- `SyncInitializer` **nigdy nie zamontowany** w `app.dart`.
- Kolejka **nigdy nie zasilana** — żadne repozytorium nie woła `enqueue*`.
- Realtime obsługuje **1 tabelę z 6** — reszta cicho porzuca zdarzenia.
- Bug runtime: `Future<int> ... as int` w liczniku retry rzuci przy pierwszym nieudanym sync.
- Brak priorytetów, backoffu i limitu retry.

Jedyny wartościowy plik: `conflict_resolver.dart` (121 linii, 3 strategie) — wart przeniesienia.

### 4.6 Dokumentacja rosnąca szybciej niż kod
**206 dokumentów na 217 plików Dart** (stosunek ~1:1), z czego 84% w archiwum. 12 plików MD w katalogu głównym ignorujących własną strukturę BMAD. Katalogi `3-ARCHITECTURE/` i `4-DEVELOPMENT/` puste, mimo że `BMAD-STRUCTURE.md` wymienia 7 nieistniejących plików. `ARCH-ai-infrastructure.md` (439 linii) opisuje szczegółowo Edge Function, która nigdy nie powstała — i przez rok wyglądała jak zrealizowana architektura.

### 4.7 Pięć zależności produkcyjnych z zerowym użyciem
`posthog_flutter`, `flutter_stripe`, `in_app_purchase`, `flutter_local_notifications`, `encrypt`.

Ostatnia jest znacząca: **E2EE nie istnieje**. Są tylko puste kolumny `encrypted_answers` / `encryption_iv`, mimo że decyzja D5 i NFR-S1 deklarują AES-256-GCM jako wymóg.

---

## 5. Sprzeczności produktowe wymagające rozstrzygnięcia

| # | Sprzeczność | Dowód |
|---|---|---|
| P1 | **Stripe vs IAP.** Tabela `Subscriptions` ma `stripeCustomerId`/`stripeSubscriptionId`. Dokumentacja mówi `in_app_purchase` + RevenueCat. Stripe za treści cyfrowe w apce mobilnej łamie regulaminy App Store i Google Play | `sprint0_tables.dart:73-74` vs `epic-7:231` |
| P2 | **Cztery skale ocen.** PRD Mind: 1–5. Life Coach encje i wykresy: 1–10. Slider: 1–10. `MoodLogs`: 1–5. Wszystkie mają się spotkać w `user_daily_metrics.mood_score` | `sprint0_tables.dart:148` vs `batch1_tables.dart:20-21` |
| P3 | **CMI jednocześnie poza MVP i kryterium sukcesu MVP** | `project-status.md:139` vs `PRD-overview.md:202` |
| P4 | **Trzy taksonomie tierów.** Kod: `free/mind/fitness/three_pack/plus`. PRD: `Free/Single Module/3-Module Pack/Full Access` | `sprint0_tables.dart:72` vs `PRD-overview.md:210` |
| P5 | **Hybrid AI jako differentiator #3** (Llama/Claude/GPT-4 z fallbackiem) vs jeden `OpenAIProvider` z `gpt-4o-mini` na sztywno w konstruktorze | `lib/core/ai/providers/` |
| P6 | **Analityka `DEFAULT TRUE`** (opt-out) vs NFR-C1 „Consent: opt-in analytics" | `001_initial_schema.sql:488` vs `PRD-nfr.md:264` |
| P7 | **Trzy terminy usunięcia konta:** 7 dni (README + UI + NFR-S3), 30 dni soft delete (ARCH-security). Plus tabela `users_pending_deletion`, która nie istnieje w żadnej migracji | |
| P8 | **Streak bez właściciela** — deklarowany jako driver retencji fitness, ale wypadł z PRD fitness i wylądował w Epic 6 (5% gotowości) | |
| P9 | **FR28 vs Story 2.6 AC3** — czy pominięcie check-inu łamie streak? Dokumentacja mówi obie rzeczy | |
| P10 | **Kolizja numeracji FR** — FR30-FR46 to fitness w aktualnym PRD, ale FR30-FR35 to streaki/powiadomienia w archiwalnym | |

---

## 6. Luki, o których dokumentacja milczy

1. **Recovery klucza E2EE.** Klucz derywowany z hasła użytkownika przez PBKDF2. Nigdzie nie opisano, co dzieje się z dziennikami po resecie hasła. Obecny `changePassword` nic z kluczem nie robi → **reset hasła = trwała utrata wszystkich wpisów**.
2. **Brak person.** Przeszukane całe `docs/` — zero person, scenariuszy, jobs-to-be-done. Cała definicja odbiorcy to jeden wiersz: „22-45, professionals, wellness enthusiasts". Onboarding „Choose your journey" (4 ścieżki) jest de facto segmentacją przerzuconą na użytkownika.
3. **Produkcja treści audio.** 24 medytacje na MVP + 105 w P1, „professional voice narration", aplikacja dwujęzyczna EN+PL → **podwójna produkcja**. Zero budżetu, dostawcy, licencji, harmonogramu. To najdroższy i najdłuższy element modułu Mind, całkowicie nieopisany.
4. **Definicja `sleep_quality`.** Dwie reguły CMI (FR78, FR80) opierają się na metryce, której nie ma w `UserDailyMetrics` ani w tabeli check-inów.
5. **Moderacja treści w CBT chat.** Progi kryzysowe istnieją tylko dla kwestionariuszy GAD-7/PHQ-9. Brak wymagań dotyczących wykrywania treści samobójczych w swobodnej rozmowie z AI — największe ryzyko prawne i etyczne produktu.
6. **i18n.** Brak `lib/l10n`, brak `flutter_localizations`, brak `AppLocalizations`. Cały UI zahardkodowany po angielsku, mimo że NFR-A4 wymaga EN + PL **w MVP**. Dla katalogu 200+ ćwiczeń retrofit i18n jest wielokrotnie droższy niż setup od pierwszego commita.
7. **Eksport zaszyfrowanego dziennika.** GDPR Art. 20 wymaga formatu maszynowego; użytkownik dostaje blob, którego nie odczyta.

---

## 7. Co warto przenieść — realny dorobek

Nie wszystko tu jest słabe. Te artefakty są dobrze przemyślane:

**Produktowe**
- **Struktura promptu planu dnia** (`daily_plan_prompt.dart`): reguły miksu kategorii (30% productivity / 25% fitness / 20% wellness / 15% personal / 10% social), mapowanie energii na porę dnia, budżet 6–8 h zadań, wymóg konkretności („30 min yoga + 10 min stretching", nie „exercise"). Najlepszy artefakt w całym module.
- **Pole `why` przy każdym zadaniu AI** — uzasadnienie buduje zaufanie i odróżnia produkt od zwykłej to-do listy.
- **Guardrail bezpieczeństwa w prompcie czatu:** *„Never diagnose mental health conditions"* + *„You're a coach, not a therapist."*
- **Zasady anty-fatigue:** max 1 insight dziennie, quiet hours 22:00–07:00, ton „encouraging, not guilt-tripping", streak freeze jako wentyl bezpieczeństwa.
- **Reguła „no paywall ever" dla mood trackingu** i darmowość narzędzi zdrowia psychicznego — etycznie słuszne i dobre marketingowo.
- **Darmowe wykresy postępu** jako świadoma przewaga cenowa (Strong i FitBod pobierają opłatę).
- **Algorytm progresji** (progi RPE 9,0 / 7,5 / 6,0; +2,5 kg powyżej 80 kg, +5 kg poniżej; deload ×0,9; cap 5 serii) — sensowna specyfikacja, wymaga tylko realnego źródła RPE.

**Techniczne**
- **66 polityk RLS** w `001_initial_schema.sql` — najbardziej wartościowy artefakt techniczny w repo.
- **5 Edge Functions** dla GDPR (924 linie TS): `delete-account`, `cleanup-deleted-accounts`, `export-user-data`, `process-mental-health-screening`, `generate-workout-plan-from-template`.
- **Wzorzec tabeli `MentalHealthScreenings`** z `encrypted_answers` + `encryption_iv` + `crisis_threshold_reached` + `crisis_modal_shown` — bezpieczeństwo wbudowane w schemat.
- **`ConflictResolver`** (3 strategie, porównanie po `updated_at`).
- **`AIProviderInterface`** — dobra abstrakcja; wszystko powyżej niej (routing, sekrety, koszty) do zbudowania na serwerze.
- **`Result<T>`** jako sealed class z typowanymi failure'ami.
- **Pipeline CMI:** debounce 5 min, cron tygodniowy zamiast dziennego (świadoma optymalizacja kosztów), próg `confidence > 0.7` dla notyfikacji.
- **Analiza kosztów AI** ($360/mies. przy 10k userów = 3,6% przychodu) — rzadka dyscyplina w PRD.
- **Kryteria GO/NO-GO** z jawnymi progami pivotu.
- **Wymagania wydajnościowe** — konkretne i mierzalne: pre-fill <500 ms p95, wyszukiwanie ćwiczeń <200 ms, zapis serii <100 ms, historia 90 dni <1 s, cold start <2 s.

**Do usunięcia bez żalu:** cały `docs/5-ARCHIVE/` (163 pliki), 12 plików MD z roota poza README i CLAUDE, `MVP-AUDIT-REPORT.md` (zdezawuowany własną korektą), `analyze_output*.txt` (570 KB), `migrations/sprint-0/`, skrypty Node do migracji.

---

## 8. Pytania blokujące, przeniesione z `MVP-SCOPE-ANALYSIS.md`

Wszystkie nadal `PENDING` po roku. Odpowiedzi znajdują się w `01-PRD.md` jako **przyjęte założenia** — jeśli któreś jest błędne, zmiana jest tania teraz i droga później.

1. Offline-write w MVP: tak czy nie?
2. Źródło bazy ćwiczeń: bundled JSON / zewnętrzne API / własna produkcja?
3. Źródło audio medytacji?
4. Czy AI jest w MVP 1.0?
5. Czy monetyzacja jest w horyzoncie 6 miesięcy?
6. Jedna platforma czy obie na start? (repo ma `android/`, `ios/`, `web/`, `windows/` przy zerze działających ekranów)

---

## 9. Trzy zasady dla przebudowy

1. **Definition of Done = osiągalny z aplikacji przepływ end-to-end na realnych danych.** Trasa w routerze + zapis do bazy + odczyt zwracający to, co zapisano + test. Istnienie klasy nie liczy się jako „Done".
2. **Walking skeleton przed architekturą.** Zanim powstanie druga funkcja: `flutter run` → logowanie → bottom nav → zapis treningu → widoczny po restarcie → zielone CI. Kolejność „features najpierw, integracja później" była głównym mechanizmem porażki.
3. **Status wywodzi się z kodu, nie z prozy.** Jedna lista w `BACKLOG.md`, jeden status na pozycję, aktualizowany przy merge'u, nie przy planowaniu.
