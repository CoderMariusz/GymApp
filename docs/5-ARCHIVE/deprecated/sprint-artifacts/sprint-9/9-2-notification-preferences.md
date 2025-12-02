# Story 9.2: Notification Preferences

**Epic:** Epic 9 - Settings & Profile
**Sprint:** 9
**Story Points:** 2
**Priority:** P0
**Status:** ready-for-dev

## Dev Agent Record

### Context Reference

- **Story Context File:** [9-2-notification-preferences.context.xml](./9-2-notification-preferences.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

---

## User Story

**As a** user
**I want** to control all notification preferences in one place
**So that** I only receive the notifications I want

---

## Acceptance Criteria

- ✅ User can enable/disable each notification type:
  - Morning check-in reminder
  - Evening reflection reminder
  - Workout reminder
  - Meditation reminder
  - Streak alerts
  - Cross-module insights
  - Weekly summary
- ✅ User can set custom time for morning/evening reminders (time picker)
- ✅ User can enable/disable **quiet hours** (default: 10pm - 7am)
- ✅ User can customize quiet hours start/end time
- ✅ "Send Test Notification" button to verify settings
- ✅ Settings persist across app restarts
- ✅ Changes sync to backend immediately (optimistic UI)

---

## Technical Implementation

See: `docs/sprint-artifacts/tech-spec-epic-8.md` Story 8.2 & 8.5

**Key Components:**
- `NotificationSettingsScreen` (UI)
- `NotificationSettingsService` (business logic)
- `QuietHoursService` (quiet hours logic)

**Database:**
```sql
notification_settings (
  user_id,
  morning_checkin_enabled,
  morning_checkin_time,
  evening_reflection_enabled,
  evening_reflection_time,
  workout_reminder_enabled,
  meditation_reminder_enabled,
  streak_alerts_enabled,
  insight_notifications_enabled,
  weekly_summary_enabled,
  quiet_hours_enabled,
  quiet_hours_start,
  quiet_hours_end
)
```

---

## UI/UX Design

**NotificationSettingsScreen**
- Section 1: Daily Reminders
  - Morning check-in (toggle + time picker)
  - Evening reflection (toggle + time picker)
  - Workout reminder (toggle)
  - Meditation reminder (toggle)

- Section 2: Alerts
  - Streak alerts (toggle)
  - Cross-module insights (toggle + "Max 1/day" note)
  - Weekly summary (toggle)

- Section 3: Quiet Hours
  - Enable quiet hours (toggle)
  - Start time (time picker, default 10pm)
  - End time (time picker, default 7am)
  - Note: "No notifications during quiet hours"

- Section 4: Testing
  - "Send Test Notification" button

---

## Testing

**Critical Scenarios:**
1. Disable morning check-in → No reminder sent at 8am
2. Change morning check-in time to 7am → Reminder sent at 7am next day
3. Enable quiet hours (10pm-7am) → Notification at 11pm skipped
4. Tap "Send Test Notification" → Push notification received immediately

---

## Definition of Done

- ✅ User can control all notification types
- ✅ Custom times for reminders
- ✅ Quiet hours configurable
- ✅ Test notification working
- ✅ Settings persist and sync
- ✅ Code reviewed and merged

**Created:** 2025-01-16 | **Author:** Bob
