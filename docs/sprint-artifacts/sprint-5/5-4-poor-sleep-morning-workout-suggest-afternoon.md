# Story 5.4: Poor Sleep + Morning Workout → Suggest Afternoon
**Epic:** 5 - Cross-Module Intelligence | **P0** | **2 SP** | **drafted**

## AC
1. ✅ Triggered when: Sleep quality <3 (poor) AND morning workout scheduled (<12pm)
2. ✅ Title: "Sleep Alert"
3. ✅ Description: "You slept poorly (2/5). Your morning workout might be tough."
4. ✅ Recommendation: "Move workout to afternoon (4-6pm) when energy rebounds"
5. ✅ CTA: "Reschedule Workout" → Opens Life Coach daily plan editor
6. ✅ Alternative: "Keep Morning Slot"
7. ✅ AI learns from choice

**FRs:** FR78

## Tech
```typescript
if (sleepQuality < 3 && workoutTime < 12) {
  return {
    type: 'sleep-workout',
    title: 'Sleep Alert',
    description: 'Poor sleep + morning workout = tough session.',
    cta: 'Reschedule Workout',
    priority: 'normal',
  };
}
```
**Dependencies:** 5.1, 5.2, Epic 2, Epic 3 | **Coverage:** 75%+
