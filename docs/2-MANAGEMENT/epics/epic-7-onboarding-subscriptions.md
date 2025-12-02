# Epic 7: Onboarding & Subscriptions

<!-- AI-INDEX: onboarding, subscriptions, trial, pricing, iap, in-app-purchase, free-tier, premium -->

**Goal:** Deliver smooth onboarding flow, 14-day trial, subscription management, and payment processing.

**Value:** Users get personalized onboarding, can try premium features, and subscribe easily.

**FRs Covered:** FR91-FR97 (Subscriptions), FR111-FR115 (Onboarding)

**Dependencies:** Epic 1 (auth)

**Stories:** 7

---

## Story 7.1: Onboarding Flow - Choose Your Journey

**Phase:** MVP
**Status:** Complete

**As a** new user
**I want** personalized onboarding based on my goals
**So that** the app emphasizes the module most relevant to me

### Acceptance Criteria

1. Onboarding starts after account creation (Story 1.1)
2. Screen 1: Welcome ("Welcome to LifeOS")
3. Screen 2: Choose journey (4 options):
   - "I want to get fit" (Fitness-first)
   - "I want to reduce stress" (Mind-first)
   - "I want to organize my life" (Life Coach-first)
   - "I want it all" (Full ecosystem)
4. Onboarding flow adapts based on choice:
   - Fitness-first → Show workout logging tutorial first
   - Mind-first → Show meditation tutorial first
   - Life Coach-first → Show morning check-in tutorial first
   - Full ecosystem → Balanced overview of all 3 modules
5. Progress dots shown (5 screens total)
6. User can skip onboarding (link at bottom)

**FRs:** FR111, FR112

### UX Notes
- Welcome screen: Hero image (LifeOS logo, gradient background)
- Journey cards: Large, tappable (44x44pt minimum)
- Progress dots: Bottom center

### Technical Notes
- onboarding_state table (user_id, journey_choice, completed)
- User preference saved for personalization

---

## Story 7.2: Onboarding - Set Initial Goals & Choose AI Personality

**Phase:** MVP
**Status:** Complete

**As a** new user
**I want** to set 1-3 initial goals and choose AI personality
**So that** the app is personalized from day one

### Acceptance Criteria

1. Screen 3: Set goals (1-3)
2. Goal input: Title + Category (dropdown)
3. Examples shown based on journey choice:
   - Fitness: "Lose 10kg", "Run 5km"
   - Mind: "Meditate daily", "Reduce anxiety"
   - Life Coach: "Wake up at 6am", "Read 20 pages/day"
4. Screen 4: Choose AI personality (2 options):
   - Sage (Calm, wise, supportive) - "Let's take this one step at a time"
   - Momentum (Energetic, motivational) - "Let's crush this! You've got this!"
5. User can preview AI personality (sample message shown)
6. Selection saved (affects all AI interactions)

**FRs:** FR21, FR113

### UX Notes
- Goal form: Simple text input + category dropdown
- "+ Add another goal" button (max 3)
- AI personality cards: Large, with sample message preview
- Tap card to select (highlighted border)

### Technical Notes
- Goals created in goals table (Story 2.3)
- AI personality saved in user_settings table (ai_personality='sage'|'momentum')

---

## Story 7.3: Onboarding - Permissions & Interactive Tutorial

**Phase:** MVP
**Status:** Complete

**As a** new user
**I want** to grant permissions and see a quick tutorial
**So that** I understand how to use the app

### Acceptance Criteria

1. Screen 5: Permissions (push notifications, health data access P1)
2. Push notifications:
   - Explanation: "Daily reminders, streak alerts, smart insights (max 1/day)"
   - "Enable Notifications" button
   - "Maybe Later" link
3. Interactive tutorial (based on journey):
   - Fitness: Log 1 sample workout (guided walkthrough)
   - Mind: Complete 2-min breathing exercise
   - Life Coach: Complete first morning check-in
4. Tutorial completion: Celebration ("You're all set!")
5. Tutorial skippable ("Skip Tutorial" link)
6. 14-day trial banner shown: "Try all premium features free for 14 days"

**FRs:** FR114, FR115

### UX Notes
- Permissions: Clear explanations (not scary)
- Tutorial: Overlay tooltips pointing to UI elements
- "Next" button to advance tutorial steps

### Technical Notes
- Permission requests: iOS notifications permission, Android permission
- Tutorial state saved (completed=true after tutorial)
- Trial activation: Set trial_end_date = now + 14 days

---

## Story 7.4: Free Tier (Life Coach Basic)

**Phase:** MVP
**Status:** Complete

**As a** free tier user
**I want** access to Life Coach basic features
**So that** I can try LifeOS without paying

### Acceptance Criteria

1. Free tier ALWAYS includes:
   - Life Coach: Daily planning, 3 goals max, Morning/evening check-ins, AI chat (3-5/day with Llama)
   - Mind: Mood tracking (ALWAYS FREE)
   - Fitness: Basic workout logging (no Smart Pattern Memory, limited templates)
2. Free tier limitations shown clearly (not hidden)
3. Premium features shown in "locked" state (with "Upgrade" CTA)
4. No credit card required for free tier
5. Free tier never expires (user can stay free forever)

**FRs:** FR91, FR92

### UX Notes
- Locked features: Gray overlay + lock icon + "Premium" badge
- Tap locked feature → Upgrade modal
- Free tier = full Life Coach (not crippled)

### Technical Notes
- subscription_tier column (user table): 'free' (default)
- Feature checks: if (tier == 'free') { limit }

---

## Story 7.5: 14-Day Trial (All Premium Features)

**Phase:** MVP
**Status:** Complete

**As a** new user
**I want** 14-day trial of all premium features
**So that** I can decide if LifeOS is worth paying for

### Acceptance Criteria

1. Trial auto-starts after onboarding (no credit card required)
2. Trial includes:
   - Fitness: Full Smart Pattern Memory, all templates, unlimited workouts
   - Mind: Full meditation library (100+ meditations), unlimited CBT chat (Claude/GPT-4)
   - Life Coach: Unlimited goals, unlimited AI chat (Claude/GPT-4)
3. Trial countdown shown: "13 days left in trial"
4. Trial end reminder: Push notification 3 days before trial ends
5. Trial end: Features revert to free tier (graceful degradation, no data loss)
6. User can subscribe anytime during trial (trial ends immediately)

**FRs:** FR96

### UX Notes
- Trial banner: Subtle, not annoying (top of Home tab)
- "Subscribe Now" CTA in trial banner
- Trial countdown: "X days left"

### Technical Notes
- trial_end_date column (user table)
- Feature checks: if (now < trial_end_date || tier == 'premium') { allow }
- Cron job: Check trial expiration daily

---

## Story 7.6: Subscription Management (In-App Purchase)

**Phase:** MVP
**Status:** Complete

**As a** user wanting premium features
**I want** to subscribe to a module or plan
**So that** I can unlock full LifeOS

### Acceptance Criteria

1. Subscription tiers (in-app purchase):
   - 2.99 EUR/month: Any 1 module (Fitness OR Mind)
   - 5.00 EUR/month: 3-Module Pack (Life Coach + Fitness + Mind)
   - 7.00 EUR/month: Full Access + Premium AI (GPT-4 unlimited)
2. Subscription screen accessible from Profile → "Subscription"
3. Current plan shown (Free, 1-Module, 3-Module, Full Access)
4. Upgrade/downgrade options shown
5. Regional pricing: UK (GBP), Poland (PLN), EU (EUR)
6. Purchase via App Store (iOS) or Google Play (Android)
7. Subscription auto-renews monthly (user can cancel anytime)
8. Subscription status synced across devices (Supabase)

**FRs:** FR92, FR93, FR94

### UX Notes
- Pricing cards: Clear tiers (Free, 1-Module, 3-Module, Full)
- "Popular" badge on 3-Module Pack
- "Current Plan" highlighted (Teal border)
- "Subscribe" button (Teal)

### Technical Notes
- In-app purchase: in_app_purchase package (Flutter)
- RevenueCat or Supabase webhook for subscription status
- subscription_tier column updated on purchase

---

## Story 7.7: Cancel Subscription & Graceful Degradation

**Phase:** MVP
**Status:** Complete

**As a** subscribed user
**I want** to cancel my subscription anytime
**So that** I have flexibility without losing my data

### Acceptance Criteria

1. "Cancel Subscription" button on Subscription screen
2. Cancellation warning: "Your subscription will end on [date]. You'll keep premium until then."
3. User confirms cancellation (not instant, end of billing period)
4. Subscription status: "Active until [date]" (grace period)
5. After cancellation: Features revert to free tier
6. Graceful degradation:
   - Goals >3 → Read-only (can't create new, can view old)
   - Meditation library → Locked (3 rotating free meditations)
   - AI chat → Limited to 3-5/day (Llama)
7. NO data loss (all workouts, moods, journals remain)
8. User can re-subscribe anytime (data intact)

**FRs:** FR95, FR97

### UX Notes
- Cancel button: Red (warning color)
- Confirmation modal: Clear explanation of what happens
- "Keep Subscription" option (prevent accidental cancel)

### Technical Notes
- subscription_status column: 'active', 'cancelled', 'expired'
- Grace period: subscription_end_date stored
- Feature checks: if (now < subscription_end_date) { allow premium }

---

## Related Documents

- [PRD-overview.md](../../1-BASELINE/product/PRD-overview.md) - Product overview
- [epic-1-core-platform.md](./epic-1-core-platform.md) - Core Platform (auth)
- [ARCH-overview.md](../../1-BASELINE/architecture/ARCH-overview.md) - Architecture

---

*7 Stories | FR91-FR97, FR111-FR115 | Onboarding & Subscriptions*
