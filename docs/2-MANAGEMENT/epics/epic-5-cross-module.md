# Epic 5: Cross-Module Intelligence (Killer Feature)

<!-- AI-INDEX: epic-5, cross-module, cmi, intelligence, pattern-detection, insights, correlation, ai-insights -->

**Epic ID:** EPIC-5
**Status:** 🔄 ~25% Complete
**Priority:** P0 (MVP Critical - Differentiator)
**Stories:** 5

---

## Overview

| Aspect | Value |
|--------|-------|
| **Goal** | Detect patterns across modules and generate AI-powered insights |
| **Value** | KILLER FEATURE - only app where modules communicate (12-18 month lead) |
| **FRs Covered** | FR77-FR84 (Cross-Module Intelligence) |
| **Dependencies** | Epic 2 (Life Coach), Epic 3 (Fitness), Epic 4 (Mind) |
| **Sprint** | Sprint 5 |

---

## What Makes This Special

**No competitor has this:**
- Calm = only meditation
- Noom = only coaching
- Freeletics = only fitness
- **LifeOS = all modules TALK to each other**

**Examples:**
- "Your stress drops 40% on days you work out"
- "Best workouts happen after 8+ hours sleep"
- "Meditation before bed improves sleep quality 25%"

---

## User Stories

| ID | Story | Points | Status | Sprint |
|----|-------|--------|--------|--------|
| 5.1 | Insight Engine (Pattern Detection) | 13 | 🔄 In Progress | 5 |
| 5.2 | Insight Card UI (Swipeable) | 5 | ⏳ Planned | 5 |
| 5.3 | High Stress → Suggest Light Workout | 5 | ⏳ Planned | 5 |
| 5.4 | Poor Sleep → Suggest Afternoon Workout | 5 | ⏳ Planned | 5 |
| 5.5 | Sleep-Performance Correlation | 5 | ⏳ Planned | 5 |

**Total Points:** 33 | **Completed:** 8

---

## Story Details

### Story 5.1: Insight Engine (Pattern Detection)

**As a** data-driven user
**I want** the system to detect patterns in my behavior
**So that** I understand correlations between fitness, mood, and habits

**Acceptance Criteria:**
1. Aggregate daily metrics from all modules
2. Calculate Pearson correlations for metric pairs
3. Filter significant: |r| > 0.5 AND p-value < 0.05
4. Run weekly (not daily to save costs)
5. Store detected patterns
6. AI generates human-readable insight text
7. Max 1 insight notification per day
8. Insights shown on dashboard

**Metric Pairs:**
| Metric A | Metric B | Expected |
|----------|----------|----------|
| workout_completed | stress_level | Negative |
| meditation_completed | mood_score | Positive |
| sleep_quality | workout_intensity | Positive |
| stress_level | completion_rate | Negative |

---

### Story 5.2: Insight Card UI

**As a** user viewing insights
**I want** swipeable insight cards
**So that** I can act on recommendations

**Acceptance Criteria:**
1. Card-based UI on Home tab
2. Max 1 insight card per day
3. Swipe right: Save/Act
4. Swipe left: Dismiss
5. Tap: View details
6. Shows: Insight + Recommendation
7. "Learn more" → CMI Dashboard

---

### Story 5.3: High Stress → Suggest Light Workout

**As a** stressed user with heavy workout planned
**I want** the system to suggest lighter exercise
**So that** I don't overtrain when stressed

**Trigger:**
- Mind module: stress_level ≥ 4/5
- Fitness module: heavy workout scheduled

**Insight:**
"High stress detected. Consider a light yoga session instead of heavy lifting today."

---

### Story 5.4: Poor Sleep → Afternoon Workout

**As a** sleep-deprived user with morning workout
**I want** suggestion to reschedule
**So that** I optimize workout timing

**Trigger:**
- Life Coach: sleep_quality ≤ 2/5
- Fitness: morning workout planned

**Insight:**
"Sleep was rough last night. Afternoon workouts might be more effective today."

---

### Story 5.5: Sleep-Performance Correlation

**As a** user tracking both sleep and workouts
**I want** to see how sleep affects my lifts
**So that** I understand the importance of rest

**Insight:**
"Your best lifts happen after 8+ hours of sleep. Last 30 days show 40% better performance with good rest."

---

## Technical Architecture

### CMI Pipeline

```
1. DATA AGGREGATION (Event-Driven + Debounced)
   ↓
   Fitness: workout_completed → Trigger
   Mind: meditation_completed → Trigger
   Life Coach: tasks_updated → Trigger
   ↓
   Debounce 5 min → MetricsAggregationService
   ↓
   Update user_daily_metrics row

2. PATTERN DETECTION (Weekly Cron)
   ↓
   Fetch 30 days of user_daily_metrics
   ↓
   Calculate Pearson correlations
   ↓
   Filter significant patterns

3. AI INSIGHT GENERATION
   ↓
   For top 3 correlations:
   - Build prompt with context
   - Call AI API (Claude/GPT-4)
   - Parse response
   ↓
   Save to detected_patterns table

4. NOTIFICATION
   ↓
   If confidence > 0.7:
   - FCM push notification
   - Deep link to dashboard
```

---

## Database Schema

```sql
-- Aggregated daily metrics (shared across modules)
user_daily_metrics (
  user_id, date,
  -- Fitness
  workout_completed, workout_duration, sets_completed,
  -- Mind
  meditation_completed, mood_score, stress_level,
  -- Life Coach
  tasks_completed, completion_rate, ai_conversations_count,
  aggregated_at
)

-- Detected patterns
detected_patterns (
  user_id,
  pattern_type,  -- 'correlation', 'trend', 'anomaly'
  metric_a, metric_b,
  correlation_coefficient,  -- -1.0 to 1.0
  confidence_score,
  insight_text,
  recommendation_text,
  viewed_at, dismissed_at
)
```

---

## Cost Analysis

**10k users scenario:**
- Pattern detection: 40k runs/month
- AI calls: 120k calls/month
- Claude cost: $0.003/call

**Monthly cost:** $360
**Revenue (20% paid × $5):** $10,000
**AI % of revenue:** 3.6% ✅ (under 30% budget)

---

## Definition of Done

- [x] user_daily_metrics table created
- [x] Metrics aggregation service
- [ ] Pattern detection algorithm
- [ ] AI insight generation
- [ ] Insight card UI
- [ ] Push notifications for insights
- [ ] CMI Dashboard
- [ ] Performance: <1s pattern calculation
- [ ] 80% test coverage

---

**Source:** `docs/ecosystem/architecture.md` + `docs/ecosystem/epics.md`
