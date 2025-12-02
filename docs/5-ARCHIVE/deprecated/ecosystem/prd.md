# LifeOS - Product Requirements Document

**Author:** Mariusz
**Date:** 2025-01-16
**Version:** 1.0

---

## Executive Summary

LifeOS to pierwszy na świecie modularny ekosystem AI-powered life coaching, który łączy fitness, zdrowie psychiczne i planowanie życia w jedną inteligentną platformę. Produkt rozwiązuje problem fragmentacji aplikacji wellness (użytkownicy płacą £200-320/rok za 5-8 oddzielnych aplikacji bez integracji) poprzez modularne ceny i cross-module intelligence.

### What Makes This Special

**Cross-Module Intelligence** - jedyna aplikacja, w której moduły komunikują się ze sobą:

- Fitness dostosowuje intensywność treningu na podstawie poziomu stresu z modułu Mind
- Life Coach sugeruje medytację gdy spada jakość snu
- Mind rekomenduje rest day gdy volume treningowy jest wysoki
- AI widzi pełny kontekst: sen + stres + nastrój + treningi + cele = holistyczna optymalizacja

**Żaden konkurent nie ma tej funkcjonalności.** Calm oferuje tylko medytację. Noom tylko coaching żywieniowy. Freeletics tylko fitness. LifeOS łączy wszystko w jeden inteligentny ekosystem z 60-70% oszczędnościami kosztów.

---

## Project Classification

**Technical Type:** mobile_app
**Domain:** general
**Complexity:** low

### Project Type: Mobile App (iOS + Android)

**Technology Stack:**
- Framework: Flutter 3.38+ (cross-platform)
- Platforms: iOS 14+, Android 10+
- State Management: Riverpod 3.0
- Local Database: Drift (SQLite) - offline-first
- Backend: Supabase (PostgreSQL)
- Real-time Sync: Supabase Realtime

**Architectural Pattern:** Modular monolith
- Single app z modułami jako features
- Wspólny core platform (auth, data sync, AI orchestration)
- Moduły mogą być włączane/wyłączane przez subscriptions

### Domain: General Wellness

LifeOS działa w domenie consumer wellness/life coaching:
- Brak wymogów regulatory (FDA, HIPAA, medical device)
- Standardowe wymagania: GDPR, data privacy, security
- Rynek: UK + Poland → EU → Global
- Użytkownicy: 22-45 lat, professionals, wellness enthusiasts

**Nie jest to:**
- Healthcare app (brak diagnozy medycznej, tylko mood tracking i mindfulness)
- Fitness wearable (software only, integracja z wearables P1)
- Medical device (brak FDA clearance needed)

### Input Documents

**Product Brief:** `docs/ecosystem/product-brief-LifeOS-2025-01-16.md`
- Kompletna wizja produktu, 4 persony, competitive analysis
- Value proposition i USPs
- Monetization model (freemium + modular subscriptions)

**Domain Research:** `docs/ecosystem/research-domain-2025-01-16.md`
- Market sizing: TAM $23.99B (Wellness + Life Coaching + Mental Health)
- UK + Poland SAM: $235M
- Competitive landscape (Calm, Headspace, Noom, Freeletics)
- Pricing advantage: 49-95% cheaper

**Technical Research:** `docs/ecosystem/research-technical-2025-01-16.md`
- Technology stack validation (Flutter, Supabase, Hybrid AI)
- ROI analysis: $158,697 savings over 3 years
- Risk assessment matrix (10 risks, prioritized P0-P3)
- Architecture assumptions validated

**Brainstorming Session:** `docs/ecosystem/bmm-brainstorming-session-2025-01-16.md`
- Detailed user personas (4)
- Cross-module intelligence design
- Go-to-market strategy (UK + Poland)
- Risk mitigation strategies

---

## Success Criteria

### North Star Metric: Day 30 Retention

**Target: 10-12%** (3x industry average of 3.3%)

**Dlaczego ten metric?**
- Retention = product-market fit validation
- Industry average dla wellness apps: 3.3% (abysmal)
- Noom (najlepszy w kategorii): ~8%
- **LifeOS target: 10-12%** = dowód że cross-module intelligence działa

**Jak go osiągniemy:**
1. **Smart Pattern Memory** (Fitness) - instant value, saves 5 min/workout
2. **Streak Mechanics** - Bronze (7d), Silver (30d), Gold (100d) z 1 freeze/week
3. **Daily Check-ins** - Morning/evening ritual builds habit
4. **Cross-Module Insights** - "Your best lifts happen after 8+ hours sleep" = sticky
5. **Weekly Reports** - Concrete evidence of progress ("+5kg squat, stress -23%")

### Success Milestones

**Month 3 (MVP Validation):**
- ✅ **GO Criteria:**
  - Day 30 retention ≥ 5%
  - App Store rating ≥ 4.3
  - CAC ≤ £15 (organic growth working)
  - 500-1,000 downloads (UK + Poland)
- ❌ **NO-GO:** Retention <3% → produkt nie rozwiązuje problemu, pivot

**Month 6 (UK Expansion Decision):**
- ✅ **GO Criteria:**
  - Retention ≥ 8%
  - Free-to-paid conversion ≥ 3%
  - MRR growing 10% MoM
  - NPS ≥ 40
- ❌ **PAUSE:** Retention <5% → reassess product

**Month 12 (P1 Features Decision):**
- ✅ **GO Criteria:**
  - Retention ≥ 10%
  - Conversion ≥ 5%
  - MRR ≥ £3,000
  - Mikroklub engagement >30% (social features work)
- ❌ **REASSESS:** Social features don't improve retention

**Month 18 (AI Investment Decision):**
- ✅ **GO Criteria:**
  - Conversion ≥ 7% (AI drives upgrades)
  - ARR ≥ £100,000
  - NPS ≥ 50
  - AI costs stay under 30% of revenue
- ❌ **REASSESS:** AI features don't improve conversion by 2%+

### Business Metrics

**Revenue Targets:**
- Year 1: £15k ARR (5,000 downloads, 5% conversion)
- Year 2: £75k ARR (25,000 downloads, 6% conversion)
- Year 3: £225k ARR (75,000 downloads, 7% conversion)

**Unit Economics:**
- ARPU: £40-50/year (mix of 2.99 / 5.00 / 7.00 EUR tiers)
- CAC: <£30 (organic growth primary)
- LTV: £80-100 (assuming 2-year retention)
- LTV:CAC: >3:1 (sustainable growth)

**User Engagement:**
- DAU %: 60% (users open app daily)
- Weekly workout frequency: 3.5/week (Fitness module)
- Meditation frequency: 4.5/week (Mind module)
- Streak completion: 70% maintain 7-day streak

### Product Quality Metrics

- App Store rating: 4.5+ (iOS + Android)
- NPS (Net Promoter Score): 50+
- Crash rate: <0.5%
- Smart pattern memory query time: <500ms p95
- AI response time: <2s p95 (Llama), <3s (Claude/GPT-4)

---

## Product Scope

### MVP - Minimum Viable Product (4-6 miesięcy)

**3 Moduły Podstawowe:**

#### 1. Life Coach (FREE Tier)
**Core Value:** Daily plan generation + goal tracking + AI chat

- Daily plan considering sleep, stress, mood, workouts
- Goal tracking (max 3 cele dla free tier)
- Morning/evening check-ins (mood, energy, sleep quality)
- AI conversations (3-5/day z Llama)
- Progress tracking (basic charts)
- Habit streaks z freeze mechanics (1/week)
- Push notifications

#### 2. Fitness Coach (2.99 EUR/month)
**Core Value:** Smart pattern memory logging + workout tracking

- Smart Pattern Memory (pre-fills last workout - killer feature)
- Manual workout logging (fast UX, 2-second log)
- Exercise library (500+ exercises)
- Progress tracking & charts (waga podniesiona, volume, PR-y)
- Workout templates (20+ pre-built: Push/Pull/Legs, Upper/Lower, etc.)
- Body measurements tracking
- Workout history
- Rest timer
- Custom templates
- Export data (CSV)
- **Cross-Module:** Receives stress data from Mind, adjusts intensity

#### 3. Mind & Emotion Coach (2.99 EUR/month)
**Core Value:** Meditation + mood tracking + CBT chat

- Guided meditations (20-30 MVP, expanding to 100+ P1)
  - Lengths: 5, 10, 15, 20 min
  - Themes: Stress relief, Sleep, Focus, Anxiety, Gratitude
- Breathing exercises (5 techniques: Box, 4-7-8, Calm, Energizing, Sleep)
- Daily mood tracking (always FREE, 1-5 scale + emoji)
- Stress level tracking (shared with Fitness and Life Coach)
- CBT chat with AI (1 conversation/day free, unlimited premium)
- Journaling with AI insights (end-to-end encrypted)
- Sleep meditations (10-30 min sleep stories)
- Anxiety screening (GAD-7)
- Depression screening (PHQ-9)
- Gratitude exercises ("3 Good Things")
- **Cross-Module:** Shares mood/stress with Life Coach, receives meditation suggestions

**Modular Pricing (MVP):**
- FREE: Life Coach basic
- 2.99 EUR/month: 1 module (Fitness OR Mind)
- 5.00 EUR/month: 3-Module Pack (Life Coach + Fitness + Mind)
- 7.00 EUR/month: Full Access + Premium AI (GPT-4 unlimited)

**MVP Success Criteria:**
- Retention ≥ 5% Day 30 (Month 3)
- 500-1,000 downloads (UK + Poland organic)
- App Store rating ≥ 4.3
- Cross-module insights working (1+ insight/week for 50%+ paid users)

### Growth Features (Post-MVP, Phased Rollout)

**Phase 1 (Month 7-12): Social & Community**

- **Mikroklub** (P1 - Social Features)
  - 10-person groups (wellness buddies)
  - Shared challenges (30-day meditation, workout streaks)
  - Group chat (moderated, safe space)
  - Leaderboards (opt-in, friendly competition)
  - Accountability partners

- **Tandem/Team Mode** (P1)
  - Shared goals with partner or friend
  - Couples wellness (shared daily plans)
  - Family challenges

- **Wearable Integration** (P1)
  - Apple Health + Google Fit
  - Import sleep, HRV, steps
  - Whoop, Oura, Garmin (P2)

**Phase 2 (Year 2): Advanced Features**

- **Talent Tree** (P1 - Gamification)
  - RPG-style skill trees (Fitness, Mind, Relationships, Career)
  - XP for completing goals, workouts, meditations
  - Unlockable badges and achievements
  - Visual progress (character grows stronger)

- **E-Learning** (P1)
  - Micro courses (5-10 min lessons)
  - Topics: Mindfulness, CBT, Strength Training, Nutrition Basics
  - Completion tracking
  - Certificates (shareable)

- **Human Help** (P2 - Social Good)
  - Peer support platform
  - Community donations to charity
  - Volunteer wellness coaching (trained users help beginners)

- **Voice AI** (P2)
  - Voice conversations with AI coach
  - Hands-free daily planning (morning routine)
  - Meditation guided by voice

**Phase 3 (Year 3): Advanced Modules**

- **Nutrition Module** (P2)
  - Meal tracking (similar to MyFitnessPal)
  - Macro goals
  - Integration with Fitness (calories burned → calorie targets)
  - Recipe suggestions (AI-generated based on goals)

- **Relationship AI** (P2)
  - Communication coaching
  - Conflict resolution guidance
  - Relationship health tracking

- **AI Future Self** (P3)
  - Conversations with your future self (6 months, 1 year, 5 years)
  - Goal visualization
  - Motivational tool

- **Life Map** (P1)
  - Visual dashboard of life progress
  - All modules in one view
  - Weekly/monthly reports

- **BioAge Tracker** (P3)
  - Biological age estimation (via wearables + health data)
  - Longevity optimization suggestions

- **Camera Features** (P3)
  - Body composition tracking (photos)
  - Posture analysis (AR)
  - Workout form checking (AI video analysis)

### Vision (Future, 3+ Years)

**Global Ecosystem:**
- 10+ modules covering all life domains
- B2B offering ("LifeOS for Teams" - corporate wellness)
- API for third-party module developers
- Marketplace for premium content (guided meditations from celebrity coaches)
- Multi-language support (20+ languages)
- Platform expansion (Web app, Desktop app)

**AI Advancements:**
- Proactive AI agent (suggests actions before you ask)
- Predictive burnout prevention
- Long-term life planning (5-10 year goals)
- Multi-modal AI (voice + text + visual analysis)

**Social Features:**
- Large-scale challenges (10,000+ users)
- Wellness influencer partnerships
- User-generated content (share workout templates, meditation scripts)

**Ultimate Vision:**
> "LifeOS becomes the operating system for every aspect of your life. One app. Infinite possibilities. Every goal achievable."

---

## Mobile App Specific Requirements

### Platform Requirements

**Supported Platforms:**
- iOS 14+ (95% of iOS users)
- Android 10+ (API level 29+, 90% of Android users)

**Target Devices:**
- iPhones: iPhone 8 and newer
- iPads: iPad Air 3 and newer (responsive layout)
- Android Phones: 5.5" to 6.7" screens (majority)
- Android Tablets: 7" to 10" (responsive layout, lower priority)

**Performance Targets:**
- App size: <50MB initial download
- Cold start time: <2s
- Hot start time: <500ms
- Memory usage: <150MB (background), <250MB (active use)

### Device Features & Permissions

**Required Permissions (MVP):**
- Internet access (AI chat, data sync)
- Local storage (offline-first database)
- Push notifications (daily reminders, streak alerts, cross-module insights)

**Optional Permissions (User can grant later):**
- Camera (P3 - body composition photos, form checking)
- Health data (P1 - Apple Health, Google Fit integration for sleep/HRV)
- Microphone (P2 - voice AI conversations)
- Location (P2 - workout location tracking, outdoor running)

**Offline Mode Requirements:**

**Fitness Module: Fully Offline**
- All workout logging works offline (Drift/SQLite local database)
- Exercise library cached locally
- Sync when internet available (Supabase Realtime)

**Mind Module: Partially Offline**
- Meditation audio files cached after first play (10-30MB total)
- Mood tracking works offline
- Journaling works offline (encrypted locally)
- CBT chat requires internet (AI API calls)

**Life Coach Module: Hybrid**
- Morning/evening check-ins work offline
- Daily plan generation requires internet (AI planning)
- Goal tracking and progress charts work offline
- Cached last daily plan if offline (fallback)

### App Store Compliance

**iOS App Store:**
- App Store Review Guidelines 2025 compliance
- Privacy Nutrition Labels (data collection transparency)
- In-App Purchase for subscriptions (Apple 30% cut Year 1, 15% Year 2+)
- TestFlight beta testing (500-10,000 external testers)
- App Privacy Report support (iOS 15+)

**Google Play Store:**
- Play Console policies compliance
- Data safety section (similar to iOS Privacy Labels)
- In-App Billing for subscriptions (Google 30% cut Year 1, 15% Year 2+)
- Open beta testing (unlimited testers)
- Families policy compliance (no harmful content)

**Content Rating:**
- PEGI 12+ / ESRB Teen (mental health content, anxiety/depression screening)
- No gambling, no violent content
- Parental guidance for users under 18

### Push Notification Strategy

**Notification Types:**

1. **Daily Reminders** (Opt-in, user controls timing)
   - Morning check-in reminder (default: 8am)
   - Evening reflection reminder (default: 8pm)
   - Workout reminder (if scheduled in daily plan)
   - Meditation reminder (if goal set)

2. **Streak Alerts** (Always on for engaged users)
   - Streak about to break (1 day before freeze needed)
   - Milestone achieved (7-day Bronze, 30-day Silver, 100-day Gold)
   - Freeze available ("You have 1 freeze available this week")

3. **Cross-Module Insights** (Max 1/day, high priority only)
   - "High stress detected + heavy workout today → Consider light session"
   - "Sleep <6 hours + morning workout planned → Suggest afternoon instead"
   - "Meditation streak 21 days + fitness improving → Keep it up!"

4. **Goal Progress** (Weekly, opt-in)
   - "Week summary ready: +5kg squat, stress -23%, 4 workouts"
   - "You're 80% toward your monthly goal"

**Notification Best Practices:**
- User controls ALL notifications in settings
- Quiet hours (default: 10pm - 7am, user customizable)
- Notification grouping (iOS) / channels (Android)
- Deep linking to relevant screen (tapping notification opens specific module)

---

## User Experience Principles

### Visual Personality

**Design Inspiration:** Nike + Headspace fusion
- **Nike**: Bold, energetic, motivational (for Fitness module)
- **Headspace**: Calm, friendly, approachable (for Mind module)
- **Hybrid**: Professional yet warm, data-driven yet empathetic

**Color Palette:**
- Primary: Deep Blue (#1E3A8A) - trust, stability, calm
- Accent 1: Energetic Teal (#14B8A6) - energy, growth, wellness
- Accent 2: Orange (#F97316) - motivation, achievement (Fitness)
- Accent 3: Purple (#9333EA) - mindfulness, calm (Mind)
- Neutrals: Gray scale (#F9FAFB → #111827)

**Typography:**
- Headings: Inter Bold (modern, clean, highly readable)
- Body: Inter Regular (same family for consistency)
- Numbers/Stats: Inter SemiBold (emphasis on data)

**Iconography:**
- Custom icon set (consistent style across modules)
- Outlined style (modern, not heavy)
- Accessible (high contrast, clear shapes)

### Key Interaction Patterns

**1. Fast Workout Logging (Fitness)**
- **Goal:** Log workout in <2 seconds per set
- **Pattern:**
  - Tap exercise name → Smart pattern memory pre-fills last sets/reps/weight
  - Adjust if needed (swipe gestures to increment/decrement)
  - Tap checkmark → Done
- **Why:** Users at gym want speed, not typing

**2. Calming Meditation Start (Mind)**
- **Goal:** Start meditation in 1 tap, no decision paralysis
- **Pattern:**
  - Open Mind module → "Continue where you left off" large button
  - OR "Meditation for today" AI-recommended based on mood
  - 1 tap → Meditation starts (calming animation, fade in)
- **Why:** Meditation should feel effortless, not another task

**3. Morning Check-in Ritual (Life Coach)**
- **Goal:** 1-minute check-in to set daily intention
- **Pattern:**
  - Open app → Morning check-in prompt (if not done)
  - 3 quick taps: Mood (1-5), Energy (1-5), Sleep quality (1-5)
  - Optional: Add note
  - AI generates daily plan based on answers
- **Why:** Quick ritual builds habit, provides data for AI

**4. Cross-Module Insight Cards**
- **Goal:** Surface insights without overwhelming user
- **Pattern:**
  - Card-based UI (swipeable)
  - 1 insight card per day max (high priority only)
  - Example: "💡 Insight: Your best workouts happen after 8+ hours sleep. Tonight's suggestion: Sleep meditation at 10pm."
  - User can dismiss, save, or act on insight
- **Why:** Insights are valuable but need to be actionable, not noise

**5. Streak Celebration**
- **Goal:** Reinforce habit formation with positive feedback
- **Pattern:**
  - Milestone reached (7, 30, 100 days)
  - Full-screen confetti animation (Lottie)
  - Badge unlocked visual
  - Shareable card (optional: post to social media)
- **Why:** Gamification drives retention (Duolingo-style)

### Navigation Architecture

**Bottom Tab Bar (Main Navigation):**
1. **Home** (Life Coach) - Daily plan, goals, check-ins
2. **Fitness** - Workout logging, progress, templates
3. **Mind** - Meditation, mood tracking, journaling
4. **Profile** - Settings, subscription, stats, export data

**Top-Level Flows:**
- Home → Daily plan → Tap suggested workout → Opens Fitness module (deep link)
- Mind → Mood tracking → AI detects low mood → Suggests meditation
- Fitness → Log workout → High stress detected → Cross-module alert → Opens Mind

**Onboarding Flow (First-Time Users):**
1. Welcome screen (vision statement)
2. Choose your journey:
   - "I want to get fit" → Fitness-first onboarding
   - "I want to reduce stress" → Mind-first onboarding
   - "I want to organize my life" → Life Coach-first onboarding
   - "I want it all" → Full ecosystem onboarding
3. Set initial goals (1-3)
4. Grant permissions (push notifications, health data if desired)
5. Choose AI personality: Sage (calm) or Momentum (energetic)
6. Tutorial (interactive, <2 minutes)
7. First morning check-in
8. Show 14-day trial of premium modules

**Progressive Disclosure:**
- Free users see premium features (locked state with "Upgrade" CTA)
- Premium features shown in context (e.g., "Unlock unlimited AI chat")
- Not pushy (1 subtle upsell per session max)

---

## Functional Requirements

### 1. User Account & Authentication

- **FR1:** Users can create accounts using email or social authentication (Google, Apple)
- **FR2:** Users can log in securely and maintain sessions across devices
- **FR3:** Users can reset passwords via email verification
- **FR4:** Users can update profile information (name, email, avatar)
- **FR5:** Users can delete their account and all associated data

### 2. Life Coach - Daily Planning

- **FR6:** System generates personalized daily plan considering sleep, mood, energy, stress, and scheduled workouts
- **FR7:** Users can view their daily plan on the home screen
- **FR8:** Users can mark daily plan items as complete
- **FR9:** Users can manually adjust or skip daily plan suggestions
- **FR10:** System adapts future daily plans based on completion patterns

### 3. Life Coach - Goal Tracking

- **FR11:** Users can create up to 3 goals (free tier) or unlimited goals (premium)
- **FR12:** Users can categorize goals (Fitness, Mental Health, Career, Relationships, Learning, Finance)
- **FR13:** Users can set target dates for goals
- **FR14:** Users can track progress toward goals with percentage completion
- **FR15:** System suggests daily tasks that contribute to active goals
- **FR16:** Users can mark goals as completed
- **FR17:** Users can archive or delete goals

### 4. Life Coach - AI Conversations

- **FR18:** Users can chat with AI life coach for motivation, advice, and problem-solving
- **FR19:** Free tier users can have 3-5 AI conversations per day (Llama model)
- **FR20:** Premium users can have unlimited AI conversations (Claude or GPT-4 model)
- **FR21:** Users can choose AI personality (Sage: calm vs. Momentum: energetic)
- **FR22:** AI can reference previous conversations and user context (goals, mood, stress)
- **FR23:** Users can view conversation history
- **FR24:** Users can delete conversation history

### 5. Life Coach - Check-ins

- **FR25:** Users can complete morning check-in (mood, energy, sleep quality, 1-minute)
- **FR26:** Users can complete evening reflection (accomplishments, tomorrow prep, 2-minute)
- **FR27:** System uses check-in data to inform daily plan generation
- **FR28:** Users can skip check-ins without penalty
- **FR29:** System displays check-in streaks and trends

### 6. Fitness - Workout Logging

- **FR30:** Users can log workouts with sets, reps, and weight
- **FR31:** System uses Smart Pattern Memory to pre-fill last workout data
- **FR32:** Users can search and select exercises from library (500+ exercises)
- **FR33:** Users can add custom exercises to library
- **FR34:** Users can log workout duration and rest intervals
- **FR35:** Users can add notes to workout sessions
- **FR36:** System supports offline workout logging with sync when online
- **FR37:** Users can edit or delete logged workouts

### 7. Fitness - Progress Tracking

- **FR38:** Users can view progress charts (weight lifted, volume, personal records)
- **FR39:** Users can track body measurements (weight, body fat %, measurements)
- **FR40:** Users can view workout history by date or exercise
- **FR41:** System calculates and displays personal records automatically
- **FR42:** Users can export workout data (CSV format)

### 8. Fitness - Templates & Library

- **FR43:** Users can access 20+ pre-built workout templates (Push/Pull/Legs, Upper/Lower, Full Body)
- **FR44:** Users can create custom workout templates
- **FR45:** Users can save favorite exercises for quick access
- **FR46:** Users can view exercise instructions and form videos (P1)

### 9. Mind - Meditation

- **FR47:** Users can access guided meditation library (20-30 meditations MVP, 100+ P1)
- **FR48:** Users can filter meditations by length (5, 10, 15, 20 min) and theme (Stress, Sleep, Focus, Anxiety, Gratitude)
- **FR49:** Free tier users can access 3 rotating meditations
- **FR50:** Premium users can access full meditation library
- **FR51:** System caches meditation audio for offline playback
- **FR52:** Users can track meditation completion and streaks
- **FR53:** Users can favorite meditations
- **FR54:** System recommends meditations based on mood and stress level

### 10. Mind - Mood & Stress Tracking

- **FR55:** Users can track daily mood (1-5 scale + emoji, always FREE)
- **FR56:** Users can track stress level (1-5 scale)
- **FR57:** Users can add optional notes about mood/stress triggers
- **FR58:** System displays mood and stress trends (weekly, monthly charts)
- **FR59:** System shares mood and stress data with Life Coach and Fitness modules (cross-module)
- **FR60:** Users can view correlations between mood, stress, sleep, and workouts

### 11. Mind - CBT & Journaling

- **FR61:** Users can have CBT-style conversations with AI (1/day free, unlimited premium)
- **FR62:** Users can write journal entries (end-to-end encrypted)
- **FR63:** AI can analyze journal sentiment and suggest coping strategies (opt-in only)
- **FR64:** Users can view journal history
- **FR65:** Users can export journal entries

### 12. Mind - Mental Health Screening

- **FR66:** Users can complete anxiety screening (GAD-7, 7 questions)
- **FR67:** Users can complete depression screening (PHQ-9, 9 questions)
- **FR68:** System tracks screening scores over time
- **FR69:** System provides crisis resources if score indicates severe symptoms (score >15 GAD-7, >20 PHQ-9)
- **FR70:** System recommends professional help for high scores

### 13. Mind - Breathing & Sleep

- **FR71:** Users can access 5 breathing exercises (Box, 4-7-8, Calm, Energizing, Sleep)
- **FR72:** System provides visual guides and haptic feedback for breathing rhythm
- **FR73:** Users can access sleep meditations and sleep stories (10-30 min)
- **FR74:** Users can set sleep timer for auto-stop
- **FR75:** Users can play ambient sounds (rain, ocean, forest)
- **FR76:** Users can complete gratitude exercises ("3 Good Things")

### 14. Cross-Module Intelligence (Killer Feature)

- **FR77:** System detects high stress (Mind) + heavy workout scheduled (Fitness) → suggests light session
- **FR78:** System detects poor sleep (<6 hours) + morning workout → suggests afternoon workout instead
- **FR79:** System detects high workout volume (Fitness) + elevated stress → recommends rest day
- **FR80:** System correlates sleep quality with workout performance and provides insights
- **FR81:** System suggests meditation (Mind) when Life Coach detects stress spike
- **FR82:** System displays max 1 cross-module insight per day
- **FR83:** Users can dismiss, save, or act on cross-module insights
- **FR84:** System learns from user responses to insights and improves recommendations

### 15. Gamification & Retention

- **FR85:** System tracks streaks for workouts, meditations, and daily check-ins
- **FR86:** Users earn badges for streak milestones (Bronze 7d, Silver 30d, Gold 100d)
- **FR87:** Users can use 1 streak freeze per week
- **FR88:** System celebrates milestone achievements with animations (confetti, badge unlock)
- **FR89:** Users can share milestone cards to social media
- **FR90:** System generates weekly summary reports (concrete stats: +5kg squat, stress -23%, 4 workouts)

### 16. Subscriptions & Monetization

- **FR91:** System supports free tier (Life Coach basic features)
- **FR92:** System supports in-app subscriptions (2.99 EUR, 5.00 EUR, 7.00 EUR tiers)
- **FR93:** Users can subscribe to individual modules or module packs
- **FR94:** Users can upgrade or downgrade subscription tiers
- **FR95:** Users can cancel subscription at any time
- **FR96:** System provides 14-day free trial of premium modules for new users
- **FR97:** System gracefully degrades features when subscription lapses (no data loss)

### 17. Data Management & Privacy

- **FR98:** System syncs user data across devices (Supabase Realtime)
- **FR99:** System encrypts sensitive data (journals, mental health assessments) end-to-end
- **FR100:** Users can export all their data (GDPR compliance)
- **FR101:** Users can request data deletion (GDPR right to be forgotten)
- **FR102:** System displays clear privacy policy and data usage information
- **FR103:** System operates offline-first for core features (Fitness logging, mood tracking)

### 18. Notifications

- **FR104:** Users can enable/disable push notifications by category
- **FR105:** System sends daily reminders (morning check-in, evening reflection, workout, meditation)
- **FR106:** System sends streak alerts (about to break, freeze available, milestone achieved)
- **FR107:** System sends cross-module insight notifications (max 1/day)
- **FR108:** System sends weekly summary notifications
- **FR109:** Users can set quiet hours for notifications
- **FR110:** Notifications deep link to relevant screens in app

### 19. Onboarding & Personalization

- **FR111:** New users complete onboarding flow (choose journey, set goals, grant permissions, choose AI personality)
- **FR112:** System adapts onboarding based on user's chosen journey (Fitness-first, Mind-first, Life Coach-first, or Full ecosystem)
- **FR113:** System provides interactive tutorial (<2 minutes)
- **FR114:** System prompts first morning check-in after onboarding
- **FR115:** System offers 14-day trial of all premium modules to new users

### 20. Settings & Profile

- **FR116:** Users can update personal settings (name, email, password, avatar)
- **FR117:** Users can manage notification preferences
- **FR118:** Users can choose preferred units (kg/lbs, cm/inches)
- **FR119:** Users can manage subscription and billing
- **FR120:** Users can contact support
- **FR121:** Users can view app version and provide feedback
- **FR122:** Users can enable/disable cross-module intelligence features
- **FR123:** Users can manage data privacy settings (opt-in/out of AI analysis)

---

**Total Functional Requirements: 123 FRs**

**Coverage Check:**
- ✅ Life Coach module (18 FRs: FR6-FR29)
- ✅ Fitness module (18 FRs: FR30-FR46)
- ✅ Mind module (31 FRs: FR47-FR76)
- ✅ Cross-Module Intelligence (8 FRs: FR77-FR84) - KILLER FEATURE
- ✅ Gamification & Retention (6 FRs: FR85-FR90)
- ✅ Subscriptions (7 FRs: FR91-FR97)
- ✅ Data & Privacy (6 FRs: FR98-FR103) - GDPR compliant
- ✅ Notifications (7 FRs: FR104-FR110)
- ✅ Onboarding (5 FRs: FR111-FR115)
- ✅ Account & Settings (13 FRs: FR1-FR5, FR116-FR123)
- ✅ Mobile-specific (covered in Platform Requirements and NFRs)

**Altitude Check:** ✅ All FRs state WHAT capabilities exist, not HOW they're implemented

**Completeness Check:** ✅ Every capability from MVP scope is represented

---

## Non-Functional Requirements

### Performance

**NFR-P1: App Responsiveness**
- Cold start time: <2 seconds (95th percentile)
- Hot start time: <500ms (95th percentile)
- Screen transitions: <300ms
- Button tap response: <100ms

**NFR-P2: Smart Pattern Memory Query**
- Pre-fill last workout data: <500ms p95 (killer feature must be fast)
- Exercise search: Results appear <200ms after typing stops
- Workout history load: <1s for 90 days of data

**NFR-P3: AI Response Times**
- Llama (self-hosted): <2s p95
- Claude API: <3s p95
- GPT-4 API: <4s p95 (acceptable tradeoff for quality)
- Timeout handling: Display clear error after 10s, suggest retry

**NFR-P4: Offline Performance**
- Fitness logging works 100% offline (no degradation)
- Mood tracking works 100% offline
- Cached meditation playback: <100ms to start
- Data sync on reconnection: <5s for typical session

**NFR-P5: App Size & Memory**
- Initial download: <50MB
- Memory usage (background): <150MB
- Memory usage (active): <250MB
- Cache size (meditations): <100MB total

### Security

**NFR-S1: Data Encryption**
- Journal entries: End-to-end encryption (E2EE)
- Mental health assessments (GAD-7, PHQ-9): E2EE
- Passwords: Hashed with bcrypt (Supabase Auth standard)
- Data in transit: HTTPS/TLS 1.3
- Data at rest: AES-256 encryption (Supabase default)

**NFR-S2: Authentication & Sessions**
- Session expiration: 30 days of inactivity
- Password requirements: Min 8 characters, 1 uppercase, 1 number, 1 special char
- Social auth: OAuth 2.0 (Google, Apple)
- MFA support: P1 (email-based 2FA)

**NFR-S3: GDPR Compliance**
- Right to access: Users can export all data (JSON + CSV formats)
- Right to deletion: Users can delete account + all data within 7 days
- Data retention: Deleted data purged after 30 days (backup retention)
- Privacy policy: Clear, visible, GDPR-compliant language
- Cookie consent: Not needed (mobile app, no web cookies)

**NFR-S4: Vulnerability Protection**
- API rate limiting: 100 requests/minute per user (prevent abuse)
- SQL injection protection: Supabase RLS policies
- XSS protection: Input sanitization for all user-generated content
- Regular security audits: Quarterly (P1)

**NFR-S5: Privacy**
- No selling user data to third parties (ever)
- AI analysis: Opt-in only for journal sentiment analysis
- Analytics: Anonymous only (no PII in analytics events)
- Third-party SDKs: Minimal (only essential: Supabase, Firebase Analytics, Sentry)

### Scalability

**NFR-SC1: User Capacity (Year 1-3)**
- Year 1: Support 5,000 active users
- Year 2: Support 25,000 active users
- Year 3: Support 75,000 active users
- Database: PostgreSQL (Supabase) scales vertically to 100k+ users

**NFR-SC2: API Scalability**
- Supabase API: 10,000 requests/sec (managed service)
- Supabase Realtime: 10,000 concurrent connections
- AI API calls: Rate-limited per user tier (prevent cost explosion)
  - Free: 3-5 AI calls/day
  - Standard: 20-30 AI calls/day
  - Premium: Unlimited (soft cap 200/day)

**NFR-SC3: Data Storage**
- Per-user storage estimate: 50MB/year (workouts, mood logs, meditations)
- Year 3 storage (75k users): 3.75TB
- Supabase storage pricing: $0.021/GB/month = ~$79/month (affordable)

**NFR-SC4: Cost Management**
- AI costs: <30% of revenue (hybrid model achieves this)
- Infrastructure costs: <20% of revenue (Supabase + self-hosted Llama)
- Total COGS target: <50% of revenue

### Integration

**NFR-I1: Wearable Integration (P1)**
- Apple Health: Import sleep, HRV, steps, workouts
- Google Fit: Import sleep, steps, workouts
- Data sync frequency: Every app open + background refresh (1x/hour)
- Fallback: Manual entry if no wearable connected

**NFR-I2: Export Integrations**
- Workout data: CSV export (compatible with Excel, Google Sheets)
- Journal entries: JSON + PDF export
- All user data: GDPR-compliant export (ZIP file with JSON)

**NFR-I3: Third-Party APIs**
- AI providers: OpenAI, Anthropic, self-hosted Llama
- Fallback strategy: Degrade to next tier if primary AI down
- API versioning: Pin to stable versions, test before upgrading

### Accessibility

**NFR-A1: Screen Reader Support**
- iOS VoiceOver: Full support for core flows (onboarding, workout logging, meditation playback)
- Android TalkBack: Full support for core flows
- Semantic labels: All interactive elements labeled
- Navigation: Logical tab order

**NFR-A2: Visual Accessibility**
- Color contrast: WCAG AA minimum (4.5:1 for body text, 3:1 for large text)
- Text scaling: Support iOS/Android system font sizes (up to 200%)
- Dark mode: P1 (reduces eye strain, battery usage)

**NFR-A3: Motor Accessibility**
- Touch targets: Minimum 44x44pt (iOS) / 48x48dp (Android)
- No time-based interactions (meditation timer is optional, not required)

**NFR-A4: Language Support (MVP)**
- English (EN-US, EN-GB)
- Polish (PL)
- Expandable: Architecture supports i18n (P1: German, Spanish, French)

### Reliability & Availability

**NFR-R1: Uptime**
- Target: 99.5% uptime (43 hours downtime/year acceptable for MVP)
- Supabase SLA: 99.9% (managed service advantage)
- Planned maintenance: Off-peak hours (2-5am UK/Poland time)

**NFR-R2: Error Handling**
- Crash rate: <0.5% (Firebase Crashlytics monitoring)
- Error tracking: Sentry for backend errors
- User-facing errors: Clear, actionable messages (no technical jargon)
- Graceful degradation: Offline mode when no internet, cached AI responses when APIs down

**NFR-R3: Data Integrity**
- Sync conflicts: Last-write-wins (Supabase Realtime default)
- Data validation: Server-side validation for all writes
- Backup frequency: Daily automated backups (Supabase managed)
- Disaster recovery: Point-in-time recovery to 7 days ago

### Compliance & Legal

**NFR-C1: GDPR (EU)**
- Data processing agreement (DPA) with Supabase
- Privacy policy prominently displayed
- Consent for data collection (opt-in analytics)
- Right to access, rectification, deletion, portability

**NFR-C2: App Store Compliance**
- iOS: App Store Review Guidelines 2025
- Android: Google Play Developer Program Policies
- Privacy nutrition labels: Accurate data collection disclosure
- In-app purchases: Follows platform guidelines (30% cut year 1, 15% year 2+)

**NFR-C3: Content Rating**
- PEGI 12+ / ESRB Teen
- Justification: Mental health content (anxiety/depression screening), no violent or sexual content

**NFR-C4: Mental Health Disclaimer**
- Clear disclaimer: "LifeOS is not a replacement for professional mental health care"
- Crisis resources: Links to suicide hotlines (UK: 116 123, Poland: 116 123)
- High-risk screening: Recommend professional help for GAD-7 >15, PHQ-9 >20

### Monitoring & Analytics

**NFR-M1: Analytics Events**
- User behavior: Anonymous events (workout logged, meditation completed, goal set)
- Retention tracking: DAU, WAU, MAU, Day 1/3/7/30 retention
- Conversion tracking: Free → Paid funnel
- Performance monitoring: Screen load times, API response times

**NFR-M2: Crash & Error Monitoring**
- Crash reporting: Firebase Crashlytics (iOS + Android)
- Error tracking: Sentry for backend (Supabase Edge Functions)
- Alert thresholds: >1% crash rate → page dev immediately

**NFR-M3: Business Metrics Dashboard**
- MRR, ARR, churn rate
- CAC, LTV, LTV:CAC ratio
- Subscription tier distribution
- AI cost per user (monitor 30% budget)

---

**Total Non-Functional Requirements: 37 NFRs**

**Categories:**
- ✅ Performance (5 NFRs)
- ✅ Security (5 NFRs) - Critical for mental health data
- ✅ Scalability (4 NFRs) - Supports 75k users by Year 3
- ✅ Integration (3 NFRs) - Wearables P1, export always
- ✅ Accessibility (4 NFRs) - WCAG AA, screen reader support
- ✅ Reliability (3 NFRs) - 99.5% uptime, <0.5% crash rate
- ✅ Compliance (4 NFRs) - GDPR, App Store, mental health disclaimers
- ✅ Monitoring (3 NFRs) - Retention, performance, business metrics
- ✅ Mobile-Specific (covered in Platform Requirements section)

---

## PRD Summary

### What We've Captured

**Requirements Overview:**
- **123 Functional Requirements** across 20 capability areas
- **37 Non-Functional Requirements** across 8 categories (Performance, Security, Scalability, Integration, Accessibility, Reliability, Compliance, Monitoring)
- **MVP Scope:** 3 modules (Life Coach FREE, Fitness 2.99 EUR, Mind 2.99 EUR)
- **Target Platform:** iOS 14+ & Android 10+ (Flutter cross-platform)
- **Domain:** General wellness (low complexity, no regulatory requirements)

### Product Value Summary

**LifeOS delivers unique value through Cross-Module Intelligence** - the only wellness app where Fitness, Mind, and Life Coach modules communicate to provide holistic optimization. This creates a moat that competitors (Calm, Headspace, Noom, Freeletics) cannot easily replicate.

**Key Differentiators:**
1. **Cross-Module Intelligence:** Modules talk to each other (12-18 month lead time for competitors)
2. **Modular Pricing:** Pay only for what you need (2.99 / 5.00 / 7.00 EUR)
3. **Hybrid AI:** User choice (Llama/Claude/GPT-4) with 30% cost budget
4. **60-70% Cost Savings:** vs multi-app stack (£60/year vs £320/year)
5. **Genuine Free Tier:** Life Coach always free (not crippled trial)

**Success Metrics:**
- **North Star:** 10-12% Day 30 retention (3x industry average)
- **Business:** £15k ARR Y1 → £225k ARR Y3
- **Quality:** 4.5+ App Store rating, NPS 50+, <0.5% crash rate

### Next Steps

Based on your Enterprise Method workflow path, you can:

**Option A: UX Design First** (Recommended for mobile app with complex UI)
- `workflow create-design`
- Design user experience and visual system
- Epic breakdown can incorporate UX details later (richer context)

**Option B: Architecture First**
- `workflow create-architecture`
- Define technical architecture (Supabase schema, API contracts, AI orchestration)
- Epic breakdown created after with full technical context

**Option C: Epic Breakdown Now** (Optional)
- `workflow create-epics-and-stories`
- Create basic epic structure from PRD
- Can be enhanced later with UX/Architecture context

**Recommendation:** Do UX Design first (mobile app benefits from visual mockups), then Architecture, then create epics with full context. This gives downstream teams (architects, developers) the richest possible input.

---

_This PRD captures the essence of LifeOS - a modular AI-powered life operating system that unifies wellness through cross-module intelligence, delivering 60-70% cost savings and 3x industry retention through features like Smart Pattern Memory, AI-powered daily planning, and holistic mental health support._

_Created through collaborative discovery between Mariusz and AI Product Manager (BMAD Methodology)._

**Document Status:** ✅ COMPLETE - Ready for UX Design & Architecture

---

