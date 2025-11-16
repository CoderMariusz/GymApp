# Story 5.3: High Stress + Heavy Workout → Suggest Light Session
**Epic:** 5 - Cross-Module Intelligence | **P0** | **2 SP** | **drafted**

## AC
1. ✅ Triggered when: Stress ≥4 (high) AND heavy workout scheduled (volume >80% of max)
2. ✅ Title: "High Stress Alert"
3. ✅ Description: "Your stress is high (4/5) and you have heavy leg day scheduled."
4. ✅ Recommendation: "Switch to upper body (light) OR rest day + meditate"
5. ✅ CTA: "Adjust Workout" → Opens Fitness with light template, "Meditate Instead" → Opens Mind with stress relief
6. ✅ Dismissable
7. ✅ AI learns from dismissals (future insights adapt)

**FRs:** FR77

## Tech
```typescript
// Pattern detection
if (stressScore >= 4 && scheduledWorkoutVolume > maxVolume * 0.8) {
  return {
    type: 'stress-workout',
    title: 'High Stress Alert',
    description: `Stress: ${stressScore}/5, Heavy workout scheduled.`,
    cta: 'Adjust Workout',
    priority: 'critical',
  };
}
```
**Dependencies:** 5.1, 5.2, Epic 3, Epic 4 | **Coverage:** 75%+
