<!-- AI-INDEX: decyzje, hierarchia dokumentów, precedencja, otwarte decyzje, ADR -->

# Decisions

**Ostatnia aktualizacja:** 2026-08-12
**Rola:** jedyne wiążące źródło decyzji produktowych i ich statusu

---

## 1. Hierarchia dokumentów — precedencja przy konflikcie

Gdy dwa dokumenty mówią co innego, **wyższy wygrywa**. Ta lista istnieje po to, żeby system autonomiczny miał deterministyczną odpowiedź zamiast wybierać losowo.

```
1. DECISIONS.md          ← ten plik; decyzje i ich status
2. PRD.md                ← co ma działać
3. ARCHITECTURE.md       ← jak wolno to zbudować
4. zaakceptowany DESIGN  ← jak to wygląda (jeszcze nie istnieje)
5. TASK_SPEC             ← zamrożony kontrakt pojedynczego zadania
6. PLAN.md               ← kolejność i nakład
```

**`reviews/` nigdy nie rozstrzyga konfliktu.** Zawartość tego katalogu jest niewiążąca i historyczna.

**`DESIGN-BRIEF.md` jest wejściem do designu, nie designem.** Nie zaspokaja `G-DESIGN` i nie może być traktowany jako artefakt projektowy przy decyzji o rozpoczęciu mierzonych zadań.

Zasady dodatkowe:

- Zmiana ADR jest commitowana **przed** kodem, który od niej zależy.
- Zadanie z zamrożonym `TASK_SPEC` nie zmienia się dlatego, że zmienił się PRD — zostaje przebazowane albo unieważnione jawnie.
- Nazwy plików są stabilne. Bez `final`, `reviewed`, `v2`, `(1)`. Wersję trzyma Git i nagłówek dokumentu.

---

## 2. Decyzje przyjęte

| ID | Decyzja | Data | Skutek |
|---|---|---|---|
| D-M | Produkt i benchmark AgentOS są równorzędne; narzut pomiarowy zaakceptowany | 2026-08-12 | Wyliczony jawnie w `PLAN.md` §8.1.2: 54–84 h |
| D-N | Wyróżnik v1.0: brak sufitu darmowego planu | 2026-08-12 | **Sformułowanie poprawione po recenzji** — patrz `PRD.md` §1.2 |
| D-O | Design powstaje w narzędziu projektowym pod nadzorem właściciela | 2026-08-12 | `G-DESIGN` ma właściciela; wejście w `DESIGN-BRIEF.md` |
| D-P | Jurysdykcja i rynek: Wielka Brytania | 2026-08-12 | UK GDPR, MHRA, UK IPO |
| D-Q | Nazwa „LifeOS" porzucona | 2026-08-12 | Krótka lista w `PRD.md` §1.4; `lifeos` tylko jako nazwa repozytorium |
| D-R | Testerzy dostępni | 2026-08-12 | G-UXR, G2, G3 bez zmian |
| D-S | Zakres v1.0 przycięty: bez szablonów, CSV, pomiarów ciała, logowania społecznościowego | 2026-08-12 | Wszystko wraca w v1.0.1 |
| D-T | Wyłącznie darmowe progi usług | 2026-08-12 | ADR-25. **Obowiązuje dla v1.0; od M5 uchylone w części dotyczącej API modelu — patrz D-X** |
| **D-U** | **Offline workout commit jest MUST v1.0** | 2026-08-12 | ADR-17 Accepted, FIT-23 MUST, **G-PROD zamknięte**. Uchyla D-D |
| **D-V** | **FIT-24 „Repeat last workout" wchodzi do v1.0** | 2026-08-12 | ADR-31 (bez encji szablonu), LIFE-T04 +8–14 h, `DESIGN-BRIEF.md` §6.9. Benchmark rozdzielony: powtórzenie <60 s, od pustego <120 s |
| **D-W** | **SET-06 pozostaje samoobsługowy w v1.0** | 2026-08-12 | Zakres bez zmian; uzasadnienie produktowe, nie prawne |
| **D-X** | **Kolejność v1.1: Life Coach → generic sync → Capacitor** | 2026-08-12 | `PLAN.md` §9. Teza produktu testowana 130–210 h wcześniej. **Koszt: pierwszy stały wydatek na API modelu przesunięty wcześniej; częściowo uchyla D-T** |

---

## 3. Decyzje otwarte

**Wszystkie decyzje produktowe są rozstrzygnięte.** Blokady, które pozostały, są wykonawcze — brakuje wykonanej pracy, nie odpowiedzi właściciela.

| Blokada | Czego brakuje |
|---|---|
| `G-DESIGN` | Pakiet graficzny nie istnieje. Brief to wejście, nie wynik |
| `G-BACKUP` | Kopie poza platformą + udokumentowana próba odtworzenia |
| `G-LIC` | Licencja zdjęć w `free-exercise-db` — planuj własne diagramy |
| `BRAND-01` | Wybór nazwy + badanie UK IPO klasy 9 i 42 |

**Zamknięte:** ~~O-01~~ (D-U) · ~~O-04~~ (D-S) · ~~O-08~~ (scalone w O-01) · ~~O-09~~ (keepalive odrzucony) · ~~O-10~~ (D-V) · ~~O-11~~ (D-W) · ~~O-12~~ (D-X)

---

## 4. Bramki i ich stan

| Bramka | Stan | Czego brakuje |
|---|---|---|
| G-PROD | 🟢 **CLOSED** | D-U…D-X, 2026-08-12 |
| G-DESIGN | 🔴 **OPEN** | Design nie istnieje. Brief to wejście, nie wynik |
| G-LIC | 🔴 **OPEN** | Licencja zdjęć w `free-exercise-db` — trzy zgłoszenia bez odpowiedzi od marca 2024. Planuj własne diagramy |
| BRAND-01 | 🔴 **OPEN** | Wybór nazwy + badanie UK IPO, klasy 9 i 42 |
| **G-BACKUP** | 🔴 **OPEN** | **Nowa.** Darmowy plan Supabase nie ma automatycznych kopii. Wymagana udokumentowana próba odtworzenia przed pierwszym zewnętrznym testerem |
| G-UXR | 🟡 gotowa do wykonania | Testerzy dostępni (D-R) |
| M0 | 🟢 **GO** | Bez zastrzeżeń |

---

## 5. Co wolno robić teraz

**GO:** repozytorium, konfiguracja, spike'i M0, projekt Supabase, rotacja sekretów, produkcja designu, wywiady z użytkownikami, treść katalogu, badanie znaku towarowego.

**NO-GO:** mierzone zadania `LIFE-T01…T07`, zamrożenie `TASK_SPEC`, pierwszy zewnętrzny tester (do czasu `G-BACKUP`).
