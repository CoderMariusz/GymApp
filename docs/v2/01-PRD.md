<!-- AI-INDEX: prd, wymagania, zakres, persony, fitness, life-coach, exercise, settings, mind, tiery, nfr, model-danych -->

# LifeOS — PRD v2

**Status:** Draft do przeglądu
**Data:** 2026-08-11
**Zastępuje:** `docs/1-BASELINE/product/PRD-*.md` (5 plików), `docs/2-MANAGEMENT/epics/*` (9 plików)
**Podstawa:** analiza projektu v1 → `00-ANALYSIS-FINDINGS.md`

---

## 0. Jak czytać ten dokument

Wymagania są oznaczone priorytetem MoSCoW **w obrębie swojej wersji**:
`MUST` — bez tego wersja nie wychodzi · `SHOULD` — wychodzi, ale gorsza · `COULD` — jeśli zostanie czas · `WON'T` — świadomie odłożone, z podaną wersją docelową.

Numeracja funkcji jest **per moduł** (`FIT-01`, `LC-01`, `EX-01`, `SET-01`, `MND-01`, `CORE-01`), nie ciągła. Powód: w v1 ciągła numeracja FR1–FR123 skolidowała między dokumentami i uniemożliwiała dodawanie wymagań bez przenumerowania. Numer nigdy nie jest ponownie użyty.

**Przyjęte założenia** są oznaczone `[Z-n]` i zebrane w §11. Każde zamyka pytanie, które w v1 pozostawało otwarte przez rok. Jeśli któreś jest błędne — zmiana teraz jest tania.

---

## 1. Produkt

### 1.1 Czym jest LifeOS

Modularna aplikacja mobilna łącząca trzy obszary życia: **trening siłowy**, **planowanie dnia z AI** i **zdrowie psychiczne** — w jednym produkcie, gdzie moduły wymieniają się danymi.

### 1.2 Problem

Osoba pracująca zawodowo, która chce być w formie, używa dziś trzech osobnych aplikacji: do logowania treningów, do planowania zadań, do medytacji. Żadna nie wie o istnieniu pozostałych. Aplikacja treningowa proponuje ciężki trening w dniu, w którym użytkownik spał 4 godziny. Aplikacja do planowania układa dzień pełen zadań, gdy poziom energii jest na dnie. Koszt tego stacku to ~£320/rok.

Drugi problem, węższy ale ostrzejszy: **logowanie treningu jest żmudne**. Standardowy wzorzec to wpisywanie ciężaru i powtórzeń dla każdej serii z klawiatury, w hałaśliwej siłowni, między seriami. Zabiera to ~5 minut na sesję i jest głównym powodem porzucania aplikacji treningowych.

### 1.3 Propozycja wartości

1. **Smart Pattern Memory** — aplikacja pamięta, co robiłeś ostatnio z tym ćwiczeniem, i wypełnia formularz zanim go dotkniesz. Logowanie serii = jedno tapnięcie potwierdzenia. Cel: **<2 s na ćwiczenie zamiast ~5 min na trening**.
2. **Wykresy postępu zawsze za darmo** — u konkurencji (Strong, FitBod) są za paywallem. To świadoma przewaga cenowa, nie przeoczenie.
3. **Moduły rozmawiają ze sobą** — plan dnia zna Twój sen i nastrój; sugestia treningu zna Twój poziom stresu; podsumowanie tygodnia łączy wszystkie trzy obszary.
4. **Cena** — pojedynczy moduł taniej niż jedna aplikacja konkurencji; pakiet taniej niż dwie.

### 1.4 Czym LifeOS nie jest

- Nie jest zamiennikiem opieki psychologicznej ani medycznej. Dyskalimer i zasoby kryzysowe są wymogiem, nie dodatkiem.
- Nie jest aplikacją dietetyczną. Liczenie kalorii i makro jest poza zakresem v1–v2.
- Nie jest siecią społecznościową. Funkcje społeczne są poza zakresem.
- Nie jest trenerem personalnym. AI proponuje i wyjaśnia, nie przepisuje programów treningowych.

---

## 2. Persony

W v1 person nie było — cała definicja odbiorcy to był jeden wiersz tabeli („22-45, professionals"). To za mało, żeby rozstrzygnąć, czy hero-feature to Smart Pattern Memory czy redukcja stresu. Poniżej trzy persony; **P1 jest personą prowadzącą dla v1.0**.

### P1 — Marek, 31 lat, główny odbiorca v1.0

Programista, trenuje siłowo 3–4× w tygodniu od dwóch lat, w domowym garażu lub w osiedlowej siłowni. Zna podstawy progresji, prowadzi notatki w Google Sheets albo w aplikacji, której nie lubi.

**Bóle:** wpisywanie tych samych liczb w kółko; brak zasięgu w siłowni w piwnicy; wykresy postępu za paywallem; nie wie, czy faktycznie robi progres, czy tylko powtarza te same ciężary.
**Czego chce od aplikacji:** żeby zniknęła. Otworzyć, tapnąć, zamknąć.
**Kryterium sukcesu:** loguje trening w mniej niż minutę i wraca po 30 dniach.

### P2 — Ania, 36 lat, odbiorca v1.1

Menedżerka, trenuje nieregularnie (1–2× w tygodniu, zależnie od tygodnia w pracy), śpi za mało, ma poczucie, że dzień „się dzieje" zamiast być zaplanowany.

**Bóle:** planowanie dnia od zera każdego ranka; wyrzuty sumienia, gdy plan się nie udaje; treningi, na które nie ma energii.
**Czego chce:** żeby ktoś powiedział jej, co dziś realnie da się zrobić — z uwzględnieniem tego, że spała 5 godzin.
**Kryterium sukcesu:** robi poranny check-in przez 7 dni z rzędu.

### P3 — Kasia, 27 lat, odbiorca v1.2

Pracuje zdalnie, wysoki poziom stresu, korzystała z Calm i Headspace, zrezygnowała po trialu. Trening traktuje jako narzędzie regulacji nastroju, nie jako cel.

**Bóle:** stres bez ujścia; brak dowodu, że cokolwiek pomaga.
**Czego chce:** krótkie narzędzie na 5 minut w środku dnia i dowód, że działa.
**Kryterium sukcesu:** widzi w podsumowaniu tygodnia korelację między aktywnością a nastrojem.

**Konsekwencja dla zakresu:** v1.0 jest budowane wyłącznie pod Marka. Nie ma w nim AI, nie ma medytacji, nie ma onboardingu z wyborem ścieżki. Jest szybkie logowanie treningu, które działa offline.

---

## 3. Zakres wersji

| Wersja | Zakres | Persona | Warunek wyjścia |
|---|---|---|---|
| **v1.0** | Fundament + Exercise + Fitness + Settings (rdzeń) | P1 Marek | Trening logowany offline w <60 s, widoczny po restarcie; wykresy na realnych danych |
| **v1.1** | Life Coach (pętla check-in → plan → refleksja) + AI przez serwer | P2 Ania | 7-dniowa seria check-inów wykonalna; plan generowany z realnego kontekstu |
| **v1.2** | Mind (mood, oddech, screening) + insighty cross-module regułowe | P3 Kasia | Insight cross-module widoczny po 7 dniach danych |
| **v2.0** | Monetyzacja, medytacje audio, korelacje statystyczne, gamifikacja | — | — |

**Uzasadnienie kolejności.** Fitness jest jedynym modułem samowystarczalnym: nie potrzebuje AI, kluczy API, Edge Functions ani produkcji treści. Da się go dowieźć do sklepu. Life Coach wymaga zbudowania `ai-orchestrator` — to osobny strumień pracy, który w v1 nigdy nie ruszył. Mind wymaga produkcji audio, czyli budżetu i czasu, których nikt nie oszacował. Cross-Module Intelligence wymaga danych z ≥2 modułów, więc fizycznie nie może być pierwszy.

---

## 4. MODUŁ: EXERCISE (katalog ćwiczeń)

Katalog jest **fundamentem fitness, nie osobnym modułem**. W v1 był katalogiem-sierotą bez jednej referencji z zewnątrz, a logowanie treningu używało wolnego tekstu — co rozbijało historię, statystyki i pre-fill przy każdej literówce. W v2 katalog jest budowany **przed** logowaniem treningu.

### 4.1 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| EX-01 | Katalog offline | **MUST** v1.0 | 200–250 ćwiczeń jako bundled asset (JSON), seedowany do lokalnej bazy przy pierwszym starcie. Zero zależności od sieci |
| EX-02 | Wersjonowanie katalogu | **MUST** v1.0 | `catalog_version`; aktualizacja przyrostowa z serwera przy starcie, jeśli dostępna nowsza |
| EX-03 | Wyszukiwanie pełnotekstowe | **MUST** v1.0 | Po nazwie, mięśniach, sprzęcie. FTS5 + debounce 150 ms. Cel <200 ms |
| EX-04 | Filtry | **MUST** v1.0 | Kategoria, sprzęt, typ, poziom — wszystkie z UI (w v1 dwa filtry miały provider bez interfejsu) |
| EX-05 | Szczegóły ćwiczenia | **MUST** v1.0 | Nazwa, mięśnie główne/pomocnicze, sprzęt, instrukcja krokowa, 3–5 wskazówek technicznych, 3–5 typowych błędów |
| EX-06 | Ulubione | **MUST** v1.0 | Toggle z listy i ze szczegółów |
| EX-07 | Ostatnio używane / najczęstsze | **MUST** v1.0 | Dwie sekcje na górze pickera, liczone z historii treningów. Tanie, wysoka wartość UX |
| EX-08 | Tryb pickera | **MUST** v1.0 | Ten sam katalog w dwóch trybach: przeglądanie i wybór do treningu. Jeden kod |
| EX-09 | Ćwiczenia własne (CRUD) | **MUST** v1.0 | Pełny cykl z UI. W v1 formularz pokazywał „created successfully!" i nic nie zapisywał |
| EX-10 | i18n katalogu | **MUST** v1.0 | EN + PL. Osobna tabela tłumaczeń, wyszukiwanie na aktywnym locale z fallbackiem EN |
| EX-11 | Ilustracje / diagramy mięśni | SHOULD v1.0 | Statyczne, bundled, lekkie. Wideo → v2.0 |
| EX-12 | Substytucje ćwiczeń | COULD v1.1 | Zamienniki wg wzorca ruchu + mięśni + dostępnego sprzętu. Wymaga EX-14 |
| EX-13 | Wideo instruktażowe | WON'T (v2.0) | Streaming przez URL |

### 4.2 Taksonomia — znormalizowana

W v1 kategoria była **wyliczana** przez `String.contains` na pierwszym elemencie listy mięśni, w dwóch sprzecznych implementacjach. Ćwiczenie z `['triceps','chest']` trafiało do „Arms", a `['traps']` do „Other".

| Wymiar | Wartości | Uwaga |
|---|---|---|
| `category` | chest, back, legs, shoulders, arms, core, cardio, full_body, other | **Jawne pole**, nie pochodna |
| `exercise_type` | strength, cardio, mobility, stretching, plyometric | Nowe. W v1 `cardio` było przemycone jako wartość w liście mięśni |
| `primary_muscles[]` / `secondary_muscles[]` | słownik zamknięty | Rozdzielone (w v1 jedna płaska lista) |
| `equipment[]` | barbell, dumbbell, kettlebell, machine, cable, bodyweight, resistance_band, suspension, smith_machine, medicine_ball, bench, sled, none | **Lista**, nie pojedyncza wartość — wyciskanie leżąc wymaga sztangi *i* ławki |
| `movement_pattern` | push_horizontal, push_vertical, pull_horizontal, pull_vertical, squat, hinge, lunge, carry, rotation, isolation | Nowe. Warunek konieczny dla substytucji i generowania planów |
| `difficulty` | beginner, intermediate, advanced | |
| `is_compound` / `is_unilateral` | bool | |
| `tracks` | zbiór z {weight, reps, time, distance} | **Krytyczne.** Określa, które pola pokazać przy logowaniu. W v1 zawsze pokazywano ciężar+powtórzenia, także dla planku i biegu |
| `default_rest_seconds` | int | Zasila timer przerwy per ćwiczenie |

### 4.3 Treść katalogu

`[Z-2]` **200–250 ćwiczeń, bundled JSON, EN+PL, produkcja własna lub import z otwartej bazy.**

W v1 deklarowano „500+" we wszystkich dokumentach, w komentarzach kodu i w nagłówku ekranu; faktycznie było **105**, a sam plik seeda przyznawał to w komentarzu. Nowa liczba jest realna i wystarczająca — jakość opisu (instrukcja + wskazówki + błędy, w dwóch językach) jest ważniejsza niż liczba pozycji.

Decyzja licencyjna do podjęcia przed startem: produkcja własna vs import z `free-exercise-db` / wger (obie na licencjach otwartych, wymagają weryfikacji zgodności i tłumaczenia na PL).

---

## 5. MODUŁ: FITNESS

### 5.1 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| FIT-01 | **Smart Pattern Memory** | **MUST** v1.0 | Po wyborze ćwiczenia formularz jest **automatycznie wypełniony** danymi z ostatniej sesji + widoczna data („ostatnio: 5 dni temu"). Cel <500 ms p95 |
| FIT-02 | Logowanie serii | **MUST** v1.0 | Ciężar, powtórzenia, opcjonalnie RPE i notatka. Pola zależne od `tracks` ćwiczenia |
| FIT-03 | Ćwiczenia z masą ciała | **MUST** v1.0 | Ciężar 0/null jako poprawny przypadek |
| FIT-04 | Ćwiczenia czasowe | **MUST** v1.0 | Czas zamiast powtórzeń (plank, martwy zwis). Było w modelu v1, nie było w PRD ani w UI |
| FIT-05 | Serie rozgrzewkowe | **MUST** v1.0 | Flaga `is_warmup`, wykluczane z objętości i z detekcji PR |
| FIT-06 | Timer przerwy | **MUST** v1.0 | **Auto-start po zamknięciu serii**, wartość domyślna z ćwiczenia, presety 30/60/90/120 s, skip, zmiana w trakcie, haptyka + dźwięk |
| FIT-07 | Automatyczny pomiar czasu sesji | **MUST** v1.0 | Start i koniec treningu |
| FIT-08 | Podsumowanie treningu | **MUST** v1.0 | Ekran po zapisie: objętość, czas, liczba serii, **wyróżnione PR-y** |
| FIT-09 | Detekcja PR | **MUST** v1.0 | Automatyczna, przy zapisie. Najtańszy element retencyjny, w v1 nie istniał mimo obietnicy |
| FIT-10 | Historia treningów | **MUST** v1.0 | Lista + filtr po ćwiczeniu + szczegóły. Cel: 90 dni <1 s |
| FIT-11 | Edycja i usuwanie treningu | **MUST** v1.0 | Z UI, z soft delete |
| FIT-12 | Wykresy postępu | **MUST** v1.0 | Szacowane 1RM per ćwiczenie, objętość tygodniowa, oś PR. Filtry: 30d / 90d / 6mies / 1r / całość. **Zawsze darmowe** |
| FIT-13 | Pomiary ciała | **MUST** v1.0 | Pełny formularz (waga, %tkanki, masa mięśniowa, klatka, talia, biodra, biceps, uda, łydki, notatka) + wykresy trendów. W v1 model miał 10 pól, UI pokazywało 4 |
| FIT-14 | Quick Log | SHOULD v1.0 | Uproszczony zapis: ćwiczenie + N serii + powtórzenia + ciężar |
| FIT-15 | Szablony treningowe | SHOULD v1.0 | Presety systemowe (PPL, Upper/Lower, Full Body) + tworzenie z zakończonego treningu + start treningu z szablonu. Pełny CRUD |
| FIT-16 | Eksport CSV | SHOULD v1.0 | Wymóg GDPR, obiecany użytkownikowi w ekranie prywatności |
| FIT-17 | Sugestia progresji | SHOULD v1.1 | Osobna, jawnie oznaczona warstwa nad FIT-01 — patrz §5.3 |
| FIT-18 | Streak treningowy | SHOULD v1.1 | Patrz §8.2 |
| FIT-19 | Supersety i obwody | WON'T (v2.0) | Nieproporcjonalnie komplikuje model danych |
| FIT-20 | Zdjęcia postępu | WON'T (v2.0) | Koszt Storage + E2EE + GDPR vs wartość na etapie walidacji |
| FIT-21 | Wearables (Apple Health / Google Fit) | WON'T (v2.0) | Odblokuje realne `sleep_quality` dla cross-module |
| FIT-22 | Kalorie spalone | WON'T | Pole istniało w trzech schematach bez metody obliczania ani źródła danych. Usunięte z modelu |

### 5.2 Reguły biznesowe — obliczenia

| Reguła | Definicja |
|---|---|
| Objętość serii | `weight × reps`. Serie rozgrzewkowe wykluczone |
| Objętość treningu | Suma objętości serii roboczych |
| **Szacowane 1RM** | **Epley: `weight × (1 + reps / 30)`**, dla `reps == 1` → `weight`. `[Z-3]` |
| Rekord osobisty (PR) | **Najwyższe szacowane 1RM** per (użytkownik, ćwiczenie). Jeden typ PR w v1.0 |
| Wykres siły | Pokazuje **szacowane 1RM**, nie surowy maksymalny ciężar. W v1 wykres nazywał się „siła", a pokazywał max ciężar — inna metryka |
| Domyślny czas przerwy | Z pola ćwiczenia; fallback **90 s** (w v1 były trzy sprzeczne wartości: 90, 120 i „30/60/90/120" w PRD) |
| Jednostki | **Przechowywane zawsze w SI (kg, cm), konwertowane przy wyświetlaniu.** `[Z-4]` |

`[Z-3]` **Wybór Epley zamiast Brzycki:** prostszy wzór, bardziej rozpowszechniony w aplikacjach treningowych, mniejsza rozbieżność przy 1–10 powtórzeniach — typowym zakresie treningu siłowego.

`[Z-4]` To eliminuje „konwersję danych historycznych" opisaną w v1 jako wymaganie. Konwertowanie zapisanych wartości przy zmianie jednostki jest antywzorcem — traci precyzję i jest nieodwracalne.

### 5.3 Smart Pattern Memory vs sugestia progresji — rozdzielenie

W v1 obie rzeczy były jednym mechanizmem uruchamianym przyciskiem „Get Smart Suggestion". To źródło całego bałaganu: PRD obiecywał automatyczne wypełnienie, kod wymagał tapnięcia; deload był prezentowany jako „🚀 Progressive Overload Suggested" na zielonym tle.

**FIT-01 — Pattern Memory (v1.0).** Automatyczny, deterministyczny, offline, bez AI. Pokazuje **co robiłeś ostatnio**. Wymaga ≥1 sesji. Brak danych → pusty formularz, bez komunikatu o błędzie.

**FIT-17 — Sugestia progresji (v1.1).** Opcjonalna warstwa, wizualnie odrębna, z uzasadnieniem. Mówi **co warto zrobić dziś**.

Algorytm: **double progression jako podstawa** — jeśli w poprzedniej sesji wykonano górną granicę zakresu powtórzeń we wszystkich seriach roboczych, proponuj wzrost ciężaru (+2,5 kg powyżej 80 kg, +5 kg poniżej); w przeciwnym razie ten sam ciężar i +1 powtórzenie. **RPE, jeśli dostępne, modyfikuje decyzję:** średnie RPE ≥ 9,0 → deload ×0,9 z jawną etykietą „tydzień odciążający" (nigdy nie oznaczany jako progresja); RPE < 6,0 → większy skok.

Powód zmiany: w v1 fundament algorytmu (RPE) nie był nigdzie utrwalany — tabela nie miała takiej kolumny. Drzewo decyzyjne na realnych danych zawsze trafiałoby w gałąź „brak RPE → dokładaj ciężar", czyli dokładałoby bezwarunkowo co sesję. Double progression działa bez RPE i jest bezpieczniejsze.

---

## 6. MODUŁ: LIFE COACH

Zawsze darmowy w podstawowym zakresie — to napęd adopcji dla płatnych modułów.

### 6.1 Pętla wartości

Cały moduł istnieje po to, żeby domknąć **jedną pętlę**:

```
poranny check-in → plan dnia z AI → realizacja zadań → wieczorna refleksja → lepszy plan jutro
```

W v1 ta pętla była przerwana w czterech miejscach jednocześnie: check-in nie zbierał danych o śnie, nie było przycisku uruchamiającego generację, refleksja nie trafiała do promptu dnia następnego, a zadania nie aktualizowały postępu celów. **Dopóki pętla nie działa dla jednego użytkownika na jednym urządzeniu, każda dodatkowa funkcja tego modułu zwiększa tylko dług.**

### 6.2 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| LC-01 | Poranny check-in | **MUST** v1.1 | Nastrój, energia, **jakość snu, godziny snu** (1–5 + emoji), opcjonalna notatka. Cel <60 s. CTA **„Wygeneruj mój dzień"** |
| LC-02 | Generowanie planu dnia | **MUST** v1.1 | 6–8 zadań z realnego kontekstu, wymuszony JSON, **deterministyczny plan awaryjny** przy błędzie AI |
| LC-03 | Pole `why` przy zadaniu | **MUST** v1.1 | Uzasadnienie AI. Buduje zaufanie, odróżnia od to-do listy |
| LC-04 | Motyw dnia + cytat | **MUST** v1.1 | Tani sposób na osobowość produktu |
| LC-05 | Status zadania | **MUST** v1.1 | `done` / `skipped`. Reschedule = edycja czasu, obsłużona przez LC-06 |
| LC-06 | Ręczna edycja planu | **MUST** v1.1 | Drag&drop, dodaj/edytuj/usuń. Jedyna funkcja w pełni dowieziona w v1 |
| LC-07 | Cele — CRUD | **MUST** v1.1 | Tytuł, opis, **kategoria ze słownika zamkniętego**, data docelowa, opcjonalny cel liczbowy z jednostką, priorytet |
| LC-08 | **UI wpisywania postępu celu** | **MUST** v1.1 | W v1 metoda repozytorium istniała bez interfejsu — pasek postępu zawsze pokazywał 0% |
| LC-09 | Wieczorna refleksja | **MUST** v1.1 | **Z przeglądem realizacji planu.** Wynik trafia do promptu dnia następnego |
| LC-10 | Preferencje w bazie | **MUST** v1.1 | Godziny pracy, typ dnia, obszary skupienia. W v1 mock dawał każdemu 09:00–17:00 |
| LC-11 | Streak check-inów | **MUST** v1.1 | Licznik na ekranie głównym, persystencja. Reguła w §8.2 |
| LC-12 | Zapis metryk dziennych | **MUST** v1.1 | Po każdym check-inie i zamknięciu dnia. Fundament pod cross-module — dane muszą naliczać się od dnia 1 |
| LC-13 | Zadanie powiązane z celem | SHOULD v1.1 | Opcjonalny `goal_id`; ukończenie zadania może inkrementować postęp celu |
| LC-14 | Czat z AI coachem | SHOULD v1.2 | Z limitem dziennym per tier i listą sesji |
| LC-15 | Dashboard trendów | SHOULD v1.2 | Nastrój, energia, sen w czasie |
| LC-16 | Sugestie celów przez AI | COULD v1.2 | Z akcją „akceptuj → utwórz cel" |
| LC-17 | Osobowości AI (Sage / Momentum) | WON'T (v2.0) | Podwaja powierzchnię testów promptów bez dowodu potrzeby |
| LC-18 | Planowanie adaptacyjne uczące się z korekt | WON'T (v2.0) | Wymaga miesięcy danych |
| LC-19 | Integracja z kalendarzem urządzenia | WON'T (v2.0) | Uprawnienia na obu platformach za niewielki zysk |
| LC-20 | Tygodniowy raport | WON'T (v2.0) | Wymaga crona, push i danych z 3 modułów |

### 6.3 Kontrakt AI

**Wejście do promptu planu dnia** (wszystko wymagane, brak = jawna informacja dla modelu):
check-in dnia (nastrój, energia, jakość snu, godziny snu, notatka) · aktywne cele (max 5) · preferencje użytkownika · **wieczorna refleksja z dnia poprzedniego** · **completion rate z ostatnich 3 dni** · dostępne dane cross-module (poziom stresu, ostatni trening) gdy moduły są aktywne.

Ostatnie trzy pozycje są nowe — w v1 ich brak sprawiał, że plan nie miał czym różnić się od generycznego.

**Reguły w prompcie** (przeniesione z v1 — najlepszy artefakt tamtego modułu):
6–8 zadań · miks kategorii 30% productivity / 25% fitness / 20% wellness / 15% personal / 10% social · mapowanie energii na porę dnia (wysoka → 7:00–11:00, średnia → 11:00–15:00, niska → 18:00–21:00) · przerwa co 2–3 h · budżet 6–8 h zadań · zadania **konkretne** („30 min jogi + 10 min rozciągania", nie „ćwiczenia") · przy niskiej energii łagodniejsze aktywności.

**Wyjście:** wymuszone `response_format: json_object`. Schemat: `tasks[]` (id, title, description, category, priority, estimated_duration, suggested_time, energy_level, **why**), `daily_theme`, `motivational_quote`.

**Zachowanie awaryjne — wymaganie produktowe, nie detal implementacji:**
osobne timeouty na połączenie i odpowiedź · maksymalnie 2 retry z backoffem · **deterministyczny plan zbudowany lokalnie** z aktywnych celów i preferencji, gdy AI zawiedzie · użytkownik nigdy nie widzi pustego ekranu.

**Bezpieczeństwo — w każdym prompcie konwersacyjnym:**
*„Never diagnose mental health conditions — suggest professional help if needed"* + *„You're a coach, not a therapist."* To wymaganie produktowe podnoszone do rangi kryterium akceptacji.

---

## 7. MODUŁ: SETTINGS

W v1 `features/settings/` zawierało wyłącznie GDPR. Konfiguracja użytkownika była rozproszona po trzech miejscach (`core/profile/`, `features/settings/`, `life_coach/domain/entities/user_preferences.dart`), a **wszystkie 20 kluczy ustawień istniało wyłącznie jako kolumny SQL** — zero encji Dart, zero repozytoriów, zero UI, zero cache offline.

Settings jest **węzłem centralnym** konsumowanym przez każdy moduł. Dlatego powstaje jako współdzielona infrastruktura **przed** modułami, które z niej korzystają.

### 7.1 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| SET-01 | Ekran-hub ustawień | **MUST** v1.0 | Trasa `/settings`, wejście z nawigacji głównej. W v1 ekranu nie było wcale |
| SET-02 | Jednostki | **MUST** v1.0 | Waga kg/lbs, wzrost cm/in, dystans km/mi. Globalny formater używany przez fitness i pomiary |
| SET-03 | Motyw | **MUST** v1.0 | `light` / `dark` / `system`. W v1 `darkTheme` istniał, ale użytkownik nie mógł go wybrać |
| SET-04 | Język | **MUST** v1.0 | EN + PL, pełny setup i18n **od pierwszego commita** |
| SET-05 | Profil | **MUST** v1.0 | Imię, e-mail (z ponowną weryfikacją), hasło, avatar, data urodzenia, płeć |
| SET-06 | Dane i prywatność | **MUST** v1.0 | Eksport (GDPR Art. 20), usunięcie konta (Art. 17), linki do polityki prywatności i regulaminu |
| SET-07 | Disclaimer + zasoby kryzysowe | **MUST** v1.0 | Wymóg zgodności. Widoczne, nie ukryte |
| SET-08 | O aplikacji | **MUST** v1.0 | Wersja, build, licencje OSS, kontakt |
| SET-09 | Wylogowanie | **MUST** v1.0 | W v1 nie było przycisku w żadnym ekranie ustawień |
| SET-10 | Przypomnienia lokalne | **MUST** v1.1 | Poranne i wieczorne, konfigurowalna godzina, quiet hours. **Lokalne, bez backendu** |
| SET-11 | Preferencje coachingowe | **MUST** v1.1 | Godziny pracy, pora treningu, typ dnia, obszary skupienia — realne, nie z mocka |
| SET-12 | Toggle'e prywatności **z egzekwowaniem** | **MUST** v1.2 | `allow_cross_module_sharing` musi być sprawdzany przed każdym zapisem metryk. **Nie wolno wystawiać przełącznika, który nic nie robi** |
| SET-13 | Ustawienia sync | SHOULD v1.1 | Tylko WiFi, ręczna synchronizacja, „ostatnia synchronizacja" |
| SET-14 | Push serwerowy | WON'T (v2.0) | Wymaga FCM/Edge Functions |
| SET-15 | Zarządzanie subskrypcją | WON'T (v2.0) | Patrz §9 |

### 7.2 Warstwy przechowywania

| Warstwa | Co | Dlaczego |
|---|---|---|
| Lokalne preferencje urządzenia | motyw, locale | Dostępne **przed logowaniem**, nie synchronizowane |
| Lokalna baza (Drift) | wszystkie ustawienia konta | **Źródło prawdy dla UI.** Odczyt synchroniczny, działa offline. W v1 ustawienia byłyby online-only — przy braku sieci aplikacja nie znałaby jednostek użytkownika |
| Supabase | te same ustawienia | Synchronizacja między urządzeniami |
| Secure storage | tokeny sesji, klucze | Wyłącznie sekrety |

---

## 8. Zagadnienia przekrojowe

### 8.1 Skale ocen — jedna dla całego produktu

`[Z-5]` **Wszystkie oceny subiektywne (nastrój, energia, jakość snu, stres) w skali 1–5 z emoji.**

W v1 współistniały cztery skale, a wszystkie miały się spotkać w jednej tabeli metryk. Wybór 1–5 zamiast 1–10: szybszy tap (jeden rząd emoji zamiast slidera), mniejsze obciążenie decyzyjne przy codziennym rytuale, standard w aplikacjach mood-trackingowych, zgodność z tabelą `mood_logs`. Skala 1–10 była w v1 uzasadniana wyłącznie kosztem zmiany kodu — który właśnie porzucamy.

**RPE pozostaje w skali 1–10** — to ustandaryzowana skala treningowa, mieszanie jej z ocenami subiektywnymi byłoby błędem.

### 8.2 Streaki

`[Z-6]` **Streak rośnie za dowolną aktywność danego typu w danym dniu.** Trzy typy: trening, check-in, medytacja.

Rozstrzygnięcia sprzeczności z v1:
- Wymaga **jednego** check-inu dziennie, nie obu (niższy próg = lepsza retencja, i tak działał kod).
- Pominięcie jednego dnia **nie łamie** serii; łamią ją dwa dni z rzędu. To zastępuje całą mechanikę „freeze 1/tydzień" — prościej, wybaczająco, bez stanu do synchronizacji.
- Milestone'y, odznaki, konfetti i karty do udostępniania → **v2.0**. W v1.1 jest goły licznik dni i rekord osobisty.
- **Właścicielem streaka treningowego jest moduł Fitness**, nie osobny moduł gamifikacji. W v1 streak „wisiał" między trzema dokumentami i nie miał właściciela.

### 8.3 Cross-Module Intelligence

To jedyny realny differentiator produktu — reszta (logowanie treningów, biblioteka medytacji, mood tracker) jest commodity. Ale w v1 miał 5% realizacji przy jednoczesnym byciu kryterium sukcesu MVP.

**Fundamentalne napięcie:** korelacje statystyczne wymagają ~30 dni danych z ≥2 modułów. Czyli wartość differentiatora pojawia się dokładnie wtedy, gdy większość użytkowników już odpadła.

`[Z-7]` **Rozwiązanie: dwie warstwy.**

**Warstwa regułowa (v1.2)** — 3–4 twarde reguły z progami liczbowymi, działające od **pierwszego dnia**:
| Reguła | Warunek | Komunikat |
|---|---|---|
| CMI-01 | Stres ≥ 4/5 **i** zaplanowany trening | „Wysoki stres. Rozważ lżejszą sesję zamiast ciężkiego treningu." |
| CMI-02 | Jakość snu ≤ 2/5 **i** poranny trening w planie | „Kiepski sen. Popołudniowy trening może być skuteczniejszy." |
| CMI-03 | Objętość tygodniowa > 120% średniej **i** podwyższony stres | Sugestia dnia regeneracji |
| CMI-04 | Wykryty skok stresu | Sugestia ćwiczenia oddechowego |

**Warstwa statystyczna (v2.0)** — korelacje Pearsona na 30 dniach, filtr `|r| > 0,5 ∧ p < 0,05`, top 3 przez LLM na tekst + rekomendację, próg `confidence > 0,7` dla powiadomienia, cron **tygodniowy** (nie dzienny — świadoma optymalizacja kosztów, przeniesiona z v1).

**Niezależnie od warstwy:** zapis metryk dziennych startuje w **v1.0** (fitness) i **v1.1** (life coach). Dane muszą naliczać się od dnia pierwszego, żeby warstwa statystyczna miała na czym pracować, gdy powstanie.

**Anty-fatigue (przeniesione z v1):** maksymalnie **1 insight dziennie**. Użytkownik może odrzucić, zapisać lub zadziałać.

### 8.4 Moduł Mind — zakres skrócony

Pełna specyfikacja v1 miała 30 wymagań; realizacja ~4. Zakres v1.2 jest radykalnie mniejszy i dobrany pod kryterium **koszt treści**:

| ID | Funkcja | Priorytet | Uzasadnienie |
|---|---|---|---|
| MND-01 | Mood + stress tracking | **MUST** v1.2 | **Zawsze darmowe, bez wyjątku.** Tanie, karmi cross-module, jedyna funkcja Mind używana codziennie |
| MND-02 | Ćwiczenia oddechowe (5 technik) | **MUST** v1.2 | **Zerowy koszt treści** — czysty kod + animacja + haptyka. Natychmiastowa wartość |
| MND-03 | GAD-7 / PHQ-9 + progi kryzysowe | **MUST** v1.2 | Darmowe, tanie (statyczne kwestionariusze), **wymóg bezpieczeństwa** |
| MND-04 | Wykres trendu nastroju | **MUST** v1.2 | Dowód wartości dla P3 |
| MND-05 | Biblioteka medytacji | WON'T (v2.0) | Najdroższy element produktu: 24 nagrania × 2 języki, budżet nieoszacowany |
| MND-06 | Journaling E2EE | WON'T (v2.0) | Wymaga rozstrzygnięcia recovery klucza — patrz `[Z-9]` |
| MND-07 | CBT chat | WON'T (v2.0) | Największe ryzyko prawne; wymaga osobnego frameworku moderacji treści samobójczych |
| MND-08 | Sleep stories, dźwięki ambientowe | WON'T (v2.0) | Czysty koszt treści, niski wpływ na retencję |

**Progi kryzysowe (bezwzględne):** GAD-7 > 15 lub PHQ-9 > 20 → automatyczne pokazanie zasobów kryzysowych (UK 116 123, Polska 116 123) + rekomendacja pomocy profesjonalnej. Stały disclaimer: *„LifeOS nie zastępuje profesjonalnej opieki zdrowia psychicznego."* Rating treści: PEGI 12+ / ESRB Teen.

---

## 9. Monetyzacja

`[Z-8]` **Monetyzacja jest poza zakresem v1.0–v1.2. Model biznesowy definiujemy teraz, wdrażamy w v2.0.**

Powód: w v1 istniały równocześnie trzy stacki billingowe (kolumny Stripe w schemacie, `in_app_purchase` i `flutter_stripe` w zależnościach — oba nieużywane, RevenueCat w dokumentacji) i trzy taksonomie tierów. Utrzymywanie martwego schematu subskrypcji przez trzy wersje to gwarantowany dług.

**Gdy wdrażamy — decyzje już podjęte:**
- **Wyłącznie natywne IAP** (App Store / Google Play), agregowane przez RevenueCat. Stripe za treści cyfrowe w aplikacji mobilnej łamie regulaminy obu sklepów.
- **Jedna taksonomia tierów:** `free` · `single_module` · `bundle` · `full`.
- **Zawsze darmowe, bez wyjątku:** Life Coach podstawowy (plan dnia, check-iny, do 3 celów), mood i stress tracking, ćwiczenia oddechowe, GAD-7/PHQ-9, **wykresy postępu fitness**.
- Free tier **nie wygasa** i **nie wymaga karty**. Ograniczenia pokazywane jawnie, nie ukrywane.
- Po anulowaniu: **zero utraty danych**, treści powyżej limitu przechodzą w tryb tylko do odczytu.

Do usunięcia ze schematu do czasu wdrożenia: kolumny Stripe, tabela subskrypcji, zależności `flutter_stripe` i `in_app_purchase`.

---

## 10. Wymagania niefunkcjonalne

Progi przeniesione z v1 (były konkretne i mierzalne) z korektami tam, gdzie były nierealistyczne.

### 10.1 Wydajność

| Metryka | Cel |
|---|---|
| Zimny start | < 2 s (p95) |
| Ciepły start | < 500 ms (p95) |
| Przejście między ekranami | < 300 ms |
| Reakcja na tap | < 100 ms |
| **Smart Pattern Memory** | **< 500 ms (p95)** — killer feature, musi być natychmiastowy |
| Wyszukiwanie ćwiczeń | < 200 ms |
| Zapis serii | < 100 ms |
| Historia 90 dni | < 1 s |
| Generowanie planu AI | < 4 s (p95), timeout 10 s → plan awaryjny |
| Rozmiar pobrania | < 60 MB (podniesione z 50 — bundled katalog ćwiczeń z ilustracjami) |
| Pamięć aktywna | < 250 MB |

### 10.2 Offline

`[Z-1]` **Offline-first jest wymaganiem produktu, nie architektury.**

Podstawowy scenariusz użycia to siłownia w piwnicy bez zasięgu. Aplikacja treningowa, która tam nie działa, jest bezużyteczna.

| Funkcja | Offline |
|---|---|
| Katalog ćwiczeń (przeglądanie, wyszukiwanie, filtry) | **100%** |
| Logowanie treningu, edycja, historia, wykresy | **100%** |
| Pomiary ciała | **100%** |
| Ustawienia | **100%** |
| Check-iny, cele, mood, oddech | **100%** |
| Generowanie planu AI, czat | Wymaga sieci — jawny komunikat, plan awaryjny |

Rozwiązywanie konfliktów: **last-write-wins po `updated_at`**. Każda synchronizowana tabela ma `updated_at`, `is_synced`, `deleted_at` — bez wyjątków (w v1 `mood_logs` nie miało `updated_at`, więc LWW zawsze przegrywał).

### 10.3 Bezpieczeństwo

- **Żaden klucz API nie może znaleźć się w kodzie klienta ani w assetach.** Konfiguracja wyłącznie przez `--dart-define-from-file` przy buildzie. Klucz `service_role` istnieje wyłącznie jako sekret Edge Function.
- **Wszystkie wywołania AI przez Edge Function `ai-orchestrator`.** Bez tego nie da się egzekwować limitów, mierzyć kosztów ani chronić klucza. To warunek konieczny całej sekcji monetyzacji.
- RLS na każdej tabeli użytkownika. `user_id` obowiązkowo na każdej tabeli użytkownika.
- Hasło: min. 8 znaków, wielka litera, cyfra, znak specjalny. Sesja 30 dni bezczynności.
- Skanowanie sekretów (`gitleaks`) jako blokujący krok w CI.

`[Z-9]` **E2EE odłożone do v2.0 wraz z journalingiem.** Gdy wraca — model **key-wrapping**: losowy klucz danych opakowany kluczem z hasła, plus **kod odzyskiwania** generowany przy zakładaniu konta. Wtedy zmiana hasła wymaga tylko ponownego opakowania klucza, nie ponownego szyfrowania danych. W v1 klucz był derywowany wprost z hasła i **reset hasła oznaczał trwałą utratę wszystkich wpisów** — czego dokumentacja nigdzie nie odnotowała.

### 10.4 Prywatność i GDPR

- **Analityka opt-in, domyślnie wyłączona.** W v1 kolumna miała `DEFAULT TRUE` przy jednoczesnym wymaganiu opt-in — konflikt zgodności.
- Analiza AI treści prywatnych wyłącznie za jawną zgodą.
- Eksport wszystkich danych: JSON + CSV w archiwum, link ważny 7 dni, **rate limit egzekwowany po stronie serwera** (w v1 był w stanie widgetu — resetował się po restarcie aplikacji).
- Usunięcie konta: **7 dni grace period w UI, 30 dni retencji backupów.** Jedna definicja w całej dokumentacji (w v1 były trzy).
- Nigdy nie sprzedajemy danych.

### 10.5 Dostępność i lokalizacja

- VoiceOver / TalkBack dla kluczowych przepływów, etykiety semantyczne wszystkich elementów interaktywnych.
- Kontrast WCAG AA (4,5:1 tekst, 3:1 duży tekst).
- Skalowanie tekstu do 200%.
- Cele dotykowe min. 44×44 pt (iOS) / 48×48 dp (Android).
- **Języki: EN + PL od v1.0.** Setup i18n od pierwszego commita — retrofit do gotowej aplikacji z katalogiem 200+ ćwiczeń jest wielokrotnie droższy.

### 10.6 Platformy

`[Z-10]` **iOS 14+ i Android 10+. Web i Windows usunięte z zakresu.**

Repo v1 miało katalogi `android/`, `ios/`, `web/`, `windows/` przy zerze działających ekranów. Cztery platformy to czterokrotny koszt testowania funkcji, która nie istnieje.

### 10.7 Niezawodność

Crash rate < 0,5% · walidacja server-side dla wszystkich zapisów · backupy dzienne z PITR do 7 dni.

---

## 11. Przyjęte założenia

Każde zamyka pytanie otwarte w v1. Zmiana któregokolwiek jest tania **teraz**.

| ID | Założenie | Konsekwencja, jeśli błędne |
|---|---|---|
| **Z-1** | Offline-write jest wymagany od v1.0 | Gdyby nie był — upraszcza architekturę o cały mechanizm outboxu (~2 tygodnie pracy) |
| **Z-2** | Katalog: 200–250 ćwiczeń, bundled JSON, EN+PL | Import z otwartej bazy skraca produkcję, ale wymaga weryfikacji licencji i tłumaczenia |
| **Z-3** | 1RM liczone wzorem Epley | Zmiana wzoru unieważnia historyczne PR-y — decyzja musi zapaść przed pierwszym zapisem |
| **Z-4** | Jednostki przechowywane w SI, konwertowane przy wyświetlaniu | — |
| **Z-5** | Wszystkie oceny subiektywne w skali 1–5 | Zmiana po starcie unieważnia dane historyczne i korelacje |
| **Z-6** | Streak: dowolna aktywność dziennie, łamie się po 2 dniach przerwy, bez mechaniki freeze | — |
| **Z-7** | Cross-module: najpierw reguły, korelacje statystyczne dopiero w v2.0 | — |
| **Z-8** | Monetyzacja poza zakresem v1.x; gdy wraca — wyłącznie IAP przez RevenueCat | Jeśli monetyzacja jest potrzebna w 6 miesięcy, IAP wchodzi do v1.2 |
| **Z-9** | E2EE i journaling odłożone do v2.0; model key-wrapping + kod odzyskiwania | — |
| **Z-10** | Tylko iOS i Android | — |
| **Z-11** | AI wchodzi dopiero w v1.1, zawsze przez `ai-orchestrator` | Jeśli AI ma być w v1.0, Edge Function staje się zadaniem P0 |

---

## 12. Kryteria sukcesu

### 12.1 Definition of Done — wymaganie
Funkcja jest ukończona, gdy: **osiągalna z aplikacji** (trasa + wejście z nawigacji) · działa na **realnych danych** (zero mocków w `lib/`) · zapis i odczyt są **symetryczne** (odczyt zwraca to, co zapisano, po restarcie) · pokryta testem · działa offline, jeśli tak deklaruje.

W v1 „Done" oznaczało istnienie pliku. To jedyna przyczyna raportowania 45–66% gotowości przy zerowej liczbie funkcji osiągalnych z aplikacji.

### 12.2 Kryteria wyjścia wersji

**v1.0:** trening zalogowany offline w < 60 s od otwarcia aplikacji · widoczny po restarcie z kompletem serii · wykresy na realnych danych użytkownika · katalog przeszukiwany bez sieci · zielone CI · zero mocków w `lib/`.

**v1.1:** 7 dni z rzędu check-inów wykonalne bez błędu · plan generowany z realnego kontekstu (sen, nastrój, cele, wczorajsza refleksja) · plan awaryjny działa przy odciętym API · żaden klucz API nie występuje w binarce.

**v1.2:** insight cross-module pojawia się po 7 dniach danych z 2 modułów · progi kryzysowe przetestowane · toggle prywatności realnie blokuje zapis metryk.

### 12.3 Metryki produktowe

North Star: **retencja D30**. Cel v1 był ustawiony na 10–12% (3× średnia branżowa) przy zespole, który nie dowiózł onboardingu.

`[Z-12]` **Realistyczna ścieżka: v1.0 ≥ 5% D30 → v1.2 ≥ 8% → v2.0 ≥ 10%.** Poniżej 3% po v1.0 → pivot, nie kolejne funkcje.

Pozostałe: ocena w sklepie ≥ 4,3 · crash rate < 0,5% · **mediana czasu logowania treningu < 60 s** (to metryka killer feature'u i powinna być mierzona od dnia 1).

---

## 13. Co zostało świadomie wycięte

Pełna lista, żeby nie wróciło tylnymi drzwiami: onboarding z wyborem ścieżki · osobowości AI · odznaki, konfetti, karty do udostępniania · tygodniowe raporty · push serwerowy · integracja z kalendarzem · biblioteka medytacji audio · sleep stories i dźwięki ambientowe · CBT chat · journaling E2EE · korelacje statystyczne · supersety i obwody · zdjęcia postępu · wearables · kalorie · monetyzacja · web i Windows · MFA.

Każda z tych pozycji miała w v1 dokumentację, a część miała status „Complete". Żadna nie działała.
