# RUNBOOK — od dzisiaj do pierwszego mierzonego zadania

**Data:** 2026-08-14 · **Właściciel:** Mariusz · **Tryb:** ~20 h/tydzień

> Ten plik jest **wyprowadzony** z `docs/PLAN.md` i jemu podporządkowany. Przy konflikcie
> wygrywa `PLAN.md`. Nakłady są human-equivalent — `PLAN.md` §0.4 zabrania wliczania
> przyspieszenia od silników, zanim je zmierzymy.

Każdy krok ma **dowód**. Krok bez dowodu nie jest zrobiony, tylko zadeklarowany.

---

## Etap 0 — Odblokowanie · ~5 h · ten tydzień

Nic z dalszych etapów nie ruszy sensownie, dopóki to nie jest zamknięte.

### 0.1 Usuń stary projekt Supabase 🔴 PILNE · 15 min

Klucz `service_role` z publicznej historii repo jest ważny do 2035 i omija wszystkie
66 polityk RLS. Kasowanie plików go **nie unieważniło**. ADR-15 i tak wymaga nowego
projektu, więc usunięcie starego załatwia jedno i drugie.

**Dowód:** panel Supabase nie pokazuje projektu `neyxqf…`; próba zapytania starym
kluczem zwraca błąd.

### 0.2 Załóż nowy projekt Supabase (P0.7) · 45 min

Plan darmowy (D-T). Region blisko UK. Zapisz `URL` i klucz `anon` do `.env.local`
— **nigdy** `service_role` w repo ani w bundlu.

Od razu: udokumentuj procedurę ręcznego wznowienia po 7 dniach ciszy (§24.1).

**Dowód:** `npm run dev` startuje, `.env.local` istnieje i **nie jest** w gicie
(`git check-ignore .env.local` zwraca ścieżkę).

### 0.3 Potwierdź fonty i ikony · 30 min

Otwórz `.claude/skills/lifeos-strength-design/guidelines/confirm-fonts.card.html`
i `confirm-icons.card.html`. Archivo + Manrope i Lucide to **substytuty** — potrzebne
jest Twoje „tak" albo prawdziwy zestaw.

Niezależnie od odpowiedzi: ikony ładują się z CDN, a przy offline-first muszą zostać
zwendorowane. To robota inżynierska, wchodzi do M0.

**Dowód:** wpis w `docs/DECISIONS.md`.

### 0.4 Rozstrzygnij kolejność baterii · 15 min

Patrz sekcja „Decyzja do podjęcia" niżej. **To blokuje planowanie etapu 4.**

### 0.5 Wypchnij dwa commity · 2 min

`git push origin main` — rozbiórka Fluttera i pakiet designu czekają lokalnie.

### 0.6 Narysuj stan `backend-unavailable` · 1–2 h

Ostatnia pozycja blokująca `G-DESIGN-SYSTEM`. To **nie** jest `FatalError` — aplikacja
działa, backend nie odpowiada. Treść ma mówić, że zalogowane serie są bezpieczne na
urządzeniu i pójdą, gdy backend wróci.

**Dowód:** klatka w `screens/system/`, oba motywy, stan `queued` widoczny na powierzchni.

**➡️ Po 0.6 bramka `G-DESIGN-SYSTEM` jest zielona.**

---

## Decyzja do podjęcia — kolejność baterii

14.08 zamieniliśmy T01↔T02, bo T02 ma narysowany design, a T01 nie miał. **Ta przesłanka
była niepełna.** Pominęła tor treści.

|                      | LIFE-T01 — Ustawienia            | LIFE-T02 — Katalog          |
| -------------------- | -------------------------------- | --------------------------- |
| Design               | brak 4 pozycji (SET-05/06/07/08) | ✅ gotowy                   |
| Praca odblokowująca  | **8–14 h projektowej**           | **60–100 h treści (C0–C5)** |
| Zależność zewnętrzna | brak                             | `G-LIC` otwarte             |

**Rekomendacja: wróć do T01 na pierwszym miejscu.** Nie dlatego, że poprzednia decyzja
była zła, tylko dlatego, że pojawiła się liczba, której wcześniej nie zestawiłem: katalog
to najdłuższy pojedynczy blok pracy właściciela w całym v1.0, a bez niego twarde AC dla
T02 (przeszukiwanie offline, zgodność ID z seedem) nie mają na czym stanąć.

Kolejność przy tej rekomendacji: **T01 → T02 → T04 → T07 → T05 → T06**, czyli oryginalna
z `PLAN.md` §5.0. Tor treści rusza równolegle w etapie 2 i ma cały czas trwania T01 na
rozbieg.

Zmiana jest darmowa **tylko do pierwszego mierzonego przebiegu.**

---

## Etap 1 — Dwa tory równolegle · 3–4 tygodnie

### Tor A — projektowy (Ty) · 8–14 h

Cztery braki T01, każdy zderzony z wymaganiem:

| Klatka               | Wymaganie        | Uwaga                                                                                                                                                   |
| -------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pełny eksport danych | SET-06 MUST v1.0 | Dialog usunięcia konta **kłamie** — mówi „export is not available in this version". Do v1.0.1 poszedł tylko CSV historii (FIT-16), nie eksport z SET-06 |
| Ekran About          | SET-08 + CORE-10 | wersja, SHA commita, wersja katalogu, licencje OSS, kontakt                                                                                             |
| Awatar w profilu     | SET-05           | `user_profiles.avatar_path`; Storage istnieje wyłącznie po to                                                                                           |
| Disclaimer fitness   | SET-07           | nic o zdrowiu psychicznym — to v1.2 (SET-07b)                                                                                                           |

Do rozstrzygnięcia przy okazji: **cm/in** (SET-02). Skoro D-S usunęło pomiary ciała,
prawdopodobnie poprawka należy się PRD, nie designowi.

**➡️ Zamyka `G-DESIGN-T01`.**

### Tor B — M0 w sześciu falach (silniki piszą, Ty recenzujesz) · 45–70 h

Pipeline na falę: **Composer implementuje → Codex recenzuje → Ty rozstrzygasz.**
Wyjątek UI: pisze Claude/Opus, recenzuje Codex. Piszący nigdy nie recenzuje siebie.

| Fala  | Zakres                                                                     | Zależy od       | Dowód wyjścia                                                                                               |
| ----- | -------------------------------------------------------------------------- | --------------- | ----------------------------------------------------------------------------------------------------------- |
| **1** | M0.3 — migracje, RLS, auth e-mail + reset, PKCE                            | 0.2             | użytkownik A nie widzi danych B; macierz RLS zielona dla SELECT/INSERT/UPDATE/DELETE                        |
| **2** | M0.4 powłoka 5 zakładek · M0.2 dokończenie i18n                            | fala 1          | każda zakładka istnieje z realnym stanem pustym; `/en` i `/pl` po twardym przeładowaniu                     |
| **3** | M0.5 Dexie · M0.7 persystencja Query                                       | fala 2          | **zabicie karty w trakcie edycji → dokładnie ta sama wartość po wznowieniu**                                |
| **4** | **M0.6 atomowy `CommitWorkout`**                                           | fala 3          | powtórzenie 5× = jeden trening; wymuszony błąd przy dziecku = zero wierszy; B nie odwoła się do ćwiczenia A |
| **5** | M0.8 Serwist/PWA · M0.11 obserwowalność · M0.12 CI/deploy · vendoring ikon | fala 2          | powłoka offline; zasiany łańcuch wrażliwy **nie** pojawia się w zdarzeniu Sentry                            |
| **6** | M0.10 tożsamość katalogu (SPIKE-06)                                        | C0–C2 częściowo | ten sam UUID w paczce statycznej i w seedzie — test automatyczny                                            |

**M0.9 — iOS, tylko Ty · 2–3 h.** Safari → auth → dodaj do ekranu początkowego →
pierwsze uruchomienie standalone. `PLAN.md` zabrania traktować „7 dni i storage znika"
jako fakt platformy — masz to **zmierzyć i opisać**, nie założyć.

**Fala 4 jest najważniejsza w całym M0.** Reszta to rusztowanie; ta jedna decyduje, czy
produkt gubi treningi.

**➡️ Wyjście M0:** publiczny URL preview, instalowalna powłoka, trwały draft przeżywa,
atomowy zapis udowodniony, zielony pipeline. **Reguła STOP:** jeśli M0 nie utrzyma
zieleni przez 48 h, bateria nie startuje.

---

## Etap 2 — Tor treści (Ty) · 60–100 h · rusza RAZEM z etapem 1

Najdłuższy blok Twojej pracy w całym v1.0. Jeśli nie ruszy teraz, stanie się wąskim
gardłem dla T02 niezależnie od kolejności baterii.

| Krok   | Co                                                                                               | Uwaga                                                            |
| ------ | ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| **C0** | snapshot `free-exercise-db` + commit, weryfikacja licencji danych, **osobno** proweniencja zdjęć | to jest `G-LIC` — trzy zgłoszenia bez odpowiedzi od marca 2024   |
| **C1** | wybór 200–250 ruchów                                                                             | pokrycie sprzętu i partii, mniej duplikatów                      |
| **C2** | normalizacja i mapowanie taksonomii                                                              | wzorzec ruchu, `tracks`, domyślna przerwa                        |
| **C3** | baza dwujęzyczna EN + PL                                                                         | PL to przypadek testowy layoutu                                  |
| **C4** | kuracja top 50                                                                                   | wskazówki techniczne, częste błędy                               |
| **C5** | walidacja i build                                                                                | ID stabilne, obie wersje językowe, brak niezatwierdzonych mediów |

**Jeśli `G-LIC` nie da odpowiedzi:** `media-approved=false`, katalog wychodzi bez zdjęć
źródłowych, planujesz własne diagramy. Build ma to **wymuszać**, nie przypominać.

**Zdjęcia instruktażowe nigdy z generatora** (§9.5) — pięknie oświetlony błędny hip hinge
to defekt bezpieczeństwa, który wygląda autorytatywnie.

---

## Etap 3 — Bramki przed pierwszym obcym człowiekiem

Żadna nie blokuje startu baterii. Wszystkie blokują testera.

| Bramka         | Co zrobić                                                                                                                                    | Nakład |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| **`G-BACKUP`** | `supabase db dump` poza platformę, retencja 7–14, kopia przed każdą ryzykowną migracją i **udokumentowana próba odtworzenia do pustej bazy** | 4–6 h  |
| **`G-UXR`**    | 5–8 wywiadów z P1, zmierzyć ich obecny sposób zapisywania treningu (P0.5)                                                                    | 8–12 h |
| **P0.6**       | zdefiniować referencyjny benchmark 6 ćwiczeń / 18 serii                                                                                      | 2 h    |
| **`BRAND-01`** | wybór z krótkiej listy (Datum / Rung / Ballast) + badanie UK IPO klasy 9 i 42                                                                | 4–8 h  |

`G-BACKUP` jest luką, nie niedogodnością: darmowy plan **nie ma** automatycznych kopii,
a przy jednoosobowym zespole bez recenzenta migracja psująca dane to scenariusz realny.
**Kopia, której nigdy nie odtworzono, jest założeniem, nie zabezpieczeniem.**

---

## Etap 4 — Bateria zadań

Startuje dopiero gdy: M0 zielone 48 h · `G-DESIGN-SYSTEM` zielone · fixture'y i tożsamość
testowa gotowe · schemat `TASK_SPEC` **zamrożony** · kolejność zamrożona · tag bazowy.

Sześć zadań, każde z własną bramką designu. Przy rekomendowanej kolejności:

`T01 Ustawienia` → `T02 Katalog` → `T04 Trening + offline` → `T07 Timer + PR` →
`T05 Historia` → `T06 Postęp` · potem w v1.0.1: `T03 Szablony` → `T08 CSV`

**T04 niesie całe ryzyko produktowe.** M0 fala 4 istnieje po to, żeby dowieźć je tam
udowodnione, a nie odkrywane.

Zmiana schematu `TASK_SPEC` między turami unieważnia porównanie. Zamrożone znaczy
zamrożone.

---

## Etap 5 — R1, hardening, beta

Przepływ end-to-end, wydajność, dostępność, PWA na urządzeniach, bezpieczeństwo
i prywatność, instrumentacja bety, wreszcie beta. Szczegóły: `PLAN.md` §7.

---

## Kalendarz — uczciwie

| Kamień                            | Kiedy                   | Warunek         |
| --------------------------------- | ----------------------- | --------------- |
| `G-DESIGN-SYSTEM` zielone         | **ten tydzień**         | krok 0.6        |
| Nowy Supabase, klucz unieważniony | **ten tydzień**         | kroki 0.1–0.2   |
| M0 zielone                        | **za 2–3 tygodnie**     | fale 1–6        |
| M0 stabilne 48 h → start baterii  | **za 3–4 tygodnie**     | reguła STOP     |
| Katalog gotowy (C5)               | **za 4–8 tygodni**      | tylko Twój czas |
| Pierwszy zewnętrzny tester        | po `G-BACKUP` + `G-UXR` | nie wcześniej   |

Pełne v1.0 to wg `PLAN.md` **612–955 h**, czyli 31–48 tygodni w wariancie konserwatywnym.
Współczynnik kompresji od silników poznamy **po M0 i pierwszych trzech zadaniach** — do
tego czasu każda data podana jako pewna byłaby zmyślona.

---

## Czego świadomie nie robimy

Systemu podtrzymującego projekt Supabase (O-09 odrzucone — mechanizm istniejący wyłącznie
po to, by obejść politykę darmowego planu, nie jest funkcją produktu). Szablonów, CSV,
pomiarów ciała i logowania społecznościowego w v1.0 (D-S). Tabel ani kolumn dla
czterech elementów z D-Y. Kolejnej rundy recenzji dokumentów — `DECISIONS.md` §6 zamyka
ten tryb pracy.
