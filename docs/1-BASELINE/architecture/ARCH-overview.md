# LifeOS Architecture - Overview

<!-- AI-INDEX: architecture, overview, decisions, tech-stack, system-design, flutter, supabase, riverpod -->

**Wersja:** 2.0
**Status:** ✅ Zatwierdzona do implementacji

---

## Spis Treści

1. [Executive Summary](#1-executive-summary)
2. [Kluczowe Decyzje Architektoniczne](#2-kluczowe-decyzje-architektoniczne)
3. [High-Level Architecture](#3-high-level-architecture)
4. [Tech Stack](#4-tech-stack)
5. [Project Structure](#5-project-structure)
6. [NFR Validation](#6-nfr-validation)
7. [Powiązane Dokumenty](#7-powiązane-dokumenty)

---

## 1. Executive Summary

### Przegląd Projektu

**LifeOS** (Life Operating System) to modułowy ekosystem aplikacji mobilnej z 3 modułami MVP:
- **Life Coach AI** (FREE) - daily planner, konwersacyjny coach
- **Fitness Coach AI** (2.99 EUR/mies.) - tracking treningów, Smart Pattern Memory
- **Mind & Emotion** (2.99 EUR/mies.) - medytacje, mood tracking, journaling

**Killer Feature:** Cross-Module Intelligence - system analizy korelacji między modułami.

### Kluczowe Metryki

| Aspekt | Target | Architektura |
|--------|--------|--------------|
| **Performance** | App launch <2s, offline <100ms | ✅ Write-through cache, Drift |
| **Security** | E2EE dla wrażliwych danych | ✅ AES-256-GCM client-side |
| **Scalability** | 10k concurrent, <500 EUR/10k | ✅ Supabase, CDN |
| **Battery** | <5% w 8h | ✅ Opportunistic sync |
| **Coverage** | 123 FRs, 37 NFRs | ✅ 100% |

---

## 2. Kluczowe Decyzje Architektoniczne

### Critical Decisions (D1-D5)

| ID | Decyzja | Wybór | Uzasadnienie |
|----|---------|-------|--------------|
| **D1** | Modular Architecture | Hybrid (features/ + clean arch) | Skalowalność + separation |
| **D2** | Cross-Module Data | Shared PostgreSQL + Drift mirror | CMI + offline-first |
| **D3** | Offline Sync | Write-Through Cache + Sync Queue | <100ms response |
| **D4** | AI Orchestration | Supabase Edge Functions | Security + cost control |
| **D5** | E2EE | Client-Side AES-256-GCM | Privacy dla journali |

### Important Decisions (D6-D13)

| ID | Decyzja | Wybór |
|----|---------|-------|
| **D6** | Provider Structure | Feature-First z clean naming |
| **D7** | Database Schema | Shared Core + Module Extensions |
| **D8** | API Layer | Hybrid (CRUD + Edge Functions) |
| **D9** | Theme Switching | Auto-switching per module |
| **D10** | Feature Flags | Enum-Based Feature Gates |
| **D11** | Background Sync | Opportunistic (lifecycle triggers) |
| **D12** | Push Notifications | Firebase Cloud Messaging (FCM) |
| **D13** | Caching | Tiered Lazy Loading + LRU |

### D1: Modular Architecture Pattern

**Struktura:**
```
lib/features/
  life_coach/
    presentation/  # UI (screens, widgets, providers)
    domain/        # Business logic (models, use cases)
    data/          # Data sources (local, remote, DTOs)
  fitness/
  mind/
  cross_module_intelligence/
```

**Uzasadnienie:**
- Feature isolation dla niezależnych modułów
- Clean architecture zapewnia testability
- Łatwe dodawanie nowych modułów (Phase 2)

### D3: Offline-First Sync Strategy

**Mechanizm:**
1. **Write:** Save to Drift (local) → instant feedback
2. **Queue:** Priority-based sync queue
3. **Sync:** Opportunistic (WiFi preferred, retry on failure)

**Conflict resolution:** Last-write-wins based on timestamp

### D4: AI Orchestration

**Flow:**
```
Flutter App → Supabase Edge Function → Route based on tier
                                      ↓
                Free tier → Llama 3 (self-hosted)
                Standard → Claude (Anthropic API)
                Premium → GPT-4 (OpenAI API)
```

**Korzyści:**
- API keys never exposed to client
- Server-side quota enforcement
- Model changes without app update

---

## 3. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App (iOS/Android)                 │
├─────────────────────────────────────────────────────────────────┤
│  Presentation Layer (Riverpod + Material 3)                     │
│  ┌─────────────┬─────────────┬─────────────┬──────────────┐    │
│  │ Life Coach  │   Fitness   │    Mind     │  CMI         │    │
│  │   Module    │   Module    │   Module    │  Dashboard   │    │
│  └─────────────┴─────────────┴─────────────┴──────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│  Domain Layer (Use Cases + Business Logic)                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ GenerateDailyPlanUseCase  │  StartWorkoutUseCase        │  │
│  │ DetectPatternsUseCase     │  PlayMeditationUseCase      │  │
│  └──────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer (Repositories + Data Sources)                       │
│  ┌──────────────────┬───────────────────────────────────────┐  │
│  │ Drift (SQLite)   │  Supabase (PostgreSQL + Realtime)    │  │
│  │ Offline-First    │  Cloud Sync + RLS                     │  │
│  └──────────────────┴───────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                               ▲ ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Supabase Backend (Cloud)                     │
├─────────────────────────────────────────────────────────────────┤
│  Edge Functions (Deno)                                          │
│  ┌──────────────────┬──────────────────┬───────────────────┐   │
│  │ AI Orchestrator  │ Generate Plan    │ Analyze Metrics   │   │
│  │ (Llama/Claude/   │ (GPT-4/Claude)   │ (Pattern Detect)  │   │
│  │  GPT-4 routing)  │                  │                   │   │
│  └──────────────────┴──────────────────┴───────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL Database + RLS Policies                             │
│  Auth (Email, Google, Apple) + Storage (CDN)                    │
└─────────────────────────────────────────────────────────────────┘
                               ▲ ▼
┌─────────────────────────────────────────────────────────────────┐
│                    External Services                             │
├─────────────────────────────────────────────────────────────────┤
│  Firebase Cloud Messaging (FCM) - Push Notifications            │
│  Stripe - Payment Processing                                    │
│  Posthog - Analytics & Telemetry                                │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow - Complete Workout Example

```
1. User taps "Complete Workout"
   ↓
2. Riverpod Provider: workoutProvider.completeWorkout()
   ↓
3. Use Case: CompleteWorkoutUseCase.call()
   ↓
4. Repository: FitnessRepository.saveWorkout()
   ↓
5. Drift insert → workouts table
   ✅ INSTANT feedback (<100ms)
   ↓
6. Sync Queue: Add (priority: HIGH)
   ↓
7. Opportunistic sync (WiFi available)
   ↓
8. Supabase insert → workouts table
   ↓
9. Metrics Aggregation → user_daily_metrics
   ↓
10. CMI Pattern Detection (weekly)
    ↓
11. AI Edge Function → Generate insight
    ↓
12. FCM → Push notification
```

---

## 4. Tech Stack

### Frontend (Flutter)

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.38+ | Cross-platform (iOS, Android) |
| **Dart** | 3.10+ | Programming language |
| **Riverpod** | 3.0+ | State management |
| **Drift** | Latest | Local SQLite ORM |
| **freezed** | Latest | Immutable models |
| **go_router** | Latest | Routing + deep linking |
| **flutter_secure_storage** | Latest | Encrypted storage |

### Backend (Supabase)

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Database** | PostgreSQL 17+ | Primary data store + RLS |
| **Realtime** | Supabase Realtime | WebSocket subscriptions |
| **Auth** | Supabase Auth | Email, Google, Apple |
| **Storage** | Supabase Storage | Media files + CDN |
| **Edge Functions** | Deno | AI orchestration |

### External Services

| Service | Purpose | Cost |
|---------|---------|------|
| **FCM** | Push notifications | Free |
| **Stripe** | Payments | 2.9% + €0.30 |
| **Posthog** | Analytics | Free tier |
| **Claude** | AI (standard) | $0.003/call |
| **GPT-4** | AI (premium) | $0.01/call |
| **Llama 3** | AI (free tier) | Self-hosted |

---

## 5. Project Structure

```
lifeos/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                          # Shared utilities
│   │   ├── auth/
│   │   ├── sync/                      # Offline-first sync (D3)
│   │   ├── cache/                     # Tiered cache (D13)
│   │   ├── database/                  # Drift local DB
│   │   ├── api/                       # Supabase client
│   │   ├── ai/                        # AI service layer (D4)
│   │   ├── subscription/              # Feature gates (D10)
│   │   ├── notifications/             # FCM (D12)
│   │   ├── theme/                     # Adaptive themes (D9)
│   │   ├── error/                     # Result<T> pattern
│   │   ├── logging/
│   │   ├── utils/
│   │   ├── routing/
│   │   └── widgets/
│   │
│   ├── features/                      # Feature modules (D1)
│   │   ├── onboarding/
│   │   ├── life_coach/
│   │   │   ├── presentation/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── fitness/
│   │   ├── mind/
│   │   ├── cross_module_intelligence/
│   │   ├── goals/
│   │   ├── subscription/
│   │   └── settings/
│   │
│   └── generated/
│
├── test/                              # Unit + Widget tests
├── integration_test/                  # E2E tests
├── supabase/
│   ├── functions/                     # Edge Functions
│   └── migrations/                    # PostgreSQL schema
├── assets/
├── l10n/                              # i18n (PL, EN)
└── pubspec.yaml
```

### Epic to Directory Mapping

| Epic | Directory |
|------|-----------|
| Epic 1: Core Platform | `features/onboarding/` |
| Epic 2: Life Coach | `features/life_coach/` |
| Epic 3: Fitness | `features/fitness/` |
| Epic 4: Mind | `features/mind/` |
| Epic 5: CMI | `features/cross_module_intelligence/` |
| Epic 6: Gamification | `features/goals/` |
| Epic 7: Subscriptions | `features/subscription/` |
| Epic 8: Notifications | `core/notifications/` |
| Epic 9: Settings | `features/settings/` |

---

## 6. NFR Validation

### Performance (NFR-P1-P6)

| NFR | Target | Solution | Status |
|-----|--------|----------|--------|
| P1 | App size <50MB | Tiered cache, 15MB bundled | ✅ |
| P2 | Cold start <2s | Flutter skeleton, minimal init | ✅ |
| P4 | Offline <100ms | Write-through cache, Drift | ✅ |
| P5 | UI response <100ms | Riverpod optimistic updates | ✅ |
| P6 | Battery <5% in 8h | Opportunistic sync | ✅ |

### Security (NFR-S1-S3)

| NFR | Target | Solution | Status |
|-----|--------|----------|--------|
| S1 | E2EE journals | AES-256-GCM client-side | ✅ |
| S2 | GDPR | RLS, export/delete endpoints | ✅ |
| S3 | Multi-device | Supabase Realtime, last-write-wins | ✅ |

### Cost (NFR-SC4)

| Component | 10k users | % Revenue |
|-----------|-----------|-----------|
| Supabase | €0 (free tier) | 0% |
| AI API (CMI) | €360/month | 3.6% |
| Stripe fees | €290/month | 2.9% |
| **Total** | **€650/month** | **6.5%** ✅ |

---

## 7. Powiązane Dokumenty

### Architecture Details

| Dokument | Zawartość |
|----------|-----------|
| [ARCH-database-schema.md](./ARCH-database-schema.md) | Database schema, RLS, Drift |
| [ARCH-ai-infrastructure.md](./ARCH-ai-infrastructure.md) | AI orchestration, CMI |
| [ARCH-security.md](./ARCH-security.md) | E2EE, GDPR, security |

### Product

| Dokument | Zawartość |
|----------|-----------|
| [PRD-overview.md](../product/PRD-overview.md) | Product requirements |
| [PRD-nfr.md](../product/PRD-nfr.md) | Non-functional requirements |

### Development

| Dokument | Zawartość |
|----------|-----------|
| [QUICK-START-5MIN.md](../../4-DEVELOPMENT/setup/QUICK-START-5MIN.md) | Quick start guide |
| [clean-architecture.md](../../4-DEVELOPMENT/patterns/clean-architecture.md) | Clean arch patterns |

---

*13 Architectural Decisions | 123 FRs covered | 37 NFRs satisfied*
