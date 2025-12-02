# LifeOS - Product Requirements Document - Overview

<!-- AI-INDEX: prd, product, requirements, overview, mvp, success-metrics, monetization, target-users -->

**Wersja:** 2.0 (BMAD Reorganized)
**Data:** 2025-01-16
**Status:** ✅ Zatwierdzona do implementacji

---

## Spis Treści

1. [Executive Summary](#1-executive-summary)
2. [Klasyfikacja Projektu](#2-klasyfikacja-projektu)
3. [Success Criteria](#3-success-criteria)
4. [Product Scope - MVP](#4-product-scope---mvp)
5. [Pricing Model](#5-pricing-model)
6. [Mobile Requirements](#6-mobile-requirements)
7. [UX Principles](#7-ux-principles)
8. [Powiązane Dokumenty](#8-powiązane-dokumenty)

---

## 1. Executive Summary

**LifeOS** to pierwszy na świecie modularny ekosystem AI-powered life coaching, łączący:
- **Fitness Coach** - tracking treningów, Smart Pattern Memory
- **Life Coach** - daily planning, goals, AI chat
- **Mind & Emotion** - meditation, mood tracking, CBT

### Killer Feature: Cross-Module Intelligence

Jedyna aplikacja gdzie moduły komunikują się ze sobą:
- Fitness dostosowuje intensywność treningu na podstawie stresu z Mind
- Life Coach sugeruje medytację gdy spada jakość snu
- Mind rekomenduje rest day gdy volume treningowy jest wysoki
- AI widzi pełny kontekst: sen + stres + nastrój + treningi + cele

**Żaden konkurent nie ma tej funkcjonalności.** Calm oferuje tylko medytację. Noom tylko coaching. Freeletics tylko fitness. LifeOS łączy wszystko z 60-70% oszczędnościami kosztów.

---

## 2. Klasyfikacja Projektu

| Aspekt | Wartość |
|--------|---------|
| **Technical Type** | Mobile App (iOS + Android) |
| **Domain** | General Wellness |
| **Complexity** | Low (brak wymogów regulatory FDA/HIPAA) |

### Technology Stack

| Komponent | Technologia |
|-----------|-------------|
| **Framework** | Flutter 3.38+ (cross-platform) |
| **Platforms** | iOS 14+, Android 10+ |
| **State Management** | Riverpod 3.0 |
| **Local Database** | Drift (SQLite) - offline-first |
| **Backend** | Supabase (PostgreSQL) |
| **Real-time Sync** | Supabase Realtime |
| **AI** | Hybrid (Llama/Claude/GPT-4) |

### Architectural Pattern

**Modular Monolith:**
- Single app z modułami jako features
- Wspólny core platform (auth, data sync, AI orchestration)
- Moduły mogą być włączane/wyłączane przez subscriptions

### Target Market

| Aspekt | Wartość |
|--------|---------|
| **Primary Markets** | UK + Poland |
| **Expansion** | EU → Global |
| **Target Users** | 22-45 lat, professionals, wellness enthusiasts |
| **TAM** | $23.99B (Wellness + Life Coaching + Mental Health) |
| **UK + Poland SAM** | $235M |

---

## 3. Success Criteria

### North Star Metric

**Day 30 Retention: 10-12%** (3x industry average 3.3%)

**Dlaczego ten metric?**
- Retention = product-market fit validation
- Industry average dla wellness apps: 3.3%
- Noom (najlepszy): ~8%
- **LifeOS target: 10-12%**

### Jak osiągniemy 10-12% retention

| Driver | Mechanizm |
|--------|-----------|
| **Smart Pattern Memory** | Instant value, saves 5 min/workout |
| **Streak Mechanics** | Bronze (7d), Silver (30d), Gold (100d) + 1 freeze/week |
| **Daily Check-ins** | Morning/evening ritual builds habit |
| **Cross-Module Insights** | "Your best lifts happen after 8+ hours sleep" |
| **Weekly Reports** | Concrete evidence ("+5kg squat, stress -23%") |

### Success Milestones

| Milestone | Timeframe | GO Criteria | NO-GO |
|-----------|-----------|-------------|-------|
| **MVP Validation** | Month 3 | Retention ≥5%, Rating ≥4.3, CAC ≤£15, 500-1k downloads | Retention <3% → pivot |
| **UK Expansion** | Month 6 | Retention ≥8%, Conversion ≥3%, MRR +10% MoM, NPS ≥40 | Retention <5% → reassess |
| **P1 Features** | Month 12 | Retention ≥10%, Conversion ≥5%, MRR ≥£3k | Social features fail |
| **AI Investment** | Month 18 | Conversion ≥7%, ARR ≥£100k, NPS ≥50, AI costs <30% | AI doesn't improve conversion 2%+ |

### Business Metrics

| Metric | Year 1 | Year 2 | Year 3 |
|--------|--------|--------|--------|
| **ARR** | £15k | £75k | £225k |
| **Downloads** | 5,000 | 25,000 | 75,000 |
| **Conversion** | 5% | 6% | 7% |

### Unit Economics

| Metric | Target |
|--------|--------|
| **ARPU** | £40-50/year |
| **CAC** | <£30 (organic primary) |
| **LTV** | £80-100 (2-year retention) |
| **LTV:CAC** | >3:1 |

### Quality Metrics

| Metric | Target |
|--------|--------|
| **App Store Rating** | 4.5+ |
| **NPS** | 50+ |
| **Crash Rate** | <0.5% |
| **Smart Pattern Query** | <500ms p95 |
| **AI Response (Llama)** | <2s p95 |
| **AI Response (Claude/GPT-4)** | <3s p95 |

---

## 4. Product Scope - MVP

### Moduł 1: Life Coach (FREE Tier)

**Core Value:** Daily plan + goal tracking + AI chat

| Feature | Opis |
|---------|------|
| Daily Plan | Considering sleep, stress, mood, workouts |
| Goal Tracking | Max 3 goals (free tier) |
| Morning/Evening Check-ins | Mood, energy, sleep quality |
| AI Conversations | 3-5/day z Llama |
| Progress Tracking | Basic charts |
| Habit Streaks | Freeze mechanics (1/week) |
| Push Notifications | Reminders, insights |

### Moduł 2: Fitness Coach (2.99 EUR/month)

**Core Value:** Smart Pattern Memory + workout tracking

| Feature | Opis |
|---------|------|
| **Smart Pattern Memory** | Pre-fills last workout (KILLER FEATURE) |
| Manual Workout Logging | Fast UX, 2-second log |
| Exercise Library | 500+ exercises |
| Progress Charts | Weight, volume, PRs (FREE!) |
| Workout Templates | 20+ pre-built |
| Body Measurements | Weight, body fat, photos |
| Workout History | Full history |
| Rest Timer | Between sets |
| Custom Templates | User-created |
| Export Data | CSV format |
| **Cross-Module** | Receives stress from Mind |

### Moduł 3: Mind & Emotion (2.99 EUR/month)

**Core Value:** Meditation + mood tracking + CBT chat

| Feature | Opis |
|---------|------|
| Guided Meditations | 20-30 MVP (5/10/15/20 min) |
| Themes | Stress, Sleep, Focus, Anxiety, Gratitude |
| Breathing Exercises | 5 techniques (Box, 4-7-8, etc.) |
| Mood Tracking | Always FREE (1-5 scale + emoji) |
| Stress Tracking | Shared with Fitness & Life Coach |
| CBT Chat with AI | 1/day free, unlimited premium |
| Journaling | E2E encrypted, AI insights |
| Sleep Meditations | 10-30 min stories |
| Mental Health Screening | GAD-7, PHQ-9 |
| Gratitude Exercises | "3 Good Things" |
| **Cross-Module** | Shares mood/stress, receives suggestions |

### MVP Success Criteria

| Metric | Target |
|--------|--------|
| Day 30 Retention | ≥5% |
| Downloads | 500-1,000 (UK + Poland) |
| App Store Rating | ≥4.3 |
| Cross-Module Insights | 1+/week for 50%+ paid users |

---

## 5. Pricing Model

### Modular Pricing (MVP)

| Tier | Price | Features |
|------|-------|----------|
| **FREE** | 0 EUR | Life Coach basic |
| **Single Module** | 2.99 EUR/month | Fitness OR Mind |
| **3-Module Pack** | 5.00 EUR/month | Life Coach + Fitness + Mind |
| **Full Access** | 7.00 EUR/month | All + Premium AI (GPT-4 unlimited) |

### Competitive Advantage

| Competitor Stack | Cost/Year | LifeOS Equivalent |
|------------------|-----------|-------------------|
| Calm + Headspace + Noom + Strong | £320 | £60 (3-Module Pack) |
| **Savings** | - | **60-70%** |

### Key Differentiators

1. **Cross-Module Intelligence** - 12-18 month lead time for competitors
2. **Modular Pricing** - Pay only for what you need
3. **Hybrid AI** - User choice (Llama/Claude/GPT-4) with 30% cost budget
4. **60-70% Cost Savings** - vs multi-app stack
5. **Genuine Free Tier** - Life Coach always free (not crippled trial)

---

## 6. Mobile Requirements

### Platform Requirements

| Platform | Min Version | Coverage |
|----------|-------------|----------|
| **iOS** | 14+ | 95% iOS users |
| **Android** | 10+ (API 29) | 90% Android users |

### Target Devices

- iPhones: iPhone 8+
- iPads: iPad Air 3+ (responsive)
- Android Phones: 5.5" - 6.7"
- Android Tablets: 7" - 10" (lower priority)

### Performance Targets

| Metric | Target |
|--------|--------|
| **App Size** | <50MB initial |
| **Cold Start** | <2s |
| **Hot Start** | <500ms |
| **Memory (background)** | <150MB |
| **Memory (active)** | <250MB |

### Permissions

**Required (MVP):**
- Internet access (AI chat, sync)
- Local storage (offline-first)
- Push notifications (reminders, alerts)

**Optional:**
- Camera (P3 - body photos, form check)
- Health data (P1 - Apple Health, Google Fit)
- Microphone (P2 - voice AI)
- Location (P2 - outdoor workouts)

### Offline Mode

| Module | Offline Support |
|--------|-----------------|
| **Fitness** | 100% offline (Drift/SQLite) |
| **Mind** | Partial (cached audio, mood tracking) |
| **Life Coach** | Hybrid (check-ins offline, AI requires internet) |

---

## 7. UX Principles

### Visual Personality

**Design Inspiration:** Nike + Headspace fusion
- Nike: Bold, energetic, motivational (Fitness)
- Headspace: Calm, friendly, approachable (Mind)
- Hybrid: Professional yet warm, data-driven yet empathetic

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary** | #1E3A8A | Deep Blue - trust, stability |
| **Accent 1** | #14B8A6 | Energetic Teal - energy, growth |
| **Accent 2** | #F97316 | Orange - motivation (Fitness) |
| **Accent 3** | #9333EA | Purple - mindfulness (Mind) |
| **Neutrals** | #F9FAFB → #111827 | Gray scale |

### Key Interaction Patterns

| Pattern | Goal | Implementation |
|---------|------|----------------|
| **Fast Workout Logging** | <2s per set | Smart Pattern Memory pre-fill |
| **Calming Meditation Start** | 1 tap start | "Continue" or AI-recommended |
| **Morning Check-in** | 1-minute | 3 quick taps: Mood, Energy, Sleep |
| **Cross-Module Insights** | Non-intrusive | 1 card/day max, swipeable |
| **Streak Celebration** | Reinforce habit | Full-screen confetti, badges |

### Navigation

**Bottom Tab Bar:**
1. Home (Life Coach) - Daily plan, goals, check-ins
2. Fitness - Workout logging, progress, templates
3. Mind - Meditation, mood tracking, journaling
4. Profile - Settings, subscription, stats, export

---

## 8. Powiązane Dokumenty

### Requirements (Szczegóły)

| Dokument | Zawartość |
|----------|-----------|
| [PRD-fitness-requirements.md](./PRD-fitness-requirements.md) | FR30-FR46: Fitness module |
| [PRD-life-coach-requirements.md](./PRD-life-coach-requirements.md) | FR6-FR29: Life Coach module |
| [PRD-mind-requirements.md](./PRD-mind-requirements.md) | FR47-FR76: Mind module |
| [PRD-nfr.md](./PRD-nfr.md) | NFR1-NFR37: Non-functional requirements |

### Architecture

| Dokument | Zawartość |
|----------|-----------|
| [ARCH-overview.md](../architecture/ARCH-overview.md) | Przegląd architektury |
| [ARCH-database-schema.md](../architecture/ARCH-database-schema.md) | Schemat bazy danych |

### Epics & Stories

| Dokument | Zawartość |
|----------|-----------|
| [epic-1-core-platform.md](../../2-MANAGEMENT/epics/epic-1-core-platform.md) | Core Platform stories |
| [epic-2-life-coach.md](../../2-MANAGEMENT/epics/epic-2-life-coach.md) | Life Coach stories |
| [epic-3-fitness.md](../../2-MANAGEMENT/epics/epic-3-fitness.md) | Fitness stories |
| [epic-4-mind.md](../../2-MANAGEMENT/epics/epic-4-mind.md) | Mind stories |

---

## FR Coverage Summary

| Category | FRs | Count |
|----------|-----|-------|
| Account & Auth | FR1-FR5 | 5 |
| Life Coach | FR6-FR29 | 24 |
| Fitness | FR30-FR46 | 17 |
| Mind | FR47-FR76 | 30 |
| Cross-Module Intel | FR77-FR84 | 8 |
| Gamification | FR85-FR90 | 6 |
| Subscriptions | FR91-FR97 | 7 |
| Data & Privacy | FR98-FR103 | 6 |
| Notifications | FR104-FR110 | 7 |
| Onboarding | FR111-FR115 | 5 |
| Settings | FR116-FR123 | 8 |
| **TOTAL** | | **123 FRs** |

---

*Dokument stworzony przez BMAD Methodology - reorganizacja 2025-12-02*
