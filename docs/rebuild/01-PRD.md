# LifeOS — PRD (przebudowa, PWA-first)

**Wersja dokumentu:** 1.0
**Data:** 2026-08-11
**Status:** Draft do przeglądu
**Kontekst:** Dokument opisuje produkt budowany **od zera** jako aplikacja webowa (PWA), z docelową ścieżką do sklepów mobilnych przez Capacitor. Poprzednia implementacja (Flutter) jest porzucana. Szczegółowa analiza tego, co poszło nie tak, znajduje się w `docs/v2/00-ANALYSIS-FINDINGS.md` — ten dokument jest samodzielny i nie wymaga jej lektury.

---

## 0. Jak czytać ten dokument

Wymagania mają priorytet MoSCoW **w obrębie swojej wersji**:
`MUST` — bez tego wersja nie wychodzi · `SHOULD` — wychodzi, ale gorsza · `COULD` — jeśli zostanie czas · `WON'T` — świadomie odłożone, z podaną wersją docelową.

Numeracja jest **per moduł** (`FIT-01`, `LC-01`, `EX-01`, `SET-01`, `MND-01`, `CORE-01`), nie ciągła. Numer nigdy nie jest użyty ponownie. Poprzednia wersja miała ciągłą numerację FR1–FR123, która skolidowała między dokumentami i uniemożliwiała dodawanie wymagań bez przenumerowania wszystkiego.

**Przyjęte założenia** są oznaczone `[Z-n]` i zebrane w §12. Każde zamyka pytanie, które w poprzednim podejściu pozostawało otwarte przez rok.

---

## 1. Dlaczego budujemy od nowa

Poprzednia wersja osiągnęła 217 plików kodu i 206 dokumentów, raportując 45–66% gotowości. Faktycznie **około 200 z 217 plików było nieosiągalnych z poziomu interfejsu** — aplikacja nie miała działającego ekranu głównego. Killer feature działał na danych testowych. Serie treningowe zapisywały się bez powiązania z treningiem, więc ich zawartość była nieodzyskiwalna.

Przyczyną nie były złe decyzje architektoniczne, tylko kolejność pracy: budowano funkcje, których nikt nie mógł uruchomić, i przypisywano im status „ukończone" na podstawie **istnienia pliku**, a nie działającej ścieżki użytkownika.

**Trzy zasady, które z tego wynikają i obowiązują w tym projekcie:**

1. **Definition of Done = działający przepływ end-to-end.** Funkcja jest ukończona, gdy jest osiągalna z nawigacji, działa na realnych danych, zapis i odczyt są symetryczne po odświeżeniu strony, i jest pokryta testem. Istnienie komponentu nie liczy się jako „done".
2. **Walking skeleton przed architekturą.** Zanim powstanie druga funkcja, musi działać: uruchomienie → logowanie → nawigacja → zapis treningu → odświeżenie → trening widoczny z kompletem serii → zielone CI.
3. **Status wywodzi się z kodu.** Jedna lista zadań, jeden status na pozycję, odhaczany przy merge'u, nie przy planowaniu.

---

## 2. Produkt

### 2.1 Czym jest LifeOS

Modularna aplikacja łącząca trzy obszary: **trening siłowy**, **planowanie dnia z AI** i **zdrowie psychiczne** — w jednym produkcie, gdzie moduły wymieniają się danymi.

Forma: **instalowalna aplikacja webowa (PWA)**, działająca w przeglądarce na telefonie i desktopie, dodawana do ekranu głównego. Docelowo ten sam kod trafia do App Store i Google Play jako aplikacja natywna przez Capacitor.

### 2.2 Problem

Osoba pracująca zawodowo, która chce być w formie, używa dziś trzech osobnych aplikacji: do logowania treningów, do planowania zadań, do medytacji. Żadna nie wie o istnieniu pozostałych. Aplikacja treningowa proponuje ciężki trening w dniu, w którym użytkownik spał cztery godziny. Aplikacja do planowania układa dzień pełen zadań, gdy energia jest na dnie. Koszt takiego zestawu to około £320 rocznie.

Drugi problem, węższy ale ostrzejszy: **logowanie treningu jest żmudne**. Standardowy wzorzec to wpisywanie ciężaru i powtórzeń dla każdej serii z klawiatury, w hałaśliwej siłowni, między seriami. Zabiera to około pięciu minut na sesję i jest głównym powodem porzucania aplikacji treningowych.

### 2.3 Propozycja wartości

1. **Smart Pattern Memory** — aplikacja pamięta, co robiłeś ostatnio z danym ćwiczeniem, i wypełnia formularz, zanim go dotkniesz. Logowanie serii to jedno tapnięcie potwierdzenia. Cel: **poniżej 2 sekund na ćwiczenie zamiast pięciu minut na trening**.
2. **Wykresy postępu zawsze za darmo** — u konkurencji (Strong, FitBod) są za paywallem. To świadoma przewaga cenowa, nie przeoczenie.
3. **Moduły rozmawiają ze sobą** — plan dnia zna Twój sen i nastrój, sugestia treningu zna Twój poziom stresu, podsumowanie tygodnia łączy wszystkie trzy obszary.
4. **Zero instalacji na wejściu** — użytkownik dostaje link i używa produktu w piętnaście sekund. To realna przewaga akwizycyjna nad konkurencją wymagającą pobrania z App Store.

### 2.4 Czym LifeOS nie jest

- Nie zastępuje opieki psychologicznej ani medycznej. Disclaimer i zasoby kryzysowe są wymogiem, nie dodatkiem.
- Nie jest aplikacją dietetyczną — liczenie kalorii i makroskładników jest poza zakresem.
- Nie jest siecią społecznościową — funkcje społeczne są poza zakresem.
- Nie jest trenerem personalnym — AI proponuje i wyjaśnia, nie przepisuje programów treningowych.

---

## 3. Persony

Poprzednia wersja nie miała person — cała definicja odbiorcy to był jeden wiersz tabeli („22–45, professionals"). To za mało, żeby rozstrzygnąć, czy funkcją prowadzącą jest szybkie logowanie treningu, czy redukcja stresu. **P1 jest personą prowadzącą dla v1.0.**

### P1 — Marek, 31 lat · odbiorca v1.0

Programista, trenuje siłowo trzy do czterech razy w tygodniu od dwóch lat, w domowym garażu albo w osiedlowej siłowni. Zna podstawy progresji, prowadzi notatki w arkuszu kalkulacyjnym albo w aplikacji, której nie lubi.

**Bóle:** wpisywanie tych samych liczb w kółko · brak zasięgu w siłowni w piwnicy · wykresy postępu za paywallem · niepewność, czy faktycznie robi progres, czy powtarza te same ciężary.
**Czego chce od aplikacji:** żeby zniknęła. Otworzyć, tapnąć, zamknąć.
**Kryterium sukcesu:** loguje trening w mniej niż minutę i wraca po trzydziestu dniach.

### P2 — Ania, 36 lat · odbiorca v1.1

Menedżerka, trenuje nieregularnie (raz–dwa razy w tygodniu, zależnie od tygodnia w pracy), śpi za mało, ma poczucie, że dzień „się dzieje" zamiast być zaplanowany.

**Bóle:** planowanie dnia od zera każdego ranka · wyrzuty sumienia, gdy plan się nie udaje · treningi, na które nie ma energii.
**Czego chce:** żeby ktoś powiedział jej, co dziś realnie da się zrobić — z uwzględnieniem tego, że spała pięć godzin.
**Kryterium sukcesu:** robi poranny check-in przez siedem dni z rzędu.

### P3 — Kasia, 27 lat · odbiorca v1.2

Pracuje zdalnie, wysoki poziom stresu, korzystała z Calm i Headspace, zrezygnowała po okresie próbnym. Trening traktuje jako narzędzie regulacji nastroju, nie jako cel.

**Bóle:** stres bez ujścia · brak dowodu, że cokolwiek pomaga.
**Czego chce:** krótkie narzędzie na pięć minut w środku dnia i dowód, że działa.
**Kryterium sukcesu:** widzi w podsumowaniu tygodnia korelację między aktywnością a nastrojem.

**Konsekwencja dla zakresu:** v1.0 jest budowane wyłącznie pod Marka. Nie ma w nim AI, medytacji ani onboardingu z wyborem ścieżki. Jest szybkie logowanie treningu.

---

## 4. Zakres wersji

| Wersja | Zakres | Persona | Warunek wyjścia |
|---|---|---|---|
| **v1.0** | Fundament + Exercise + Fitness + Settings | P1 Marek | Trening zalogowany w poniżej 60 s, widoczny po odświeżeniu z kompletem serii; wykresy na realnych danych; katalog przeszukiwalny bez sieci |
| **v1.1** | **Zapis offline** + Life Coach + AI przez serwer + Capacitor | P2 Ania | Trening logowany bez zasięgu i synchronizowany po powrocie; pełna pętla check-in → plan → refleksja działa 7 dni; aplikacja w sklepach |
| **v1.2** | Mind + insighty cross-module regułowe | P3 Kasia | Insight pojawia się po 7 dniach danych z dwóch modułów |
| **v2.0** | Monetyzacja, medytacje audio, korelacje statystyczne, gamifikacja | — | — |

**Uzasadnienie kolejności.** Fitness jest jedynym modułem samowystarczalnym: nie potrzebuje AI, kluczy API, funkcji serwerowych ani produkcji treści audio. Da się go dowieźć do użytkowników. Life Coach wymaga zbudowania warstwy pośredniczącej AI — to osobny strumień pracy, który w poprzednim podejściu nigdy nie ruszył. Mind wymaga produkcji audio, czyli budżetu i czasu, których nikt nie oszacował. Insighty cross-module wymagają danych z co najmniej dwóch modułów, więc fizycznie nie mogą być pierwsze.

---

## 5. MODUŁ: EXERCISE (katalog ćwiczeń)

Katalog jest **fundamentem modułu Fitness, nie osobnym bytem**. W poprzedniej wersji był katalogiem-sierotą bez jednej referencji z zewnątrz, a logowanie treningu używało nazwy ćwiczenia jako wolnego tekstu — co rozbijało historię, statystyki, pre-fill i rekordy przy każdej literówce. Tutaj katalog powstaje **przed** logowaniem treningu.

### 5.1 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| EX-01 | Katalog dostępny offline | **MUST** v1.0 | 200–250 ćwiczeń jako statyczny zasób aplikacji, zapisywany lokalnie przy pierwszym uruchomieniu. Zero zależności od sieci przy przeglądaniu |
| EX-02 | Wersjonowanie katalogu | **MUST** v1.0 | Numer wersji katalogu; aktualizacja przyrostowa z serwera, gdy dostępna jest nowsza |
| EX-03 | Wyszukiwanie pełnotekstowe | **MUST** v1.0 | Po nazwie, mięśniach i sprzęcie, z opóźnieniem 150 ms. Cel poniżej 200 ms |
| EX-04 | Filtry | **MUST** v1.0 | Kategoria, sprzęt, typ, poziom — **wszystkie dostępne z interfejsu**. W poprzedniej wersji dwa filtry istniały w kodzie bez żadnego elementu UI, który by je ustawiał |
| EX-05 | Szczegóły ćwiczenia | **MUST** v1.0 | Nazwa, mięśnie główne i pomocnicze, sprzęt, instrukcja krokowa, 3–5 wskazówek technicznych, 3–5 typowych błędów |
| EX-06 | Ulubione | **MUST** v1.0 | Przełącznik z listy i z widoku szczegółów |
| EX-07 | Ostatnio i najczęściej używane | **MUST** v1.0 | Dwie sekcje na górze wyboru ćwiczenia, liczone z historii treningów. Tanie w implementacji, wysoka wartość dla użytkownika |
| EX-08 | Tryb wyboru | **MUST** v1.0 | Ten sam katalog w dwóch trybach — przeglądanie i wybór do treningu. Jeden komponent, nie dwa |
| EX-09 | Ćwiczenia własne | **MUST** v1.0 | Pełny cykl tworzenia, edycji i usuwania z interfejsu. W poprzedniej wersji formularz wyświetlał komunikat „utworzono pomyślnie" i nie zapisywał niczego |
| EX-10 | Dwujęzyczność katalogu | **MUST** v1.0 | EN + PL. Osobna warstwa tłumaczeń; wyszukiwanie działa na aktywnym języku z awaryjnym powrotem do EN |
| EX-11 | Ilustracje i diagramy mięśni | SHOULD v1.0 | Statyczne, dołączone do aplikacji, lekkie |
| EX-12 | Substytucje ćwiczeń | COULD v1.1 | Zamienniki na podstawie wzorca ruchu, mięśni i dostępnego sprzętu |
| EX-13 | Wideo instruktażowe | WON'T (v2.0) | Streaming przez URL |

### 5.2 Taksonomia

W poprzedniej wersji kategoria była **wyliczana** z pierwszego elementu listy mięśni przez dopasowanie fragmentu tekstu, w dwóch wzajemnie sprzecznych implementacjach. Ćwiczenie oznaczone `['triceps','chest']` trafiało do kategorii „Ramiona", a `['traps']` do „Inne".

| Wymiar | Wartości | Uwaga |
|---|---|---|
| `category` | chest, back, legs, shoulders, arms, core, cardio, full_body, other | **Jawne pole**, nie wartość wyliczana |
| `exercise_type` | strength, cardio, mobility, stretching, plyometric | Nowe. Wcześniej „cardio" było przemycane jako wartość na liście mięśni, mieszając dwa wymiary |
| `primary_muscles[]` / `secondary_muscles[]` | słownik zamknięty | Rozdzielone. Wcześniej jedna płaska lista |
| `equipment[]` | barbell, dumbbell, kettlebell, machine, cable, bodyweight, resistance_band, suspension, smith_machine, medicine_ball, bench, sled, none | **Lista**, nie pojedyncza wartość — wyciskanie leżąc wymaga sztangi *i* ławki |
| `movement_pattern` | push_horizontal, push_vertical, pull_horizontal, pull_vertical, squat, hinge, lunge, carry, rotation, isolation | Nowe. Warunek konieczny dla substytucji i przyszłego generowania planów |
| `difficulty` | beginner, intermediate, advanced | |
| `is_compound`, `is_unilateral` | wartość logiczna | |
| `tracks` | podzbiór {weight, reps, time, distance} | **Krytyczne.** Określa, które pola pokazać przy logowaniu. Wcześniej zawsze pokazywano ciężar i powtórzenia — także dla planku i biegu |
| `default_rest_seconds` | liczba | Zasila timer przerwy per ćwiczenie |

### 5.3 Treść katalogu

`[Z-2]` **200–250 ćwiczeń, dołączonych do aplikacji jako dane statyczne, w dwóch językach.**

Poprzednia wersja deklarowała „500+" we wszystkich dokumentach, w komentarzach kodu i w nagłówku ekranu. Faktycznie było ich **105**, a sam plik z danymi przyznawał to w komentarzu na końcu. Nowa liczba jest realna. Jakość opisu — instrukcja, wskazówki techniczne, typowe błędy, w dwóch językach — jest ważniejsza niż liczba pozycji.

**Decyzja do podjęcia przed startem:** produkcja własna czy import z otwartej bazy (`free-exercise-db`, wger). Obie są na licencjach otwartych, ale wymagają weryfikacji zgodności i tłumaczenia na polski. To jest **zadanie contentowe, nie programistyczne** — musi mieć osobnego właściciela i biec równolegle od pierwszego dnia, inaczej stanie się ścieżką krytyczną.

---

## 6. MODUŁ: FITNESS

### 6.1 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| FIT-01 | **Smart Pattern Memory** | **MUST** v1.0 | Po wyborze ćwiczenia formularz jest **automatycznie wypełniony** danymi z ostatniej sesji, z widoczną informacją „ostatnio: 5 dni temu". Cel poniżej 500 ms |
| FIT-02 | Logowanie serii | **MUST** v1.0 | Ciężar, powtórzenia, opcjonalnie RPE i notatka. Widoczne pola zależą od `tracks` ćwiczenia |
| FIT-03 | Ćwiczenia z masą ciała | **MUST** v1.0 | Ciężar zerowy lub pusty jako poprawny przypadek |
| FIT-04 | Ćwiczenia czasowe | **MUST** v1.0 | Czas zamiast powtórzeń (plank, martwy zwis). Istniało w modelu danych poprzedniej wersji, ale nie w wymaganiach ani w interfejsie |
| FIT-05 | Serie rozgrzewkowe | **MUST** v1.0 | Oznaczane, wykluczane z objętości i z wykrywania rekordów |
| FIT-06 | Timer przerwy | **MUST** v1.0 | **Automatyczny start po zamknięciu serii**, wartość domyślna z ćwiczenia, warianty 30/60/90/120 s, pominięcie, zmiana w trakcie, wibracja i dźwięk |
| FIT-07 | Pomiar czasu sesji | **MUST** v1.0 | Automatyczny start i zakończenie treningu |
| FIT-08 | Podsumowanie treningu | **MUST** v1.0 | Ekran po zapisie: objętość, czas, liczba serii, **wyróżnione rekordy** |
| FIT-09 | Wykrywanie rekordów | **MUST** v1.0 | Automatyczne przy zapisie. Najtańszy element budujący powroty; w poprzedniej wersji nie istniał mimo obietnicy w dokumentacji |
| FIT-10 | Historia treningów | **MUST** v1.0 | Lista, filtr po ćwiczeniu, widok szczegółów. Cel: 90 dni poniżej 1 s |
| FIT-11 | Edycja i usuwanie treningu | **MUST** v1.0 | Z interfejsu, z usuwaniem miękkim |
| FIT-12 | Wykresy postępu | **MUST** v1.0 | Szacowane 1RM per ćwiczenie, objętość tygodniowa, oś rekordów. Zakresy: 30 dni / 90 dni / 6 miesięcy / rok / całość. **Zawsze darmowe** |
| FIT-13 | Pomiary ciała | **MUST** v1.0 | Pełny formularz (waga, tkanka tłuszczowa, masa mięśniowa, klatka, talia, biodra, biceps, uda, łydki, notatka) plus wykresy trendów. Wcześniej model miał dziesięć pól, a interfejs pokazywał cztery |
| FIT-14 | Szybkie logowanie | SHOULD v1.0 | Uproszczony zapis: ćwiczenie, liczba serii, powtórzenia, ciężar |
| FIT-15 | Szablony treningowe | SHOULD v1.0 | Gotowe zestawy (PPL, Góra/Dół, Full Body), tworzenie szablonu z zakończonego treningu, start treningu z szablonu. Pełny cykl edycji |
| FIT-16 | Eksport CSV | SHOULD v1.0 | Wymóg RODO, obiecany użytkownikowi w ekranie prywatności |
| FIT-17 | Sugestia progresji | SHOULD v1.1 | Osobna, jawnie oznaczona warstwa nad FIT-01 — patrz §6.3 |
| FIT-18 | Seria treningowa | SHOULD v1.1 | Patrz §9.2 |
| FIT-19 | Supersety i obwody | WON'T (v2.0) | Nieproporcjonalnie komplikują model danych względem wartości dla persony P1 |
| FIT-20 | Zdjęcia postępu | WON'T (v2.0) | Koszt przechowywania, szyfrowania i zgodności RODO względem wartości na etapie walidacji |
| FIT-21 | Integracja z Apple Health / Google Fit | WON'T (v2.0) | Wymaga Capacitora; odblokuje realne dane o śnie dla insightów cross-module |
| FIT-22 | Kalorie spalone | WON'T | Pole istniało w trzech schematach bez metody obliczania i bez źródła danych. Usunięte z modelu |

### 6.2 Reguły obliczeniowe

| Reguła | Definicja |
|---|---|
| Objętość serii | `ciężar × powtórzenia`. Serie rozgrzewkowe wykluczone |
| Objętość treningu | Suma objętości serii roboczych |
| **Szacowane 1RM** | **Wzór Epleya: `ciężar × (1 + powtórzenia / 30)`**; dla jednego powtórzenia równe ciężarowi. `[Z-3]` |
| Rekord osobisty | **Najwyższe szacowane 1RM** dla pary (użytkownik, ćwiczenie). Jeden typ rekordu w v1.0 |
| Wykres siły | Pokazuje **szacowane 1RM**, nie surowy maksymalny ciężar. W poprzedniej wersji wykres nazywał się „siła", a prezentował maksymalny ciężar — to inna metryka |
| Domyślna przerwa | Wartość z ćwiczenia; awaryjnie **90 s**. Wcześniej istniały trzy sprzeczne wartości: 90, 120 i „30/60/90/120" w wymaganiach |
| Jednostki | **Przechowywane zawsze w SI (kg, cm), przeliczane wyłącznie przy wyświetlaniu.** `[Z-4]` |

`[Z-3]` Wybór wzoru Epleya zamiast Brzyckiego: prostszy, bardziej rozpowszechniony w aplikacjach treningowych, mniejsza rozbieżność w zakresie 1–10 powtórzeń, typowym dla treningu siłowego.

`[Z-4]` Eliminuje „konwersję danych historycznych", która w poprzedniej wersji figurowała jako wymaganie. Przeliczanie zapisanych wartości przy zmianie jednostki traci precyzję i jest nieodwracalne.

### 6.3 Pamięć wzorca a sugestia progresji — rozdzielenie

W poprzedniej wersji obie rzeczy były jednym mechanizmem uruchamianym przyciskiem. To było źródło całego zamieszania: wymagania obiecywały automatyczne wypełnienie, a kod wymagał kliknięcia; tydzień odciążający był prezentowany jako „🚀 Sugerowana progresja" na zielonym tle.

**FIT-01 — Pamięć wzorca (v1.0).** Automatyczna, deterministyczna, bez AI. Pokazuje **co robiłeś ostatnio**. Wymaga jednej wcześniejszej sesji. Brak danych oznacza pusty formularz, bez komunikatu o błędzie.

**FIT-17 — Sugestia progresji (v1.1).** Opcjonalna warstwa, wizualnie odrębna, zawsze z uzasadnieniem. Mówi **co warto zrobić dziś**.

Algorytm: **podwójna progresja jako podstawa** — jeśli w poprzedniej sesji wykonano górną granicę zakresu powtórzeń we wszystkich seriach roboczych, proponuj wzrost ciężaru (+2,5 kg powyżej 80 kg, +5 kg poniżej); w przeciwnym razie ten sam ciężar i jedno powtórzenie więcej. **RPE, jeśli dostępne, modyfikuje decyzję:** średnia od 9,0 wzwyż oznacza tydzień odciążający (ciężar ×0,9, **nigdy nieoznaczany jako progresja**); poniżej 6,0 oznacza większy skok.

Powód zmiany względem poprzedniej wersji: fundamentem tamtego algorytmu było RPE, które **nie miało kolumny w bazie danych**. Na realnych danych drzewo decyzyjne zawsze trafiałoby w gałąź „brak RPE, dokładaj ciężar" — czyli dokładałoby bezwarunkowo co sesję. Podwójna progresja działa bez RPE i jest bezpieczniejsza.

---

## 7. MODUŁ: LIFE COACH

Zawsze darmowy w podstawowym zakresie — napędza adopcję płatnych modułów.

### 7.1 Pętla wartości

Cały moduł istnieje po to, żeby domknąć **jedną pętlę**:

```
poranny check-in → plan dnia z AI → realizacja zadań → wieczorna refleksja → lepszy plan jutro
```

W poprzedniej wersji pętla była przerwana w czterech miejscach jednocześnie: check-in nie zbierał danych o śnie, nie istniał przycisk uruchamiający generowanie planu, refleksja nie trafiała do kontekstu następnego dnia, a ukończone zadania nie aktualizowały postępu celów. **Dopóki pętla nie działa dla jednego użytkownika, każda dodatkowa funkcja tego modułu zwiększa tylko dług.**

### 7.2 Funkcje

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| LC-01 | Poranny check-in | **MUST** v1.1 | Nastrój, energia, **jakość snu, godziny snu** (skala 1–5 z emoji), opcjonalna notatka. Cel poniżej 60 s. Wyraźne wezwanie do działania: **„Wygeneruj mój dzień"** |
| LC-02 | Generowanie planu dnia | **MUST** v1.1 | 6–8 zadań z realnego kontekstu, wymuszona odpowiedź w formacie JSON, **deterministyczny plan awaryjny** przy błędzie AI |
| LC-03 | Uzasadnienie przy zadaniu | **MUST** v1.1 | Pole wyjaśniające, dlaczego to zadanie. Buduje zaufanie i odróżnia produkt od zwykłej listy zadań |
| LC-04 | Motyw dnia i cytat | **MUST** v1.1 | Tani sposób na nadanie produktowi osobowości |
| LC-05 | Status zadania | **MUST** v1.1 | Ukończone lub pominięte. Przełożenie to edycja czasu, obsługiwana przez LC-06 |
| LC-06 | Ręczna edycja planu | **MUST** v1.1 | Zmiana kolejności, dodawanie, edycja, usuwanie. Jedyna funkcja w pełni dowieziona w poprzedniej wersji |
| LC-07 | Cele | **MUST** v1.1 | Tytuł, opis, **kategoria ze słownika zamkniętego**, data docelowa, opcjonalna wartość liczbowa z jednostką, priorytet |
| LC-08 | **Interfejs wpisywania postępu celu** | **MUST** v1.1 | W poprzedniej wersji metoda zapisu istniała bez żadnego elementu UI — pasek postępu zawsze pokazywał zero |
| LC-09 | Wieczorna refleksja | **MUST** v1.1 | **Z przeglądem realizacji planu.** Wynik trafia do kontekstu następnego dnia |
| LC-10 | Preferencje w bazie | **MUST** v1.1 | Godziny pracy, typ dnia, obszary skupienia. Wcześniej dane testowe dawały każdemu użytkownikowi godziny 9–17 |
| LC-11 | Seria check-inów | **MUST** v1.1 | Licznik na ekranie głównym, trwale zapisany. Reguła w §9.2 |
| LC-12 | Zapis metryk dziennych | **MUST** v1.1 | Po każdym check-inie i zamknięciu dnia. Fundament pod insighty cross-module — dane muszą naliczać się od pierwszego dnia |
| LC-13 | Zadanie powiązane z celem | SHOULD v1.1 | Opcjonalne powiązanie; ukończenie zadania może zwiększać postęp celu |
| LC-14 | Rozmowa z AI | SHOULD v1.2 | Z dziennym limitem i listą sesji |
| LC-15 | Wykresy trendów | SHOULD v1.2 | Nastrój, energia, sen w czasie |
| LC-16 | Sugestie celów przez AI | COULD v1.2 | Z akcją „akceptuj i utwórz cel" |
| LC-17 | Osobowości AI | WON'T (v2.0) | Podwaja powierzchnię testowania bez dowodu, że użytkownicy tego chcą |
| LC-18 | Planowanie uczące się z korekt | WON'T (v2.0) | Wymaga miesięcy danych |
| LC-19 | Integracja z kalendarzem | WON'T (v2.0) | Uprawnienia za niewielki zysk w pierwszych wersjach |
| LC-20 | Raport tygodniowy | WON'T (v2.0) | Wymaga zadań cyklicznych, powiadomień i danych z trzech modułów |

### 7.3 Kontrakt AI

**Wejście do kontekstu planu dnia** (brak elementu jest jawnie sygnalizowany modelowi):
check-in dnia (nastrój, energia, jakość snu, godziny snu, notatka) · aktywne cele (maksymalnie pięć) · preferencje użytkownika · **wieczorna refleksja z dnia poprzedniego** · **odsetek ukończonych zadań z ostatnich trzech dni** · dane z innych modułów (poziom stresu, ostatni trening), gdy są dostępne.

Trzy ostatnie pozycje są nowe. Ich brak w poprzedniej wersji sprawiał, że plan nie miał czym różnić się od ogólnego.

**Reguły w kontekście** (przeniesione z poprzedniej wersji — najlepszy artefakt tamtego modułu):
6–8 zadań · proporcje kategorii 30% produktywność / 25% fitness / 20% dobrostan / 15% osobiste / 10% społeczne · przypisanie energii do pory dnia (wysoka 7:00–11:00, średnia 11:00–15:00, niska 18:00–21:00) · przerwa co 2–3 godziny · budżet 6–8 godzin zadań · zadania **konkretne** („30 minut jogi plus 10 minut rozciągania", nie „ćwiczenia") · przy niskiej energii łagodniejsze aktywności.

**Wyjście:** wymuszony format JSON. Struktura: lista zadań (identyfikator, tytuł, opis, kategoria, priorytet, szacowany czas, sugerowana godzina, poziom energii, **uzasadnienie**), motyw dnia, cytat motywacyjny.

**Zachowanie awaryjne — wymaganie produktowe, nie szczegół implementacyjny:**
osobne limity czasu na połączenie i na odpowiedź · maksymalnie dwie ponowne próby z narastającym opóźnieniem · **deterministyczny plan budowany lokalnie** z aktywnych celów i preferencji, gdy AI zawiedzie · użytkownik nigdy nie widzi pustego ekranu.

**Bezpieczeństwo — w każdym kontekście konwersacyjnym:** instrukcja zakazująca diagnozowania stanów zdrowia psychicznego i nakazująca kierowanie do specjalisty, oraz jawne określenie roli jako coacha, nie terapeuty. To jest kryterium akceptacji, nie szczegół redakcyjny.

---

## 8. MODUŁ: SETTINGS

W poprzedniej wersji moduł ustawień zawierał wyłącznie funkcje RODO. Konfiguracja użytkownika była rozproszona po trzech miejscach, a **wszystkie dwadzieścia kluczy ustawień istniało wyłącznie jako kolumny w bazie** — bez modelu, bez interfejsu, bez dostępu offline.

Ustawienia są **węzłem centralnym** używanym przez każdy moduł. Dlatego powstają jako wspólna infrastruktura **przed** modułami, które z nich korzystają.

| ID | Funkcja | Priorytet | Opis |
|---|---|---|---|
| SET-01 | Ekran ustawień | **MUST** v1.0 | Osobna trasa, wejście z nawigacji głównej. Wcześniej takiego ekranu nie było wcale |
| SET-02 | Jednostki | **MUST** v1.0 | Waga kg/lbs, wzrost cm/cale, dystans km/mile. Wspólny formater używany przez fitness i pomiary |
| SET-03 | Motyw | **MUST** v1.0 | Jasny, ciemny, systemowy. Wcześniej ciemny motyw istniał w kodzie, ale użytkownik nie mógł go wybrać |
| SET-04 | Język | **MUST** v1.0 | EN i PL, pełna warstwa tłumaczeń **od pierwszego commita** |
| SET-05 | Profil | **MUST** v1.0 | Imię, adres e-mail z ponowną weryfikacją, hasło, awatar, data urodzenia, płeć |
| SET-06 | Dane i prywatność | **MUST** v1.0 | Eksport danych, usunięcie konta, odnośniki do polityki prywatności i regulaminu |
| SET-07 | Disclaimer i zasoby kryzysowe | **MUST** v1.0 | Wymóg zgodności. Widoczne, nie ukryte w podmenu |
| SET-08 | O aplikacji | **MUST** v1.0 | Wersja, licencje otwartego oprogramowania, kontakt |
| SET-09 | Wylogowanie | **MUST** v1.0 | Wcześniej nie było takiego przycisku w żadnym ekranie ustawień |
| SET-10 | Zachęta do instalacji PWA | **MUST** v1.0 | Kontekstowa, po pierwszym zapisanym treningu — nie przy pierwszym wejściu |
| SET-11 | Przypomnienia | **MUST** v1.1 | Poranne i wieczorne, konfigurowalna godzina, godziny ciszy |
| SET-12 | Preferencje coachingowe | **MUST** v1.1 | Godziny pracy, pora treningu, typ dnia, obszary skupienia — realne, nie testowe |
| SET-13 | Przełączniki prywatności **z egzekwowaniem** | **MUST** v1.2 | Zgoda na współdzielenie danych między modułami musi być sprawdzana przed każdym zapisem metryk. **Nie wolno wystawiać przełącznika, który nic nie robi** |
| SET-14 | Ustawienia synchronizacji | SHOULD v1.1 | Stan synchronizacji, ręczne wymuszenie, informacja o niezsynchronizowanych danych |
| SET-15 | Zarządzanie subskrypcją | WON'T (v2.0) | Patrz §10 |

---

## 9. Zagadnienia przekrojowe

### 9.1 Skale ocen

`[Z-5]` **Wszystkie oceny subiektywne — nastrój, energia, jakość snu, stres — w skali 1–5 z emoji.**

W poprzedniej wersji współistniały cztery różne skale, a wszystkie miały się spotkać w jednej tabeli metryk, co czyniłoby korelacje bezwartościowymi. Wybór skali 1–5 zamiast 1–10: szybsze wprowadzenie (jeden rząd emoji zamiast suwaka), mniejsze obciążenie decyzyjne przy codziennym rytuale, standard w aplikacjach do śledzenia nastroju.

**RPE pozostaje w skali 1–10** — to ustandaryzowana skala treningowa i mieszanie jej z ocenami subiektywnymi byłoby błędem.

### 9.2 Serie (streaki)

`[Z-6]` **Seria rośnie za dowolną aktywność danego typu w danym dniu.** Trzy typy: trening, check-in, medytacja.

Rozstrzygnięcia sprzeczności z poprzedniej wersji:
- Wymaga **jednego** check-inu dziennie, nie obu. Niższy próg oznacza lepsze powroty i tak działał kod, choć dokumentacja twierdziła inaczej.
- Pominięcie jednego dnia **nie przerywa** serii; przerywają ją dwa dni z rzędu. To zastępuje całą mechanikę „zamrożenia raz w tygodniu" — prościej, wybaczająco, bez dodatkowego stanu do synchronizacji.
- Odznaki, konfetti i karty do udostępniania trafiają do **v2.0**. W v1.1 jest licznik dni i rekord osobisty.
- **Właścicielem serii treningowej jest moduł Fitness.** Wcześniej seria „wisiała" między trzema dokumentami i nie miała właściciela, przez co nie powstała.

### 9.3 Insighty cross-module

To jedyny realny wyróżnik produktu — reszta (logowanie treningów, biblioteka medytacji, śledzenie nastroju) jest standardem rynkowym. W poprzedniej wersji miał 5% realizacji, będąc jednocześnie zapisanym jako kryterium sukcesu MVP.

**Fundamentalne napięcie:** korelacje statystyczne wymagają około trzydziestu dni danych z co najmniej dwóch modułów. Czyli wartość wyróżnika pojawia się dokładnie wtedy, gdy większość użytkowników już odpadła.

`[Z-7]` **Rozwiązanie: dwie warstwy.**

**Warstwa regułowa (v1.2)** — cztery twarde reguły z progami liczbowymi, działające od **pierwszego dnia**:

| ID | Warunek | Komunikat |
|---|---|---|
| CMI-01 | Stres co najmniej 4/5 i zaplanowany trening | „Wysoki poziom stresu. Rozważ lżejszą sesję zamiast ciężkiego treningu." |
| CMI-02 | Jakość snu najwyżej 2/5 i poranny trening w planie | „Kiepski sen. Popołudniowy trening może być dziś skuteczniejszy." |
| CMI-03 | Objętość tygodniowa powyżej 120% średniej i podwyższony stres | Sugestia dnia regeneracyjnego |
| CMI-04 | Wykryty skok stresu | Sugestia ćwiczenia oddechowego |

**Warstwa statystyczna (v2.0)** — korelacje na trzydziestu dniach z filtrem istotności, trzy najsilniejsze przetwarzane przez model językowy na tekst i rekomendację, próg pewności przed powiadomieniem, przeliczanie **tygodniowe, nie dzienne** (świadoma optymalizacja kosztów, przeniesiona z poprzedniej wersji).

**Niezależnie od warstwy:** zapis metryk dziennych startuje w **v1.0** (fitness) i **v1.1** (life coach). Dane muszą naliczać się od pierwszego dnia, żeby warstwa statystyczna miała na czym pracować, gdy powstanie.

**Zasada przeciw przesytowi:** maksymalnie **jeden insight dziennie**. Użytkownik może odrzucić, zapisać lub zadziałać.

### 9.4 Moduł Mind — zakres skrócony

Pełna specyfikacja poprzedniej wersji miała trzydzieści wymagań przy realizacji około czterech. Zakres v1.2 jest dobrany według kryterium **kosztu treści**:

| ID | Funkcja | Priorytet | Uzasadnienie |
|---|---|---|---|
| MND-01 | Śledzenie nastroju i stresu | **MUST** v1.2 | **Zawsze darmowe, bez wyjątku.** Tanie, zasila insighty, jedyna funkcja Mind używana codziennie |
| MND-02 | Ćwiczenia oddechowe (5 technik) | **MUST** v1.2 | **Zerowy koszt treści** — kod, animacja i wibracja. Natychmiastowa wartość |
| MND-03 | Kwestionariusze GAD-7 i PHQ-9 | **MUST** v1.2 | Darmowe, tanie w implementacji, **wymóg bezpieczeństwa** |
| MND-04 | Wykres trendu nastroju | **MUST** v1.2 | Dowód wartości dla persony P3 |
| MND-05 | Biblioteka medytacji | WON'T (v2.0) | Najdroższy element produktu: dwadzieścia kilka nagrań razy dwa języki, budżet nigdy nieoszacowany |
| MND-06 | Prywatny dziennik z szyfrowaniem | WON'T (v2.0) | Wymaga rozstrzygnięcia odzyskiwania klucza — patrz `[Z-9]` |
| MND-07 | Rozmowa terapeutyczna z AI | WON'T (v2.0) | Największe ryzyko prawne; wymaga osobnego mechanizmu wykrywania treści kryzysowych |
| MND-08 | Historie na sen, dźwięki otoczenia | WON'T (v2.0) | Czysty koszt treści przy niskim wpływie na powroty |

**Progi kryzysowe (bezwzględne):** wynik GAD-7 powyżej 15 lub PHQ-9 powyżej 20 uruchamia automatyczne wyświetlenie zasobów kryzysowych (Wielka Brytania 116 123, Polska 116 123) oraz rekomendację kontaktu ze specjalistą. Stały disclaimer: *„LifeOS nie zastępuje profesjonalnej opieki zdrowia psychicznego."*

---

## 10. Monetyzacja

`[Z-8]` **Monetyzacja jest poza zakresem v1.0–v1.2. Model definiujemy teraz, wdrażamy w v2.0.**

Powód: w poprzedniej wersji istniały równocześnie trzy systemy płatności (kolumny Stripe w schemacie, dwie nieużywane biblioteki płatnicze, RevenueCat w dokumentacji) i trzy różne nazewnictwa poziomów. Utrzymywanie martwego schematu przez trzy wersje to gwarantowany dług.

**Decyzje już podjęte na moment wdrożenia:**
- **Płatności przez web (Stripe) w PWA, przez natywne zakupy w aplikacjach ze sklepów.** To istotna przewaga formy webowej: brak prowizji 30% dla użytkowników, którzy zapłacą w przeglądarce. W wersji ze sklepu obowiązują natywne zakupy — inaczej łamiemy regulaminy.
- **Jedno nazewnictwo poziomów:** `free` · `single_module` · `bundle` · `full`.
- **Zawsze darmowe, bez wyjątku:** Life Coach podstawowy (plan dnia, check-iny, do trzech celów), śledzenie nastroju i stresu, ćwiczenia oddechowe, kwestionariusze przesiewowe, **wykresy postępu fitness**.
- Poziom darmowy **nie wygasa** i **nie wymaga karty**. Ograniczenia są pokazywane jawnie, nie ukrywane.
- Po rezygnacji: **zero utraty danych**, treści powyżej limitu przechodzą w tryb tylko do odczytu.

---

## 11. Wymagania niefunkcjonalne

### 11.1 Wydajność

Metryki webowe zamiast czasu startu aplikacji natywnej.

| Metryka | Cel |
|---|---|
| Largest Contentful Paint | poniżej 2,0 s (4G, telefon średniej klasy) |
| Interaction to Next Paint | poniżej 200 ms |
| Cumulative Layout Shift | poniżej 0,1 |
| Lighthouse PWA | 100 |
| Lighthouse Performance | co najmniej 90 |
| Rozmiar pierwszego wczytania (JS) | poniżej 200 kB skompresowanego |
| Ponowne wejście (z service workera) | poniżej 1 s do interaktywności |
| **Pamięć wzorca (pre-fill)** | **poniżej 500 ms** — funkcja kluczowa, musi być natychmiastowa |
| Wyszukiwanie ćwiczeń | poniżej 200 ms |
| Zapis serii (odczucie użytkownika) | poniżej 100 ms — aktualizacja optymistyczna |
| Historia 90 dni | poniżej 1 s |
| Generowanie planu AI | poniżej 4 s, limit 10 s i przejście na plan awaryjny |

### 11.2 Dostępność offline — świadome ograniczenie v1.0

`[Z-1]` **W v1.0: odczyt działa offline, zapis wymaga połączenia. Zapis offline wchodzi w v1.1.**

| Funkcja | v1.0 | v1.1 |
|---|---|---|
| Katalog ćwiczeń: przeglądanie, wyszukiwanie, filtry | ✅ offline | ✅ |
| Historia treningów i wykresy (dane wcześniej pobrane) | ✅ offline | ✅ |
| Ustawienia | ✅ offline | ✅ |
| **Logowanie treningu** | ❌ **wymaga sieci** | ✅ offline z kolejką |
| Pomiary ciała, check-iny, nastrój | ❌ wymaga sieci | ✅ offline z kolejką |
| Generowanie planu AI | ❌ wymaga sieci | ❌ wymaga sieci |

**Ryzyko przyjęte świadomie.** Podstawowy scenariusz persony P1 to siłownia bez zasięgu. W v1.0 aplikacja tam nie zadziała przy zapisie. Wymagane działania łagodzące:

- Wyraźny, natychmiastowy komunikat o braku połączenia — nigdy cicha utrata wpisanych danych.
- **Zachowanie niezapisanego treningu w pamięci przeglądarki** i propozycja ponowienia po powrocie sieci. To nie jest pełna kolejka synchronizacji, tylko zabezpieczenie przed utratą pracy.
- Warstwa zapisu odizolowana architektonicznie tak, żeby dołożenie kolejki w v1.1 było **podmianą jednego modułu, nie przebudową** (szczegóły w dokumencie architektury).
- **Zapis offline jest zobowiązaniem v1.1, nie opcją.** Jeśli testy z użytkownikami pokażą, że brak zapisu offline blokuje główny scenariusz, priorytet rośnie do natychmiastowego.

**Ograniczenie platformowe do odnotowania:** Safari na iOS może usunąć dane lokalne po około siedmiu dniach nieużywania aplikacji, a trwałe przechowywanie jest przyznawane wybiórczo. Dotyczy to również v1.1. Łagodzenie: agresywna synchronizacja przy każdym powrocie online i widoczny wskaźnik niezsynchronizowanych danych. Problem znika po przejściu na Capacitora.

### 11.3 Bezpieczeństwo

- **Żaden klucz API nie może znaleźć się w kodzie klienta ani w danych aplikacji.** W poprzedniej wersji klucz z uprawnieniami administracyjnymi, omijający wszystkie reguły dostępu do danych, znajdował się w kodzie klienta i w historii repozytorium.
- **Wszystkie wywołania AI przez funkcję serwerową.** Bez tego nie da się egzekwować limitów, mierzyć kosztów ani chronić klucza. To warunek konieczny całej sekcji monetyzacji.
- Reguły dostępu na poziomie wierszy dla każdej tabeli użytkownika. Identyfikator użytkownika obowiązkowo na każdej tabeli.
- Hasło: minimum osiem znaków, wielka litera, cyfra, znak specjalny.
- Automatyczne skanowanie repozytorium w poszukiwaniu sekretów jako blokujący krok w procesie budowania.

`[Z-9]` **Szyfrowanie end-to-end odłożone do v2.0 wraz z dziennikiem.** Gdy wraca, w modelu z opakowaniem klucza: losowy klucz danych zaszyfrowany kluczem pochodzącym z hasła, plus **kod odzyskiwania** generowany przy zakładaniu konta. Wtedy zmiana hasła wymaga tylko ponownego opakowania klucza, nie ponownego szyfrowania wszystkich danych. W poprzedniej wersji klucz pochodził wprost z hasła, co oznaczało, że **reset hasła powodował trwałą utratę wszystkich wpisów** — czego dokumentacja nigdzie nie odnotowała.

### 11.4 Prywatność i RODO

- **Analityka włączana świadomie, domyślnie wyłączona.** W poprzedniej wersji domyślna wartość była przeciwna do zadeklarowanego wymogu zgody.
- Analiza treści prywatnych przez AI wyłącznie za jawną zgodą.
- Eksport wszystkich danych w formacie JSON i CSV, odnośnik ważny siedem dni, **limit częstotliwości egzekwowany po stronie serwera** (wcześniej był w stanie komponentu i resetował się po odświeżeniu strony).
- Usunięcie konta: **siedem dni na wycofanie decyzji, trzydzieści dni retencji kopii zapasowych.** Jedna definicja w całej dokumentacji — wcześniej były trzy sprzeczne.
- Nigdy nie sprzedajemy danych.

### 11.5 Dostępność

Pełna obsługa klawiatury · widoczny wskaźnik fokusu · etykiety dla czytników ekranu na wszystkich elementach interaktywnych · kontrast zgodny z WCAG AA · skalowanie tekstu do 200% bez utraty funkcjonalności · cele dotykowe minimum 44×44 px · komunikaty o zmianach stanu ogłaszane czytnikom ekranu.

### 11.6 Języki i przeglądarki

**Języki: EN i PL od v1.0.** Warstwa tłumaczeń od pierwszego commita — dołożenie jej do gotowej aplikacji z katalogiem dwustu ćwiczeń jest wielokrotnie droższe.

`[Z-10]` **Obsługiwane: dwie ostatnie wersje Chrome, Safari, Firefox i Edge, oraz Safari na iOS 16.4+.** Ta ostatnia granica wynika z obsługi powiadomień web push w PWA. Poniżej niej aplikacja działa, ale bez powiadomień.

### 11.7 Niezawodność

Wskaźnik błędów krytycznych poniżej 0,5% sesji · walidacja po stronie serwera dla wszystkich zapisów · kopie zapasowe dzienne z możliwością odtworzenia do siedmiu dni wstecz.

---

## 12. Przyjęte założenia

Każde zamyka pytanie, które w poprzednim podejściu pozostawało otwarte. Zmiana któregokolwiek jest tania **teraz**.

| ID | Założenie | Konsekwencja, jeśli błędne |
|---|---|---|
| **Z-1** | v1.0 offline tylko do odczytu; zapis offline w v1.1 | Jeśli testy pokażą, że blokuje główny scenariusz — priorytet rośnie natychmiast, koszt około dwóch tygodni |
| **Z-2** | Katalog 200–250 ćwiczeń, dane statyczne, EN i PL | Import z otwartej bazy skraca produkcję, ale wymaga weryfikacji licencji i tłumaczenia |
| **Z-3** | 1RM liczone wzorem Epleya | Zmiana wzoru unieważnia historyczne rekordy — decyzja musi zapaść przed pierwszym zapisem |
| **Z-4** | Jednostki przechowywane w SI, przeliczane przy wyświetlaniu | — |
| **Z-5** | Oceny subiektywne w skali 1–5, RPE 1–10 | Zmiana po starcie unieważnia dane historyczne i korelacje |
| **Z-6** | Seria: dowolna aktywność dziennie, przerywa się po dwóch dniach, bez mechaniki zamrożenia | — |
| **Z-7** | Insighty najpierw regułowe, statystyczne w v2.0 | — |
| **Z-8** | Monetyzacja poza v1.x; Stripe w web, natywne zakupy w sklepach | Jeśli przychód jest potrzebny w pół roku, płatności wchodzą do v1.2 |
| **Z-9** | Szyfrowanie end-to-end i dziennik do v2.0; model z opakowaniem klucza i kodem odzyskiwania | — |
| **Z-10** | PWA jako podstawa, Capacitor w v1.1; wsparcie iOS 16.4+ dla powiadomień | — |
| **Z-11** | AI wchodzi w v1.1, zawsze przez funkcję serwerową | Jeśli AI ma być w v1.0, warstwa pośrednicząca staje się zadaniem o najwyższym priorytecie |
| **Z-12** | Ścieżka powrotów: v1.0 co najmniej 5% w trzydziestym dniu, v1.2 co najmniej 8%, v2.0 co najmniej 10% | Poniżej 3% po v1.0 oznacza zmianę produktu, nie dokładanie funkcji |

---

## 13. Kryteria sukcesu

### 13.1 Definition of Done — dla każdego wymagania

Funkcja jest ukończona, gdy: jest **osiągalna z nawigacji** · działa na **realnych danych** (zero danych testowych w kodzie produkcyjnym) · zapis i odczyt są **symetryczne** (po odświeżeniu strony odczyt zwraca to, co zapisano) · jest pokryta testem · działa offline, jeśli tak deklaruje.

W poprzedniej wersji „ukończone" oznaczało istnienie pliku. To jedyna przyczyna raportowania 45–66% gotowości przy zerowej liczbie funkcji osiągalnych z interfejsu.

### 13.2 Kryteria wyjścia wersji

**v1.0:** trening zalogowany w poniżej 60 sekund od otwarcia aplikacji · widoczny po odświeżeniu z kompletem serii · wykresy na realnych danych użytkownika · katalog przeszukiwalny bez sieci · aplikacja instalowalna z Lighthouse PWA równym 100 · zielone CI · zero danych testowych w kodzie produkcyjnym.

**v1.1:** trening zalogowany bez zasięgu i zsynchronizowany po powrocie sieci · siedem dni z rzędu check-inów wykonalne bez błędu · plan generowany z realnego kontekstu · plan awaryjny działa przy odciętym API · żaden klucz API nie występuje w kodzie klienta · aplikacja przyjęta w obu sklepach.

**v1.2:** insight pojawia się po siedmiu dniach danych z dwóch modułów · progi kryzysowe przetestowane · przełącznik prywatności realnie blokuje zapis metryk.

### 13.3 Metryki produktowe

Metryka główna: **powroty w trzydziestym dniu**. Poprzednia wersja stawiała cel 10–12%, czyli trzykrotność średniej branżowej, przy zespole, który nie dowiózł ekranu głównego.

`[Z-12]` **Realistyczna ścieżka: v1.0 co najmniej 5% → v1.2 co najmniej 8% → v2.0 co najmniej 10%.** Poniżej 3% po v1.0 oznacza zmianę produktu, nie kolejne funkcje.

Pozostałe: **mediana czasu logowania treningu poniżej 60 sekund** (to metryka funkcji kluczowej i musi być mierzona od pierwszego dnia) · odsetek instalacji PWA wśród powracających użytkowników · wskaźnik błędów krytycznych poniżej 0,5%.

---

## 14. Co zostało świadomie wycięte

Pełna lista, żeby nie wróciło tylnymi drzwiami: onboarding z wyborem ścieżki · osobowości AI · odznaki, konfetti i karty do udostępniania · raporty tygodniowe · integracja z kalendarzem · biblioteka medytacji audio · historie na sen i dźwięki otoczenia · rozmowa terapeutyczna z AI · prywatny dziennik z szyfrowaniem · korelacje statystyczne · supersety i obwody · zdjęcia postępu · integracje zdrowotne · liczenie kalorii · monetyzacja · uwierzytelnianie dwuskładnikowe.

Każda z tych pozycji miała w poprzedniej wersji dokumentację, a część miała status „ukończone". Żadna nie działała.
