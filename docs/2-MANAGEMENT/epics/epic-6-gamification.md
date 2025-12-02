# Epic 6: Gamification & Retention

<!-- AI-INDEX: gamification, streaks, badges, celebrations, retention, milestones, sharing, weekly-report -->

**Goal:** Implement gamification mechanics (streaks, badges, celebrations) and weekly summary reports to drive retention.

**Value:** Users stay engaged through visible progress, milestone celebrations, and concrete evidence of improvement.

**FRs Covered:** FR85-FR90 (Gamification & Retention)

**Dependencies:** Epic 2, Epic 3, Epic 4 (modules must exist to track streaks)

**Stories:** 6

---

## Story 6.1: Streak Tracking System (Workouts, Meditations, Check-ins)

**Phase:** MVP
**Status:** 🔄 In Progress

**As a** user building habits
**I want** to see my streaks for workouts, meditations, and check-ins
**So that** I'm motivated to maintain consistency

### Acceptance Criteria

1. 3 streak types: Workout streak, Meditation streak, Check-in streak
2. Streak increments when user completes activity (daily)
3. Streak breaks if user misses a day (no activity)
4. Streak freeze: 1 per week per streak type (automatic on first miss)
5. Freeze availability shown: "Freeze available: 1 this week"
6. Streak resets on Sunday (new week, new freeze)
7. Longest streak saved (personal record)
8. Current streak shown on Home tab (fire emoji)

**FRs:** FR85, FR86, FR87

### UX Notes
- Streak card on Home tab
- Fire emoji + number (e.g., "7-day streak!")
- Progress bar to next milestone (Bronze 7d, Silver 30d, Gold 100d)

### Technical Notes
- streaks table (user_id, type, current_streak, longest_streak, freeze_used_this_week, last_activity_date)
- Cron job daily (checks if streak should increment or break)

---

## Story 6.2: Milestone Badges (Bronze, Silver, Gold)

**Phase:** MVP
**Status:** 🔄 In Progress

**As a** user reaching a streak milestone
**I want** to earn badges
**So that** I feel recognized for my commitment

### Acceptance Criteria

1. Milestone badges: Bronze (7 days), Silver (30 days), Gold (100 days)
2. Badges awarded for each streak type (9 total badges possible)
3. Badge unlock: Full-screen celebration (confetti animation)
4. Badge shown in profile: "Badges Earned" section
5. Badge icons: Bronze, Silver, Gold medals
6. Shareable badge card (generate image, share to social media)
7. Push notification on badge unlock: "Silver Meditation Badge earned!"

**FRs:** FR86, FR88

### UX Notes
- Confetti animation: Lottie, 2 seconds
- Badge unlock screen: Full-screen modal, badge zooms in
- "Share Achievement" button (optional)

### Technical Notes
- badges table (user_id, type, tier='bronze'|'silver'|'gold', earned_at)
- Badge detection: Check current_streak against milestones
- Confetti: Lottie animation file

---

## Story 6.3: Streak Break Alerts (Push Notification)

**Phase:** MVP
**Status:** Planned

**As a** user about to break a streak
**I want** a reminder notification
**So that** I don't lose my progress

### Acceptance Criteria

1. Push notification sent if streak about to break (8pm, if activity not done today)
2. Notification message: "Streak Alert! Your 15-day meditation streak is about to break. Meditate now!"
3. Tap notification → Opens relevant module (Meditation player, Workout log, Check-in modal)
4. Notification NOT sent if freeze available (automatic freeze used instead)
5. User can disable streak alerts in settings

**FRs:** FR87, FR106

### UX Notes
- Notification tone: Encouraging, not guilt-tripping
- Deep link to quick action (1-tap to complete)

### Technical Notes
- Cron job 8pm daily (check streaks, send notifications)
- Deep link: Open app to specific screen
- Notification service: Supabase + Firebase Cloud Messaging

---

## Story 6.4: Celebration Animations (Confetti, Badge Pop)

**Phase:** MVP
**Status:** Planned

**As a** user achieving a milestone
**I want** a celebration animation
**So that** I feel rewarded and motivated

### Acceptance Criteria

1. Confetti animation on: Badge unlock, PR achievement, Goal completion
2. Animation: Lottie confetti (colorful, 2 seconds)
3. Badge pop: Badge icon zooms in with bounce effect
4. Haptic feedback: Medium vibration during celebration
5. Sound effect: Optional chime (can disable in settings)
6. Celebration doesn't block user (can dismiss early)

**FRs:** FR88

### UX Notes
- Confetti colors: Match module theme (Orange for Fitness, Purple for Mind)
- Badge bounce: Elastic easing (playful, not jarring)

### Technical Notes
- Lottie animations (confetti.json)
- Flutter animations: ScaleTransition for badge pop
- Haptic: HapticFeedback.mediumImpact()

---

## Story 6.5: Shareable Milestone Cards (Social Sharing)

**Phase:** MVP
**Status:** Planned

**As a** user earning a badge or achieving a goal
**I want** to share my achievement
**So that** I can celebrate with friends

### Acceptance Criteria

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

### UX Notes
- Card design: LifeOS branding (Deep Blue background, Teal accents)
- Badge prominent (large, centered)
- Clean typography (Inter Bold)

### Technical Notes
- Image generation: screenshot package (Flutter) or server-side image generation
- Share: share_plus package (Flutter)
- Image stored temporarily (deleted after 24h)

---

## Story 6.6: Weekly Summary Report (All Modules)

**Phase:** MVP
**Status:** Planned

**As a** user tracking progress across all modules
**I want** a weekly summary report
**So that** I can see concrete evidence of my improvements

### Acceptance Criteria

1. Weekly report generated every Monday morning (6am)
2. Push notification: "Your week in review is ready!"
3. Report includes:
   - **Fitness:** Workouts completed, +XKG on exercise (PR), Total volume (+X%)
   - **Mind:** Meditations completed (avg duration), Stress: -X% vs last week, Mood avg
   - **Life Coach:** Check-ins completed (X/7), Goals progressed (X%), Daily plan completion (X% avg)
   - **Streaks:** Workout streak, Meditation streak, Check-in streak
   - **Top Insight:** "Your best workouts happened after 8+ hours sleep."
4. Report shareable (generate image, share to social)
5. Report saved in history ("View Past Weeks")
6. Report accessible from Home tab (card shown Monday-Tuesday)

**FRs:** FR90

### UX Notes
- Report card: Clean, data-focused
- Stats with trend arrows (up, down, stable)
- Color-coded by module (Orange for Fitness, Purple for Mind, Deep Blue for Life Coach)

### Technical Notes
- Cron job Monday 6am (Supabase Edge Function)
- Aggregate queries on past 7 days (all modules)
- Push notification via Firebase Cloud Messaging
- weekly_reports table (user_id, week_start_date, report_data JSON, created_at)

---

## Related Documents

- [PRD-overview.md](../../1-BASELINE/product/PRD-overview.md) - Product overview
- [epic-2-life-coach.md](./epic-2-life-coach.md) - Life Coach (check-in streaks)
- [epic-3-fitness.md](./epic-3-fitness.md) - Fitness (workout streaks)
- [epic-4-mind.md](./epic-4-mind.md) - Mind (meditation streaks)

---

*6 Stories | FR85-FR90 | Gamification & Retention*
