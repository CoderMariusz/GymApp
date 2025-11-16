# Story 8.4: Cross-Module Insight Notifications (Max 1/day)

**Epic:** Epic 8 - Notifications & Engagement
**Sprint:** 8
**Story Points:** 3
**Priority:** P0
**Status:** Draft

---

## User Story

**As a** paid user
**I want** to receive push notifications for high-priority cross-module insights
**So that** I can act on important patterns without checking the app constantly

---

## Acceptance Criteria

- ✅ Push notification sent when high-confidence insight detected (confidence >0.7)
- ✅ **Max 1 insight notification per day** (prevents notification fatigue)
- ✅ Notification includes insight summary (e.g., "Your stress drops 40% on days you work out")
- ✅ Tapping notification opens Insight Card with full details and CTAs
- ✅ Deep link navigation: `lifeos://home/insights`
- ✅ User can disable insight notifications in Settings
- ✅ Quiet hours respected (no notifications during 10pm-7am by default)

---

## Technical Implementation

### Data Models

```dart
@freezed
class InsightNotification with _$InsightNotification {
  const factory InsightNotification({
    required String id,
    required String userId,
    required String insightId,
    required String title,
    required String body,
    required String deepLink,
    required DateTime sentAt,
  }) = _InsightNotification;
}
```

### Services

**NotificationService (Insight Notification)**
```dart
Future<void> sendInsightNotification({
  required String userId,
  required String insightText,
  required String insightId,
}) async {
  // 1. Check if user already received insight notification today
  final settings = await _settingsRepository.getSettings(userId);
  final today = DateUtils.dateOnly(DateTime.now());
  final lastSent = settings.lastInsightNotificationSent;

  if (lastSent != null && DateUtils.isSameDay(lastSent, today)) {
    print('User $userId: Already sent insight notification today');
    return;
  }

  // 2. Check if insight notifications enabled
  final notificationSettings = await _notificationSettingsRepository.getSettings(userId);
  if (!notificationSettings.insightNotificationsEnabled) {
    print('User $userId: Insight notifications disabled');
    return;
  }

  // 3. Check quiet hours
  if (_isInQuietHours(notificationSettings)) {
    print('User $userId: In quiet hours, skipping notification');
    return;
  }

  // 4. Send FCM notification
  await _fcmService.send(
    userId: userId,
    notification: FCMNotification(
      title: '💡 Pattern Detected',
      body: insightText,
      data: {
        'deep_link': 'lifeos://home/insights/$insightId',
        'type': 'insight',
        'insight_id': insightId,
      },
    ),
  );

  // 5. Update last sent timestamp
  await _settingsRepository.updateSettings(
    userId: userId,
    updates: {'last_insight_notification_sent': today},
  );

  // 6. Log notification
  await _logNotification(
    userId: userId,
    type: NotificationType.insightNotification,
    title: '💡 Pattern Detected',
    body: insightText,
    deepLink: 'lifeos://home/insights/$insightId',
  );
}
```

### Integration with Epic 5 (Cross-Module Intelligence)

**Edge Function: `detect-patterns` (from Epic 5)**
```typescript
// After generating insight (Story 5.1)
if (pattern.confidenceScore > 0.7) {
  await sendInsightNotification(supabase, userId, aiInsight.insight, pattern.id)
}

async function sendInsightNotification(supabase: any, userId: string, insightText: string, insightId: string) {
  // Check last sent (max 1/day)
  const { data: settings } = await supabase
    .from('user_settings')
    .select('last_insight_notification_sent')
    .eq('user_id', userId)
    .single()

  const today = new Date().toISOString().split('T')[0]
  if (settings?.last_insight_notification_sent === today) {
    console.log(`User ${userId}: Already sent insight notification today`)
    return
  }

  // Send notification via FCM
  await supabase.functions.invoke('send-notification', {
    body: {
      userId,
      title: '💡 Pattern Detected',
      body: insightText,
      deepLink: `lifeos://home/insights/${insightId}`,
      type: 'insight',
    },
  })

  // Update last sent
  await supabase
    .from('user_settings')
    .update({ last_insight_notification_sent: today })
    .eq('user_id', userId)
}
```

---

## UI/UX Design

### Notification Appearance

**Lock Screen / Notification Shade:**
```
┌────────────────────────────────────────┐
│ 💡 Pattern Detected                    │
│ LifeOS • now                           │
├────────────────────────────────────────┤
│ Your stress drops 40% on days you      │
│ work out 💪                            │
│                                        │
│ [Swipe to view insight]                │
└────────────────────────────────────────┘
```

**In-App Banner (if app is open):**
- Material banner slides down from top
- Same content as push notification
- Tap to navigate to Insight Card
- Auto-dismiss after 5 seconds (or manual dismiss)

### Deep Link Navigation

**Flow:**
1. User taps notification
2. App opens (or comes to foreground)
3. Navigate to: `lifeos://home/insights/{insightId}`
4. InsightCard displayed with full details
5. User can:
   - Swipe left to dismiss
   - Swipe right to save for later
   - Tap CTA to take action (e.g., "Adjust Workout")

---

## Testing Strategy

### Unit Tests
- ✅ `sendInsightNotification()` respects max 1/day limit
- ✅ `sendInsightNotification()` checks user settings (enabled/disabled)
- ✅ `sendInsightNotification()` respects quiet hours
- ✅ Deep link parsing: `lifeos://home/insights/{id}` → Navigate to correct screen

### Integration Tests
- ✅ E2E: Pattern detected (confidence >0.7) → Notification sent → Tap notification → Insight Card opens
- ✅ E2E: 2 high-confidence insights on same day → Only 1 notification sent
- ✅ E2E: User disables insight notifications → No notifications sent
- ✅ E2E: Notification sent during quiet hours → Skipped (or batched for next day)

### Critical Scenarios
1. **Max 1/day enforcement:**
   - Morning: Insight A generated (confidence 0.8) → Notification sent
   - Afternoon: Insight B generated (confidence 0.9) → Notification BLOCKED (already sent today)
   - Result: User receives only 1 notification per day

2. **Deep link navigation:**
   - Tap notification → App opens → Navigate to `lifeos://home/insights/{id}` → Insight Card displayed with correct data

3. **User settings:**
   - User disables insight notifications in Settings → Notification BLOCKED even if high-confidence insight detected

4. **Quiet hours:**
   - Insight generated at 11pm (quiet hours) → Notification skipped (optional: batch for 7am next day)

---

## Dependencies

- ✅ Epic 5 (Story 5.1): Insight Engine - detect-patterns Edge Function
- ✅ Epic 5 (Story 5.2): Insight Card UI - deep link navigation target
- ✅ Story 8.1: Push Notification Infrastructure (FCM setup)
- ✅ Story 8.5: Quiet Hours implementation

---

## Definition of Done

- ✅ Code implemented and tested
- ✅ Max 1 insight notification per day enforced
- ✅ Deep link navigation working
- ✅ User can disable in Settings
- ✅ Quiet hours respected
- ✅ Unit tests passing (100% coverage for notification logic)
- ✅ Integration tests passing (E2E notification flow)
- ✅ Code reviewed and merged

---

**Story 8.4 created:** 2025-01-16
**Author:** Bob (BMAD Scrum Master)
**Epic:** 8 - Notifications & Engagement
**Estimated Effort:** 3 SP (6-8 hours)
