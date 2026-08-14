# lifeos — STAN 2026-08-14

**Jednym zdaniem:** dziennik treningu siłowego — PWA offline-first, EN/PL.
Projekt przebudowany od zera: **Flutter porzucony, stack to Next.js + Supabase.**

- **Status:** 🟢 M0 rozpoczęte — szkielet stoi i się buduje
- **Katalog:** `~/Projects/lifeos` · **Remote:** `github.com/CoderMariusz/GymApp` — ⚠️ **PUBLICZNE**
- **Nazwa produktu:** nierozstrzygnięta (D-Q). `lifeos` to nazwa repo. Kandydaci: Datum, Rung, Ballast

## Co się stało 14.08

Stara implementacja Flutter (216 plików Dart, ~56 % wg raportu z 23.11.2025) **skasowana**.
Punkt odtworzenia: tag `flutter-archive-2026-08-14`, wypchnięty na origin.

Wgrane dokumenty z rundy konsolidacji 12.08 → `docs/` (PRD, ARCHITECTURE, PLAN,
DESIGN-BRIEF, DECISIONS, reviews). To jest teraz jedyne źródło prawdy.

Postawiony szkielet: Next.js 16 + React 19 + TS 6 strict, `output: 'export'`, Tailwind 4,
next-intl EN/PL, Vitest, Playwright, ESLint z regułą granic feature'ów, CI.

**Dowody, nie deklaracje:**

- `npm run verify` → kod wyjścia **0** (format, lint, typecheck, 4 testy, build)
- statyczny eksport generuje `/en` i `/pl` z realnie przetłumaczoną treścią i `lang` w HTML
- reguła granic **sprawdzona na czerwono** — import `features/history` → wnętrze
  `features/workouts` pada z komunikatem wskazującym ARCHITECTURE §4.1
- test parytetu tłumaczeń i sześciu stanów CORE-07 **sprawdzony na czerwono** — usunięcie
  `conflict` z `pl.json` wywala 2 z 4 testów

## Decyzje z 14.08

| Decyzja           | Wybór                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------- |
| Repozytorium      | to samo, kasowanie w miejscu, historia zachowana                                        |
| Kolejność baterii | **T02 przed T01** — Ustawienia jako jedyne nie mają narysowanego designu                |
| TypeScript        | **6.0.3, nie 7** — TS 7 nie jest wspierany przez `typescript-eslint` (`>=4.8.4 <6.1.0`) |
| ESLint            | **9.39.5, nie 10** — ESLint 10 wywala `scopeManager.addGlobals` w parserze              |
| Fonty             | self-hosted przez `next/font`, nie CDN — wymóg offline-first (§16.1)                    |

## ⚠️ Do zrobienia poza repo — pilne

**Klucz `service_role` Supabase jest w historii publicznego repo** (`supabase_config.dart`,
jako `defaultValue`). Ważny do 2035, omija wszystkie 66 polityk RLS. Kasowanie plików tego
**nie naprawia** — trzeba unieważnić u wystawcy.

Skoro ADR-15 i tak wymaga nowego projektu, najprościej **usunąć stary projekt Supabase**
(ref `neyxqf…`) z panelu. To unieważnia oba klucze jednym ruchem.

## Audyt systemu designu wobec PRD — 14.08

Pakiet z 14.08 (183 pliki, było 160) domyka trzy z czterech luk: ekrany Ustawień,
layouty set-editora dla wszystkich czterech typów śledzenia i osiem klatek stanów
systemowych. Dochodzą komponenty Checkbox, RadioGroup, Switch, ListRow, Skeleton
oraz karty potwierdzenia fontów i ikon. Oba motywy na wszystkich nowych ekranach.

Pakiet deklaruje, że „nic z inwentarza v1.0 nie jest już nienarysowane". Zderzenie
z PRD tego nie potwierdza.

### Braki wymagań

| #   | Brak                                                                                                                                                                                                                                                                                                             | Waga               |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| A   | **SET-06 pełny eksport danych** nie istnieje, a dialog usunięcia konta mówi wprost „export is not available in this version". SET-06 to MUST v1.0; do v1.0.1 przeszedł wyłącznie FIT-16 (CSV historii). LIFE-T01 AC #6 zakazuje fałszywego toasta — agent musi coś zbudować, a klatki mówią mu, żeby nie budował | **blokuje T01**    |
| B   | **SET-08 About** — brak ekranu w całości: wersja aplikacji, licencje OSS, kontakt. CORE-10 wymaga widocznej wersji, SHA commita i wersji katalogu                                                                                                                                                                | blokuje T01        |
| C   | **SET-05 awatar** — nie występuje nigdzie. `user_profiles.avatar_path` istnieje, a §24 mówi, że Storage służy wyłącznie awatarom                                                                                                                                                                                 | blokuje T01        |
| D   | **SET-07 disclaimer** fitness/health i nota bezpieczeństwa — brak                                                                                                                                                                                                                                                | blokuje T01        |
| E   | **SET-02 jednostka długości** cm/in — są kg/lb i km/mi, nie ma cm/in. Możliwe, że słusznie po D-S; wtedy poprawka należy się PRD, nie designowi                                                                                                                                                                  | do rozstrzygnięcia |
| F   | **`backend-unavailable`** — ARCH §24.1 wymaga tego stanu wprost (wstrzymany projekt na darmowym planie). `FatalError` to awaria aplikacji, nie niedostępny backend                                                                                                                                               | do narysowania     |

### Narysowane ponad zakres v1.0

Odwrotny problem: ekran obiecuje funkcję, której nie ma. Pakiet radzi sobie z tym
poprawnie przy CSV i „missed planned session" — wyszarza i wiesza plakietkę `1.0.1`.
Przy tych czterech tego nie zrobił.

| #   | Element                                                               | Stan w dokumentach                                                       |
| --- | --------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| G   | Ekran **Notifications** z trzema aktywnymi przełącznikami             | zero wystąpień w PRD; ARCH wiąże powiadomienia z Capacitorem, czyli v1.1 |
| H   | **Plate inventory** — „quick picks are built from the plates you own" | zero wystąpień w PRD; nowa funkcja                                       |
| I   | **Body weight** w koncie, 78 kg                                       | brak takiej kolumny w `user_profiles` (§9.2)                             |
| J   | **Keep the screen awake**                                             | zero wystąpień w PRD                                                     |

### Poza tym

Trzy nowe grupy ekranów są tylko mobilne. Pakiet sam zapowiada, że następna partia to
ich odpowiedniki na desktopie — `PLAN.md` §2.2 wymaga referencji 1440 w pełnym pakiecie
`G-DESIGN`.

Fonty (Archivo + Manrope) i ikony (Lucide) czekają na **Twoje potwierdzenie** —
karty `guidelines/confirm-fonts.card.html` i `confirm-icons.card.html`.
Ikony ładują się z CDN; przy offline-first trzeba je zwendorować.

## Bramki

| Bramka            | Stan                                                                                                                       |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------- |
| M0                | 🟢 GO — szkielet stoi, zostają SPIKE-01…06                                                                                 |
| `G-DESIGN-SYSTEM` | 🟡 blisko — po pakiecie z 14.08 zostaje sześć braków wymagań (A–F) i cztery elementy ponad zakres (G–J), patrz audyt wyżej |
| `G-BACKUP`        | 🔴 darmowy plan nie ma kopii; wymagana udokumentowana próba odtworzenia                                                    |
| `G-LIC`           | 🔴 licencja zdjęć `free-exercise-db`                                                                                       |
| `BRAND-01`        | 🔴 nazwa + UK IPO klasy 9 i 42                                                                                             |

## Następny krok

1. Usunąć stary projekt Supabase, założyć nowy (P0.7)
2. Domknąć `G-DESIGN-SYSTEM` — cztery brakujące pozycje
3. SPIKE-01…06 — reszta M0
