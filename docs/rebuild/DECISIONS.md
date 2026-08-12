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
| D-T | Wyłącznie darmowe progi usług | 2026-08-12 | ADR-25; konsekwencje w `ARCHITECTURE.md` §24 |

---

## 3. Decyzje otwarte — blokujące

**Żadne mierzone zadanie `LIFE-Txx` nie startuje, dopóki O-01 i `G-DESIGN` są otwarte.**

| ID | Pytanie | Blokuje | Skutek każdej odpowiedzi |
|---|---|---|---|
| **O-01** | Czy pełny zapis treningu offline (FIT-23) pozostaje MUST v1.0? | **G-PROD**, LIFE-T04 | **Tak** → ADR-17 Accepted, FIT-23 MUST, T04 z kryteriami offline. **Nie** → trwały szkic i atomowy zapis zostają, ale zakończenie treningu wymaga sieci; oszczędność 20–30 h |
| **O-10** | Czy dodać FIT-24 „Repeat last workout" do v1.0? | LIFE-T04, benchmark 60 s | **Tak** → +8–14 h, budżet 60 s realny. **Nie** → cel 60 s wymaga rewizji, bo sześć ćwiczeń wybieranych ręcznie co sesję go przekracza |
| **O-11** | Czy SET-06 jest samoobsługowy w v1.0, czy wystarczy udokumentowany proces? | LIFE-T01 | **Samoobsługa** → bez zmian. **Proces** → T01 lżejsze o kilka godzin, praca wraca przed sklepami |
| **O-12** | Kolejność v1.1: Life Coach przed generic sync i Capacitorem? | po becie v1.0 | **Tak** → teza produktu sprawdzona 130–210 h wcześniej, ale pierwszy stały koszt API. **Nie** → infrastruktura najpierw, teza sprawdzona pół roku później |

**Zamknięte w tej rundzie:** ~~O-04~~ (pomiary ciała → v1.0.1, D-S) · ~~O-08~~ (scalone w O-01) · ~~O-09~~ (podtrzymywanie projektu Supabase — odrzucone, `ARCHITECTURE.md` §24.1)

---

## 4. Bramki i ich stan

| Bramka | Stan | Czego brakuje |
|---|---|---|
| G-PROD | 🔴 **OPEN** | O-01 nierozstrzygnięte |
| G-DESIGN | 🔴 **OPEN** | Design nie istnieje. Brief to wejście, nie wynik |
| G-LIC | 🔴 **OPEN** | Licencja zdjęć w `free-exercise-db` — trzy zgłoszenia bez odpowiedzi od marca 2024. Planuj własne diagramy |
| BRAND-01 | 🔴 **OPEN** | Wybór nazwy + badanie UK IPO, klasy 9 i 42 |
| **G-BACKUP** | 🔴 **OPEN** | **Nowa.** Darmowy plan Supabase nie ma automatycznych kopii. Wymagana udokumentowana próba odtworzenia przed pierwszym zewnętrznym testerem |
| G-UXR | 🟡 gotowa do wykonania | Testerzy dostępni (D-R) |
| M0 | 🟢 **GO** | Trwały szkic i atomowy zapis są potrzebne niezależnie od O-01 |

---

## 5. Co wolno robić teraz

**GO:** repozytorium, konfiguracja, spike'i M0, projekt Supabase, rotacja sekretów, produkcja designu, wywiady z użytkownikami, treść katalogu, badanie znaku towarowego.

**NO-GO:** mierzone zadania `LIFE-T01…T07`, zamrożenie `TASK_SPEC`, pierwszy zewnętrzny tester (do czasu `G-BACKUP`).
