# lifeos

Dziennik treningu siłowego. PWA (Next.js static export) + Supabase, offline-first,
dwujęzyczny EN/PL.

> `lifeos` to nazwa repozytorium. Nazwa produktu jest otwarta — bramka BRAND-01,
> patrz `docs/DECISIONS.md`.

## Start

```bash
npm install
cp .env.example .env.local     # uzupełnij URL i klucz anon nowego projektu Supabase
npm run dev
```

## Dokumentacja

| Plik                   | Co zawiera                                    |
| ---------------------- | --------------------------------------------- |
| `docs/DECISIONS.md`    | decyzje, bramki, co wolno robić teraz         |
| `docs/PRD.md`          | wymagania funkcjonalne                        |
| `docs/ARCHITECTURE.md` | kontrakt implementacyjny, ADR-y, model danych |
| `docs/PLAN.md`         | M0, bateria zadań, nakład                     |
| `docs/DESIGN-BRIEF.md` | wejście do designu (nie design)               |
| `CLAUDE.md`            | instrukcja dla agentów AI                     |

System designu: `.claude/skills/lifeos-strength-design/`.

## Polecenia

```bash
npm run dev       npm run build     npm run verify
npm run test      npm run e2e       npm run typecheck
```

## Stan

M0 (walking skeleton) w toku. Bramki `G-DESIGN-SYSTEM`, `G-BACKUP`, `G-LIC` i `BRAND-01`
pozostają otwarte — `docs/DECISIONS.md` §4.
