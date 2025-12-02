# GymApp - UX Design Specification

**Date:** 2025-11-15
**Version:** 1.0
**Author:** UX Designer Agent + Mariusz
**Project:** GymApp (Mobile Fitness Tracker with MindPeace Zone)

---

## Executive Summary

GymApp to nowoczesna aplikacja mobilna fitness z unikalną funkcją **MindPeace Zone** dla medytacji i mindfulness. Aplikacja oferuje **dwa tryby widoku** (Standard View i Quick View) dostosowane do różnych preferencji użytkowników, z adaptacyjnymi motywami kolorystycznymi dla trzech głównych stref: Workout, MindPeace i Analytics.

**Kluczowe Decyzje UX:**
- Material Design 3 jako fundament + custom theming
- Dark Mode domyślnie (inspiracja: Spotify)
- 3 dynamiczne motywy kolorystyczne (Workout/MindPeace/Analytics)
- 2 tryby widoku: Standard (rich data) i Quick (minimal focus)
- Bottom navigation (thumb-friendly)
- Integracja muzyki jako core feature (Spotify/YouTube)
- Maksymalna prostota: MAX 3 taps do akcji (inspiracja: Strong app)

---

## 1. Design System Foundation

### 1.1 Design System Choice

**Wybór:** Material Design 3 (Material You) + Custom Theming

**Uzasadnienie:**
- ✅ Natywny support w Flutter (szybszy development)
- ✅ Świetny dark mode out-of-the-box
- ✅ Komponenty accessibility-ready (WCAG 2.1 AA)
- ✅ Możliwość custom theming dla 3 stref
- ✅ Proven patterns (buttons, forms, modals, alerts)
- ✅ Responsive grid system

**Material Components Used:**
- Bottom Navigation Bar
- Cards (elevated, filled)
- Buttons (filled, outlined, text)
- Text Fields
- Progress Indicators
- Dialogs/Modals
- Chips/Badges
- FAB (Floating Action Button)

---

## 2. Visual Foundation

### 2.1 Color System - 3 Adaptive Themes

**Philosophy:** Aplikacja zmienia motyw kolorystyczny w zależności od strefy, w której znajduje się użytkownik.

#### **💪 Workout Zone Theme**
**Emocja:** Energia, Motywacja, Akcja

**Paleta:**
- **Primary:** `#FF6B6B` → `#FF5252` (gradient, czerwony/koralowy)
- **Secondary:** `#FFA726` → `#FF7043` (gradient, pomarańczowy)
- **Accent:** `#FFD93D` → `#FFC107` (gradient, żółty)
- **Success:** `#4CAF50` (zielony)
- **Error:** `#EF4444` (czerwony)

**Zastosowanie:**
- Home screen przy aktywnym workout mode
- Workout logging screens
- Exercise library
- Streak badges
- Primary action buttons w kontekście treningu

**Psychologia:** Ciepłe, energetyczne kolory (czerwień, pomarańcz) zwiększają motywację do działania i podnoszą poziom energii.

---

#### **🧘 MindPeace Zone Theme**
**Emocja:** Spokój, Relaks, Wyciszenie

**Paleta:**
- **Primary:** `#A78BFA` → `#8B5CF6` (gradient, fiolet)
- **Secondary:** `#60A5FA` → `#3B82F6` (gradient, niebieski)
- **Accent:** `#34D399` → `#10B981` (gradient, miętowy)
- **Calm:** `#C084FC` → `#A855F7` (gradient, jasny fiolet)
- **Soft:** `#93C5FD` → `#60A5FA` (gradient, błękit)

**Zastosowanie:**
- MindPeace zone screens
- Meditation sessions
- Music player interface
- Breathing exercises
- Sleep tracking (future)

**Psychologia:** Fiolety i błękity uspokajają układ nerwowy, sprzyjają relaksowi i medytacji. Soft gradienty tworzą atmosferę bezpieczeństwa.

---

#### **📊 Analytics Zone Theme**
**Emocja:** Fokus, Klarowność, Wgląd

**Paleta:**
- **Primary:** `#3B82F6` → `#2563EB` (gradient, niebieski)
- **Secondary:** `#10B981` → `#059669` (gradient, zielony)
- **Accent:** `#06B6D4` → `#0891B2` (gradient, cyan)
- **Chart 1:** `#8B5CF6` (fiolet)
- **Chart 2:** `#10B981` (zielony)

**Zastosowanie:**
- Progress charts
- Analytics dashboard
- Weekly reports
- Data export screens
- Statistics views

**Psychologia:** Niebiesko-zielone tony wspomagają koncentrację i analizę danych. High contrast zapewnia czytelność liczb.

---

### 2.2 Dark Mode Foundation

**Default:** Dark Mode (jak Spotify)

**Background Colors:**
- **Primary Background:** `#121212` (ekran główny)
- **Surface:** `#1a1a1a` (karty, komponenty)
- **Surface Variant:** `#2a2a2a` (inputs, secondary surfaces)

**Text Colors:**
- **Primary Text:** `#e0e0e0` (główny tekst)
- **Secondary Text:** `#9ca3af` (meta info, labels)
- **Disabled Text:** `#6b7280`

**Uzasadnienie Dark Mode:**
- ✅ Łagodny dla oczu w siłowni (często słabe oświetlenie)
- ✅ Premium feeling (Apple Fitness+, Spotify)
- ✅ Oszczędność baterii na OLED (iOS/Android)
- ✅ Lepszy kontrast dla wykresów i danych
- ✅ Wspiera medytację (MindPeace zone - nie oślepia)

---

### 2.3 Typography

**Font Family:**
- **Primary:** Roboto (Material Design default)
- **Headings:** Roboto Bold, Medium
- **Body:** Roboto Regular
- **Numbers/Stats:** Roboto Mono (dla wyraźności cyfr)

**Type Scale:**
- **H1 (Screen Title):** 28sp, Bold, Letter spacing -0.5
- **H2 (Section Header):** 24sp, Bold
- **H3 (Card Title):** 18sp, Semibold
- **Body Large:** 16sp, Regular
- **Body Medium:** 14sp, Regular
- **Caption:** 12sp, Regular
- **Button:** 14sp, Semibold, Uppercase

**Line Height:**
- Headings: 1.2
- Body text: 1.6 (czytelność)
- Captions: 1.4

**Accessibility:**
- Minimum font size: 12sp
- Support dla Dynamic Type (iOS) i Font Scaling (Android)
- Testowane przy 200% scale

---

### 2.4 Spacing & Layout

**Base Unit:** 8dp (Material Design standard)

**Spacing Scale:**
- **xs:** 4dp
- **sm:** 8dp
- **md:** 16dp (default padding)
- **lg:** 24dp
- **xl:** 32dp
- **2xl:** 48dp

**Layout Grid:**
- Mobile: Single column, 16dp horizontal padding
- Tablet: 2-column adaptive (future)

**Card Padding:** 16dp internal
**Screen Padding:** 16dp horizontal, 24dp vertical

---

## 3. Dual View Modes

### 3.1 Overview

GymApp oferuje **2 tryby widoku** dostosowane do różnych preferencji użytkowników:

#### **Standard View** (Direction 1 + 3 Combined)
**"Rich Data Mode"** - Card-Heavy + Analytics

**Charakterystyka:**
- Card-based layout (przyjazny, prowadzi użytkownika)
- Bogate dane i wykresy (z Direction 3)
- Medium-high information density
- Bottom navigation (4-5 tabs)
- Wszystko na widoku: stats, progress, quick actions

**Dla kogo:**
- Użytkownicy którzy chcą wszystko na widoku
- Analytical types (lubią metryki)
- Planowanie treningów w domu
- Analiza postępów

---

#### **Quick View** (Direction 2)
**"Focus Mode"** - Minimal Quick Actions

**Charakterystyka:**
- Spacious, minimalist layout
- Quick action grid (duże przyciski)
- Low information density
- Bottom navigation (3 tabs max)
- MAX 3 taps do akcji

**Dla kogo:**
- Power users (speed-focused)
- W siłowni (szybkie logowanie)
- W ruchu (zero distrakcji)
- Starsi użytkownicy (prostota)

---

### 3.2 Switching Between Modes

**Metoda A: Settings Toggle**
```
Settings → Display Preferences → View Mode
- ○ Standard View (Rich data and cards)
- ○ Quick View (Minimal and fast)
```

**Metoda B: Quick Gesture Switch**
```
Long-press na Home icon (bottom nav) → Quick menu:
- "Switch to Quick View"
- "Switch to Standard View"
```

**Default:** Standard View dla nowych użytkowników

**Onboarding Question:**
"Jak wolisz korzystać z aplikacji?"
- [ ] Więcej informacji i prowadzenia (Standard View)
- [ ] Prostota i szybkość (Quick View)

**Persistence:** Wybór zapisywany lokalnie (SharedPreferences/UserDefaults)

---

## 4. Navigation Architecture

### 4.1 Bottom Navigation (Primary)

**Standard View - 4 Tabs:**
1. 🏠 **Home** - Dashboard, today's actions, streak
2. 💪 **Workout** - Active workout, exercise library
3. 🧘 **MindPeace** - Meditation, music, calm
4. 📊 **Progress** - Charts, analytics, history

**Quick View - 3 Tabs:**
1. 🏠 **Home** - Quick actions only
2. 📈 **Stats** - Minimal stats view
3. 👤 **Profile** - Settings, account

**Design:**
- Material Bottom Navigation Bar
- Icons: Material Icons + custom for brand
- Active state: Theme color (Workout red, MindPeace purple, etc.)
- Ripple effect on tap
- Haptic feedback (iOS/Android vibration)

---

### 4.2 Top Navigation (Context-Specific)

**Back Button:**
- Material back arrow (top-left)
- Swipe from left edge (iOS gesture)

**Context Menu:**
- 3-dot menu (top-right) dla opcji kontekstowych
- Share, Export, Settings (per-screen)

---

### 4.3 Floating Action Button (FAB)

**Standard View:**
- Visible na Home screen
- **Icon:** + (plus)
- **Action:** "Start Workout" (main CTA)
- **Color:** Workout theme primary (#FF6B6B)
- **Position:** Bottom-right (above bottom nav)

**Quick View:**
- Not used (duży button na ekranie zamiast FAB)

---

## 5. Key User Journeys

### 5.1 Workout Logging Flow (Core Feature)

**Goal:** Zalogować trening w <2 minuty z Smart Pattern Memory

**Standard View Journey:**

```
Step 1: Home Screen
  ↓ Tap "Start Workout" (card or FAB)

Step 2: Workout Type Selection
  - "Push Day" (pre-filled from last session)
  - OR "Quick Start" (freestyle)
  ↓ Tap workout type

Step 3: Exercise Selection
  - Search bar (top)
  - Recent exercises (auto-shown)
  - "Bench Press" (select from list)
  ↓ Tap exercise

Step 4: Smart Pattern Memory Screen
  📋 Display:
    "Last time: 4×12 @ 90kg"
    "Date: 2025-11-10"

  Pre-filled sets:
    Set 1: 12 reps, 90kg [Edit] [✓]
    Set 2: 12 reps, 90kg [Edit] [✓]
    Set 3: 12 reps, 90kg [Edit] [✓]
    Set 4: 12 reps, 90kg [Edit] [✓]

  [+ Add Set] [Complete Exercise]
  ↓ Tap checkmarks or edit, then "Complete Exercise"

Step 5: Next Exercise
  - Auto-advance to next exercise in workout
  - OR "Finish Workout"
  ↓ Repeat for all exercises

Step 6: Workout Summary
  Display:
    "Workout Complete! 🎉"
    Duration: 45 min
    Exercises: 6
    Total Volume: 4,250kg
    New PR: +2.5kg Bench Press

  [Save Workout] [Share]
  ↓ Tap "Save Workout"

Step 7: Confirmation
  - Toast: "Workout saved!"
  - Update streak (+1 day)
  - Return to Home
```

**Quick View Journey:**
```
Step 1: Home → Tap giant "Start Workout" button
Step 2: Exercise name (voice or text search)
Step 3: Sets/Reps/Weight (pre-filled, tap to accept)
Step 4: Next exercise OR Finish
```

**Key UX Principles:**
- ✅ MAX 3 taps per exercise (goal achieved with Smart Pattern Memory)
- ✅ Pre-fill everything possible
- ✅ Clear visual feedback (checkmarks, progress)
- ✅ Offline-first (works without internet)

---

### 5.2 MindPeace Meditation Flow

**Goal:** Rozpocząć sesję medytacji z muzyką w <30 sekund

**Standard View Journey:**

```
Step 1: Bottom Nav → Tap "🧘 MindPeace"

Step 2: MindPeace Home
  Theme switches to Purple/Blue
  Display:
    "Find your calm 🧘"

    Featured Session Card:
      "Morning Calm - 10 min"
      "Guided meditation"
      [Start Session]

    Music Player (if active):
      Track: "Peaceful Piano"
      Artist: "Relaxing Sounds"
      [◀ ▶ ⏭]

    Stats:
      7 Day Streak | 45m This Week

    Browse Sessions:
      - Breathing Exercises
      - Sleep Meditation
      - Stress Relief

  ↓ Tap "Start Session"

Step 3: Session Setup (Optional)
  - Duration: [5min] [10min] [15min] [20min]
  - Background Music: [On/Off]
  - Voice Guide: [On/Off]
  ↓ Tap "Begin"

Step 4: Active Session Screen
  Full-screen immersive:
    Theme: Soft purple gradient background

    Center:
      Timer: 10:00 (counting down)
      Breathing circle (animated expand/contract)

    Bottom:
      [Pause] [End Session]

  Audio: Gentle voice guide + ambient music

  ↓ Complete or tap "End Session"

Step 5: Session Complete
  "Great job, Mariusz! 🧘"

  Duration: 10 min
  Streak: 8 days 🔥

  [Save Session] [Share Progress]
```

**Music Integration:**
- Spotify/YouTube embeds
- Native player controls
- Background playback
- Playlist support
- User can add own tracks

---

### 5.3 Progress Tracking Flow

**Goal:** Zobacz postęp siły w konkretnym ćwiczeniu

**Standard View Journey:**

```
Step 1: Bottom Nav → Tap "📊 Progress"

Step 2: Analytics Dashboard
  Theme switches to Blue/Green

  Display:
    "Analytics Dashboard"

    Chart: Strength Progression (line chart)
      - Last 90 days
      - Multiple exercises tracked
      - Trend lines

    Quick Stats Grid:
      142 Total Workouts
      +18kg Total Gains
      85% Consistency
      45h Training Time

    Weekly Summary Card:
      Nov 10-16, 2025
      Workouts: 5/5 ✓
      Squat PR: +5kg
      Volume: 12,450kg

    [View Detailed Charts] [Export Data]

  ↓ Tap exercise name on chart

Step 3: Exercise Detail View
  "Bench Press - Progress"

  Chart: Weight over Time
    - Line chart showing progression
    - PR markers highlighted
    - Date range selector

  Stats:
    Current PR: 95kg
    Starting (90 days ago): 80kg
    Total Gain: +15kg
    Average gain: +1.67kg/month

  History:
    [List of all Bench Press sessions]
    Date | Sets | Weight | Volume

  [Export CSV] [Set Goal]
```

**Key Features:**
- FREE charts (competitive advantage vs Strong app £45/year paywall)
- Concrete numbers (+5kg squat) not vanity metrics
- fl_chart library (MVP) → Syncfusion (P2 for advanced)

---

## 6. Component Library

### 6.1 Shared Components (Both Views)

**Buttons:**
- **Primary Button:** Filled, theme color, rounded 12dp
- **Secondary Button:** Outlined, 2dp border, rounded 12dp
- **Text Button:** No background, theme color text
- **FAB:** Circular, 56dp, shadow, theme color

**Cards:**
- **Elevated Card:** 4dp elevation, rounded 16dp, left border accent
- **Filled Card:** Solid background, rounded 16dp
- **Compact Card:** Minimal padding, rounded 12dp

**Inputs:**
- **Text Field:** Material filled style, rounded top, 2dp bottom line
- **Search Bar:** Rounded 24dp pill, magnifying glass icon
- **Number Stepper:** -/+ buttons with number display

**Progress Indicators:**
- **Linear Progress Bar:** 8dp height, rounded, gradient fill
- **Circular Progress:** 48dp, theme color
- **Streak Badge:** Rounded pill, gradient, fire emoji

**Alerts/Toasts:**
- **Success Alert:** Green left border, check icon
- **Error Alert:** Red left border, warning icon
- **Info Alert:** Blue left border, info icon
- **Toast:** Bottom sheet, 4s auto-dismiss

---

### 6.2 Standard View Specific

**Stat Box:**
- Background: surface color
- Value: Large bold number (2rem), theme color
- Label: Small caps, secondary text
- Used in: 2×2 grid on dashboards

**Exercise List Item:**
- Icon/thumbnail (left)
- Exercise name + meta (center)
- Weight/reps (right, bold)
- Swipe actions: Edit, Delete

**Music Player Card:**
- Gradient background (theme)
- Track info (center)
- Progress bar
- Play/pause/skip controls
- Spotify/YouTube logo

---

### 6.3 Quick View Specific

**Action Card (Large):**
- 120dp × 120dp minimum
- Icon: 3rem
- Label: 1.1rem bold
- Full-width option available
- Gradient background for primary actions

**Minimal Stat Display:**
- Centered layout
- Giant number (3rem+)
- Small label below
- No background (uses screen background)

---

## 7. UX Patterns & Consistency Rules

### 7.1 Button Hierarchy

**Primary Action:**
- Style: Filled gradient button
- Color: Theme primary
- Usage: Main CTA per screen (max 1)
- Example: "Start Workout", "Save", "Begin Session"

**Secondary Action:**
- Style: Outlined button
- Color: Neutral border, theme color text
- Usage: Alternative actions (2-3 per screen)
- Example: "Skip", "Cancel", "Browse"

**Tertiary Action:**
- Style: Text button
- Color: Theme color text, no background
- Usage: Low-priority actions
- Example: "Learn More", "See All"

**Destructive Action:**
- Style: Filled button
- Color: Error red (#EF4444)
- Usage: Delete, Remove, Reset
- Example: "Delete Workout", "Clear Data"

---

### 7.2 Feedback Patterns

**Success Feedback:**
- **Toast:** Green check icon + message, 3s
- **Inline:** Green text below action
- **Modal:** Full-screen success with animation (streak milestones)
- **Haptic:** Light impact (iOS), short vibration (Android)

**Error Feedback:**
- **Toast:** Red warning icon + message, 4s
- **Inline:** Red text with icon, shake animation
- **Modal:** For critical errors only
- **Haptic:** Heavy impact (iOS), double vibration (Android)

**Loading States:**
- **Inline:** Circular progress (24dp) replaces content
- **Full-screen:** Centered spinner with "Loading..." text
- **Skeleton:** Animated placeholder (for lists)
- **No spinners for <500ms actions**

---

### 7.3 Form Patterns

**Label Position:**
- Floating labels (Material Design standard)
- Move to top when focused/filled

**Required Fields:**
- Red asterisk (*) next to label
- Error state if submitted empty

**Validation Timing:**
- **onBlur** (when user leaves field) - Best UX
- NOT onChange (too aggressive)
- NOT onSubmit only (too late)

**Error Display:**
- Inline below field (red text, icon)
- Shake animation on error
- Focus moved to first error field

**Help Text:**
- Caption below field (gray)
- Tooltip icon (?) for complex fields

---

### 7.4 Modal Patterns

**Size Variants:**
- **Small:** Confirmations (300dp max width)
- **Medium:** Forms (400dp max width)
- **Large:** Complex content (90% screen width)
- **Full-Screen:** Immersive experiences (meditation)

**Dismiss Behavior:**
- **Click outside:** Dismiss for non-critical modals
- **Escape/Back:** Always dismiss
- **Explicit close:** X button (top-right)
- **Swipe down:** Dismiss on mobile (sheet-style)

**Focus Management:**
- Auto-focus first input field
- Trap focus inside modal (accessibility)
- Return focus to trigger element on close

---

### 7.5 Navigation Patterns

**Active State Indication:**
- Bottom nav: Theme color icon + label
- Subtle background highlight
- Ripple effect on tap

**Back Button Behavior:**
- Browser back: Goes to previous screen (web)
- App back: Standard navigation back
- Workout in progress: Confirm before exit

**Deep Linking:**
- Support for: `/workout/:id`, `/exercise/:id`, `/meditation/:id`
- Opens app to specific screen
- Shareable URLs

---

### 7.6 Empty State Patterns

**First Use (No Data):**
- Illustration/icon (center)
- Friendly message: "No workouts yet!"
- CTA: "Start Your First Workout"
- Guidance: Brief explanation

**No Results (Search/Filter):**
- "No exercises found"
- Suggestion: "Try different keywords"
- CTA: "Clear filters" or "Browse all"

**Cleared Content:**
- "All done! 🎉"
- Option: "Undo" if recently cleared
- CTA: "Add new" to populate again

---

### 7.7 Notification Patterns

**Placement:**
- **Toast:** Bottom (above bottom nav), 16dp margin
- **Banner:** Top (below status bar), swipe to dismiss
- **Badge:** Red dot on tab icon (notifications)

**Duration:**
- **Success:** 3 seconds, auto-dismiss
- **Error:** 5 seconds, manual dismiss available
- **Info:** 4 seconds, auto-dismiss

**Stacking:**
- Max 1 toast visible at a time
- Queue additional toasts (show sequentially)

**Priority Levels:**
- **Critical:** Full-screen modal (account issues)
- **Important:** Banner notification (streak ending)
- **Info:** Toast (workout saved)

---

### 7.8 Confirmation Patterns

**Delete Actions:**
- **Always confirm** for permanent deletes
- Modal: "Delete this workout?"
- Options: [Cancel] [Delete] (red)
- Undo not possible → require confirmation

**Leave Unsaved:**
- Detect unsaved changes
- Modal: "Discard changes?"
- Options: [Stay] [Discard]

**Irreversible Actions:**
- Two-step confirmation for critical actions
- Example: Delete account → type "DELETE" to confirm

---

## 8. Responsive Design & Accessibility

### 8.1 Responsive Breakpoints

**Mobile (Primary Focus):**
- **Width:** 360dp - 414dp (iPhone/Android standard)
- **Layout:** Single column, full-width components
- **Nav:** Bottom navigation bar
- **Density:** Optimized for thumb zone

**Tablet (Future - P2):**
- **Width:** 768dp+
- **Layout:** 2-column adaptive grid
- **Nav:** Side navigation drawer (left)
- **Density:** More content visible

**Adaptation Patterns:**
- Bottom nav → Sidebar (tablet)
- Single column → 2-column grid (tablet)
- Modal → Inline panel (tablet)

---

### 8.2 Touch Target Sizes

**Minimum Touch Targets:**
- **Buttons:** 48dp × 48dp (Material minimum)
- **Icons:** 44dp × 44dp (Apple HIG)
- **List items:** 56dp min height
- **FAB:** 56dp diameter

**Why Larger:**
- Gym environment (sweaty hands, gloves)
- Accessibility (motor impairments)
- Reduces mis-taps

---

### 8.3 Accessibility (WCAG 2.1 AA)

**Color Contrast:**
- **Normal text:** 4.5:1 minimum ratio
- **Large text (18sp+):** 3:1 minimum ratio
- **Tested:** All theme colors vs backgrounds

**Dynamic Text Sizing:**
- Support iOS Dynamic Type
- Support Android Font Scaling
- Test at 200% scale

**Screen Reader Support:**
- Semantic labels for all UI elements
- **iOS VoiceOver:** Complete navigation
- **Android TalkBack:** Complete navigation
- Alt text for all meaningful images

**Keyboard Navigation:**
- Tab order logical (top→bottom, left→right)
- Focus indicators visible (2dp outline)
- All actions keyboard-accessible

**Motion & Animations:**
- Respect "Reduce Motion" settings (iOS/Android)
- Provide static alternatives for animations
- No essential info conveyed by motion alone

---

## 9. Music Integration Strategy

### 9.1 Supported Services

**Phase 1 (MVP):**
- **YouTube Music:** Embeds via YouTube API
- **Manual Upload:** User uploads MP3/AAC files

**Phase 2 (P1):**
- **Spotify:** OAuth integration, playlist sync
- **Apple Music:** MusicKit integration (iOS)

### 9.2 Player Controls

**Standard Player (MindPeace Zone):**
- Track info (title, artist)
- Progress bar (seekable)
- Controls: Previous, Play/Pause, Next
- Volume slider
- Shuffle, Repeat toggle

**Mini Player (Global):**
- Collapsed bar (bottom, above nav)
- Track info (scrolling text)
- Play/Pause only
- Tap to expand full player

**Background Playback:**
- Continue playing when app backgrounded
- Lock screen controls (iOS/Android)
- Notification with controls

---

### 9.3 Playlists & Recommendations

**User Playlists:**
- Create custom playlists
- "Workout Mix" (energetic)
- "Meditation Mix" (calm)
- Import from Spotify (P2)

**App Playlists (Curated):**
- "Focus Workout" (instrumental, 140 BPM)
- "Peaceful Mind" (ambient, nature sounds)
- "Morning Energy" (upbeat, motivational)

**Recommendations:**
- Based on zone (Workout → energetic, MindPeace → calm)
- Based on time of day
- Based on user listening history (P2)

---

## 10. Alert System

### 10.1 Push Notifications

**Daily Check-in (8am local time):**
- Title: "Ready for today's workout? 💪"
- Body: "You're on a 7-day streak! Keep it going."
- Action: Open app to Home screen

**Streak Reminder (9pm if no workout logged):**
- Title: "Don't break your streak! 🔥"
- Body: "Log a quick workout or rest day to keep your 7-day streak."
- Action: Open workout logger or mark rest day

**Weekly Report (Sunday 7pm):**
- Title: "Your Weekly Progress 📊"
- Body: "4 workouts, +5kg squat PR! See your full report."
- Action: Open Analytics screen

**Milestone Achievements:**
- Title: "Streak Milestone! 🎉"
- Body: "You've hit 30 days! Bronze badge unlocked."
- Action: Open achievement screen

### 10.2 In-App Alerts

**Success:**
- "Workout saved! +1 day streak 🔥"
- "Meditation complete! Great session."
- "New PR! +2.5kg Bench Press 💪"

**Errors:**
- "Connection lost. Data saved locally."
- "Failed to export. Please try again."

**Warnings:**
- "Your streak ends tonight! Log a workout or rest day."
- "Account storage 90% full. Consider exporting data."

---

## 11. Implementation Priorities

### 11.1 MVP (Phase 1) - Must Have

**Core UX:**
- ✅ Standard View layout (primary)
- ✅ Workout theme (red/orange)
- ✅ Bottom navigation (4 tabs)
- ✅ Smart Pattern Memory UI
- ✅ Progress charts (fl_chart library)
- ✅ Dark mode foundation
- ✅ Basic alerts/toasts

**Components:**
- ✅ Buttons, Cards, Inputs (Material Design 3)
- ✅ Exercise list
- ✅ Stat boxes
- ✅ Progress bars

**Not in MVP:**
- ❌ Quick View (defer to P1)
- ❌ MindPeace theme (defer to P1)
- ❌ Music player (defer to P1)
- ❌ Advanced charts (defer to P2)

---

### 11.2 P1 (Months 4-9) - Enhance

**Add:**
- ✅ Quick View mode
- ✅ MindPeace Zone theme + screens
- ✅ Music player integration (YouTube)
- ✅ Analytics theme
- ✅ View mode switcher (Settings + gesture)
- ✅ Enhanced animations (Lottie)

---

### 11.3 P2 (Months 10-18) - Differentiate

**Add:**
- ✅ Advanced charts (Syncfusion)
- ✅ Spotify integration
- ✅ Tablet layouts (responsive)
- ✅ AI personality themes (UX adaptation)
- ✅ Voice input UX
- ✅ Progress photo gallery

---

## 12. Design Deliverables

**Created:**
1. ✅ **Color Themes Visualizer** (`ux-color-themes.html`)
   - 3 complete themes with components
   - Interactive browser preview

2. ✅ **Design Directions Mockups** (`ux-design-directions.html`)
   - 8 different UX approaches
   - 3 fully developed with screens
   - Interactive comparison

3. ✅ **UX Design Specification** (`ux-design-specification.md`)
   - Complete design system documentation
   - User journeys
   - Component library
   - UX patterns
   - Accessibility guidelines

**Next Steps for Development:**
1. Architecture team: System design based on UX requirements
2. Dev team: Implement Material Design 3 theming in Flutter
3. Create reusable component library (atomic design)
4. Implement Standard View first (MVP)
5. Add Quick View in P1

---

## 13. Success Metrics

**UX Quality Metrics:**
- ✅ **Logging speed:** <2 minutes per workout (measured)
- ✅ **App rating:** 4.5+ stars (UX quality indicator)
- ✅ **NPS:** 50+ (users love the design)
- ✅ **Accessibility:** Pass WCAG 2.1 AA audit
- ✅ **Crash rate:** <0.5% (stability)

**Engagement Metrics:**
- ✅ **View mode adoption:** 70%+ Standard, 30% Quick
- ✅ **Theme switch frequency:** Track which zones used most
- ✅ **Music integration:** 50%+ users play music during meditation

---

## Appendix A: Inspirations Applied

**From Apple Fitness+:**
- ✅ Rings & streaks for gamification
- ✅ Premium animations and polish
- ✅ Personalized notifications

**From Strava:**
- ✅ Clean, intuitive navigation (mobile-first)
- ✅ Real-time stats during workout
- ✅ Social integration patterns (future P1)

**From Spotify:**
- ✅ Dark UI as default (easy on eyes)
- ✅ Minimalist design philosophy
- ✅ Bottom navigation (thumb zone)
- ✅ Music player interface patterns
- ✅ Playlist organization

**From Strong:**
- ✅ MAX 3 taps to log exercise
- ✅ Distraction-free during workout
- ✅ Fast onboarding (60 sec to first workout)
- ✅ Clear visual hierarchy for sets/reps

---

## Appendix B: Design Decisions Rationale

**Why 2 View Modes?**
- Flexibility: Different users, different needs
- Context: Home (Standard) vs Gym (Quick)
- Accessibility: Quick View easier for older users
- Differentiation: Competitors don't offer this

**Why Dark Mode Default?**
- Gym environment (dim lighting)
- Battery saving (OLED screens)
- Premium feeling (Apple/Spotify standard)
- Better for meditation (MindPeace zone)

**Why 3 Adaptive Themes?**
- Context switching (Workout vs Meditation very different moods)
- Emotional design (colors affect psychology)
- Visual hierarchy (helps users know where they are)
- Memorable (unique to GymApp)

**Why Bottom Navigation?**
- Thumb zone (reachable on large phones)
- Mobile-first best practice
- Familiar pattern (Spotify, Instagram, Apple Music)
- Faster than hamburger menu

---

**Document Complete.**
**Ready for Architecture and Development Handoff.**

---

_Created through collaborative UX design process._
_Mariusz (Product Owner) + UX Designer Agent_
_2025-11-15_