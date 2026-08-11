<!-- AI-INDEX: v2, indeks, przebudowa, prd, plan-implementacji, analiza -->

# LifeOS v2 — dokumentacja przebudowy

Zestaw dokumentów przygotowany po pełnej analizie projektu v1. Kod v1 jest porzucany; przenosimy **założenia produktowe**, nie implementację.

## Kolejność czytania

| # | Dokument | Co zawiera | Dla kogo |
|---|---|---|---|
| 1 | [`00-ANALYSIS-FINDINGS.md`](00-ANALYSIS-FINDINGS.md) | Co wyciągnęliśmy z v1: stan faktyczny vs deklarowany, blokery bezpieczeństwa, mechanizmy porażki, sprzeczności produktowe, co warto przenieść | Każdy — to kontekst dla dwóch pozostałych |
| 2 | [`01-PRD.md`](01-PRD.md) | Wymagania od zera: persony, propozycja wartości, zakres wersji, funkcje z priorytetami MoSCoW, reguły biznesowe, taksonomia, monetyzacja, NFR, przyjęte założenia | Produkt |
| 3 | [`02-IMPLEMENTATION-PLAN.md`](02-IMPLEMENTATION-PLAN.md) | Stack, struktura, model danych, offline, AI, fazy M0–M6, testy, CI, zadania przed pierwszym commitem | Development |

## Skrót

**Diagnoza v1:** projekt nie upadł na złych decyzjach architektonicznych. Upadł na tym, że zbudowano 13 decyzji architektonicznych, 206 dokumentów, 36 tabel PostgreSQL i 380-linijkowy pipeline CI dla aplikacji, która nigdy nie miała działającego ekranu głównego. Około 200 z 217 plików Dart było nieosiągalnych z poziomu interfejsu.

**Zakres v2:**

| Wersja | Zakres | Czas |
|---|---|---|
| v1.0 | Fundament + Exercise + Fitness + Settings | ~11 tyg. |
| v1.1 | Life Coach + AI przez serwer | ~4 tyg. |
| v1.2 | Mind + insighty cross-module regułowe | ~3 tyg. |

**Trzy zasady:**
1. Definition of Done = osiągalny z aplikacji przepływ end-to-end na realnych danych. Istnienie klasy nie liczy się jako „Done".
2. Walking skeleton przed architekturą — M0 blokuje wszystko pozostałe.
3. Status wywodzi się z kodu, nie z prozy.

## Wymaga decyzji przed startem

1. **Rotacja kluczy Supabase (`service_role`, anon) i OpenAI** — klucz omijający wszystkie polityki RLS jest w historii Git
2. Katalog ćwiczeń: import z otwartej bazy vs produkcja własna (ścieżka krytyczna M1)
3. Spike na PowerSync/Brick — przesądza podejście do synchronizacji
4. Potwierdzenie 12 przyjętych założeń `[Z-1]`…`[Z-12]` z `01-PRD.md`
5. Właściciel produkcji treści (200–250 ćwiczeń × 2 języki)

## Status dokumentacji v1

Dokumenty w `docs/1-BASELINE/`, `docs/2-MANAGEMENT/` i `docs/5-ARCHIVE/` są **historyczne**. Nie są źródłem prawdy o stanie ani o wymaganiach. Zawierają trzy pokolenia sprzecznych audytów, z których najnowszy otwiera się nagłówkiem *„poprzedni audit był częściowo błędny"*, a najstarszy nadal jest linkowany jako źródło prawdy.
