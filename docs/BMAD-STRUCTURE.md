# BMAD Framework - Struktura Dokumentacji

<!-- AI-INDEX: bmad, documentation-structure, framework, organization -->

**Wersja:** 2.0
**Data:** 2025-12-02

---

## Czym jest BMAD?

**BMAD** (Baseline-Management-Architecture-Development) to framework organizacji dokumentacji projektowej optymalizowany dla:
- **AI Agents** - szybkie znajdowanie informacji przez indeksy
- **Developerów** - jasna hierarchia i nawigacja
- **Skalowalności** - łatwe dodawanie nowych dokumentów

---

## Zasady Struktury

### 1. Numerowane Foldery (Hierarchia)
```
1-BASELINE/      → Fundamenty (czytaj najpierw)
2-MANAGEMENT/    → Zarządzanie (status, epiki)
3-ARCHITECTURE/  → Techniczne szczegóły
4-DEVELOPMENT/   → Poradniki implementacji
5-ARCHIVE/       → Historia (nie czytaj bez potrzeby)
```

### 2. Maksymalny Rozmiar Pliku
- **Idealny:** 600-800 linii
- **Maksymalny:** 1200 linii
- **Dlaczego:** AI context limits, czytelność

### 3. Indeksy AI
Każdy plik zawiera na górze:
```markdown
<!-- AI-INDEX: keyword1, keyword2, keyword3 -->
```

**Użycie:** Wyszukaj `AI-INDEX: keyword` zamiast czytać całe pliki.

### 4. Cross-References
Linkuj do powiązanych dokumentów:
```markdown
**Zobacz też:**
- [Architektura](../1-BASELINE/architecture/ARCH-overview.md)
- [Epic 3](../2-MANAGEMENT/epics/epic-3-fitness.md)
```

---

## Struktura Katalogów

### 1-BASELINE/ (Dokumentacja Fundamentalna)

| Folder | Zawartość | Kiedy czytać |
|--------|-----------|--------------|
| `product/` | PRD, wymagania funkcjonalne | Zrozumienie co budujemy |
| `architecture/` | Decyzje arch., tech stack | Zrozumienie jak budujemy |
| `design-system/` | UI/UX, komponenty | Implementacja UI |

**Pliki:**
- `PRD-overview.md` - Przegląd produktu, success metrics
- `PRD-fitness-requirements.md` - Wymagania Fitness module
- `PRD-life-coach-requirements.md` - Wymagania Life Coach
- `PRD-mind-requirements.md` - Wymagania Mind module
- `ARCH-overview.md` - Przegląd architektury
- `ARCH-database-schema.md` - Schemat bazy danych
- `ARCH-ai-infrastructure.md` - AI/LLM infrastructure
- `ARCH-security.md` - Security, GDPR

### 2-MANAGEMENT/ (Zarządzanie Projektem)

| Folder | Zawartość | Kiedy czytać |
|--------|-----------|--------------|
| `epics/` | User stories per epic | Planowanie implementacji |
| `backlog/` | Sprint summaries | Status sprintów |
| `reports/` | Audyty, compliance | Przeglądy jakości |

**Pliki:**
- `project-status.md` - Aktualny status projektu
- `epic-1-core-platform.md` - Stories dla Core Platform
- `epic-2-life-coach.md` - Stories dla Life Coach
- `epic-3-fitness.md` - Stories dla Fitness
- `epic-4-mind.md` - Stories dla Mind & Emotion
- `epic-5-cross-module.md` - Cross-Module Intelligence
- `sprint-1-summary.md` ... `sprint-9-summary.md`

### 3-ARCHITECTURE/ (Szczegóły Techniczne)

| Folder | Zawartość | Kiedy czytać |
|--------|-----------|--------------|
| `system-design/` | Design per moduł | Przed implementacją modułu |
| `deployment/` | CI/CD, Firebase | DevOps, deploy |
| `integration/` | API, third-party | Integracje |

**Pliki:**
- `core-platform.md` - Auth, DB, offline-first
- `fitness-module.md` - Fitness technical design
- `life-coach-module.md` - Life Coach technical design
- `deployment-strategy.md` - Deploy, environments
- `api-contracts.md` - API specifications

### 4-DEVELOPMENT/ (Poradniki)

| Folder | Zawartość | Kiedy czytać |
|--------|-----------|--------------|
| `setup/` | Quick start, environment | Nowy dev, setup |
| `standards/` | Code style, testing | Coding standards |
| `patterns/` | Design patterns | Best practices |
| `modules/` | Per-module guides | Working on specific module |

**Pliki:**
- `QUICK-START-5MIN.md` - Szybki start
- `environment-setup.md` - Pełny setup
- `code-standards.md` - Standardy kodu
- `testing-guidelines.md` - Jak testować
- `clean-architecture.md` - Clean Architecture patterns

### 5-ARCHIVE/ (Historia)

| Folder | Zawartość | Kiedy czytać |
|--------|-----------|--------------|
| `historical/` | Stare sesje planowania | Reference only |
| `deprecated/` | Zastąpione pliki | Nie czytać |

---

## Konwencje Nazewnictwa

### Pliki
```
PRD-[temat].md           # Product requirements
ARCH-[temat].md          # Architecture documents
epic-[N]-[nazwa].md      # Epic documents
sprint-[N]-summary.md    # Sprint summaries
[temat]-guide.md         # Guides/tutorials
```

### Sekcje w Plikach
```markdown
# Główny Tytuł
<!-- AI-INDEX: keywords -->

## Spis Treści (dla plików >500 linii)

## 1. Executive Summary
## 2. Szczegóły
## 3. Przykłady
## 4. Zobacz też
```

---

## Jak Używać (dla AI)

### Znajdowanie Informacji
```
1. Sprawdź 00-START-HERE.md dla kontekstu
2. Wyszukaj "AI-INDEX: [keyword]" w docs/
3. Przeczytaj tylko potrzebne sekcje
4. Użyj cross-references dla głębszego kontekstu
```

### Aktualizowanie Dokumentacji
```
1. Znajdź odpowiedni plik wg hierarchii BMAD
2. Zachowaj format i konwencje
3. Dodaj/zaktualizuj AI-INDEX jeśli trzeba
4. Linkuj do powiązanych dokumentów
```

---

## Migracja ze Starej Struktury

### Co Przeniesiono
| Stary plik | Nowa lokalizacja |
|------------|------------------|
| `ecosystem/prd.md` | `1-BASELINE/product/PRD-*.md` |
| `ecosystem/architecture.md` | `1-BASELINE/architecture/ARCH-*.md` |
| `modules/module-fitness/epics.md` | `2-MANAGEMENT/epics/epic-*.md` |
| `ecosystem/epics.md` | `2-MANAGEMENT/epics/epic-*.md` |
| `sprint-artifacts/` | `2-MANAGEMENT/backlog/` + `5-ARCHIVE/` |

### Co Zarchiwizowano
- Stare sesje brainstormingu → `5-ARCHIVE/historical/`
- Deprecated pliki → `5-ARCHIVE/deprecated/`

---

*BMAD Framework v2.0 - Optimized for AI + Human collaboration*
