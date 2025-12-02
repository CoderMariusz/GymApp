# DOCUMENTATION-TEMPLATE

> Generyczny szablon do przebudowy dokumentacji projektu.
> Kompatybilny z BMAD Method V6 + optymalizacja dla AI-assisted development.

---

## Spis Treści

1. [Overview](#1-overview)
2. [Proces Przebudowy](#2-proces-przebudowy)
3. [Struktura docs/ (BMAD V6)](#3-struktura-docs-bmad-v6)
4. [Struktura .claude/](#4-struktura-claude)
5. [Template CLAUDE.md](#5-template-claudemd)
6. [Multi-Model Workflow](#6-multi-model-workflow)
7. [Checklisty](#7-checklisty)

---

## 1. Overview

### Cel

Stworzyć dokumentację która:
- Jest **szybka do przeczytania** przez AI (mniej tokenów = szybsze odpowiedzi)
- **Nie wymaga Glob/Grep** dla standardowych operacji
- Jest **kompatybilna z BMAD v6** (fazy, epics, stories)
- Wspiera **multi-model workflow** (różne modele do różnych zadań)

### Wynik końcowy

```
projekt/
├── CLAUDE.md                 ← Entry point dla AI (zawsze ładowany)
├── .claude/
│   ├── FILE-MAP.md           ← Index plików projektu
│   ├── TABLES.md             ← Schema bazy danych (skrócone)
│   ├── PATTERNS.md           ← Wzorce kodu
│   └── PROMPTS.md            ← Szablony promptów
│
└── docs/                     ← BMAD-compatible dokumentacja
    ├── 00-START-HERE.md      ← Entry point dla człowieka
    ├── BMAD-STRUCTURE.md     ← Jak zorganizowana jest dokumentacja
    │
    ├── 1-BASELINE/           ← Wymagania i architektura
    │   ├── product/          ← PRD, requirements
    │   └── architecture/     ← Tech decisions, schema
    │
    ├── 2-MANAGEMENT/         ← Status, TODO, epics
    │   ├── project-status.md
    │   ├── MVP-TODO.md
    │   └── epics/
    │
    ├── 3-ARCHITECTURE/       ← Szczegółowa architektura (opcjonalne)
    ├── 4-DEVELOPMENT/        ← Developer guides
    └── 5-ARCHIVE/            ← Stara/deprecated dokumentacja
```

---

## 2. Proces Przebudowy

### Krok 1: Analiza obecnej dokumentacji

```
Przeanalizuj obecną dokumentację projektu:

1. Jakie pliki dokumentacji istnieją?
2. Jakie są główne sekcje?
3. Co jest aktualne, a co przestarzałe?
4. Czy są epics/stories? W jakim formacie?

Wynik: Lista plików + ich status (aktualne/do aktualizacji/do archiwizacji)
```

### Krok 2: Ekstrakcja kluczowych informacji

```
Z istniejącej dokumentacji wyciągnij:

1. QUICK FACTS (nazwa, typ, tech stack, status %)
2. CODE STRUCTURE (główne foldery, architektura)
3. KNOWN ISSUES (aktywne bugi, TODO)
4. DATABASE SCHEMA (tabele, relacje)
5. CONVENTIONS (nazewnictwo, patterns)
6. EPICS/STORIES (jeśli istnieją)
```

### Krok 3: Stwórz CLAUDE.md

Użyj [Template CLAUDE.md](#5-template-claudemd) poniżej.

### Krok 4: Stwórz pliki .claude/

| Plik | Źródło danych | Instrukcje |
|------|---------------|------------|
| FILE-MAP.md | Struktura `lib/` lub `src/` | Glob all files, categorize by type |
| TABLES.md | Schema DB, migrations | Extract table names + key fields |
| PATTERNS.md | Istniejący kod | Identify recurring patterns |
| PROMPTS.md | Workflow projektu | Create task-specific prompts |

### Krok 5: Przebuduj docs/ na strukturę BMAD

Przenieś istniejące pliki do odpowiednich folderów:

| Zawartość | Cel |
|-----------|-----|
| PRD, requirements, specs | `1-BASELINE/product/` |
| Architecture, schema, decisions | `1-BASELINE/architecture/` |
| Status, TODO, roadmap | `2-MANAGEMENT/` |
| Epics, stories | `2-MANAGEMENT/epics/` |
| Setup guides, tutorials | `4-DEVELOPMENT/` |
| Stare/nieaktualne | `5-ARCHIVE/` |

### Krok 6: Walidacja

```
Sprawdź:
- [ ] CLAUDE.md ładuje się poprawnie
- [ ] FILE-MAP.md zawiera wszystkie key files
- [ ] TABLES.md pokrywa aktywne tabele
- [ ] PATTERNS.md ma wzorce dla głównych operacji
- [ ] docs/ ma czytelną strukturę
```

---

## 3. Struktura docs/ (BMAD V6)

### Kompatybilność z BMAD Phases

| BMAD Phase | Folder docs/ | Zawartość |
|------------|--------------|-----------|
| Phase 1: Analysis | `1-BASELINE/product/` | Research, briefs |
| Phase 2: Planning | `1-BASELINE/product/` | PRD, requirements |
| Phase 3: Solutioning | `1-BASELINE/architecture/` | Architecture, design |
| Phase 4: Implementation | `2-MANAGEMENT/epics/` | Stories, status |

### Format Epic (BMAD-compatible)

```markdown
# Epic {N}: {Nazwa}

## Overview
{Krótki opis epica}

## Stories

### Story {N}.1: {Nazwa}
**Status:** ⏳ Planned | 🔄 In Progress | ✅ Done | ❌ Blocked

**As a** {user type}
**I want** {action}
**So that** {benefit}

**Acceptance Criteria:**
- [ ] {AC1}
- [ ] {AC2}

**Technical Notes:**
- {implementation details}

**Dependencies:**
- Story {X}.{Y}
```

### Format project-status.md

```markdown
# Project Status

## Quick Stats
| Metric | Value |
|--------|-------|
| Overall Progress | XX% |
| Current Sprint | Sprint N |
| Blockers | X |

## Module Progress
| Module | Status | % |
|--------|--------|---|
| Auth | ✅ Done | 100% |
| Feature A | 🔄 In Progress | 60% |
| Feature B | ⏳ Planned | 0% |

## Current Focus
- [ ] Task 1
- [ ] Task 2

## Blockers
1. {Blocker description}
```

---

## 4. Struktura .claude/

### FILE-MAP.md Template

```markdown
# FILE-MAP

## Pages/Screens
| Page | Path | Description |
|------|------|-------------|
| HomePage | `src/pages/home.tsx` | Main dashboard |

## Components
| Component | Path | Description |
|-----------|------|-------------|
| Button | `src/components/Button.tsx` | Reusable button |

## API/Services
| Service | Path | Description |
|---------|------|-------------|
| AuthService | `src/services/auth.ts` | Authentication |

## Database/Models
| Model | Path | Description |
|-------|------|-------------|
| User | `src/models/user.ts` | User entity |

## Config
| File | Path | Description |
|------|------|-------------|
| env | `.env.example` | Environment vars |
```

### TABLES.md Template

```markdown
# TABLES

## Quick Reference
| Table | Key Fields | Relations |
|-------|------------|-----------|
| users | id, email, name | → posts, → comments |
| posts | id, userId, title | ← users, → comments |

## Table Details

### users
- id: UUID (PK)
- email: TEXT UNIQUE
- name: TEXT
- createdAt: TIMESTAMP

### posts
- id: UUID (PK)
- userId: UUID (FK → users)
- title: TEXT
- content: TEXT
```

### PATTERNS.md Template

```markdown
# PATTERNS

## Component Pattern
\`\`\`{language}
// Standard component structure
{code example}
\`\`\`

## API Pattern
\`\`\`{language}
// Standard API endpoint
{code example}
\`\`\`

## State Management Pattern
\`\`\`{language}
// Standard state handling
{code example}
\`\`\`

## Error Handling Pattern
\`\`\`{language}
// Standard error handling
{code example}
\`\`\`

## Naming Conventions
| Element | Format | Example |
|---------|--------|---------|
| File | kebab-case | `user-service.ts` |
| Class | PascalCase | `UserService` |
| Function | camelCase | `getUser()` |
```

### PROMPTS.md Template

```markdown
# PROMPTS

## 1. New Feature
\`\`\`
Create new feature: {NAME}
Requirements: {list}
Use patterns from PATTERNS.md
Update FILE-MAP.md after completion
\`\`\`

## 2. Fix Bug
\`\`\`
Fix bug: {DESCRIPTION}
Location: {file:line}
Expected: {behavior}
Actual: {behavior}
\`\`\`

## 3. Continue Work
\`\`\`
Continue work on project.
Read: project-status.md, MVP-TODO.md
Propose next tasks with priority.
\`\`\`
```

---

## 5. Template CLAUDE.md

```markdown
# {Project Name} - AI Assistant Guide

## Quick Facts

| Aspect | Value |
|--------|-------|
| **Name** | {project_name} |
| **Type** | {type: web app, mobile app, API, library} |
| **Stack** | {main technologies} |
| **Architecture** | {pattern: Clean Architecture, MVC, etc.} |
| **Database** | {database type} |
| **Status** | {current status, % complete} |

---

## Documentation Index

### .claude/ Files (AI-optimized)

| File | Purpose |
|------|---------|
| FILE-MAP.md | Index of all code files |
| TABLES.md | Database schema (condensed) |
| PATTERNS.md | Code patterns to follow |
| PROMPTS.md | Ready-to-use prompts |

### docs/ Structure

```
docs/
├── 00-START-HERE.md          ← Entry point
├── 1-BASELINE/               ← Requirements & Architecture
│   ├── product/              ← PRD, requirements
│   └── architecture/         ← Tech decisions
├── 2-MANAGEMENT/             ← Status & Tracking
│   ├── project-status.md     ← Current state
│   ├── MVP-TODO.md           ← Task list
│   └── epics/                ← Epic & story files
└── 4-DEVELOPMENT/            ← Developer guides
```

### Quick Links

| Question | File |
|----------|------|
| What is current status? | `docs/2-MANAGEMENT/project-status.md` |
| What's left to do? | `docs/2-MANAGEMENT/MVP-TODO.md` |
| Story details? | `docs/2-MANAGEMENT/epics/epic-*.md` |
| Database schema? | `.claude/TABLES.md` |
| Code patterns? | `.claude/PATTERNS.md` |

---

## Code Structure

```
{lib|src}/
├── {main_folder}/            ← Entry point
├── {core_folder}/            ← Shared infrastructure
│   ├── {subfolder}/          ← Description
│   └── {subfolder}/          ← Description
└── {features_folder}/        ← Feature modules
    ├── {feature_a}/          ← % complete
    └── {feature_b}/          ← % complete
```

---

## Known Issues

### Critical
1. **{Issue Title}** - {short description}
   - Location: `{file:line}`
   - Fix: {proposed fix}

### To Do
- {Item 1}
- {Item 2}

---

## Conventions

### File Naming
```
{pattern description}
```

### Commit Messages
```
{type}: {description}
Examples: feat:, fix:, docs:, refactor:
```

---

## AI Instructions

### Before starting work:
1. Read `project-status.md` - current state
2. Read `MVP-TODO.md` - remaining tasks
3. Check relevant epic file for story details

### After completing work:
1. Update `project-status.md` if % changed
2. Update epic file if story completed
3. Update `MVP-TODO.md` - mark tasks as done
4. Commit with descriptive message

### Creating new files:
1. Follow patterns from PATTERNS.md
2. Add to FILE-MAP.md
3. Use naming conventions

---

## Quick Commands

```bash
# {command description}
{command}

# {command description}
{command}
```

---

*Last updated: {date}*
```

---

## 6. Multi-Model Workflow

### Podział zadań między modele

| Zadanie | Model | Dlaczego |
|---------|-------|----------|
| **Planowanie, architektura** | Opus | Głęboka analiza, long-context |
| **Implementacja kodu** | Sonnet | Szybki, dokładny w kodzie |
| **Quick fixes, review** | Haiku | Najszybszy, tani |
| **Dokumentacja** | Sonnet/Opus | Zależnie od złożoności |

### Workflow Setup

```
1. OPUS: Analiza projektu, tworzenie CLAUDE.md
   ↓
2. OPUS: Przebudowa docs/, planowanie epics
   ↓
3. SONNET: Implementacja stories (per story fresh chat)
   ↓
4. HAIKU: Code review, quick fixes
   ↓
5. SONNET: Aktualizacja dokumentacji
```

### Fresh Chat Rule (BMAD)

> **KRYTYCZNE:** Używaj fresh chat dla każdego workflow żeby uniknąć halucynacji.

- Nowy chat dla każdego story
- Nowy chat po dużej zmianie kontekstu
- Zawsze zaczynaj od przeczytania CLAUDE.md

---

## 7. Checklisty

### Checklist: Nowy Projekt

- [ ] Stwórz CLAUDE.md z Quick Facts
- [ ] Stwórz strukturę docs/ (BMAD)
- [ ] Stwórz .claude/FILE-MAP.md
- [ ] Stwórz .claude/TABLES.md (jeśli ma DB)
- [ ] Stwórz .claude/PATTERNS.md
- [ ] Stwórz .claude/PROMPTS.md
- [ ] Dodaj AI-INDEX do kluczowych plików

### Checklist: Przebudowa Istniejącego Projektu

- [ ] Przeanalizuj obecną dokumentację
- [ ] Zidentyfikuj co jest aktualne/przestarzałe
- [ ] Stwórz CLAUDE.md z wyekstrahowanych danych
- [ ] Przenieś pliki do struktury docs/ BMAD
- [ ] Zarchiwizuj stare pliki w 5-ARCHIVE/
- [ ] Stwórz pliki .claude/
- [ ] Zwaliduj że wszystko działa

### Checklist: Story Implementation

- [ ] Fresh chat
- [ ] Przeczytaj CLAUDE.md
- [ ] Przeczytaj story w epic file
- [ ] Sprawdź dependencies
- [ ] Implementuj używając PATTERNS.md
- [ ] Zaktualizuj FILE-MAP.md (jeśli nowe pliki)
- [ ] Zaktualizuj epic file (status: ✅ Done)
- [ ] Zaktualizuj project-status.md
- [ ] Commit z opisowym message

---

## AI-INDEX Format

Każdy plik dokumentacji powinien mieć:

```markdown
<!-- AI-INDEX: keyword1, keyword2, keyword3 -->
```

Przykłady:
```markdown
<!-- AI-INDEX: authentication, login, oauth, security -->
<!-- AI-INDEX: database, schema, tables, migrations -->
<!-- AI-INDEX: epic, story, sprint, backlog -->
```

---

*Ten szablon jest generyczny - dostosuj do specyfiki swojego projektu i tech stacku.*
