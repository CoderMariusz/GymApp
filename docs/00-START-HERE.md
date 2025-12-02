# LifeOS / GymApp - Dokumentacja Projektu

<!-- AI-INDEX: entry-point, navigation, project-overview, getting-started -->

**Status:** W trakcie implementacji (~66% FRs)
**Wersja:** 2.0 (BMAD Framework)
**Ostatnia aktualizacja:** 2025-12-02

---

## Szybki Start

### Dla AI Agentów
```
1. Przeczytaj ten plik dla kontekstu
2. Użyj indeksów (AI-INDEX) do wyszukiwania
3. Sprawdź 2-MANAGEMENT/project-status.md dla aktualnego stanu
4. Sprawdź odpowiedni folder dla szczegółów
```

### Dla Developerów
```
1. 4-DEVELOPMENT/setup/QUICK-START-5MIN.md - szybki start
2. 4-DEVELOPMENT/standards/ - standardy kodu
3. 2-MANAGEMENT/project-status.md - co jest do zrobienia
```

---

## O Projekcie

**LifeOS** to modularny ekosystem AI-powered life coaching łączący:
- **Fitness Coach** - Smart Pattern Memory, workout tracking
- **Life Coach** - Daily planning, goals, AI chat
- **Mind & Emotion** - Meditation, mood tracking, CBT

**Killer Feature:** Cross-Module Intelligence - moduły komunikują się ze sobą dla holistycznej optymalizacji.

---

## Struktura Dokumentacji BMAD

```
docs/
├── 00-START-HERE.md          ← JESTEŚ TUTAJ
├── BMAD-STRUCTURE.md         # Wyjaśnienie struktury
│
├── 1-BASELINE/               # Fundamenty (PRD, Architecture, Design)
│   ├── product/              # Wymagania produktowe
│   ├── architecture/         # Decyzje architektoniczne
│   └── design-system/        # UI/UX guidelines
│
├── 2-MANAGEMENT/             # Zarządzanie projektem
│   ├── epics/                # User stories podzielone na epiki
│   ├── backlog/              # Sprint backlogs i summaries
│   └── reports/              # Raporty statusu i audytów
│
├── 3-ARCHITECTURE/           # Szczegóły techniczne
│   ├── system-design/        # Design per moduł
│   ├── deployment/           # Deploy, Firebase, CI/CD
│   └── integration/          # API, third-party services
│
├── 4-DEVELOPMENT/            # Poradniki dla devów
│   ├── setup/                # Quick start, environment
│   ├── standards/            # Code standards, testing
│   ├── patterns/             # Design patterns, AI patterns
│   └── modules/              # Jak pracować z każdym modułem
│
└── 5-ARCHIVE/                # Historia i deprecated
    ├── historical/           # Historyczne planowanie
    └── deprecated/           # Zastąpione pliki
```

---

## Kluczowe Dokumenty

| Cel | Plik | Opis |
|-----|------|------|
| **Status projektu** | `2-MANAGEMENT/project-status.md` | Aktualny postęp, co zrobić |
| **Wymagania** | `1-BASELINE/product/PRD-overview.md` | Przegląd produktu i FRs |
| **Architektura** | `1-BASELINE/architecture/ARCH-overview.md` | Decyzje i patterns |
| **Quick start** | `4-DEVELOPMENT/setup/QUICK-START-5MIN.md` | Setup w 5 minut |
| **Epiki** | `2-MANAGEMENT/epics/` | User stories per epic |

---

## Nawigacja AI (Indeksy)

Każdy dokument zawiera `<!-- AI-INDEX: keywords -->` dla szybkiego wyszukiwania.

**Przykłady wyszukiwania:**
- `AI-INDEX: authentication` → pliki o auth
- `AI-INDEX: fitness` → pliki o Fitness module
- `AI-INDEX: database` → pliki o bazie danych
- `AI-INDEX: deployment` → pliki o deploy

---

## Metryki Projektu

| Metryka | Wartość |
|---------|---------|
| **Implementacja FRs** | ~66% (81/123) |
| **Core Infrastructure** | ~90% |
| **Life Coach** | ~75% |
| **Fitness Coach** | ~82% |
| **Mind & Emotion** | ~40% |
| **Cross-Module Intel** | ~25% |

---

## Tech Stack

- **Framework:** Flutter 3.38+, Dart 3.10+
- **State:** Riverpod 3.0
- **Local DB:** Drift (SQLite) - offline-first
- **Backend:** Supabase (PostgreSQL)
- **AI:** Hybrid (Llama/Claude/GPT-4)

---

## Linki

- **Kod:** `/lib/` (287+ plików Dart)
- **Migracje:** `/supabase/migrations/`
- **Testy:** `/test/`

---

*Dokumentacja zgodna z BMAD Framework v2.0*
