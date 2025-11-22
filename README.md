# LifeOS - Your AI-Powered Operating System for Life

> **Status:** 🚧 Pre-Implementation - Sprint 0 Required
> **Phase:** Phase 2 Complete → Sprint 0 Database Schema Completion
> **Readiness:** 82% (100% after Sprint 0)

LifeOS is a modular life coaching ecosystem combining AI-powered coaching across three core modules to help users optimize their physical fitness, mental well-being, and life goals.

## 🎯 Vision

Transform your life with an AI-powered operating system that adapts to your needs, learns from your patterns, and provides personalized guidance across fitness, mental health, and life planning.

## 🏗️ Architecture

### Modules (MVP)

| Module | Price | Status | Description |
|--------|-------|--------|-------------|
| **Life Coach AI** | FREE | Planned | Daily planning, goal tracking, AI conversations (Llama 3) |
| **Fitness Coach AI** | €2.99/mo | Designed | Smart workout logging, training plans, AR form analysis |
| **Mind & Emotion** | €2.99/mo | Planned | Meditation, mood tracking, CBT, mental health screening |

### Killer Feature: Cross-Module Intelligence 🧠

AI-powered correlation detection between modules:
- "Your best workouts happen after 8+ hours sleep"
- "Stress drops 40% on days you work out"
- "High stress + heavy workout → suggest light session"

### Pricing Tiers

| Tier | Price | Features |
|------|-------|----------|
| **Free** | €0.00 | Life Coach (basic), 5 AI chats/day (Llama), Mood tracking |
| **Single Module** | €2.99/mo | Free + Mind OR Fitness, 10 AI chats/day (Claude) |
| **3-Module Pack** | €5.00/mo | All 3 modules, Cross-module insights, 20 AI chats/day |
| **LifeOS Plus** | €7.00/mo | Everything + Unlimited AI (GPT-4), Priority support |

All tiers include 14-day free trial.

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.38+ (iOS, Android)
- **Riverpod** 3.0+ (State management)
- **Drift** (SQLite local database)
- **go_router** (Navigation + deep linking)

### Backend
- **Supabase** (PostgreSQL, Auth, Realtime, Storage)
- **Edge Functions** (Deno - AI orchestration)
- **Row Level Security** (RLS policies)

### AI Integration
- **Hybrid Approach:**
  - Free tier: Llama 3 (self-hosted)
  - Standard: Claude (Anthropic API)
  - Premium: GPT-4 (OpenAI API)
- **Budget:** <30% of revenue

### Payments & Services
- **Stripe** (Subscriptions + payments)
- **Firebase Cloud Messaging** (Push notifications)
- **Posthog** (Analytics)

### Security
- **E2EE:** AES-256-GCM for journals + mental health data
- **RLS:** Row Level Security on all tables
- **GDPR:** Export/delete endpoints

---

## 📋 Current Status

### ✅ Completed (Phase 0-2)

- ✅ Discovery & Research (5 documents)
- ✅ PRD (123 FRs, 37 NFRs) - **100% validated**
- ✅ UX Design (2,115 lines) - **88% FR coverage**
- ✅ Architecture (13 decisions) - **98% validated**
- ✅ Test Design (523 tests planned)
- ✅ Security Architecture (E2EE, RLS, threat model)
- ✅ DevOps Strategy (CI/CD, environments)
- ✅ Implementation Readiness Analysis - **82% ready**

### 🔴 CRITICAL: Sprint 0 Required (Before Implementation)

**Status:** 🚨 **MUST COMPLETE BEFORE EPIC 1**

Sprint 0 adds 6 missing database tables + 2 Edge Functions required for UX features.

**See:** `docs/ecosystem/sprint-0-database-schema-completion.md`

**Effort:** 18-21 hours (1-2 weeks)
**Impact:** Blocks 38/123 FRs (31%)

**Missing Tables:**
1. `workout_templates` - Template creation/management (FR43-46)
2. `mental_health_screenings` - GAD-7/PHQ-9 results (FR66-70) **SAFETY CRITICAL**
3. `subscriptions` - Stripe integration (FR91-97)
4. `streaks` - Gamification (FR85-90)
5. `ai_conversations` - Chat history (FR18-24)
6. `mood_logs` - Mood tracking (FR55-60)

**Missing Edge Functions:**
1. `process-mental-health-screening` - Score calculation + crisis detection
2. `generate-workout-plan-from-template` - Template → Workout with Smart Pattern Memory

---

## 🚀 Quick Start

### Prerequisites

⚠️ **Before starting, you must have:**

| Tool | Version | Status | Install |
|------|---------|--------|---------|
| Flutter SDK | 3.38+ | ❌ Required | https://docs.flutter.dev/get-started/install |
| Dart | 3.10+ | ✅ With Flutter | Included |
| Android Studio | 2024.1+ | ❌ Required | https://developer.android.com/studio |
| Xcode | 15+ | ⚠️ iOS only | App Store (macOS) |
| Git | 2.30+ | ✅ Installed | - |
| Node.js | 18+ | ✅ 22.20.0 | - |
| Supabase CLI | Latest | ✅ 2.58.5 | - |

**Current System Check:**
- ✅ Git: 2.51.0
- ✅ Node.js: 22.20.0
- ✅ Supabase CLI: 2.58.5
- ❌ Flutter: Not installed
- ❌ Android Studio: Unknown

**Installation Time:** ~1.5-2 hours for Flutter + Android Studio

### Installation Steps

#### 1. Install Prerequisites (if needed)

**Flutter SDK (Windows):**
```powershell
# Option A: Chocolatey (recommended)
choco install flutter

# Option B: Manual
# Download from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\src\flutter
# Add C:\src\flutter\bin to PATH

# Verify
flutter --version
flutter doctor
```

**Android Studio:**
1. Download from https://developer.android.com/studio
2. Install with Android SDK
3. SDK Manager → Install: Android SDK Platform 34, Build-Tools 34, Emulator
4. Accept licenses: `flutter doctor --android-licenses`

#### 2. Clone Repository (when ready)

```bash
# Clone project
git clone https://github.com/YOUR_USERNAME/lifeos.git
cd lifeos
```

#### 3. Complete Sprint 0 (REQUIRED FIRST)

```bash
# Follow instructions in:
cat docs/ecosystem/sprint-0-database-schema-completion.md

# Sprint 0 Stories (18-21 hours):
# S0.1: workout_templates table (2-3h)
# S0.2: mental_health_screenings table (2-3h) - SAFETY CRITICAL
# S0.3: subscriptions table (2h)
# S0.4: streaks table (1-2h)
# S0.5: ai_conversations table (1-2h)
# S0.6: mood_logs table (2h)
# S0.7: Edge Functions (4-6h)
# S0.8: Drift mirror tables (2-3h)
```

#### 4. Complete Epic 0 Setup (After Sprint 0)

```bash
# Follow instructions in:
cat docs/ecosystem/epic-0-setup-infrastructure.md

# Epic 0 Stories (19-30 hours):
# 0.1: Flutter environment setup
# 0.2: Project initialization
# 0.3: Supabase backend setup
# 0.4: Firebase FCM configuration
# 0.5: Stripe integration
# 0.6: CI/CD pipeline
# 0.7: Test framework
# 0.8: Environment configuration
# 0.9: Local development (optional)
# 0.10: Documentation
```

#### 5. Run Application (After Epic 0)

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build

# Setup environment variables
cp .env.example .env
# Edit .env with your Supabase/Firebase/Stripe keys

# Run app
flutter run
```

---

## 📁 Project Structure

```
lifeos/
├── lib/
│   ├── main.dart
│   ├── core/                      # Shared utilities
│   │   ├── auth/                  # Authentication
│   │   ├── sync/                  # Offline-first sync
│   │   ├── cache/                 # Tiered cache
│   │   ├── database/              # Drift (SQLite)
│   │   ├── api/                   # Supabase client
│   │   ├── ai/                    # AI service layer
│   │   ├── subscription/          # Feature gates
│   │   ├── notifications/         # FCM service
│   │   ├── encryption/            # E2EE (AES-256-GCM)
│   │   └── ...
│   └── features/                  # Feature modules
│       ├── onboarding/
│       ├── life_coach/            # FREE module
│       ├── fitness/               # €2.99/mo module
│       ├── mind/                  # €2.99/mo module
│       ├── cross_module_intelligence/  # Killer feature
│       ├── goals/                 # Gamification
│       ├── subscription/          # Paywalls
│       └── settings/
├── test/                          # Unit + Widget tests
├── integration_test/              # E2E tests
├── supabase/
│   ├── functions/                 # Edge Functions (Deno)
│   └── migrations/                # PostgreSQL schema
├── docs/
│   ├── ecosystem/                 # Project documentation
│   │   ├── prd.md                 # 123 FRs, 37 NFRs
│   │   ├── architecture.md        # 13 decisions
│   │   ├── ux-design-specification.md  # 2,115 lines
│   │   ├── epics.md               # 9 epics, 66 stories
│   │   ├── sprint-0-database-schema-completion.md  # 🔴 START HERE
│   │   ├── epic-0-setup-infrastructure.md
│   │   └── ...
│   └── modules/                   # Module-specific docs
│       └── module-fitness/        # 100% planned (43 SP)
└── ...
```

---

## 📖 Documentation

### Core Documentation (Phase 0-2)

| Document | Lines | Description | Status |
|----------|-------|-------------|--------|
| **prd.md** | 1,020 | Product requirements (123 FRs, 37 NFRs) | ✅ Validated 100% |
| **architecture.md** | 1,296 | System architecture (13 decisions) | ✅ Validated 98% |
| **ux-design-specification.md** | 2,115 | Complete UX design (16 sections) | ✅ 88% FR coverage |
| **epics.md** | 2,642 | 9 epics, 66 stories, FR traceability | ✅ Complete |
| **test-design-system.md** | - | 523 tests, 660h effort | ✅ Complete |

### Validation Reports (NEW - 2025-01-16)

| Report | Score | Status |
|--------|-------|--------|
| **prd-validation-report** | 116/116 (100%) | ✅ All FRs covered |
| **architecture-validation-report** | 99/101 (98%) | ✅ Production-ready |
| **ux-validation-report** | 108/123 (88%) | ✅ MVP-ready |
| **implementation-readiness-report** | 82% | ⚠️ Sprint 0 required |

### Implementation Guides

| Guide | Effort | Status |
|-------|--------|--------|
| **sprint-0-database-schema-completion.md** | 18-21h | 🔴 **START HERE** |
| **epic-0-setup-infrastructure.md** | 19-30h | ✅ Ready (after Sprint 0) |

---

## 🧪 Testing

### Test Strategy (70/20/10 Pyramid)

- **70% Unit Tests:** Use cases, repositories, services
- **20% Widget Tests:** UI components, state management
- **10% Integration Tests:** End-to-end flows

### Running Tests

```bash
# Unit tests
flutter test

# Unit tests with coverage
flutter test --coverage

# Integration tests (requires emulator)
flutter test integration_test/

# Specific test file
flutter test test/unit/core/encryption_test.dart
```

### Test Coverage Goal

- **Overall:** >80%
- **Critical paths:** >90% (auth, sync, payments, mental health)

---

## 🔒 Security

### Encryption (E2EE)

- **Algorithm:** AES-256-GCM
- **Encrypted Data:**
  - Journal entries
  - Mental health screening answers
  - CBT chat logs
- **Key Storage:** flutter_secure_storage (iOS Keychain, Android KeyStore)

### Row Level Security (RLS)

All Supabase tables enforce RLS:
- Users can only access their own data
- Service role can update subscriptions (Stripe webhooks)
- Public templates viewable by all

### GDPR Compliance

- Export data: JSON format
- Delete data: Cascade delete with confirmation
- Consent management: Explicit opt-in

---

## 🎨 Design System

### Colors

- **Deep Blue** (#1E3A8A) - Primary brand color
- **Energetic Teal** (#14B8A6) - CTAs, success states
- **Orange** (#F97316) - Fitness module accent
- **Purple** (#A855F7) - Mind module accent

### Typography

- **Headings:** SF Pro Display (iOS), Roboto (Android)
- **Body:** SF Pro Text / Roboto
- **Monospace:** SF Mono / Roboto Mono (code, data)

### UX Principles

1. **Speed** - Offline-first, <100ms interactions
2. **Simplicity** - Max 3 taps to any feature
3. **Personality** - Conversational AI, not robotic
4. **Delight** - Micro-animations, haptic feedback
5. **Intelligence** - Cross-module insights (killer feature)

---

## 🚢 Deployment

### Environments

- **Development:** Local Supabase + test Stripe
- **Staging:** Supabase staging + test Stripe
- **Production:** Supabase production + live Stripe

### CI/CD (GitHub Actions)

- **On PR:** Run tests, analyze code, check coverage
- **On merge to main:** Build APK, deploy to TestFlight/Internal Testing
- **On tag (v*):** Build release, deploy to App Store/Play Store

---

## 📊 Project Metrics

### Scope

- **Total FRs:** 123 (88% have UX design)
- **Total NFRs:** 37 (100% satisfied)
- **Epics:** 9
- **Stories:** 66
- **Test Cases:** 523 planned

### Effort Estimates

| Phase | Effort | Status |
|-------|--------|--------|
| Sprint 0 | 18-21h | 🔴 REQUIRED |
| Epic 0 | 19-30h | ⏸️ After Sprint 0 |
| Epic 1 | 40-60h | ⏸️ Core Platform |
| Epic 2-9 | 400-600h | ⏸️ Feature Implementation |
| **Total MVP** | **~500-700h** | ⏸️ 3-6 months |

### Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| AI costs too high | High | Critical | Hybrid AI (Llama/Claude/GPT-4), usage quotas |
| Scope too large | Medium | High | Defer Mind module to v1.1 if needed |
| Privacy concerns | Medium | Critical | E2EE, RLS, GDPR compliance, legal review |
| Battery drain | Low | Medium | Opportunistic sync, WiFi-preferred |

---

## 🤝 Contributing

> **Note:** Project is currently in pre-implementation phase. Contributions will be accepted after Sprint 0 + Epic 0 complete.

### Development Workflow (Future)

1. Create feature branch from `main`
2. Make changes
3. Run tests: `flutter test`
4. Commit with conventional commits: `feat: add workout templates`
5. Push and create PR

### Code Style

- Use `flutter analyze` before committing
- Follow Dart style guide
- Write tests for new features (70/20/10 pyramid)
- Add documentation for public APIs

---

## 📝 License

**Proprietary** - All rights reserved

---

## 🙏 Credits

- **Architecture:** BMAD Method (Business Modular AI Development)
- **UX Design:** Nike + Headspace fusion aesthetic
- **AI:** Claude (Anthropic), GPT-4 (OpenAI), Llama 3 (Meta)

---

## 📞 Support

- **Issues:** GitHub Issues (after public release)
- **Documentation:** `docs/ecosystem/` folder
- **Email:** [TBD]

---

## 🗺️ Roadmap

### Phase 0: Pre-Implementation (CURRENT)

- ✅ Discovery & Research
- ✅ Planning (PRD, UX, Epics)
- ✅ Solutioning (Architecture, Tests, Security)
- ✅ Validation (100% PRD, 98% Architecture, 88% UX)
- 🔴 **Sprint 0: Database Schema Completion** ⬅️ **START HERE**
- ⏸️ Epic 0: Setup & Infrastructure

### Phase 1: MVP Development (3-6 months)

- Epic 1: Core Platform Foundation
- Epic 2: Life Coach MVP
- Epic 3: Fitness Coach MVP (leverages GymApp planning)
- Epic 4: Mind & Emotion MVP
- Epic 5: Cross-Module Intelligence (killer feature)
- Epic 6: Gamification
- Epic 7: Onboarding & Subscriptions
- Epic 8: Notifications
- Epic 9: Settings & Profile

### Phase 2: Post-MVP (6-12 months)

- AR form analysis (Fitness)
- Voice AI conversations
- Wearable integration (Apple Watch, Fitbit)
- Web app (Flutter Web)
- B2B corporate wellness

### Phase 3: Ecosystem Expansion (12+ months)

- Talent Tree (RPG gamification)
- Relationship AI
- Tandem/Team Mode (social features)
- E-Learning micro courses
- AI Future Self conversations
- Life Map visual dashboard
- Human Help platform

---

## 🎯 Next Steps

### For Developers

1. ✅ Read this README
2. 🔴 **Complete Sprint 0** (18-21h) - `docs/ecosystem/sprint-0-database-schema-completion.md`
3. ⏸️ Complete Epic 0 (19-30h) - `docs/ecosystem/epic-0-setup-infrastructure.md`
4. ⏸️ Start Epic 1 (40-60h) - `docs/ecosystem/epics.md`

### For Stakeholders

1. Review validation reports in `docs/ecosystem/`
2. Understand 82% → 100% readiness path (Sprint 0)
3. Approve Sprint 0 → Epic 0 → Epic 1 timeline
4. Monitor progress via workflow status

---

**Last Updated:** 2025-01-16
**Version:** 0.1.0 (Pre-Implementation)
**Status:** 🚧 Sprint 0 Required Before Implementation

---

🎨 **Generated with [Claude Code](https://claude.com/claude-code)**
