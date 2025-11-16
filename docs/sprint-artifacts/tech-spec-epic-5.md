# Tech Spec - Epic 5: Cross-Module Intelligence

**Epic:** Epic 5 - Cross-Module Intelligence (Killer Feature)
**Author:** Winston (BMAD Architect)
**Date:** 2025-01-16
**Status:** Ready for Implementation
**Sprint:** TBD (Sprint 6)
**Stories:** 5 (5.1 - 5.5)
**Estimated Duration:** 10-12 days
**Dependencies:** Epic 2 (Life Coach), Epic 3 (Fitness), Epic 4 (Mind)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture Alignment](#2-architecture-alignment)
3. [Detailed Design](#3-detailed-design)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Dependencies & Integrations](#5-dependencies--integrations)
6. [Acceptance Criteria](#6-acceptance-criteria)
7. [Traceability Mapping](#7-traceability-mapping)
8. [Risks & Test Strategy](#8-risks--test-strategy)

---

## 1. Overview

### 1.1 Epic Goal

Implement cross-module intelligence where modules communicate to provide holistic optimization and insights. This is the **killer feature** that differentiates LifeOS from all competitors.

### 1.2 Value Proposition

**For users:** Personalized insights that no competitor offers:
- "High stress + heavy workout → suggest light session"
- "Sleep <6 hours + morning workout planned → suggest afternoon instead"
- "Your best lifts happen after 8+ hours sleep"
- "Meditation streak 21 days + stress dropping → Keep it up!"

**For business:**
- Unique differentiator (no competitor has this)
- Drives premium subscriptions (insights require paid modules)
- Increases retention (actionable insights are sticky)
- Cost-effective: 3.6% of revenue (well under 30% budget)

### 1.3 Scope Summary

**In Scope (MVP):**
- Insight engine (daily cron job, pattern detection)
- Insight card UI (swipeable, actionable CTAs)
- High stress + heavy workout → Suggest light session
- Poor sleep + morning workout → Suggest afternoon
- Sleep quality + workout performance correlation
- Push notifications for critical insights (max 1/day)
- Insight history (view dismissed insights)

**Out of Scope (P1/P2):**
- Machine learning models (use rule-based for MVP) (P1)
- Predictive insights ("burnout risk next week") (P2)
- Multi-module correlations (3+ modules) (P1)
- User feedback on insights (thumbs up/down) (P1)
- Custom insight rules (user-defined) (P2)

### 1.4 Success Criteria

**Functional:**
- ✅ Insight engine runs daily (6am cron job)
- ✅ 3 insight types working (stress/workout, sleep/workout, correlation)
- ✅ Insight cards displayed on Home tab
- ✅ CTAs open relevant module with pre-filled action
- ✅ Push notification sent for critical insights (max 1/day)

**Non-Functional:**
- ✅ Insight generation <5s (30-day data analysis)
- ✅ Pattern detection cost <€360/month (10k users)
- ✅ Insight card load <200ms
- ✅ Deep link navigation <500ms

**Business:**
- ✅ 50%+ paid users receive at least 1 insight/week
- ✅ Insight dismissal rate <40% (indicates value)
- ✅ CTA tap rate >20% (indicates actionability)

---

## 2. Architecture Alignment

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Cross-Module Intelligence Pipeline              │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│ 1. DATA AGGREGATION (Event-Driven + Debounced)              │
│                                                              │
│  Fitness Module → workout_completed                          │
│  Mind Module → meditation_completed                          │
│  Life Coach Module → tasks_updated                           │
│                          ↓                                   │
│  Debounce 5 min → MetricsAggregationService                  │
│                          ↓                                   │
│  Insert/Update user_daily_metrics row                        │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│ 2. PATTERN DETECTION (Daily Cron Job - 6am)                 │
│                                                              │
│  Fetch last 30 days of user_daily_metrics                    │
│                          ↓                                   │
│  Calculate Pearson correlations for metric pairs:            │
│  - (workout_completed, stress_level)                         │
│  - (meditation_completed, stress_level)                      │
│  - (stress_level, completion_rate)                           │
│  - (sleep_quality, workout_intensity)                        │
│                          ↓                                   │
│  Filter significant: |r| > 0.5 AND p-value < 0.05           │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│ 3. AI INSIGHT GENERATION (GPT-4/Claude)                     │
│                                                              │
│  For top 3 correlations:                                     │
│  - Build prompt with context (30-day summary)                │
│  - Call AI API (GPT-4 for premium, Claude for standard)     │
│  - Parse JSON response: { insight, recommendation }         │
│                          ↓                                   │
│  Save to detected_patterns table                             │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│ 4. USER NOTIFICATION (FCM)                                  │
│                                                              │
│  If confidence_score > 0.7 (high confidence):                │
│  - Send FCM push notification                                │
│  - Deep link to CMI Dashboard                                │
│  - Max 1 insight notification per day                        │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│ 5. INSIGHT CARD UI (Home Tab)                               │
│                                                              │
│  Insight card appears on Home tab (top of feed)              │
│  - Gradient background (Module A → Module B)                │
│  - Swipeable (dismiss, save, act)                            │
│  - CTA button → Opens relevant module                        │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Key Architectural Decisions

**AD-CMI1: Rule-Based Pattern Detection (MVP)**
- **Decision:** Use statistical correlations (Pearson r) instead of ML models
- **Rationale:** Faster to implement, easier to debug, sufficient for MVP
- **Future:** Add ML models in P1 for predictive insights

**AD-CMI2: Daily Cron Job (6am)**
- **Decision:** Run pattern detection once per day (not real-time)
- **Rationale:**
  - Cost control (120k AI API calls/month for 10k users = €360)
  - Insights don't need to be instant (daily is sufficient)
  - Batch processing more efficient
- **Implementation:** Supabase Edge Function scheduled via pg_cron

**AD-CMI3: Max 1 Insight Notification Per Day**
- **Decision:** Limit push notifications to 1 high-priority insight/day
- **Rationale:** Prevent notification fatigue, maintain user trust
- **Implementation:** Track last_insight_notification_sent in user_settings

**AD-CMI4: Shared Schema (user_daily_metrics)**
- **Decision:** All modules write to shared user_daily_metrics table
- **Rationale:** Enables cross-module analysis without complex joins
- **Implementation:** Decision D2 from Architecture (already implemented)

---

## 3. Detailed Design

### 3.1 Story 5.1: Insight Engine - Detect Patterns & Generate Insights

**Goal:** Daily cron job to detect patterns across modules and generate AI insights.

#### 3.1.1 Data Models

```dart
@freezed
class DetectedPattern with _$DetectedPattern {
  const factory DetectedPattern({
    required String id,
    required String userId,
    required PatternType patternType,    // correlation | trend | anomaly
    required String metricA,             // e.g., 'workout_completed'
    required String metricB,             // e.g., 'stress_level'
    required double correlationCoefficient,  // -1.0 to 1.0
    required double confidenceScore,     // 0.0 to 1.0
    required DateTime startDate,
    required DateTime endDate,
    required int sampleSize,
    required String insightText,         // AI-generated
    required String recommendationText,  // AI-generated
    DateTime? viewedAt,
    DateTime? dismissedAt,
    required DateTime createdAt,
  }) = _DetectedPattern;
}

enum PatternType { correlation, trend, anomaly }

@freezed
class InsightCard with _$InsightCard {
  const factory InsightCard({
    required String id,
    required String title,
    required String description,
    required String recommendation,
    required List<InsightAction> actions,
    required ModuleGradient gradient,    // e.g., Fitness Orange → Mind Purple
    required List<String> moduleIcons,   // ['🏋️', '🧠']
    required double confidenceScore,
    required DateTime createdAt,
  }) = _InsightCard;
}

@freezed
class InsightAction with _$InsightAction {
  const factory InsightAction({
    required String label,               // e.g., "Adjust Workout"
    required String deepLink,            // e.g., "lifeos://fitness/template/light"
    dynamic payload,                     // Optional data for pre-filling
  }) = _InsightAction;
}
```

#### 3.1.2 Database Schema

**Supabase: detected_patterns table**
```sql
CREATE TABLE detected_patterns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  pattern_type TEXT NOT NULL CHECK (pattern_type IN ('correlation', 'trend', 'anomaly')),
  metric_a TEXT NOT NULL,
  metric_b TEXT NOT NULL,
  correlation_coefficient DECIMAL(4,3),  -- -1.000 to 1.000
  confidence_score DECIMAL(3,2),         -- 0.00 to 1.00
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  sample_size INTEGER NOT NULL,
  insight_text TEXT,
  recommendation_text TEXT,
  viewed_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, metric_a, metric_b, end_date)
);

CREATE INDEX idx_patterns_user_active ON detected_patterns(user_id, created_at DESC)
  WHERE dismissed_at IS NULL;

ALTER TABLE detected_patterns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own patterns"
  ON detected_patterns FOR ALL USING (auth.uid() = user_id);
```

#### 3.1.3 Supabase Edge Function: `detect-patterns`

**File:** `supabase/functions/detect-patterns/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_KEY')!)

  // 1. Fetch all paid users (only paid users get insights)
  const { data: users } = await supabase
    .from('subscriptions')
    .select('user_id')
    .neq('tier', 'free')

  console.log(`Processing ${users?.length || 0} paid users`)

  for (const user of users || []) {
    try {
      await detectPatternsForUser(supabase, user.user_id)
    } catch (error) {
      console.error(`Error processing user ${user.user_id}:`, error)
    }
  }

  return new Response(JSON.stringify({ processed: users?.length || 0 }), { status: 200 })
})

async function detectPatternsForUser(supabase: any, userId: string) {
  // 1. Fetch last 30 days of user_daily_metrics
  const endDate = new Date()
  const startDate = new Date()
  startDate.setDate(startDate.getDate() - 30)

  const { data: metrics } = await supabase
    .from('user_daily_metrics')
    .select('*')
    .eq('user_id', userId)
    .gte('date', startDate.toISOString().split('T')[0])
    .lte('date', endDate.toISOString().split('T')[0])
    .order('date', { ascending: true })

  if (!metrics || metrics.length < 14) {
    console.log(`User ${userId}: Insufficient data (${metrics?.length || 0} days)`)
    return  // Need at least 14 days of data
  }

  // 2. Calculate correlations for metric pairs
  const metricPairs = [
    { a: 'workout_completed', b: 'stress_level' },
    { a: 'meditation_completed', b: 'stress_level' },
    { a: 'sleep_quality', b: 'workout_intensity' },
    { a: 'stress_level', b: 'completion_rate' },
  ]

  const significantPatterns = []

  for (const pair of metricPairs) {
    const correlation = calculatePearsonCorrelation(metrics, pair.a, pair.b)

    if (correlation && Math.abs(correlation.r) > 0.5 && correlation.pValue < 0.05) {
      significantPatterns.push({
        metricA: pair.a,
        metricB: pair.b,
        r: correlation.r,
        pValue: correlation.pValue,
        sampleSize: correlation.sampleSize,
      })
    }
  }

  if (significantPatterns.length === 0) {
    console.log(`User ${userId}: No significant patterns found`)
    return
  }

  // 3. Generate AI insights for top 3 patterns
  const top3 = significantPatterns.slice(0, 3)

  for (const pattern of top3) {
    const aiInsight = await generateAIInsight(supabase, userId, pattern, metrics)

    // 4. Save to detected_patterns
    await supabase.from('detected_patterns').upsert({
      user_id: userId,
      pattern_type: 'correlation',
      metric_a: pattern.metricA,
      metric_b: pattern.metricB,
      correlation_coefficient: pattern.r,
      confidence_score: 1 - pattern.pValue,  // Convert p-value to confidence (0.95 = high confidence)
      start_date: startDate.toISOString().split('T')[0],
      end_date: endDate.toISOString().split('T')[0],
      sample_size: pattern.sampleSize,
      insight_text: aiInsight.insight,
      recommendation_text: aiInsight.recommendation,
    })

    // 5. Send push notification if confidence > 0.7
    if ((1 - pattern.pValue) > 0.7) {
      await sendInsightNotification(supabase, userId, aiInsight.insight)
    }
  }
}

function calculatePearsonCorrelation(metrics: any[], metricA: string, metricB: string) {
  // Filter valid data points (both metrics must be non-null)
  const validPairs = metrics
    .filter(m => m[metricA] != null && m[metricB] != null)
    .map(m => ({ x: m[metricA], y: m[metricB] }))

  if (validPairs.length < 10) return null  // Need at least 10 data points

  const n = validPairs.length
  const sumX = validPairs.reduce((sum, p) => sum + p.x, 0)
  const sumY = validPairs.reduce((sum, p) => sum + p.y, 0)
  const sumXY = validPairs.reduce((sum, p) => sum + p.x * p.y, 0)
  const sumX2 = validPairs.reduce((sum, p) => sum + p.x * p.x, 0)
  const sumY2 = validPairs.reduce((sum, p) => sum + p.y * p.y, 0)

  const numerator = n * sumXY - sumX * sumY
  const denominator = Math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

  if (denominator === 0) return null

  const r = numerator / denominator

  // Calculate p-value (simplified t-test)
  const t = r * Math.sqrt((n - 2) / (1 - r * r))
  const pValue = 2 * (1 - tDistributionCDF(Math.abs(t), n - 2))

  return { r, pValue, sampleSize: n }
}

async function generateAIInsight(supabase: any, userId: string, pattern: any, metrics: any[]) {
  // Get user tier to determine AI model
  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('tier')
    .eq('user_id', userId)
    .single()

  const model = subscription?.tier === 'premium' ? 'gpt-4' : 'claude-3-sonnet'

  // Build prompt
  const prompt = `You are analyzing health and wellness data to provide actionable insights.

**Correlation Detected:**
- Metric A: ${pattern.metricA}
- Metric B: ${pattern.metricB}
- Correlation coefficient: ${pattern.r.toFixed(2)}
- Sample size: ${pattern.sampleSize} days

**30-Day Summary:**
${summarizeMetrics(metrics)}

**Task:** Generate a concise, actionable insight.

**Response format (JSON):**
{
  "insight": "Your [metric A] [increases/decreases] by X% on days you [metric B action]",
  "recommendation": "Try [specific actionable advice]"
}

**Constraints:**
- Insight: 1 sentence, max 100 chars
- Recommendation: 1 sentence, max 120 chars
- Use friendly, motivational tone
- Focus on actionable advice`

  // Call AI API
  const response = await callAI(model, prompt)

  return JSON.parse(response)
}

async function sendInsightNotification(supabase: any, userId: string, insightText: string) {
  // Check if user already received insight notification today
  const { data: settings } = await supabase
    .from('user_settings')
    .select('last_insight_notification_sent')
    .eq('user_id', userId)
    .single()

  const today = new Date().toISOString().split('T')[0]
  if (settings?.last_insight_notification_sent === today) {
    console.log(`User ${userId}: Already sent insight notification today`)
    return
  }

  // Send FCM notification
  await supabase.functions.invoke('send-notification', {
    body: {
      userId,
      title: '💡 Pattern Detected',
      body: insightText,
      deepLink: 'lifeos://home/insights',
    },
  })

  // Update last_insight_notification_sent
  await supabase
    .from('user_settings')
    .update({ last_insight_notification_sent: today })
    .eq('user_id', userId)
}
```

**Cron Job Setup (pg_cron)**
```sql
SELECT cron.schedule(
  'detect-patterns-daily',
  '0 6 * * *',  -- Every day at 6am
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/detect-patterns',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

### 3.2 Story 5.2: Insight Card UI (Swipeable, Actionable)

**Goal:** Display insight cards on Home tab with swipeable gestures and actionable CTAs.

#### 3.2.1 UI Components

**InsightCardWidget**
```dart
class InsightCardWidget extends StatelessWidget {
  final InsightCard insight;
  final VoidCallback onDismiss;
  final VoidCallback onSaveForLater;
  final Function(InsightAction) onActionTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(insight.id),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.close, color: Colors.red),
      ),
      secondaryBackground: Container(
        color: Colors.blue.shade100,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.bookmark, color: Colors.blue),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onDismiss();
        } else {
          onSaveForLater();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: insight.gradient.toLinearGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icons + Confidence
              Row(
                children: [
                  Text(
                    insight.moduleIcons.join(' '),
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.lightbulb_outline, color: Colors.white),
                  Spacer(),
                  Text(
                    '${(insight.confidenceScore * 100).toInt()}% confidence',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Insight Title
              Text(
                insight.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // Insight Description
              Text(
                insight.description,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 16),
              // Recommendation
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.recommendation,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Action Buttons
              Row(
                children: insight.actions.map((action) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => onActionTap(action),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: insight.gradient.primaryColor,
                        ),
                        child: Text(action.label, textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**InsightProvider (Riverpod)**
```dart
@riverpod
class InsightNotifier extends _$InsightNotifier {
  @override
  FutureOr<List<InsightCard>> build() async {
    return _loadActiveInsights();
  }

  Future<List<InsightCard>> _loadActiveInsights() async {
    final patterns = await _repository.getActivePatterns(_currentUserId);

    return patterns.map((pattern) => _buildInsightCard(pattern)).toList();
  }

  InsightCard _buildInsightCard(DetectedPattern pattern) {
    // Map pattern to UI-friendly insight card
    if (pattern.metricA == 'workout_completed' && pattern.metricB == 'stress_level') {
      return _buildStressWorkoutInsight(pattern);
    } else if (pattern.metricA == 'sleep_quality' && pattern.metricB == 'workout_intensity') {
      return _buildSleepWorkoutInsight(pattern);
    }
    // ... other patterns
  }

  InsightCard _buildStressWorkoutInsight(DetectedPattern pattern) {
    final correlation = pattern.correlationCoefficient;
    final stressDropPercent = (correlation.abs() * 100).toInt();

    return InsightCard(
      id: pattern.id,
      title: 'High Stress Alert',
      description: 'Your stress drops $stressDropPercent% on days you work out 💪',
      recommendation: 'Try scheduling workouts before high-stress meetings',
      actions: [
        InsightAction(
          label: 'Adjust Workout',
          deepLink: 'lifeos://fitness/template/light',
        ),
        InsightAction(
          label: 'Meditate Instead',
          deepLink: 'lifeos://mind/meditation',
        ),
      ],
      gradient: ModuleGradient.fitnessToMind,
      moduleIcons: ['🏋️', '🧠'],
      confidenceScore: pattern.confidenceScore,
      createdAt: pattern.createdAt,
    );
  }

  Future<void> dismissInsight(String insightId) async {
    await _repository.dismissPattern(insightId);
    ref.invalidateSelf();
  }

  Future<void> saveInsightForLater(String insightId) async {
    // Implementation: Add to saved insights list (P1 feature)
  }

  Future<void> handleAction(InsightAction action) async {
    // Navigate to deep link with payload
    await _router.push(action.deepLink, extra: action.payload);
  }
}
```

**Workflow:**
1. User opens Home tab
2. InsightProvider loads active insights (not dismissed)
3. InsightCardWidget displays at top of feed
4. User swipes left → Dismiss (mark as dismissed_at)
5. User swipes right → Save for later (P1 feature)
6. User taps CTA → Navigate to module with pre-filled action
7. Max 1 insight card shown per day (high priority only)

---

### 3.3 Story 5.3: High Stress + Heavy Workout → Suggest Light Session

**Goal:** Detect when user has high stress AND heavy workout scheduled, suggest light session.

#### 3.3.1 Pattern Detection Logic

**Trigger Conditions:**
- `stress_level >= 4` (high stress from Mind module)
- `workout_scheduled = true` AND `workout_intensity > 0.8` (heavy workout)

**Insight Example:**
```json
{
  "title": "High Stress Alert",
  "description": "Your stress level is high today (4/5) and you have a heavy leg day scheduled.",
  "recommendation": "Switch to upper body (light) OR take a rest day + meditate",
  "actions": [
    {
      "label": "Adjust Workout",
      "deepLink": "lifeos://fitness/template/light",
      "payload": { "templateId": "bodyweight-light" }
    },
    {
      "label": "Meditate Instead",
      "deepLink": "lifeos://mind/meditation?category=stressRelief",
      "payload": { "category": "stressRelief" }
    }
  ]
}
```

**Implementation:**
- Check daily metrics: `user_daily_metrics.stress_level` and `workouts.scheduled_at`
- If both conditions met, generate insight card
- Priority: HIGH (show immediately, send push notification)

---

### 3.4 Story 5.4: Poor Sleep + Morning Workout → Suggest Afternoon

**Goal:** Detect poor sleep + morning workout, suggest rescheduling to afternoon.

#### 3.4.1 Pattern Detection Logic

**Trigger Conditions:**
- `sleep_quality < 3` (poor sleep from Life Coach check-in)
- `workout_scheduled_time < 12:00` (morning workout)

**Insight Example:**
```json
{
  "title": "Sleep Alert",
  "description": "You slept poorly last night (2/5). Your morning workout might be tough.",
  "recommendation": "Move workout to afternoon (4-6pm) when energy rebounds",
  "actions": [
    {
      "label": "Reschedule Workout",
      "deepLink": "lifeos://life-coach/daily-plan/edit",
      "payload": { "action": "rescheduleWorkout", "newTime": "16:00" }
    },
    {
      "label": "Keep Morning Slot",
      "deepLink": "lifeos://fitness/workout/start"
    }
  ]
}
```

**AI Learning:**
- Track user choice (reschedule vs keep)
- If user consistently keeps morning slot despite poor sleep, reduce frequency of this insight

---

### 3.5 Story 5.5: Sleep Quality + Workout Performance Correlation

**Goal:** Show correlation between sleep quality and workout performance (PRs).

#### 3.5.1 Pattern Detection Logic

**Trigger Conditions:**
- 30+ days of data available (sleep + workouts)
- Correlation between `sleep_quality` and `max_weight` (PRs) significant (|r| > 0.5)

**Insight Example:**
```json
{
  "title": "Sleep is Your Secret Weapon!",
  "description": "Your best lifts happen after 8+ hours sleep. When you sleep <6 hours, strength drops 15%.",
  "recommendation": "Tonight's goal: Sleep meditation + 8 hours rest",
  "actions": [
    {
      "label": "Start Sleep Meditation",
      "deepLink": "lifeos://mind/meditation?category=sleep"
    },
    {
      "label": "View Chart",
      "deepLink": "lifeos://insights/correlation/sleep-vs-performance"
    }
  ]
}
```

**Data Visualization:**
- Scatter plot: X-axis = sleep quality, Y-axis = max weight lifted
- Trend line showing correlation
- Tap to expand chart (full-screen)

---

## 4. Non-Functional Requirements

### 4.1 Performance

| NFR | Target | Implementation |
|-----|--------|----------------|
| **NFR-CMI1** | Insight generation <5s | Batch processing, pre-calculated correlations |
| **NFR-CMI2** | Insight card load <200ms | Local cache, Riverpod state |
| **NFR-CMI3** | Deep link navigation <500ms | Pre-load module, optimized routing |

### 4.2 Cost

| NFR | Target | Implementation |
|-----|--------|----------------|
| **NFR-SC4** | AI costs <30% revenue | Hybrid AI, batch processing (10k users = €360/month) |

**Cost Breakdown (10k users):**
- Pattern detection runs: 1x per user per week = 40k runs/month
- AI API calls: 3 insights per run = 120k calls/month
- Claude cost: $0.003 per call (200 tokens avg)
- **Monthly cost:** 120k × $0.003 = **$360/month**
- **Revenue:** 10k × 20% × $5 = $10,000/month
- **AI cost percentage:** 3.6% ✅ (well under 30% budget)

### 4.3 Reliability

| NFR | Target | Implementation |
|-----|--------|----------------|
| **NFR-R1** | Insight delivery 95%+ | FCM reliability + in-app fallback |
| **NFR-R2** | No duplicate insights | UNIQUE constraint on detected_patterns |

---

## 5. Dependencies & Integrations

### 5.1 Internal Dependencies

| Dependency | Type | Reason |
|------------|------|--------|
| **Epic 2: Life Coach** | Hard | Sleep quality, daily plan, check-ins |
| **Epic 3: Fitness** | Hard | Workout data, intensity, PRs |
| **Epic 4: Mind** | Hard | Mood, stress, meditation data |
| **user_daily_metrics table** | Hard | Shared schema for cross-module analysis |
| **Epic 8: Notifications** | Hard | Push notifications for insights |

### 5.2 External Dependencies

| Service | Purpose | Risk Mitigation |
|---------|---------|-----------------|
| **AI APIs (Claude/GPT-4)** | Insight generation | Timeout handling, fallback templates |
| **Supabase Edge Functions** | Cron job, pattern detection | Retry on failure, error logging |
| **FCM** | Push notifications | Graceful degradation, in-app fallback |

---

## 6. Acceptance Criteria

### 6.1 Story-Level Acceptance

**Story 5.1: Insight Engine**
- ✅ Daily cron job runs at 6am
- ✅ Pattern detection working (Pearson correlation)
- ✅ AI insight generation functional (Claude/GPT-4)
- ✅ Insights saved to detected_patterns table
- ✅ Push notification sent for high-confidence insights (max 1/day)

**Story 5.2: Insight Card UI**
- ✅ Insight card displayed on Home tab
- ✅ Swipeable (dismiss left, save right)
- ✅ Actionable CTAs open relevant module
- ✅ Deep link navigation with pre-filled data
- ✅ Gradient background (module colors)

**Story 5.3: High Stress + Heavy Workout**
- ✅ Pattern detected when stress ≥4 AND heavy workout scheduled
- ✅ Insight card shown with 2 CTAs (Adjust Workout, Meditate Instead)
- ✅ CTA opens Fitness with light template OR Mind with stress meditation

**Story 5.4: Poor Sleep + Morning Workout**
- ✅ Pattern detected when sleep <3 AND morning workout scheduled
- ✅ Insight suggests rescheduling to afternoon
- ✅ CTA opens Life Coach daily plan editor

**Story 5.5: Sleep + Workout Correlation**
- ✅ Correlation calculated (30+ days data)
- ✅ Insight shows correlation (e.g., "Best lifts after 8+ hours sleep")
- ✅ Scatter plot visualization
- ✅ CTA opens sleep meditation

### 6.2 Epic-Level Acceptance

**Functional:**
- ✅ All 5 stories implemented
- ✅ 3 insight types working (stress/workout, sleep/workout, correlation)
- ✅ Insight engine runs daily (cron job)
- ✅ Push notifications sent (max 1/day)

**Non-Functional:**
- ✅ Insight generation <5s
- ✅ AI cost <€360/month (10k users)
- ✅ Insight card load <200ms
- ✅ Deep link navigation <500ms

**Business:**
- ✅ 50%+ paid users receive at least 1 insight/week
- ✅ Insight dismissal rate <40%
- ✅ CTA tap rate >20%

---

## 7. Traceability Mapping

### 7.1 FRs to Stories

| FR Range | Feature | Stories | Status |
|----------|---------|---------|--------|
| FR77-FR81 | Cross-Module Intelligence | 5.1-5.5 | ✅ |
| FR82-FR84 | Insight UI & Notifications | 5.2 | ✅ |

**Coverage:** 8/8 FRs covered (FR77-FR84) ✅

---

## 8. Risks & Test Strategy

### 8.1 Identified Risks

| Risk ID | Description | Probability | Impact | Mitigation |
|---------|-------------|-------------|--------|------------|
| **RISK-CMI1** | AI costs exceed budget (€360/month) | Low | Critical | Strict quotas, batch processing, monitor usage |
| **RISK-CMI2** | Insights not actionable (low CTA tap rate) | Medium | High | User research, A/B test CTA wording |
| **RISK-CMI3** | Notification fatigue (users disable notifications) | Medium | Medium | Max 1 insight/day, high-quality insights only |
| **RISK-CMI4** | Insufficient data (users don't log consistently) | Medium | High | Encourage logging, free tier features |

### 8.2 Test Strategy

**Unit Tests (70%):**
- Pearson correlation calculation
- Pattern detection logic (stress/workout, sleep/workout)
- AI prompt generation
- Insight card mapping

**Integration Tests (30%):**
- E2E: Complete workout → Log mood → Insight generated → Push notification sent
- E2E: Dismiss insight → Marked as dismissed, not shown again
- E2E: Tap CTA → Navigate to module with pre-filled data

**Critical Scenarios:**
1. **High stress + heavy workout:** Log stress ≥4 → Schedule heavy workout → Insight shown
2. **Poor sleep + morning workout:** Check-in with sleep <3 → Morning workout planned → Insight suggests afternoon
3. **Sleep correlation:** 30 days of sleep + workout data → Correlation calculated → Insight generated
4. **Max 1 notification/day:** 2 high-confidence insights → Only 1 push notification sent
5. **Deep link navigation:** Tap "Adjust Workout" CTA → Opens Fitness with light template pre-loaded

**Coverage Target:** 80%+ unit, 75%+ integration, 100% critical flows

---

## Document Status

✅ **COMPLETE** - Ready for implementation

**Version:** 1.0
**Last Updated:** 2025-01-16
**Next Steps:**
1. Dev agent implements Story 5.1 (Insight Engine)
2. Iterate through 5 stories sequentially
3. Final epic validation and merge

---

**Epic 5 Tech Spec created by Winston (BMAD Architect)**
**Total Pages:** 38
**Estimated Implementation:** 10-12 days
**Dependencies:** Epic 2, 3, 4 (all modules) ✅ Complete
