# LifeOS — Product Requirements Document

**Wersja:** 1.2 — po decyzjach właściciela z 2026-08-12  
**Data:** 2026-08-12  
**Status:** READY FOR M0 — **nie** ready do zamrożenia `TASK_SPEC`. Otwarte: **O-01** (offline, blokuje G-PROD), G-LIC, BRAND-01, G-DESIGN (design jeszcze nie istnieje)  
**Produkt:** greenfield, PWA-first, docelowo Capacitor  
**Odbiorcy dokumentu:** właściciel produktu, designer, Agent OS, developer/recenzent  
**Dokumenty powiązane:** `02ARCHITECTURE_REVIEWED.md`, `03IMPLEMENTATIONPLAN_REVIEWED.md`, `plan-testow-v2.md`

> Ten dokument zastępuje wersję 1.0 z 2026-08-11 jako kandydat do zatwierdzenia. Nie jest kosmetycznym rewrite'em. W miejscach, w których research lub analiza architektury obalały założenie, wymaganie zostało zmienione i oznaczone w Change Log.

---

## 0. Kontrakt dokumentu

### 0.1 Jak czytać wymagania

Priorytet MoSCoW obowiązuje **w obrębie wersji**:

- **MUST** — bez tego wersja nie wychodzi.
- **SHOULD** — może zostać przesunięte tylko decyzją właściciela produktu.
- **COULD** — wykonywane po MUST/SHOULD.
- **WON'T** — jawnie poza wersją.

Każde wymaganie ma trwały identyfikator: `CORE-*`, `EX-*`, `FIT-*`, `LC-*`, `SET-*`, `MND-*`. Identyfikator nigdy nie jest ponownie używany do innej funkcji.

**Definition of Done dla wymagania:** jest osiągalne z UI, działa na realnych danych, ma symetryczny zapis/odczyt, ma stany błędu/pusty/loading/offline tam gdzie dotyczą, ma test właściwej warstwy, spełnia wymagania dostępności i jest powiązane z co najmniej jednym `TASK_SPEC` w planie implementacji.

### 0.2 Zmiany krytyczne względem v1.0

| ID | Zmiana | Powód | Status do ratyfikacji |
|---|---|---|---|
| R-01 | **Zapis pełnego treningu offline wchodzi do v1.0.** Generic multi-entity sync pozostaje v1.1 | Główny ból P1 to siłownia bez zasięgu | **OPEN — patrz O-01.** Jedyne miejsce, w którym ta decyzja żyje |
| R-02 | „Lighthouse PWA = 100” usunięte | Lighthouse 12 usunął kategorię PWA. Zastępują ją konkretne testy instalowalności, manifestu, service workera i offline shell | **REQUIRED** |
| R-03 | `LifeOS` pozostaje nazwą roboczą, ale **publiczny brand wymaga hard gate przed brandingiem/sklepami** | W 2026 istnieje kilka aplikacji i usług o dokładnej lub bardzo zbliżonej nazwie LifeOS | **REQUIRED** |
| R-04 | PHQ-9/GAD-7 w v1.2 są **PROVISIONAL**, nie bezwarunkowe MUST | Wynik całkowity nie jest „progiem kryzysowym”; moduł wymaga osobnej walidacji kliniczno-regulacyjnej i bezpiecznej obsługi odpowiedzi o samouszkodzeniu | **REQUIRED** |
| R-05 | ~~minimalne tarcie + wiarygodny zapis offline~~ → **zastąpione przez D-N** | Recenzja nie sprawdziła, czy lider rynku już nie zapisuje offline. Materiały wtórne wskazują, że zapisuje | **SUPERSEDED** przez D-N |
| R-06 | Wymagania `CORE-*` dodane | Wersja 1.0 deklarowała namespace CORE, ale nie miała żadnego wymogu CORE; przez to shell/auth/offline/telemetria nie miały śladu PRD → task | Accepted |
| R-07 | Szczegółowe `form_tips/common_mistakes` nie są blokadą dla wszystkich 200–250 ćwiczeń | 1500–2500 ręcznie tworzonych mikrotreści nie mieściło się realnie w budżecie 24 h | Accepted |
| R-08 | Cel „<60 s” zdefiniowany jako **aktywny czas interakcji**, nie czas ścienny całego treningu | Użytkownik fizycznie ćwiczy i odpoczywa; poprzednia metryka była niemożliwa do interpretacji | Accepted |
| R-09 | AgentOS ma osobny **Evaluation Profile** | Zewnętrzne OAuth/DNS/store/legal nie mogą zanieczyszczać pomiaru „czy agent potrafi oddać feature end-to-end” | Accepted |

### 0.3 Decyzje właściciela produktu — stan po przeglądzie

| ID | Decyzja | Stan |
|---|---|---|
| D-A | PWA jako wejście, Capacitor jako ścieżka sklepowa | KEEP |
| D-B | Next.js + React + TypeScript | KEEP |
| D-C | Supabase | KEEP |
| D-D | v1.0 read-only offline | **Zastąpione przez O-01** — jedna otwarta decyzja, nie trzy |
| D-E | `free-exercise-db` jako źródło bazowego katalogu | KEEP, ale fotografie zablokowane do potwierdzenia praw |
| D-F | Monetyzacja poza horyzontem 12 miesięcy | KEEP; politykę sklepów weryfikujemy ponownie przy wdrożeniu v2 |
| D-G | EN + PL od v1.0 | KEEP |
| D-H | Jedna osoba + asystent/Agent OS | KEEP |
| D-I | Około 20 h/tydzień czasu właściciela | KEEP; nie zakładamy automatycznie kompresji AI |
| D-J | Nazwa LifeOS | KEEP jako nazwa projektu; **public use blocked by BRAND-01** |
| D-K | Nowy projekt Supabase | KEEP |
| D-L | Dokumentacja ma być czytelna dla modeli AI | KEEP + wymagamy traceability |

### 0.4 Decyzje właściciela z 2026-08-12 — zamykają bramki P0

| ID | Decyzja | Skutek w dokumencie |
|---|---|---|
| **D-M** | **Rola produktu i benchmarku jest równorzędna.** Właściciel akceptuje narzut infrastruktury pomiarowej | Warstwa AgentOS zostaje. §4 planu implementacji wylicza jawnie jej koszt godzinowy, żeby cena była widoczna |
| **D-N** | **Wyróżnik v1.0: brak limitów darmowego planu konkurencji** — nieograniczone rutyny i własne ćwiczenia, pełna historia wykresów, bez reklam | **Zastępuje R-05.** Patrz §1.2, w tym udokumentowane ryzyko tego wyboru |
| **D-O** | **Projekt graficzny powstaje w narzędziu projektowym pod nadzorem właściciela**, na podstawie pełnej specyfikacji | `G-DESIGN` ma właściciela. Specyfikacja: `05-DESIGN-BRIEF.md` |
| **D-P** | **Jurysdykcja i rynek docelowy: Wielka Brytania** | Potwierdza MHRA, UK GDPR i UK/EU name clearance w §12 i G-MH |
| **D-Q** | **Nazwa „LifeOS" zostaje porzucona.** Nowa do wyboru z krótkiej listy | Patrz §1.4. `lifeos` pozostaje wyłącznie nazwą repozytorium |
| **D-R** | **Testerzy są dostępni** — właściciel ma dostęp do osób trenujących siłowo | G-UXR, G2 i G3 zostają bez zmian. To najmocniejszy element planu walidacji |
| **D-S** | **Zakres v1.0 przycięty.** Wypadają: szablony treningów, eksport CSV, pomiary ciała, logowanie przez Google i Apple | Patrz §3.2. Wszystkie cztery wracają w v1.0.1 |
| **D-T** | **Budżet: wyłącznie darmowe progi usług** | Patrz §13.6. Architektura projektowana pod limity planu darmowego, z jawnym progiem opłacalności |


---

## 1. Research snapshot — rynek na 2026-08-12

### 1.1 Co już jest standardem

| Segment | Przykłady | Co użytkownik już dostaje | Konsekwencja dla LifeOS |
|---|---|---|---|
| Strength logging | Hevy, Strong | poprzednie wartości, logowanie serii, wykresy, rekordy, rutyny/szablony | „pamiętamy ostatni ciężar” nie jest wystarczającym USP |
| Adaptive fitness | Fitbod | rekomendacje treningu na podstawie historii, celów, dostępnego sprzętu i recovery | późniejszy coaching musi wyjaśniać *dlaczego* i korzystać z szerszego kontekstu |
| AI day planning | Motion, Reclaim | automatyczne planowanie zadań/habits w kalendarzu | samo „AI układa dzień” jest commodity |
| Wellness | Finch, Headspace | mood check-ins, breathing, medytacja, psychoedukacja | Mind nie wygra katalogiem treści; powinien dostarczać szybki sygnał i powiązanie z resztą danych |
| „Life OS” category | wiele nowych produktów 2026 | tasks + habits + fitness + AI pod nazwą LifeOS/Life OS | nazwa i „all-in-one” same w sobie nie są wyróżnikiem |

### 1.2 Pozycjonowanie

**Wedge v1.0 (decyzja D-N, poprawiona po recenzji):** *a strength log with no free-tier ceiling — unlimited custom exercises and all-time performance charts, with cross-device sync — that keeps working without a signal.*

**Dlaczego sformułowanie z D-N wymagało poprawki.** Pierwotna wersja mówiła „unlimited routines… no ads". Oba człony były błędne:

- **„Unlimited routines" jest niemożliwe do obiecania w v1.0**, ponieważ decyzja D-S usunęła szablony treningów. Wersja 1.0 nie ma żadnych rutyn, więc nie może reklamować się ich nieograniczoną liczbą.
- **„No ads" nie odróżnia niczego.** Darmowy plan Hevy jest bezreklamowy i tak się właśnie reklamuje. To warunek wejścia, nie przewaga.

**Co darmowy Hevy realnie ogranicza** (stan na 2026-08-12): cztery rutyny, siedem własnych ćwiczeń, około trzech miesięcy historii analitycznej. Plan Pro zdejmuje dokładnie te trzy limity plus reklamy — których w darmowym i tak nie ma.

Po usunięciu szablonów z v1.0 **zostają nam dwa z tych trzech limitów**: własne ćwiczenia bez ograniczeń i pełna historia wykresów. Trzeci — rutyny — wraca dopiero w v1.0.1.

**Ryzyko tego wyboru, udokumentowane przed podjęciem pracy.** Badanie z 2026-08-12 pokazuje, że w tej samej niszy działają już co najmniej trzy produkty:

| Produkt | Deklaracja |
|---|---|
| Notch — Gym Workout Tracker | „darmowy na zawsze, bez reklam, bez kont, bez dosprzedaży" |
| StrengthBox | „minimalistyczny dziennik treningowy, bez kanału społecznościowego, reklam i bałaganu" |
| StrengthLog | darmowe, nieograniczone logowanie treningów |

Wyróżnik jest zatem **cienki i zajęty**. Wąska szczelina, która pozostaje, to przecięcie trzech cech, którego żaden z nich nie pokrywa w całości: **konto i synchronizacja między urządzeniami** (Notch świadomie ich nie ma, więc nie ma też kopii zapasowej ani dostępu z drugiego urządzenia), **brak limitów** (czego nie daje darmowy Hevy) oraz **dwujęzyczność EN i PL**.

To jest przewaga możliwa do skopiowania w jeden kwartał przez każdego z wymienionych. Właściciel podjął tę decyzję świadomie. **Trwałym wyróżnikiem pozostaje teza długoterminowa z §1.2, a nie wersja 1.0.**

**Długoterminowa teza:** *jedna przezroczysta pętla decyzyjna łącząca trening, energię/sen/stres i realny plan dnia — z wyjaśnieniem, kontrolą użytkownika i prywatnością.*

LifeOS **nie** konkuruje w v1.0 „liczbą funkcji”. Jeśli użytkownik nie zauważa oszczędności czasu i nie ufa zapisowi treningu, projekt nie przechodzi do Life Coach.

### 1.3 Tezy do walidacji, nie fakty

- H1 — co najmniej połowa testerów P1 uzna obecne logowanie treningu za wystarczająco uciążliwe, aby przetestować szybszy workflow.
- H2 — pre-fill + one-tap confirmation ograniczy aktywny czas wprowadzania standardowego treningu 6 ćwiczeń / 18 serii roboczych do mediany <60 s.
- H3 — zapis offline jest warunkiem zaufania, nie „nice to have”.
- H4 — darmowe wykresy pomagają utrzymać użytkownika, ale **nie są powodem pierwszego wyboru**.
- H5 — cross-module recommendations mają wartość dopiero, gdy są konkretne, wyjaśnione i możliwe do odrzucenia.

---

### 1.4 Nazwa — krótka lista po badaniu kolizji (decyzja D-Q)

Nazwa „LifeOS" zostaje porzucona. W sklepach na rynku docelowym działają już: **LifeOS: Focus and Habit Tracker** (Google Play), **LifeOS: Daily Habits & Focus** (App Store), **MyLifeOS** (App Store, z logowaniem treningów siłowych) oraz **LifeOS** na macOS, opisujący się jako „cele, nawyki i fitness, offline-first, bez subskrypcji" — czyli dokładnie tak, jak ten produkt.

**Odrzucone po sprawdzeniu:**

| Kandydat | Powód odrzucenia |
|---|---|
| Notch | **Notch — Gym Workout Tracker** już istnieje i sprzedaje dokładnie ten wyróżnik, który wybraliśmy |
| Cairn | **CAIRN Strength** działa na Google Play w kategorii fitness |
| Keel | Kolizja z **Keelo** (trening siłowy i interwałowy) oraz **Keel Mental Fitness** w Wielkiej Brytanii |
| Tally | Kilka aplikacji-liczników, w tym jedna licząca serie i powtórzenia |
| Plumb | Silne skojarzenie z branżą hydrauliczną w Wielkiej Brytanii; dodatkowo **Plum** w finansach |

**Do rozważenia — brak kolizji w kategorii fitness w wynikach wyszukiwania:**

| Kandydat | Znaczenie i uzasadnienie |
|---|---|
| **Datum** | Punkt odniesienia, od którego prowadzi się pomiar. Trafne dla dziennika, w którym chodzi o punkt wyjścia i progresję. Krótkie, wymawialne w obu językach. Ryzyko: brzmi technicznie i chłodno |
| **Rung** | Szczebel drabiny. Metafora progresji pokonywanej po jednym stopniu. Cztery litery, dobrze wygląda jako ikona. Ryzyko: trudne w wymowie dla polskiego odbiorcy |
| **Ballast** | To, co utrzymuje statek w stabilnej pozycji. Pasuje do wartości „wiarygodny zapis, który nie gubi danych". Ryzyko: dłuższe, mniej oczywiste |

**Zastrzeżenie.** To jest wyszukiwanie w sklepach i wyszukiwarce, **nie jest to badanie znaków towarowych**. Przed wydaniem publicznym wymagane jest sprawdzenie w rejestrze UK IPO w klasach 9 i 42 — bramka BRAND-01 pozostaje otwarta. Do tego czasu w dokumentach i konfiguracji używamy znacznika `PRODUCT_NAME`, a `lifeos` pozostaje wyłącznie nazwą repozytorium.


## 2. Problem, Jobs To Be Done i persony

### 2.1 Primary JTBD — v1.0

> Kiedy jestem między seriami i nie chcę tracić uwagi na telefon, chcę zapisać to, co właśnie zrobiłem, praktycznie bez pisania, nawet bez zasięgu, żebym po tygodniu dokładnie wiedział co robiłem i czy progresuję.

### 2.2 Secondary JTBD — v1.1+

> Kiedy mój dzień, sen, energia i trening konkurują o ten sam czas, chcę dostać realistyczną propozycję dnia opartą na moich własnych danych — i wiedzieć, dlaczego została zaproponowana.

### 2.3 P1 — Marek, 31 — leading persona v1.0

Trenuje 3–4 razy tygodniowo, zna podstawy progresji, używa arkusza lub istniejącej aplikacji. Często ćwiczy w miejscu ze słabym zasięgiem.

**Bóle:** powtarzalne wprowadzanie wartości; brak pewności zapisu; utrudnione sprawdzanie progresu; zbyt dużo tapnięć.

**Sukces:** standardowy trening daje się zalogować przy minimalnej interakcji, bez utraty danych i bez sieci.

### 2.4 P2 — Ania, 36 — leading persona v1.1

Pracuje zawodowo, trenuje nieregularnie, plan dnia często rozmija się z energią i snem.

**Sukces:** check-in + realistyczny plan zajmuje <60 s przygotowania i jest używany 7 dni.

### 2.5 P3 — Kasia, 27 — leading persona v1.2

Pracuje zdalnie, chce krótkich narzędzi do regulacji stresu i zobaczyć powiązanie między samopoczuciem a zachowaniami.

**Sukces:** używa krótkiej interwencji i rozumie, jakie dane doprowadziły do insightu.

### 2.6 Wiek

**[Z-AGE] v1.x jest projektowane dla użytkowników 18+.** Rozszerzenie na osoby niepełnoletnie wymaga osobnego przeglądu bezpieczeństwa, prywatności, treści i stores policy.

---

## 3. Scope i wersje

| Wersja | Zakres | Persona | Warunek wyjścia |
|---|---|---|---|
| **v1.0** | Core + Exercise + Fitness + Settings + **offline completion of workout** | P1 | test benchmarku logowania zaliczony; zero utraty danych w scenariuszach offline/reload; historia i progress na realnych danych |
| **v1.1** | generic sync + Life Coach + AI broker + Capacitor | P2 | pełna 7-dniowa pętla check-in → plan → completion → reflection; native builds przechodzą device tests |
| **v1.2** | Mood/stress + breathing + rule insights; screening tylko po G-MH | P3 | insight z dwóch modułów ma traceable reason; privacy switch realnie odcina dane |
| **v2.0** | monetization, statistical insights, health integrations, richer Mind | — | osobny PRD |

### 3.2 Przycięcie zakresu v1.0 (decyzja D-S)

Cztery obszary wypadają z v1.0 i wracają w v1.0.1. Powód: harmonogram pełnego zakresu wypadał na rok lub więcej do bety.

| Wypada | Było | Wraca |
|---|---|---|
| Szablony treningów | FIT-15, LIFE-T03 | v1.0.1 |
| Eksport CSV historii | FIT-16, LIFE-T08 | v1.0.1 |
| Pomiary ciała i trendy | FIT-13 | v1.0.1 |
| Logowanie przez Google i Apple | część CORE-02 | v1.0.1, lub przy Capacitorze w v1.1 |

**Co zostaje mimo cięcia i dlaczego:**

- **SET-06, eksport i usunięcie konta, pozostaje MUST v1.0** — ale nie dlatego, że „RODO wymaga przycisku". Wymogiem prawnym jest *proces* obsługi żądania w terminie, który przy dziesięciu testerach spełnia udokumentowana procedura i polecenie administracyjne. Samoobsługa zostaje z powodów produktowych i dlatego, że będzie wymagana przy dystrybucji przez sklepy. Patrz O-11.
- **FIT-23, zapis treningu offline, pozostaje MUST v1.0.** Nie jest już wyróżnikiem po decyzji D-N, ale trwały zapis lokalny i atomowy zapis na serwer są potrzebne niezależnie — pierwszy chroni przed utratą treningu przy przeładowaniu strony, drugi przed osieroconymi seriami. Skoro obie maszynerie i tak powstają, dołożenie kolejki wysyłkowej jest przyrostem małym względem wartości, jaką daje działanie bez zasięgu. **To jest założenie autora dokumentu, nie decyzja właściciela** — do zakwestionowania w drugiej rundzie.

### 3.1 Wprost poza v1.x

Social network · calorie/macro tracking · medical diagnosis/treatment · therapeutic AI chat · public sharing · progress photos · supersets/circuits · full calendar integration · automated purchasing · nutrition coach · E2E encrypted journal · badges/confetti · plugin ecosystem.

---

## 4. AgentOS Evaluation Profile

LifeOS pełni dwie role: produkt oraz **instrument testujący autonomiczną implementację**. Te role nie mogą mieszać metryk.

### 4.1 Co mierzymy

Czy Agent OS potrafi dostać **zamrożony `TASK_SPEC` + projekt UI + kontrakt danych** i oddać działający feature obejmujący UI, persistence, wiring oraz E2E.

### 4.2 Czego nie liczymy jako porażkę capability

OAuth provider provisioning · DNS · zakup domeny · Apple/Google developer accounts · store review · legal/trademark decision · potwierdzenie licencji · ręczne sekrety w dashboardach · custom SMTP provisioning.

Te kroki są **human-gated / pre-provisioned**. Ich awaria ma klasę `infra_fail` albo `human_gate`, nie `task_fail`.

### 4.3 Dwa osobne kamienie milowe — produkt i benchmark

Po decyzji D-S bateria v1.0 liczy sześć zadań, ale benchmark AgentOS potrzebuje ośmiu porównywalnych próbek. **To nie jest sprzeczność — to dwa różne kamienie milowe i nie wolno ich mylić.**

| Kamień milowy | Zakres | Warunek |
|---|---|---|
| **Product v1.0 gate** | LIFE-T01, T02, T04, T05, T06, T07 | Wydanie bety **nie czeka** na benchmark |
| **AgentOS GO-A complete** | powyższe **plus** T03 i T08 w v1.0.1 | Osiem porównywalnych próbek, ta sama wersja schematu `TASK_SPEC` |

Nie zmniejszamy GO-A z ośmiu do sześciu. Zmniejszenie unieważniłoby porównywalność, dla której właściciel zaakceptował cały narzut pomiarowy (D-M). Zamiast tego benchmark kończy się później niż produkt.

### 4.3.1 Feature packages

| TASK | Feature | Główne PRD IDs |
|---|---|---|
| LIFE-T01 | Profile & Settings | SET-01…SET-09, CORE-03 |
| LIFE-T02 | Exercise catalog | EX-01…EX-10 |
| ~~LIFE-T03~~ | Workout template builder — **v1.0.1** | FIT-15 |
| LIFE-T04 | Workout logging + offline durable completion | FIT-01…FIT-05, FIT-07, FIT-08, FIT-23 |
| LIFE-T05 | Workout history | FIT-10, FIT-11 |
| LIFE-T06 | Progress dashboard | FIT-12, FIT-13 |
| LIFE-T07 | Rest timer + PR detection | FIT-06, FIT-09 |
| ~~LIFE-T08~~ | CSV export — **v1.0.1**; SET-06 realizowane w LIFE-T01 | FIT-16, SET-06 |

**Precondition:** foundation/auth test identity/schema/design system istnieją przed pomiarem B6. Agent nie implementuje zewnętrznych providerów podczas tych ośmiu triali.

---

## 5. CORE — wymagania platformowe

| ID | Priorytet | Wymaganie / Acceptance Criteria |
|---|---|---|
| CORE-01 | MUST v1.0 | **App shell i nawigacja.** Mobile bottom nav: Home, Workout, Exercises, History, Progress. Settings przez avatar/gear. Każdy ekran krytyczny osiągalny bez wpisywania URL. |
| CORE-02 | MUST v1.0 | **Auth produkcyjny.** **Wyłącznie e-mail z hasłem** oraz reset hasła; route guard w UI + RLS jako realna autoryzacja. Google i Apple przeniesione do v1.0.1 decyzją D-S — w v1.0 nie ma obecności w sklepach, a logowanie przez Apple wymaga płatnego konta dewelopera. W eval używany wcześniej przygotowany test user/session. |
| CORE-03 | MUST v1.0 | **EN + PL od pierwszego commita.** Brak hard-coded user-facing strings poza test fixtures; fallback do EN. |
| CORE-04 | MUST v1.0 | **PWA installability.** Manifest, właściwe ikony, standalone display, service worker, install smoke-test Chrome/Android i ręczny test iOS/Safari. Brak wymogu „Lighthouse PWA score”. |
| CORE-05 | MUST v1.0 | **Offline shell.** Po co najmniej jednym udanym wejściu aplikacja uruchamia się bez sieci do ekranów deklarowanych offline. |
| CORE-06 | MUST v1.0 | **Durable active-workout draft.** Każda zmiana aktywnego treningu zapisuje się lokalnie w IndexedDB; reload/kill karty nie usuwa pracy. |
| CORE-07 | MUST v1.0 | **Widoczny stan danych.** UI rozróżnia `saved`, `queued`, `syncing`, `failed`, `conflict`; nigdy nie komunikuje „zapisano w chmurze”, jeśli zapis jest tylko lokalny. |
| CORE-08 | MUST v1.0 | **Error recovery.** Każda krytyczna operacja ma retry/recovery path; błędy mają stabilny kod diagnostyczny. |
| CORE-09 | MUST v1.0 | **No silent update.** Nowa wersja PWA nie reloaduje aktywnego treningu automatycznie. |
| CORE-10 | MUST v1.0 | **Release traceability.** Build zawiera semver/commit SHA/catalog version; ekran About pokazuje wersję. |
| CORE-11 | MUST v1.0 | **Accessibility baseline.** Keyboard, screen reader labels, focus, WCAG AA contrast, 200% text scaling, 44×44 px touch targets. |
| CORE-12 | MUST v1.0 | **Privacy-safe observability.** Runtime errors bez sekretów, notatek treningowych/mentalnych i payloadów health w Sentry/logach. |

---

## 6. EXERCISE — katalog ćwiczeń

### 6.1 Funkcje

| ID | Priorytet | Wymaganie |
|---|---|---|
| EX-01 | MUST v1.0 | 200–250 rekordów bazowych dostępnych offline jako wersjonowany katalog. |
| EX-02 | MUST v1.0 | Katalog ma stabilne ID i wersję; klient potrafi rozpoznać nowszą wersję. |
| EX-03 | MUST v1.0 | Wyszukiwanie po nazwie, mięśniach, sprzęcie; wynik lokalny p95 <200 ms na urządzeniu referencyjnym. |
| EX-04 | MUST v1.0 | Filtry category/equipment/type/difficulty mają realne kontrolki UI. |
| EX-05 | MUST v1.0 | Detail: nazwa, muscles, equipment, level, bazowa instrukcja. Curated form tips/common mistakes wymagane dla **top 50** launch exercises; pozostałe mogą wejść później. |
| EX-06 | MUST v1.0 | Favorites z pełnym zapisem/odczytem. |
| EX-07 | MUST v1.0 | Recent i frequent na selectorze z realnej historii. |
| EX-08 | MUST v1.0 | Jeden komponent katalogu obsługuje browse i select mode. |
| EX-09 | MUST v1.0 | Custom exercise CRUD. Systemowe ćwiczenia są immutable; własne należą do usera. |
| EX-10 | MUST v1.0 | PL + EN dla nazwy i instrukcji. Search działa w aktywnym języku z fallbackiem EN. |
| EX-11 | SHOULD v1.0 | Własne/licencjonowane lekkie diagramy mięśni. **Zdjęcia z repo źródłowego nie shipują bez G-LIC.** |
| EX-12 | COULD v1.1 | Substitutions na podstawie movement pattern + muscles + equipment. |
| EX-13 | WON'T v1.x | Instruction video streaming. |

### 6.2 Taksonomia

- `category`: chest, back, legs, shoulders, arms, core, cardio, full_body, other
- `exercise_type`: strength, cardio, mobility, stretching, plyometric
- `primary_muscles[]`, `secondary_muscles[]`: zamknięty słownik
- `equipment[]`: zamknięty słownik wielowartościowy
- `movement_pattern`: push_horizontal, push_vertical, pull_horizontal, pull_vertical, squat, hinge, lunge, carry, rotation, isolation
- `difficulty`: beginner, intermediate, advanced
- `is_compound`, `is_unilateral`
- `tracks ⊆ {weight,reps,time,distance}`
- `default_rest_seconds`

**Ważna korekta:** importer najpierw wykorzystuje istniejące pola źródła (`category`, `mechanic`, `force`, muscles, equipment, instructions), a dopiero później jawne reguły mapowania. Nie wyliczamy ponownie tego, co źródło już deklaruje, bez powodu.

### 6.3 Content gate

`free-exercise-db` ma publicznie deklarowaną licencję Unlicense dla repo/danych, ale **pochodzenie/licencja zdjęć nie jest wystarczająco udokumentowane**. G-LIC ma osobno zatwierdzić:
1. dane i instrukcje,
2. media,
3. wymagany attribution/provenance log.

Fallback dla zdjęć: **ship without source photos** + własne/licencjonowane diagramy.

---

## 7. FITNESS — core produktu

### 7.1 Core logging

| ID | Priorytet | Wymaganie |
|---|---|---|
| FIT-01 | MUST v1.0 | Smart Pattern Memory: po wyborze ćwiczenia ostatni wzorzec serii pojawia się automatycznie; lokalny odczyt p95 <500 ms. |
| FIT-02 | MUST v1.0 | Logging fields zależą od `tracks`; RPE i note są opcjonalne. |
| FIT-03 | MUST v1.0 | Bodyweight: puste/zero additional weight jest poprawne. |
| FIT-04 | MUST v1.0 | Timed exercises używają czasu zamiast wymuszonego reps. |
| FIT-05 | MUST v1.0 | Warm-up sets nie wchodzą do volume ani PR. |
| FIT-06 | MUST v1.0 | Rest timer: auto-start po confirm set, per-exercise default, skip/edit, haptic/audio jeśli platforma pozwala. |
| FIT-07 | MUST v1.0 | Session duration mierzony od start do complete; pause/background semantics opisane w AC. |
| FIT-08 | MUST v1.0 | Summary: working sets, duration, volume, new PRs, sync status. |
| FIT-09 | MUST v1.0 | PR detection: highest estimated 1RM per user/exercise; wynik po edycji/usunięciu treningu musi pozostać poprawny. |
| FIT-10 | MUST v1.0 | History list + filter by exercise + detail. |
| FIT-11 | MUST v1.0 | Edit/delete z soft-delete; po edycji statystyki i PR są przeliczane. |
| FIT-12 | MUST v1.0 | Progress: estimated 1RM, weekly volume, PR timeline; 30d/90d/6m/1y/all. |
| FIT-13 | **v1.0.1** | Body measurements + trends. Przeniesione decyzją D-S. Zamyka otwartą decyzję O-04. |
| FIT-14 | WON'T | Osobny „quick log” screen. **Główny workflow ma być quick**; nie utrzymujemy dwóch ścieżek zapisu. |
| FIT-15 | **v1.0.1** | Workout templates. Przeniesione decyzją D-S. Konsekwencja: w v1.0 trening zaczyna się zawsze od pustego, a szybkość zapewnia pamięć wzorca (FIT-01), nie szablon. |
| FIT-16 | **v1.0.1** | CSV export historii treningów. Przeniesione decyzją D-S. **Uwaga:** eksport pełnych danych użytkownika z SET-06 pozostaje MUST v1.0 jako wymóg UK GDPR. |
| FIT-17 | SHOULD v1.1 | Progression suggestion jako oddzielna, wyjaśniona warstwa nad pattern memory. |
| FIT-18 | SHOULD v1.1 | Workout streak. |
| FIT-19 | WON'T v1.x | Supersets/circuits. |
| FIT-20 | WON'T v1.x | Progress photos. |
| FIT-21 | WON'T v1.x | Apple Health / Health Connect. |
| FIT-22 | WON'T | Calories burned. |
| FIT-23 | **MUST v1.0** | **Offline workout completion:** cały trening można zakończyć bez sieci; po powrocie jest automatycznie/idempotentnie wysłany. Reload/kill/reopen przed sync nie gubi danych. |

### 7.2 Reguły obliczeniowe

- Working-set volume: `weight_kg × reps`, bez warm-up. Dla timed/distance bez sztucznego „volume”.
- Estimated 1RM: Epley `weight × (1 + reps/30)`; dla `reps=1` dokładnie weight.
- PR: najwyższy estimated 1RM dla danego ćwiczenia, tylko eligible working sets.
- Units stored canonically: kg/cm/metres/seconds; display converts.
- `total_volume` i PR są **derived**, nie niezależnym źródłem prawdy.
- Edycja/usunięcie historycznego treningu musi automatycznie zmienić wynik pochodny.

### 7.3 Performance benchmark „<60 s”

Standard benchmark:
- 6 ćwiczeń,
- 18 working sets,
- istnieje poprzednia sesja dla każdego ćwiczenia,
- timer fizycznego odpoczynku **nie jest liczony**,
- **granice pomiaru są jawne:** START w momencie naciśnięcia „Start workout" (lub „Repeat last workout", jeśli O-10 przyjęte), STOP w momencie pojawienia się podsumowania treningu. Do wyniku wchodzi więc rozpoczęcie sesji, wybór ćwiczeń, korekty wartości, potwierdzanie serii i zakończenie treningu — **nie tylko najwygodniejszy fragment interfejsu**,
- liczony jest **cumulative active interaction time** w tych granicach: od focus/touch rozpoczęcia operacji do zakończenia każdej interakcji z logging UI,
- **równolegle mierzymy ten sam scenariusz w Hevy na tych samych osobach.** Wynik względem konkurenta niesie więcej informacji niż przekroczenie progu ustalonego przy biurku,
- mediana dla testerów P1 po pierwszym treningu treningowym: **<60 s**,
- mediana confirm/prefill flow na set: **<2 s aktywnej interakcji**.

Instrumentacja benchmarku nie może rejestrować treści notatek ani danych mental-health.

---

## 8. LIFE COACH — v1.1

### 8.1 Pętla

`morning check-in → generated day → user edits → task outcomes → evening reflection → next-day context`

Dopóki ta pętla nie działa 7 dni dla jednego użytkownika, nie dokładamy chat/personality/weekly report.

### 8.2 Wymagania

| ID | Priorytet | Wymaganie |
|---|---|---|
| LC-01 | MUST v1.1 | Morning check-in: mood, energy, sleep quality, sleep hours, optional note; <60 s. |
| LC-02 | MUST v1.1 | Generate plan przez server-side AI broker; structured output + validated schema + deterministic fallback. |
| LC-03 | MUST v1.1 | Każde AI-suggested task ma krótkie rationale i source context categories, bez ujawniania prywatnych raw notes. |
| LC-04 | SHOULD v1.1 | Day theme; quote tylko jeśli nie zwiększa latencji/kosztu i designer uzna, że nie rozprasza. |
| LC-05 | MUST v1.1 | Task status: done/skipped + edit schedule. |
| LC-06 | MUST v1.1 | Add/edit/delete/reorder AI plan manually. |
| LC-07 | MUST v1.1 | Goals CRUD; max 5 active; closed category vocabulary; optional numeric progress. |
| LC-08 | MUST v1.1 | Explicit goal-progress UI. |
| LC-09 | MUST v1.1 | Evening reflection includes plan completion review and flows into next context. |
| LC-10 | MUST v1.1 | Coaching preferences stored, not hardcoded. |
| LC-11 | MUST v1.1 | Check-in streak. |
| LC-12 | MUST v1.1 | Daily aggregate metrics created with consent/privacy rules. |
| LC-13 | SHOULD v1.1 | Task ↔ goal link. |
| LC-14 | SHOULD v1.2 | Bounded AI conversation only after separate safety scope. |
| LC-15 | SHOULD v1.2 | Trend charts. |
| LC-16 | COULD v1.2 | Suggested goals. |
| LC-17 | WON'T v1.x | AI personalities. |
| LC-18 | WON'T v1.x | Learning policy from long-term corrections. |
| LC-19 | WON'T v1.x | Calendar integration. |
| LC-20 | WON'T v1.x | Weekly report. |

### 8.3 Plan contract — korekta

Nie wymuszamy arbitralnego mixu „30/25/20/15/10” ani zawsze 6–8 godzin zadań.

Input obejmuje:
- current check-in,
- user-selected **available capacity/time budget**,
- max 5 active goals,
- preferences/work hours,
- prior reflection,
- 3-day completion rate,
- last workout / mood-stress data **tylko jeśli privacy policy pozwala**.

Output:
- **3–6 concrete tasks**, mieszczących się w deklarowanym budżecie,
- suggested time/window,
- priority,
- energy demand,
- rationale,
- optional linked goal,
- reason codes pozwalające audytować decyzję.

Fallback generuje 3–5 zadań deterministycznie z goals/preferences/capacity.

---

## 9. SETTINGS, ACCOUNT, PRIVACY

| ID | Priorytet | Wymaganie |
|---|---|---|
| SET-01 | MUST v1.0 | Settings route dostępny z global shell. |
| SET-02 | MUST v1.0 | Units kg/lbs, cm/in, km/mi; storage pozostaje canonical SI. |
| SET-03 | MUST v1.0 | Theme light/dark/system. |
| SET-04 | MUST v1.0 | Language EN/PL. |
| SET-05 | MUST v1.0 | Profile: name, email, password/reset, avatar; DOB/gender opcjonalne i zbierane tylko jeśli mają realny use case. |
| SET-06 | MUST v1.0 | Data/privacy: full export, account deletion workflow, policy links. **Uzasadnienie poprawione:** to nie jest bezpośredni wymóg UK GDPR. ICO wymaga *procesu* obsługi żądań dostępu, przenoszenia i usunięcia w terminie — nie samoobsługowego przycisku w aplikacji. Powodem utrzymania w v1.0 jest prywatność od projektu, zaufanie użytkownika oraz to, że Apple wymaga usuwania konta w aplikacji, więc praca i tak będzie potrzebna przy Capacitorze. **Patrz O-11.** |
| SET-07 | MUST v1.0 | **Fitness/health disclaimer, safety notice, terms.** Nic o zdrowiu psychicznym. |
| SET-07b | **MUST v1.2** | **Mental-health disclaimer + region-aware crisis resources registry.** Przeniesione z v1.0 po recenzji: wersja 1.0 jest czystym dziennikiem siłowym, a pokazanie materiałów kryzysowych w aplikacji, która nie robi niczego z obszaru zdrowia psychicznego, jest mylące dla użytkownika i nieuzasadnione. Wchodzi razem z MND-09 i bramką G-MH. |
| SET-08 | MUST v1.0 | About: app version, OSS licenses, contact. |
| SET-09 | MUST v1.0 | Logout. |
| SET-10 | MUST v1.0 | Contextual install prompt po pierwszym completed workout; browser limitations handled. |
| SET-11 | MUST v1.1 | Reminder configuration + quiet hours. |
| SET-12 | MUST v1.1 | Coaching preferences. |
| SET-13 | MUST v1.2 | Cross-module privacy switches **enforced at data boundary**, nie tylko w UI. |
| SET-14 | SHOULD v1.1 | Sync dashboard: queued/failed/conflict/manual retry. |
| SET-15 | WON'T v1.x | Subscription management. |

---

## 10. MIND — v1.2

### 10.1 Pozycjonowanie bezpieczeństwa

Mind jest modułem **wellness/self-reflection**, nie diagnozowania ani leczenia. Wymagania medycznie brzmiące są blokowane przez `G-MH`.

### 10.2 Wymagania

| ID | Priorytet | Wymaganie |
|---|---|---|
| MND-01 | MUST v1.2 | Mood + stress check on 1–5 scale. |
| MND-02 | MUST v1.2 | 5 breathing exercises with clear duration and stop control. |
| MND-03 | **PROVISIONAL v1.2** | PHQ-9/GAD-7 only after G-MH: approved wording, scoring, safety flow, intended-purpose review, language versions. |
| MND-04 | MUST v1.2 | Mood trend. |
| MND-05 | WON'T v1.x | Meditation audio library. |
| MND-06 | WON'T v1.x | Encrypted private journal. |
| MND-07 | WON'T v1.x | Therapeutic AI conversation. |
| MND-08 | WON'T v1.x | Sleep stories/ambient audio. |
| MND-09 | MUST v1.2 | Safety resource registry is region-aware, externally reviewable and updatable without app release. |
| MND-10 | MUST v1.2 | No total PHQ/GAD score is called a “crisis threshold”. Any self-harm/suicidal-ideation item has a **separate safety flow**, defined only after professional review. |

### 10.3 Gate G-MH

Przed MND-03:
1. written intended-purpose statement,
2. MHRA/UK medical-device applicability review for the actual claims/functionality,
3. clinical/safety review of exact questionnaire UX and escalation logic,
4. PHQ/GAD language/attribution/licensing check,
5. privacy/DPIA update,
6. app-store health declaration update,
7. test plan for safety copy/resources.

Jeśli gate nie przechodzi, v1.2 shipuje bez screeners. Mood + breathing + trend + rule insights pozostają.

---

## 11. Cross-module insights

### 11.1 Rule layer v1.2

Rules are **supportive suggestions**, not medical conclusions.

- poor self-reported sleep + hard planned session → suggest review/lighter option, not automatic cancellation;
- high self-reported stress + hard session → suggest lower intensity/recovery option;
- weekly training load spike + high stress → recovery prompt;
- abrupt stress increase → breathing tool suggestion.

Każdy insight pokazuje:
- jakie **category-level signals** go wywołały,
- „why am I seeing this?”,
- dismiss/save/action,
- privacy source,
- maksymalnie 1 insight/dzień.

### 11.2 Statistical layer

WON'T v1.x. Wymaga osobnego data-quality/statistical PRD, minimalnego okna danych i kontroli false discoveries. Nie zakładamy, że prosta korelacja = przyczynowość.

---

## 12. Prywatność, bezpieczeństwo i compliance

### 12.1 Health data

Workout history, mood, sleep, screening and related inferences mogą stanowić health-related personal data / special-category data. Przed publicznym użyciem:
- dokumentujemy Article 6 lawful basis oraz Article 9 condition dla każdego processing purpose,
- jeśli podstawą jest consent, musi być explicit i granular,
- wykonujemy DPIA tam, gdzie wymaga tego profil ryzyka,
- minimalizujemy dane,
- rozdzielamy operational data od optional analytics/AI processing.

To jest wymaganie projektowe; finalna podstawa prawna wymaga review osoby kompetentnej w UK GDPR.

### 12.2 AI

- AI provider receives only minimum context required.
- Cross-module mental/health context requires applicable privacy permission.
- No API key in client.
- No diagnosis/treatment instruction.
- Structured output validated before persistence.
- Every AI action has deterministic fallback or user-recoverable error.
- Provider/model/version/cost recorded server-side without raw sensitive prompt in ordinary logs.

### 12.3 Data subject actions

- Export all functional user data.
- Delete-account workflow with clear cancellation/retention explanation.
- Server-side rate limits, not UI-only.
- No data sale.
- Production error logs scrub PII and health content.

---

## 13. NFR — measurable

### 13.1 Performance

Targets measured on a documented mid-range mobile device / throttled network profile:

| Metric | Target |
|---|---|
| LCP | ≤2.5 s p75 where applicable |
| INP | ≤200 ms p75 |
| CLS | ≤0.1 |
| Reopen from cached shell | <1 s to usable shell |
| Pattern memory local lookup | p95 <500 ms |
| Exercise search | p95 <200 ms |
| Set confirmation perceived update | <100 ms |
| Online workout commit | p95 <2 s; UI remains responsive |
| History 90 days | p95 <1 s |
| AI plan | target <4 s; hard timeout/fallback policy in architecture |
| Critical route JS | route budget defined in CI; no single global “magic number” without measurement |

### 13.2 Reliability

- 0 orphan workout sets in accepted test corpus.
- 0 duplicated workouts under retry/reload/offline replay.
- 100% recovery of active workout draft in deterministic crash/reload tests.
- Sync failures are visible and retryable.
- Critical error rate target <0.5% sessions after telemetry exists.

### 13.3 PWA verification

No Lighthouse PWA score. Release gate instead verifies:
- valid linked manifest and icons,
- service worker controls production scope,
- offline shell launch,
- installed standalone launch on current Chrome/Android,
- installed Home Screen launch on supported iOS/Safari,
- update flow does not interrupt active workout,
- auth/session behavior after installation is explicitly tested.

### 13.4 Browser/device matrix

**v1.0 target — poziomy wsparcia, nie jedna lista.** Jedna osoba pracująca 20 h tygodniowo nie przetestuje regularnie ośmiu kombinacji, a obiecywanie ich w dokumencie jest deklaracją bez pokrycia.

| Poziom | Przeglądarki | Zobowiązanie |
|---|---|---|
| **Tier 1 — bramka wydania** | iOS Safari, Android Chrome, desktop Chromium/Edge | Pełne testy, blokują wydanie |
| **Tier 2 — smoke zgodności** | Firefox najnowszy, macOS Safari najnowszy | Test przejścia krytycznej ścieżki; błąd jest zgłoszeniem, nie blokadą |
| Poza macierzą | reszta | Rozszerzamy dopiero, gdy pojawią się realni użytkownicy z danymi telemetrycznymi |

Baseline iOS/iPadOS Safari wyznaczany z faktycznie użytych API, nie z dostępności web-push.

PWA install behavior is tested manually on at least:
- iPhone/Safari → Home Screen,
- Android/Chrome,
- desktop Chromium.

### 13.5 Accessibility

WCAG 2.2 AA target for critical flows. Automated axe checks are necessary but not sufficient; keyboard/screen-reader/manual zoom tests are release gates.

---

### 13.6 Budżet i limity darmowych progów (decyzja D-T)

Projekt nie ma monetyzacji przez dwanaście miesięcy, więc przez dwanaście miesięcy generuje wyłącznie koszty. Architektura jest projektowana pod darmowe progi.

**Supabase, plan darmowy — stan na 2026-08-12:**

| Zasób | Limit | Kiedy stanie się problemem |
|---|---|---|
| Baza danych | 500 MB | Bardzo późno. Trening z osiemnastoma seriami to rzędu kilku kilobajtów; dziesięciu testerów nie zbliży się do progu |
| Aktywni użytkownicy miesięcznie | 50 000 | Poza horyzontem tego projektu |
| Pliki | 1 GB | Awatary są jedynym użyciem w v1.0. **Katalog ćwiczeń nie może iść przez ten limit** — jest częścią paczki statycznej |
| Transfer z bazy | 5 GB miesięcznie | Przy dziesięciu testerach bezpiecznie |
| Liczba aktywnych projektów | 2 | Wystarczy na produkcję i środowisko testowe dla benchmarku. **Trzeciego środowiska nie będzie** |
| **Wstrzymanie projektu** | **po 7 dniach bez zapytań do bazy** | **To jest realny problem, nie teoretyczny** |

**Wstrzymanie po tygodniu bezczynności wymaga obsługi w planie.** Liczy się brak zapytań docierających do bazy — nie brak wizyt w panelu. Przy pracy dwadzieścia godzin tygodniowo i przerwach w projekcie środowisko produkcyjne potrafi zasnąć między sesjami. Dane są zachowane, wznowienie jest ręczne, ale w trakcie bety oznacza to, że pierwszy tester po przerwie zobaczy aplikację, która nie odpowiada. Do rozwiązania w M0: albo lekkie zapytanie cykliczne utrzymujące projekt przy życiu, albo świadoma akceptacja ryzyka z komunikatem w interfejsie.

**Pozostałe pozycje:**

| Pozycja | Koszt | Kiedy |
|---|---|---|
| Hosting statyczny | 0 GBP w darmowym progu | Od M0 |
| Domena | 10–15 GBP rocznie | Przed bety zewnętrzną |
| Sentry | 0 GBP w darmowym progu | Od M0 |
| Konto Apple Developer | 99 USD rocznie | **Dopiero v1.1** przy Capacitorze |
| Konto Google Play | 25 USD jednorazowo | **Dopiero v1.1** |
| API modelu językowego | zależne od użycia | **Dopiero v1.1** przy Life Coach |

**Wniosek: v1.0 mieści się w kosztach rzędu kilkunastu funtów rocznie** — sama domena. Pierwszy realny wydatek pojawia się przy v1.1.

---

## 14. Product metrics

### 14.1 Primary

1. **Activation:** user completes first real workout within 7 days of account creation.
2. **Logging friction:** median active interaction time on standard 6/18 benchmark <60 s.
3. **Data trust:** 0 unrecoverable workout-loss events in beta.
4. **D30 activated retention:** target ≥5% **as a product hypothesis**, measured among users who activated, not every signup.

`D30 <3%` is a review trigger, not an automatic product-kill based on a tiny sample. Decision uses cohort size + qualitative interviews + activation/usage data.

### 14.2 Secondary

- D7 activated retention.
- workouts per activated user/week.
- % completed workouts created with pattern memory.
- offline queue success rate / median time to sync.
- install rate among returning eligible users.
- error rate.

### 14.3 AgentOS metrics are separate

`READY_FOR_HUMAN`, accepted without corrections, iterations, infra_fail, gate results and unattended success belong to AgentOS benchmark. Nie wolno używać ich jako KPI produktu.

---

## 15. Design handoff contract

Designer otrzymuje **ten PRD + Architecture v1.1**. Nie powinien zgadywać architektury, routingu ani stanów danych.

### 15.1 Information architecture

**Bottom navigation (mobile):**
1. Home
2. Workout
3. Exercises
4. History
5. Progress

**Settings/Profile:** avatar/gear w Home/header, nie szósta zakładka.

### 15.2 Minimal route/screen inventory v1.0

- Auth: sign in, sign up, reset, callback/recovery.
- Home: new user, returning user, active workout resume, queued-sync warning.
- Workout: start blank *(oraz „powtórz ostatni trening", jeśli O-10 zostanie przyjęte)*, active session, exercise selector, set editor, rest timer, `draft_local`/offline/queued state, complete confirmation, summary.
- Exercises: list/search/filter, detail, custom create/edit.
- History: list/filter, workout detail, edit/delete.
- Progress: overview, per-exercise chart/ranges, PR timeline. *(Bez pomiarów ciała — v1.0.1.)*
- Settings: profile, units, theme, language, data/privacy, about, logout.
- System: loading, empty, offline, queued, sync failed, conflict (v1.1), update available, fatal/recovery.

### 15.3 Required design outputs

Before feature implementation:
- design tokens and semantic color roles,
- mobile reference at 390×844,
- desktop reference at 1440 px,
- reusable component states,
- full active-workout prototype,
- light + dark,
- PL long-string pass,
- keyboard/focus/screen-reader annotations for critical controls,
- destructive confirmation patterns,
- offline/queued/sync/error visuals,
- `DESIGN_ID` on each frame mapped to PRD IDs,
- assets export rules.

**AgentOS requirement:** critical screens used in visual gate must have stable `DESIGN_ID` and frozen screenshot reference.

---

## 16. Hard gates before implementation/public release

| Gate | When | PASS |
|---|---|---|
| G-PROD | before implementation freeze | **O-01**, R-04, Z-AGE ratified. **Obecnie OPEN** — O-01 nierozstrzygnięte. M0 może iść naprzód, bo trwały szkic i atomowy zapis są potrzebne w obu wariantach |
| G-UXR | before M2 completion | ≥5 target-user interviews + baseline logging observation; findings incorporated or explicitly rejected |
| G-LIC | before source content/media ships | data license verified; media provenance separately verified; source snapshot/hash recorded |
| BRAND-01 | before logo/domain/store metadata spend | UK/EU/target-market name clearance or explicit owner risk acceptance |
| G-DESIGN | before AgentOS feature battery | v1.0 design inventory + states + IDs frozen |
| G-PRIV | before external beta | privacy map, RLS matrix, export/delete test, logging redaction verified |
| G-MH | before screeners | clinical/regulatory/privacy/store review passes |
| G-MOBILE | before store submission | native utility/device tests/store health declarations/policy review complete |

---

## 17. Out of scope guards

Nowe wymaganie może wejść tylko przez:
1. nowe ID PRD,
2. wersję docelową,
3. wpływ na architecture/data/privacy,
4. zmapowany task,
5. kryteria akceptacji,
6. jawne usunięcie lub przesunięcie równoważnego scope, jeśli termin/effort jest ograniczony.

„Dodamy przy okazji” nie jest trybem zmiany zakresu.

---

## 18. Open decisions — muszą mieć właściciela

| ID | Pytanie | Owner | Deadline/Gate |
|---|---|---|---|
| **O-01** | **Czy FIT-23 (pełny zapis treningu offline) pozostaje MUST v1.0?** Jedyne miejsce tej decyzji — zastępuje dawne R-01, D-D i O-08. **Przyjęte** → ADR-17 Accepted, FIT-23 MUST, LIFE-T04 dostaje kryteria offline. **Odrzucone** → trwały szkic i atomowy zapis zostają, ale zakończenie treningu wymaga sieci; oszczędność 20–30 h | Product owner | **G-PROD** |
| O-02 | Wybór nazwy z krótkiej listy w §1.4 + badanie znaków towarowych UK IPO w klasach 9 i 42 | Product owner + brand/legal review | BRAND-01 |
| O-03 | Exact v1.0 catalog subset | Product/content | before LIFE-T02 |
| ~~O-04~~ | ~~Body measurements v1.0 czy v1.0.1?~~ | **ZAMKNIĘTE** decyzją D-S: v1.0.1 | — |
| O-05 | PHQ/GAD included at all in v1.2? | Product + clinical/regulatory | G-MH |
| O-06 | Target iOS baseline after capability spike | Architecture owner | M0 |
| O-07 | Analytics consent/instrumentation approach for beta logging-time metric | Product/privacy | G-PRIV |
| **O-10** | **Czy dodać FIT-24 „Repeat last workout" do v1.0?** Po wycięciu szablonów każdy trening zaczyna się od pustego, co dokłada kilkanaście interakcji poza budżet 60 s. Propozycja kopiuje samą strukturę ostatniego treningu do nowego szkicu — bez tabel szablonów, edytora i nazw. Szacunek 8–14 h | Product owner | przed LIFE-T04 |
| **O-11** | **Czy SET-06 zostaje samoobsługowy w v1.0**, czy do v1.0.1 wystarczy udokumentowany proces? Patrz §9 | Product owner | przed LIFE-T01 |
| **O-12** | **Kolejność v1.1: Life Coach przed generic sync i Capacitorem?** Patrz PLAN §9. Przesuwa test głównej tezy produktu o 130–210 h wcześniej, ale koliduje z D-T, bo API modelu językowego kosztuje | Product owner | po becie v1.0 |
| O-09 | **Jak utrzymać projekt Supabase przy życiu** mimo wstrzymania po 7 dniach bezczynności. Patrz §13.6 | Architecture | M0 |

---

## Appendix A — research basis (snapshot 2026-08-12)

External claims reviewed against current primary/official sources where available:

- Hevy product/help/store listings — previous workout values, graphs, free/pro limits.
- Strong official/store listings — progress/1RM/volume/body metrics.
- Fitbod official product material — adaptive planning from history/recovery/goals/equipment.
- Motion/Reclaim — AI task/day scheduling.
- Finch/Headspace — mood/breathing/wellness.
- Current App Store/Google Play/web products using „LifeOS”.
- Next.js static export docs.
- Chrome/Lighthouse release notes.
- Supabase Auth/production security docs.
- TanStack Query persistence docs.
- WebKit storage/ITP notes.
- Apple App Review and Google Play health-app policies.
- ICO special-category/DPIA guidance.
- MHRA digital mental-health guidance updated July 2026.
- Pfizer/PHQ resources and NHS usage/safety material for PHQ/GAD.

This appendix is a research provenance list, not a substitute for legal/clinical advice or release-time policy re-checks.
