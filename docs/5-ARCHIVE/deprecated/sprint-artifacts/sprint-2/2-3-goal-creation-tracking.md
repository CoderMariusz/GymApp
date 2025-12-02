# Story 2.3: Goal Creation & Tracking

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P0 | **Status:** ready-for-dev | **Effort:** 3 SP

---

## User Story
**As a** user with personal goals
**I want** to create and track up to 3 goals (free tier)
**So that** I can measure progress toward what matters

---

## Acceptance Criteria
1. ✅ Create goals from Home → Goals screen
2. ✅ Form: Title (60 chars), Category (Fitness/Mental/Career/etc.), Target date, Description (500 chars)
3. ✅ Free tier: Max 3 goals, Premium: Unlimited
4. ✅ Progress tracked manually (% slider, 0-100%)
5. ✅ Mark goal complete → Celebration animation (confetti)
6. ✅ Archive goal (removed from active, kept in history)
7. ✅ Delete goal (confirmation required)
8. ✅ Goals on Home tab (progress bars)
9. ✅ AI daily plan references active goals

**FRs:** FR11-FR17

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  target_date DATE,
  description TEXT,
  progress INT DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_goals_user_status ON goals(user_id, status);
```

### Free Tier Limit
```dart
Future<Result<Goal>> createGoal(Goal goal) async {
  final tier = await ref.read(userTierProvider.future);
  if (tier == 'free') {
    final activeCount = await countActiveGoals();
    if (activeCount >= 3) {
      return Failure('Free tier: Max 3 goals. Upgrade for unlimited.');
    }
  }
  return await repository.saveGoal(goal);
}
```

---

## Dependencies
**Prerequisites:** Epic 1
**Enables:** Story 2.9 (Goal Suggestions)

**Coverage Target:** 80%+

---

## Dev Agent Record
**Context File:** 2-3-goal-creation-tracking.context.xml

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
