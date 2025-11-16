# LifeOS - UX Design Specification

**Author:** Sally (UX Designer - BMAD)
**Date:** 2025-01-16
**Version:** 1.0
**Project:** LifeOS (Life Operating System)

---

## Executive Summary

LifeOS to modularny ekosystem AI-powered life coaching łączący Fitness, Mind & Emotion oraz Life Coach w jedną inteligentną platformę mobilną (iOS + Android). Ten dokument definiuje kompletną specyfikację UX dla MVP, bazując na analizie Nike Training Club (speed, clarity) oraz Headspace (emotion, calm).

**Dominant UX Philosophy:** "Achievement-driven calm" - użytkownik czuje się empowered ("I'm crushing it!") przy jednoczesnym poczuciu kontroli i spokoju.

**Target Emotion:** "Wow, I'm crushing it!" (Nike vibe) z elementami "I'm in control" (Headspace vibe)

**Platform:** Mobile-first (iOS 14+, Android 10+, Flutter)

**Design Inspiration:** Nike Training Club + Headspace fusion

---

## 1. UX Principles

### 1.1 Core Principles

**Principle #1: Speed Over Beauty** (Fitness Module)
- **Rationale:** Użytkownicy na siłowni potrzebują szybkości, nie estetyki
- **Application:**
  - Smart Pattern Memory pre-fills wszystko
  - Swipe gestures zamiast klawiatury
  - Offline-first (zero loading states)
  - Target: <2s per set logging

**Principle #2: Emotional Anchoring** (Mind Module)
- **Rationale:** Meditation wymaga immediate emotional connection
- **Application:**
  - Pierwsze 10 sekund = emotional hook
  - Calming animations (subtle, not energetic)
  - 1-tap to peace
  - Warm, consistent voice

**Principle #3: Achievement Celebration** (Cross-Module)
- **Rationale:** Retention driven by visible progress and wins
- **Application:**
  - Every milestone recognized (streaks, PRs, badges)
  - Bold, energetic feedback (confetti animations)
  - Progress always visible
  - Weekly summary reports with concrete stats

**Principle #4: Friction Reduction** (Life Coach)
- **Rationale:** Morning ritual musi być effortless, żeby stał się nawykiem
- **Application:**
  - Morning check-in w 60s
  - AI robi thinking za użytkownika
  - Smart defaults wszędzie
  - Zero decision paralysis

**Principle #5: Cross-Module Intelligence Visibility**
- **Rationale:** Killer feature musi być widoczny i actionable
- **Application:**
  - Insights surfaced as cards (swipeable)
  - Max 1 insight/day (high value only)
  - Visual connection między modułami (consistent colors/icons)
  - Clear actionable CTAs

---

## 2. Visual System

### 2.1 Color Palette

**Primary Colors:**

- **Deep Blue** `#1E3A8A` - Trust, stability, calm
  - Use: Primary brand color, headers, navigation bar
  - Psychology: Evokes confidence and reliability
  - Contrast ratio: 7.2:1 (WCAG AAA)

- **Energetic Teal** `#14B8A6` - Energy, growth, wellness
  - Use: Primary CTAs, progress indicators, success states
  - Psychology: Optimism and forward motion
  - Module: Cross-module accent

**Module-Specific Accents:**

- **Orange** `#F97316` - Motivation, achievement (Fitness)
  - Use: Fitness module headers, workout CTAs, PR celebrations
  - Psychology: Energy, urgency, action
  - Pairing: Works with Deep Blue background

- **Purple** `#9333EA` - Mindfulness, calm (Mind)
  - Use: Mind module headers, meditation CTAs, calm states
  - Psychology: Spirituality, tranquility, wisdom
  - Pairing: Softer than orange, calming effect

**Neutrals:**

- **Background Light** `#F9FAFB` - Primary background (light mode)
- **Background Dark** `#111827` - Primary background (dark mode, P1)
- **Text Primary** `#1F2937` - Body text (light mode)
- **Text Secondary** `#6B7280` - Secondary text, labels
- **Border** `#E5E7EB` - Dividers, cards

**Semantic Colors:**

- **Success** `#10B981` - Completed goals, streaks maintained
- **Warning** `#F59E0B` - Streak about to break, high stress alerts
- **Error** `#EF4444` - Failed actions, critical alerts
- **Info** `#3B82F6` - Informational messages, tips

### 2.2 Typography

**Font Family:** Inter (Google Fonts, open source)
- **Rationale:** Modern, highly readable, excellent number rendering (critical for stats)
- **Fallback:** System default (San Francisco iOS, Roboto Android)

**Type Scale:**

- **H1 (Page Headers):** Inter Bold, 28pt, Letter spacing -0.5%
  - Use: Screen titles, module names
  - Example: "Morning Check-in", "Workout Log"

- **H2 (Section Headers):** Inter SemiBold, 22pt, Letter spacing -0.3%
  - Use: Section titles, card headers
  - Example: "Today's Plan", "Recent Workouts"

- **H3 (Subsection Headers):** Inter SemiBold, 18pt, Letter spacing 0%
  - Use: Sub-sections, list headers
  - Example: "Goals", "Meditations"

- **Body (Regular Text):** Inter Regular, 16pt, Line height 24pt
  - Use: Body copy, descriptions, instructions
  - Minimum size for accessibility

- **Body Small:** Inter Regular, 14pt, Line height 20pt
  - Use: Secondary text, labels, metadata
  - Example: "Last updated 2 hours ago"

- **Caption:** Inter Regular, 12pt, Line height 16pt
  - Use: Timestamps, footnotes
  - Minimum readable size

- **Numbers/Stats:** Inter SemiBold, Variable (context-dependent)
  - Use: Workout stats, progress numbers, streaks
  - Example: "5 sets", "100kg", "7-day streak"
  - Rationale: Numbers must stand out for quick scanning

**Letter Spacing:**
- Headers: Slightly tighter (-0.3% to -0.5%) for boldness
- Body: Default (0%) for readability
- All-caps labels: +5% for legibility

### 2.3 Iconography

**Icon Style:** Outlined, 2px stroke weight
- **Rationale:** Modern, not heavy, scalable, consistent with clean aesthetic
- **Library:** Heroicons (MIT license, matches Inter vibe)
- **Sizes:** 20px (small), 24px (standard), 32px (large), 48px (hero)

**Module Icons:**

- **Home (Life Coach):** House outline
- **Fitness:** Dumbbell outline
- **Mind:** Brain outline / Lotus flower
- **Profile:** User circle outline

**Action Icons:**

- **Add/Create:** Plus circle
- **Check/Complete:** Check circle (filled when complete)
- **Edit:** Pencil
- **Delete:** Trash
- **Settings:** Cog
- **Notifications:** Bell
- **Insights:** Light bulb
- **AI Chat:** Chat bubble with sparkles

**Accessibility:**
- All icons paired with text labels (no icon-only buttons in critical flows)
- Minimum 44x44pt touch targets (iOS HIG)
- High contrast versions for accessibility mode

### 2.4 Component Library

**Cards:**

- **Standard Card**
  - Background: White (#FFFFFF)
  - Border radius: 12px
  - Shadow: 0px 2px 8px rgba(0,0,0,0.08)
  - Padding: 16px
  - Use: Workout summary, meditation card, goal card

- **Insight Card** (Cross-Module Intelligence)
  - Background: Gradient (Module color A → Module color B)
  - Border radius: 16px
  - Shadow: 0px 4px 12px rgba(0,0,0,0.12)
  - Padding: 20px
  - Icon: Light bulb (top left)
  - CTA: Teal button (bottom right)
  - Swipeable: Yes (dismiss or save)

- **Streak Card**
  - Background: Deep Blue (#1E3A8A)
  - Text: White
  - Border radius: 12px
  - Badge: Gold/Silver/Bronze (visual indicator)
  - Animation: Pulse on milestone

**Buttons:**

- **Primary CTA**
  - Background: Energetic Teal (#14B8A6)
  - Text: White, Inter SemiBold 16pt
  - Height: 48px (touch-friendly)
  - Border radius: 12px
  - Shadow: 0px 2px 4px rgba(0,0,0,0.1)
  - Hover/Press: Darken 10%
  - Use: Main actions (Start Meditation, Log Workout, Save Goal)

- **Secondary CTA**
  - Background: Transparent
  - Border: 2px solid Deep Blue (#1E3A8A)
  - Text: Deep Blue, Inter SemiBold 16pt
  - Height: 48px
  - Border radius: 12px
  - Use: Cancel, Skip, Secondary actions

- **Module-Specific CTA**
  - Fitness: Orange (#F97316) background
  - Mind: Purple (#9333EA) background
  - Same dimensions as Primary CTA

- **Text Button**
  - No background, no border
  - Text: Teal (#14B8A6), Inter SemiBold 16pt
  - Underline on press
  - Use: Tertiary actions (Learn More, View All)

**Input Fields:**

- **Text Input**
  - Border: 1px solid #E5E7EB
  - Border radius: 8px
  - Height: 44px
  - Padding: 12px 16px
  - Focus state: Border Teal (#14B8A6), 2px
  - Error state: Border Red (#EF4444)
  - Placeholder: #9CA3AF (Gray 400)

- **Number Input (Fitness)**
  - Same as text input
  - Font: Inter SemiBold (numbers emphasized)
  - Increment/decrement buttons: +/- (swipe gestures preferred)

**Progress Indicators:**

- **Progress Bar**
  - Track: #E5E7EB (Gray 200)
  - Fill: Teal (#14B8A6) or Module color
  - Height: 8px
  - Border radius: 4px (pill shape)
  - Animation: Smooth fill (300ms ease-out)

- **Circular Progress** (Streaks)
  - Track: #E5E7EB
  - Fill: Module color (Orange for Fitness, Purple for Mind)
  - Stroke width: 6px
  - Center: Streak number (Inter Bold, 24pt)

**Badges:**

- **Streak Badges**
  - Bronze (7 days): #CD7F32
  - Silver (30 days): #C0C0C0
  - Gold (100 days): #FFD700
  - Size: 48x48px icon
  - Animation: Confetti on unlock (Lottie)

**Bottom Navigation Bar:**

- **Height:** 72px (safe area + tab bar)
- **Background:** White (#FFFFFF) with top border (#E5E7EB)
- **Icons:** 24px, outlined style
- **Active state:** Icon filled + Module color + label
- **Inactive state:** Icon outlined + Gray (#6B7280) + label
- **Labels:** Inter Medium, 12pt
- **Touch targets:** Minimum 44x44pt per tab

---

## 3. Navigation Architecture

### 3.1 Bottom Tab Bar (Primary Navigation)

**Tab Order (Left to Right):**

1. **Home** (Life Coach)
   - Icon: House outline
   - Active color: Deep Blue (#1E3A8A)
   - Badge: Unread check-in reminder (dot)

2. **Fitness**
   - Icon: Dumbbell outline
   - Active color: Orange (#F97316)
   - Badge: Active workout indicator (pulse)

3. **Mind**
   - Icon: Lotus flower outline
   - Active color: Purple (#9333EA)
   - Badge: Meditation reminder (if set)

4. **Profile**
   - Icon: User circle outline
   - Active color: Teal (#14B8A6)
   - Badge: Settings notification (if needed)

**Navigation Behavior:**
- Tap active tab → Scroll to top (iOS standard)
- Tap inactive tab → Navigate to that module's home
- Deep links open relevant tab + screen

### 3.2 Screen Hierarchy

**Home (Life Coach) Screens:**
```
Home
├── Morning Check-in (Modal)
├── Evening Reflection (Modal)
├── Daily Plan (Main view)
├── Goals List
│   └── Goal Detail
│       └── Edit Goal
├── AI Chat
│   └── Conversation History
├── Progress Dashboard
└── Insights (Cross-Module)
```

**Fitness Screens:**
```
Fitness Home
├── Log Workout (Modal - Primary Flow)
│   ├── Select Exercise (Search)
│   ├── Log Sets (Smart Pattern Memory)
│   └── Complete Workout
├── Workout History
│   └── Workout Detail
│       └── Edit Workout
├── Progress Charts
│   ├── Strength Progress
│   ├── Volume Trends
│   └── Personal Records
├── Templates
│   ├── Pre-built Templates (20+)
│   └── Custom Templates
│       └── Create Template
└── Body Measurements
```

**Mind Screens:**
```
Mind Home
├── Start Meditation (Modal - Primary Flow)
│   ├── Continue Last Session
│   ├── Today's Recommendation (AI)
│   └── Browse Library
│       └── Meditation Player
├── Mood Tracking
│   ├── Log Mood (Quick)
│   └── Mood Trends
├── Breathing Exercises
│   └── Breathing Guide (Animated)
├── Journal
│   ├── New Entry
│   └── Entry History
├── CBT Chat (AI)
└── Mental Health Screening
    ├── GAD-7
    └── PHQ-9
```

**Profile Screens:**
```
Profile
├── Account Settings
│   ├── Personal Info
│   ├── Change Password
│   └── Delete Account
├── Subscription Management
│   ├── Current Plan
│   ├── Upgrade Options
│   └── Billing History
├── Notifications Settings
│   ├── Daily Reminders
│   ├── Streak Alerts
│   └── Cross-Module Insights
├── Data & Privacy
│   ├── Export Data
│   ├── Privacy Settings
│   └── Privacy Policy
├── Support & Feedback
└── App Info
```

### 3.3 Modal Patterns

**Full-Screen Modals:** (Can't be dismissed accidentally)
- Onboarding flow
- Subscription paywall
- First-time feature tutorials

**Card Modals:** (Swipe down to dismiss)
- Morning check-in
- Mood logging
- Quick actions (log workout, start meditation)

**Bottom Sheets:** (Partial screen overlay)
- Filter options
- Sort options
- Quick settings

---

## 4. Key Screen Flows

### 4.1 Priority #1: Fast Workout Logging (Fitness)

**Goal:** Log workout set in <2 seconds

**User Journey:**
1. User opens Fitness tab
2. Taps large "Log Workout" FAB (Floating Action Button)
3. **Smart Pattern Memory** pre-fills last workout:
   - Exercise name
   - Sets, reps, weight from last session
4. User adjusts if needed:
   - Swipe up/down on weight to increment/decrement
   - Tap reps to edit
5. Tap checkmark → Set logged
6. Repeat for next set

**Screen: Log Workout (Modal)**

```
┌─────────────────────────────────────┐
│  ← Back          Bench Press    ✓   │ (Header)
├─────────────────────────────────────┤
│                                     │
│  Set 1                              │
│  ┌─────────────────────────────┐   │
│  │  100 kg  ×  8 reps          │   │ (Pre-filled)
│  └─────────────────────────────┘   │
│                              [✓]    │ (Check to complete)
│                                     │
│  Set 2                              │
│  ┌─────────────────────────────┐   │
│  │  100 kg  ×  8 reps          │   │ (Pre-filled)
│  └─────────────────────────────┘   │
│                              [ ]    │
│                                     │
│  Set 3                              │
│  ┌─────────────────────────────┐   │
│  │  100 kg  ×  8 reps          │   │ (Pre-filled)
│  └─────────────────────────────┘   │
│                              [ ]    │
│                                     │
│  [+ Add Set]                        │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Complete Workout (Orange)   │ │ (Primary CTA)
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Interaction Details:**
- **Swipe gestures:** Swipe up on "100 kg" → 105 kg, swipe down → 95 kg (5kg increments)
- **Tap to edit:** Tap "8 reps" → Number picker modal
- **Offline:** Works 100% offline, syncs when online
- **Haptic feedback:** Light tap on check, medium on complete
- **Animation:** Checkmark bounce (delight)

**Edge Cases:**
- First time exercise → No pre-fill, show placeholder "Enter weight & reps"
- Changed exercise → Clear pre-fill, show empty state
- Network offline → Show "Offline mode" banner (reassuring, not alarming)

---

### 4.2 Priority #2: Morning Ritual (Life Coach)

**Goal:** Complete morning check-in in 60 seconds

**User Journey:**
1. User opens app (any tab)
2. If morning check-in not done → Modal appears automatically
3. User rates:
   - Mood (1-5, emoji slider)
   - Energy (1-5, emoji slider)
   - Sleep quality (1-5, emoji slider)
4. Optional: Add note (text input, "Anything on your mind?")
5. Tap "Generate My Plan" → AI creates daily plan
6. Daily plan appears on Home tab

**Screen: Morning Check-in (Modal)**

```
┌─────────────────────────────────────┐
│           Good Morning! 🌅          │ (Header)
│       How are you feeling?          │
├─────────────────────────────────────┤
│                                     │
│  Mood                               │
│  😢  😞  😐  😊  😄                  │ (Emoji slider)
│  └────●───────────────┘             │ (Currently: Happy)
│                                     │
│  Energy                             │
│  😴  😪  😐  😃  ⚡                  │
│  └──────────●─────────┘             │ (Currently: Good)
│                                     │
│  Sleep Quality                      │
│  😴  😞  😐  😊  ✨                  │
│  └──────●─────────────┘             │ (Currently: Good)
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Anything on your mind?      │   │ (Optional)
│  │ (Optional note...)          │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Generate My Plan (Teal)      │ │ (Primary CTA)
│  └───────────────────────────────┘ │
│                                     │
│  [Skip for today]                   │ (Text button)
└─────────────────────────────────────┘
```

**Interaction Details:**
- **Emoji sliders:** Drag to select, haptic feedback on each emoji
- **Default values:** Mid-point (3/5) if user doesn't adjust
- **AI generation:** Loading indicator (animated AI sparkle) → "Generating your perfect day..."
- **Animation:** Emoji bounce on selection (delight)
- **Accessibility:** VoiceOver reads "Mood: Happy, 4 out of 5"

**AI Daily Plan Output:**
```
Today's Plan (Generated)
━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Morning meditation (10 min) - You seem energized!
⏱ 10:00 AM - Focus work block
💪 12:00 PM - Gym workout (Pre-filled: Push day)
🍽 1:00 PM - Lunch break
⏱ 2:00 PM - Creative work
🧘 6:00 PM - Evening wind-down meditation
📝 8:00 PM - Evening reflection

Insight: Your sleep was good (4/5). Great foundation for a productive day!
```

---

### 4.3 Priority #3: Calming Meditation Start (Mind)

**Goal:** Start meditation in 1 tap, zero decision paralysis

**User Journey:**
1. User opens Mind tab
2. **Hero CTA:** "Continue where you left off" (large button)
   - OR "Today's meditation" (AI recommended based on mood)
3. User taps → Meditation player opens
4. Calming fade-in animation (2s)
5. Meditation starts automatically (no extra tap needed)

**Screen: Mind Home**

```
┌─────────────────────────────────────┐
│  Mind & Emotion              [Zzz] │ (Header + Sleep mode icon)
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │   🧘 Continue Meditation      │ │ (Hero card, Purple bg)
│  │                               │ │
│  │   Stress Relief               │ │
│  │   15 min • 4/10 complete      │ │
│  │                               │ │
│  │   [▶ Resume]  (White button)  │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Today's Recommendation 💡          │
│  ┌───────────────────────────────┐ │
│  │  Morning Focus (10 min)       │ │
│  │  "Based on your good sleep"   │ │ (AI reasoning)
│  │                       [Start] │ │
│  └───────────────────────────────┘ │
│                                     │
│  Quick Actions                      │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│  │ 🫁  │ │ 😊  │ │ 📓  │ │ 📊  │ │ (Icons)
│  │Breat││Mood ││Journ││Trend│ │
│  │hing ││ Log ││ al  ││ s   │ │
│  └─────┘ └─────┘ └─────┘ └─────┘ │
│                                     │
│  Browse Library →                   │ (Text link)
└─────────────────────────────────────┘
```

**Meditation Player (Full Screen)**

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          🧘‍♀️                        │ (Animated breathing circle)
│                                     │
│      Stress Relief Meditation       │
│                                     │
│      ⏸  [  7:32 / 15:00  ]          │ (Play/pause + progress)
│                                     │
│      ●─────────────────○            │ (Scrubber)
│                                     │
│                                     │
│      [  -15s  ] [  +15s  ]          │ (Skip buttons)
│                                     │
│                                     │
│      Breathe in... 🌊               │ (Live transcript, optional)
│                                     │
│                                     │
│                 [×]                 │ (Close - bottom right)
│                                     │
└─────────────────────────────────────┘
```

**Interaction Details:**
- **Fade-in animation:** 2-second calming transition (purple → white gradient)
- **Breathing circle:** Expands/contracts with guided breathing rhythm
- **Background:** Soft gradient (purple → deep blue)
- **Haptic:** Gentle pulse during "breathe in" cues
- **Offline:** Cached audio plays seamlessly
- **Auto-lock prevention:** Screen stays on during meditation

---

## 5. Cross-Module Intelligence UX

### 5.1 Insight Card Pattern

**Goal:** Surface 1 high-value insight per day, make it actionable

**Insight Types:**
1. **Stress + Workout:** "High stress detected + heavy workout today → Consider light session"
2. **Sleep + Workout:** "Sleep <6 hours + morning workout → Suggest afternoon instead"
3. **Volume + Stress:** "High workout volume + elevated stress → Recommend rest day"
4. **Sleep + Performance:** "Your best lifts happen after 8+ hours sleep. Tonight: Sleep meditation?"
5. **Meditation + Progress:** "21-day meditation streak + fitness improving → Keep it up!"

**Card Design:**

```
┌─────────────────────────────────────┐
│  💡 Insight for You                 │
├─────────────────────────────────────┤
│                                     │
│  🏋️ Fitness + 🧠 Mind Alert          │ (Module icons)
│                                     │
│  Your stress level is high today    │
│  (4/5) and you have a heavy leg     │
│  day scheduled.                     │
│                                     │
│  Recommendation:                    │
│  → Switch to upper body (light)     │
│  → OR take a rest day + meditate    │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ Adjust Plan  │  │  Dismiss    │ │ (CTAs)
│  └──────────────┘  └─────────────┘ │
│                                     │
│  [Save for later]                   │ (Text link)
└─────────────────────────────────────┘
```

**Behavior:**
- Appears on Home tab (top of feed)
- Swipeable (swipe left = dismiss, swipe right = save)
- Tap "Adjust Plan" → Opens relevant module with pre-filled action
- Max 1 per day (prevents notification fatigue)
- AI learns from dismissals (improve relevance over time)

**Visual Connection:**
- Gradient background: Fitness Orange → Mind Purple (shows cross-module)
- Module icons in header (visual cue)
- Actionable CTAs (not just informational)

---

## 6. Gamification & Retention UX

### 6.1 Streak Mechanics

**Streak Types:**
- Workout streaks (Fitness)
- Meditation streaks (Mind)
- Daily check-in streaks (Life Coach)

**Milestone Badges:**
- **Bronze:** 7 days
- **Silver:** 30 days
- **Gold:** 100 days

**Streak Card (Home Tab)**

```
┌─────────────────────────────────────┐
│  🔥 Your Streaks                    │
├─────────────────────────────────────┤
│                                     │
│  💪 Workout Streak                  │
│  ┌───────────────────────────────┐ │
│  │   🥉  7 Days                   │ │ (Bronze badge)
│  │   ███████░░░  70% to Silver    │ │ (Progress bar)
│  │   Freeze available: 1 this week│ │
│  └───────────────────────────────┘ │
│                                     │
│  🧘 Meditation Streak               │
│  ┌───────────────────────────────┐ │
│  │   🥈  32 Days                  │ │ (Silver badge)
│  │   █████░░░░░  32% to Gold      │ │
│  │   Freeze available: 1 this week│ │
│  └───────────────────────────────┘ │
│                                     │
│  ☀️ Check-in Streak                 │
│  ┌───────────────────────────────┐ │
│  │   ⚠️  2 Days                   │ │ (Warning - low)
│  │   Keep it going today!         │ │
│  │   [Do Morning Check-in]        │ │ (CTA)
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Streak Break Alert (Push Notification):**
```
🔥 Streak Alert!
Your meditation streak is about to break.
Meditate today to keep your 15-day streak alive!
[Tap to start 5-min meditation]
```

**Milestone Celebration (Full Screen)**

When user reaches 7/30/100 days:

```
┌─────────────────────────────────────┐
│                                     │
│          🎉 🎉 🎉                   │ (Confetti animation)
│                                     │
│       🥉 BRONZE UNLOCKED!            │
│                                     │
│     7-Day Workout Streak!           │
│                                     │
│   You're building unstoppable       │
│   momentum. Keep crushing it! 💪    │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Share Achievement           │ │ (Optional)
│  └───────────────────────────────┘ │
│                                     │
│  [Continue]                         │
└─────────────────────────────────────┘
```

**Animation:** Lottie confetti animation (2s), badge bounce-in

### 6.2 Weekly Summary Report

**Delivered:** Every Monday morning (push notification + in-app card)

**Report Card (Home Tab)**

```
┌─────────────────────────────────────┐
│  📊 Your Week in Review             │
│  Jan 9-15, 2025                     │
├─────────────────────────────────────┤
│                                     │
│  💪 Fitness                          │
│  • 4 workouts completed             │
│  • +5kg on squat (new PR! 🎉)       │
│  • 12,500 kg total volume (+8%)     │
│                                     │
│  🧠 Mind                             │
│  • 5 meditations (avg 12 min)       │
│  • Stress: -23% vs last week        │
│  • Mood: 4.2/5 avg (↑ from 3.8)     │
│                                     │
│  ☀️ Life Coach                       │
│  • 6/7 check-ins completed          │
│  • 2 goals progressed (67%)         │
│  • 89% daily plan completion        │
│                                     │
│  🔥 Streak Status                    │
│  • Workout: 12 days 🔥              │
│  • Meditation: 18 days 🔥           │
│  • Check-in: 6 days (1 missed)      │
│                                     │
│  💡 Top Insight                      │
│  "Your best workouts happened       │
│  after 8+ hours sleep. Prioritize   │
│  sleep this week!"                  │
│                                     │
│  ┌───────────────────────────────┐ │
│  │   Share Report                │ │ (Optional)
│  └───────────────────────────────┘ │
│                                     │
│  [View Detailed Stats]              │
└─────────────────────────────────────┘
```

**UX Goal:** Concrete evidence of progress ("+5kg squat, stress -23%") → Retention driver

---

## 7. Onboarding Flow

### 7.1 First-Time User Experience

**Goal:** Get user to first value moment in <3 minutes

**Flow:**

**Screen 1: Welcome**
```
┌─────────────────────────────────────┐
│                                     │
│         Welcome to LifeOS 🌟        │
│                                     │
│    Your AI-powered operating        │
│    system for life                  │
│                                     │
│  [Get Started]                      │
│                                     │
│  ●○○○○                              │ (Progress dots)
└─────────────────────────────────────┘
```

**Screen 2: Choose Your Journey**
```
┌─────────────────────────────────────┐
│  What brings you here?              │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  💪 I want to get fit         │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🧠 I want to reduce stress   │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  ☀️ I want to organize my life│ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🌟 I want it all             │ │
│  └───────────────────────────────┘ │
│                                     │
│  ○●○○○                              │
└─────────────────────────────────────┘
```

**Personalization:** Based on choice, app emphasizes that module first

**Screen 3: Set Goals (1-3)**
```
┌─────────────────────────────────────┐
│  What's your main goal?             │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Lose 10 kg                 │   │ (Example goal)
│  └─────────────────────────────┘   │
│                                     │
│  [+ Add another goal] (max 3)       │
│                                     │
│  ○○●○○                              │
└─────────────────────────────────────┘
```

**Screen 4: Choose AI Personality**
```
┌─────────────────────────────────────┐
│  Choose your AI coach               │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🧘 Sage                      │ │
│  │  Calm, wise, supportive       │ │
│  │  "Let's take this one step    │ │
│  │   at a time"                  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  ⚡ Momentum                  │ │
│  │  Energetic, motivational      │ │
│  │  "Let's crush this! You've    │ │
│  │   got this!"                  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ○○○●○                              │
└─────────────────────────────────────┘
```

**Screen 5: Permissions**
```
┌─────────────────────────────────────┐
│  Enable notifications?              │
├─────────────────────────────────────┤
│                                     │
│  📬 Daily reminders                 │
│  Help you stay on track with       │
│  morning check-ins and workouts    │
│                                     │
│  🔥 Streak alerts                   │
│  Never miss a milestone             │
│                                     │
│  💡 Smart insights                  │
│  Get personalized recommendations   │
│  (max 1 per day)                    │
│                                     │
│  [Enable Notifications]             │
│  [Maybe Later]                      │
│                                     │
│  ○○○○●                              │
└─────────────────────────────────────┘
```

**Screen 6: First Action (Depends on chosen journey)**

If "Get Fit" chosen:
```
┌─────────────────────────────────────┐
│  Let's log your first workout! 💪   │
├─────────────────────────────────────┤
│                                     │
│  [Interactive tutorial]             │
│  → Shows Smart Pattern Memory       │
│  → User logs 1 exercise             │
│  → Celebrates completion 🎉         │
│                                     │
│  [Start Logging]                    │
└─────────────────────────────────────┘
```

If "Reduce Stress" chosen:
```
┌─────────────────────────────────────┐
│  Let's take a mindful breath 🧘     │
├─────────────────────────────────────┤
│                                     │
│  [Guided 2-minute breathing]        │
│  → Animated breathing circle        │
│  → Immediate calm experience        │
│  → Celebrates completion ✨         │
│                                     │
│  [Start Breathing]                  │
└─────────────────────────────────────┘
```

**Total time:** 2-3 minutes to first value moment

---

## 8. Accessibility Guidelines

### 8.1 Visual Accessibility

**Color Contrast (WCAG AA Minimum):**
- Body text: 7.2:1 (Deep Blue #1E3A8A on white)
- Secondary text: 4.8:1 (Gray #6B7280 on white)
- All CTAs: Minimum 4.5:1

**Text Scaling:**
- Support iOS/Android system font sizes up to 200%
- Layouts reflow gracefully (no horizontal scrolling)
- Minimum font size: 12pt (even at default scale)

**Dark Mode (P1):**
- Background: #111827 (Dark gray, not pure black)
- Text: #F9FAFB (Light gray, not pure white)
- Reduce eye strain for night use

### 8.2 Motor Accessibility

**Touch Targets:**
- Minimum: 44x44pt (iOS HIG)
- Preferred: 48x48dp (Material Design)
- Spacing: 8px minimum between tappable elements

**No Time-Based Interactions:**
- Meditation timer is optional (can pause anytime)
- No auto-dismiss modals (user controls)

**Alternative Input:**
- Swipe gestures have button alternatives
- Voice input for text fields (P1)

### 8.3 Screen Reader Support

**iOS VoiceOver:**
- All interactive elements labeled semantically
- Hint text for complex actions ("Double tap to log set")
- Logical tab order (top to bottom, left to right)

**Android TalkBack:**
- Same semantic labels as iOS
- Content descriptions for all images/icons
- Focus order matches visual order

**Image Descriptions:**
- Decorative images: `alt=""`
- Functional images: Descriptive text ("Bench press exercise illustration")

### 8.4 Language Support (MVP)

**Supported Languages:**
- English (EN-US, EN-GB)
- Polish (PL)

**i18n Architecture:**
- All strings externalized (easy to add languages)
- Date/number formatting localized
- RTL support prepared (P2)

---

## 9. Animation & Motion

### 9.1 Animation Principles

**Purpose:** Delight + Feedback + Guidance (not decoration)

**Nike Influence:** Bold, energetic (for achievements)
**Headspace Influence:** Calm, flowing (for meditation)

### 9.2 Key Animations

**Workout Logging:**
- Checkmark bounce (300ms, ease-out) - Achievement feedback
- Set completion: Light haptic + visual check fill
- PR celebration: Confetti + badge pop (Lottie, 2s)

**Meditation:**
- Breathing circle: Smooth expand/contract (4s in, 4s out)
- Fade-in transition: 2s purple → white gradient
- Player controls: Gentle slide-in (200ms)

**Streaks:**
- Milestone unlock: Full-screen confetti (Lottie, 2s) + badge bounce
- Streak card: Pulse animation on active streak (subtle, 2s loop)
- Progress bar fill: Smooth animation (500ms, ease-in-out)

**Cross-Module Insights:**
- Card slide-in: From bottom, 300ms ease-out
- Swipe dismiss: Follow finger, then slide out (200ms)
- Save action: Card shrink + move to "Saved" section (400ms)

**Navigation:**
- Tab switch: Crossfade content (200ms)
- Screen transitions: Slide (iOS standard) or fade (Android)
- Modal present: Slide up from bottom (300ms)

### 9.3 Performance

**Frame Rate:** 60 FPS minimum (120 FPS on supported devices)
**Reduce Motion:** Respect OS setting (disable decorative animations)
**Battery:** Minimize animations in background (meditation player only)

---

## 10. Design System Implementation

### 10.1 Design Tokens

**Spacing Scale (8px base):**
```
xs:  4px  (tight spacing, icon padding)
sm:  8px  (card padding, small gaps)
md:  16px (standard padding, content margins)
lg:  24px (section spacing)
xl:  32px (screen margins)
xxl: 48px (hero spacing)
```

**Border Radius:**
```
sm:  4px  (small elements)
md:  8px  (input fields)
lg:  12px (cards, buttons)
xl:  16px (hero cards)
full: 9999px (pills, badges)
```

**Shadows:**
```
sm:  0px 1px 2px rgba(0,0,0,0.05)  (subtle depth)
md:  0px 2px 8px rgba(0,0,0,0.08)  (cards)
lg:  0px 4px 12px rgba(0,0,0,0.12) (modals, insight cards)
xl:  0px 8px 24px rgba(0,0,0,0.16) (popovers)
```

### 10.2 Flutter Implementation Notes

**State Management:** Riverpod 3.0
**UI Framework:** Material Design 3 (baseline) + Custom theme
**Animations:** Flutter implicit animations + Lottie for complex
**Icons:** Heroicons (via SVG)
**Fonts:** Google Fonts package (Inter)

**Theme Structure:**
```dart
ThemeData(
  colorScheme: ColorScheme(
    primary: Color(0xFF1E3A8A), // Deep Blue
    secondary: Color(0xFF14B8A6), // Teal
    tertiary: Color(0xFFF97316), // Orange (Fitness)
    // ... (all tokens defined)
  ),
  textTheme: TextTheme(
    displayLarge: InterBold28,
    headlineMedium: InterSemiBold22,
    // ... (all type styles)
  ),
  // ... (spacing, radius, shadows as extensions)
)
```

---

## 11. Design Deliverables

### 11.1 Files to Create (Figma/Sketch)

**Component Library:**
- Buttons (Primary, Secondary, Text, Module-specific)
- Cards (Standard, Insight, Streak)
- Input fields (Text, Number, Search)
- Navigation (Bottom tabs, Headers)
- Badges, Progress bars, Sliders

**Key Screens (High-Fidelity):**
1. Onboarding flow (6 screens)
2. Home (Life Coach) - Daily plan view
3. Fitness - Log workout flow (3 screens)
4. Mind - Meditation player + Library
5. Profile - Settings & Subscription
6. Cross-Module Insight card examples (3 variants)

**Interaction Prototypes:**
- Fast workout logging (clickable prototype)
- Morning check-in flow
- Meditation start flow
- Streak milestone celebration

### 11.2 Developer Handoff

**Spec Document:** This file (ux-design-specification.md)
**Design System:** Figma file with tokens exported
**Assets:** SVG icons, Lottie animations (confetti, breathing circle)
**Prototypes:** Clickable Figma prototypes for key flows

---

## 12. Success Metrics (UX-Specific)

### 12.1 Usability Metrics

**Fast Workout Logging:**
- Target: <2s per set (95th percentile)
- Measure: Time from "Log Workout" tap to set completion
- Success: 90%+ of users log set in <2s

**Morning Check-in:**
- Target: <60s completion (95th percentile)
- Measure: Time from modal open to "Generate Plan" tap
- Success: 85%+ complete in <60s

**Meditation Start:**
- Target: <10s from tab tap to meditation playing
- Measure: Time from Mind tab tap to audio start
- Success: 95%+ start meditation in <10s

### 12.2 Engagement Metrics

**Onboarding Completion:**
- Target: 80%+ complete full onboarding
- Measure: Users who reach "First Action" screen
- Baseline: 60% industry average

**Feature Discovery:**
- Cross-Module Insights: 70%+ view at least 1 insight in first week
- Streaks: 60%+ check streak card in first 7 days
- AI Chat: 40%+ send at least 1 message

### 12.3 Retention Drivers (UX Impact)

**Streak Engagement:**
- Users with active streak (7+ days): 3x Day 30 retention
- Target: 50%+ users maintain 7-day streak by Week 2

**Weekly Summary Open Rate:**
- Target: 60%+ open Monday report notification
- Measure: Tap-through rate on push notification

**Cross-Module Insight Action Rate:**
- Target: 40%+ tap CTA on insight card
- Measure: "Adjust Plan" or "Start Meditation" tap vs dismissals

---

## 13. Next Steps

### 13.1 For Designers

1. **Create Figma Design System:**
   - Import color palette, typography, components
   - Build high-fidelity mockups for 20 key screens
   - Create interactive prototypes for 3 main flows

2. **User Testing:**
   - Test onboarding flow with 10 users (5 UK, 5 Poland)
   - Validate Fast Workout Logging UX (time to log set)
   - Test Cross-Module Insight card comprehension

3. **Iterate Based on Feedback:**
   - Refine interaction patterns
   - Adjust color palette if needed
   - Simplify any confusing flows

### 13.2 For Developers

1. **Review This Spec:**
   - Understand UX principles and rationale
   - Flag any technical constraints (e.g., animation performance)
   - Align on feasibility of <2s workout logging

2. **Set Up Design System in Flutter:**
   - Implement theme with all tokens
   - Build reusable components (buttons, cards, inputs)
   - Test on iOS + Android (visual parity)

3. **Build MVP Screens:**
   - Start with Onboarding → Home → Fitness logging flow
   - Implement Smart Pattern Memory backend logic
   - Test offline-first architecture

### 13.3 For Product/PM

1. **Validate Assumptions:**
   - Does Fast Workout Logging really drive retention?
   - Is 1 insight/day the right frequency?
   - Should streak freeze be 1/week or more?

2. **Prioritize Features:**
   - Which P1 features are essential for retention?
   - Can we defer any MVP features to P1?
   - Dark mode: MVP or P1?

3. **Define Success Criteria:**
   - Set baseline metrics for usability tests
   - Define "Good" vs "Excellent" UX performance
   - Plan A/B tests (e.g., AI personality choice impact)

---

## Document Status

✅ **COMPLETE** - Ready for design implementation

**Version:** 1.0
**Last Updated:** 2025-01-16
**Next Review:** After Figma mockups complete

---

_This UX Design Specification was created collaboratively between Mariusz and Sally (UX Designer) using the BMAD Methodology. It synthesizes insights from Nike Training Club (speed, clarity) and Headspace (emotion, calm) to create an achievement-driven, friction-free experience for LifeOS users._

**Design Philosophy:** "Fast when you need speed (Fitness), calm when you need peace (Mind), and empowering always (Life Coach)."

🎨 Ready to bring LifeOS to life!
