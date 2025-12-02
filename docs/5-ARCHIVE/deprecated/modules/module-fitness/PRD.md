# GymApp - Product Requirements Document

**Author:** Mariusz
**Date:** 2025-11-15
**Version:** 1.0

---

## Executive Summary

*(Building as we discover...)*

### What Makes This Special

**GymApp is the first fitness tracker that saves users 17 hours/year while achieving 3x industry retention, powered by empathy-driven AI at 60% lower cost than competitors.**

**User Impact First:** Every feature solves a real frustration - tedious 5-minute logging becomes 2 seconds, invisible progress becomes concrete "+5kg squat!", lonely gym experience becomes supportive mikroklub community.

**Business Viability:** £2.99/month (vs FitBod £8), FREE progress charts (vs Strong £45/year paywall), proven freemium model with 4:1 LTV:CAC achieving £135k ARR by Year 3.

**Technical Innovation as Enabler:** Smart pattern memory (MVP killer feature), AI with empathy (P2 differentiation), BioAge tracking (P3 moat) - all serving the core mission of making fitness tracking effortless and motivating.

---

## Project Classification

**Technical Type:** Mobile Application (iOS + Android, Flutter cross-platform)
**Domain:** Health & Fitness (GDPR-regulated, health data privacy requirements)
**Complexity:** Level 2-3 (Commercial venture, enterprise-grade requirements, phased AI rollout)
**Business Model:** Hybrid Freemium (strong free tier + £2.99/mo premium)

**Project Context:**
- **Market:** UK + Poland fitness app market (£1.74B-£10.14B, 11-17% CAGR)
- **Competition:** Fragmented (Strong, JEFIT, FitBod, MyFitnessPal) - no dominant "AI coach with empathy" player
- **Go-to-Market:** Niche-first (Polish gym partnerships) → UK expansion → Viral social features
- **Timeline:** 3-month MVP (400 hours) → P1 (social, 6 months) → P2 (AI, 12 months) → P3 (moat, 24 months)

### Domain Context

**Health & Fitness App Regulations:**
- **GDPR Compliance:** Mandatory user consent, data export, account deletion, privacy policy
- **Health Data Privacy:** Workout data, body measurements, progress photos = personal health information
- **App Store Requirements:** Clear privacy practices, no health claims without disclaimers, content rating
- **User Safety:** No medical advice, encouragement of rest days, injury prevention disclaimers

**Industry Standards:**
- **Workout Data Schema:** Industry-standard exercise taxonomy, rep/set/weight formats
- **Integration Protocols:** Apple HealthKit, Google Fit, wearable APIs (Fitbit, Garmin, Whoop)
- **Accessibility:** WCAG 2.1 AA compliance for inclusive fitness access

---

## Success Criteria

**Philosophy: User Impact First, Business Viability Second**

GymApp succeeds when users love it and keep using it. Revenue is a lagging indicator of user value delivered, not the primary goal.

### Primary Success Metrics (User Impact)

**Month 6 Validation Criteria:**
- ✅ **Day 30 Retention: 10-12%** (3x industry average of 3-4%) - Proves product solves real problem
- ✅ **Smart Pattern Memory Adoption: 80%+** - Users experience "aha moment" (2 sec vs 5 min logging)
- ✅ **App Store Rating: 4.5+ stars** - Social proof of user satisfaction
- ✅ **NPS (Net Promoter Score): 50+** - Users actively recommend to friends
- ✅ **Weekly Workout Frequency: 3.5 avg** - Shows committed, engaged user base

**User Experience Benchmarks:**
- ✅ **Logging Speed: <2 minutes per workout** (competitive with Strong, 60% faster than manual)
- ✅ **Streak Completion: 70%+ maintain 7-day streak** (habit formation working)
- ✅ **Feature Adoption:** Progress charts 60%+, Weekly reports 70%+

### Secondary Success Metrics (Business Viability)

**Revenue targets are optimistic projections, NOT success criteria:**

**Year 1 (Validation Phase):**
- Target: £9k ARR (500 downloads, 250 paid @ 5% conversion)
- **Success threshold:** Break-even OR validated product-market fit (retention >10%)
- Philosophy: Revenue follows retention, not vice versa

**Year 2-3 (Growth Phase):**
- Target: £45k → £135k ARR
- **Success threshold:** Sustainable CAC <£25, LTV:CAC ratio >3:1
- Philosophy: Profitable unit economics matter more than absolute revenue

**Critical Business Metrics:**
- ✅ **CAC (Customer Acquisition Cost): £10-25** - Sustainable acquisition
- ✅ **LTV (Lifetime Value): £80** - Assumes 2.3 year retention
- ✅ **Free→Paid Conversion: 5-7%** - Industry benchmark
- ✅ **Monthly Churn: <10%** - Sticky product, long retention

### Technical Success Metrics

**MVP Launch (Month 3):**
- ✅ **400 hours development completed** - On-time, on-budget
- ✅ **iOS + Android live** - Both platforms simultaneously
- ✅ **Crash rate: <0.5%** - Stability = retention
- ✅ **Offline-first functional** - Core logging works without internet
- ✅ **GDPR compliant** - User data export, deletion, consent flows implemented

**Post-Launch Quality:**
- ✅ **App size: <50MB** - Fast download
- ✅ **Startup time: <2 seconds** - No friction
- ✅ **Zero critical security vulnerabilities** - Health data protected

### Go/No-Go Decision Points

**Month 3 (MVP Launch):**
- ❌ **If no Product Brief → PRD → MVP pipeline** → Process broken, restart planning
- ✅ **Pass:** MVP launched with 10 core features functional

**Month 6 (PMF Validation):**
- ❌ **If Day 30 retention <5%** → Product doesn't solve problem, PIVOT required
- ❌ **If App Store rating <3.5** → UX broken, redesign needed
- ❌ **If CAC >£25 in Polish niche** → GTM strategy failed, rethink marketing
- ✅ **Pass:** Retention >10%, Rating >4.3, CAC <£20 → Scale to UK

**Month 12 (Growth Decision):**
- ❌ **If growth <10% MoM OR conversion <3%** → Product-market fit weak, reassess
- ✅ **Pass:** Consistent growth, conversion >5% → Launch P1 features (mikroklub, tandem)

**Month 18 (AI Investment Decision):**
- ❌ **If AI features don't improve conversion to 7%+** → Reconsider AI investment ROI
- ✅ **Pass:** AI proves valuable → Continue to P2 (voice, mood adaptation)

**Success Philosophy:**
> "GymApp succeeds when users say 'I can't imagine going back to my old app.' Revenue follows inevitably from that user love."

---

## Product Scope

**Phased approach: Validate → Differentiate → Dominate**

### MVP - Minimum Viable Product (Months 0-3, 400 hours)

**Goal:** Prove GymApp solves the core problem (tedious logging + invisible progress) better than competitors.

**Must-Have Features (10 core):**

1. **Smart Pattern Memory Logging** ⭐ KILLER FEATURE
   - App remembers last workout for each exercise
   - Pre-fills sets/reps/weight ("Last time: 4×12, 90kg")
   - Reduces logging from 5 min → 2 seconds
   - Works offline (Drift local cache)

2. **Manual Workout Logging**
   - Fast, intuitive entry (match Strong app UX speed)
   - Exercise selection (search + browse library)
   - Sets/reps/weight with minimal taps
   - Rest timer between sets
   - Workout duration tracking

3. **Exercise Library (500+)**
   - Comprehensive database (compound + isolation)
   - Filter by muscle group, equipment
   - Search functionality
   - Descriptions, muscle groups, difficulty levels

4. **FREE Progress Tracking & Charts** ⭐ COMPETITIVE ADVANTAGE
   - Strength progression line charts (weight/reps over time)
   - Body measurements tracking (weight, waist, chest, arms, legs)
   - Weekly/monthly/all-time views
   - CSV data export (GDPR compliance)
   - Chart library: fl_chart (free, lightweight)

5. **Streak System + Daily Check-in** ⭐ RETENTION DRIVER
   - Duolingo-style streak tracking
   - Daily notification (8am): "Ready for today's workout?"
   - Milestones: Bronze (7d), Silver (30d), Gold (100d)
   - 1 "freeze" per week for missed days
   - Badge animations (Lottie confetti)

6. **Weekly Progress Reports**
   - Automated Sunday 7pm summary
   - Concrete numbers: "+5kg squat, 4 workouts completed"
   - Strength gains per exercise
   - Body measurement changes
   - Streak status
   - Push notification + in-app view

7. **Workout Templates/Plans (20+)**
   - Pre-built routines (Push/Pull/Legs, Upper/Lower, Full Body)
   - Beginner/Intermediate/Advanced variants
   - Custom template creation (save favorites)
   - Quick-start from template

8. **User Profile & Goal Setting**
   - Onboarding flow (goals: Get Stronger, Build Muscle, Lose Weight, Stay Healthy)
   - Fitness level (Beginner, Intermediate, Advanced)
   - Workout frequency preference
   - Optional: age, gender (future analytics)

9. **Push Notifications (Firebase FCM)**
   - Daily check-in (8am local time)
   - Streak reminder (9pm if no workout logged)
   - Weekly report (Sunday 7pm)
   - Customizable preferences

10. **Authentication & GDPR**
    - Email/password + Google/Apple Sign-In
    - GDPR consent flow
    - Data export (JSON download)
    - Account deletion (complete wipe)
    - Privacy policy integration

**MVP Success Criteria:**
- All 10 features functional and tested
- App Store approved (iOS + Android)
- Beta tested (50 users, <5 critical bugs)
- Logging speed <2 min measured
- 500 downloads Month 1 (Polish niche)

### Growth Features (P1 - Months 4-9)

**Goal:** Build social moat and holistic wellness positioning.

**Social & Community:**
- **Mikroklub** - 10-person, 6-week challenges (intimate support, not toxic leaderboards)
- **Tandem Training** - Real-time sync with workout partner, live progress tracking
- **WhatsApp-style Contact Sync** - "5 friends use GymApp!" viral loop
- **Friend Invites** - Referral program with rewards

**Holistic Wellness Integration:**
- **Diet App Integrations** - Fitatu, MyFitnessPal auto-sync
- **Wearable Integrations** - Apple Health, Fitbit, Garmin, Whoop (HRV, sleep, stress)
- **Advanced Analytics** - Muscle group breakdown, strength progression trends, recovery metrics

**Enhanced Engagement:**
- **Daily Challenge** - Wordle-style workout of the day
- **Training Streaks with Friends** - Snapchat-style streak sharing
- **Profile Completion Gamification** - LinkedIn-style progress incentives

**P1 Success Criteria:**
- 25k downloads (UK market entry)
- Mikroklub participation: 30% of active users
- Tandem workout adoption: 20%
- Viral coefficient (K-factor): 0.3+ (referrals drive growth)

### Vision - P2 (Months 10-18): AI Differentiation

**Goal:** Compete with FitBod on AI at 60% lower price (£2.99 vs £8/mo).

**AI-Powered Intelligence:**
- **AI Workout Suggestions** - Personalized programs based on goals, equipment, progress history
- **Voice Input Logging** - "Hey GymApp, log 5 sets of squats at 90kg" (hands-free)
- **Mood Adaptation** - AI adjusts intensity based on sleep quality, stress levels (HRV), energy
- **Progress Photo AI Analysis** - "Waist -2cm, shoulders more defined"

**Empathy Engine:**
- **AI Personality Options** - Zen (calm), Motivator (encouraging), Drill Sergeant (tough love), Psychologist (understanding)
- **Adaptive Communication** - "Slept poorly? Let's do a lighter session today" (not guilt-tripping)
- **Smart Recovery Recommendations** - Rest day suggestions based on workout volume

**Advanced Charts:**
- Syncfusion charts (advanced visualizations)
- Predictive strength progression curves
- Injury risk indicators (overtraining detection)

**P2 Success Criteria:**
- 75k downloads (viral growth from P1 social features)
- AI features improve free→paid conversion to 7%+ (from 5% baseline)
- ARPU increases to £40/year (premium tier adoption)

### Vision - P3 (Months 19-36): Moat Building

**Goal:** Create defensible technical moat that competitors can't easily copy.

**Advanced AI Features:**
- **Camera Biomechanics** - Real-time form analysis (squat depth, push-up posture) via phone camera
- **BioAge Calculation** - "You dropped 0.6 biological years this month!" (unique motivation metric)
- **Live Voice Coaching** - AI coach through headphones responding to breath, tempo, form in real-time
- **AI Injury Prediction** - Analyze workout patterns to predict overtraining/injury risk

**Platform & Network Effects:**
- **Trainer Marketplace** - Professional trainers create programs, GymApp takes 20% platform fee
- **B2B Gym Partnerships** - White-label licensing for gym chains
- **Professional Fitness Network** - LinkedIn-style connections for fitness professionals
- **Global Warm-Up** - "4,214 people from 38 countries warming up with you now!" (synchronous sessions)

**Premium Features:**
- **PvP Competitions** - Live challenges with friends, leaderboards
- **3D Body Visualization** - AI body composition analysis from photos
- **Wearable Native Apps** - Apple Watch, Garmin standalone apps

**P3 Success Criteria:**
- 250k+ active users
- £500k+ ARR (combination of subscriptions, IAP, marketplace fees)
- Technical moat established (camera AI, BioAge) - 12-18 month competitor delay to copy

**Out of Scope (Explicitly NOT Building):**
- Nutrition meal planning (integrate with Fitatu/MyFitnessPal instead)
- Live video classes (partner with Nike NTC, not compete)
- Equipment e-commerce (affiliate links only, no inventory)
- Medical/physiotherapy advice (liability risk)

---

## Functional Requirements

**Critical Note:** These FRs define WHAT capabilities GymApp must have. Each FR is implementation-agnostic (states capability, not how it's built). UX Designer, Architect, and Dev teams will use ONLY these FRs as the source of truth for what to build.

**Total FRs:** 52 (MVP: 35, P1: 8, P2: 6, P3: 3)

---

### User Account & Authentication (MVP)

**FR1:** Users can create accounts using email/password, Google Sign-In, or Apple Sign-In
**FR2:** Users can log in securely and maintain authenticated sessions across devices
**FR3:** Users can reset passwords via email verification
**FR4:** Users can update profile information (name, photo, fitness goals, experience level)
**FR5:** Users can delete their account and all associated data permanently
**FR6:** Users can export all their data in JSON format
**FR7:** Users must explicitly consent to data processing (GDPR compliance) during signup

---

### Workout Logging & Tracking (MVP)

**FR8:** Users can start a new workout session with timestamp tracking
**FR9:** Users can select exercises from a searchable library of 500+ exercises
**FR10:** Users can filter exercises by muscle group, equipment type, or difficulty
**FR11:** Users can log sets, reps, and weight for each exercise
**FR12:** Users can edit or delete sets within an active workout
**FR13:** Users can use a rest timer between sets
**FR14:** Users can complete and save a workout with total duration calculated
**FR15:** Users can view their workout history sorted by date
**FR16:** Users can edit or delete past workouts
**FR17:** **Smart Pattern Memory:** System automatically pre-fills last workout data (sets/reps/weight) when user selects an exercise
**FR18:** **Smart Pattern Memory:** System displays date of last performance for each exercise
**FR19:** Users can log workouts offline and sync when connection restored

---

### Exercise Library (MVP)

**FR20:** System provides 500+ exercises with names, descriptions, primary/secondary muscle groups, equipment needed, and difficulty level
**FR21:** Users can search exercises by name or keyword
**FR22:** Users can browse exercises by category (muscle group, equipment)
**FR23:** Users can mark exercises as favorites for quick access

---

### Progress Tracking & Analytics (MVP)

**FR24:** Users can track body measurements (weight, waist, chest, arms, legs, body fat %)
**FR25:** Users can view line charts showing strength progression for each exercise (weight over time, reps over time)
**FR26:** Users can view body measurement trends over time with line charts
**FR27:** Users can toggle chart views between weekly, monthly, and all-time timeframes
**FR28:** **FREE Charts:** All progress charts available without paywall or subscription
**FR29:** Users can export workout and measurement data to CSV format

---

### Habit Formation & Engagement (MVP)

**FR30:** **Streak System:** System tracks consecutive days with logged workouts or rest days
**FR31:** **Streak System:** Users earn badges at milestones (Bronze: 7 days, Silver: 30 days, Gold: 100 days)
**FR32:** **Streak System:** Users can "freeze" streak once per week if they miss a day
**FR33:** **Daily Check-in:** Users receive daily notification (8am local time) prompting workout readiness
**FR34:** **Streak Reminder:** Users receive notification (9pm local time) if no workout logged that day
**FR35:** **Weekly Report:** Users receive automated progress summary every Sunday 7pm showing: total workouts, strength gains per exercise, body measurement changes, streak status

---

### Workout Templates & Programs (MVP)

**FR36:** Users can access 20+ pre-built workout templates (Push/Pull/Legs, Upper/Lower, Full Body, Strength, Hypertrophy)
**FR37:** Users can start a workout directly from a template (exercises pre-populated)
**FR38:** Users can create custom templates by saving favorite workout combinations
**FR39:** Users can edit or delete custom templates

---

### User Settings & Preferences (MVP)

**FR40:** Users can set fitness goals (Get Stronger, Build Muscle, Lose Weight, Stay Healthy)
**FR41:** Users can specify fitness experience level (Beginner, Intermediate, Advanced)
**FR42:** Users can set preferred workout frequency (2x, 3x, 4x, 5x+ per week)
**FR43:** Users can customize notification preferences (enable/disable daily check-in, streak reminders, weekly reports)
**FR44:** Users can access privacy policy and terms of service in-app

---

### Social & Community Features (P1 - Post-MVP)

**FR45:** **Mikroklub:** Users can create or join 10-person, 6-week challenge groups
**FR46:** **Mikroklub:** Users can view group members' workout completion status and encourage each other
**FR47:** **Tandem Training:** Users can invite a friend to sync workouts in real-time and see live progress
**FR48:** Users can invite friends to join GymApp via WhatsApp/SMS/email with referral tracking
**FR49:** Users can see which of their contacts use GymApp (with permission)
**FR50:** Users can participate in daily challenges (workout of the day, Wordle-style)

---

### Integrations & Holistic Wellness (P1)

**FR51:** **Diet Integration:** System can sync nutrition data from Fitatu and MyFitnessPal
**FR52:** **Wearable Integration:** System can sync sleep, HRV, stress data from Apple Health, Fitbit, Garmin, Whoop

---

### AI-Powered Features (P2)

**FR53:** **AI Workout Suggestions:** System generates personalized workout programs based on user goals, available equipment, and progress history
**FR54:** **Voice Input:** Users can log workouts using voice commands ("Log 5 sets of squats at 90kg")
**FR55:** **Mood Adaptation:** System adjusts workout intensity recommendations based on sleep quality and stress levels from wearable data
**FR56:** **AI Personality:** Users can select AI coach personality (Zen, Motivator, Drill Sergeant, Psychologist)
**FR57:** **Progress Photo Analysis:** System analyzes before/after photos and identifies visible changes ("waist -2cm, shoulders more defined")
**FR58:** **Recovery Recommendations:** System suggests rest days based on workout volume and recovery metrics

---

### Advanced Features (P3)

**FR59:** **Camera Biomechanics:** System analyzes exercise form in real-time via phone camera and provides corrective feedback
**FR60:** **BioAge Calculation:** System calculates biological age based on fitness metrics and shows monthly changes
**FR61:** **Live Voice Coaching:** System provides real-time verbal coaching through headphones during workouts

---

### Administrative & System Capabilities

**FR62:** System maintains 99.5% uptime (allows <0.5% crash rate)
**FR63:** System supports offline-first architecture (core logging works without internet, syncs when online)
**FR64:** System encrypts all user data in transit (HTTPS) and at rest
**FR65:** System complies with GDPR data protection requirements
**FR66:** System supports iOS (14+) and Android (10+) platforms
**FR67:** System app size remains under 50MB for initial download
**FR68:** System startup time is under 2 seconds from app launch to home screen

---

**FR Completeness Validation:**
- ✅ All MVP features (10 core) mapped to FRs
- ✅ All P1 features mapped to FRs
- ✅ All P2 features mapped to FRs
- ✅ All P3 features mapped to FRs
- ✅ Domain requirements (GDPR, privacy) mapped to FRs
- ✅ Mobile-specific needs (offline, platforms) mapped to FRs
- ✅ All FRs are capability statements (WHAT), not implementation (HOW)
- ✅ All FRs are testable and independent

**Next:** Epic breakdown will decompose these 68 FRs into user stories with acceptance criteria.

---

## Non-Functional Requirements

**Philosophy:** NFRs must directly serve user impact. Avoid vanity metrics - focus on what users actually experience.

---

### Performance Requirements

**Why Performance Matters:** Slow apps = user frustration = abandonment. GymApp competes on speed (2 sec logging vs 5 min).

**NFR-P1:** App startup time must be under 2 seconds from tap to home screen
- **Rationale:** No friction to start workout reduces dropout
- **Measurement:** 95th percentile load time <2s on mid-range devices (iPhone 12, Samsung Galaxy S21)

**NFR-P2:** Workout logging flow must complete in under 2 minutes total
- **Rationale:** Core value proposition - save 17 hours/year (vs 5 min manual logging)
- **Measurement:** Time from "Start Workout" → log 15 exercises × 4 sets → "Complete" <2 min with smart pattern memory

**NFR-P3:** Smart pattern memory query must return results in under 500ms
- **Rationale:** Instant pre-fill = "aha moment", any delay breaks magic
- **Measurement:** Database query for last workout data <500ms (p95)

**NFR-P4:** Progress charts must render in under 1 second
- **Rationale:** Users check progress frequently, lag = frustration
- **Measurement:** fl_chart render time for 90-day exercise progression <1s

**NFR-P5:** Offline mode must provide full logging functionality without internet
- **Rationale:** Gyms often have poor Wi-Fi/cellular, can't block core workflow
- **Measurement:** Users can log complete workout offline, auto-sync when online within 30s

---

### Security & Privacy Requirements

**Why Security Matters:** Health data + GDPR compliance + user trust. One breach = business killer.

**NFR-S1:** All user data must be encrypted in transit using TLS 1.3+
- **Rationale:** Prevent man-in-the-middle attacks on public gym Wi-Fi
- **Implementation:** HTTPS only, certificate pinning (Firebase default)

**NFR-S2:** All user data at rest must be encrypted using AES-256
- **Rationale:** Protect user data if device lost/stolen
- **Implementation:** Firebase Firestore encryption (default), local Drift database encryption

**NFR-S3:** Authentication sessions must expire after 30 days of inactivity
- **Rationale:** Prevent unauthorized access from abandoned sessions
- **Implementation:** Firebase Auth token refresh, auto-logout

**NFR-S4:** User passwords must be hashed using industry-standard algorithms (bcrypt, scrypt, or Argon2)
- **Rationale:** Prevent credential theft from database breach
- **Implementation:** Firebase Auth handles this (bcrypt + salt)

**NFR-S5:** System must comply with GDPR Article 17 (Right to be Forgotten)
- **Rationale:** Legal requirement in UK + Poland markets
- **Implementation:** Account deletion cascades to all user data (workouts, measurements, photos) within 24 hours

**NFR-S6:** System must provide user data export in machine-readable format (JSON)
- **Rationale:** GDPR Article 20 (Data Portability)
- **Implementation:** Generate JSON export of all user data on request, delivered via email within 48 hours

**NFR-S7:** System must obtain explicit user consent before processing personal data
- **Rationale:** GDPR Article 6 (Lawfulness of Processing)
- **Implementation:** Consent checkbox during signup, stored timestamp, re-prompt if privacy policy changes

---

### Scalability Requirements

**Why Scalability Matters:** Plan for success - if retention hits 12%, growth will accelerate fast.

**NFR-SC1:** System must support 5,000 concurrent users (Year 1 target)
- **Rationale:** Polish niche launch, 500 downloads/month, 60% DAU rate
- **Measurement:** Load testing with 5k simulated concurrent workout logs

**NFR-SC2:** System must scale to 75,000 users by Year 3 without architecture redesign
- **Rationale:** P2 launch target, avoid costly rewrites
- **Implementation:** Firebase Firestore auto-scales, monitor quotas monthly

**NFR-SC3:** Database queries must maintain <500ms response time at 75k user scale
- **Rationale:** Smart pattern memory performance can't degrade with growth
- **Implementation:** Proper indexing (user_id, exercise_id, date), query optimization

**NFR-SC4:** Push notification delivery must scale to 75k daily messages (Year 3)
- **Rationale:** Daily check-ins + streak reminders for full user base
- **Implementation:** Firebase Cloud Messaging (FCM) handles 1M+ messages, batch sends

**NFR-SC5:** Backend costs must stay under £400/month at 75k users (5% of £135k ARR)
- **Rationale:** Unit economics viability (80% gross margin target)
- **Measurement:** Firebase monthly bill tracking, implement caching/pagination if needed

---

### Mobile-Specific Requirements

**Why Mobile Matters:** GymApp is mobile-first - gym environment demands specific UX.

**NFR-M1:** App must function fully on iOS 14+ and Android 10+
- **Rationale:** Cover 95%+ of target market devices
- **Implementation:** Flutter compatibility matrix, test on minimum OS versions

**NFR-M2:** App download size must remain under 50MB
- **Rationale:** Users on limited data plans, faster install = lower abandonment
- **Measurement:** Monitor APK/IPA size post-build, implement lazy loading for non-critical assets

**NFR-M3:** App must support offline-first architecture with background sync
- **Rationale:** Gyms have poor connectivity, core workflow can't depend on internet
- **Implementation:** Drift local database, sync queue, conflict resolution

**NFR-M4:** App must preserve battery life (no excessive background processing)
- **Rationale:** Don't drain phone during workout session
- **Measurement:** Battery usage <5% per hour during active workout logging

**NFR-M5:** App must support device rotation (portrait/landscape)
- **Rationale:** Users prop phones on equipment, need flexible viewing
- **Implementation:** Responsive Flutter layouts

**NFR-M6:** App must handle interruptions gracefully (calls, notifications, backgrounding)
- **Rationale:** Phone call mid-workout shouldn't lose workout data
- **Implementation:** Auto-save workout state every 30 seconds, restore on resume

---

### Accessibility Requirements

**Why Accessibility Matters:** Fitness is for everyone - inclusive design = larger TAM.

**NFR-A1:** App must support dynamic text sizing (iOS Dynamic Type, Android font scaling)
- **Rationale:** Users with vision impairments, older demographics
- **Implementation:** Relative font sizes (sp units), test at 200% scale

**NFR-A2:** App must provide sufficient color contrast (WCAG 2.1 AA)
- **Rationale:** Readability in bright gym lighting, colorblind users
- **Measurement:** Contrast ratio ≥4.5:1 for normal text, ≥3:1 for large text

**NFR-A3:** Interactive elements must have minimum touch target size of 44×44 dp
- **Rationale:** Gym environment = sweaty hands, gloves, accessibility
- **Implementation:** Button/tap target padding

**NFR-A4:** App must support screen readers (iOS VoiceOver, Android TalkBack)
- **Rationale:** Visually impaired users, audio workout guidance
- **Implementation:** Semantic labels for all UI elements

---

### Reliability & Availability

**NFR-R1:** App crash rate must stay below 0.5%
- **Rationale:** Crashes during workout = lost data = user frustration
- **Measurement:** Firebase Crashlytics reporting, fix critical crashes within 48 hours

**NFR-R2:** Backend API availability must be 99.5%+ (max 3.6 hours downtime/month)
- **Rationale:** Sync failures acceptable, but not frequent
- **Implementation:** Firebase SLA 99.95%, monitor uptime monthly

**NFR-R3:** Data sync conflicts must resolve automatically without user intervention
- **Rationale:** Offline logging creates conflicts, users shouldn't see errors
- **Implementation:** Last-write-wins for user data, timestamp-based conflict resolution

---

**NFR Summary:**
- **Performance:** <2s startup, <2min logging, <500ms pattern memory, <1s charts
- **Security:** TLS 1.3, AES-256 at rest, GDPR compliant, explicit consent
- **Scalability:** 5k users Y1 → 75k users Y3, <£400/mo backend costs
- **Mobile:** iOS 14+, Android 10+, <50MB app size, offline-first, battery efficient
- **Accessibility:** Dynamic text, WCAG AA contrast, 44dp touch targets, screen reader support
- **Reliability:** <0.5% crash rate, 99.5% uptime, auto conflict resolution

---

## Mobile App Specific Requirements

**Platform:** iOS + Android (Flutter cross-platform)

### Platform Requirements

**iOS Requirements:**
- Minimum version: iOS 14+
- Distribution: Apple App Store
- Required capabilities: Camera (progress photos), Notifications (daily check-ins), Health (optional integration)
- App Store compliance: Privacy Nutrition Labels, App Tracking Transparency (if analytics)
- Apple Sign-In: Mandatory if offering social auth (per Apple guidelines)

**Android Requirements:**
- Minimum version: Android 10+ (API 29+)
- Distribution: Google Play Store
- Required permissions: Camera, Notifications, Internet, Storage (local DB)
- Google Play compliance: Data Safety section, target API 33+
- Google Sign-In: OAuth 2.0 implementation

### Device Features Utilized

**Camera:** Progress photos (P1), Form analysis (P3)
**Sensors:** Accelerometer (auto-detect workout P2), Gyroscope (form analysis P3)
**Storage:** Drift local DB (offline-first), Firebase Firestore (cloud sync)
**Notifications:** FCM (daily check-ins, streak reminders)

---

## UX Principles & Key Interactions

**Design Philosophy:** "Invisible complexity, obvious value"

### Visual Personality

**Vibe:** Professional yet motivating (Apple Fitness+ meets Duolingo)

- Color: Energetic but approachable, dark mode mandatory
- Typography: Numbers-first, large readable displays
- NOT: Gym bro aesthetic OR sterile medical app

### Key Interaction Patterns

**1. Logging Flow (2 min total):**
- Tap "Start" → Select exercise → Smart pattern pre-fills → Tap to accept → 8 taps for 4 sets

**2. Daily Check-in:**
- 8am notification: "Ready?" → [Yes] [Rest Day] [Snooze] - Rest Day preserves streak

**3. Streak Celebration:**
- 7/30/100 days = Badge + animation + shareable card

**4. First-Time Experience:**
- Goal → Experience level → Frequency → Try first workout → Pattern memory "aha moment"

**Emotional Design:** Supportive buddy, not drill sergeant. Celebrate wins, acknowledge effort, respect rest days.

---

## Implementation Planning

### Epic Breakdown Required

Requirements will be decomposed into epics and user stories after PRD completion.

**Next Step:** Run `workflow create-epics-and-stories` to create implementation breakdown.

---

## References

- **Product Brief:** docs/product-brief-GymApp-2025-11-15.md
- **Brainstorming:** docs/bmm-brainstorming-session-2025-11-15.md
- **Research:** docs/market-research-condensed.md, docs/competitive-intelligence-condensed.md, docs/technical-research-condensed.md, docs/user-research-condensed.md

---

_This PRD captures the essence of GymApp - a fitness tracker that puts user impact first, built on solid business fundamentals, enabled by thoughtful technical innovation._

_Created through collaborative discovery between Mariusz and PM Agent (John)._
