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

Estymaty w tygodniach pracy jednej osoby na pełen etat. Nie zawierają produkcji treści (biegnie równolegle) ani bufora.

---

### M0 — Walking skeleton · 1,5 tyg. · BLOKUJE WSZYSTKO

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

### M1 — Katalog ćwiczeń · 2 tyg.

**Zależności:** M0. **Równolegle:** produkcja treści (patrz §5).

| # | Zadanie |
|---|---|
| 1.1 | Schemat `exercises` i `exercise_translations` z pełną taksonomią wg §5.2 PRD |
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

### M2 — Logowanie treningu · 3 tyg. · SERCE PRODUKTU

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

### M3 — Historia i postęp · 2 tyg.

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

### M4 — Domknięcie v1.0 · 2 tyg.

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

**v1.0 = 8,5 tygodnia.**

---

### M5 — Zapis offline + Capacitor · 3 tyg. · v1.1

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

### M6 — Life Coach · 4 tyg. · v1.1

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

### M7 — Mind i insighty · 3 tyg. · v1.2

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

| Wersja | Etapy | Czas | Skumulowany |
|---|---|---|---|
| **v1.0** | M0–M4 | 8,5 tyg. | 8,5 tyg. |
| **v1.1** | M5–M6 | 7 tyg. | 15,5 tyg. |
| **v1.2** | M7 | 3 tyg. | 18,5 tyg. |

Nie zawiera produkcji treści (równolegle), bufora na nieprzewidziane (zalecane 20%) ani procesu wydawniczego w sklepach.

---

## 5. Ścieżka równoległa: produkcja treści

**Zaczyna się w M0, nie w M1.** Produkcja 200–250 ćwiczeń w dwóch językach to zadanie contentowe, nie programistyczne, i musi mieć **osobnego właściciela**. W poprzedniej wersji „20+ szablonów" figurowało jako „w trakcie" przez trzy sprinty przy zerowym postępie, właśnie dlatego, że nikt nie był za to odpowiedzialny.

| Etap | Rezultat |
|---|---|
| Tydzień 1 | Decyzja: import z otwartej bazy czy produkcja własna. Weryfikacja licencji |
| Tydzień 2 | Struktura danych uzgodniona z zespołem, 20 ćwiczeń wzorcowych w obu językach |
| Tygodnie 3–5 | Pozostałe ćwiczenia partiami po 50 |
| Tygodnie 4–6 | Ilustracje lub diagramy mięśni |
| Tydzień 6 | Korekta językowa obu wersji |

**Ryzyko:** jeśli treść nie będzie gotowa do końca M1, etap M2 może ruszyć na dwudziestu ćwiczeniach wzorcowych — struktura danych jest wtedy przetestowana, a reszta dochodzi później. **Treść nie może blokować kodu.**

---

## 6. Ryzyka i reakcje

| Ryzyko | Prawdopodobieństwo | Skutek | Reakcja |
|---|---|---|---|
| **Brak zapisu offline blokuje główny scenariusz w v1.0** | Wysokie | Wysoki | Zabezpieczenie z §5.3 architektury łagodzi najgorszy przypadek. Jeśli testy beta w M4 to potwierdzą — M5 przesuwa się przed M6 (już tak zaplanowane) |
| Produkcja treści staje się ścieżką krytyczną | Średnie | Wysoki | Osobny właściciel od M0, dwadzieścia ćwiczeń wzorcowych odblokowuje M2 |
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

## 9. Pierwszy tydzień — konkretnie

| Dzień | Działanie |
|---|---|
| 1 | Rotacja kluczy. Projekt Next.js z TypeScriptem, Tailwindem i statycznym eksportem. Repozytorium, lint, formatowanie, `gitleaks` |
| 2 | Projekt Supabase, migracja początkowa, reguły dostępu, generowanie typów. Autoryzacja e-mailem |
| 3 | Logowanie społecznościowe, reset hasła, strażnik tras. Powłoka aplikacji z nawigacją dolną |
| 4 | `next-intl` z EN i PL. Ustawienia: motyw i język, utrwalone |
| 5 | `lib/mutations/`, TanStack Query z zapisem do IndexedDB. Serwis roboczy, manifest, ikony |
| 6 | Proces budowania, wdrożenie, Sentry, test end-to-end. **Instalacja aplikacji na telefonie i sprawdzenie, że działa** |

Równolegle od pierwszego dnia: decyzja o źródle katalogu ćwiczeń i wyznaczenie właściciela treści.
