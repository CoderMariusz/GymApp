# TABLES - Drift Schema (Skrócone)

> Szybki przegląd tabel lokalnej bazy danych (SQLite/Drift).
> Pełna dokumentacja: `docs/1-BASELINE/architecture/ARCH-database-schema.md`

---

## Quick Reference

| Tabela | Plik | Główne pola |
|--------|------|-------------|
| WorkoutTemplates | sprint0 | name, exercises (JSON), category, difficulty |
| Subscriptions | sprint0 | tier, status, stripeSubscriptionId |
| Streaks | sprint0 | streakType, currentStreak, longestStreak |
| AiConversations | sprint0 | messages (JSON), aiModel, conversationType |
| MoodLogs | sprint0 | moodScore, energyScore, stressLevel |
| UserDailyMetrics | sprint0 | [fitness + mind + life coach metrics] |
| MentalHealthScreenings | sprint0 | screeningType (GAD-7/PHQ-9), score, severity |
| CheckIns | batch1 | type (morning/evening), energyLevel, mood |
| WorkoutLogs | batch1 | workoutName, duration, isQuickLog |
| ExerciseSets | batch1 | exerciseName, weight, reps, setNumber |
| Goals | batch3 | title, category, targetValue, currentValue |
| GoalProgress | batch3 | goalId, value, timestamp |
| BodyMeasurements | batch3 | weight, bodyFat, chest, waist, hips... |
| DailyPlans | life_coach | date, tasksJson, dailyTheme |
| ChatSessions | life_coach | messagesJson, title, isArchived |

---

## Tabele szczegółowo

### CheckIns (Morning/Evening)
```dart
// lib/core/database/tables/batch1_tables.dart
id, userId, timestamp, type ('morning'|'evening')
// Morning: energyLevel, mood, intentions, gratitude
// Evening: productivityRating, wins, improvements, tomorrowFocus
// Common: tags (JSON), notes, isSynced
```

### WorkoutLogs + ExerciseSets
```dart
// WorkoutLogs
id, userId, timestamp, workoutName, duration (seconds), isQuickLog

// ExerciseSets (FK: workoutLogId)
id, workoutLogId, exerciseName, setNumber, weight, reps, duration, restTime
```

### Goals + GoalProgress
```dart
// Goals
id, userId, title, description, category
targetDate, targetValue, unit ('kg'|'reps'|'days')
currentValue, completionPercentage, isCompleted
priority (1-5), isArchived

// GoalProgress (FK: goalId)
id, goalId, timestamp, value, notes
```

### DailyPlans
```dart
id, date, tasksJson, dailyTheme, motivationalQuote
source (0=ai_generated, 1=manual), metadataJson
```

### ChatSessions
```dart
id, userId, title, messagesJson
lastMessageAt, isArchived
```

### UserDailyMetrics (Cross-Module Intelligence)
```dart
id, userId, date
// Fitness
workoutCompleted, workoutDurationMinutes, caloriesBurned, setsCompleted, workoutIntensity
// Mind
meditationCompleted, meditationDurationMinutes, moodScore, stressLevel, journalEntriesCount
// Life Coach
dailyPlanGenerated, tasksCompleted, tasksTotal, completionRate, aiConversationsCount
```

### Streaks
```dart
id, userId, streakType ('workout'|'meditation'|'check_in')
currentStreak, longestStreak, lastCompletedDate, freezeUsed
```

### Subscriptions
```dart
id, userId, tier ('free'|'mind'|'fitness'|'three_pack'|'plus')
status ('active'|'trial'|'canceled'|'past_due')
stripeCustomerId, stripeSubscriptionId
trialEndsAt, currentPeriodStart, currentPeriodEnd
```

---

## Sync Metadata (wszystkie tabele)

```dart
BoolColumn isSynced => withDefault(false)
DateTimeColumn lastSyncedAt => nullable()
```

---

## Regenerowanie kodu Drift

```bash
dart run build_runner build
```

---

*Pliki: sprint0_tables.dart, batch1_tables.dart, batch3_tables.dart, life_coach_tables.dart*
