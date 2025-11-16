# LifeOS - Brainstorming Session Answers

**Project Name:** LifeOS (Life Operating System)
**Tagline:** "Your AI-powered operating system for life"
**Date:** 2025-01-16
**Status:** Ready for Analyst Agent Brainstorming Session

---

## 📋 COMPLETE ANSWERS - User Input

### MONETIZATION

**1. Pricing Structure:**
```
FREE TIER:
- Life Coach module (basic features)
- 14-day trial of any premium module

SINGLE MODULE: 2.99 EUR/month
- Choose 1 module (Fitness, Mind, or other)

3-MODULE PACK: 5.00 EUR/month
- Any 3 modules

FULL ACCESS (LifeOS+): 7.00 EUR/month
- All modules unlocked
- Premium AI (GPT-4)
- No ads
```

**2. Trial Period:** 14 days (full access to selected module)

**3. Subscription Model:** Subscription-only (no lifetime purchase)

**4. Monetization Strategy:**
- Primary: Subscriptions
- Secondary: Ads in free tier (optional/potential)

**5. Regional Pricing:** YES
- Prices adjusted by region (2.99 EUR = ~13 PLN in Poland)
- Target: UK + Poland initially, then EU

---

### FREE TIER DETAILS

**Life Coach Module (FREE):**
- ✅ Daily plans generation (basic)
- ✅ 3 goals tracking (max)
- ✅ Limited AI conversations (3-5 per day with Llama/Claude)
- ✅ Progress tracking (basic charts)
- ❌ Advanced insights (premium only)
- ❌ Unlimited AI chat (premium only)
- ❌ GPT-4 access (premium only)

**Fitness Module (14-day trial, then):**
- ✅ Basic workout logging
- ❌ Advanced charts (premium)
- ❌ AR form analysis (premium)
- ❌ Pattern memory AI (premium)

**Mind Module (14-day trial, then):**
- ✅ 3 guided meditations (rotating selection)
- ✅ Daily mood tracking (always free)
- ✅ 1 CBT chat conversation per day
- ❌ Full meditation library (premium)
- ❌ Unlimited CBT chat (premium)
- ❌ Breathing exercises variety (premium)

**Ads:**
- Free tier: May show ads
- Premium tier: Ad-free

---

### TECHNOLOGY - AI INFRASTRUCTURE

**AI Provider Strategy: HYBRID + USER CHOICE**

**1. AI Models by Module:**

| Module | Free Tier | Standard (2.99-5 EUR) | Premium (7 EUR) |
|--------|-----------|----------------------|----------------|
| **Life Coach** | Llama 3 (self-hosted) | Claude | GPT-4 |
| **Mind & Emotion** | Claude (limited) | Claude | GPT-4 |
| **Fitness** | Rule-based + Llama | Claude | GPT-4 |

**2. User Choice:**
- Users can select preferred AI model in settings
- Options: Llama (fast, basic) / Claude (balanced) / GPT-4 (best, premium only)
- UI shows model comparison (speed, quality, cost)

**3. AI Budget:**
- **30% of revenue** can go to AI costs
- At 5 EUR/month (3-module pack): 1.50 EUR/user/month for AI
- At 7 EUR/month (full): 2.10 EUR/user/month for AI

**Breakdown:**
- Llama (self-hosted): ~0.10 EUR/user/month
- Claude: ~0.30-0.50 EUR/user/month
- GPT-4: ~0.50-1.00 EUR/user/month

**4. Fallback Strategy:**
- ✅ Show clear error message: "AI unavailable: [reason]"
- ✅ Reasons: "No internet connection" / "Daily limit reached" / "Service temporarily down"
- ✅ Offer cached responses when possible
- ✅ Degrade gracefully (Llama → Claude → GPT-4 fallback chain)

**5. Rate Limiting:**
- Free tier: 3-5 AI conversations/day
- Standard: 20-30 AI conversations/day
- Premium: Unlimited (with fair use policy)

---

### TECHNOLOGY - BACKEND

**Backend Infrastructure: Supabase**

**Why Supabase:**
- ✅ Open-source (PostgreSQL)
- ✅ Self-hostable (if needed in future)
- ✅ Cost-effective long-term
- ✅ Realtime subscriptions (module data sync)
- ✅ Row-level security (multi-tenant by design)
- ✅ Auth built-in (email, Google, Apple)

**Architecture:**
- **Database:** PostgreSQL (via Supabase)
- **Realtime sync:** Supabase Realtime
- **Auth:** Supabase Auth
- **Storage:** Supabase Storage (progress photos, meditation audio)
- **Edge Functions:** Supabase Edge Functions (AI orchestration)

**AI Integration:**
- Self-hosted Llama on separate server (cost optimization)
- Claude + GPT-4 via cloud APIs (Anthropic + OpenAI)
- Edge Functions orchestrate model selection

**Data Model:**
- Modular schema (each module has its own tables)
- Shared core: users, subscriptions, settings
- Module-specific: fitness_workouts, mind_meditations, lifecoach_plans

---

### MARKET & GEOGRAPHY

**1. Languages (MVP):**
- ✅ English (primary)
- ✅ Polish (secondary)
- UI fully translated EN + PL
- AI conversations: EN + PL (GPT-4 and Claude support both)

**2. Target Markets:**

**Phase 1 (MVP):**
- 🇬🇧 United Kingdom
- 🇵🇱 Poland

**Phase 2 (Post-MVP, 6-12 months):**
- 🇪🇺 European Union (all countries)
- Additional languages: German, French, Spanish

**Phase 3 (Future):**
- 🌍 Global expansion (US, Canada, Australia)

**3. Regional Pricing:**
- **UK:** 2.99 GBP / 5 GBP / 7 GBP
- **Poland:** 12.99 PLN / 21.99 PLN / 30.99 PLN
- **EU:** 2.99 EUR / 5 EUR / 7 EUR

**App Store Optimization:**
- Separate listings for UK App Store (English) and Polish App Store (Polish)
- Keywords localized per market
- Screenshots and descriptions translated

---

### MVP SCOPE - LIFE COACH MODULE

**Must-Have Features (MVP):**

1. **Daily Plan Generation** ✅
   - AI generates personalized daily plan
   - Considers: sleep, energy, mood, goals, calendar
   - Suggests: workouts, meditations, tasks, learning
   - Updates throughout day based on progress

2. **Goal Tracking (Max 3 Goals)** ✅
   - Users set up to 3 active goals
   - Categories: Fitness, Mental Health, Career, Relationships, Learning
   - AI suggests tasks toward goals
   - Progress visualization (simple charts)

3. **AI Conversations** ✅
   - Chat interface with AI coach
   - Free: 3-5 conversations/day (Llama/Claude)
   - Premium: Unlimited (GPT-4)
   - Use cases: motivation, advice, reflection

4. **Progress Tracking** ✅
   - Habit streaks
   - Goal progress %
   - Module activity summary
   - Weekly/monthly reports

5. **Morning/Evening Check-ins**
   - Morning: Mood, energy, sleep quality
   - Evening: Reflection, accomplishments, tomorrow prep
   - AI uses data for next day's plan

6. **Integration with Modules**
   - Import workout data from Fitness
   - Import mood/stress from Mind
   - Suggest module activities in daily plan

7. **Push Notifications**
   - Daily plan ready notification (morning)
   - Task reminders
   - Motivational messages
   - Streak milestones

**Deferred to Phase 2:**
- Voice conversations (speech-to-text)
- Calendar integration (Google Calendar, Outlook)
- Advanced analytics
- Social features (accountability partners)
- Habit RPG gamification (moved to Talent Tree module)

---

### MVP SCOPE - MIND & EMOTION MODULE

**Must-Have Features (MVP):**

1. **Guided Meditations** ✅
   - Library: 20-30 meditations (MVP)
   - Lengths: 5min, 10min, 15min, 20min
   - Themes: Stress relief, Sleep, Focus, Anxiety, Gratitude
   - Free: 3 meditations (rotating)
   - Premium: Full library
   - Audio quality: Professional recording or AI-generated (TBD)

2. **Breathing Exercises** ✅
   - 5 basic techniques: Box breathing, 4-7-8, Calm breathing, Energizing breath, Sleep breath
   - Visual guides with animations
   - Haptic feedback (phone vibrates with breath rhythm)
   - Timer and progress tracking

3. **CBT Chat with AI** ✅
   - Conversational AI with CBT training
   - Free: 1 conversation/day (Claude)
   - Premium: Unlimited (Claude or GPT-4)
   - Disclaimers: Not a replacement for therapy
   - Crisis resources: Links to helplines

4. **Daily Mood Tracking** ✅
   - Always free (core feature)
   - Simple mood selector (1-5 scale + emoji)
   - Optional: Note about mood
   - Trends and insights (weekly/monthly)
   - Shared with Life Coach for daily planning

5. **Stress Level Tracking**
   - Similar to mood tracking
   - Integration with Fitness (detect overtraining)
   - Burnout risk alerts

6. **Journaling with AI Insights**
   - Free-form text journaling
   - AI analyzes sentiment (optional, opt-in)
   - Suggests coping strategies based on entries
   - Privacy: End-to-end encrypted

**Additional Features (User Request - Add These):**
7. **Sleep Meditations**
   - Dedicated sleep meditation category
   - 10-30 min guided sleep stories
   - Ambient sounds library

8. **Anxiety Screening (GAD-7)**
   - Standardized anxiety assessment
   - Track over time
   - Suggest resources if score is high

9. **Depression Screening (PHQ-9)**
   - Standardized depression assessment
   - Monthly check-ins (optional)
   - Crisis intervention if severe

10. **Gratitude Exercises**
    - Daily gratitude prompts
    - "3 Good Things" exercise
    - Gratitude journal

**Deferred to Phase 2:**
- Communication training scenarios (RPG-style)
- Group meditations (social feature)
- Therapist marketplace
- Wearable integration (HRV for stress)

---

### MVP SCOPE - FITNESS MODULE

**Already Planned (43 SP, 3 Sprints):**
- All features from GymApp planning (see `modules/module-fitness/sprint-planning-summary.md`)

**Additional Features for LifeOS Integration:**

1. **Export to Life Coach** ✅
   - Share workout completion status
   - Share energy levels (pre/post workout)
   - Share rest days and recovery needs

2. **Import from Life Coach** ✅
   - Receive suggested workout from daily plan
   - AI recommends: "Today is a rest day" or "Good day for heavy lifting"

3. **Mood-Based Workout Intensity**
   - Import stress level from Mind module
   - Adjust workout difficulty (low stress = harder workout, high stress = easier/recovery)

4. **Integration with Talent Tree (Phase 2)**
   - Earn Fitness XP
   - Unlock achievements (First 10kg squat, 100 workouts logged, etc.)

---

### TIMELINE

**Target: Realistic (4-6 months for MVP)**

**Month 1-2: Planning & Architecture**
- Week 1-2: Brainstorming, Product Brief, PRD
- Week 3-4: Architecture design, Tech setup (Supabase, AI models)
- Week 5-6: UX design, Sprint planning
- Week 7-8: Dev environment setup, CI/CD

**Month 3-4: Development (Core Modules)**
- Sprint 1-3: Fitness module (already planned, 24 days)
- Sprint 4-6: Life Coach module core features
- Sprint 7-9: Mind module core features
- Parallel: Backend (Supabase), Auth, Subscription system

**Month 5: Integration & Polish**
- Module integration (data sharing)
- AI orchestration layer
- UX polish
- Performance optimization

**Month 6: Testing & Launch Prep**
- Beta testing (internal + friends/family)
- Bug fixes
- App Store submission
- Marketing prep

**Launch Target: Month 6-7**

**Post-Launch:**
- Month 7-9: User feedback, iteration
- Month 10-12: Phase 2 modules (Talent Tree, Relationship AI, etc.)

---

### BRANDING & DESIGN

**1. Design Direction: Nike + Headspace Fusion**

**From Nike Training:**
- ✅ Energetic, motivational vibe
- ✅ Bold typography
- ✅ High-energy imagery (when appropriate)
- ✅ Clear CTAs ("Start Your Day", "Complete Plan")

**From Headspace:**
- ✅ Calm, zen aesthetic
- ✅ Friendly illustrations
- ✅ Soothing color palette
- ✅ Minimalist UI

**Fusion:**
- Energizing but not overwhelming
- Motivational but not aggressive
- Clean and focused
- Playful illustrations where appropriate

**2. AI Personality: User Choice (2 Options)**

Users select their preferred AI coach personality:

**Option 1: "Sage" (Headspace-style)**
- Calm, gentle, supportive
- Uses phrases like: "Let's take a moment...", "You're doing great"
- Meditation-coach vibe
- Good for: Mindfulness-focused users, anxiety management

**Option 2: "Momentum" (Nike-style)**
- Energetic, motivational, direct
- Uses phrases like: "Let's crush today!", "You've got this!"
- Personal trainer vibe
- Good for: Goal-driven users, fitness enthusiasts

**Implementation:**
- System prompt changes based on selection
- User can switch anytime in settings
- Affects: Life Coach conversations, Mind CBT chat

**3. Color Scheme**

**Option A: Based on GymApp Design (Recommended)**

From `ux-design-specification.md`, the recommended colors were:
- **Primary:** Indigo (#3F51B5 - trust, professionalism)
- **Secondary:** Teal (#009688 - energy, growth)
- **Accent:** Amber (#FFC107 - motivation, achievement)

**Adaptation for LifeOS:**
- **Primary:** Deep Blue (#1E3A8A - calm, trust, intelligence)
- **Secondary:** Energetic Teal (#14B8A6 - growth, vitality)
- **Accent (Momentum mode):** Electric Orange (#F97316 - energy, motivation)
- **Accent (Sage mode):** Soft Purple (#A855F7 - calm, mindfulness)
- **Neutrals:** Gray scale (white to charcoal)

**Module Color Coding (Subtle):**
- Life Coach: Blue (planning, intelligence)
- Fitness: Orange (energy, movement)
- Mind: Purple (calm, reflection)

**Dark Mode:**
- Yes, full dark mode support
- OLED-friendly (pure black backgrounds)

---

### APPROACH & RISK

**Balanced Approach:**

**What "Balanced" Means:**

1. **Scope:**
   - ✅ 3 MVP modules (Life Coach + Fitness + Mind)
   - ⏳ Defer 7 modules to Phase 2
   - ✅ Focus on core features only

2. **Technology:**
   - ✅ Proven stack (Flutter, Supabase)
   - ✅ Hybrid AI (Llama + Claude + GPT-4)
   - ✅ Self-host Llama (cost savings)
   - ✅ Use cloud APIs for Claude/GPT-4 (speed to market)

3. **Timeline:**
   - ✅ 4-6 months to MVP launch
   - ✅ Don't rush, don't over-engineer
   - ✅ Beta test before public launch

4. **Development:**
   - ✅ Solo developer (manage scope carefully)
   - ✅ Use existing Fitness planning (head start)
   - ✅ Leverage AI for content generation

5. **Launch:**
   - ✅ Soft launch (UK + Poland only)
   - ✅ Gather feedback, iterate
   - ✅ Expand to EU after validation

**Risk Mitigation:**
- Fitness module fully planned (reduces unknowns)
- Hybrid AI reduces vendor lock-in
- Supabase is open-source (can self-host if needed)
- Modular architecture (modules can launch independently)

---

### AI COST MODEL

**Revenue per User Tier:**
- Free: 0 EUR (ad revenue: ~0.10 EUR/month)
- Single Module: 2.99 EUR/month
- 3-Module Pack: 5.00 EUR/month
- Full Access: 7.00 EUR/month

**AI Budget (30% of revenue):**
- Free: 0.03 EUR/month (ads) → Llama only
- Single: 0.90 EUR/month → Llama + Claude
- 3-Module: 1.50 EUR/month → Claude + limited GPT-4
- Full: 2.10 EUR/month → GPT-4 unlimited

**AI Cost per Model (estimated):**
- Llama (self-hosted): 0.10 EUR/user/month
- Claude: 0.30-0.50 EUR/user/month (20-30 convos)
- GPT-4: 0.50-1.00 EUR/user/month (15-25 convos)

**Distribution Strategy:**
- Free users: 90% Llama, 10% Claude (trial)
- Standard users: 70% Claude, 30% GPT-4
- Premium users: 100% GPT-4

**Premium Feature: Model Selection:**
- Premium users can choose: "Always use GPT-4" (default) or "Smart mix" (uses Claude when appropriate to extend quota)

---

### LEGAL & COMPLIANCE

**1. Mental Health Disclaimers:**
- ✅ "Mind module is not therapy"
- ✅ Crisis resources (suicide hotlines)
- ✅ Professional review of CBT content

**2. Data Privacy:**
- ✅ GDPR compliant (EU, UK, Poland)
- ✅ End-to-end encryption for journals
- ✅ User data export (GDPR right to data)
- ✅ Account deletion (GDPR right to erasure)

**3. AI Usage:**
- ✅ Disclose AI usage to users
- ✅ Don't train on user data (unless explicit opt-in)
- ✅ Allow users to delete conversation history

**4. Subscriptions:**
- ✅ Clear cancellation policy
- ✅ Easy cancellation (1 tap in app)
- ✅ Pro-rated refunds (if applicable)

---

## 📊 SUMMARY TABLE

| Category | Decision |
|----------|----------|
| **Project Name** | LifeOS (Life Operating System) |
| **Tagline** | "Your AI-powered operating system for life" |
| **Pricing** | 2.99 / 5.00 / 7.00 EUR per month |
| **Trial** | 14 days |
| **Monetization** | Subscription + Ads (free tier) |
| **AI Strategy** | Hybrid: Llama (free) + Claude (standard) + GPT-4 (premium) |
| **AI Budget** | 30% of revenue |
| **Backend** | Supabase (PostgreSQL) |
| **Languages** | English + Polish (MVP) |
| **Markets** | UK + Poland → EU → Global |
| **MVP Modules** | Life Coach + Fitness + Mind |
| **Timeline** | 4-6 months (realistic) |
| **Design** | Nike + Headspace fusion |
| **AI Personality** | User choice: "Sage" or "Momentum" |
| **Colors** | Blue (primary), Teal (secondary), Orange/Purple (accents) |
| **Approach** | Balanced (proven tech, focused scope) |

---

## ✅ NEXT STEPS

1. **Update all documentation** with "LifeOS" name
2. **Run Brainstorming Session** with analyst agent
3. **Create Product Brief** for LifeOS ecosystem
4. **Design Architecture** (modular + AI infrastructure)
5. **Create PRD** (ecosystem-level requirements)
6. **Sprint Planning** (MVP: 3 modules)

---

**Document Version:** 1.0
**Created:** 2025-01-16
**Status:** COMPLETE - Ready for Analyst Agent
**Next:** Brainstorming Session → Product Brief
