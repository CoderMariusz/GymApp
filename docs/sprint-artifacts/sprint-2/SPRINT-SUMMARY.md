# Sprint 2 Summary - Life Coach MVP

**Sprint:** 2
**Epic:** Epic 2 - Life Coach MVP
**Status:** Drafted
**Sprint Duration:** 2-3 weeks (TBD)
**Team Velocity:** 28 SP (estimated)

---

## Sprint Goal

**"Deliver core Life Coach module with AI-powered daily planning, goal tracking, check-ins, and conversational coaching."**

By the end of Sprint 2, users should be able to:
- ✅ Complete morning check-in (mood, energy, sleep)
- ✅ Get AI-generated personalized daily plan
- ✅ Create and track up to 3 goals (free tier)
- ✅ Chat with AI life coach for motivation
- ✅ Complete evening reflection
- ✅ Build check-in streaks with freeze protection
- ✅ View progress dashboard (mood/energy/sleep trends)
- ✅ Manually adjust AI-generated plans
- ✅ Get AI goal suggestions
- ✅ Receive weekly summary report

---

## Sprint Backlog

| Story ID | Title | Priority | Effort (SP) | Status |
|----------|-------|----------|-------------|--------|
| 2.1 | Morning Check-in Flow | P0 | 3 | drafted |
| 2.2 | AI Daily Plan Generation | P0 | 5 | drafted |
| 2.3 | Goal Creation & Tracking | P0 | 3 | drafted |
| 2.4 | AI Conversational Coaching | P0 | 5 | drafted |
| 2.5 | Evening Reflection Flow | P0 | 2 | drafted |
| 2.6 | Streak Tracking (Check-ins) | P1 | 3 | drafted |
| 2.7 | Progress Dashboard | P1 | 3 | drafted |
| 2.8 | Daily Plan Manual Adjustment | P1 | 2 | drafted |
| 2.9 | Goal Suggestions (AI) | P2 | 2 | drafted |
| 2.10 | Weekly Summary Report | P1 | 3 | drafted |
| **TOTAL** | **10 stories** | - | **28 SP** | **drafted** |

---

## Story Dependencies

```
2.1 (Morning Check-in)
 ├─→ 2.2 (AI Daily Plan - uses check-in data)
 │    └─→ 2.8 (Manual Adjustment - edits AI plan)
 ├─→ 2.5 (Evening Reflection - similar UI pattern)
 │    └─→ 2.6 (Streak Tracking - both check-ins required)
 ├─→ 2.7 (Progress Dashboard - displays check-in trends)
 └─→ 2.10 (Weekly Report - aggregates check-in data)

2.3 (Goal Creation)
 ├─→ 2.2 (AI Daily Plan - references goals)
 ├─→ 2.4 (AI Chat - uses goals as context)
 └─→ 2.9 (Goal Suggestions - suggests new goals)
```

**Recommended Order:**
1. Story 2.1 (Morning Check-in) - **Foundation**
2. Story 2.3 (Goal Creation) - **Parallel with 2.2**
3. Story 2.2 (AI Daily Plan) - **Uses 2.1 data**
4. Story 2.4 (AI Conversational Coaching) - **Uses 2.3 goals**
5. Story 2.5 (Evening Reflection) - **Similar to 2.1**
6. Story 2.8 (Manual Adjustment) - **Requires 2.2**
7. Story 2.6 (Streak Tracking) - **Requires 2.1 + 2.5**
8. Story 2.7 (Progress Dashboard) - **Requires 2.1 data**
9. Story 2.9 (Goal Suggestions) - **Requires 2.3**
10. Story 2.10 (Weekly Report) - **Final, aggregates all data**

---

## Technical Highlights

### AI Integration (Multi-tier)
- **Free Tier:** Llama 3 (self-hosted) - 3-5 conversations/day
- **Standard Tier:** Claude 3 (Anthropic API) - Unlimited
- **Premium Tier:** GPT-4 (OpenAI API) - Unlimited

### AI Features
1. **Daily Plan Generation** (Story 2.2) - Personalized 5-8 tasks based on mood/energy/goals
2. **Conversational Coaching** (Story 2.4) - Context-aware chat with 2 personalities (Sage vs Momentum)
3. **Goal Suggestions** (Story 2.9) - AI analyzes user patterns to suggest relevant goals

### Database Schema (Sprint 2)
```sql
-- Check-ins
CREATE TABLE check_ins (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  date DATE UNIQUE,
  mood INT CHECK (mood BETWEEN 1 AND 5),
  energy INT CHECK (energy BETWEEN 1 AND 5),
  sleep_quality INT CHECK (sleep_quality BETWEEN 1 AND 5),
  note TEXT
);

-- Daily Plans
CREATE TABLE daily_plans (
  id UUID PRIMARY KEY,
  user_id UUID,
  date DATE UNIQUE,
  tasks JSONB, -- [{id, title, completed, time}]
  insight TEXT,
  ai_model TEXT
);

-- Goals
CREATE TABLE goals (
  id UUID PRIMARY KEY,
  user_id UUID,
  title TEXT,
  category TEXT,
  progress INT CHECK (progress BETWEEN 0 AND 100),
  status TEXT CHECK (status IN ('active', 'completed', 'archived'))
);

-- AI Conversations
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY,
  user_id UUID,
  session_id UUID,
  role TEXT CHECK (role IN ('user', 'assistant')),
  content TEXT,
  ai_model TEXT
);

-- Reflections
CREATE TABLE reflections (
  id UUID PRIMARY KEY,
  user_id UUID,
  date DATE UNIQUE,
  completion_rate INT,
  accomplishments TEXT,
  tomorrow_priorities TEXT,
  gratitude TEXT
);

-- Streaks
CREATE TABLE streaks (
  id UUID PRIMARY KEY,
  user_id UUID,
  type TEXT,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  freeze_used_this_week BOOLEAN DEFAULT FALSE
);

-- Weekly Reports
CREATE TABLE weekly_reports (
  id UUID PRIMARY KEY,
  user_id UUID,
  week_start_date DATE,
  report_data JSONB
);
```

---

## Non-Functional Requirements

- [ ] **NFR-AI1:** AI response time <3s (Llama), <4s (Claude/GPT-4)
- [ ] **NFR-AI2:** AI rate limiting (Free: 5/day, Premium: Unlimited)
- [ ] **NFR-P1:** Morning check-in completion <60 seconds
- [ ] **NFR-P2:** Daily plan generation <3s
- [ ] **NFR-UX1:** Haptic feedback on all emoji selections
- [ ] **NFR-S7:** GDPR - User can delete conversation history

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| AI costs exceed budget (€360/month for 10k users) | Medium | Critical | Implement strict rate limiting, use Llama for free tier |
| Story 2.2 (AI Daily Plan) complexity higher than estimated | Medium | High | Create fallback template if AI fails, simplify initial prompt |
| Streak freeze logic complex (weekly reset, automatic freeze) | Low | Medium | Write comprehensive unit tests, add manual freeze override |
| Cross-module data queries slow (check-in + stress + workouts) | Low | Medium | Use materialized views, cache daily aggregates |

---

## Testing Strategy

### Critical Scenarios
1. **Morning Check-in → AI Plan:** Complete check-in → Plan generated in <3s
2. **Goal Creation:** Create 3 goals (free tier limit) → 4th blocked with upgrade prompt
3. **AI Chat:** Free tier sends 5 messages → 6th blocked until next day
4. **Streak Tracking:** Miss morning check-in → Freeze auto-used → Streak maintained
5. **Weekly Report:** Monday 6am → Report generated → Push notification sent

**Coverage Target:** 80%+ unit, 75%+ widget, 100% critical flows

---

## Definition of Done

- [ ] All 10 stories implemented
- [ ] AI integration working (Llama + Claude + GPT-4)
- [ ] Rate limiting enforced (free tier)
- [ ] Streak freeze logic working
- [ ] Weekly report cron job scheduled
- [ ] All tests passing (80%+ coverage)
- [ ] Code reviewed and merged to develop

---

## Next Sprint

**Sprint 3: Fitness Coach MVP (Epic 3)**
- Smart Pattern Memory (killer feature!)
- Exercise library (500+ exercises)
- Workout logging with rest timer
- Progress charts and PRs

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
