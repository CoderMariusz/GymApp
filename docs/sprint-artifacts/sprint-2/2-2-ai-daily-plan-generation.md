# Story 2.2: AI Daily Plan Generation

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P0 | **Status:** ready-for-dev | **Effort:** 5 SP

---

## User Story
**As a** user who completed morning check-in
**I want** the AI to generate a personalized daily plan
**So that** I know what to focus on today

---

## Acceptance Criteria
1. ✅ AI analyzes: mood, energy, sleep, stress (from Mind module), workouts (from Fitness)
2. ✅ AI generates 5-8 tasks/suggestions
3. ✅ Plan considers user's active goals
4. ✅ Plan adapts to mood (high energy = more tasks, low = lighter day)
5. ✅ Insight shown: "Your sleep was good (4/5). Great foundation for a productive day!"
6. ✅ Plan saves to database, visible on Home tab
7. ✅ Items can be marked complete (checkboxes)
8. ✅ AI model based on tier (Free: Llama, Standard: Claude, Premium: GPT-4)
9. ✅ Timeout handling: If AI fails, show fallback template
10. ✅ Generation time <3s (Llama), <4s (Claude/GPT-4)

**FRs:** FR6, FR7, FR10

---

## Technical Implementation

### Edge Function (AI Orchestration)
```typescript
// supabase/functions/generate-daily-plan/index.ts
Deno.serve(async (req) => {
  const { userId, mood, energy, sleepQuality } = await req.json();

  // Fetch context
  const goals = await getActiveGoals(userId);
  const workouts = await getScheduledWorkouts(userId);
  const stress = await getStressLevel(userId); // Cross-module

  // Select AI model based on tier
  const tier = await getUserTier(userId);
  const model = tier === 'free' ? 'llama-3' : tier === 'standard' ? 'claude-3' : 'gpt-4';

  // Generate plan
  const prompt = buildPrompt({ mood, energy, sleepQuality, goals, workouts, stress });
  const plan = await callAI(model, prompt);

  // Save to DB
  await saveDailyPlan(userId, plan);

  return Response.json({ plan });
});
```

### Database Schema
```sql
CREATE TABLE daily_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  tasks JSONB NOT NULL, -- [{id, title, completed, time}]
  insight TEXT,
  ai_model TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

### Fallback Template
```dart
final fallbackPlan = [
  {'title': 'Morning meditation (10 min)', 'time': '08:00'},
  {'title': 'Focus work block', 'time': '09:00'},
  {'title': 'Lunch break', 'time': '12:30'},
  {'title': 'Workout', 'time': '17:00'},
  {'title': 'Evening reflection', 'time': '20:00'},
];
```

---

## Dependencies
**Prerequisites:** Story 2.1 (Morning Check-in)
**Blocks:** Story 2.8 (Manual Adjustment)

**Coverage Target:** 75%+ (AI logic complex)

---

## Dev Agent Record
**Context File:** 2-2-ai-daily-plan-generation.context.xml

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
