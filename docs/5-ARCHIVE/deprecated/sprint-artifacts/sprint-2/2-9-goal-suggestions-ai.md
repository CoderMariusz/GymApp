# Story 2.9: Goal Suggestions (AI)

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P2 | **Status:** ready-for-dev | **Effort:** 2 SP

---

## User Story
**As a** user unsure what goals to set
**I want** the AI to suggest relevant goals
**So that** I can get started quickly

---

## Acceptance Criteria
1. ✅ "Suggest goals" button on Goals screen (when <3 goals)
2. ✅ AI analyzes: onboarding choice, mood trends, activity patterns
3. ✅ AI suggests 3-5 relevant goals with rationale
4. ✅ Examples: "Lose 5kg" (fitness-focused), "Meditate 5 days/week" (stress-focused)
5. ✅ Tap suggestion to create goal (pre-filled form)
6. ✅ Dismiss suggestion
7. ✅ Suggestions refresh daily

**FRs:** FR15

---

## Technical Implementation

### AI Prompt
```typescript
const prompt = `
User profile:
- Onboarding choice: ${user.journey} // "fitness", "stress", "life"
- Avg mood: ${avgMood}/5
- Avg stress: ${avgStress}/5
- Current goals: ${goals.map(g => g.title)}

Suggest 3 personalized goals. Format:
[
  {"title": "...", "category": "...", "rationale": "..."},
  ...
]
`;
```

### Suggestion Cache
```sql
CREATE TABLE goal_suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  suggestions JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours'
);
```

---

## Dependencies
**Prerequisites:** Story 2.3 (Goals must exist)

**Coverage Target:** 75%+

---

## Dev Agent Record
**Context File:** 2-9-goal-suggestions-ai.context.xml

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
