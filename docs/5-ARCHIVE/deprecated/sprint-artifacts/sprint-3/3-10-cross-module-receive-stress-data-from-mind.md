# Story 3.10: Cross-Module: Receive Stress Data from Mind

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P1 | **Status:** ready-for-dev | **Effort:** 2 SP

---

## User Story
**As a** user with high stress
**I want** Fitness module to adjust workout intensity
**So that** I don't overtrain when stressed

---

## Acceptance Criteria
1. ✅ Fitness module queries Mind module for today's stress level (1-5)
2. ✅ If stress ≥4 (high) → Show workout adjustment suggestion
3. ✅ Suggestion: "High stress detected. Consider light session or rest day."
4. ✅ User can accept suggestion (loads light template) or dismiss
5. ✅ Suggestion shown as insight card (Mind purple → Fitness orange gradient)
6. ✅ Logged in workout notes: "Adjusted for high stress"

**FRs:** FR77, FR79, FR81 (Cross-Module Intelligence)

---

## Technical Implementation

### Query Stress Level
```dart
class CrossModuleService {
  Future<int?> getTodayStressLevel(String userId) async {
    final result = await supabase
      .from('stress_logs')
      .select('stress_score')
      .eq('user_id', userId)
      .eq('date', DateTime.now().toIso8601String().split('T')[0])
      .maybeSingle();

    return result?['stress_score'] as int?;
  }
}
```

### Insight Card
```dart
class StressAdjustmentInsight extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.orange],
        ),
      ),
      child: Column(
        children: [
          Text('💡 High Stress Detected'),
          Text('Your stress level is 4/5 today.'),
          Text('Consider a light session or rest day.'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => loadLightTemplate(),
                child: Text('Load Light Session'),
              ),
              TextButton(
                onPressed: () => dismiss(),
                child: Text('Continue as Planned'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Dependencies
**Prerequisites:** Epic 4 (Mind module with stress tracking)

**Coverage Target:** 75%+

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [3-10-cross-module-receive-stress-data-from-mind.context.xml](./3-10-cross-module-receive-stress-data-from-mind.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
