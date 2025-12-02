# Life Coach Module - Product Requirements

<!-- AI-INDEX: life-coach, requirements, daily-planning, goals, ai-chat, check-ins, coaching -->

**Moduł:** Life Coach AI
**Cena:** FREE (base tier)
**Status:** ~75% zaimplementowane

---

## Spis Treści

1. [Module Overview](#1-module-overview)
2. [Functional Requirements](#2-functional-requirements)
3. [User Flows](#3-user-flows)
4. [AI Integration](#4-ai-integration)
5. [Cross-Module Integration](#5-cross-module-integration)
6. [Technical Notes](#6-technical-notes)

---

## 1. Module Overview

### Core Value Proposition

**Daily AI-powered planning** that considers sleep, mood, stress, and workouts to create personalized daily plans. Always FREE to drive adoption.

### Key Features

| Feature | Priority | Value |
|---------|----------|-------|
| Daily Plan Generation | P0 (MVP) | AI-generated based on context |
| Goal Tracking | P0 (MVP) | Max 3 goals (free), unlimited (premium) |
| Morning Check-in | P0 (MVP) | 1-minute ritual, builds habit |
| Evening Reflection | P0 (MVP) | Review day, plan tomorrow |
| AI Conversations | P0 (MVP) | 3-5/day (free), unlimited (premium) |
| Progress Dashboard | P0 (MVP) | Charts, streaks, achievements |

### Free vs Premium

| Feature | FREE | Premium |
|---------|------|---------|
| Daily Planning | ✅ | ✅ |
| Goals | Max 3 | Unlimited |
| AI Conversations/day | 3-5 (Llama) | Unlimited (Claude/GPT-4) |
| Check-ins | ✅ | ✅ |
| Progress Charts | ✅ | ✅ |
| Weekly Reports | ✅ | ✅ |

---

## 2. Functional Requirements

### 2.1 Daily Planning (FR6-FR10)

**FR6: Personalized Daily Plan Generation**
- System generates daily plan considering:
  - Sleep quality (from check-in or wearable)
  - Current mood (1-5 scale)
  - Energy level (1-5 scale)
  - Stress level (from Mind module)
  - Scheduled workouts
  - Active goals
  - Historical patterns
- Generated via AI (Llama for free, Claude/GPT-4 for premium)

**FR7: View Daily Plan on Home Screen**
- User sees daily plan immediately on app open
- Plan includes:
  - Prioritized tasks
  - Suggested activities
  - Time blocks (optional)
  - Cross-module suggestions (workout, meditation)

**FR8: Mark Plan Items Complete**
- User can mark items as:
  - Done ✓
  - Skipped →
  - Rescheduled ↷
- Progress percentage updates in real-time

**FR9: Manual Plan Adjustments**
- User can:
  - Add custom tasks
  - Remove suggested items
  - Reorder priorities
  - Change time allocations
- System learns from adjustments

**FR10: Adaptive Planning**
- System learns from:
  - Completion patterns
  - Manual adjustments
  - Time-of-day preferences
  - Day-of-week patterns
- Improves suggestions over time

### 2.2 Goal Tracking (FR11-FR17)

**FR11: Create Goals**
- User can create goals:
  - Free tier: Max 3 active goals
  - Premium: Unlimited goals
- Goal fields:
  - Title (required)
  - Description (optional)
  - Category (Fitness, Mental Health, Career, etc.)
  - Target date (optional)
  - Milestones (optional)

**FR12: Goal Categories**
- Predefined categories:
  - Fitness
  - Mental Health
  - Career
  - Relationships
  - Learning
  - Finance
  - Custom

**FR13: Target Dates**
- User can set deadline for goal
- System calculates pace needed
- Reminders as deadline approaches

**FR14: Progress Tracking**
- User can update progress (0-100%)
- Manual updates or auto-calculated from milestones
- Visual progress bar

**FR15: Daily Task Suggestions**
- System suggests daily tasks that contribute to goals
- AI-generated based on goal type and timeline
- Included in daily plan

**FR16: Goal Completion**
- User marks goal as completed
- Celebration animation
- Added to achievements history

**FR17: Archive/Delete Goals**
- User can archive goals (hidden but retained)
- User can delete goals (soft delete, 30-day recovery)

### 2.3 AI Conversations (FR18-FR24)

**FR18: Chat with AI Coach**
- User can have natural conversations for:
  - Motivation and encouragement
  - Advice on challenges
  - Problem-solving
  - Goal refinement
  - Emotional support

**FR19: Free Tier Limits**
- 3-5 AI conversations per day
- Uses Llama model (cost-efficient)
- Resets at midnight local time

**FR20: Premium Unlimited**
- Unlimited conversations
- Choice of AI: Claude or GPT-4
- Higher quality responses

**FR21: AI Personality**
- User can choose personality:
  - **Sage:** Calm, thoughtful, reflective
  - **Momentum:** Energetic, motivational, action-oriented
- Personality affects tone and suggestions

**FR22: Context Awareness**
- AI references:
  - Previous conversations
  - User's goals
  - Recent mood/stress data
  - Workout history
  - Check-in responses

**FR23: Conversation History**
- User can view past conversations
- Searchable by date/keyword
- Exportable

**FR24: Delete History**
- User can delete individual conversations
- User can clear all history
- GDPR compliance

### 2.4 Check-ins (FR25-FR29)

**FR25: Morning Check-in**
- 1-minute ritual (target)
- Questions:
  - Mood (1-5 + emoji)
  - Energy (1-5)
  - Sleep quality (1-5)
  - Optional note
- Triggers daily plan generation

**FR26: Evening Reflection**
- 2-minute ritual (target)
- Questions:
  - Day satisfaction (1-5)
  - Accomplishments (free text)
  - Tomorrow intentions
  - Gratitude (optional)
- Feeds next day's plan

**FR27: Check-in Data Usage**
- Data informs:
  - Daily plan generation
  - Cross-module insights
  - Weekly reports
  - AI conversation context

**FR28: Skip Without Penalty**
- User can skip check-ins
- No streak penalty for skipping
- System uses last known data

**FR29: Check-in Trends**
- Visualize mood/energy over time
- Weekly/monthly charts
- Correlations shown (sleep vs mood)

---

## 3. User Flows

### 3.1 Morning Ritual Flow

```
1. User opens app (morning)
2. If check-in not done → Morning check-in prompt
3. User rates: Mood (emoji tap), Energy (slider), Sleep (slider)
4. Optional: Add note
5. Tap "Generate My Day"
6. AI creates daily plan (2-3 seconds)
7. Plan displayed on home screen
8. User reviews and adjusts as needed
```

### 3.2 Evening Reflection Flow

```
1. User opens app (evening) OR notification at 8pm
2. Evening reflection prompt
3. User rates day satisfaction
4. Types accomplishments (optional)
5. Sets tomorrow intentions (optional)
6. Gratitude prompt (optional)
7. Day summary shown
8. "Ready for tomorrow" confirmation
```

### 3.3 Goal Creation Flow

```
1. User taps "Add Goal"
2. Enters goal title
3. Selects category
4. Sets target date (optional)
5. Adds milestones (optional)
6. AI suggests daily tasks
7. Goal created and added to tracking
```

### 3.4 AI Chat Flow

```
1. User taps chat icon
2. Free tier: Shows remaining conversations (e.g., "3/5 today")
3. User types message
4. AI responds (2-3 seconds)
5. Conversation continues
6. User can rate response (thumbs up/down)
7. Conversation saved to history
```

---

## 4. AI Integration

### 4.1 Model Selection

| Tier | Model | Response Time | Quality |
|------|-------|---------------|---------|
| FREE | Llama 3 (self-hosted) | <2s | Good |
| Premium | Claude 3.5 Sonnet | <3s | Excellent |
| Premium | GPT-4 Turbo | <4s | Excellent |

### 4.2 AI Prompts

**Daily Plan Generation:**
```
Given user context:
- Sleep: {sleep_quality}/5
- Mood: {mood}/5
- Energy: {energy}/5
- Active goals: {goals}
- Scheduled workout: {workout}
- Yesterday's completion: {completion_rate}%

Generate a personalized daily plan with:
1. Top 3 priorities
2. Suggested activities
3. Time recommendations
4. Cross-module suggestions
```

**Chat Personality - Sage:**
```
You are a calm, thoughtful life coach. Use gentle language,
ask reflective questions, encourage self-discovery.
Avoid pushy or aggressive motivation.
```

**Chat Personality - Momentum:**
```
You are an energetic, motivational life coach. Use action-oriented
language, celebrate wins, push for progress. Be encouraging but
not overwhelming.
```

### 4.3 Cost Management

| Model | Cost/1K tokens | Daily Budget |
|-------|----------------|--------------|
| Llama | ~$0 (self-hosted) | Unlimited |
| Claude | ~$0.003 | $0.50/user/month |
| GPT-4 | ~$0.01 | $1.00/user/month |

**Budget Rule:** AI costs <30% of revenue

---

## 5. Cross-Module Integration

### 5.1 Receives from Fitness

| Data | Usage |
|------|-------|
| Workout completed | Update daily plan |
| PRs achieved | Celebrate in plan |
| Volume/frequency | Adjust suggestions |

### 5.2 Receives from Mind

| Data | Usage |
|------|-------|
| Stress level | Adjust plan intensity |
| Mood trends | Adapt AI tone |
| Meditation completed | Update plan |

### 5.3 Sends to Other Modules

| Data | Recipient | Usage |
|------|-----------|-------|
| Daily goals | Fitness | Suggest workout |
| Stress detected | Mind | Suggest meditation |
| Sleep quality | Both | Adjust intensity |

---

## 6. Technical Notes

### Database Tables

```sql
-- Drift (SQLite) tables
daily_plans (id, user_id, date, plan_json, completed_items, created_at)
goals (id, user_id, title, description, category, target_date, progress, status)
goal_milestones (id, goal_id, title, completed, completed_at)
check_ins (id, user_id, type, mood, energy, sleep, notes, created_at)
ai_conversations (id, user_id, messages_json, model, created_at)
```

### Performance Requirements

| Metric | Target |
|--------|--------|
| Daily Plan Generation | <3s p95 |
| AI Chat Response | <3s p95 (Claude) |
| Check-in Submit | <500ms |
| Goal Operations | <200ms |

### Offline Support

| Feature | Offline? |
|---------|----------|
| View daily plan | ✅ (cached) |
| Mark items complete | ✅ |
| Morning check-in | ✅ |
| AI chat | ❌ (requires internet) |
| Goal tracking | ✅ |

---

## Powiązane Dokumenty

- [PRD-overview.md](./PRD-overview.md) - Przegląd produktu
- [ARCH-ai-infrastructure.md](../architecture/ARCH-ai-infrastructure.md) - AI infrastructure
- [epic-2-life-coach.md](../../2-MANAGEMENT/epics/epic-2-life-coach.md) - Life Coach stories
- [life-coach-module.md](../../3-ARCHITECTURE/system-design/life-coach-module.md) - Technical design

---

*FR6-FR29 | 24 Functional Requirements | ~75% implemented*
