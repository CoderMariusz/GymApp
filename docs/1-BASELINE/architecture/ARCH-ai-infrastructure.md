# AI Infrastructure - Architecture

<!-- AI-INDEX: ai, llm, claude, gpt-4, llama, orchestration, cross-module-intelligence, cmi, pattern-detection -->

**Wersja:** 2.0
**Decision:** D4 - Supabase Edge Functions for AI Orchestration

---

## Spis Treści

1. [Overview](#1-overview)
2. [AI Orchestration Layer](#2-ai-orchestration-layer)
3. [Cross-Module Intelligence](#3-cross-module-intelligence)
4. [Cost Management](#4-cost-management)
5. [AI Prompts](#5-ai-prompts)
6. [Implementation Details](#6-implementation-details)

---

## 1. Overview

### AI Strategy

**Hybrid AI Model** - Different models for different tiers:

| Tier | Model | Cost | Use Case |
|------|-------|------|----------|
| **FREE** | Llama 3 (self-hosted) | ~$0 | Basic conversations |
| **Standard** | Claude 3.5 Sonnet | $0.003/call | Quality conversations |
| **Premium** | GPT-4 Turbo | $0.01/call | Best quality |

### Key Principles

1. **Server-Side Routing:** API keys never exposed to client
2. **Cost Control:** Server-side quotas enforcement
3. **Flexibility:** Model changes without app update
4. **Fallback:** Degrade gracefully if API fails

---

## 2. AI Orchestration Layer

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            AI Service (lib/core/ai/)                │    │
│  │  - generateDailyPlan()                              │    │
│  │  - chat()                                           │    │
│  │  - generateInsight()                                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              ↓ POST /ai-orchestrator
┌─────────────────────────────────────────────────────────────┐
│              Supabase Edge Function                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           AI Orchestrator (Deno)                    │    │
│  │                                                     │    │
│  │  1. Authenticate user (JWT)                         │    │
│  │  2. Check subscription tier                         │    │
│  │  3. Check daily quota                               │    │
│  │  4. Route to appropriate model                      │    │
│  │  5. Return response + update quota                  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    AI Providers                              │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐               │
│  │  Llama 3  │  │  Claude   │  │  GPT-4    │               │
│  │  (Free)   │  │ (Standard)│  │ (Premium) │               │
│  └───────────┘  └───────────┘  └───────────┘               │
└─────────────────────────────────────────────────────────────┘
```

### Edge Function: AI Orchestrator

```typescript
// supabase/functions/ai-orchestrator/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from '@supabase/supabase-js'

serve(async (req) => {
  const { prompt, context, feature } = await req.json()

  // 1. Authenticate
  const authHeader = req.headers.get('Authorization')
  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
    global: { headers: { Authorization: authHeader } }
  })

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // 2. Check subscription tier
  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('tier')
    .eq('user_id', user.id)
    .single()

  const tier = subscription?.tier || 'free'

  // 3. Check daily quota
  const quota = await checkQuota(user.id, tier)
  if (!quota.allowed) {
    return new Response(JSON.stringify({
      error: 'quota_exceeded',
      message: 'Daily AI limit reached',
      resetAt: quota.resetAt
    }), { status: 429 })
  }

  // 4. Route to model
  let response
  switch (tier) {
    case 'plus':
      response = await callGPT4(prompt, context)
      break
    case 'pack':
    case 'single':
      response = await callClaude(prompt, context)
      break
    default:
      response = await callLlama(prompt, context)
  }

  // 5. Update quota
  await incrementQuota(user.id)

  return new Response(JSON.stringify(response))
})
```

### Quotas by Tier

| Tier | Daily AI Calls | Model |
|------|----------------|-------|
| FREE | 3-5 | Llama 3 |
| Single (2.99 EUR) | 20-30 | Claude |
| Pack (5.00 EUR) | 50 | Claude |
| Plus (7.00 EUR) | Unlimited (soft 200) | GPT-4 |

---

## 3. Cross-Module Intelligence

### CMI Pipeline

**Killer Feature:** Detect patterns across modules and generate insights.

```
1. DATA AGGREGATION (Event-Driven + Debounced)
   ↓
   Fitness: workout_completed → Trigger aggregation
   Mind: meditation_completed → Trigger aggregation
   Life Coach: tasks_updated → Trigger aggregation
   ↓
   Debounce 5 minutes → MetricsAggregationService
   ↓
   Insert/Update user_daily_metrics row

2. PATTERN DETECTION (Weekly Schedule)
   ↓
   Fetch last 30 days of user_daily_metrics
   ↓
   Calculate Pearson correlations for metric pairs:
   - (workout_completed, stress_level)
   - (meditation_completed, mood_score)
   - (stress_level, completion_rate)
   ↓
   Filter significant: |r| > 0.5 AND p-value < 0.05

3. AI INSIGHT GENERATION
   ↓
   For top 3 correlations:
   - Build prompt with 30-day context
   - Call AI API (GPT-4 for premium, Claude for standard)
   - Parse JSON response: { insight, recommendation }
   ↓
   Save to detected_patterns table

4. USER NOTIFICATION (FCM)
   ↓
   If confidence_score > 0.7:
   - Send FCM push notification
   - Deep link to CMI Dashboard
```

### Pattern Detection Example

**Detected Correlation:**
```json
{
  "metric_a": "workout_completed",
  "metric_b": "stress_level",
  "correlation_coefficient": -0.72,
  "p_value": 0.003,
  "sample_size": 28
}
```

**AI-Generated Insight:**
```json
{
  "insight": "Your stress drops 40% on days you work out 💪",
  "recommendation": "Try scheduling workouts before high-stress meetings"
}
```

**Push Notification:**
```
Title: "Pattern Detected 🧠"
Body: "Your stress drops 40% on days you work out 💪"
Action: "View Insight" → Deep link to /cmi-dashboard
```

### Correlation Pairs

| Metric A | Metric B | Expected Correlation |
|----------|----------|---------------------|
| workout_completed | stress_level | Negative |
| meditation_completed | mood_score | Positive |
| sleep_quality | workout_intensity | Positive |
| stress_level | completion_rate | Negative |
| meditation_duration | sleep_quality | Positive |

---

## 4. Cost Management

### Monthly Cost Analysis (10k users)

**Assumptions:**
- Pattern detection: 1x/user/week = 40k runs/month
- AI calls per run: 3 insights = 120k calls/month
- 20% paid users at avg $5/month

**Costs:**
```
AI API (Claude): 120k × $0.003 = $360/month
Revenue: 10k × 20% × $5 = $10,000/month
AI % of Revenue: 3.6% ✅ (well under 30% budget)
```

### Cost Control Mechanisms

1. **Quotas:** Server-side enforcement per tier
2. **Caching:** Cache common prompts/responses
3. **Batching:** Aggregate insights weekly, not daily
4. **Fallback:** Degrade to cheaper model if budget exceeded

### Budget Alert System

```typescript
// Alert if AI costs exceed threshold
async function checkAICostBudget() {
  const monthlySpend = await getMonthlyAISpend()
  const monthlyRevenue = await getMonthlyRevenue()
  const ratio = monthlySpend / monthlyRevenue

  if (ratio > 0.25) { // 25% warning
    await sendSlackAlert('AI costs at 25% of revenue')
  }
  if (ratio > 0.30) { // 30% critical
    await sendSlackAlert('AI costs exceeded 30% budget!')
    await reduceFreeQuotas()
  }
}
```

---

## 5. AI Prompts

### Daily Plan Generation

```
You are an AI life coach helping the user plan their day.

User Context:
- Sleep quality: {sleep_quality}/5
- Current mood: {mood}/5
- Energy level: {energy}/5
- Stress level: {stress_level}/5
- Active goals: {goals}
- Scheduled workout: {workout}
- Yesterday's completion: {completion_rate}%

Generate a personalized daily plan with:
1. Top 3 priorities for today
2. Suggested activities based on energy/mood
3. Time recommendations (morning/afternoon/evening)
4. Cross-module suggestions (workout, meditation if needed)

Respond in JSON format:
{
  "priorities": [{ "title": "", "reason": "" }],
  "activities": [{ "title": "", "time": "", "duration": "" }],
  "suggestions": [{ "module": "", "action": "" }]
}
```

### CMI Insight Generation

```
You are analyzing wellness patterns for a user.

Pattern detected:
- Metric A: {metric_a}
- Metric B: {metric_b}
- Correlation: {correlation} ({positive/negative})
- Confidence: {confidence}%
- Sample size: {sample_size} days

User's 30-day summary:
{summary_json}

Generate a user-friendly insight and actionable recommendation.

Respond in JSON format:
{
  "insight": "One sentence describing the pattern with emoji",
  "recommendation": "One actionable suggestion"
}
```

### Chat Personalities

**Sage (Calm):**
```
You are a calm, thoughtful life coach named Sage.
Use gentle language, ask reflective questions.
Encourage self-discovery over direct advice.
Avoid pushy or aggressive motivation.
```

**Momentum (Energetic):**
```
You are an energetic, motivational coach named Momentum.
Use action-oriented language, celebrate wins.
Push for progress while staying supportive.
Be encouraging but not overwhelming.
```

---

## 6. Implementation Details

### Flutter AI Service

```dart
// lib/core/ai/ai_service.dart

class AIService {
  final SupabaseClient _supabase;

  Future<DailyPlan> generateDailyPlan({
    required String userId,
    required UserContext context,
  }) async {
    final response = await _supabase.functions.invoke(
      'ai-orchestrator',
      body: {
        'feature': 'daily_plan',
        'prompt': _buildDailyPlanPrompt(context),
        'context': context.toJson(),
      },
    );

    if (response.status == 429) {
      throw AIQuotaExceededException(
        message: 'Daily AI limit reached',
        resetAt: DateTime.parse(response.data['resetAt']),
      );
    }

    return DailyPlan.fromJson(response.data);
  }

  Future<String> chat({
    required String message,
    required List<ChatMessage> history,
    required AIPersonality personality,
  }) async {
    final response = await _supabase.functions.invoke(
      'ai-orchestrator',
      body: {
        'feature': 'chat',
        'prompt': message,
        'context': {
          'history': history.map((m) => m.toJson()).toList(),
          'personality': personality.name,
        },
      },
    );

    return response.data['response'];
  }
}
```

### Riverpod Provider

```dart
// lib/core/ai/providers/ai_providers.dart

@riverpod
AIService aiService(AIServiceRef ref) {
  return AIService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<DailyPlan> dailyPlan(DailyPlanRef ref, String userId) async {
  final aiService = ref.watch(aiServiceProvider);
  final context = await ref.watch(userContextProvider(userId).future);

  return aiService.generateDailyPlan(
    userId: userId,
    context: context,
  );
}
```

---

## Powiązane Dokumenty

- [ARCH-overview.md](./ARCH-overview.md) - Architecture overview
- [ARCH-database-schema.md](./ARCH-database-schema.md) - CMI tables
- [PRD-life-coach-requirements.md](../product/PRD-life-coach-requirements.md) - AI chat requirements

---

*Hybrid AI Model | Server-Side Orchestration | <30% Cost Budget*
