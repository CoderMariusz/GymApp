# Epic 8: Notifications & Engagement

<!-- AI-INDEX: notifications, push, fcm, firebase, reminders, alerts, engagement, quiet-hours -->

**Goal:** Implement push notifications for reminders, streak alerts, cross-module insights, and weekly reports.

**Value:** Users stay engaged through timely reminders and high-value notifications (max 1 insight/day to avoid fatigue).

**FRs Covered:** FR104-FR110 (Notifications)

**Dependencies:** Epic 2, Epic 3, Epic 4, Epic 5 (modules + insights must exist)

**Stories:** 5

---

## Story 8.1: Push Notification Infrastructure

**Phase:** MVP
**Status:** Not Started

**As the system**
**I want** to send push notifications to users
**So that** they stay engaged with timely reminders

### Acceptance Criteria

1. Push notification service integrated (Firebase Cloud Messaging)
2. Notifications work on iOS and Android
3. User can grant/deny permission on first launch
4. Device tokens stored in database (user_id, device_token, platform)
5. Notifications sent via Supabase Edge Functions (cron jobs)
6. Notification categories: Reminders, Streaks, Insights, Reports
7. User can enable/disable each category in settings

**FRs:** FR104, FR105

### UX Notes
- Permission request: Clear explanation ("Get reminders and stay motivated")
- Settings screen: Toggle for each notification type

### Technical Notes
- Firebase Cloud Messaging setup (iOS + Android)
- device_tokens table (user_id, token, platform, created_at)
- Supabase Edge Functions for sending notifications

---

## Story 8.2: Daily Reminders (Morning Check-in, Workout, Meditation)

**Phase:** MVP
**Status:** Not Started

**As a** user with scheduled activities
**I want** daily reminders
**So that** I don't forget my morning check-in or workout

### Acceptance Criteria

1. Morning check-in reminder (default 8am, user customizable)
2. Evening reflection reminder (default 8pm, user customizable)
3. Workout reminder (if workout scheduled in daily plan)
4. Meditation reminder (if meditation goal set)
5. Reminder message examples:
   - "Good morning! Complete your check-in to start your day"
   - "Time for your workout! Leg day awaits"
   - "Evening reflection - Review your day in 2 minutes"
6. Tap notification → Opens relevant screen (Deep link)
7. User can customize reminder times (settings)
8. User can disable specific reminders

**FRs:** FR105

### UX Notes
- Notifications: Friendly, encouraging tone
- Deep links: Direct to action (check-in modal, workout log, meditation player)

### Technical Notes
- Cron jobs: Schedule notifications based on user preferences
- notification_settings table (user_id, morning_checkin_time, evening_reflection_time, workout_reminder, meditation_reminder)
- Deep links: Custom URL scheme (lifeos://check-in, lifeos://workout, etc.)

---

## Story 8.3: Streak Alerts (About to Break, Freeze, Milestone)

**Phase:** MVP
**Status:** Not Started

**As a** user with active streaks
**I want** alerts when my streak is at risk
**So that** I can maintain my progress

### Acceptance Criteria

1. Streak alert sent if activity not completed by 8pm
2. Alert message: "Streak Alert! Your 15-day meditation streak is about to break. Meditate now!"
3. Alert NOT sent if freeze available (automatic freeze used instead)
4. Freeze used notification: "Streak freeze used! You have 0 freezes left this week."
5. Milestone alert: "Milestone! You've reached a 30-day workout streak. Silver badge unlocked!"
6. Tap notification → Opens relevant module
7. User can disable streak alerts (settings)

**FRs:** FR106

### UX Notes
- Alerts: Motivating, not guilt-tripping
- Freeze notification: Reassuring ("We've got you covered")

### Technical Notes
- Cron job 8pm daily: Check streaks, send alerts
- Milestone notifications sent immediately on achievement

---

## Story 8.4: Cross-Module Insight Notifications (Max 1/day)

**Phase:** MVP
**Status:** Not Started

**As a** user receiving cross-module insights
**I want** a push notification for high-priority insights
**So that** I can act on them immediately

### Acceptance Criteria

1. Insight notification sent for critical insights only (e.g., overtraining risk)
2. Max 1 insight notification per day (prevents fatigue)
3. Notification message: "Insight: High stress + heavy workout today. Consider a light session."
4. Tap notification → Opens Home tab with insight card visible
5. User can disable insight notifications (settings)
6. Insight shown in-app even if notification disabled

**FRs:** FR107

### UX Notes
- Notification: Clear, actionable message
- Not spammy (max 1/day)

### Technical Notes
- Insight notification flag (insights table: notification_sent BOOLEAN)
- Sent immediately when high-priority insight generated

---

## Story 8.5: Weekly Summary Notification & Quiet Hours

**Phase:** MVP
**Status:** Not Started

**As a** user
**I want** a weekly summary notification
**And** quiet hours for notifications
**So that** I'm not disturbed at night

### Acceptance Criteria

1. Weekly summary notification sent every Monday 8am
2. Notification message: "Your week in review is ready! +5kg squat, stress -23%, 4 workouts"
3. Tap notification → Opens Home tab with weekly report card
4. Quiet hours setting (default 10pm - 7am, user customizable)
5. No notifications sent during quiet hours (except emergencies)
6. Notifications batched during quiet hours (sent when quiet hours end)
7. User can disable quiet hours (settings)

**FRs:** FR108, FR109

### UX Notes
- Weekly notification: Exciting, shows concrete stats
- Quiet hours: Respect user's sleep (good UX)

### Technical Notes
- Cron job Monday 8am: Send weekly summary notification
- Quiet hours check before sending any notification
- notification_settings table: quiet_hours_start, quiet_hours_end

---

## Technical Implementation Notes

### Firebase Setup Required

```yaml
# Required Firebase configuration
- iOS: GoogleService-Info.plist
- Android: google-services.json
- FCM Server Key for Edge Functions
```

### Device Token Management

```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  token TEXT NOT NULL,
  platform TEXT NOT NULL, -- 'ios' | 'android'
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Edge Function Pattern

```typescript
// supabase/functions/send-notification/index.ts
serve(async (req) => {
  const { user_id, title, body, data } = await req.json()

  const tokens = await getDeviceTokens(user_id)

  for (const token of tokens) {
    await sendFCM(token, { title, body, data })
  }
})
```

---

## Related Documents

- [PRD-nfr.md](../../1-BASELINE/product/PRD-nfr.md) - NFR requirements
- [epic-5-cross-module.md](./epic-5-cross-module.md) - Cross-Module Intelligence
- [epic-6-gamification.md](./epic-6-gamification.md) - Gamification (streaks)

---

*5 Stories | FR104-FR110 | Notifications & Engagement | Status: Not Started*
