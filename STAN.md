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

| Decyzja | Wybór |
|---|---|
| Repozytorium | to samo, kasowanie w miejscu, historia zachowana |
| Kolejność baterii | **T02 przed T01** — Ustawienia jako jedyne nie mają narysowanego designu |
| TypeScript | **6.0.3, nie 7** — TS 7 nie jest wspierany przez `typescript-eslint` (`>=4.8.4 <6.1.0`) |
| ESLint | **9.39.5, nie 10** — ESLint 10 wywala `scopeManager.addGlobals` w parserze |
| Fonty | self-hosted przez `next/font`, nie CDN — wymóg offline-first (§16.1) |

## ⚠️ Do zrobienia poza repo — pilne

**Klucz `service_role` Supabase jest w historii publicznego repo** (`supabase_config.dart`,
jako `defaultValue`). Ważny do 2035, omija wszystkie 66 polityk RLS. Kasowanie plików tego
**nie naprawia** — trzeba unieważnić u wystawcy.

Skoro ADR-15 i tak wymaga nowego projektu, najprościej **usunąć stary projekt Supabase**
(ref `neyxqf…`) z panelu. To unieważnia oba klucze jednym ruchem.

## Bramki

| Bramka | Stan |
|---|---|
| M0 | 🟢 GO — szkielet stoi, zostają SPIKE-01…06 |
| `G-DESIGN-SYSTEM` | 🟡 blisko — system designu istnieje i pokrywa tokeny, powłokę, sześć stanów sync, obie motywy, PL. Brakuje: ekranów Ustawień, layoutów set-editora dla bodyweight/timed/distance, ekranowych stanów systemowych, potwierdzenia fontów i ikon |
| `G-BACKUP` | 🔴 darmowy plan nie ma kopii; wymagana udokumentowana próba odtworzenia |
| `G-LIC` | 🔴 licencja zdjęć `free-exercise-db` |
| `BRAND-01` | 🔴 nazwa + UK IPO klasy 9 i 42 |

## Następny krok

1. Usunąć stary projekt Supabase, założyć nowy (P0.7)
2. Domknąć `G-DESIGN-SYSTEM` — cztery brakujące pozycje
3. SPIKE-01…06 — reszta M0
