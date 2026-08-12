<!-- AI-INDEX: weryfikacja recenzji, research, sprzeczności, otwarte decyzje, runda 2 -->

# Weryfikacja recenzji v1.1 — przed drugą rundą

**Data:** 2026-08-12
**Przedmiot:** `01PRD_REVIEWED.md`, `02ARCHITECTURE_REVIEWED.md`, `03IMPLEMENTATIONPLAN_REVIEWED.md`
**Cel:** sprawdzić twierdzenia recenzji u źródeł, wskazać to, czego recenzja nie zauważyła, i wypunktować decyzje blokujące

> Recenzja jest w większości dobra i wyłapała rzeczy, które przeoczyłem — w szczególności atomowy zapis treningu, zakaz LWW po `updated_at` i zablokowanie zdjęć do czasu potwierdzenia praw. Ten dokument nie jest jej podważeniem w całości. Sprawdza konkretne twierdzenia i wskazuje, gdzie recenzja poprawiła jedną rzecz, psując inną.

---

## 1. Werdykt

Dokumenty **nie są gotowe do implementacji**, ale nie z powodów wymienionych w ich własnym werdykcie. Trzy powody, w kolejności wagi:

1. **Teza produktowa v1.0 opiera się na niesprawdzonym założeniu o konkurencji.** Recenzja przepisała wyróżnik na „minimalne tarcie + wiarygodny zapis offline" i nie sprawdziła, czy lider rynku już tego nie ma. Materiały wtórne twierdzą, że ma. To jest do sprawdzenia w trzydzieści minut i blokuje sens całej wersji 1.0.
2. **Cały plan został przebudowany wokół „Agent OS", który nie pochodzi od właściciela produktu.** Około jednej trzeciej objętości planu implementacji to infrastruktura pomiarowa dla systemu, o którym w decyzjach właściciela nie ma ani słowa.
3. **G-DESIGN blokuje całą implementację i nie ma właściciela, budżetu ani estymaty.** To największa nieoszacowana zależność w planie.

Reszta dokumentów jest bliska stanu wykonawczego.

---

## 2. Twierdzenia sprawdzone u źródeł

| # | Twierdzenie recenzji | Wynik | Konsekwencja |
|---|---|---|---|
| 1 | Lighthouse usunął kategorię PWA (R-02) | **Potwierdzone** | Usunięcie „Lighthouse PWA = 100" było słuszne. Kategoria zniknęła w Lighthouse 12; service worker przestał być warunkiem instalowalności już w 11. Lista weryfikacyjna z §13.3 PRD zostaje |
| 2 | `free-exercise-db` ma licencję Unlicense na dane | **Potwierdzone** | Dane i instrukcje są w domenie publicznej, użycie komercyjne bez atrybucji dozwolone |
| 3 | Pochodzenie zdjęć w tym repozytorium jest niejasne (G-LIC) | **Potwierdzone i gorsze niż opisano** | Pytania o licencję zdjęć zadano w co najmniej trzech osobnych zgłoszeniach, najstarsze z marca 2024. **Żadne nie doczekało się odpowiedzi opiekuna repozytorium.** To nie jest „do weryfikacji" — to jest cisza trwająca ponad dwa lata. Planuj od razu własne diagramy; nie rezerwuj czasu na czekanie na odpowiedź |
| 4 | Zainstalowana aplikacja na ekranie startowym iOS nie podlega siedmiodniowemu czyszczeniu danych | **Potwierdzone z zastrzeżeniem** | Aplikacje z ekranu startowego mają własny licznik dni użycia, niezależny od Safari, a inżynier WebKit stwierdził, że nie oczekuje usuwania danych first-party w takich aplikacjach. Zastrzeżenie: licznik dotyczy **używania samej aplikacji**. Użytkownik, który nie otworzy jej przez tydzień, wciąż jest scenariuszem do przetestowania. SPIKE-05 zostaje |
| 5 | `next-intl` działa ze statycznym eksportem | **Potwierdzone, z twardymi ograniczeniami** | Wymagane: prefiks lokalizacji w ścieżce, brak negocjacji języka po stronie serwera, brak tłumaczonych ścieżek (`pathnames`), wymuszony static rendering. Middleware nie działa. To dokładnie to, co opisuje §3.1 architektury |
| 6 | Nazwa „LifeOS" ma kolizje | **Potwierdzone i znacznie gorsze niż opisano** | Patrz §3 |

---

## 3. Nazwa — decyzja D-J jest nie do utrzymania

Zapisałem wcześniej Twoją decyzję „LifeOS zostaje na stałe" z adnotacją, że nazwa jest rozpowszechniona. To było zbyt łagodne sformułowanie. W sklepach są obecnie co najmniej:

- **LifeOS: Focus and Habit Tracker** (Google Play) — produktywność, nawyki, aktualizowany w kwietniu 2026
- **LifeOS: Daily Habits & Focus** (App Store) — dziesięć nawyków dziennych, ciało i umysł, integracja z Apple Watch
- **MyLifeOS** (App Store) — **jawnie obejmuje trening siłowy, wytrzymałość i logowanie posiłków**
- **LifeOS** — aplikacja macOS: finanse, cele, nawyki i fitness, offline-first, bez subskrypcji
- **LifeOS** — kurs/marka szkoleniowa oraz szablon Notion „Life OS 2026"

MyLifeOS to nazwa różniąca się jednym przedrostkiem, w tej samej kategorii, z tym samym zakresem funkcji. Aplikacja macOS opisuje się dokładnie tak, jak Ty opisujesz swoją: nawyki, cele i fitness w jednym, offline-first.

To nie jest ryzyko marketingowe do rozpatrzenia przed logotypem. To jest problem z odnalezieniem produktu w sklepie i realne ryzyko odrzucenia zgłoszenia. Bramka BRAND-01 z recenzji jest słuszna, ale jej priorytet jest zaniżony — **nazwa powinna zmienić się teraz, kiedy kosztuje to jedną zmianę w plikach konfiguracyjnych**, a nie po zbudowaniu identyfikacji wizualnej.

Rekomendacja: zostaw `lifeos` jako wewnętrzną nazwę repozytorium i pakietu, ale nie buduj wokół niej niczego widocznego dla użytkownika.

---

## 4. Wyróżnik v1.0 — niesprawdzone założenie

Recenzja zmieniła wyróżnik (R-05) na:

> *the lowest-friction, trustworthy strength log that keeps working when the gym has no signal*

i uczyniła zapis offline wymaganiem MUST v1.0 (R-01, FIT-23). To zwiększyło nakład — Dexie, outbox, atomowy RPC, idempotencja, wstrzykiwanie awarii — i jest jednym z głównych powodów, dla których estymata wzrosła z 420 h do 395–600 h.

**Czego recenzja nie sprawdziła:** czy Hevy już tego nie robi.

Moje ustalenia są **sprzeczne i nierozstrzygające**:

| Źródło | Twierdzenie |
|---|---|
| Serwisy porównawcze (2026) | Hevy loguje treningi lokalnie i synchronizuje po odzyskaniu połączenia; wskazywane jako przydatne przy słabym zasięgu na siłowni |
| Komentarz użytkownika znaleziony w wynikach | „aplikacja wymaga połączenia z internetem do logowania treningów; czemu po prostu nie zapisywać ich offline?" |
| Źródła oficjalne Hevy | **Niedostępne** — `hevyapp.com`, centrum pomocy i Google Play są zablokowane przez proxy sieciowe tego środowiska |

Nie potwierdzam ani nie obalam. Ale **cała wersja 1.0 stoi na tym jednym fakcie** i jest on sprawdzalny przez Ciebie w pół godziny:

> Zainstaluj Hevy. Załóż konto przy włączonej sieci. Włącz tryb samolotowy. Zaloguj pełny trening: sześć ćwiczeń, kilkanaście serii. Zamknij aplikację całkowicie. Otwórz ponownie, wciąż offline — czy trening tam jest? Włącz sieć — czy się zsynchronizował? Czy powstał jeden trening, czy dwa?

Wynik decyduje o kształcie v1.0:

- **Jeśli Hevy robi to bez zarzutu** — wyróżnik v1.0 nie istnieje, a offline jest kosztem wejścia, nie przewagą. Trzeba wtedy albo przenieść element cross-module do v1.0, albo uczciwie nazwać v1.0 fundamentem i przestać mierzyć go powrotami użytkowników.
- **Jeśli Hevy zawodzi** — masz udokumentowany, konkretny wyróżnik i całą maszynerię z recenzji uzasadnioną.

**Warte odnotowania niezależnie od wyniku:** darmowy plan Hevy jest szczodry — nielimitowane logowanie, ponad tysiąc ćwiczeń, cztery rutyny, siedem własnych ćwiczeń, timer przerw, rekordy, funkcje społecznościowe. Ograniczenia to trzy miesiące historii wykresów i reklamy. Strong daje trzy własne rutyny. Hevy ma też polskie centrum pomocy, więc rynek polskojęzyczny nie jest niszą wolną od konkurencji.

Twierdzenie z PRD §1.1, że „darmowe wykresy" nie są wyróżnikiem, jest zatem trafne. Ale to oznacza, że po odjęciu wykresów i offline **v1.0 nie ma nic, czego lider rynku nie daje za darmo.**

---

## 5. Agent OS — warstwa, która nie pochodzi od właściciela

Recenzja wprowadziła do wszystkich trzech dokumentów rozbudowaną warstwę:

- PRD §4 „AgentOS Evaluation Profile", §14.3 osobne metryki
- Architektura ADR-22, §12.4, §20 „AgentOS implementation contract", reguły monotoniczności, klasyfikacja wyników
- Plan: całe §5 (LIFE-T01…T08 jako „feature battery"), §6 „Benchmark execution rules", §14 polityka WIP, odwołania do `plan-testow-v2.md`, „Poligon-A", „B6"

W Twoich decyzjach (D-A…D-L) nie ma ani słowa o systemie agentowym, benchmarku ani planie testów. D-H mówi tylko o „jednej osobie pracującej w parze z asystentem AI".

Możliwości są dwie i mają przeciwne konsekwencje:

**Jeśli Agent OS to Twój realny, osobny projekt** — warstwa jest uzasadniona, ale dokumenty są splecione w sposób, który szkodzi obu celom. Cele są w konflikcie: benchmark potrzebuje **zamrożonych specyfikacji i porównywalności**, produkt potrzebuje **szybkiej nauki i zmiany kierunku**. Kolejność zadań `T01 → T02 → T03 → T04` jest tego objawem — ustawienia przed sercem produktu mają sens jako rozgrzewka benchmarku i nie mają sensu jako kolejność redukcji ryzyka produktowego. Rekomendacja: rozdzielić na dokumenty produktowe i osobną specyfikację benchmarku, która się do nich odwołuje.

**Jeśli to konstrukcja recenzenta** — do usunięcia w całości. Około jednej trzeciej planu implementacji, plus rozdziały w dwóch pozostałych dokumentach. Bez tego harmonogram chudnie znacząco, bo znika `TASK_SPEC`, zamrażanie klatek wizualnych, `base_sha` per zadanie, klasyfikacja `infra_fail`/`task_fail` i cała dyscyplina porównywalności.

Nie zgaduję, która wersja jest prawdziwa. To pierwsze pytanie w §8.

---

## 6. Co recenzja poprawiła — i co przy tym zepsuła

### Poprawiła słusznie

| Zmiana | Ocena |
|---|---|
| Atomowy `CommitWorkout` zamiast zapisu wiersz po wierszu | **Najlepsza zmiana w całej recenzji.** Czyni niemożliwą klasę awarii, która zabiła poprzednią wersję: trening istnieje, serie osierocone |
| Dexie zamiast `localStorage` dla aktywnego treningu | Słuszne. `localStorage` jest synchroniczny, mały i podatny na czyszczenie |
| Zakaz LWW po `updated_at` w synchronizacji v1.1 | Słuszne i nieoczywiste. Argument o edycji sprzed doby docierającej dziś jest poprawny |
| `navigator.onLine` jako wskazówka, nie źródło prawdy | Słuszne |
| Rozbicie licencji danych i mediów na osobne bramki | Słuszne — i jak pokazuje §2, potrzebne bardziej, niż recenzja sądziła |
| Usunięcie `Lighthouse PWA = 100` | Słuszne, potwierdzone |
| `form_tips`/`common_mistakes` tylko dla pięćdziesięciu kluczowych ćwiczeń (R-07) | Słuszne. Moja estymata 24 h na 200–250 ćwiczeń była nierealna, co recenzja trafnie wypunktowała |
| Redefinicja „<60 s" jako aktywnego czasu interakcji (R-08) | Słuszne. Poprzednia metryka była niemierzalna |
| Wymagania `CORE-*` (R-06) | Trafne wyłapanie luki — deklarowałem przestrzeń nazw, której nie użyłem |

### Zepsuła lub przeoczyła

| # | Problem | Waga |
|---|---|---|
| 6.1 | **Jurysdykcja przyjęta bez podstaw.** Dokumenty mówią o MHRA, UK GDPR i „UK/EU name clearance". Piszesz po polsku i nie deklarowałeś, gdzie mieszkasz. Jeśli w Polsce, właściwe są RODO, unijne MDR i wytyczne MDCG, a organem jest URPL, nie MHRA. Cała sekcja compliance i bramka G-MH są napisane pod niewłaściwy kraj | Wysoka |
| 6.2 | **Język dokumentów.** Poprzednia wersja była po polsku. Obecna to mieszanka: polskie nagłówki, angielskie tabele, zdania typu „RLS ze starego projektu może być referencją". Dokument, który ma być czytany i przez Ciebie, i przez modele budujące kod, powinien być w jednym języku | Średnia |
| 6.3 | **Google i Apple OAuth jako MUST v1.0** (CORE-02). W v1.0 nie ma obecności w sklepach. Logowanie przez Apple wymaga płatnego konta dewelopera, a plan sam klasyfikuje udostępnianie providerów jako bramkę ludzką poza zakresem zadań. Dla bety z dziesięcioma osobami wystarczy e-mail z hasłem. To jest realny nakład i zewnętrzna zależność wycięte jedną decyzją | Średnia |
| 6.4 | **Macierz przeglądarek** (§13.4 PRD): dwie ostatnie wersje Chrome, Safari, Firefox i Edge. Dla jednej osoby pracującej dwadzieścia godzin tygodniowo to nierealny zakres testów. Firefox na Androidzie ma inne zachowanie instalacji PWA niż Chrome | Średnia |
| 6.5 | **G-UXR wymaga pięciu do ośmiu wywiadów z użytkownikami, G3 wymaga dziesięciu testerów P1.** Nigdzie nie ma pytania, czy masz do nich dostęp. Jeśli nie masz, cały kręgosłup walidacyjny jest teoretyczny, a bramki G2 i G3 nigdy nie zostaną przejęte | Wysoka |
| 6.6 | **Harmonogram urósł, ale poza inżynierią wciąż nic nie jest policzone.** 474–720 h z buforem to 24–36 tygodni przy dwudziestu godzinach. Do tego dochodzą: pakiet projektowy (bez estymaty), treść 60–100 h, wywiady, przeglądy prawne, czekanie na providerów. Realnie do bety z dziesięcioma użytkownikami mija **rok lub więcej**. Recenzja uczciwie mówi „nie obiecujemy czterech miesięcy", ale nigdzie nie sumuje tego, co obiecuje | Wysoka |
| 6.7 | **G-DESIGN nie ma właściciela.** Wymaga referencji 390×844 i 1440, tokenów, wszystkich przepływów, obu motywów, przebiegu na długich polskich napisach, stanów offline/queued/sync-failed, adnotacji dostępności i **niezmiennych, hashowalnych plików referencyjnych** — a plan mówi tylko „designer otrzymuje". Nie ma osoby, budżetu ani czasu. To jest twarda blokada całej implementacji postawiona na nieistniejącym zasobie | Wysoka |
| 6.8 | **`O-04` (pomiary ciała v1.0 czy v1.0.1) pozostaje otwarte, a blokuje LIFE-T06.** Podobnie `O-03` (dokładny podzbiór katalogu) blokuje LIFE-T02. Otwarte decyzje z terminem „przed zadaniem X" nie mają dat ani właściciela innego niż „product owner", czyli Ty | Niska |
| 6.9 | **Metryka „D30 ≥5%" pozostaje w PRD** (§14.1) obok uczciwego zastrzeżenia z G4, że nie da się jej ocenić na dziesięciu osobach. Dwa miejsca dokumentu mówią różne rzeczy o tej samej liczbie | Niska |

---

## 7. Czego brakuje w obu wersjach — mojej i recenzenckiej

1. **Koszty pieniężne.** Żaden dokument nie zawiera budżetu. Do policzenia: domena, Supabase powyżej darmowego progu, konto dewelopera Apple (jeśli Capacitor), konto Google Play, Sentry, ewentualny designer, API modelu językowego w v1.1. Projekt bez monetyzacji przez dwanaście miesięcy to dwanaście miesięcy samych kosztów.
2. **Co się dzieje po v1.0, jeśli bramka G3 nie przechodzi.** Plan mówi „product review before v1.1", co nie jest decyzją, tylko jej odroczeniem. Warto zapisać z góry, jaki wynik oznacza zmianę kierunku, a jaki zamknięcie projektu — decyzja podjęta teraz jest tańsza niż podjęta po ośmiu miesiącach pracy.
3. **Kopie zapasowe i odtwarzanie po awarii.** Nie ma nic o kopiach bazy, odtwarzaniu do punktu w czasie ani o tym, co się stanie, gdy migracja zepsuje dane produkcyjne. Przy jednoosobowym zespole bez recenzenta to realne ryzyko.
4. **Dostępność testerów.** Patrz 6.5.

---

## 8. Pytania blokujące drugą rundę

Odpowiedzi na te cztery zmieniają treść dokumentów na tyle, że pisanie ich wcześniej byłoby zgadywaniem.

| # | Pytanie | Dlaczego blokuje |
|---|---|---|
| **1** | **Czym jest Agent OS?** Twoim osobnym projektem, dla którego LifeOS jest benchmarkiem? Narzędziem, którym budujesz produkt? Czy konstrukcją recenzenta? | Decyduje o losie około jednej trzeciej planu implementacji i rozdziałów w dwóch pozostałych dokumentach |
| **2** | **Czy Hevy działa offline?** Test opisany w §4, trzydzieści minut Twojego czasu | Decyduje, czy v1.0 ma wyróżnik, czy jest fundamentem pod v1.1. Zmienia zakres, metryki sukcesu i bramki G2/G3 |
| **3** | **Kto robi projekt graficzny?** Ty na komponentach z półki, płatny designer, gotowy kit, czy AI pod Twoją recenzją? | G-DESIGN blokuje całą implementację. Bez właściciela plan ma zależność, której nikt nie wykona |
| **4** | **Gdzie mieszkasz i na jaki rynek celujesz?** | Decyduje, czy compliance pisać pod RODO i unijne MDR, czy pod UK GDPR i MHRA. Dotyczy G-MH, G-PRIV i modułu Mind |

Pytania drugiego rzędu, na które odpowiedź przyda się w tej samej turze:

5. **Czy masz dostęp do pięciu do ośmiu osób trenujących siłowo**, które zgodzą się na wywiad i test? Jeśli nie — bramki G-UXR, G2 i G3 trzeba przepisać na coś wykonalnego.
6. **Czy akceptujesz rok lub więcej do bety**, czy tniemy zakres v1.0? Jeśli tniemy, mam propozycję: bez szablonów, bez eksportu CSV, bez pomiarów ciała, bez Google i Apple OAuth — zostaje katalog, logowanie, historia, prosty postęp.
7. **Jaki masz budżet miesięczny** na infrastrukturę i narzędzia?
8. **Czy nazwa może się zmienić teraz?** Patrz §3.

---

## Źródła

Twierdzenia z §2 sprawdzone wobec: dokumentacji i changelogu Lighthouse oraz zgłoszenia o usunięciu kategorii PWA; repozytorium `yuhonas/free-exercise-db` wraz ze zgłoszeniami nr 2, 12 i 13 dotyczącymi licencji zdjęć; wpisu WebKit o polityce przechowywania danych i wypowiedzi inżyniera WebKit o aplikacjach z ekranu startowego; dokumentacji `next-intl` dotyczącej routingu i ograniczeń przy braku middleware; list produktów o nazwie LifeOS w App Store i Google Play; publicznych materiałów porównawczych Hevy i Strong z 2026 roku.

Źródła oficjalne Hevy były niedostępne z tego środowiska — stąd status „nierozstrzygnięte" w §4, a nie „obalone".
