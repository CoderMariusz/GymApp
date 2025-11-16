# Story 4.12: Cross-Module: Share Mood/Stress with Life Coach & Fitness
**Epic:** 4 - Mind & Emotion | **P0** | **2 SP** | **drafted**

## User Story
**As a** user logging mood/stress, **I want** other modules to use this data, **So that** I get personalized recommendations across the app.

## Acceptance Criteria
1. ✅ Mood/stress data queryable by Life Coach module
2. ✅ Life Coach daily plan considers mood: Low mood → Suggest gratitude, light day | High mood → Challenging tasks
3. ✅ Life Coach daily plan considers stress: High stress → Suggest meditation, rest | Low stress → Normal workload
4. ✅ Fitness module queries stress (Epic 3, Story 3.10)
5. ✅ Data sharing opt-in (user can disable in Privacy settings)

**FRs:** FR59, FR77, FR81 (Cross-Module Intelligence)

## Tech
```dart
// Cross-module API: Direct table queries (same Supabase DB)
Future<int?> getTodayMood(String userId) async {
  final result = await supabase
    .from('mood_logs')
    .select('mood_score')
    .eq('user_id', userId)
    .eq('date', today)
    .maybeSingle();
  return result?['mood_score'];
}
```
```sql
-- Privacy flag
ALTER TABLE user_settings ADD COLUMN share_data_across_modules BOOLEAN DEFAULT TRUE;
```
**Dependencies:** 4.3 (Mood/Stress), Epic 2 (Life Coach), Epic 3 (Fitness)
**Enables:** Story 2.2 (AI Daily Plan), Story 3.10 (Fitness stress query)
**Coverage:** 80%+
