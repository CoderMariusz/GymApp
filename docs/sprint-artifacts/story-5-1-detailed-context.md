# Story 5.1 - Detailed Technical Context
## Insight Engine: Detect Patterns & Generate Insights

**Story:** 5.1
**Epic:** 5 - Cross-Module Intelligence
**Sprint:** 5
**Story Points:** 5
**Complexity:** ⭐⭐⭐⭐⭐ (Highest)

---

## 🎯 Executive Summary

The Insight Engine is the **killer feature** of LifeOS - it analyzes cross-module data to detect meaningful patterns and generate AI-powered actionable insights. This is what differentiates LifeOS from all competitors (Calm, Headspace, Noom, Freeletics).

**Key Challenge:** Detect statistically significant correlations across modules (stress/workout, sleep/performance) and generate insights that users will actually act on, while keeping costs under €360/month for 10k users.

---

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   INSIGHT ENGINE PIPELINE                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: DATA AGGREGATION (Event-Driven)                         │
│                                                                  │
│  Module Event → Debounced (5 min) → MetricsAggregationService   │
│                                   ↓                              │
│                    UPDATE user_daily_metrics table               │
│                                                                  │
│  Example:                                                        │
│  - Workout completed → workout_completed = true                  │
│  - Meditation done → meditation_completed = true                 │
│  - Morning check-in → mood_score = 4, stress_level = 3          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: PATTERN DETECTION (Daily Cron - 6am)                    │
│                                                                  │
│  For each paid user:                                             │
│    1. Fetch last 30 days of user_daily_metrics                   │
│    2. Calculate Pearson correlations for metric pairs            │
│    3. Filter significant: |r| > 0.5 AND p-value < 0.05          │
│    4. Rank by |r| * confidence                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: AI INSIGHT GENERATION (GPT-4/Claude)                    │
│                                                                  │
│  For top 3 patterns:                                             │
│    1. Build context prompt (30-day summary + pattern)            │
│    2. Call AI API (tier-based: Claude/GPT-4)                     │
│    3. Parse JSON: { insight, recommendation }                    │
│    4. Save to detected_patterns table                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: NOTIFICATION (FCM)                                      │
│                                                                  │
│  If confidence_score > 0.7:                                      │
│    - Check: Max 1 notification per day                           │
│    - Send FCM push notification                                  │
│    - Deep link: lifeos://home/insights/{id}                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧮 DETAILED ALGORITHM: Pearson Correlation

### Mathematical Foundation

**Pearson Correlation Coefficient (r):**

```
r = Σ[(xi - x̄)(yi - ȳ)] / √[Σ(xi - x̄)² × Σ(yi - ȳ)²]

Where:
- xi, yi = paired observations
- x̄, ȳ = means of x and y
- r ∈ [-1, 1]
  - r = 1: Perfect positive correlation
  - r = 0: No correlation
  - r = -1: Perfect negative correlation
```

**Statistical Significance (p-value):**

```
t = r × √[(n - 2) / (1 - r²)]

Where:
- n = sample size
- t follows Student's t-distribution with (n-2) degrees of freedom
- p-value = 2 × P(T > |t|)  [two-tailed test]
```

**Significance Threshold:**
- |r| > 0.5 (moderate to strong correlation)
- p-value < 0.05 (95% confidence)
- n ≥ 10 (minimum sample size)

---

## 💻 IMPLEMENTATION

### TypeScript: Pearson Correlation Function

```typescript
interface CorrelationResult {
  r: number              // Correlation coefficient (-1 to 1)
  pValue: number         // Statistical significance (0 to 1)
  sampleSize: number     // Number of valid data points
  isSignificant: boolean // |r| > 0.5 AND p < 0.05
}

function calculatePearsonCorrelation(
  metrics: UserDailyMetric[],
  metricA: string,
  metricB: string
): CorrelationResult | null {

  // 1. Extract valid pairs (both metrics non-null)
  const validPairs = metrics
    .filter(m => m[metricA] != null && m[metricB] != null)
    .map(m => ({ x: Number(m[metricA]), y: Number(m[metricB]) }))

  const n = validPairs.length

  // 2. Validate minimum sample size
  if (n < 10) {
    console.log(`Insufficient data: ${n} points (need ≥10)`)
    return null
  }

  // 3. Calculate means
  const meanX = validPairs.reduce((sum, p) => sum + p.x, 0) / n
  const meanY = validPairs.reduce((sum, p) => sum + p.y, 0) / n

  // 4. Calculate sums for Pearson formula
  let sumXY = 0      // Σ[(xi - x̄)(yi - ȳ)]
  let sumX2 = 0      // Σ(xi - x̄)²
  let sumY2 = 0      // Σ(yi - ȳ)²

  for (const pair of validPairs) {
    const dx = pair.x - meanX
    const dy = pair.y - meanY

    sumXY += dx * dy
    sumX2 += dx * dx
    sumY2 += dy * dy
  }

  // 5. Calculate correlation coefficient
  const denominator = Math.sqrt(sumX2 * sumY2)

  if (denominator === 0) {
    console.log('Zero variance detected (constant values)')
    return null
  }

  const r = sumXY / denominator

  // 6. Calculate p-value (t-test)
  const t = r * Math.sqrt((n - 2) / (1 - r * r))
  const pValue = calculateTwoTailedPValue(t, n - 2)

  // 7. Determine significance
  const isSignificant = Math.abs(r) > 0.5 && pValue < 0.05

  return { r, pValue, sampleSize: n, isSignificant }
}

// Helper: Two-tailed p-value for Student's t-distribution
function calculateTwoTailedPValue(t: number, df: number): number {
  // Approximation using error function (erf)
  // For production, use a proper statistics library like jStat

  const absT = Math.abs(t)

  // Simplified approximation for df > 20
  if (df > 20) {
    const z = absT
    const p = 1 - normalCDF(z)  // One-tailed
    return 2 * p  // Two-tailed
  }

  // For smaller df, use lookup table or library
  // This is a simplified version
  return tDistributionCDF(absT, df)
}

// Normal CDF approximation (for large samples)
function normalCDF(z: number): number {
  const t = 1 / (1 + 0.2316419 * Math.abs(z))
  const d = 0.3989423 * Math.exp(-z * z / 2)
  const probability = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))

  return z > 0 ? 1 - probability : probability
}
```

---

## 🔍 METRIC PAIRS TO ANALYZE

```typescript
const METRIC_PAIRS = [
  // Stress correlations
  { a: 'workout_completed', b: 'stress_level', expectedSign: 'negative' },
  { a: 'meditation_completed', b: 'stress_level', expectedSign: 'negative' },
  { a: 'stress_level', b: 'completion_rate', expectedSign: 'negative' },

  // Sleep correlations
  { a: 'sleep_quality', b: 'workout_intensity', expectedSign: 'positive' },
  { a: 'sleep_quality', b: 'mood_score', expectedSign: 'positive' },
  { a: 'sleep_quality', b: 'energy_level', expectedSign: 'positive' },

  // Mood correlations
  { a: 'workout_completed', b: 'mood_score', expectedSign: 'positive' },
  { a: 'meditation_completed', b: 'mood_score', expectedSign: 'positive' },

  // Energy correlations
  { a: 'energy_level', b: 'tasks_completed', expectedSign: 'positive' },
  { a: 'energy_level', b: 'workout_intensity', expectedSign: 'positive' },
]
```

---

## 🤖 AI PROMPT ENGINEERING

### Prompt Template for Insight Generation

```typescript
function buildInsightPrompt(
  pattern: CorrelationResult,
  metricA: string,
  metricB: string,
  metricsData: UserDailyMetric[]
): string {

  const summary = summarizeMetrics(metricsData)

  return `You are a wellness AI analyzing health and fitness data to provide actionable insights.

**Detected Correlation:**
- Metric A: ${formatMetricName(metricA)}
- Metric B: ${formatMetricName(metricB)}
- Correlation: r = ${pattern.r.toFixed(2)} (${pattern.r > 0 ? 'positive' : 'negative'})
- Confidence: ${((1 - pattern.pValue) * 100).toFixed(1)}% (p = ${pattern.pValue.toFixed(4)})
- Sample size: ${pattern.sampleSize} days

**30-Day Data Summary:**
${summary}

**Example Pattern:**
${generateExamplePattern(metricA, metricB, pattern.r, metricsData)}

**Task:**
Generate a concise, actionable insight for the user.

**Response Format (JSON):**
{
  "insight": "[One sentence, max 100 chars, friendly tone. Quantify the impact if possible.]",
  "recommendation": "[One sentence, max 120 chars, specific actionable advice.]"
}

**Guidelines:**
1. Use "you/your" (personal)
2. Quantify impact when possible (e.g., "40% drop", "+5kg")
3. Be motivational but realistic
4. Focus on actionable advice
5. Avoid medical claims
6. Use emojis sparingly (max 1-2)

**Examples:**
- Good: "Your stress drops 40% on days you work out 💪"
- Bad: "There is a correlation between exercise and stress reduction"

**JSON Response:**`
}

function formatMetricName(metric: string): string {
  const names: Record<string, string> = {
    'workout_completed': 'Workout Completion',
    'stress_level': 'Stress Level (1-5)',
    'sleep_quality': 'Sleep Quality (1-5)',
    'mood_score': 'Mood Score (1-5)',
    'meditation_completed': 'Meditation Completion',
    'completion_rate': 'Daily Plan Completion Rate',
    'workout_intensity': 'Workout Intensity (0-1)',
    'energy_level': 'Energy Level (1-5)',
    'tasks_completed': 'Tasks Completed',
  }
  return names[metric] || metric
}

function summarizeMetrics(metrics: UserDailyMetric[]): string {
  const lines = []

  // Workout summary
  const workouts = metrics.filter(m => m.workout_completed).length
  lines.push(`- Workouts: ${workouts}/${metrics.length} days`)

  // Meditation summary
  const meditations = metrics.filter(m => m.meditation_completed).length
  lines.push(`- Meditations: ${meditations}/${metrics.length} days`)

  // Stress average
  const stressValues = metrics.filter(m => m.stress_level != null).map(m => m.stress_level)
  if (stressValues.length > 0) {
    const avgStress = (stressValues.reduce((a, b) => a + b, 0) / stressValues.length).toFixed(1)
    lines.push(`- Avg Stress: ${avgStress}/5`)
  }

  // Mood average
  const moodValues = metrics.filter(m => m.mood_score != null).map(m => m.mood_score)
  if (moodValues.length > 0) {
    const avgMood = (moodValues.reduce((a, b) => a + b, 0) / moodValues.length).toFixed(1)
    lines.push(`- Avg Mood: ${avgMood}/5`)
  }

  return lines.join('\n')
}

function generateExamplePattern(
  metricA: string,
  metricB: string,
  r: number,
  metrics: UserDailyMetric[]
): string {
  // Find best example (highest difference)
  const withA = metrics.filter(m => m[metricA] === true || m[metricA] > 0)
  const withoutA = metrics.filter(m => m[metricA] === false || m[metricA] === 0)

  const avgWithA = average(withA.map(m => m[metricB]).filter(v => v != null))
  const avgWithoutA = average(withoutA.map(m => m[metricB]).filter(v => v != null))

  const diff = avgWithA - avgWithoutA
  const percentChange = Math.abs((diff / avgWithoutA) * 100).toFixed(0)

  return `When ${formatMetricName(metricA)} is TRUE: ${formatMetricName(metricB)} = ${avgWithA.toFixed(1)}
When ${formatMetricName(metricA)} is FALSE: ${formatMetricName(metricB)} = ${avgWithoutA.toFixed(1)}
Difference: ${diff > 0 ? '+' : ''}${diff.toFixed(1)} (${percentChange}% ${diff > 0 ? 'increase' : 'decrease'})`
}

function average(values: number[]): number {
  return values.length > 0 ? values.reduce((a, b) => a + b, 0) / values.length : 0
}
```

---

## 🏗️ SUPABASE EDGE FUNCTION IMPLEMENTATION

### File: `supabase/functions/detect-patterns/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_KEY')!
  )

  console.log('🔍 Pattern Detection Started:', new Date().toISOString())

  try {
    // 1. Fetch all paid users (only paid users get insights)
    const { data: subscriptions } = await supabase
      .from('subscriptions')
      .select('user_id, tier')
      .neq('tier', 'free')
      .eq('status', 'active')

    console.log(`📊 Processing ${subscriptions?.length || 0} paid users`)

    let processed = 0
    let patternsFound = 0
    let errors = 0

    for (const subscription of subscriptions || []) {
      try {
        const result = await detectPatternsForUser(
          supabase,
          subscription.user_id,
          subscription.tier
        )

        processed++
        patternsFound += result.patternsFound

        if (processed % 100 === 0) {
          console.log(`Progress: ${processed}/${subscriptions.length} users`)
        }
      } catch (error) {
        console.error(`❌ Error processing user ${subscription.user_id}:`, error.message)
        errors++
      }
    }

    console.log(`✅ Pattern Detection Complete:
- Processed: ${processed} users
- Patterns Found: ${patternsFound}
- Errors: ${errors}`)

    return new Response(
      JSON.stringify({
        success: true,
        processed,
        patternsFound,
        errors
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Fatal error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

async function detectPatternsForUser(
  supabase: any,
  userId: string,
  tier: string
): Promise<{ patternsFound: number }> {

  // 1. Fetch last 30 days of metrics
  const endDate = new Date()
  const startDate = new Date()
  startDate.setDate(startDate.getDate() - 30)

  const { data: metrics, error } = await supabase
    .from('user_daily_metrics')
    .select('*')
    .eq('user_id', userId)
    .gte('date', startDate.toISOString().split('T')[0])
    .lte('date', endDate.toISOString().split('T')[0])
    .order('date', { ascending: true })

  if (error) throw new Error(`Failed to fetch metrics: ${error.message}`)

  if (!metrics || metrics.length < 14) {
    console.log(`User ${userId}: Insufficient data (${metrics?.length || 0} days, need ≥14)`)
    return { patternsFound: 0 }
  }

  console.log(`User ${userId}: Analyzing ${metrics.length} days of data`)

  // 2. Calculate correlations for all metric pairs
  const significantPatterns = []

  for (const pair of METRIC_PAIRS) {
    const correlation = calculatePearsonCorrelation(metrics, pair.a, pair.b)

    if (correlation && correlation.isSignificant) {
      significantPatterns.push({
        metricA: pair.a,
        metricB: pair.b,
        ...correlation
      })
    }
  }

  if (significantPatterns.length === 0) {
    console.log(`User ${userId}: No significant patterns found`)
    return { patternsFound: 0 }
  }

  console.log(`User ${userId}: Found ${significantPatterns.length} significant pattern(s)`)

  // 3. Rank patterns by strength
  significantPatterns.sort((a, b) => {
    const scoreA = Math.abs(a.r) * (1 - a.pValue)
    const scoreB = Math.abs(b.r) * (1 - b.pValue)
    return scoreB - scoreA
  })

  // 4. Generate AI insights for top 3 patterns
  const top3 = significantPatterns.slice(0, 3)

  for (const pattern of top3) {
    try {
      const insight = await generateAIInsight(supabase, userId, tier, pattern, metrics)

      // 5. Save to detected_patterns
      await supabase.from('detected_patterns').upsert({
        user_id: userId,
        pattern_type: 'correlation',
        metric_a: pattern.metricA,
        metric_b: pattern.metricB,
        correlation_coefficient: pattern.r,
        confidence_score: 1 - pattern.pValue,
        start_date: startDate.toISOString().split('T')[0],
        end_date: endDate.toISOString().split('T')[0],
        sample_size: pattern.sampleSize,
        insight_text: insight.insight,
        recommendation_text: insight.recommendation,
      }, {
        onConflict: 'user_id,metric_a,metric_b,end_date'
      })

      // 6. Send notification if high confidence
      if ((1 - pattern.pValue) > 0.7) {
        await sendInsightNotification(supabase, userId, insight.insight)
      }

    } catch (error) {
      console.error(`Failed to generate insight for pattern ${pattern.metricA}/${pattern.metricB}:`, error.message)
    }
  }

  return { patternsFound: top3.length }
}

async function generateAIInsight(
  supabase: any,
  userId: string,
  tier: string,
  pattern: any,
  metrics: any[]
): Promise<{ insight: string, recommendation: string }> {

  // Select AI model based on tier
  const model = tier === 'premium' ? 'gpt-4' : 'claude-3-sonnet'

  // Build prompt
  const prompt = buildInsightPrompt(pattern, pattern.metricA, pattern.metricB, metrics)

  // Call AI API
  const response = await callAI(model, prompt)

  // Parse JSON response
  try {
    const result = JSON.parse(response)
    return {
      insight: result.insight || 'Pattern detected',
      recommendation: result.recommendation || 'Keep tracking your progress'
    }
  } catch (error) {
    console.error('Failed to parse AI response:', error)
    return {
      insight: 'We detected an interesting pattern in your data',
      recommendation: 'Continue your current routine'
    }
  }
}

async function callAI(model: string, prompt: string): Promise<string> {
  if (model === 'gpt-4') {
    return await callOpenAI(prompt)
  } else {
    return await callClaude(prompt)
  }
}

async function callOpenAI(prompt: string): Promise<string> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
    },
    body: JSON.stringify({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7,
      max_tokens: 200,
    }),
  })

  const data = await response.json()
  return data.choices[0].message.content
}

async function callClaude(prompt: string): Promise<string> {
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': Deno.env.get('ANTHROPIC_API_KEY')!,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-3-sonnet-20240229',
      max_tokens: 200,
      messages: [{ role: 'user', content: prompt }],
    }),
  })

  const data = await response.json()
  return data.content[0].text
}

async function sendInsightNotification(
  supabase: any,
  userId: string,
  insightText: string
) {
  // Check if already sent today (max 1/day)
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
      type: 'insight',
    },
  })

  // Update last sent
  await supabase
    .from('user_settings')
    .update({ last_insight_notification_sent: today })
    .eq('user_id', userId)
}
```

---

## ⚙️ CRON JOB SETUP

### PostgreSQL: pg_cron Extension

```sql
-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule pattern detection (daily at 6am)
SELECT cron.schedule(
  'detect-patterns-daily',
  '0 6 * * *',  -- Cron expression: Every day at 6am
  $$
  SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/detect-patterns',
    headers := jsonb_build_object(
      'Authorization', 'Bearer YOUR_SERVICE_KEY',
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb
  )
  $$
);

-- View scheduled jobs
SELECT * FROM cron.job;

-- Unschedule (if needed)
SELECT cron.unschedule('detect-patterns-daily');
```

---

## 💰 COST OPTIMIZATION

### Current Cost Analysis (10k users, 20% paid)

```
Assumptions:
- Paid users: 10,000 × 20% = 2,000
- Pattern detection: 1x per week per user = 2,000 runs/week = ~8,000 runs/month
- Top 3 patterns per run = 3 insights
- AI calls: 8,000 × 3 = 24,000 calls/month

Claude Pricing:
- Model: claude-3-sonnet
- Cost: $0.003 per API call (input: 200 tokens, output: 100 tokens)
- Monthly: 24,000 × $0.003 = $72/month

GPT-4 Pricing (Premium tier):
- Assume 10% of paid users = 200 premium users
- AI calls: (200 / 2,000) × 24,000 = 2,400 calls/month
- Cost: 2,400 × $0.01 = $24/month

Total AI Cost: $72 + $24 = $96/month
Revenue: 2,000 × $5 avg = $10,000/month
AI Cost %: $96 / $10,000 = 0.96% ✅ (well under 30% budget!)
```

### Optimization Strategies

**1. Run Pattern Detection Weekly (Not Daily)**
- Current: Daily detection for all users (expensive)
- Optimized: Weekly detection (1x per week)
- Cost reduction: 7x less AI calls = $96/month → $14/month

**2. Cache Pattern Results (30 days)**
- Store detected patterns for 30 days
- Only re-run if new data significantly different
- Cost reduction: ~50% (avoid duplicate insights)

**3. Batch AI Calls**
- Group multiple users in single API call (if possible)
- Use streaming responses for faster feedback

**4. Use Cheaper Models for Simple Patterns**
- Simple patterns (obvious correlations) → Use template-based insights (no AI call)
- Complex patterns → Use AI
- Cost reduction: ~30%

---

## 🧪 TESTING STRATEGY

### Unit Tests

```typescript
// Test: Pearson correlation calculation
describe('calculatePearsonCorrelation', () => {
  it('should calculate correct correlation for perfect positive relationship', () => {
    const metrics = [
      { workout_completed: 1, stress_level: 1 },
      { workout_completed: 2, stress_level: 2 },
      { workout_completed: 3, stress_level: 3 },
      { workout_completed: 4, stress_level: 4 },
      { workout_completed: 5, stress_level: 5 },
    ]

    const result = calculatePearsonCorrelation(metrics, 'workout_completed', 'stress_level')

    expect(result).not.toBeNull()
    expect(result!.r).toBeCloseTo(1.0, 2)  // Perfect positive correlation
    expect(result!.isSignificant).toBe(false)  // Only 5 points (need ≥10)
  })

  it('should calculate correct correlation for perfect negative relationship', () => {
    const metrics = Array.from({ length: 15 }, (_, i) => ({
      workout_completed: i + 1,
      stress_level: 15 - i
    }))

    const result = calculatePearsonCorrelation(metrics, 'workout_completed', 'stress_level')

    expect(result).not.toBeNull()
    expect(result!.r).toBeCloseTo(-1.0, 2)  // Perfect negative correlation
    expect(result!.pValue).toBeLessThan(0.05)
    expect(result!.isSignificant).toBe(true)
  })

  it('should return null for insufficient data', () => {
    const metrics = [
      { workout_completed: 1, stress_level: 3 },
      { workout_completed: 0, stress_level: 4 },
    ]

    const result = calculatePearsonCorrelation(metrics, 'workout_completed', 'stress_level')

    expect(result).toBeNull()  // Only 2 points (need ≥10)
  })

  it('should handle missing data correctly', () => {
    const metrics = [
      { workout_completed: 1, stress_level: null },  // Missing stress
      { workout_completed: 1, stress_level: 3 },
      { workout_completed: 0, stress_level: 4 },
      { workout_completed: null, stress_level: 2 },  // Missing workout
      { workout_completed: 1, stress_level: 3 },
    ]

    const result = calculatePearsonCorrelation(metrics, 'workout_completed', 'stress_level')

    expect(result).toBeNull()  // Only 2 valid pairs
  })
})

// Test: AI prompt generation
describe('buildInsightPrompt', () => {
  it('should generate correct prompt for workout/stress correlation', () => {
    const pattern = { r: -0.72, pValue: 0.003, sampleSize: 28, isSignificant: true }
    const metrics = generateMockMetrics(30)

    const prompt = buildInsightPrompt(pattern, 'workout_completed', 'stress_level', metrics)

    expect(prompt).toContain('Workout Completion')
    expect(prompt).toContain('Stress Level')
    expect(prompt).toContain('r = -0.72')
    expect(prompt).toContain('negative')
    expect(prompt).toContain('30-Day Data Summary')
  })
})
```

### Integration Tests

```typescript
// Test: E2E pattern detection flow
describe('Pattern Detection E2E', () => {
  it('should detect pattern and generate insight for valid data', async () => {
    // 1. Setup: Create user with 30 days of metrics
    const userId = 'test-user-123'
    await createMockMetrics(userId, 30, {
      workoutDays: [1, 3, 5, 7, 9, 11, 13, 15, 17, 19],  // 10 workout days
      stressOnWorkoutDays: [2, 2, 3, 2, 3, 2, 2, 3, 2, 2],  // Low stress
      stressOnRestDays: [4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5],  // High stress
    })

    // 2. Run pattern detection
    const response = await callEdgeFunction('detect-patterns')

    // 3. Assert: Pattern detected
    expect(response.success).toBe(true)
    expect(response.patternsFound).toBeGreaterThan(0)

    // 4. Verify: Pattern saved to database
    const patterns = await supabase
      .from('detected_patterns')
      .select('*')
      .eq('user_id', userId)
      .eq('metric_a', 'workout_completed')
      .eq('metric_b', 'stress_level')

    expect(patterns.data).toHaveLength(1)
    expect(patterns.data[0].correlation_coefficient).toBeLessThan(-0.5)  // Negative correlation
    expect(patterns.data[0].insight_text).toContain('stress')
    expect(patterns.data[0].recommendation_text).toBeTruthy()

    // 5. Verify: Notification sent (if high confidence)
    if (patterns.data[0].confidence_score > 0.7) {
      const notifications = await getNotificationLog(userId, 'insight')
      expect(notifications).toHaveLength(1)
    }
  })
})
```

---

## 🐛 TROUBLESHOOTING GUIDE

### Issue 1: No Patterns Detected

**Symptoms:**
- Edge function runs successfully
- No patterns saved to `detected_patterns` table

**Possible Causes:**
1. Insufficient data (< 14 days)
2. No significant correlations (|r| < 0.5 or p > 0.05)
3. Data quality issues (too many null values)

**Debug Steps:**
```typescript
// Add logging to Edge Function
console.log(`User ${userId}: Metrics count: ${metrics.length}`)
console.log(`Valid pairs for workout/stress: ${validPairs.length}`)
console.log(`Correlation: r=${r}, p=${pValue}, significant=${isSignificant}`)
```

**Solutions:**
- Wait for more data (minimum 14 days, recommended 30 days)
- Lower threshold temporarily for testing (|r| > 0.3)
- Check data quality in `user_daily_metrics` table

---

### Issue 2: AI API Timeouts

**Symptoms:**
- Edge function times out after 30s
- Some insights generated, others fail

**Possible Causes:**
1. AI API slow response (GPT-4 can take 5-10s)
2. Too many concurrent calls
3. Network issues

**Solutions:**
```typescript
// Add timeout handling
const aiResponse = await Promise.race([
  callAI(model, prompt),
  new Promise((_, reject) =>
    setTimeout(() => reject(new Error('AI timeout')), 10000)  // 10s timeout
  )
])

// Fallback to template-based insight
if (aiError) {
  return {
    insight: generateTemplateInsight(pattern),
    recommendation: generateTemplateRecommendation(pattern)
  }
}
```

---

### Issue 3: Duplicate Notifications

**Symptoms:**
- Users receive multiple insight notifications per day

**Possible Causes:**
1. `last_insight_notification_sent` not updated
2. Race condition (multiple Edge Functions running)

**Solutions:**
```sql
-- Check last notification sent
SELECT user_id, last_insight_notification_sent
FROM user_settings
WHERE user_id = 'test-user-123';

-- Fix: Use atomic update with RETURNING
UPDATE user_settings
SET last_insight_notification_sent = CURRENT_DATE
WHERE user_id = $1
  AND (last_insight_notification_sent IS NULL
       OR last_insight_notification_sent < CURRENT_DATE)
RETURNING last_insight_notification_sent;
```

---

## 📊 MONITORING & METRICS

### Key Metrics to Track

```sql
-- Daily pattern detection stats
CREATE TABLE pattern_detection_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  run_date DATE NOT NULL,
  users_processed INTEGER,
  patterns_found INTEGER,
  ai_calls_made INTEGER,
  errors INTEGER,
  avg_processing_time_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Track insight engagement
SELECT
  COUNT(*) as total_insights,
  COUNT(*) FILTER (WHERE viewed_at IS NOT NULL) as viewed,
  COUNT(*) FILTER (WHERE dismissed_at IS NOT NULL) as dismissed,
  (COUNT(*) FILTER (WHERE viewed_at IS NOT NULL)::FLOAT / COUNT(*)) * 100 as view_rate,
  (COUNT(*) FILTER (WHERE dismissed_at IS NOT NULL)::FLOAT / COUNT(*)) * 100 as dismiss_rate
FROM detected_patterns
WHERE created_at >= NOW() - INTERVAL '30 days';
```

---

## ✅ DEFINITION OF DONE

- [ ] Pearson correlation algorithm implemented and tested (unit tests passing)
- [ ] Edge Function deployed and scheduled (daily cron at 6am)
- [ ] AI prompt engineering completed (Claude + GPT-4 integration)
- [ ] Cost optimization validated (< €100/month for 10k users)
- [ ] Notification flow working (max 1/day enforced)
- [ ] Integration tests passing (E2E flow: detect → generate → notify)
- [ ] Monitoring dashboard created (pattern detection stats)
- [ ] Documentation complete (troubleshooting guide, runbook)

---

**Created:** 2025-01-16
**Author:** Winston (BMAD Architect)
**Last Updated:** 2025-01-16
**Status:** Ready for Implementation
