# LifeOS / GymApp - AI Assistant Guide

> Ten plik pomaga AI (Claude, GPT, etc.) efektywnie pracować z projektem.

## Quick Facts

| Aspect | Value |
|--------|-------|
| **Nazwa** | LifeOS (package: lifeos) |
| **Typ** | Flutter mobile app (iOS + Android) |
| **Architektura** | Clean Architecture + Riverpod |
| **Baza danych** | Drift (SQLite) + Supabase |
| **Status** | MVP 1.0 in progress (~45% complete) |

---

## 📁 Documentation Index

### Gdzie szukać informacji?

```
docs/
├── 00-START-HERE.md          ← ZACZNIJ TUTAJ (entry point)
├── BMAD-STRUCTURE.md         ← Jak zorganizowana jest dokumentacja
│
├── 1-BASELINE/               ← WYMAGANIA I ARCHITEKTURA
│   ├── product/
│   │   ├── PRD-overview.md        ← Executive summary, success criteria
│   │   ├── PRD-fitness-requirements.md   ← FR30-FR46
│   │   ├── PRD-life-coach-requirements.md ← FR6-FR29
│   │   ├── PRD-mind-requirements.md      ← FR47-FR76
│   │   └── PRD-nfr.md             ← Non-functional requirements
│   └── architecture/
│       ├── ARCH-overview.md       ← Tech stack, decisions D1-D13
│       ├── ARCH-database-schema.md ← Drift tables, Supabase
│       ├── ARCH-ai-infrastructure.md ← AI prompts, CMI
│       └── ARCH-security.md       ← E2EE, GDPR, RLS
│
├── 2-MANAGEMENT/             ← EPICS, STATUS, TODO
│   ├── project-status.md     ← AKTUALNY STATUS PROJEKTU
│   ├── MVP-AUDIT-REPORT.md   ← Audit kodu vs dokumentacji
│   ├── MVP-TODO.md           ← Master TODO list
│   ├── MVP-SCOPE-ANALYSIS.md ← Analiza scope MVP 1.0
│   └── epics/
│       ├── epic-1-core-platform.md
│       ├── epic-2-life-coach.md
│       ├── epic-3-fitness.md
│       ├── epic-4-mind.md
│       ├── epic-5-cross-module.md
│       ├── epic-6-gamification.md
│       ├── epic-7-onboarding-subscriptions.md
│       ├── epic-8-notifications.md
│       └── epic-9-settings.md
│
├── 4-DEVELOPMENT/            ← DEVELOPER GUIDES
│   └── setup/QUICK-START-5MIN.md
│
└── 5-ARCHIVE/                ← STARA DOKUMENTACJA (nie używać)
```

### Szybkie linki

| Pytanie | Plik |
|---------|------|
| Co to za projekt? | `docs/00-START-HERE.md` |
| Jaki jest aktualny status? | `docs/2-MANAGEMENT/project-status.md` |
| Co zostało do zrobienia? | `docs/2-MANAGEMENT/MVP-TODO.md` |
| Jakie są wymagania modułu X? | `docs/1-BASELINE/product/PRD-*.md` |
| Jak działa baza danych? | `docs/1-BASELINE/architecture/ARCH-database-schema.md` |
| Szczegóły story Y? | `docs/2-MANAGEMENT/epics/epic-*.md` |

---

## 🏗️ Code Structure

```
lib/
├── main.dart                 ← Entry point
├── core/                     ← Shared infrastructure
│   ├── ai/                   ← AI service (OpenAI, prompts)
│   ├── auth/                 ← Supabase auth
│   ├── database/             ← Drift tables & providers
│   ├── sync/                 ← Offline sync (partial)
│   ├── router/               ← GoRouter navigation
│   └── theme/                ← App theme
│
└── features/                 ← Feature modules
    ├── fitness/              ← 🏋️ ~90% complete
    │   ├── data/             ← Repositories, models
    │   ├── domain/           ← Entities, use cases
    │   └── presentation/     ← Pages, providers, widgets
    │
    ├── life_coach/           ← 🎯 ~75% complete
    │   ├── ai/               ← Daily plan generator
    │   ├── chat/             ← AI coaching chat
    │   ├── goals/            ← Goal suggestions
    │   ├── data/             ← Repositories
    │   ├── domain/           ← Entities, use cases
    │   └── presentation/     ← Pages, providers
    │
    ├── mind_emotion/         ← 🧘 ~25% complete
    │   ├── data/             ← Meditation repos
    │   ├── domain/           ← Entities
    │   └── presentation/     ← Library screen (player TODO)
    │
    ├── exercise/             ← 📚 ~20% (no persistence)
    ├── settings/             ← ⚙️ ~25% (basic)
    └── onboarding/           ← 👋 ~5% (placeholder)
```

---

## 📜 Documentation Rules

### Kiedy aktualizować dokumentację?

| Trigger | Akcja |
|---------|-------|
| Nowa funkcja zaimplementowana | Update `project-status.md` |
| Story ukończone | Update epic file (status: ✅ Done) |
| Nowy bug/issue | Dodaj do `MVP-TODO.md` |
| Zmiana architektury | Update `ARCH-*.md` |
| Nowe wymagania | Update `PRD-*.md` |

### Jak aktualizować?

1. **project-status.md** - Zmień procenty w tabelach
2. **epic-X.md** - Zmień status story (⏳ Planned → 🔄 In Progress → ✅ Done)
3. **MVP-TODO.md** - Zmień ❌ na ✅ dla ukończonych tasków

### Format AI-INDEX

Każdy plik MD powinien mieć komentarz AI-INDEX:
```markdown
<!-- AI-INDEX: keyword1, keyword2, keyword3 -->
```
To pomaga AI szybko znaleźć odpowiedni plik.

---

## ⚠️ Known Issues (Stan na 2025-12-02)

### KRYTYCZNE

1. **Provider Conflict** - `daily_plan_provider.dart` używa MockGoalsRepository
   - Fix: Zamień na GoalsRepositoryImpl
   - Plik: `lib/features/life_coach/ai/providers/daily_plan_provider.dart`

2. **Hardcoded User IDs** - W meditation_providers.dart
   - `userId: 'current_user_id'` - powinno być z auth provider
   - Plik: `lib/features/mind_emotion/presentation/providers/meditation_providers.dart`

### Do zrobienia

- Meditation Player screen (nie istnieje)
- Breathing exercises screen (nie istnieje)
- Exercise library persistence (brak Drift tables)

---

## 🚀 MVP 1.0 Scope

### In Scope
- ✅ Auth (email)
- ✅ Fitness (full)
- ✅ Life Coach (daily plan, check-ins, goals, chat)
- 🔄 Mind (mood in check-in, meditation player, breathing)
- 🔄 Basic settings

### Out of Scope (MVP 1.1)
- ❌ Onboarding flow
- ❌ IAP/Subscriptions
- ❌ Push notifications
- ❌ Cross-Module Intelligence
- ❌ Social features

---

## 🔧 Tech Stack Quick Reference

| Layer | Technology |
|-------|------------|
| UI | Flutter 3.x, Material 3 |
| State | Riverpod 3.0 (riverpod_annotation) |
| Database | Drift (SQLite) |
| Backend | Supabase (Auth, PostgreSQL, Storage) |
| AI | OpenAI API (gpt-4o-mini) |
| Navigation | GoRouter |
| Charts | fl_chart |
| Audio | just_audio (not integrated yet) |

---

## 📝 Conventions

### File Naming
```
feature_name/
├── data/
│   ├── models/         → feature_model.dart
│   ├── repositories/   → feature_repository_impl.dart
│   └── datasources/    → feature_datasource.dart
├── domain/
│   ├── entities/       → feature_entity.dart
│   ├── repositories/   → feature_repository.dart (interface)
│   └── usecases/       → verb_noun_usecase.dart
└── presentation/
    ├── pages/          → feature_page.dart
    ├── providers/      → feature_provider.dart
    └── widgets/        → feature_widget.dart
```

### Commit Messages
```
feat: Add meditation player screen
fix: Resolve provider conflict in daily_plan_provider
docs: Update project status after Epic 3 completion
refactor: Extract breathing animation to separate widget
```

---

## 🤖 AI Instructions

### Przed rozpoczęciem pracy:
1. Przeczytaj `docs/2-MANAGEMENT/project-status.md` - aktualny stan
2. Przeczytaj `docs/2-MANAGEMENT/MVP-TODO.md` - co zostało do zrobienia
3. Sprawdź odpowiedni epic file dla szczegółów story

### Po zakończeniu pracy:
1. Update `project-status.md` jeśli zmienił się % completion
2. Update epic file jeśli story zostało ukończone
3. Update `MVP-TODO.md` - oznacz task jako ✅
4. Commit z opisowym message

### Jeśli tworzysz nowy plik:
1. Dodaj AI-INDEX comment na początku
2. Śledź naming conventions
3. Użyj Clean Architecture pattern
4. Dodaj do odpowiedniego folderu

---

## 📞 Quick Commands

```bash
# Run app
flutter run

# Generate Drift code
dart run build_runner build

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

*Ostatnia aktualizacja: 2025-12-02*
