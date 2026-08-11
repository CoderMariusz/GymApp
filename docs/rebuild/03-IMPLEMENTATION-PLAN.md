# LifeOS — Plan implementacji (PWA)

**Wersja dokumentu:** 1.0
**Data:** 2026-08-11
**Status:** Draft do przeglądu
**Powiązane:** `01-PRD.md` (co budujemy) · `02-ARCHITECTURE.md` (jak jest zbudowane)

---

## 1. Zasada nadrzędna

**Etap M0 blokuje wszystko pozostałe.** Zanim powstanie druga funkcja, musi działać pełna ścieżka:

```
uruchomienie → logowanie → nawigacja → zapis treningu → odświeżenie strony
            → trening widoczny z kompletem serii → zielony proces budowania
```

Poprzednia wersja projektu zbudowała trzynaście decyzji architektonicznych, 206 dokumentów, 36 tabel i pipeline CI na 380 linii, po czym okazało się, że około dwustu z 217 plików jest nieosiągalnych z interfejsu. Kolejność „funkcje najpierw, integracja później" była głównym mechanizmem porażki. Ten plan ją odwraca.

---

## 2. Definition of Done

Obowiązuje dla **każdego** zadania w tym planie. Zadanie jest ukończone, gdy:

1. Funkcja jest **osiągalna z nawigacji** — istnieje trasa i jest z niej wejście.
2. Działa na **realnych danych** — zero danych testowych w kodzie produkcyjnym, weryfikowane automatycznie.
3. Zapis i odczyt są **symetryczne** — po odświeżeniu strony odczyt zwraca dokładnie to, co zapisano.
4. Jest **pokryta testem** na poziomie właściwym dla swojej warstwy.
5. **Działa offline**, jeśli tak deklaruje w PRD.
6. **Ma tłumaczenia** w obu językach.

W poprzedniej wersji „ukończone" oznaczało istnienie pliku. To jedyna przyczyna raportowania 45–66% gotowości przy zerowej liczbie funkcji osiągalnych z interfejsu.

---

## 3. Etapy

**Estymaty podane są w godzinach roboczych**, nie w tygodniach kalendarzowych. Powód: tryb pracy to około dwudziestu godzin tygodniowo (decyzja D-I), więc tydzień kalendarzowy to pół tygodnia pracy. Przeliczenie na kalendarz jest w §4.

Estymaty nie zawierają produkcji treści (biegnie równolegle, §5) ani bufora na nieprzewidziane.

---

### M0 — Walking skeleton · 60 h · BLOKUJE WSZYSTKO

**Cel:** działająca, wdrożona, instalowalna aplikacja z jedną prawdziwą funkcją.

| # | Zadanie |
|---|---|
| 0.1 | **Rotacja kluczy Supabase i OpenAI** przed czymkolwiek innym |
| 0.2 | Projekt Next.js, TypeScript w trybie ścisłym, tryb statycznego eksportu, Tailwind, shadcn/ui |
| 0.3 | ESLint z regułami granic modułów i zakazem danych testowych w kodzie produkcyjnym; Prettier; `gitleaks` |
| 0.4 | `next-intl` z EN i PL, przełącznik języka, jeden przetłumaczony ekran na dowód działania |
| 0.5 | Projekt Supabase, migracja początkowa z trzema tabelami, reguły dostępu, generowanie typów |
| 0.6 | Autoryzacja: e-mail z hasłem, Google, Apple; reset hasła; strażnik tras |
| 0.7 | **Powłoka aplikacji: nawigacja dolna z pięcioma zakładkami**, wszystkie osiągalne |
| 0.8 | Ustawienia: motyw i język, utrwalone po odświeżeniu |
| 0.9 | `lib/mutations/` — brama zapisu wg §5.2 dokumentu architektury, z identyfikatorami po stronie klienta |
| 0.10 | TanStack Query z zapisem cache do IndexedDB |
| 0.11 | Serwis roboczy, manifest, ikony, ekran startowy |
| 0.12 | Proces budowania: trzy zadania wg §11 architektury |
| 0.13 | Wdrożenie na produkcję pod `app.domena` |
| 0.14 | Jeden test end-to-end: logowanie → nawigacja → zapis → odświeżenie → odczyt |
| 0.15 | Sentry |

**Wyjście:** aplikacja pod publicznym adresem, instalowalna na telefonie, logowanie działa, zmiana motywu przeżywa odświeżenie, Lighthouse PWA równy 100, proces budowania zielony.

---

### M1 — Katalog ćwiczeń · 80 h

**Zależności:** M0. **Równolegle:** produkcja treści (patrz §5).

| # | Zadanie |
|---|---|
| 1.1 | Schemat `exercises` i `exercise_translations` z pełną taksonomią wg §5.2 PRD |
| 1.1a | **Skrypty importu katalogu** wg §6.4 architektury: pobranie źródła, wybór pozycji, mapowanie na taksonomię, scalenie z treścią ręczną, optymalizacja obrazów |
| 1.1b | Test walidacyjny katalogu: każda pozycja ma komplet pól wymaganych i tłumaczenie w obu językach — uruchamiany w procesie budowania |
| 1.2 | Dexie: przechowywanie katalogu z wersjonowaniem |
| 1.3 | Zasilanie katalogu z danych statycznych przy pierwszym uruchomieniu, z ekranem postępu |
| 1.4 | Aktualizacja przyrostowa z serwera, gdy dostępna nowsza wersja katalogu |
| 1.5 | Wyszukiwanie pełnotekstowe w Dexie, opóźnienie 150 ms, wyszukiwanie na aktywnym języku |
| 1.6 | Filtry: kategoria, sprzęt, typ, poziom — **wszystkie z interfejsem** |
| 1.7 | Lista z wirtualizacją (250 pozycji z ilustracjami) |
| 1.8 | Widok szczegółów: mięśnie, sprzęt, instrukcja, wskazówki, typowe błędy |
| 1.9 | Ulubione, z synchronizacją |
| 1.10 | Ćwiczenia własne: pełny cykl tworzenia, edycji i usuwania |
| 1.11 | Tryb wyboru ćwiczenia — ten sam komponent, inny tryb |
| 1.12 | Testy: wyszukiwanie, filtry, zasilanie katalogu, praca bez sieci |

**Wyjście:** katalog przeszukiwalny **z wyłączonym internetem**, wynik poniżej 200 ms, obsługa dwóch języków.

---

### M2 — Logowanie treningu · 120 h · SERCE PRODUKTU

**Zależności:** M1.

| # | Zadanie |
|---|---|
| 2.1 | Schemat: `workouts`, `workout_exercises`, `workout_sets`, `personal_records` |
| 2.2 | Stan aktywnego treningu w Zustand, utrwalany w `localStorage` przy każdej zmianie |
| 2.3 | Ekran treningu: dodawanie ćwiczeń z katalogu, kolejność, usuwanie |
| 2.4 | Wprowadzanie serii z polami zależnymi od `tracks` ćwiczenia |
| 2.5 | **Pamięć wzorca:** automatyczne wypełnienie z ostatniej sesji plus informacja „ostatnio: N dni temu". Cel poniżej 500 ms |
| 2.6 | Serie rozgrzewkowe, wykluczane z objętości i rekordów |
| 2.7 | Timer przerwy: automatyczny start, wartość z ćwiczenia, warianty, pominięcie, wibracja i dźwięk |
| 2.8 | Pomiar czasu sesji |
| 2.9 | **Wykrywanie rekordów** przy zapisie, wzorem Epleya |
| 2.10 | Zapis przez `lib/mutations/` z aktualizacją optymistyczną |
| 2.11 | **Obsługa braku sieci:** baner, zachowanie danych, propozycja ponowienia po powrocie |
| 2.12 | Ekran podsumowania z wyróżnionymi rekordami |
| 2.13 | Szybkie logowanie |
| 2.14 | Testy jednostkowe: 1RM, wykrywanie rekordów, pamięć wzorca, agregacja objętości — **100% pokrycia** |
| 2.15 | Test end-to-end: pełny trening od startu do podsumowania |
| 2.16 | Test end-to-end: zachowanie przy zerwanym połączeniu |

**Wyjście:** trening zalogowany w poniżej 60 sekund, po odświeżeniu widoczny **z kompletem serii**.

> W poprzedniej wersji serie zapisywano z pustym powiązaniem do treningu. Trening był formalnie zapisany, a jego zawartość nieodzyskiwalna. Punkt 2.16 istnieje po to, żeby to wykryć automatycznie, a nie po miesiącu.

---

### M3 — Historia i postęp · 80 h

**Zależności:** M2.

| # | Zadanie |
|---|---|
| 3.1 | Lista historii z podziałem na strony i filtrem po ćwiczeniu |
| 3.2 | Widok szczegółów treningu |
| 3.3 | Edycja i usuwanie miękkie |
| 3.4 | Wykres siły: szacowane 1RM w czasie, per ćwiczenie |
| 3.5 | Wykres objętości tygodniowej |
| 3.6 | Oś rekordów |
| 3.7 | Zakresy czasu: 30 dni, 90 dni, 6 miesięcy, rok, całość |
| 3.8 | Pomiary ciała: pełny formularz (dziesięć pól) |
| 3.9 | Wykresy trendów pomiarów |
| 3.10 | Przeliczanie jednostek wpięte we wszystkie miejsca wyświetlania |
| 3.11 | Eksport CSV |
| 3.12 | Testy: agregacje, zakresy czasu, przeliczanie jednostek |

**Wyjście:** wykresy na **realnych danych użytkownika**. Weryfikacja automatyczna: zero danych testowych w kodzie produkcyjnym.

---

### M4 — Domknięcie v1.0 · 80 h

**Zależności:** M3.

| # | Zadanie |
|---|---|
| 4.1 | Szablony: gotowe zestawy, tworzenie z zakończonego treningu, start treningu z szablonu |
| 4.2 | Pełny ekran ustawień wg §8 PRD |
| 4.3 | Profil: imię, e-mail z weryfikacją, hasło, awatar |
| 4.4 | Zgodność RODO: eksport danych, usunięcie konta z limitem po stronie serwera |
| 4.5 | Disclaimer i zasoby kryzysowe |
| 4.6 | Kontekstowa zachęta do instalacji PWA — po pierwszym zapisanym treningu |
| 4.7 | Przegląd dostępności: klawiatura, czytniki ekranu, kontrast, skalowanie do 200% |
| 4.8 | Optymalizacja wydajności do progów z §11.1 PRD |
| 4.9 | Uzupełnienie tłumaczeń, przegląd tekstów |
| 4.10 | Metryka: mediana czasu logowania treningu |
| 4.11 | Testy end-to-end dla wszystkich ścieżek krytycznych |
| 4.12 | Testy beta z użytkownikami |

**v1.0 = 420 h pracy** (z zapasem na integrację). Przy 20 h/tydzień: około 17 tygodni kalendarzowych — patrz §4.

---

### M5 — Zapis offline + Capacitor · 120 h · v1.1

**Zależności:** M4. **To jest spłata świadomie zaciągniętego długu z `[Z-1]`.**

| # | Zadanie |
|---|---|
| 5.1 | Schemat `sync_outbox`, `updated_at` po stronie serwera na wszystkich tabelach |
| 5.2 | **Podmiana `lib/mutations/`** na wersję z kolejką — reszta aplikacji bez zmian |
| 5.3 | Kolejka: priorytety, narastające opóźnienie, limit ponowień, stan „wymaga uwagi" |
| 5.4 | Rozstrzyganie konfliktów: wygrywa ostatni zapis po `updated_at` |
| 5.5 | Widoczny stan synchronizacji plus ręczne wymuszenie |
| 5.6 | Prośba o trwałe przechowywanie danych, obsługa odmowy |
| 5.7 | Testy: **jeden test integracyjny na każdą synchronizowaną tabelę** |
| 5.8 | Test end-to-end: pełny trening offline, potem synchronizacja |
| 5.9 | Capacitor: projekty iOS i Android, ikony, ekrany startowe, bezpieczne obszary |
| 5.10 | Powiadomienia lokalne przez Capacitor |
| 5.11 | Zgłoszenie do App Store i Google Play |

**Wyjście:** trening zalogowany bez zasięgu, zsynchronizowany po powrocie sieci; aplikacja przyjęta w obu sklepach.

---

### M6 — Life Coach · 160 h · v1.1

**Zależności:** M5.

| # | Zadanie |
|---|---|
| 6.1 | **Funkcja brzegowa `ai-orchestrator` — przed czymkolwiek innym w tym etapie** |
| 6.2 | Definicje kontekstu w bazie danych, wersjonowane |
| 6.3 | Schemat: `check_ins`, `goals`, `goal_progress`, `daily_plans`, `plan_tasks`, `streaks`, `user_daily_metrics` |
| 6.4 | Poranny check-in: nastrój, energia, jakość snu, godziny snu, notatka. Cel poniżej 60 s |
| 6.5 | Generowanie planu z pełnym kontekstem wg §7.3 PRD |
| 6.6 | **Deterministyczny plan awaryjny** budowany lokalnie |
| 6.7 | Widok planu, statusy zadań, ręczna edycja |
| 6.8 | Cele: pełny cykl edycji plus **interfejs wpisywania postępu** |
| 6.9 | Wieczorna refleksja z przeglądem realizacji planu |
| 6.10 | Preferencje coachingowe w bazie |
| 6.11 | Seria check-inów |
| 6.12 | Zapis metryk dziennych |
| 6.13 | Testy: przetwarzanie odpowiedzi modelu, plan awaryjny, obliczanie serii |
| 6.14 | **Weryfikacja: rozpakowanie paczki aplikacji i potwierdzenie braku kluczy API** |

**Wyjście:** pełna pętla działa siedem dni z rzędu; plan awaryjny działa przy odciętym API.

---

### M7 — Mind i insighty · 120 h · v1.2

**Zależności:** M6.

| # | Zadanie |
|---|---|
| 7.1 | Schemat: `mood_logs`, `breathing_sessions`, `mental_health_screenings`, `insights` |
| 7.2 | Śledzenie nastroju i stresu w skali 1–5 z emoji |
| 7.3 | Wykres trendu nastroju |
| 7.4 | Pięć technik oddechowych z animacją i wibracją |
| 7.5 | Kwestionariusze GAD-7 i PHQ-9 z punktacją |
| 7.6 | **Progi kryzysowe i zasoby pomocowe** |
| 7.7 | Cztery reguły cross-module wg §9.3 PRD |
| 7.8 | Karta insightu, maksymalnie jeden dziennie, z akcjami |
| 7.9 | **Przełącznik prywatności realnie blokujący zapis metryk** |
| 7.10 | Testy: punktacja kwestionariuszy, progi kryzysowe, reguły insightów |

**Wyjście:** insight pojawia się po siedmiu dniach danych z dwóch modułów.

---

## 4. Harmonogram

Przy tempie **20 godzin tygodniowo** (decyzja D-I).

| Wersja | Etapy | Nakład | Kalendarz nominalny | Realnie z asystentem AI |
|---|---|---|---|---|
| **v1.0** | M0–M4 | 420 h | 21 tyg. | **16–18 tyg.** (~4 miesiące) |
| **v1.1** | M5–M6 | 280 h | 14 tyg. | 11–12 tyg. |
| **v1.2** | M7 | 120 h | 6 tyg. | 5 tyg. |
| **Razem** | | 820 h | 41 tyg. | **32–35 tyg.** (~8 miesięcy) |

**Skąd kolumna „realnie".** Praca w parze z asystentem AI kompresuje zadania rutynowe — komponenty, formularze, testy jednostkowe, migracje, skrypty importu, tłumaczenia — o rząd 40–50%. Nie kompresuje natomiast decyzji projektowych, integracji, debugowania na realnych urządzeniach ani testów z użytkownikami. Ponieważ rutyna to około połowy nakładu, oszczędność na całości wynosi 15–25%. **To jest oszacowanie, nie obietnica** — pierwszy punkt kontrolny po M0 pokaże realny współczynnik i wtedy warto przeliczyć resztę.

Harmonogram nie zawiera produkcji treści (biegnie równolegle, §5), bufora na nieprzewidziane (zalecane 20%) ani procesu wydawniczego w sklepach (M5).

---

## 5. Ścieżka równoległa: produkcja treści

**Zaczyna się w M0, nie w M1.**

Decyzja D-E przesądziła źródło: import z `free-exercise-db` (domena publiczna, około ośmiuset pozycji ze zdjęciami), wzbogacony własnymi opisami i przetłumaczony na polski. To skraca ścieżkę treści z około sześciu tygodni pracy pełnoetatowej do **około 60–80 godzin**, ale nie eliminuje jej.

| Faza | Zakres | Nakład |
|---|---|---|
| F1 | Weryfikacja licencji **osobno dla danych i osobno dla obrazów** | 2 h |
| F2 | Wybór 200–250 pozycji z bazy źródłowej wg kryteriów pokrycia | 6 h |
| F3 | Reguły mapowania na taksonomię plus ręczne uzupełnienie `movement_pattern` i `tracks` (nie istnieją w źródle) | 16 h |
| F4 | Tłumaczenie maszynowe nazw i instrukcji plus **obowiązkowa korekta** przez osobę znającą terminologię treningową | 20 h |
| F5 | Wskazówki techniczne i typowe błędy, 3–5 pozycji każdego rodzaju na ćwiczenie | 24 h |
| F6 | Optymalizacja obrazów (skryptem) i kontrola jakości | 6 h |

**Kolejność wykonania ma znaczenie.** F1 do F3 muszą być gotowe **przed M1**, bo od nich zależy kształt schematu bazy. F4 do F6 mogą biec równolegle z M1 i M2.

**Zawór bezpieczeństwa:** jeśli treść nie będzie gotowa do końca M1, etap M2 rusza na **dwudziestu ćwiczeniach wzorcowych** przerobionych w całości. Struktura danych jest wtedy przetestowana end-to-end, a reszta katalogu dochodzi partiami. **Treść nie może blokować kodu.**

**Uwaga o właścicielu.** Przy pracy jednoosobowej „osobny właściciel treści" oznacza **osobny blok czasu**, a nie osobną osobę. Praktycznie: treść w innych sesjach niż kod, bo przełączanie kontekstu między pisaniem opisów ćwiczeń a debugowaniem jest kosztowne. W poprzedniej wersji projektu zadania contentowe wisiały trzy sprinty przy zerowym postępie właśnie dlatego, że nie miały wydzielonego czasu.

---

## 5a. Praca solo z asystentem AI

Decyzja D-H oznacza brak drugiej pary oczu przy decyzjach architektonicznych. To jest główne ryzyko tego trybu pracy i wymaga rekompensaty proceduralnej.

**Co delegować bez wahania:** komponenty interfejsu z gotowej specyfikacji · formularze i walidacja · testy jednostkowe czystej logiki · migracje bazy · skrypty importu i mapowania · tłumaczenia · konfiguracja narzędzi · uzupełnianie powtarzalnych wzorców.

**Czego nie delegować bez własnej weryfikacji:** kształt modelu danych · granice modułów · cokolwiek dotykającego bramy zapisu z §5.2 architektury · reguły dostępu do danych · obliczenia wpływające na dane użytkownika (1RM, wykrywanie rekordów, agregacja objętości) · obsługa błędów w ścieżkach zapisu.

Wzór jest prosty: **im trudniej cofnąć skutek, tym mniej delegować**. Błąd w komponencie widać od razu. Błąd w modelu danych albo w wykrywaniu rekordów ujawnia się po miesiącu, gdy dane są już zepsute.

**Rekompensata za brak recenzenta — reguły egzekwowane automatycznie zastępują przegląd kodu.** Lista z §4 dokumentu architektury (zero danych testowych w kodzie produkcyjnym, zero błędów typów, granice modułów, budżet rozmiaru paczki, skanowanie sekretów) nie jest formalnością — przy pracy solo to jedyna instancja, która powie „nie". Wyłączenie którejkolwiek reguły „na chwilę" jest dokładnie tym mechanizmem, który w poprzedniej wersji doprowadził do 728 błędów, których nikt nie zauważył.

**Zasada dodatkowa:** decyzja architektoniczna trafia do rejestru decyzji **zanim** powstanie kod, który ją realizuje. Zapisanie uzasadnienia na piśmie jest przy pracy solo namiastką rozmowy z drugim developerem i wyłapuje zaskakująco dużo.

---

## 6. Ryzyka i reakcje

| Ryzyko | Prawdopodobieństwo | Skutek | Reakcja |
|---|---|---|---|
| **Brak zapisu offline blokuje główny scenariusz w v1.0** | Wysokie | Wysoki | Zabezpieczenie z §5.3 architektury łagodzi najgorszy przypadek. Jeśli testy beta w M4 to potwierdzą — M5 przesuwa się przed M6 (już tak zaplanowane) |
| Produkcja treści staje się ścieżką krytyczną | **Niskie** po decyzji D-E | Wysoki | Import ze źródła skraca ścieżkę do 60–80 h. Fazy F1–F3 przed M1, reszta równolegle. Dwadzieścia ćwiczeń wzorcowych odblokowuje M2 |
| **Licencja obrazów w bazie źródłowej okazuje się inna niż licencja danych** | Średnie | Średni | Weryfikacja w fazie F1, przed jakąkolwiek pracą. Zapas: katalog bez zdjęć, z samymi diagramami grup mięśniowych |
| **Brak drugiej pary oczu przy decyzjach architektonicznych** (praca solo) | **Wysokie** | Wysoki | Reguły egzekwowane automatycznie zamiast przeglądu kodu (§5a). Rejestr decyzji wypełniany przed napisaniem kodu. Zewnętrzny przegląd dokumentów przed startem |
| **Utrata tempa przy pracy 20 h/tydzień** | Średnie | Średni | Zadania w planie są samodzielnie zamykalne. Punkty kontrolne z §8 wymuszają weryfikację co kilka tygodni, a nie dopiero na końcu |
| Safari na iOS usuwa dane lokalne | Średnie | Średni | Prośba o trwałe przechowywanie, agresywna synchronizacja, widoczny wskaźnik. Znika po Capacitorze |
| Odrzucenie w App Store jako „opakowana strona" | Niskie | Średni | Capacitor z realnie natywnymi funkcjami: powiadomienia, biometria, dane offline |
| Rozjazd między schematem bazy a typami | Niskie | Wysoki | Typy **generowane**, nie pisane. Weryfikacja w procesie budowania |
| Rozrost zakresu | **Wysokie** | Wysoki | Lista z §14 PRD jest zamknięta. Każde nowe wymaganie wchodzi przez zmianę PRD, nie przez rozmowę |

Ostatnie ryzyko jest w tym projekcie najpoważniejsze i ma historię: poprzednia wersja miała 123 wymagania funkcjonalne i 37 niefunkcjonalnych, opisując produkt trzykrotnie większy niż to, co dało się zbudować.

---

## 7. Dokumentacja projektu

Osiem plików zamiast dwustu sześciu.

```
README.md              ← uruchomienie, komendy, konfiguracja
docs/PRD.md            ← 01-PRD.md
docs/ARCHITECTURE.md   ← 02-ARCHITECTURE.md
docs/PLAN.md           ← ten dokument
docs/DECISIONS.md      ← rejestr decyzji: data, kontekst, decyzja, skutki, status
docs/SCHEMA.md         ← generowany z migracji, nie pisany ręcznie
docs/BACKLOG.md        ← jedna lista, jeden status na pozycję
docs/CONTENT.md        ← produkcja katalogu: standard, postęp, właściciel
```

**Zasady:**
- **Każda decyzja architektoniczna ma status:** proponowana, zaakceptowana, wdrożona, zastąpiona. W poprzedniej wersji trzynaście decyzji nie miało statusu, więc sześć z nich latami figurowało jako zatwierdzone, nie istniejąc w kodzie.
- **Status wywodzi się z kodu.** Pozycja w backlogu jest odhaczana przy scaleniu, nie przy planowaniu.
- **Zero plików dokumentacji w katalogu głównym** poza README.
- **Nie archiwizujemy — usuwamy.** System kontroli wersji pamięta. Poprzedni katalog archiwum miał 163 pliki bez żadnej wartości.
- **Nie piszemy dokumentu opisującego kod, którego nie ma.** W poprzedniej wersji dokument na 439 linii opisywał szczegółowo warstwę serwerową, która nigdy nie powstała — i przez rok wyglądała jak zrealizowana architektura.

---

## 8. Punkty kontrolne

| Po etapie | Pytanie | Reakcja przy odpowiedzi negatywnej |
|---|---|---|
| M2 | Czy logowanie treningu trwa poniżej 60 sekund na realnym telefonie w realnej siłowni? | Optymalizacja przed dalszymi funkcjami. To jest cały produkt |
| M4 | Czy testerzy beta wracają po tygodniu? | Zatrzymanie i rozmowy z użytkownikami przed budowaniem Life Coacha |
| v1.0 | Czy powroty w trzydziestym dniu przekraczają 3%? | **Poniżej 3% oznacza zmianę produktu, nie dokładanie funkcji** |
| M5 | Czy zapis offline działa w realnych warunkach, nie tylko w teście? | Zatrzymanie przed M6 |

---

## 9. Pierwsze trzy tygodnie — konkretnie

Etap M0 to 60 godzin, czyli przy 20 h tygodniowo **trzy tygodnie kalendarzowe**. Bloki są tak dobrane, żeby każdy dało się domknąć w jednej sesji i żeby po każdym repozytorium było w stanie działającym.

**Tydzień 1 — fundament (20 h)**

| Blok | Działanie |
|---|---|
| A (4 h) | **Założenie nowego projektu Supabase** (D-14), rotacja klucza OpenAI, usunięcie starego projektu po zabraniu reguł dostępu i funkcji RODO jako wzorców |
| B (6 h) | Projekt Next.js: TypeScript w trybie ścisłym, statyczny eksport, Tailwind, shadcn/ui. Repozytorium, lint z regułami granic, formatowanie, `gitleaks` |
| C (6 h) | Migracja początkowa, reguły dostępu, generowanie typów ze schematu |
| D (4 h) | Autoryzacja e-mailem, strażnik tras |

**Tydzień 2 — powłoka (20 h)**

| Blok | Działanie |
|---|---|
| E (5 h) | Logowanie przez Google i Apple, reset hasła |
| F (5 h) | Powłoka aplikacji: nawigacja dolna z pięcioma zakładkami, wszystkie osiągalne |
| G (5 h) | `next-intl` z EN i PL, przełącznik języka |
| H (5 h) | Ustawienia: motyw i język, utrwalone po odświeżeniu |

**Tydzień 3 — dane i wdrożenie (20 h)**

| Blok | Działanie |
|---|---|
| I (6 h) | `lib/mutations/` — brama zapisu z identyfikatorami po stronie klienta. **Nie skracać tego bloku** — od niego zależy, czy offline w v1.1 będzie podmianą modułu, czy przebudową |
| J (4 h) | TanStack Query z zapisem cache do IndexedDB |
| K (4 h) | Serwis roboczy, manifest, ikony, ekran startowy |
| L (4 h) | Proces budowania (trzy zadania), wdrożenie, Sentry |
| M (2 h) | Test end-to-end i **instalacja aplikacji na własnym telefonie z realnym sprawdzeniem, że działa** |

**Równolegle, poza tymi godzinami:** faza F1 ścieżki treści — weryfikacja licencji `free-exercise-db` osobno dla danych i osobno dla obrazów. To dwie godziny, ale warunkuje całą resztę katalogu.

---

## 10. Dla recenzenta — co zakwestionować w tym planie

Dokument trafia do niezależnego przeglądu. Miejsca o największej wartości dla recenzji:

| # | Zagadnienie | Pytanie |
|---|---|---|
| P-1 | **Kolejność M5 przed M6** — zapis offline i Capacitor przed Life Coachem | Czy spłata długu offline powinna wyprzedzić funkcję, która buduje codzienne powroty? Argument przeciwny: Life Coach jest tym, co sprowadza użytkownika codziennie, a offline dotyczy trzech sesji w tygodniu |
| P-2 | **420 h na v1.0** | Czy rozkład nakładu między etapami jest wiarygodny? Podejrzane w szczególności: 60 h na M0 (dużo konfiguracji naraz) i 80 h na M4 (zawiera szablony, RODO, dostępność i wydajność) |
| P-3 | **Kompresja 15–25% dzięki asystentowi AI** | Czy to oszacowanie jest realistyczne, czy optymistyczne? Jeśli optymistyczne, kalendarz v1.0 wraca do 21 tygodni |
| P-4 | **Brak bufora w harmonogramie** | Zalecane 20% nie jest wliczone w tabelę. Czy powinno być, skoro to plan jednoosobowy bez zastępowalności? |
| P-5 | **Punkt kontrolny „poniżej 3% powrotów oznacza zmianę produktu"** | Czy po ośmiu miesiącach pracy taka decyzja jest realistyczna psychologicznie? Czy nie potrzeba wcześniejszego, tańszego testu tezy produktowej? |
| P-6 | **Reguły automatyczne zamiast przeglądu kodu** (§5a) | Czy zestaw z §4 architektury faktycznie wyłapuje klasy błędów, które w poprzedniej wersji przeszły niezauważone? Czego w nim brakuje? |

**Czego nie podważać:** decyzji z §0.1 PRD (należą do właściciela produktu) oraz Definition of Done z §2 (to bezpośredni wniosek z analizy poprzedniej wersji, gdzie „ukończone" oznaczało istnienie pliku).
