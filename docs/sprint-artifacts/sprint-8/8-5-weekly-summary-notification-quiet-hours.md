# Story 8.5: Weekly Summary Notification & Quiet Hours

**Epic:** Epic 8 - Notifications & Engagement
**Sprint:** 8
**Story Points:** 3
**Priority:** P1
**Status:** Draft

---

## User Story

**As a** user
**I want** to receive a weekly summary notification every Monday morning
**So that** I can review my progress from the previous week

**As a** user
**I want** to configure quiet hours for all notifications
**So that** I'm not disturbed during sleep or focus time

---

## Acceptance Criteria

### Weekly Summary Notification
- ✅ Notification sent every **Monday at 8am** (user's local timezone)
- ✅ Notification includes week summary: workouts, meditations, goals, top insight
- ✅ Tapping notification opens Weekly Report Card
- ✅ Deep link: `lifeos://home/weekly-report`
- ✅ User can disable weekly summary notifications in Settings

### Quiet Hours
- ✅ Default quiet hours: **10pm - 7am** (user customizable)
- ✅ **No notifications** sent during quiet hours (all types: reminders, streaks, insights, weekly summary)
- ✅ Exception: Critical alerts (e.g., account security) bypass quiet hours
- ✅ User can toggle quiet hours ON/OFF in Settings
- ✅ User can customize start/end time (time picker UI)
- ✅ Quiet hours apply to all notification types globally

---

## Technical Implementation

### Data Models

```dart
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    required String userId,
    // ... (other notification settings from Story 8.2)
    required bool weeklySummaryEnabled,
    required bool quietHoursEnabled,
    required TimeOfDay quietHoursStart,  // Default: 22:00
    required TimeOfDay quietHoursEnd,    // Default: 07:00
  }) = _NotificationSettings;
}
```

### Database Schema

```sql
ALTER TABLE notification_settings ADD COLUMN IF NOT EXISTS
  weekly_summary_enabled BOOLEAN DEFAULT TRUE,
  quiet_hours_enabled BOOLEAN DEFAULT TRUE,
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '07:00';
```

---

## Part 1: Weekly Summary Notification

### Supabase Edge Function: `send-weekly-summary-notifications`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_KEY')!)

  // Get all users with weekly summary enabled
  const { data: users } = await supabase
    .from('notification_settings')
    .select('user_id, quiet_hours_enabled, quiet_hours_start, quiet_hours_end')
    .eq('weekly_summary_enabled', true)

  for (const user of users || []) {
    try {
      // Check quiet hours
      if (isInQuietHours(user)) {
        console.log(`User ${user.user_id}: In quiet hours, skipping notification`)
        continue
      }

      // Get latest weekly report
      const { data: report } = await supabase
        .from('weekly_reports')
        .select('report_data')
        .eq('user_id', user.user_id)
        .order('week_start_date', { ascending: false })
        .limit(1)
        .maybeSingle()

      if (!report) {
        console.log(`User ${user.user_id}: No weekly report found`)
        continue
      }

      // Generate notification summary
      const summary = generateSummary(report.report_data)

      // Send notification
      await sendNotification(supabase, {
        userId: user.user_id,
        title: '📊 Your Week in Review',
        body: summary,
        deepLink: 'lifeos://home/weekly-report',
        type: 'weekly_summary',
      })
    } catch (error) {
      console.error(`Error processing user ${user.user_id}:`, error)
    }
  }

  return new Response(JSON.stringify({ processed: users?.length || 0 }), { status: 200 })
})

function generateSummary(reportData: any): string {
  const parts = []

  if (reportData.workoutsCompleted > 0) {
    parts.push(`${reportData.workoutsCompleted} workouts`)
  }

  if (reportData.prAchieved) {
    parts.push(`PR: ${reportData.prAchieved}`)
  }

  if (reportData.meditationsCompleted > 0) {
    parts.push(`${reportData.meditationsCompleted} meditations`)
  }

  if (reportData.stressChange) {
    parts.push(`stress ${reportData.stressChange}`)
  }

  return parts.join(', ') || 'Review your weekly progress'
}

function isInQuietHours(user: any): boolean {
  if (!user.quiet_hours_enabled) return false

  const now = new Date()
  const currentTime = now.getHours() * 60 + now.getMinutes()
  const startTime = parseTime(user.quiet_hours_start)
  const endTime = parseTime(user.quiet_hours_end)

  if (startTime < endTime) {
    return currentTime >= startTime && currentTime < endTime
  } else {
    // Quiet hours span midnight (e.g., 22:00 - 07:00)
    return currentTime >= startTime || currentTime < endTime
  }
}

function parseTime(timeStr: string): number {
  const [hours, minutes] = timeStr.split(':').map(Number)
  return hours * 60 + minutes
}
```

### Cron Job: Send Weekly Summary (Monday 8am)

```sql
SELECT cron.schedule(
  'send-weekly-summary-notifications',
  '0 8 * * 1',  -- Monday 8am
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/send-weekly-summary-notifications',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

## Part 2: Quiet Hours Implementation

### QuietHoursService

```dart
class QuietHoursService {
  final NotificationSettingsRepository _repository;

  /// Check if current time is in quiet hours
  Future<bool> isInQuietHours(String userId) async {
    final settings = await _repository.getSettings(userId);

    if (!settings.quietHoursEnabled) return false;

    final now = TimeOfDay.now();
    final start = settings.quietHoursStart;
    final end = settings.quietHoursEnd;

    return _isTimeBetween(now, start, end);
  }

  bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes < endMinutes) {
      // Normal range (e.g., 08:00 - 20:00)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Range spans midnight (e.g., 22:00 - 07:00)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  Future<void> updateQuietHours({
    required bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) async {
    final settings = await _repository.getSettings(_currentUserId);

    final updatedSettings = settings.copyWith(
      quietHoursEnabled: enabled,
      quietHoursStart: start ?? settings.quietHoursStart,
      quietHoursEnd: end ?? settings.quietHoursEnd,
    );

    await _repository.updateSettings(updatedSettings);

    // Sync to Supabase
    await _supabase.from('notification_settings').update({
      'quiet_hours_enabled': enabled,
      if (start != null) 'quiet_hours_start': '${start.hour}:${start.minute}',
      if (end != null) 'quiet_hours_end': '${end.hour}:${end.minute}',
    }).eq('user_id', _currentUserId);
  }
}
```

### Integration with NotificationService

**Modify all notification send functions to check quiet hours:**

```dart
class NotificationService {
  final QuietHoursService _quietHoursService;

  Future<void> send({
    required String userId,
    required String title,
    required String body,
    String? deepLink,
    bool bypassQuietHours = false,  // For critical alerts only
  }) async {
    // Check quiet hours (unless bypassed)
    if (!bypassQuietHours) {
      final inQuietHours = await _quietHoursService.isInQuietHours(userId);
      if (inQuietHours) {
        print('User $userId: In quiet hours, skipping notification');
        return;
      }
    }

    // Send notification (existing logic)
    await _fcmService.send(/* ... */);
  }
}
```

---

## UI/UX Design

### Weekly Summary Notification

**Lock Screen / Notification Shade:**
```
┌────────────────────────────────────────┐
│ 📊 Your Week in Review                 │
│ LifeOS • 8:00 AM                       │
├────────────────────────────────────────┤
│ 4 workouts, +5kg squat, 5 meditations, │
│ stress -23%                            │
│                                        │
│ [Tap to view full report]              │
└────────────────────────────────────────┘
```

### Quiet Hours Settings UI

**NotificationSettingsScreen:**
```dart
SwitchListTile(
  title: Text('Quiet Hours'),
  subtitle: Text('No notifications during quiet hours'),
  value: settings.quietHoursEnabled,
  onChanged: (value) => _updateQuietHours(enabled: value),
),

if (settings.quietHoursEnabled) ...[
  ListTile(
    title: Text('Start Time'),
    trailing: Text(_formatTime(settings.quietHoursStart)),
    onTap: () => _selectTime(context, isStart: true),
  ),
  ListTile(
    title: Text('End Time'),
    trailing: Text(_formatTime(settings.quietHoursEnd)),
    onTap: () => _selectTime(context, isStart: false),
  ),
],
```

**Time Picker:**
```dart
Future<void> _selectTime(BuildContext context, {required bool isStart}) async {
  final currentTime = isStart ? settings.quietHoursStart : settings.quietHoursEnd;

  final time = await showTimePicker(
    context: context,
    initialTime: currentTime,
  );

  if (time != null) {
    await _quietHoursService.updateQuietHours(
      enabled: settings.quietHoursEnabled,
      start: isStart ? time : null,
      end: !isStart ? time : null,
    );
  }
}
```

---

## Testing Strategy

### Unit Tests
- ✅ `isInQuietHours()` correctly handles normal range (08:00 - 20:00)
- ✅ `isInQuietHours()` correctly handles midnight-spanning range (22:00 - 07:00)
- ✅ `generateSummary()` formats report data correctly
- ✅ `send()` skips notification when in quiet hours (unless bypassed)

### Integration Tests
- ✅ E2E: Monday 8am → Weekly summary notification sent → Tap → Weekly Report Card opens
- ✅ E2E: User in quiet hours (11pm) → Morning check-in reminder scheduled for 8am → Skipped → Batched for 7am next day (after quiet hours end)
- ✅ E2E: User disables quiet hours → Notifications sent 24/7
- ✅ E2E: Critical alert (account security) → Sent even during quiet hours (bypassQuietHours=true)

### Critical Scenarios
1. **Weekly summary notification:**
   - Monday 8am → Weekly report generated (Story 6.6) → Notification sent → User taps → Opens Weekly Report Card

2. **Quiet hours (normal range):**
   - Quiet hours: 08:00 - 20:00
   - Current time: 10:00 → In quiet hours → Notification skipped
   - Current time: 21:00 → Outside quiet hours → Notification sent

3. **Quiet hours (midnight-spanning):**
   - Quiet hours: 22:00 - 07:00
   - Current time: 23:00 → In quiet hours (after 22:00) → Notification skipped
   - Current time: 02:00 → In quiet hours (before 07:00) → Notification skipped
   - Current time: 08:00 → Outside quiet hours → Notification sent

4. **Critical alert bypass:**
   - Quiet hours: ON (22:00 - 07:00)
   - Current time: 23:00
   - Critical alert (e.g., "Suspicious login from new device") → Sent with `bypassQuietHours=true` → User receives notification despite quiet hours

---

## Dependencies

- ✅ Epic 6 (Story 6.6): Weekly Summary Report generation
- ✅ Story 8.1: Push Notification Infrastructure (FCM setup)
- ✅ All other notification stories (8.2, 8.3, 8.4) depend on quiet hours implementation

---

## Definition of Done

- ✅ Code implemented and tested
- ✅ Weekly summary notification sent Monday 8am
- ✅ Quiet hours working (default: 10pm - 7am, customizable)
- ✅ Quiet hours apply to all notification types
- ✅ User can configure quiet hours in Settings (time picker UI)
- ✅ Critical alerts can bypass quiet hours
- ✅ Unit tests passing (100% coverage for quiet hours logic)
- ✅ Integration tests passing (E2E notification flows)
- ✅ Code reviewed and merged

---

**Story 8.5 created:** 2025-01-16
**Author:** Bob (BMAD Scrum Master)
**Epic:** 8 - Notifications & Engagement
**Estimated Effort:** 3 SP (6-8 hours)
