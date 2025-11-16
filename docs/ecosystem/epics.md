# LifeOS - Epic & Story Breakdown

**Author:** John (Product Manager - BMAD)
**Date:** 2025-01-16
**Version:** 1.0
**Project:** LifeOS (Life Operating System)
**Source:** PRD.md (123 FRs, 37 NFRs)

---

## Executive Summary

Ten dokument dekompozycje 123 Functional Requirements z PRD na **9 implementable epics** z **~60 user stories**. Każdy epic dostarcza end-to-end user value (nie technical layers). Stories są vertical slices, completable by single dev agent in one focused session.

**Epic Structure:**
1. **Core Platform Foundation** - Auth, data sync, GDPR (6 stories)
2. **Life Coach MVP** - Daily planning, goals, AI chat (10 stories)
3. **Fitness Coach MVP** - Smart Pattern Memory, logging (10 stories)
4. **Mind & Emotion MVP** - Meditation, mood, CBT (12 stories)
5. **Cross-Module Intelligence** - Killer feature (5 stories)
6. **Gamification & Retention** - Streaks, badges (6 stories)
7. **Onboarding & Subscriptions** - Trial, payment (7 stories)
8. **Notifications & Engagement** - Push, reminders (5 stories)
9. **Settings & Profile** - Account management (5 stories)

**Total:** 9 Epics, 66 Stories

**Sequencing Principle:**
- Epic 1 establishes foundation
- Epics 2-4 are parallel (core modules)
- Epic 5+ depend on earlier epics
- No forward dependencies

---

## Epic 1: Core Platform Foundation

**Goal:** Establish core authentication, data sync infrastructure, and GDPR compliance foundation that all modules depend on.

**Value:** Users can create accounts, log in securely across devices, and have confidence their data is private and exportable.

**FRs Covered:** FR1-FR5 (Authentication), FR98-FR103 (Data Management & Privacy)

**Dependencies:** None (foundation epic)

**Stories:** 6

---

### Story 1.1: User Account Creation

**Phase:** MVP

**As a** new user
**I want** to create an account using email or social authentication
**So that** I can start using LifeOS and have my data synced across devices

**Acceptance Criteria:**

1. User can register with email + password (min 8 chars, 1 uppercase, 1 number, 1 special char)
2. User can register with Google OAuth 2.0 (Android + iOS)
3. User can register with Apple Sign-In (iOS)
4. Email verification sent after registration (link expires in 24h)
5. User profile created with default settings (name, email, avatar placeholder)
6. User redirected to onboarding flow after successful registration
7. Error handling: Email already exists, invalid email format, weak password
8. Supabase Auth integration working (session management)

**FRs:** FR1

**UX Notes:**
- Use Supabase Auth UI library (styled with LifeOS Deep Blue theme)
- Social auth buttons: Google (white), Apple (black)
- "Sign up with email" option below social buttons
- Privacy policy link visible before registration

**Prerequisites:** None (first story)

**Technical Notes:**
- Supabase Auth configured (email + social providers)
- PostgreSQL user table with RLS policies
- Flutter Supabase SDK integrated

---

### Story 1.2: User Login & Session Management

**Phase:** MVP

**As a** returning user
**I want** to log in securely and stay logged in across app restarts
**So that** I don't have to re-authenticate every time I open the app

**Acceptance Criteria:**

1. User can log in with email + password
2. User can log in with Google OAuth 2.0
3. User can log in with Apple Sign-In
4. Session persists for 30 days of inactivity
5. User auto-logged in on app restart if session valid
6. User can log out manually (session cleared)
7. Error handling: Invalid credentials, account not verified, session expired
8. "Remember me" checkbox (optional, defaults to true)

**FRs:** FR2

**UX Notes:**
- Login screen: Email + password fields, "Forgot password?" link
- Social auth buttons above email login
- "Don't have an account? Sign up" link at bottom
- Loading state during authentication

**Prerequisites:** Story 1.1 (account creation must exist)

**Technical Notes:**
- Supabase session token stored in secure storage (iOS Keychain, Android KeyStore)
- Auto-refresh token before expiration

---

### Story 1.3: Password Reset Flow

**Phase:** MVP

**As a** user who forgot their password
**I want** to reset it via email
**So that** I can regain access to my account

**Acceptance Criteria:**

1. User can request password reset from login screen
2. Email sent with reset link (expires in 1 hour)
3. Reset link opens password change screen (deep link)
4. User can set new password (same validation as registration)
5. User auto-logged in after successful password reset
6. Old password invalidated after reset
7. Error handling: Email not found, link expired, weak new password

**FRs:** FR3

**UX Notes:**
- "Forgot password?" link on login screen → Modal with email input
- "Check your email" confirmation screen
- Password reset screen: New password + confirm password fields
- Success message: "Password reset successfully! Logging you in..."

**Prerequisites:** Story 1.1, Story 1.2

**Technical Notes:**
- Supabase password reset flow
- Email template customized with LifeOS branding

---

### Story 1.4: User Profile Management

**Phase:** MVP

**As a** user
**I want** to update my profile information
**So that** my account reflects my current details

**Acceptance Criteria:**

1. User can update name
2. User can update email (requires re-verification)
3. User can update avatar (upload from gallery or camera)
4. User can change password (requires current password confirmation)
5. Changes saved to Supabase and synced across devices
6. Avatar uploaded to Supabase Storage (max 5MB, JPG/PNG)
7. Error handling: Invalid email, weak password, upload failed

**FRs:** FR4

**UX Notes:**
- Profile screen accessible from Profile tab
- Edit mode: Inline editing with "Save" button
- Avatar: Circular image with "Change photo" button overlay
- Form validation before save

**Prerequisites:** Story 1.1, Story 1.2

**Technical Notes:**
- Supabase Storage bucket for avatars (public read, user-specific write)
- Image compression before upload (max 512x512px)

---

### Story 1.5: Data Sync Across Devices

**Phase:** MVP

**As a** user with multiple devices
**I want** my data synced in real-time
**So that** I can seamlessly switch between my phone and tablet

**Acceptance Criteria:**

1. Workout data synced via Supabase Realtime (<5s latency)
2. Mood logs synced across devices
3. Goals synced across devices
4. Meditation progress synced across devices
5. Sync works offline (queued, synced when online)
6. Conflict resolution: Last-write-wins
7. Sync status indicator in app (syncing/synced/offline)

**FRs:** FR98

**UX Notes:**
- Subtle sync indicator in navigation bar (cloud icon)
- "Offline mode" banner when no internet (reassuring, not alarming)
- No user action required for sync (automatic)

**Prerequisites:** Story 1.1, Story 1.2

**Technical Notes:**
- Supabase Realtime subscriptions for all user tables
- Local Drift database for offline-first (SQLite)
- Sync queue for offline writes

---

### Story 1.6: GDPR Compliance (Data Export & Deletion)

**Phase:** MVP

**As a** user concerned about data privacy
**I want** to export or delete my data
**So that** I comply with my rights under GDPR

**Acceptance Criteria:**

1. User can request data export from Profile → Data & Privacy
2. Export generates ZIP file (JSON + CSV formats)
3. Export includes: workouts, mood logs, goals, meditations, journal entries, account info
4. Export download link sent via email (expires in 7 days)
5. User can request account deletion (requires password confirmation)
6. Account deletion removes all data within 7 days (GDPR compliance)
7. Deletion is irreversible (clear warning shown)
8. Deleted data purged from backups after 30 days

**FRs:** FR100, FR101, FR102

**UX Notes:**
- Data & Privacy screen: Export button + Delete account button (red, bottom)
- Export: "Preparing your data..." loading state → Email sent confirmation
- Delete: Modal with password input + "I understand this is permanent" checkbox
- Delete confirmation: "Your account will be deleted in 7 days. You can cancel anytime."

**Prerequisites:** Story 1.1

**Technical Notes:**
- Supabase Edge Function for data export (generates ZIP)
- Supabase RLS policies for deletion (cascading deletes)
- Email notification for export + deletion

---

## Epic 2: Life Coach MVP

**Goal:** Deliver core Life Coach module - AI-powered daily planning, goal tracking, check-ins, and conversational AI coaching.

**Value:** Users can plan their day, track goals, complete morning/evening check-ins, and chat with AI for motivation and advice.

**FRs Covered:** FR6-FR29 (Life Coach module)

**Dependencies:** Epic 1 (requires authentication and data sync)

**Stories:** 10

---

### Story 2.1: Morning Check-in Flow

**Phase:** MVP

**As a** user starting my day
**I want** to complete a quick morning check-in
**So that** the AI can generate a personalized daily plan

**Acceptance Criteria:**

1. Morning check-in modal appears on first app open (if not done today)
2. User rates mood (1-5 emoji slider, default 3)
3. User rates energy (1-5 emoji slider, default 3)
4. User rates sleep quality (1-5 emoji slider, default 3)
5. Optional note field ("Anything on your mind?")
6. Haptic feedback on emoji selection
7. "Generate My Plan" CTA triggers AI daily plan generation
8. "Skip for today" option (text link, bottom)
9. Check-in saves to database (mood, energy, sleep, note, timestamp)
10. Accessibility: VoiceOver reads "Mood: Happy, 4 out of 5"

**FRs:** FR25, FR27

**UX Notes (from UX spec):**
- Modal card (swipe down to dismiss NOT allowed - must complete or skip)
- Emoji sliders: 😢 😞 😐 😊 😄 for mood
- Default mid-point (3/5) if user doesn't adjust
- Loading indicator during AI generation: "Generating your perfect day..." (animated sparkle)
- Target completion time: <60 seconds

**Prerequisites:** Epic 1 (auth, data sync)

**Technical Notes:**
- Drift local storage for offline check-ins
- Supabase sync when online
- AI daily plan API call (Llama for free tier, Claude/GPT-4 for premium)

---

### Story 2.2: AI Daily Plan Generation

**Phase:** MVP

**As a** user who completed morning check-in
**I want** the AI to generate a personalized daily plan
**So that** I know what to focus on today

**Acceptance Criteria:**

1. AI analyzes: mood, energy, sleep, stress (from Mind module if available), scheduled workouts (from Fitness)
2. AI generates daily plan with 5-8 tasks/suggestions
3. Plan includes: Morning meditation (if low energy), Focus work block, Gym workout (pre-filled from schedule), Lunch, Creative work, Evening meditation, Reflection
4. Plan considers user's goals (pulls active goals from DB)
5. Plan adapts to mood (high energy = more tasks, low energy = lighter day)
6. Insight shown: "Your sleep was good (4/5). Great foundation for a productive day!"
7. Plan saves to database (visible on Home tab)
8. Plan items can be marked as complete (checkboxes)
9. AI model based on subscription tier (Free: Llama, Standard: Claude, Premium: GPT-4)
10. Timeout handling: If AI fails, show fallback plan (generic template)

**FRs:** FR6, FR7, FR10

**UX Notes:**
- Daily plan shown as list on Home tab
- Checkboxes for each item (tap to complete)
- Completed items strike-through
- Insight card at top (purple/blue gradient)

**Prerequisites:** Story 2.1

**Technical Notes:**
- Supabase Edge Function for AI orchestration
- Prompt engineering for daily plan (include context: goals, mood, workouts)
- Fallback template if AI fails (avoid user frustration)

---

### Story 2.3: Goal Creation & Tracking

**Phase:** MVP

**As a** user with personal goals
**I want** to create and track up to 3 goals (free tier)
**So that** I can measure my progress toward what matters

**Acceptance Criteria:**

1. User can create goals from Home → Goals screen
2. Goal form: Title (max 60 chars), Category (Fitness, Mental Health, Career, Relationships, Learning, Finance), Target date (optional), Description (max 500 chars)
3. Free tier: Max 3 goals, Premium: Unlimited
4. Goal progress tracked manually (% completion slider, 0-100%)
5. User can mark goal as completed (celebration animation)
6. User can archive goal (removed from active list, kept in history)
7. User can delete goal (confirmation required)
8. Goals displayed on Home tab (active goals with progress bars)
9. AI daily plan references active goals ("Work on [Goal title]")

**FRs:** FR11-FR17

**UX Notes:**
- Goal card: Title, category icon, progress bar, target date
- "Add Goal" FAB (Floating Action Button) on Goals screen
- Goal detail screen: Edit, Archive, Delete buttons
- Completion animation: Confetti (Lottie) + "Goal achieved!" message

**Prerequisites:** Epic 1

**Technical Notes:**
- Goals table in Supabase (user_id, title, category, target_date, progress, status)
- RLS policies (user can only see their own goals)

---

### Story 2.4: AI Conversational Coaching

**Phase:** MVP

**As a** user needing motivation or advice
**I want** to chat with an AI life coach
**So that** I can get personalized guidance and support

**Acceptance Criteria:**

1. AI Chat accessible from Home tab → "Chat with AI" button
2. User can send text messages to AI
3. AI responds with motivational advice, problem-solving, or encouragement
4. AI has context: User's goals, mood (from check-ins), recent activity
5. AI personality based on onboarding choice (Sage: calm vs Momentum: energetic)
6. Free tier: 3-5 conversations/day (Llama model), Premium: Unlimited (Claude/GPT-4)
7. Conversation history saved and viewable
8. User can delete conversation history (GDPR)
9. AI response time: <2s (Llama), <3s (Claude), <4s (GPT-4)
10. Timeout handling: Clear error message after 10s, suggest retry

**FRs:** FR18-FR24

**UX Notes:**
- Chat interface: Message bubbles (user: Teal, AI: Gray)
- AI typing indicator (3 dots animation)
- "Powered by [Model]" footer (transparency)
- Free tier limit indicator: "2 conversations left today"

**Prerequisites:** Epic 1, Story 2.3 (goals for context)

**Technical Notes:**
- Supabase Edge Function for AI API calls
- Rate limiting per user tier (Supabase RLS + app logic)
- Conversation history stored in messages table

---

### Story 2.5: Evening Reflection Flow

**Phase:** MVP

**As a** user ending my day
**I want** to complete an evening reflection
**So that** I can review my accomplishments and prepare for tomorrow

**Acceptance Criteria:**

1. Evening reflection prompt appears at set time (default 8pm, user customizable)
2. User reviews daily plan completion (auto-filled checkboxes shown)
3. User adds accomplishments (text input, "What went well today?")
4. User notes tomorrow priorities (text input, "What's important tomorrow?")
5. Optional gratitude prompt ("3 good things today")
6. Reflection saves to database (completion %, accomplishments, tomorrow, gratitude, timestamp)
7. "Skip for today" option
8. Reflection data used by AI for next day's plan
9. Target completion time: <2 minutes

**FRs:** FR26, FR28

**UX Notes:**
- Modal card (similar style to morning check-in)
- Daily plan completion shown: "You completed 5 of 7 tasks today! 🎉"
- Text inputs: Multiline, placeholder text
- "Save Reflection" CTA (Teal button)

**Prerequisites:** Story 2.2 (daily plan must exist)

**Technical Notes:**
- Reflections table (user_id, date, completion_rate, accomplishments, tomorrow, gratitude)
- AI incorporates reflection data into next day's plan

---

### Story 2.6: Streak Tracking (Check-ins)

**Phase:** MVP

**As a** user building daily habits
**I want** to see my check-in streak
**So that** I'm motivated to maintain consistency

**Acceptance Criteria:**

1. Streak counter on Home tab ("7-day streak! 🔥")
2. Streak increments when both morning check-in AND evening reflection completed
3. Streak breaks if user misses both check-ins in a day
4. User can use 1 streak freeze per week (automatic on first miss)
5. Freeze availability shown ("Freeze available: 1 this week")
6. Milestone badges: Bronze (7 days), Silver (30 days), Gold (100 days)
7. Milestone celebration: Full-screen confetti + badge unlock
8. Streak data synced across devices
9. Push notification if streak about to break ("Complete your evening reflection to keep your 10-day streak!")

**FRs:** FR29, FR85-FR87

**UX Notes (from UX spec):**
- Streak card on Home tab
- Progress bar to next milestone
- Badge icons: 🥉 🥈 🥇
- Confetti animation on milestone (Lottie, 2s)

**Prerequisites:** Story 2.1, Story 2.5

**Technical Notes:**
- Streaks table (user_id, type='check-in', current_streak, longest_streak, freeze_used_this_week)
- Cron job to check streaks daily (Supabase Edge Function)

---

### Story 2.7: Progress Dashboard (Life Coach)

**Phase:** MVP

**As a** user tracking my life progress
**I want** to see charts and trends
**So that** I can understand my patterns and improvements

**Acceptance Criteria:**

1. Progress screen accessible from Home tab → "View Stats"
2. Mood trend chart (7-day, 30-day line graph)
3. Energy trend chart (7-day, 30-day)
4. Sleep quality trend chart (7-day, 30-day)
5. Goal completion rate (% of goals completed this month)
6. Check-in completion rate (% of days with both check-ins)
7. AI chat usage (conversations per week)
8. Charts interactive (tap data point to see details)
9. Export data option (CSV download)

**FRs:** FR27, FR29

**UX Notes:**
- Charts: Line graphs (Flutter fl_chart library)
- Color-coded: Mood (Purple), Energy (Orange), Sleep (Deep Blue)
- Date range selector (7d, 30d, 3m)

**Prerequisites:** Story 2.1, Story 2.5 (data must exist)

**Technical Notes:**
- Aggregate queries on check-ins table
- Caching for performance (materialize daily stats)

---

### Story 2.8: Daily Plan Manual Adjustment

**Phase:** MVP

**As a** user with a generated daily plan
**I want** to manually adjust or skip suggestions
**So that** I have flexibility when my day changes

**Acceptance Criteria:**

1. User can tap any plan item to edit
2. User can change task description
3. User can change task time
4. User can delete task (swipe left gesture)
5. User can add custom task to plan
6. User can reorder tasks (drag & drop)
7. Changes save immediately (optimistic UI)
8. AI learns from adjustments (future plans adapt)

**FRs:** FR9

**UX Notes:**
- Long-press task → Edit modal
- Swipe left → Delete button appears (red)
- Drag handle icon on right side of task
- "+ Add Task" button at bottom

**Prerequisites:** Story 2.2

**Technical Notes:**
- Daily plan stored as JSON array in plans table
- User edits flagged for AI learning

---

### Story 2.9: Goal Suggestions (AI)

**Phase:** MVP

**As a** user unsure what goals to set
**I want** the AI to suggest relevant goals
**So that** I can get started quickly

**Acceptance Criteria:**

1. "Suggest goals" button on Goals screen (when <3 goals)
2. AI analyzes: User's onboarding choice (fitness/stress/life), mood trends, activity patterns
3. AI suggests 3-5 relevant goals with rationale
4. Example suggestions: "Lose 5kg" (if fitness-focused), "Meditate 5 days/week" (if stress-focused)
5. User can tap suggestion to create goal (pre-filled form)
6. User can dismiss suggestion
7. Suggestions refresh daily

**FRs:** FR15

**UX Notes:**
- Suggestion cards: Goal title, category, AI rationale ("Based on your fitness focus...")
- "+ Create this goal" button on each card
- Dismiss (X icon, top right)

**Prerequisites:** Story 2.3

**Technical Notes:**
- AI prompt: Analyze user data → suggest personalized goals
- Suggestions cached for 24h

---

### Story 2.10: Weekly Summary Report (Life Coach)

**Phase:** MVP

**As a** user tracking my life progress
**I want** a weekly summary report
**So that** I can see concrete evidence of my improvements

**Acceptance Criteria:**

1. Weekly report generated every Monday morning
2. Push notification: "Your week in review is ready! 📊"
3. Report includes:
   - Check-ins completed (6/7 days)
   - Goals progressed (2 of 3 goals, 67%)
   - Daily plan completion (89% avg)
   - Mood avg (4.2/5, ↑ from 3.8 last week)
   - Energy avg (3.8/5)
   - Sleep avg (4.0/5)
   - Top insight ("Your best days had 8+ hours sleep")
4. Report shareable (generate image, share to social)
5. Report saved in history (view past weeks)

**FRs:** FR29, FR90

**UX Notes (from UX spec):**
- Report card on Home tab (Monday mornings)
- Stats with trend arrows (↑ ↓ →)
- "Share Report" button (optional)
- Archive: "View Past Weeks"

**Prerequisites:** Story 2.1, Story 2.5, Story 2.6

**Technical Notes:**
- Cron job every Monday 8am (Supabase Edge Function)
- Aggregate queries on past 7 days
- Push notification via Supabase

---

## Epic 3: Fitness Coach MVP

**Goal:** Deliver core Fitness Coach module with Smart Pattern Memory (killer feature), workout logging, progress tracking, and templates.

**Value:** Users can log workouts in <2 seconds per set, track progress with charts, and see personal records.

**FRs Covered:** FR30-FR46 (Fitness module)

**Dependencies:** Epic 1 (auth, data sync)

**Stories:** 10

---

### Story 3.1: Smart Pattern Memory - Pre-fill Last Workout

**Phase:** MVP

**As a** user logging a workout
**I want** the app to pre-fill my last sets/reps/weight
**So that** I can log workouts in <2 seconds per set

**Acceptance Criteria:**

1. User opens "Log Workout" modal
2. If exercise logged before, app pre-fills last session's data:
   - Exercise name
   - Sets (same count as last time)
   - Reps per set (same as last time)
   - Weight per set (same as last time)
3. If first time logging exercise, show empty form
4. User can swipe up/down on weight to increment/decrement (5kg/10lbs increments)
5. User can tap reps to edit (number picker modal)
6. User taps checkmark → Set logged (<2s target)
7. Haptic feedback on check (light tap)
8. Offline-first (works without internet)
9. Data synced when online

**FRs:** FR30, FR31

**UX Notes (from UX spec):**
- Large, clear numbers (Inter SemiBold font)
- Swipe gestures for weight (avoid keyboard)
- Checkmark bounce animation (delight)
- Target: <2s from "Log Workout" tap to set complete

**Prerequisites:** Epic 1

**Technical Notes:**
- Query last workout for this exercise (local Drift DB)
- Optimistic UI (save locally, sync later)
- Edge case: Changed exercise → clear pre-fill

---

### Story 3.2: Exercise Library (500+ Exercises)

**Phase:** MVP

**As a** user logging a variety of exercises
**I want** to search and select from a comprehensive exercise library
**So that** I can track all my workouts accurately

**Acceptance Criteria:**

1. Exercise library with 500+ exercises (seeded on first launch)
2. Exercises categorized: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
3. Search bar with real-time filtering (results <200ms)
4. Exercise details: Name, category, muscle groups, instructions (optional)
5. User can add custom exercises (name, category)
6. Custom exercises saved to user's library
7. Favorite exercises (star icon) → Quick access list
8. Exercise instructions: Text description (P1: form videos)

**FRs:** FR32, FR33

**UX Notes:**
- Search bar at top (filter as you type)
- Exercise cards: Name, category icon, favorite star
- "+ Add Custom Exercise" button
- Favorites section at top

**Prerequisites:** Epic 1

**Technical Notes:**
- Exercises table (global, read-only)
- User_exercises table (custom exercises, user_id FK)
- Favorites table (user_id, exercise_id)

---

### Story 3.3: Workout Logging with Rest Timer

**Phase:** MVP

**As a** user during a workout
**I want** to log sets with automatic rest timer
**So that** I can track my workout and rest appropriately

**Acceptance Criteria:**

1. User logs set → Rest timer auto-starts (default 90s, customizable)
2. Timer shown as countdown (large, readable)
3. Haptic + sound notification when rest complete
4. User can skip rest (tap "Next Set")
5. User can adjust rest time mid-workout (tap timer)
6. Workout duration tracked automatically (start to finish)
7. User can add notes to workout ("Felt strong today")
8. User can add notes to individual sets ("Failed last rep")
9. Workout saves when user taps "Complete Workout"

**FRs:** FR34, FR35, FR36

**UX Notes:**
- Rest timer: Circular progress (shrinking)
- Skip rest: "Next Set" button
- Notes: Text field, expand on tap
- "Complete Workout" CTA (Orange button)

**Prerequisites:** Story 3.1, Story 3.2

**Technical Notes:**
- Workout session stored in workouts table (start_time, end_time, duration, notes)
- Sets stored in workout_sets table (workout_id FK, exercise_id, set_number, reps, weight, notes)

---

### Story 3.4: Workout History & Detail View

**Phase:** MVP

**As a** user who wants to review past workouts
**I want** to see my workout history
**So that** I can track my consistency and progress

**Acceptance Criteria:**

1. Workout history screen (accessible from Fitness tab)
2. Workouts sorted by date (most recent first)
3. Workout cards show: Date, duration, exercises count, total volume (kg lifted)
4. Tap workout → Detail view (all sets, reps, weight)
5. Detail view: Edit button (can modify past workouts)
6. Detail view: Delete button (confirmation required)
7. Filter by date range (7d, 30d, 3m, 1y, All)
8. Search by exercise name

**FRs:** FR37, FR40

**UX Notes:**
- Calendar icon + date on cards
- Volume shown prominently (e.g., "12,500 kg")
- Edit: Inline editing mode
- Delete: Red button, bottom

**Prerequisites:** Story 3.3

**Technical Notes:**
- Workouts table query with pagination (20 per page)
- JOIN with workout_sets for details
- Soft delete (is_deleted flag)

---

### Story 3.5: Progress Charts (Strength, Volume, PRs)

**Phase:** MVP

**As a** user tracking strength progress
**I want** to see charts of my improvements
**So that** I can visualize my gains and stay motivated

**Acceptance Criteria:**

1. Progress screen (Fitness tab → "Progress")
2. Weight lifted chart per exercise (line graph, 30-day)
3. Total volume chart (bar graph, weekly totals)
4. Personal records (PRs) list (heaviest weight per exercise)
5. PR celebrations when new PR achieved (confetti + badge)
6. Chart filtering: Select exercise, date range
7. Export data button (CSV download)

**FRs:** FR38, FR41

**UX Notes:**
- Charts: fl_chart library (Flutter)
- PR list: Exercise name, weight, date
- PR badge: Gold star icon
- Confetti animation on new PR

**Prerequisites:** Story 3.3, Story 3.4

**Technical Notes:**
- Aggregate queries on workout_sets
- Materialized view for PRs (performance)
- PR detection: Compare new set to max(weight) for exercise

---

### Story 3.6: Body Measurements Tracking

**Phase:** MVP

**As a** user tracking body composition
**I want** to log body measurements
**So that** I can see non-scale victories

**Acceptance Criteria:**

1. Body measurements screen (Fitness tab → "Measurements")
2. Log: Weight, body fat %, chest, waist, hips, arms, legs
3. Measurements saved with timestamp
4. Trend charts (line graphs, 30-day, 90-day)
5. Goal weight setting (optional)
6. Progress to goal shown (e.g., "3kg to go!")
7. Units: kg/lbs, cm/inches (user preference)

**FRs:** FR39

**UX Notes:**
- Measurement form: Number inputs, unit selector
- Charts color-coded (Deep Blue for weight, Orange for body fat %)
- "+ Log Measurement" FAB

**Prerequisites:** Epic 1

**Technical Notes:**
- body_measurements table (user_id, date, weight, body_fat_pct, chest, waist, hips, arms, legs, unit)
- Unit conversion logic (kg ↔ lbs, cm ↔ inches)

---

### Story 3.7: Workout Templates (Pre-built + Custom)

**Phase:** MVP

**As a** user following a training program
**I want** to use pre-built or custom workout templates
**So that** I don't have to plan every workout from scratch

**Acceptance Criteria:**

1. Templates screen (Fitness tab → "Templates")
2. 20+ pre-built templates: Push/Pull/Legs, Upper/Lower, Full Body, etc.
3. Template shows: Name, exercises, sets/reps scheme
4. User can start workout from template (exercises pre-loaded)
5. User can create custom templates (name + exercise list)
6. User can edit custom templates
7. User can delete custom templates
8. Favorite templates (star icon) → Quick access

**FRs:** FR43, FR44

**UX Notes:**
- Template cards: Name, exercise count, preview
- "Start Workout" button on each template
- "+ Create Template" FAB
- Template editor: Drag & drop exercises, set reps/sets

**Prerequisites:** Story 3.2, Story 3.3

**Technical Notes:**
- workout_templates table (global templates, read-only)
- user_workout_templates table (custom templates, user_id FK)
- template_exercises junction table (template_id, exercise_id, order, sets, reps)

---

### Story 3.8: Quick Log (Rapid Workout Entry)

**Phase:** MVP

**As a** user who wants ultra-fast logging
**I want** a quick log mode
**So that** I can log entire workout in <30 seconds

**Acceptance Criteria:**

1. "Quick Log" button on Fitness home
2. Quick log modal: List of recent exercises
3. Tap exercise → Pre-fill last workout → Tap check → Done
4. No rest timer (ultra-fast mode)
5. Add new exercise: Search → Select → Log
6. Quick log saves as regular workout (visible in history)
7. Duration auto-calculated based on log timestamps

**FRs:** FR30, FR31

**UX Notes:**
- Minimal UI (no fluff, speed-focused)
- Large tap targets
- "Recent Exercises" list (5 most recent)

**Prerequisites:** Story 3.1, Story 3.3

**Technical Notes:**
- Same workout/workout_sets tables
- UX shortcut (no intermediate screens)

---

### Story 3.9: Exercise Instructions & Form Tips

**Phase:** MVP

**As a** beginner lifter
**I want** to see exercise instructions
**So that** I can perform exercises with proper form

**Acceptance Criteria:**

1. Exercise detail screen (tap exercise in library)
2. Instructions: Text description (300-500 words)
3. Muscle groups highlighted (visual diagram, P1)
4. Form tips: Bullet points (3-5 key tips)
5. Common mistakes to avoid (bullet points)
6. Video tutorial link (P1: embedded video player)
7. "Start Workout with This Exercise" CTA

**FRs:** FR46 (P1 feature, basic MVP)

**UX Notes:**
- Exercise detail screen (full-screen)
- Scrollable content
- Clear typography (Inter Regular, 16pt)

**Prerequisites:** Story 3.2

**Technical Notes:**
- exercises table: instructions, form_tips, mistakes, video_url columns
- Seed data with instructions (500+ exercises)

---

### Story 3.10: Cross-Module: Receive Stress Data from Mind

**Phase:** MVP

**As a** user with high stress
**I want** Fitness module to adjust workout intensity
**So that** I don't overtrain when stressed

**Acceptance Criteria:**

1. Fitness module queries Mind module for today's stress level (1-5)
2. If stress ≥4 (high), show workout adjustment suggestion
3. Suggestion: "High stress detected. Consider light session or rest day."
4. User can accept suggestion (loads light template) or dismiss
5. Suggestion shown as insight card (Mind purple → Fitness orange gradient)
6. Logged in workout notes: "Adjusted for high stress"

**FRs:** FR77, FR79, FR81 (Cross-Module Intelligence)

**UX Notes (from UX spec):**
- Insight card on Fitness home (if applicable)
- Swipeable (dismiss or accept)
- Clear CTA: "Load Light Session"

**Prerequisites:** Epic 1, Epic 4 (Mind module with stress tracking)

**Technical Notes:**
- Query stress_logs table (today's entry)
- Cross-module API (Supabase RPC or direct table query)
- Light template predefined (bodyweight, stretching)

---

## Epic 4: Mind & Emotion MVP

**Goal:** Deliver core Mind & Emotion module with guided meditations, mood tracking, CBT chat, breathing exercises, and mental health screening.

**Value:** Users can meditate, track mood/stress, journal privately, and access mental health resources.

**FRs Covered:** FR47-FR76 (Mind module)

**Dependencies:** Epic 1 (auth, data sync)

**Stories:** 12

---

### Story 4.1: Guided Meditation Library (20-30 MVP)

**Phase:** MVP

**As a** user wanting to meditate
**I want** to access guided meditations
**So that** I can reduce stress and improve focus

**Acceptance Criteria:**

1. Meditation library with 20-30 meditations (MVP)
2. Meditations categorized: Stress Relief, Sleep, Focus, Anxiety, Gratitude
3. Lengths: 5, 10, 15, 20 minutes
4. Free tier: 3 rotating meditations (changes weekly)
5. Premium tier: Full library access
6. Audio files cached for offline playback
7. Meditation player: Play/pause, scrubber, skip ±15s
8. Completion tracked (meditation_id, duration, completed)

**FRs:** FR47, FR48, FR49, FR50, FR51

**UX Notes (from UX spec):**
- Meditation cards: Title, duration, theme, narrator
- "Continue" button for last played meditation
- Player: Full-screen, calming purple/blue gradient background
- Breathing circle animation (expands/contracts with cues)

**Prerequisites:** Epic 1

**Technical Notes:**
- meditations table (id, title, category, duration, audio_url, is_premium)
- meditation_completions table (user_id, meditation_id, completed_at, duration_seconds)
- Audio storage: Supabase Storage (MP3, cached locally after first play)

---

### Story 4.2: Meditation Player with Breathing Animation

**Phase:** MVP

**As a** user during meditation
**I want** a calming player with visual breathing guide
**So that** I can stay focused and relaxed

**Acceptance Criteria:**

1. Full-screen meditation player (purple → deep blue gradient)
2. Breathing circle: Expands on "breathe in", contracts on "breathe out"
3. Live transcript (optional): "Breathe in... Feel the air..." (subtitles)
4. Play/pause button (large, center)
5. Scrubber (seek to any point)
6. Skip buttons: -15s, +15s
7. Auto-lock prevention (screen stays on during meditation)
8. Haptic pulse during "breathe in" cues (gentle)
9. Completion: Checkmark + "Meditation complete! 🧘" message
10. Track meditation time toward daily goal

**FRs:** FR51, FR52

**UX Notes:**
- Breathing circle: Smooth CSS/Lottie animation (4s in, 4s out)
- Minimal UI (hide controls after 3s inactivity)
- Exit button (X, top right) → Confirmation modal

**Prerequisites:** Story 4.1

**Technical Notes:**
- Audio player: just_audio package (Flutter)
- Breathing animation: Lottie or custom Flutter animation
- Prevent screen lock: wakelock package

---

### Story 4.3: Mood & Stress Tracking (Always FREE)

**Phase:** MVP

**As a** user monitoring mental health
**I want** to track my daily mood and stress
**So that** I can identify patterns and triggers

**Acceptance Criteria:**

1. Mood tracking accessible from Mind tab (Quick Action button)
2. Mood log modal: Emoji slider (1-5: 😢 😞 😐 😊 😄)
3. Stress log modal: Emoji slider (1-5: 😌 😐 😰 😫 😱)
4. Optional note: "What's causing this?" (text input)
5. Logs save with timestamp (multiple per day allowed)
6. Mood/stress ALWAYS FREE (even for free tier users)
7. Mood trends chart (7-day, 30-day line graph)
8. Stress trends chart (7-day, 30-day line graph)
9. Data shared with Life Coach and Fitness modules (cross-module)

**FRs:** FR55, FR56, FR57, FR58, FR59

**UX Notes:**
- Quick log: Tap emoji → Saved (optional note can be added after)
- Charts: Line graphs (Purple for mood, Orange for stress)
- Insight shown: "Your stress is 30% lower this week!"

**Prerequisites:** Epic 1

**Technical Notes:**
- mood_logs table (user_id, timestamp, mood_score, note)
- stress_logs table (user_id, timestamp, stress_score, note)
- Always accessible (no subscription check)

---

### Story 4.4: CBT Chat with AI (1/day free, unlimited premium)

**Phase:** MVP

**As a** user experiencing negative thoughts
**I want** to chat with a CBT-trained AI
**So that** I can reframe my thinking and feel better

**Acceptance Criteria:**

1. CBT Chat accessible from Mind tab
2. AI uses CBT techniques: Identify cognitive distortions, challenge beliefs, reframe thoughts
3. Free tier: 1 conversation per day (Llama model)
4. Premium tier: Unlimited conversations (Claude or GPT-4)
5. AI has empathetic, warm tone (not clinical)
6. Conversation history saved (GDPR: user can delete)
7. AI response time: <2s (Llama), <3s (Claude/GPT-4)
8. Timeout handling: Clear error, suggest retry

**FRs:** FR61, FR63

**UX Notes:**
- Chat interface: Similar to Life Coach AI chat
- AI personality: Empathetic, validating ("That sounds really hard...")
- CBT framework visible: "Let's explore that thought together..."

**Prerequisites:** Epic 1

**Technical Notes:**
- cbt_conversations table (user_id, message_id, role, content, timestamp)
- AI prompt: CBT-trained system prompt
- Rate limiting: Free tier = 1/day, Premium = unlimited

---

### Story 4.5: Private Journaling (E2E Encrypted)

**Phase:** MVP

**As a** user wanting to journal privately
**I want** end-to-end encryption for my entries
**So that** no one (not even LifeOS) can read my thoughts

**Acceptance Criteria:**

1. Journal accessible from Mind tab
2. User can write journal entries (rich text editor)
3. Entries encrypted client-side (E2E encryption)
4. Decryption key stored locally (device-specific)
5. Entries synced as encrypted blobs (Supabase cannot decrypt)
6. AI sentiment analysis opt-in only (user must enable in settings)
7. If AI analysis enabled: Sentiment shown (Positive, Neutral, Negative)
8. User can view journal history (sorted by date)
9. User can export journal (PDF, encrypted ZIP)

**FRs:** FR62, FR63, FR64, FR65

**UX Notes:**
- Journal entry screen: Clean, distraction-free editor
- Placeholder: "What's on your mind?"
- Date + time stamp on each entry
- "AI Insights" toggle (settings)

**Prerequisites:** Epic 1

**Technical Notes:**
- journal_entries table (user_id, timestamp, encrypted_content, iv, salt)
- Encryption: AES-256 (encrypt_dart package)
- AI sentiment: Only if user opts in, send decrypted content to AI

---

### Story 4.6: Mental Health Screening (GAD-7, PHQ-9)

**Phase:** MVP

**As a** user concerned about mental health
**I want** to complete anxiety and depression screenings
**So that** I can assess my symptoms and seek help if needed

**Acceptance Criteria:**

1. Screening accessible from Mind tab → "Mental Health Check"
2. GAD-7 (anxiety): 7 questions, scored 0-21
3. PHQ-9 (depression): 9 questions, scored 0-27
4. Questions presented one at a time (not overwhelming)
5. Score calculated and categorized: Minimal, Mild, Moderate, Moderately Severe, Severe
6. If score high (GAD-7 >15, PHQ-9 >20): Show crisis resources
7. Crisis resources: Suicide hotlines (UK: 116 123, Poland: 116 123)
8. Recommendation: "Consider speaking to a professional"
9. Screening history saved (track trends over time)
10. Disclaimer: "This is not a diagnosis. Consult a healthcare professional."

**FRs:** FR66, FR67, FR68, FR69, FR70

**UX Notes:**
- Screening UI: One question per screen (swipe to next)
- Progress bar (7/7 or 9/9)
- Results screen: Score + category + resources (if needed)
- Calming colors (purple, not alarming red)

**Prerequisites:** Epic 1

**Technical Notes:**
- screenings table (user_id, type='GAD-7'|'PHQ-9', score, category, timestamp)
- Scoring logic: Sum responses, categorize based on thresholds
- Crisis resources: Hardcoded links (hotlines, websites)

---

### Story 4.7: Breathing Exercises (5 Techniques)

**Phase:** MVP

**As a** user needing quick stress relief
**I want** guided breathing exercises
**So that** I can calm down in 2-5 minutes

**Acceptance Criteria:**

1. Breathing exercises accessible from Mind tab (Quick Action)
2. 5 techniques: Box Breathing (4-4-4-4), 4-7-8 (sleep), Calm Breathing (5-5), Energizing (quick inhale, slow exhale), Sleep Prep (long exhale)
3. Breathing guide: Visual circle (expands/contracts with rhythm)
4. Haptic feedback on inhale/exhale cues
5. Duration: User selects (2, 5, 10 minutes)
6. Completion tracked (breathing_id, duration, completed_at)
7. No audio required (visual + haptic only)

**FRs:** FR71, FR72

**UX Notes:**
- Technique selector: Cards with name + description
- Breathing guide: Full-screen, calming purple background
- Rhythm indicators: "Inhale... Hold... Exhale... Hold..."
- Exit button (X, top right)

**Prerequisites:** Epic 1

**Technical Notes:**
- breathing_exercises table (id, name, pattern, description)
- breathing_completions table (user_id, exercise_id, duration, completed_at)
- Haptic patterns: Light pulse on inhale, double pulse on exhale

---

### Story 4.8: Sleep Meditations & Ambient Sounds

**Phase:** MVP

**As a** user struggling to fall asleep
**I want** sleep meditations and ambient sounds
**So that** I can relax and sleep better

**Acceptance Criteria:**

1. Sleep meditations: 10-30 minute guided sleep stories
2. Ambient sounds: Rain, Ocean, Forest, White Noise, Campfire
3. Sleep timer: Auto-stop after duration (10, 20, 30, 60 minutes, or Until finished)
4. Audio fades out smoothly (30-second fade)
5. Screen dims during playback (low brightness mode)
6. Completion tracked (if user falls asleep, track start time)
7. Premium feature (Free tier: 3 sleep meditations)

**FRs:** FR73, FR74, FR75

**UX Notes:**
- Sleep section in Mind tab
- Dark mode UI (automatic for sleep content)
- Timer selector: Large buttons (10, 20, 30, 60 min)
- Fade-out preview: "Audio will fade out in last 30 seconds"

**Prerequisites:** Story 4.1

**Technical Notes:**
- sleep_meditations table (similar to meditations)
- ambient_sounds table (id, name, audio_url, loop=true)
- Sleep timer: just_audio player with fade effect

---

### Story 4.9: Gratitude Exercises ("3 Good Things")

**Phase:** MVP

**As a** user cultivating gratitude
**I want** to log 3 good things daily
**So that** I can improve my mental wellbeing

**Acceptance Criteria:**

1. Gratitude exercise accessible from Mind tab
2. Daily prompt: "What are 3 good things from today?"
3. User enters 3 items (text inputs, short)
4. Entries saved with timestamp
5. Gratitude history viewable (past entries)
6. Streak tracking (consecutive days with gratitude log)
7. Incorporated into Evening Reflection (Life Coach module)

**FRs:** FR76

**UX Notes:**
- Simple form: 3 text inputs (placeholders: "1. ", "2. ", "3. ")
- "Save Gratitude" CTA (Purple button)
- History: List of past days with entries (tap to expand)

**Prerequisites:** Epic 1

**Technical Notes:**
- gratitude_logs table (user_id, date, item_1, item_2, item_3, timestamp)
- Integration with Evening Reflection (Story 2.5)

---

### Story 4.10: Meditation Recommendations (AI)

**Phase:** MVP

**As a** user unsure which meditation to choose
**I want** personalized recommendations
**So that** I can start meditating quickly

**Acceptance Criteria:**

1. "Today's Meditation" card on Mind home (AI-recommended)
2. AI considers: Mood (from mood log), stress level, time of day, past preferences
3. Example: High stress + morning → "Stress Relief (10 min)"
4. Example: Low energy + evening → "Sleep Meditation (20 min)"
5. User can tap "Start" → Meditation player opens
6. User can dismiss → Browse library instead
7. Recommendations refresh daily

**FRs:** FR54

**UX Notes:**
- Hero card on Mind home (large, prominent)
- AI rationale shown: "Based on your high stress level..."
- "Start Now" CTA (Purple button)

**Prerequisites:** Story 4.1, Story 4.3

**Technical Notes:**
- AI prompt: Analyze mood/stress → recommend meditation
- Recommendation cached for 24h

---

### Story 4.11: Mood & Workout Correlation Insights

**Phase:** MVP

**As a** user tracking mood and workouts
**I want** to see correlations between them
**So that** I can understand how exercise affects my mental health

**Acceptance Criteria:**

1. Insights screen (Mind tab → "Insights")
2. Correlation analysis: Mood vs Workout frequency
3. Insight examples:
   - "Your mood is 20% higher on workout days"
   - "After leg day, your mood drops (soreness?)"
   - "7-day workout streaks correlate with better sleep"
4. Insights shown as cards (swipeable)
5. Data visualization: Scatter plot or bar chart
6. Minimum 14 days of data required for insights

**FRs:** FR60 (correlations)

**UX Notes:**
- Insight cards: Gradient (Mind purple → Fitness orange)
- Clear data visualization (easy to understand)
- "Learn more" expands card with detailed chart

**Prerequisites:** Story 4.3, Epic 3 (Fitness data must exist)

**Technical Notes:**
- Aggregate query: JOIN mood_logs + workouts by date
- Statistical correlation (Pearson coefficient)
- Insights generated weekly (cron job)

---

### Story 4.12: Cross-Module: Share Mood/Stress with Life Coach & Fitness

**Phase:** MVP

**As a** user logging mood/stress
**I want** other modules to use this data
**So that** I get personalized recommendations across the app

**Acceptance Criteria:**

1. Mood/stress data queryable by Life Coach module
2. Life Coach daily plan considers mood:
   - Low mood → Suggest gratitude exercise, light day
   - High mood → Suggest challenging tasks
3. Life Coach daily plan considers stress:
   - High stress → Suggest meditation, rest
   - Low stress → Normal workload
4. Fitness module queries stress (Epic 3, Story 3.10)
5. Data sharing opt-in (user can disable in Privacy settings)

**FRs:** FR59, FR77, FR81 (Cross-Module Intelligence)

**UX Notes:**
- Privacy setting: "Allow modules to share data" (default ON)
- If disabled, show warning: "Some personalization features won't work"

**Prerequisites:** Story 4.3, Epic 2 (Life Coach), Epic 3 (Fitness)

**Technical Notes:**
- Cross-module API: Direct table queries (same Supabase database)
- Privacy flag: user_settings table (share_data_across_modules BOOLEAN)

---

## Epic 5: Cross-Module Intelligence (Killer Feature)

**Goal:** Implement cross-module intelligence where modules communicate to provide holistic optimization and insights.

**Value:** Users get personalized insights that no competitor offers ("High stress + heavy workout → suggest light session").

**FRs Covered:** FR77-FR84 (Cross-Module Intelligence)

**Dependencies:** Epic 2 (Life Coach), Epic 3 (Fitness), Epic 4 (Mind)

**Stories:** 5

---

### Story 5.1: Insight Engine - Detect Patterns & Generate Insights

**Phase:** MVP

**As the system**
**I want** to detect patterns across modules
**So that** I can generate actionable cross-module insights

**Acceptance Criteria:**

1. Insight engine runs daily (cron job, 6am)
2. Analyzes data from all 3 modules:
   - Mood/stress (Mind)
   - Workout volume/frequency (Fitness)
   - Sleep quality/energy (Life Coach)
3. Detects patterns:
   - High stress + heavy workout scheduled
   - Poor sleep + morning workout planned
   - High workout volume + elevated stress
   - Meditation streak + improving mood
   - 8+ hours sleep → better workout performance
4. Generates 1 high-priority insight per day (max)
5. Insight stored in insights table (type, title, description, action_cta)
6. Push notification sent if insight is critical (e.g., overtraining risk)

**FRs:** FR77-FR81

**Technical Notes:**
- Supabase Edge Function (cron job, daily 6am)
- Pattern detection logic (if-then rules + basic ML later)
- insights table (user_id, type, title, description, cta, priority, created_at, dismissed)

---

### Story 5.2: Insight Card UI (Swipeable, Actionable)

**Phase:** MVP

**As a** user receiving an insight
**I want** to see it prominently and take action
**So that** I can benefit from cross-module intelligence

**Acceptance Criteria:**

1. Insight card appears on Home tab (top of feed)
2. Card design: Gradient background (Module A color → Module B color)
3. Module icons shown (e.g., 🏋️ Fitness + 🧠 Mind)
4. Insight title + description (clear, concise)
5. Recommendation + CTA (e.g., "Switch to light workout" button)
6. Swipe left → Dismiss insight
7. Swipe right → Save for later
8. Tap CTA → Opens relevant module with pre-filled action
9. Max 1 insight per day (prevents notification fatigue)
10. User can view dismissed insights in history

**FRs:** FR82, FR83

**UX Notes (from UX spec):**
- Card gradient: Fitness Orange → Mind Purple (example)
- Light bulb icon (💡) in header
- Swipeable gestures (like Tinder)
- CTA button: Teal (primary action)

**Prerequisites:** Story 5.1

**Technical Notes:**
- Insight card component (Flutter)
- Swipe detection: Dismissible widget
- CTA deep link: Navigate to Fitness with pre-loaded template

---

### Story 5.3: High Stress + Heavy Workout → Suggest Light Session

**Phase:** MVP

**As a** user with high stress and a heavy workout scheduled
**I want** the app to suggest a lighter session
**So that** I don't overtrain and worsen my stress

**Acceptance Criteria:**

1. Insight triggered when: Stress ≥4 (high) AND heavy workout scheduled (volume >80% of max)
2. Insight title: "High Stress Alert"
3. Description: "Your stress level is high today (4/5) and you have a heavy leg day scheduled."
4. Recommendation: "Switch to upper body (light) OR take a rest day + meditate"
5. CTA options:
   - "Adjust Workout" → Opens Fitness with light template pre-loaded
   - "Meditate Instead" → Opens Mind with stress relief meditation
6. User can dismiss insight
7. If dismissed, AI learns (future insights consider user preference)

**FRs:** FR77

**UX Notes:**
- Warning tone (not alarming, supportive)
- "We've got your back" vibe
- Icons: ⚠️ (stress) + 🏋️ (workout)

**Prerequisites:** Story 5.1, Story 5.2, Epic 3 (Fitness), Epic 4 (Mind stress tracking)

**Technical Notes:**
- Pattern: Query stress_logs (today, stress >=4) AND workouts (scheduled, volume >80%)
- Light template: Predefined (bodyweight, stretching, yoga)

---

### Story 5.4: Poor Sleep + Morning Workout → Suggest Afternoon

**Phase:** MVP

**As a** user with poor sleep and a morning workout planned
**I want** the app to suggest moving it to afternoon
**So that** I can train when better rested

**Acceptance Criteria:**

1. Insight triggered when: Sleep quality <3 (poor) AND morning workout scheduled (<12pm)
2. Insight title: "Sleep Alert"
3. Description: "You slept poorly last night (2/5). Your morning workout might be tough."
4. Recommendation: "Move workout to afternoon (4-6pm) when energy rebounds"
5. CTA: "Reschedule Workout" → Opens Life Coach daily plan editor
6. Alternative CTA: "Keep Morning Slot" (user preference)
7. AI learns from user choice (future insights adapt)

**FRs:** FR78

**UX Notes:**
- Supportive tone: "Your body needs rest"
- Icon: 😴 (sleep) + 🏋️ (workout)

**Prerequisites:** Story 5.1, Story 5.2, Epic 2 (Life Coach check-ins), Epic 3 (Fitness)

**Technical Notes:**
- Pattern: Query check-ins (today, sleep <3) AND daily_plan (workout time <12pm)
- Reschedule action: Update daily_plan (move workout time to 16:00)

---

### Story 5.5: Sleep Quality + Workout Performance Correlation

**Phase:** MVP

**As a** user tracking sleep and workouts
**I want** to see how sleep affects my performance
**So that** I can prioritize sleep for better gains

**Acceptance Criteria:**

1. Insight triggered when: 30+ days of data available (sleep + workouts)
2. Correlation analysis: Sleep quality vs Weight lifted (PRs)
3. Insight examples:
   - "Your best lifts happen after 8+ hours sleep"
   - "When you sleep <6 hours, strength drops 15%"
   - "7-day good sleep streak → 10% higher workout volume"
4. Recommendation: "Tonight's goal: Sleep meditation + 8 hours rest"
5. CTA: "Start Sleep Meditation" → Opens Mind with sleep meditation
6. Data visualization: Scatter plot (sleep vs performance)

**FRs:** FR80

**UX Notes:**
- Insight card: Deep Blue (Life Coach) → Orange (Fitness)
- Chart embedded in card (tap to expand)
- Motivational tone: "Sleep is your secret weapon!"

**Prerequisites:** Story 5.1, Story 5.2, Epic 2, Epic 3, Epic 4 (30+ days data)

**Technical Notes:**
- Statistical analysis: Pearson correlation (sleep vs max_weight)
- Minimum 30 data points required
- Insight generated monthly (not daily)

---

## Epic 6: Gamification & Retention

**Goal:** Implement gamification mechanics (streaks, badges, celebrations) and weekly summary reports to drive retention.

**Value:** Users stay engaged through visible progress, milestone celebrations, and concrete evidence of improvement.

**FRs Covered:** FR85-FR90 (Gamification & Retention)

**Dependencies:** Epic 2, Epic 3, Epic 4 (modules must exist to track streaks)

**Stories:** 6

---

### Story 6.1: Streak Tracking System (Workouts, Meditations, Check-ins)

**Phase:** MVP

**As a** user building habits
**I want** to see my streaks for workouts, meditations, and check-ins
**So that** I'm motivated to maintain consistency

**Acceptance Criteria:**

1. 3 streak types: Workout streak, Meditation streak, Check-in streak
2. Streak increments when user completes activity (daily)
3. Streak breaks if user misses a day (no activity)
4. Streak freeze: 1 per week per streak type (automatic on first miss)
5. Freeze availability shown: "Freeze available: 1 this week"
6. Streak resets on Sunday (new week, new freeze)
7. Longest streak saved (personal record)
8. Current streak shown on Home tab (🔥 emoji)

**FRs:** FR85, FR86, FR87

**UX Notes:**
- Streak card on Home tab
- Fire emoji 🔥 + number (e.g., "7-day streak!")
- Progress bar to next milestone (Bronze 7d, Silver 30d, Gold 100d)

**Prerequisites:** Epic 2, Epic 3, Epic 4

**Technical Notes:**
- streaks table (user_id, type, current_streak, longest_streak, freeze_used_this_week, last_activity_date)
- Cron job daily (checks if streak should increment or break)

---

### Story 6.2: Milestone Badges (Bronze, Silver, Gold)

**Phase:** MVP

**As a** user reaching a streak milestone
**I want** to earn badges
**So that** I feel recognized for my commitment

**Acceptance Criteria:**

1. Milestone badges: Bronze (7 days), Silver (30 days), Gold (100 days)
2. Badges awarded for each streak type (9 total badges possible)
3. Badge unlock: Full-screen celebration (confetti animation)
4. Badge shown in profile: "Badges Earned" section
5. Badge icons: 🥉 🥈 🥇
6. Shareable badge card (generate image, share to social media)
7. Push notification on badge unlock: "🎉 Silver Meditation Badge earned!"

**FRs:** FR86, FR88

**UX Notes (from UX spec):**
- Confetti animation: Lottie, 2 seconds
- Badge unlock screen: Full-screen modal, badge zooms in
- "Share Achievement" button (optional)

**Prerequisites:** Story 6.1

**Technical Notes:**
- badges table (user_id, type, tier='bronze'|'silver'|'gold', earned_at)
- Badge detection: Check current_streak against milestones
- Confetti: Lottie animation file

---

### Story 6.3: Streak Break Alerts (Push Notification)

**Phase:** MVP

**As a** user about to break a streak
**I want** a reminder notification
**So that** I don't lose my progress

**Acceptance Criteria:**

1. Push notification sent if streak about to break (8pm, if activity not done today)
2. Notification message: "🔥 Streak Alert! Your 15-day meditation streak is about to break. Meditate now!"
3. Tap notification → Opens relevant module (Meditation player, Workout log, Check-in modal)
4. Notification NOT sent if freeze available (automatic freeze used instead)
5. User can disable streak alerts in settings

**FRs:** FR87, FR106

**UX Notes:**
- Notification tone: Encouraging, not guilt-tripping
- Deep link to quick action (1-tap to complete)

**Prerequisites:** Story 6.1

**Technical Notes:**
- Cron job 8pm daily (check streaks, send notifications)
- Deep link: Open app to specific screen
- Notification service: Supabase + Firebase Cloud Messaging

---

### Story 6.4: Celebration Animations (Confetti, Badge Pop)

**Phase:** MVP

**As a** user achieving a milestone
**I want** a celebration animation
**So that** I feel rewarded and motivated

**Acceptance Criteria:**

1. Confetti animation on: Badge unlock, PR achievement, Goal completion
2. Animation: Lottie confetti (colorful, 2 seconds)
3. Badge pop: Badge icon zooms in with bounce effect
4. Haptic feedback: Medium vibration during celebration
5. Sound effect: Optional chime (can disable in settings)
6. Celebration doesn't block user (can dismiss early)

**FRs:** FR88

**UX Notes:**
- Confetti colors: Match module theme (Orange for Fitness, Purple for Mind)
- Badge bounce: Elastic easing (playful, not jarring)

**Prerequisites:** Story 6.2

**Technical Notes:**
- Lottie animations (confetti.json)
- Flutter animations: ScaleTransition for badge pop
- Haptic: HapticFeedback.mediumImpact()

---

### Story 6.5: Shareable Milestone Cards (Social Sharing)

**Phase:** MVP

**As a** user earning a badge or achieving a goal
**I want** to share my achievement
**So that** I can celebrate with friends

**Acceptance Criteria:**

1. "Share Achievement" button on badge unlock screen
2. Generate shareable image card:
   - Badge icon (centered)
   - Achievement title ("30-Day Meditation Streak!")
   - User name (optional, can remove)
   - "Achieved with LifeOS" branding (bottom)
3. Share to: Instagram Stories, Facebook, Twitter, WhatsApp, Copy link
4. Image saved to user's gallery (optional)
5. No personal data in image (GDPR compliant)

**FRs:** FR89

**UX Notes:**
- Card design: LifeOS branding (Deep Blue background, Teal accents)
- Badge prominent (large, centered)
- Clean typography (Inter Bold)

**Prerequisites:** Story 6.2

**Technical Notes:**
- Image generation: screenshot package (Flutter) or server-side image generation
- Share: share_plus package (Flutter)
- Image stored temporarily (deleted after 24h)

---

### Story 6.6: Weekly Summary Report (All Modules)

**Phase:** MVP

**As a** user tracking progress across all modules
**I want** a weekly summary report
**So that** I can see concrete evidence of my improvements

**Acceptance Criteria:**

1. Weekly report generated every Monday morning (6am)
2. Push notification: "📊 Your week in review is ready!"
3. Report includes:
   - **Fitness:** Workouts completed, +XKG on exercise (PR), Total volume (+X%)
   - **Mind:** Meditations completed (avg duration), Stress: -X% vs last week, Mood avg (↑ from last week)
   - **Life Coach:** Check-ins completed (X/7), Goals progressed (X%), Daily plan completion (X% avg)
   - **Streaks:** Workout streak, Meditation streak, Check-in streak
   - **Top Insight:** "Your best workouts happened after 8+ hours sleep. Prioritize sleep this week!"
4. Report shareable (generate image, share to social)
5. Report saved in history ("View Past Weeks")
6. Report accessible from Home tab (card shown Monday-Tuesday)

**FRs:** FR90

**UX Notes (from UX spec):**
- Report card: Clean, data-focused
- Stats with trend arrows (↑ ↓ →)
- Color-coded by module (Orange for Fitness, Purple for Mind, Deep Blue for Life Coach)
- "Share Report" button (optional)

**Prerequisites:** Epic 2 (Story 2.10), Epic 3, Epic 4

**Technical Notes:**
- Cron job Monday 6am (Supabase Edge Function)
- Aggregate queries on past 7 days (all modules)
- Push notification via Firebase Cloud Messaging
- weekly_reports table (user_id, week_start_date, report_data JSON, created_at)

---

## Epic 7: Onboarding & Subscriptions

**Goal:** Deliver smooth onboarding flow, 14-day trial, subscription management, and payment processing.

**Value:** Users get personalized onboarding, can try premium features, and subscribe easily.

**FRs Covered:** FR91-FR97 (Subscriptions), FR111-FR115 (Onboarding)

**Dependencies:** Epic 1 (auth)

**Stories:** 7

---

### Story 7.1: Onboarding Flow - Choose Your Journey

**Phase:** MVP

**As a** new user
**I want** personalized onboarding based on my goals
**So that** the app emphasizes the module most relevant to me

**Acceptance Criteria:**

1. Onboarding starts after account creation (Story 1.1)
2. Screen 1: Welcome ("Welcome to LifeOS 🌟")
3. Screen 2: Choose journey (4 options):
   - "💪 I want to get fit" (Fitness-first)
   - "🧠 I want to reduce stress" (Mind-first)
   - "☀️ I want to organize my life" (Life Coach-first)
   - "🌟 I want it all" (Full ecosystem)
4. Onboarding flow adapts based on choice:
   - Fitness-first → Show workout logging tutorial first
   - Mind-first → Show meditation tutorial first
   - Life Coach-first → Show morning check-in tutorial first
   - Full ecosystem → Balanced overview of all 3 modules
5. Progress dots shown (5 screens total)
6. User can skip onboarding (link at bottom)

**FRs:** FR111, FR112

**UX Notes (from UX spec):**
- Welcome screen: Hero image (LifeOS logo, gradient background)
- Journey cards: Large, tappable (44x44pt minimum)
- Progress dots: Bottom center (●○○○○)

**Prerequisites:** Epic 1 (Story 1.1)

**Technical Notes:**
- onboarding_state table (user_id, journey_choice, completed)
- User preference saved for personalization

---

### Story 7.2: Onboarding - Set Initial Goals & Choose AI Personality

**Phase:** MVP

**As a** new user
**I want** to set 1-3 initial goals and choose AI personality
**So that** the app is personalized from day one

**Acceptance Criteria:**

1. Screen 3: Set goals (1-3)
2. Goal input: Title + Category (dropdown)
3. Examples shown based on journey choice:
   - Fitness: "Lose 10kg", "Run 5km"
   - Mind: "Meditate daily", "Reduce anxiety"
   - Life Coach: "Wake up at 6am", "Read 20 pages/day"
4. Screen 4: Choose AI personality (2 options):
   - 🧘 Sage (Calm, wise, supportive) - "Let's take this one step at a time"
   - ⚡ Momentum (Energetic, motivational) - "Let's crush this! You've got this!"
5. User can preview AI personality (sample message shown)
6. Selection saved (affects all AI interactions)

**FRs:** FR21, FR113

**UX Notes:**
- Goal form: Simple text input + category dropdown
- "+ Add another goal" button (max 3)
- AI personality cards: Large, with sample message preview
- Tap card to select (highlighted border)

**Prerequisites:** Story 7.1

**Technical Notes:**
- Goals created in goals table (Story 2.3)
- AI personality saved in user_settings table (ai_personality='sage'|'momentum')

---

### Story 7.3: Onboarding - Permissions & Interactive Tutorial

**Phase:** MVP

**As a** new user
**I want** to grant permissions and see a quick tutorial
**So that** I understand how to use the app

**Acceptance Criteria:**

1. Screen 5: Permissions (push notifications, health data access P1)
2. Push notifications:
   - Explanation: "Daily reminders, streak alerts, smart insights (max 1/day)"
   - "Enable Notifications" button
   - "Maybe Later" link
3. Interactive tutorial (based on journey):
   - Fitness: Log 1 sample workout (guided walkthrough)
   - Mind: Complete 2-min breathing exercise
   - Life Coach: Complete first morning check-in
4. Tutorial completion: Celebration ("You're all set! 🎉")
5. Tutorial skippable ("Skip Tutorial" link)
6. 14-day trial banner shown: "Try all premium features free for 14 days"

**FRs:** FR114, FR115

**UX Notes:**
- Permissions: Clear explanations (not scary)
- Tutorial: Overlay tooltips pointing to UI elements
- "Next" button to advance tutorial steps

**Prerequisites:** Story 7.1, Story 7.2

**Technical Notes:**
- Permission requests: iOS notifications permission, Android permission
- Tutorial state saved (completed=true after tutorial)
- Trial activation: Set trial_end_date = now + 14 days

---

### Story 7.4: Free Tier (Life Coach Basic)

**Phase:** MVP

**As a** free tier user
**I want** access to Life Coach basic features
**So that** I can try LifeOS without paying

**Acceptance Criteria:**

1. Free tier ALWAYS includes:
   - Life Coach: Daily planning, 3 goals max, Morning/evening check-ins, AI chat (3-5/day with Llama)
   - Mind: Mood tracking (ALWAYS FREE)
   - Fitness: Basic workout logging (no Smart Pattern Memory, limited templates)
2. Free tier limitations shown clearly (not hidden)
3. Premium features shown in "locked" state (with "Upgrade" CTA)
4. No credit card required for free tier
5. Free tier never expires (user can stay free forever)

**FRs:** FR91, FR92

**UX Notes:**
- Locked features: Gray overlay + lock icon + "Premium" badge
- Tap locked feature → Upgrade modal
- Free tier = full Life Coach (not crippled)

**Prerequisites:** Epic 2 (Life Coach)

**Technical Notes:**
- subscription_tier column (user table): 'free' (default)
- Feature checks: if (tier == 'free') { limit }

---

### Story 7.5: 14-Day Trial (All Premium Features)

**Phase:** MVP

**As a** new user
**I want** 14-day trial of all premium features
**So that** I can decide if LifeOS is worth paying for

**Acceptance Criteria:**

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

**UX Notes:**
- Trial banner: Subtle, not annoying (top of Home tab)
- "Subscribe Now" CTA in trial banner
- Trial countdown: "X days left"

**Prerequisites:** Story 7.3, Story 7.4

**Technical Notes:**
- trial_end_date column (user table)
- Feature checks: if (now < trial_end_date || tier == 'premium') { allow }
- Cron job: Check trial expiration daily

---

### Story 7.6: Subscription Management (In-App Purchase)

**Phase:** MVP

**As a** user wanting premium features
**I want** to subscribe to a module or plan
**So that** I can unlock full LifeOS

**Acceptance Criteria:**

1. Subscription tiers (in-app purchase):
   - 2.99 EUR/month: Any 1 module (Fitness OR Mind)
   - 5.00 EUR/month: 3-Module Pack (Life Coach + Fitness + Mind)
   - 7.00 EUR/month: Full Access + Premium AI (GPT-4 unlimited)
2. Subscription screen accessible from Profile → "Subscription"
3. Current plan shown (Free, 1-Module, 3-Module, Full Access)
4. Upgrade/downgrade options shown
5. Regional pricing: UK (£), Poland (PLN), EU (EUR)
6. Purchase via App Store (iOS) or Google Play (Android)
7. Subscription auto-renews monthly (user can cancel anytime)
8. Subscription status synced across devices (Supabase)

**FRs:** FR92, FR93, FR94

**UX Notes:**
- Pricing cards: Clear tiers (Free, 1-Module, 3-Module, Full)
- "Popular" badge on 3-Module Pack
- "Current Plan" highlighted (Teal border)
- "Subscribe" button (Teal)

**Prerequisites:** Story 7.4, Story 7.5

**Technical Notes:**
- In-app purchase: in_app_purchase package (Flutter)
- RevenueCat or Supabase webhook for subscription status
- subscription_tier column updated on purchase

---

### Story 7.7: Cancel Subscription & Graceful Degradation

**Phase:** MVP

**As a** subscribed user
**I want** to cancel my subscription anytime
**So that** I have flexibility without losing my data

**Acceptance Criteria:**

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

**UX Notes:**
- Cancel button: Red (warning color)
- Confirmation modal: Clear explanation of what happens
- "Keep Subscription" option (prevent accidental cancel)

**Prerequisites:** Story 7.6

**Technical Notes:**
- subscription_status column: 'active', 'cancelled', 'expired'
- Grace period: subscription_end_date stored
- Feature checks: if (now < subscription_end_date) { allow premium }

---

## Epic 8: Notifications & Engagement

**Goal:** Implement push notifications for reminders, streak alerts, cross-module insights, and weekly reports.

**Value:** Users stay engaged through timely reminders and high-value notifications (max 1 insight/day to avoid fatigue).

**FRs Covered:** FR104-FR110 (Notifications)

**Dependencies:** Epic 2, Epic 3, Epic 4, Epic 5 (modules + insights must exist)

**Stories:** 5

---

### Story 8.1: Push Notification Infrastructure

**Phase:** MVP

**As the system**
**I want** to send push notifications to users
**So that** they stay engaged with timely reminders

**Acceptance Criteria:**

1. Push notification service integrated (Firebase Cloud Messaging)
2. Notifications work on iOS and Android
3. User can grant/deny permission on first launch
4. Device tokens stored in database (user_id, device_token, platform)
5. Notifications sent via Supabase Edge Functions (cron jobs)
6. Notification categories: Reminders, Streaks, Insights, Reports
7. User can enable/disable each category in settings

**FRs:** FR104, FR105

**UX Notes:**
- Permission request: Clear explanation ("Get reminders and stay motivated")
- Settings screen: Toggle for each notification type

**Prerequisites:** Epic 1

**Technical Notes:**
- Firebase Cloud Messaging setup (iOS + Android)
- device_tokens table (user_id, token, platform, created_at)
- Supabase Edge Functions for sending notifications

---

### Story 8.2: Daily Reminders (Morning Check-in, Workout, Meditation)

**Phase:** MVP

**As a** user with scheduled activities
**I want** daily reminders
**So that** I don't forget my morning check-in or workout

**Acceptance Criteria:**

1. Morning check-in reminder (default 8am, user customizable)
2. Evening reflection reminder (default 8pm, user customizable)
3. Workout reminder (if workout scheduled in daily plan)
4. Meditation reminder (if meditation goal set)
5. Reminder message examples:
   - "Good morning! ☀️ Complete your check-in to start your day"
   - "Time for your workout! 💪 Leg day awaits"
   - "Evening reflection 📝 Review your day in 2 minutes"
6. Tap notification → Opens relevant screen (Deep link)
7. User can customize reminder times (settings)
8. User can disable specific reminders

**FRs:** FR105

**UX Notes:**
- Notifications: Friendly, encouraging tone
- Deep links: Direct to action (check-in modal, workout log, meditation player)

**Prerequisites:** Story 8.1, Epic 2, Epic 3, Epic 4

**Technical Notes:**
- Cron jobs: Schedule notifications based on user preferences
- notification_settings table (user_id, morning_checkin_time, evening_reflection_time, workout_reminder, meditation_reminder)
- Deep links: Custom URL scheme (lifeos://check-in, lifeos://workout, etc.)

---

### Story 8.3: Streak Alerts (About to Break, Freeze, Milestone)

**Phase:** MVP

**As a** user with active streaks
**I want** alerts when my streak is at risk
**So that** I can maintain my progress

**Acceptance Criteria:**

1. Streak alert sent if activity not completed by 8pm
2. Alert message: "🔥 Streak Alert! Your 15-day meditation streak is about to break. Meditate now!"
3. Alert NOT sent if freeze available (automatic freeze used instead)
4. Freeze used notification: "Streak freeze used! You have 0 freezes left this week."
5. Milestone alert: "🎉 Milestone! You've reached a 30-day workout streak. Silver badge unlocked!"
6. Tap notification → Opens relevant module
7. User can disable streak alerts (settings)

**FRs:** FR106

**UX Notes:**
- Alerts: Motivating, not guilt-tripping
- Freeze notification: Reassuring ("We've got you covered")

**Prerequisites:** Story 8.1, Epic 6 (Streaks)

**Technical Notes:**
- Cron job 8pm daily: Check streaks, send alerts
- Milestone notifications sent immediately on achievement

---

### Story 8.4: Cross-Module Insight Notifications (Max 1/day)

**Phase:** MVP

**As a** user receiving cross-module insights
**I want** a push notification for high-priority insights
**So that** I can act on them immediately

**Acceptance Criteria:**

1. Insight notification sent for critical insights only (e.g., overtraining risk)
2. Max 1 insight notification per day (prevents fatigue)
3. Notification message: "💡 Insight: High stress + heavy workout today. Consider a light session."
4. Tap notification → Opens Home tab with insight card visible
5. User can disable insight notifications (settings)
6. Insight shown in-app even if notification disabled

**FRs:** FR107

**UX Notes:**
- Notification: Clear, actionable message
- Not spammy (max 1/day)

**Prerequisites:** Story 8.1, Epic 5 (Cross-Module Intelligence)

**Technical Notes:**
- Insight notification flag (insights table: notification_sent BOOLEAN)
- Sent immediately when high-priority insight generated

---

### Story 8.5: Weekly Summary Notification & Quiet Hours

**Phase:** MVP

**As a** user
**I want** a weekly summary notification
**And** quiet hours for notifications
**So that** I'm not disturbed at night

**Acceptance Criteria:**

1. Weekly summary notification sent every Monday 8am
2. Notification message: "📊 Your week in review is ready! +5kg squat, stress -23%, 4 workouts"
3. Tap notification → Opens Home tab with weekly report card
4. Quiet hours setting (default 10pm - 7am, user customizable)
5. No notifications sent during quiet hours (except emergencies)
6. Notifications batched during quiet hours (sent when quiet hours end)
7. User can disable quiet hours (settings)

**FRs:** FR108, FR109

**UX Notes:**
- Weekly notification: Exciting, shows concrete stats
- Quiet hours: Respect user's sleep (good UX)

**Prerequisites:** Story 8.1, Epic 6 (Weekly Report)

**Technical Notes:**
- Cron job Monday 8am: Send weekly summary notification
- Quiet hours check before sending any notification
- notification_settings table: quiet_hours_start, quiet_hours_end

---

## Epic 9: Settings & Profile

**Goal:** Deliver user settings, preferences, account management, and data privacy controls.

**Value:** Users can customize app, manage subscription, and control data privacy (GDPR compliance).

**FRs Covered:** FR116-FR123 (Settings & Profile)

**Dependencies:** Epic 1 (auth), Epic 7 (subscriptions)

**Stories:** 5

---

### Story 9.1: Personal Settings (Name, Email, Password, Avatar)

**Phase:** MVP

**As a** user
**I want** to update my personal information
**So that** my account is current

**Acceptance Criteria:**

1. Settings screen accessible from Profile tab
2. Personal info section: Name, Email, Password, Avatar
3. Edit mode: Tap field → Inline editing
4. Name: Max 50 chars, validation (no special chars)
5. Email: Validation (valid format), requires re-verification if changed
6. Password: Change password (requires current password confirmation)
7. Avatar: Upload from gallery or camera (max 5MB, JPG/PNG)
8. Changes saved to Supabase (synced across devices)
9. Success message: "Settings updated successfully"

**FRs:** FR116, FR4

**UX Notes:**
- Settings screen: List of sections (Personal Info, Notifications, Subscription, etc.)
- Edit mode: Pencil icon → Inline editing
- Avatar: Circular image with "Change photo" overlay

**Prerequisites:** Epic 1 (Story 1.4)

**Technical Notes:**
- Update user table (name, email, avatar_url)
- Email change triggers verification email
- Avatar upload to Supabase Storage

---

### Story 9.2: Notification Preferences

**Phase:** MVP

**As a** user
**I want** to control which notifications I receive
**So that** I'm not overwhelmed

**Acceptance Criteria:**

1. Notification settings section (Settings → Notifications)
2. Toggle for each notification type:
   - Morning check-in reminder
   - Evening reflection reminder
   - Workout reminder
   - Meditation reminder
   - Streak alerts
   - Cross-module insights
   - Weekly summary
3. Customize times: Morning reminder time, Evening reminder time
4. Quiet hours: Start time, End time (default 10pm - 7am)
5. Changes saved immediately (optimistic UI)
6. Test notification button ("Send test notification")

**FRs:** FR117

**UX Notes:**
- Toggle switches: iOS style (green when ON)
- Time pickers: Native OS pickers (iOS wheel, Android clock)
- "Test notification" button: Sends sample notification immediately

**Prerequisites:** Epic 8 (Notifications)

**Technical Notes:**
- notification_settings table updated
- Test notification: Send via Firebase Cloud Messaging immediately

---

### Story 9.3: Unit Preferences (kg/lbs, cm/inches)

**Phase:** MVP

**As a** user from different regions
**I want** to choose my preferred units
**So that** data is displayed in familiar format

**Acceptance Criteria:**

1. Unit settings section (Settings → Units)
2. Weight unit: kg or lbs (toggle)
3. Distance unit: km or miles (toggle, P1 for running)
4. Height unit: cm or inches (toggle)
5. Unit changes apply immediately across app
6. Historical data converted automatically (e.g., 100kg → 220lbs)
7. Workout logs re-rendered with new units

**FRs:** FR118

**UX Notes:**
- Toggle switches: "kg ↔ lbs"
- Immediate feedback: "Weight unit changed to lbs"

**Prerequisites:** Epic 3 (Fitness data)

**Technical Notes:**
- user_settings table: weight_unit, distance_unit, height_unit
- Conversion functions: kgToLbs(), cmToInches()
- Display logic: Check user preference before rendering

---

### Story 9.4: Subscription & Billing Management

**Phase:** MVP

**As a** subscribed user
**I want** to manage my subscription
**So that** I can upgrade, downgrade, or cancel

**Acceptance Criteria:**

1. Subscription section (Settings → Subscription)
2. Current plan shown: Tier name, Price, Billing date
3. Upgrade options: "Upgrade to Full Access" button
4. Downgrade options: "Switch to 1-Module" button
5. Cancel subscription button (red, bottom)
6. Billing history: List of past charges (date, amount, receipt)
7. Receipt download button (PDF)
8. Manage subscription → Opens App Store/Google Play subscription management (iOS/Android)

**FRs:** FR119

**UX Notes:**
- Current plan: Highlighted card (Teal border)
- Upgrade/downgrade: Clear CTAs
- Billing history: Scrollable list (date, amount, status)

**Prerequisites:** Epic 7 (Subscriptions)

**Technical Notes:**
- Query subscription status from RevenueCat or Supabase
- Billing history: Store in subscriptions table (transaction history)
- Receipt: Generate PDF (Supabase Edge Function)

---

### Story 9.5: Data Privacy & Cross-Module Settings

**Phase:** MVP

**As a** privacy-conscious user
**I want** to control data sharing and AI analysis
**So that** I maintain privacy

**Acceptance Criteria:**

1. Data & Privacy section (Settings → Data & Privacy)
2. Toggle: "Allow modules to share data" (default ON)
   - If OFF: Cross-module insights disabled (warning shown)
3. Toggle: "AI analysis of journal entries" (default OFF)
   - If OFF: Sentiment analysis disabled (E2E encryption only)
4. Toggle: "Send anonymous analytics" (default ON)
   - App usage data (no PII)
5. "Export All Data" button → Generate ZIP (Story 1.6)
6. "Delete Account" button (red, bottom) → Confirmation modal
7. Privacy Policy link
8. GDPR compliance message: "Your data is yours. We never sell it."

**FRs:** FR122, FR123, FR102

**UX Notes:**
- Clear explanations for each toggle
- Warning if user disables cross-module sharing: "Some features won't work"
- Privacy Policy: Opens in-app browser

**Prerequisites:** Epic 1 (Story 1.6), Epic 5 (Cross-Module Intelligence)

**Technical Notes:**
- user_settings table: share_data_across_modules, ai_journal_analysis, send_analytics
- Feature checks: if (!share_data_across_modules) { disable insights }

---

## Epic Summary & FR Coverage Validation

### Epic Recap

1. **Epic 1: Core Platform Foundation** - 6 stories (FR1-5, FR98-103) ✅
2. **Epic 2: Life Coach MVP** - 10 stories (FR6-29) ✅
3. **Epic 3: Fitness Coach MVP** - 10 stories (FR30-46) ✅
4. **Epic 4: Mind & Emotion MVP** - 12 stories (FR47-76) ✅
5. **Epic 5: Cross-Module Intelligence** - 5 stories (FR77-84) ✅
6. **Epic 6: Gamification & Retention** - 6 stories (FR85-90) ✅
7. **Epic 7: Onboarding & Subscriptions** - 7 stories (FR91-97, FR111-115) ✅
8. **Epic 8: Notifications & Engagement** - 5 stories (FR104-110) ✅
9. **Epic 9: Settings & Profile** - 5 stories (FR116-123) ✅

**Total:** 9 Epics, 66 Stories

---

### FR Coverage Check (123 FRs)

| FR Range | Description | Epic | Stories | Status |
|----------|-------------|------|---------|--------|
| FR1-FR5 | Authentication | Epic 1 | 1.1-1.4 | ✅ |
| FR6-FR10 | Life Coach - Daily Planning | Epic 2 | 2.1-2.2, 2.8 | ✅ |
| FR11-FR17 | Life Coach - Goal Tracking | Epic 2 | 2.3, 2.9 | ✅ |
| FR18-FR24 | Life Coach - AI Chat | Epic 2 | 2.4 | ✅ |
| FR25-FR29 | Life Coach - Check-ins | Epic 2 | 2.1, 2.5-2.7, 2.10 | ✅ |
| FR30-FR37 | Fitness - Logging | Epic 3 | 3.1-3.4, 3.8 | ✅ |
| FR38-FR42 | Fitness - Progress | Epic 3 | 3.5 | ✅ |
| FR43-FR46 | Fitness - Templates | Epic 3 | 3.7, 3.9 | ✅ |
| FR47-FR54 | Mind - Meditation | Epic 4 | 4.1-4.2, 4.10 | ✅ |
| FR55-FR60 | Mind - Mood/Stress | Epic 4 | 4.3, 4.11 | ✅ |
| FR61-FR65 | Mind - CBT/Journal | Epic 4 | 4.4-4.5 | ✅ |
| FR66-FR70 | Mind - Screening | Epic 4 | 4.6 | ✅ |
| FR71-FR76 | Mind - Breathing/Sleep | Epic 4 | 4.7-4.9 | ✅ |
| FR77-FR84 | Cross-Module Intelligence | Epic 5 | 5.1-5.5 | ✅ |
| FR85-FR90 | Gamification | Epic 6 | 6.1-6.6 | ✅ |
| FR91-FR97 | Subscriptions | Epic 7 | 7.4-7.7 | ✅ |
| FR98-FR103 | Data/Privacy | Epic 1 | 1.5-1.6 | ✅ |
| FR104-FR110 | Notifications | Epic 8 | 8.1-8.5 | ✅ |
| FR111-FR115 | Onboarding | Epic 7 | 7.1-7.3 | ✅ |
| FR116-FR123 | Settings/Profile | Epic 9 | 9.1-9.5 | ✅ |

**Coverage:** 123/123 FRs covered ✅

---

### Sequencing Validation

**Epic 1 (Foundation):**
- ✅ Establishes auth, data sync, GDPR foundation
- ✅ All subsequent epics depend on Epic 1
- ✅ No forward dependencies

**Epics 2-4 (Core Modules):**
- ✅ Can be developed in parallel (independent modules)
- ✅ Each delivers end-to-end user value
- ✅ Vertical slicing (not horizontal layers)

**Epic 5 (Cross-Module Intelligence):**
- ✅ Depends on Epics 2-4 (modules must exist first)
- ✅ No forward dependencies

**Epics 6-9 (Enhancement Layers):**
- ✅ Depend on earlier epics (Gamification needs modules, Notifications need features to notify about)
- ✅ No forward dependencies
- ✅ Can be prioritized flexibly

**Validation:** ✅ No forward dependencies detected

---

### Vertical Slicing Check

**Epic 1:**
- ✅ Story 1.1: Account creation (auth + DB + UI)
- ✅ Story 1.5: Data sync (backend + frontend + offline)

**Epic 2:**
- ✅ Story 2.1: Morning check-in (UI + data + AI integration)
- ✅ Story 2.2: AI daily plan (backend AI + frontend display)

**Epic 3:**
- ✅ Story 3.1: Smart Pattern Memory (query + pre-fill + UI + offline)
- ✅ Story 3.5: Progress charts (data aggregation + charting + UI)

**Epic 4:**
- ✅ Story 4.1: Meditation library (audio storage + player + UI + tracking)

**Epic 5:**
- ✅ Story 5.2: Insight card UI (backend pattern detection + frontend card + CTA actions)

**Validation:** ✅ All stories are vertical slices (end-to-end functionality)

---

## Implementation Readiness

### For Developers

**Architecture Inputs Available:**
- ✅ PRD (123 FRs, 37 NFRs, mobile_app type, general domain)
- ✅ UX Design Specification (interaction patterns, screen flows, visual system)
- ⏳ Architecture (pending - next workflow)

**Development Order:**
1. Epic 1 → Epic 2/3/4 (parallel) → Epic 5 → Epic 6/7/8/9

**Technical Stack (from PRD):**
- Frontend: Flutter 3.38+, Riverpod 3.0, Drift (SQLite)
- Backend: Supabase (PostgreSQL, Realtime, Auth, Storage, Edge Functions)
- AI: Hybrid (Llama self-hosted, Claude/GPT-4 APIs)

**Estimated Scope:**
- 66 stories total
- Average 2-4 hours per story (AI-assisted development)
- ~150-250 hours total development time

---

## Document Status

✅ **COMPLETE** - Ready for validation and architecture workflow

**Version:** 1.0
**Last Updated:** 2025-01-16
**Next Steps:**
1. Run `*validate-prd` (full validation now possible with epics.md)
2. Then run `*create-architecture` (Architect agent)

---

_This epic breakdown was created by John (PM - BMAD) based on PRD.md (123 FRs) and UX Design Specification. All 123 FRs are covered across 9 epics and 66 vertical-sliced stories._

**Ready to implement! 🚀**
