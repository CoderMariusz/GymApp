# AGENTS.md

Ten projekt trzyma pełną instrukcję dla agentów w **`CLAUDE.md`** w korzeniu repozytorium.
Przeczytaj ją w całości przed pierwszą zmianą — obowiązuje tak samo Codex, Cursor/Composer
i każdy inny silnik.

Skrót tego, co najczęściej łamane:

1. Hierarchia dokumentów: `docs/DECISIONS.md` > `docs/PRD.md` > `docs/ARCHITECTURE.md` >
   design > TASK_SPEC > `docs/PLAN.md`. `docs/reviews/` nie rozstrzyga niczego.
2. Stack jest ustalony w ADR-ach. Nie podmieniaj bibliotek „dla wygody".
3. Żaden feature nie zapisuje do Supabase bezpośrednio — tylko przez `lib/mutations/`.
4. Trening zapisuje się jednym atomowym poleceniem, nigdy zestawem żądań.
5. Nie twórz katalogów ani kolumn dla funkcji, których nie ma w v1.0 (ADR-27).
6. Przed „zrobione" uruchom `npm run verify` i pokaż wynik.

Zmiana ADR jest commitowana **przed** kodem, który od niej zależy.
