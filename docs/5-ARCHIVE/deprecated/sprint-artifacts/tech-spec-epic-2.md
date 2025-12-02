# Epic Technical Specification: Life Coach MVP

Date: 2025-01-16
Author: Mariusz
Epic ID: epic-2
Status: Draft

---

## Overview

Epic 2 delivers the core Life Coach AI module, the "brain" of the LifeOS ecosystem that provides personalized daily planning, goal tracking, and conversational coaching powered by hybrid AI (Llama 3 for free tier, Claude/GPT-4 for premium). This module is FREE for all users (basic tier) and serves as the foundation for user engagement and retention.

The epic implements 10 user stories covering morning check-ins, AI-generated daily plans, goal management, AI chat conversations, evening reflections, streak tracking, progress dashboards, manual adjustments, AI goal suggestions, and weekly summary reports. Completion unlocks the killer "Cross-Module Intelligence" feature (Epic 5) that correlates Life Coach data with Fitness and Mind modules.

**Business Impact:** Primary retention driver (10-12% Day 30 retention target), differentiated AI experience, gateway to premium subscriptions.

## Objectives and Scope

**In Scope:**
- ✅ Morning check-in flow (mood, energy, focus assessment)
- ✅ AI daily plan generation (personalized task suggestions based on context)
- ✅ Goal creation & tracking (max 3 goals for free tier, unlimited for premium)
- ✅ AI conversational coaching (5 chats/day free, unlimited premium)
- ✅ Evening reflection flow (accomplishments, learnings, tomorrow prep)
- ✅ Streak tracking (check-in streaks with freeze/restore mechanics)
- ✅ Progress dashboard (charts, trends, insights)
- ✅ Manual daily plan adjustments (drag-drop reorder, mark complete, add custom tasks)
- ✅ AI goal suggestions (personalized based on user context)
- ✅ Weekly summary report (email + in-app, highlights + patterns)

**Out of Scope (Deferred to P1/P2):**
- ❌ Multi-goal dependencies and milestones - P1
- ❌ Habit tracking separate from goals - P1
- ❌ Time blocking / calendar integration - P1
- ❌ Voice-based check-ins - P2
- ❌ Team/shared goals - P2 (Tandem Mode)
- ❌ AI personality customization (Sage vs Momentum) - P1

## System Architecture Alignment

**Aligned to Architecture Decisions:**
- **D1 (Hybrid Architecture):** Life Coach module in `lib/features/life_coach/` with clean architecture layers
- **D2 (Shared PostgreSQL Schema):** Uses `user_daily_metrics` table for cross-module intelligence, `daily_plans` table for AI-generated plans
- **D3 (Offline-First Sync):** Check-ins and reflections save to Drift first (instant feedback), sync to Supabase when online
- **D4 (AI Orchestration):** Supabase Edge Functions route AI requests to Llama (free), Claude (standard), GPT-4 (premium)
- **D10 (Feature Gates):** Goal limit enforced (3 for free, unlimited for premium)
- **D13 (Tiered Cache):** AI conversation history cached locally (last 7 days critical tier)

**Architecture Components:**
- **Frontend:** Flutter 3.38+, Riverpod 3.0, Drift (local DB), go_router (navigation)
- **Backend:** Supabase (PostgreSQL, Edge Functions, Realtime)
- **AI Services:** Anthropic Claude API, OpenAI GPT-4 API, Llama 3 (self-hosted or API)
- **Notifications:** Firebase Cloud Messaging (morning reminder, streak alerts)

**Database Schema (Epic 2 Tables):**
```sql
-- Life Coach specific tables
daily_plans (id, user_id, date, tasks JSONB, generated_by, created_at)
goals (id, user_id, title, description, target_value, current_value, deadline, completed_at, created_at)
check_ins (id, user_id, type, mood, energy, focus, notes, created_at)  # type: 'morning' | 'evening'
ai_conversations (id, user_id, messages JSONB, created_at)
streaks (id, user_id, type, current_count, longest_count, last_check_in, freezes_remaining, created_at)
```

**Constraints:**
- AI quota: 5 conversations/day (free), unlimited (premium) - enforced by rate limiter
- Goal limit: 3 active goals (free), unlimited (premium) - enforced by feature gate
- Daily plan: 1 plan per day (regeneration allowed, overwrites previous)
- Streak freezes: 2 per month (free), 5 per month (premium)

---

## Detailed Design

### Services and Modules

| Service/Module | Responsibilities | Inputs | Outputs | Owner |
|----------------|-----------------|--------|---------|-------|
| **CheckInService** | Handle morning/evening check-ins | Mood (1-10), Energy (1-10), Focus (1-10), Notes | CheckInResult | Life Coach Team |
| **DailyPlanService** | Generate & manage daily plans | User context, Goals, Past performance | DailyPlan | Life Coach Team |
| **GoalService** | CRUD for user goals | Goal model, Progress updates | Result<Goal> | Life Coach Team |
| **AICoachService** | Conversational AI coaching | User message, Conversation history | AIResponse | Life Coach Team |
| **StreakService** | Track check-in streaks | Check-in timestamp | StreakStatus | Life Coach Team |
| **ProgressAnalyticsService** | Generate dashboards & charts | Time range, Metrics | ProgressReport | Life Coach Team |
| **AISuggestionService** | Suggest goals based on context | User profile, Activity history | List<GoalSuggestion> | Life Coach Team |

**Service Dependencies:**
```
CheckInService → StreakService (update streak on check-in)
              → DailyPlanService (trigger plan generation after morning check-in)

DailyPlanService → AICoachService (call AI API for plan generation)
                 → GoalService (fetch active goals for context)

AICoachService → Supabase Edge Function (AI orchestration - D4)
               → Rate limiter (enforce quota)

StreakService → NotificationService (send alerts when streak at risk)

ProgressAnalyticsService → user_daily_metrics table (aggregate data from all modules)
```

---

### Data Models and Contracts

#### CheckIn Model
```dart
@freezed
class CheckIn with _$CheckIn {
  const factory CheckIn({
    required String id,
    required String userId,
    required CheckInType type,        // morning | evening
    required int mood,                // 1-10
    required int energy,              // 1-10
    required int focus,               // 1-10
    String? notes,                    // Optional reflection text
    required DateTime createdAt,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
}

enum CheckInType {
  morning,
  evening,
}
```

#### DailyPlan Model
```dart
@freezed
class DailyPlan with _$DailyPlan {
  const factory DailyPlan({
    required String id,
    required String userId,
    required DateTime date,
    required List<PlanTask> tasks,    // AI-generated + user-added tasks
    required AIModel generatedBy,     // llama | claude | gpt4
    required DateTime createdAt,
  }) = _DailyPlan;

  factory DailyPlan.fromJson(Map<String, dynamic> json) => _$DailyPlanFromJson(json);
}

@freezed
class PlanTask with _$PlanTask {
  const factory PlanTask({
    required String id,
    required String title,
    String? description,
    required TaskPriority priority,   // high | medium | low
    int? estimatedMinutes,
    bool completed = false,
    DateTime? completedAt,
    String? linkedGoalId,             // Optional link to a goal
  }) = _PlanTask;
}

enum TaskPriority {
  high,     // Red accent, shown first
  medium,   // Orange accent
  low,      // Blue accent
}

enum AIModel {
  llama,    // Free tier
  claude,   // Standard tier
  gpt4,     // Premium tier
}
```

#### Goal Model
```dart
@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required String title,
    String? description,
    int? targetValue,                 // Optional numeric target (e.g., "Run 100km")
    @Default(0) int currentValue,     // Progress towards target
    DateTime? deadline,               // Optional deadline
    DateTime? completedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Goal;

  // Computed property: progress percentage
  double get progressPercentage {
    if (targetValue == null || targetValue == 0) return 0.0;
    return (currentValue / targetValue!) * 100.0;
  }

  // Computed property: is goal completed
  bool get isCompleted => completedAt != null;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
```

#### AIConversation Model
```dart
@freezed
class AIConversation with _$AIConversation {
  const factory AIConversation({
    required String id,
    required String userId,
    required List<AIMessage> messages,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AIConversation;

  factory AIConversation.fromJson(Map<String, dynamic> json) => _$AIConversationFromJson(json);
}

@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required MessageRole role,        // user | assistant
    required String content,
    required DateTime timestamp,
  }) = _AIMessage;
}

enum MessageRole {
  user,
  assistant,
}
```

#### Streak Model
```dart
@freezed
class Streak with _$Streak {
  const factory Streak({
    required String id,
    required String userId,
    required StreakType type,         // check_in | workout | meditation
    @Default(0) int currentCount,     // Current active streak
    @Default(0) int longestCount,     // Personal record
    DateTime? lastCheckIn,
    @Default(0) int freezesRemaining, // 2 for free, 5 for premium
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Streak;

  // Computed property: is streak at risk (last check-in >20h ago)
  bool get isAtRisk {
    if (lastCheckIn == null) return false;
    return DateTime.now().difference(lastCheckIn!) > Duration(hours: 20);
  }

  factory Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);
}

enum StreakType {
  checkIn,
  workout,
  meditation,
}
```

---

### APIs and Interfaces

#### CheckInService Interface
```dart
abstract class CheckInService {
  /// Submit morning check-in
  /// Triggers: Streak update, Daily plan generation
  Future<Result<CheckIn>> submitMorningCheckIn({
    required int mood,      // 1-10
    required int energy,    // 1-10
    required int focus,     // 1-10
    String? notes,
  });

  /// Submit evening reflection
  /// Triggers: Streak update, Weekly report data aggregation
  Future<Result<CheckIn>> submitEveningReflection({
    required int mood,
    required int energy,
    required int focus,
    String? accomplishments,
    String? learnings,
  });

  /// Get check-in history for date range
  Future<Result<List<CheckIn>>> getCheckInHistory({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get today's check-ins (morning + evening)
  Future<Result<List<CheckIn>>> getTodayCheckIns();
}
```

#### DailyPlanService Interface
```dart
abstract class DailyPlanService {
  /// Generate daily plan using AI
  /// Uses: User context, Active goals, Past performance, Morning check-in data
  /// Throws: [AIQuotaExceededException], [NetworkException]
  Future<Result<DailyPlan>> generateDailyPlan({
    required DateTime date,
    required CheckIn morningCheckIn,  // Mood, energy, focus context
    bool forceRegenerate = false,     // Overwrite existing plan
  });

  /// Get daily plan for date (null if not generated yet)
  Future<Result<DailyPlan?>> getDailyPlan(DateTime date);

  /// Mark task as complete
  Future<Result<DailyPlan>> completeTask({
    required String planId,
    required String taskId,
  });

  /// Add custom task to plan
  Future<Result<DailyPlan>> addCustomTask({
    required String planId,
    required String title,
    TaskPriority priority = TaskPriority.medium,
  });

  /// Reorder tasks (drag-drop)
  Future<Result<DailyPlan>> reorderTasks({
    required String planId,
    required List<String> newTaskOrder,  // Task IDs in new order
  });

  /// Delete task from plan
  Future<Result<DailyPlan>> deleteTask({
    required String planId,
    required String taskId,
  });
}
```

#### GoalService Interface
```dart
abstract class GoalService {
  /// Create new goal
  /// Throws: [GoalLimitExceededException] if free tier limit reached (3 goals)
  Future<Result<Goal>> createGoal({
    required String title,
    String? description,
    int? targetValue,
    DateTime? deadline,
  });

  /// Update goal progress
  Future<Result<Goal>> updateGoalProgress({
    required String goalId,
    required int newValue,
  });

  /// Complete goal
  Future<Result<Goal>> completeGoal(String goalId);

  /// Delete goal
  Future<Result<void>> deleteGoal(String goalId);

  /// Get all active goals (not completed)
  Future<Result<List<Goal>>> getActiveGoals();

  /// Get all goals (including completed)
  Future<Result<List<Goal>>> getAllGoals();
}
```

#### AICoachService Interface
```dart
abstract class AICoachService {
  /// Send message to AI coach
  /// Enforces: Rate limit (5/day free, unlimited premium)
  /// Throws: [AIQuotaExceededException], [NetworkException]
  Future<Result<AIMessage>> sendMessage({
    required String conversationId,
    required String message,
  });

  /// Start new AI conversation
  Future<Result<AIConversation>> startConversation();

  /// Get conversation history
  Future<Result<AIConversation>> getConversation(String conversationId);

  /// Get all user conversations (last 30 days)
  Future<Result<List<AIConversation>>> getAllConversations();

  /// Check remaining AI quota for today
  Future<AIQuotaStatus> getQuotaStatus();
}

class AIQuotaStatus {
  final int remaining;      // Remaining chats today
  final int limit;          // Daily limit (5 for free, -1 for unlimited)
  final DateTime resetsAt;  // Midnight UTC

  bool get exceeded => remaining <= 0 && limit != -1;
}
```

#### StreakService Interface
```dart
abstract class StreakService {
  /// Update streak (called after check-in)
  Future<Result<Streak>> updateStreak(StreakType type);

  /// Use streak freeze (when about to break streak)
  /// Throws: [NoFreezesRemaining]
  Future<Result<Streak>> useStreakFreeze(StreakType type);

  /// Get current streak for type
  Future<Result<Streak>> getStreak(StreakType type);

  /// Get all streaks
  Future<Result<List<Streak>>> getAllStreaks();

  /// Check if streak is at risk (>20h since last check-in)
  Future<bool> isStreakAtRisk(StreakType type);
}
```

---

### Workflows and Sequencing

#### Workflow 1: Morning Check-In → AI Daily Plan Generation (Story 2.1 + 2.2)
```
1. User opens app (morning reminder notification)
   ↓
2. App shows Morning Check-In screen (if not completed today)
   ↓
3. User rates Mood (slider 1-10), Energy (slider 1-10), Focus (slider 1-10)
   ↓
4. User taps "Generate My Day" button
   ↓
5. CheckInService.submitMorningCheckIn() called
   ↓
6. Save to Drift → Instant feedback ("Check-in saved ✓")
   ↓
7. StreakService.updateStreak(checkIn) → Update streak count
   ↓
8. Enqueue Supabase sync (check_ins table)
   ↓
9. Show loading screen: "AI is crafting your perfect day..."
   ↓
10. DailyPlanService.generateDailyPlan() called
    ↓
11. Fetch user context:
    - Active goals (from GoalService)
    - Past performance (completion rate last 7 days)
    - Morning check-in data (mood, energy, focus)
    - User preferences (work hours, break preferences)
    ↓
12. Call AI API via Supabase Edge Function:
    - Free tier → Llama 3 API
    - Standard tier → Claude API
    - Premium tier → GPT-4 API
    ↓
13. Edge Function builds prompt:
    """
    You are a life coach AI. Generate a daily plan for this user.

    Context:
    - Mood: 7/10 (Good)
    - Energy: 6/10 (Moderate)
    - Focus: 8/10 (High)
    - Active goals: [Run 100km, Learn Spanish, Read 12 books]
    - Past completion rate: 65%

    Generate 5-7 tasks for today, prioritized by importance.
    Format: JSON array of {title, description, priority, estimatedMinutes}
    """
    ↓
14. AI responds with JSON task list
    ↓
15. Edge Function validates response, returns to app
    ↓
16. DailyPlanService saves plan to Drift + Supabase
    ↓
17. Navigate to Daily Plan screen showing AI-generated tasks
    ↓
18. User can:
    - Mark tasks complete (checkmark)
    - Reorder tasks (drag-drop)
    - Add custom tasks (+ button)
    - Edit task details (tap)
    ↓
19. DONE ✅
```

#### Workflow 2: AI Conversational Coaching (Story 2.4)
```
1. User navigates to "Talk to Coach" screen
   ↓
2. AICoachService.getQuotaStatus() → Check remaining chats (5/day free)
   ↓
3. If quota exceeded:
   - Show paywall: "Upgrade to Premium for unlimited coaching"
   - User can subscribe or exit
   ↓
4. If quota available:
   - Show chat interface (conversation history loaded)
   ↓
5. User types message: "I'm feeling overwhelmed with work"
   ↓
6. User taps Send button
   ↓
7. AICoachService.sendMessage() called
   ↓
8. Save user message to local DB (instant display in chat)
   ↓
9. Show typing indicator: "Coach is typing..."
   ↓
10. Call AI API via Supabase Edge Function:
    - Build prompt with conversation context (last 10 messages)
    - Include user profile context (goals, recent check-ins)
    ↓
11. AI generates empathetic response:
    "It sounds like you're dealing with a lot right now. Let's break this down.
     What specific aspect of work is causing the most stress?"
    ↓
12. Edge Function returns AI response
    ↓
13. Save AI message to local DB + Supabase
    ↓
14. Display AI response in chat with smooth animation
    ↓
15. Decrement quota counter (5 → 4 remaining)
    ↓
16. User can continue conversation or close
    ↓
17. DONE ✅
```

#### Workflow 3: Goal Creation with AI Suggestions (Story 2.3 + 2.9)
```
1. User navigates to Goals screen
   ↓
2. User taps "Create New Goal" button
   ↓
3. App checks feature gate:
   - Free tier: Check if <3 active goals (limit)
   - Premium: No limit
   ↓
4. If limit exceeded:
   - Show paywall: "Upgrade for unlimited goals"
   - Exit flow
   ↓
5. If limit OK:
   - Show goal creation screen
   ↓
6. Option A: User manually enters goal
   - Title: "Run 100km this month"
   - Target: 100 (numeric)
   - Deadline: End of month
   - Tap "Create Goal" → Save to DB
   ↓
7. Option B: User taps "Suggest Goals" button
   ↓
8. AISuggestionService.suggestGoals() called
   ↓
9. Fetch user context:
   - Recent check-ins (mood/energy patterns)
   - Completed goals (past achievements)
   - Life areas (fitness, learning, relationships, etc.)
   ↓
10. Call AI API with context:
    "Based on this user's profile, suggest 3 personalized goals."
    ↓
11. AI returns goal suggestions:
    - "Improve morning energy by exercising 3x/week"
    - "Learn Spanish (15 min/day for 30 days)"
    - "Read 12 books this year (1 book/month)"
    ↓
12. Display suggestions as cards with "Add" button
    ↓
13. User taps "Add" on selected suggestion
    ↓
14. Goal created with AI-generated title + target
    ↓
15. Navigate back to Goals screen showing new goal
    ↓
16. DONE ✅
```

#### Workflow 4: Streak Tracking with Freeze Mechanic (Story 2.6)
```
1. User completes morning check-in at 8:00 AM
   ↓
2. StreakService.updateStreak(checkIn) called
   ↓
3. Check last_check_in timestamp:
   - If <24h ago: Increment current_count (5 → 6 days)
   - If >24h ago: Reset to 1 (streak broken)
   ↓
4. Update longest_count if current_count > longest_count
   ↓
5. Save to Drift + Supabase
   ↓
6. Show celebration UI if milestone reached:
   - 7 days: "1 week streak! 🔥"
   - 30 days: "1 month streak! 🎉"
   - 100 days: "100 day streak! 🏆"
   ↓
7. Next day at 8:00 PM (20 hours since last check-in):
   - StreakService.isStreakAtRisk() → true
   - FCM push notification: "Don't break your 6-day streak! Check in now."
   ↓
8. User opens app but realizes they can't check in (traveling, busy)
   ↓
9. User navigates to Streaks screen, taps "Use Freeze" button
   ↓
10. StreakService.useStreakFreeze(checkIn) called
    ↓
11. Check freezes_remaining:
    - Free tier: 2/month
    - Premium: 5/month
    ↓
12. If freezes available:
    - Decrement freezes_remaining (2 → 1)
    - Extend grace period by 24 hours
    - Show confirmation: "Freeze used! You have 1 day to check in."
    ↓
13. User checks in next day within grace period
    ↓
14. Streak continues (6 → 7 days)
    ↓
15. DONE ✅
```

---

## Non-Functional Requirements

### Performance

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-P5 | UI response time | <100ms | Riverpod optimistic updates, save to Drift first |
| NFR-AI1 | AI response time (free tier - Llama) | <2s | Llama 3 optimized for speed |
| NFR-AI2 | AI response time (standard - Claude) | <3s | Claude 3 Haiku (fastest variant) |
| NFR-AI3 | AI response time (premium - GPT-4) | <5s | GPT-4 Turbo (latest, faster than GPT-4) |
| NFR-P4 | Offline mode | Check-ins work offline | Save to Drift, sync when online |

**Performance Benchmarks:**
- Morning check-in submit: 50ms (Drift write)
- Daily plan generation: 2-5s (AI API call)
- Goal creation: 30ms (Drift write)
- AI chat message: 2-5s (AI API call + token streaming)
- Load daily plan: 20ms (Drift query)

### Security

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-S4 | AI prompt injection protection | Prevent jailbreaking | Input sanitization, prompt prefix/suffix guards |
| NFR-S5 | AI quota enforcement | Server-side validation | Supabase Edge Functions track usage, reject if exceeded |
| NFR-S2 | GDPR compliance | Data export includes Life Coach data | Include check-ins, plans, goals, AI conversations in ZIP |

**Security Measures:**
- ✅ AI prompts sanitized (remove system commands, escape special chars)
- ✅ Rate limiting on AI endpoints (5 req/day free, unlimited premium)
- ✅ User-generated content validated (max length, profanity filter)
- ✅ Goals and check-ins protected by RLS policies

### Reliability/Availability

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-R2 | AI fallback | Graceful degradation if AI fails | Show fallback template plan instead of error |
| NFR-R3 | Data persistence | 99.9% no data loss | Drift + Supabase sync with retry queue |

**Fallback Strategies:**
- AI API failure → Show template daily plan (generic tasks based on user goals)
- Network timeout → Queue AI request, generate plan when online
- Quota exceeded → Clear upgrade CTA instead of error message

### Observability

**Metrics to Track:**
- Daily check-in completion rate (target: 60%+)
- Daily plan generation success rate (target: 99%+)
- AI chat quota usage (free tier average: 3.2/day)
- Goal completion rate (target: 40%+)
- Streak retention (% users maintaining 7+ day streaks)

**Alerts:**
- 🚨 AI API failure rate >5% (degraded service)
- 🚨 Daily plan generation time >10s (performance issue)
- 🚨 Check-in completion rate drops <40% (engagement crisis)

---

## Dependencies and Integrations

### Flutter Dependencies (Epic 2 Specific)
```yaml
dependencies:
  # AI API clients
  anthropic_sdk: ^0.1.0        # Claude API
  openai_dart: ^3.1.0          # GPT-4 API
  http: ^1.2.0                 # Llama API (REST)

  # Charts & Visualization
  fl_chart: ^0.68.0            # Progress charts, trend lines

  # Markdown rendering (AI responses)
  flutter_markdown: ^0.7.3

  # Drag & drop reordering
  reorderable_list: ^1.0.0

  # Animations
  lottie: ^3.1.2               # Celebration animations (streak milestones)
```

### Supabase Edge Functions

**Function: `generate-daily-plan`**
```typescript
// supabase/functions/generate-daily-plan/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { userId, morningCheckIn, activeGoals } = await req.json()

  // Get user subscription tier
  const { data: user } = await supabase
    .from('users')
    .select('subscription_tier')
    .eq('id', userId)
    .single()

  // Route to appropriate AI model
  let aiResponse
  if (user.subscription_tier === 'free') {
    aiResponse = await callLlama3(buildPrompt(...))
  } else if (user.subscription_tier === 'standard') {
    aiResponse = await callClaude(buildPrompt(...))
  } else {
    aiResponse = await callGPT4(buildPrompt(...))
  }

  // Parse AI response (JSON task list)
  const tasks = JSON.parse(aiResponse)

  return new Response(JSON.stringify({ tasks }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

**Function: `ai-coach-chat`**
- Similar routing logic to `generate-daily-plan`
- Implements rate limiting (check `ai_usage_logs` table)
- Stores conversation history

**Function: `suggest-goals`**
- Calls AI API with user context
- Returns 3 personalized goal suggestions

---

## Acceptance Criteria (Authoritative)

### Story 2.1: Morning Check-in Flow
1. ✅ User sees morning check-in prompt on app launch (if not completed today)
2. ✅ User rates mood (slider 1-10), energy (slider 1-10), focus (slider 1-10)
3. ✅ User can add optional notes (text input, max 500 chars)
4. ✅ User taps "Generate My Day" → Triggers AI daily plan generation
5. ✅ Check-in data saved to Drift (instant) + Supabase (synced)
6. ✅ Streak updated (+1 day if within 24h of last check-in)
7. ✅ Morning check-in only allowed once per day (button disabled if completed)

### Story 2.2: AI Daily Plan Generation
1. ✅ Plan generated using AI (Llama/Claude/GPT-4 based on tier)
2. ✅ Plan includes 5-7 tasks prioritized by importance (high/medium/low)
3. ✅ Each task has: title, optional description, estimated time, priority
4. ✅ Tasks linked to active goals when relevant
5. ✅ Plan considers morning check-in context (mood, energy, focus)
6. ✅ Plan considers past performance (completion rate, task preferences)
7. ✅ User can regenerate plan (overwrites previous, confirmation dialog)
8. ✅ Fallback template plan shown if AI fails (generic tasks based on goals)
9. ✅ Plan saved to Drift + Supabase with AI model attribution

### Story 2.3: Goal Creation & Tracking
1. ✅ User can create goal with title, description, target value, deadline
2. ✅ Free tier limited to 3 active goals (paywall shown if limit reached)
3. ✅ Premium tier has unlimited goals
4. ✅ User can update goal progress (increment current value)
5. ✅ User can mark goal complete (shows celebration animation)
6. ✅ User can delete goal (confirmation dialog)
7. ✅ Goals displayed with progress bar (currentValue / targetValue)
8. ✅ Goals sortable by: creation date, deadline, progress

### Story 2.4: AI Conversational Coaching
1. ✅ User can start new AI conversation from "Talk to Coach" screen
2. ✅ User can send text message (max 1000 chars)
3. ✅ AI responds with empathetic, personalized advice
4. ✅ Conversation history displayed (user messages right-aligned, AI left-aligned)
5. ✅ Free tier limited to 5 chats/day (quota indicator shown)
6. ✅ Premium tier has unlimited chats
7. ✅ Typing indicator shown while AI generating response
8. ✅ Conversation history saved locally + Supabase (last 30 days)
9. ✅ User can delete conversation (confirmation dialog)

### Story 2.5: Evening Reflection Flow
1. ✅ User sees evening reflection prompt at 8:00 PM (push notification)
2. ✅ User rates mood, energy, focus (same as morning)
3. ✅ User answers reflection prompts:
   - "What did you accomplish today?"
   - "What did you learn?"
   - "What will you focus on tomorrow?"
4. ✅ Reflection data saved to Drift + Supabase
5. ✅ Streak updated (+1 if both morning + evening completed)
6. ✅ AI incorporates reflection into next day's plan

### Story 2.6: Streak Tracking (Check-ins)
1. ✅ Streak increments when user completes check-in within 24h of last
2. ✅ Streak resets to 1 if >24h gap (unless freeze used)
3. ✅ Streak freezes available: 2/month (free), 5/month (premium)
4. ✅ User can manually use freeze from Streaks screen
5. ✅ Push notification sent when streak at risk (>20h since last check-in)
6. ✅ Celebration animation shown at milestones (7, 30, 100 days)
7. ✅ Longest streak (personal record) tracked separately

### Story 2.7: Progress Dashboard (Life Coach)
1. ✅ Dashboard shows:
   - Check-in completion rate (last 7/30 days)
   - Task completion rate (last 7/30 days)
   - Goal progress (visual progress bars)
   - Mood/energy/focus trends (line charts)
   - Current streaks (all types)
2. ✅ Charts interactive (tap data point to see details)
3. ✅ Date range filter (7 days, 30 days, all time)
4. ✅ Data cached locally for offline viewing

### Story 2.8: Daily Plan Manual Adjustment
1. ✅ User can mark task complete (checkmark animation)
2. ✅ User can reorder tasks (drag-drop)
3. ✅ User can add custom task (+ button, quick add modal)
4. ✅ User can edit task (tap → edit modal)
5. ✅ User can delete task (swipe left → delete)
6. ✅ Changes saved to Drift instantly + Supabase sync
7. ✅ User edits flagged for AI learning (future improvement)

### Story 2.9: Goal Suggestions (AI)
1. ✅ User can tap "Suggest Goals" button on goal creation screen
2. ✅ AI generates 3 personalized goal suggestions based on:
   - Recent check-ins (mood/energy patterns)
   - Past goals (if any)
   - User profile (age, interests if provided)
3. ✅ Suggestions displayed as cards with "Add" button
4. ✅ User can add suggested goal with one tap
5. ✅ Suggestions cached for 24h (avoid redundant AI calls)

### Story 2.10: Weekly Summary Report (Life Coach)
1. ✅ Report generated every Monday at 8:00 AM
2. ✅ Report includes:
   - Check-in streak (current + longest)
   - Task completion rate (%)
   - Goals progress (list with progress bars)
   - Mood/energy/focus averages
   - Top 3 accomplishments (from reflections)
   - AI-generated insights ("You completed 85% of tasks, up from 70% last week!")
3. ✅ Report sent via push notification + email
4. ✅ Report viewable in-app (Reports tab)
5. ✅ Report shareable (screenshot + social share)

---

## Traceability Mapping

| AC | Spec Section | Component/API | Test Strategy |
|----|--------------|---------------|---------------|
| Story 2.1 AC1-7 | Workflows → Morning Check-In | CheckInService.submitMorningCheckIn() | Unit: Check-in validation, Widget: Check-in screen UI, Integration: E2E check-in flow |
| Story 2.2 AC1-9 | APIs → DailyPlanService, Workflows → AI Plan Generation | generateDailyPlan(), Supabase Edge Function | Unit: Mock AI response parsing, Integration: E2E plan generation, Load test: 1000 concurrent requests |
| Story 2.3 AC1-8 | APIs → GoalService, Data Models → Goal | createGoal(), updateGoalProgress(), completeGoal() | Unit: Goal validation, Widget: Goal creation form, Integration: Feature gate enforcement |
| Story 2.4 AC1-9 | APIs → AICoachService | sendMessage(), getQuotaStatus() | Unit: Quota enforcement logic, Integration: AI conversation flow, Performance: Response time <5s |
| Story 2.5 AC1-6 | APIs → CheckInService | submitEveningReflection() | Unit: Reflection data save, Integration: AI incorporation into next plan |
| Story 2.6 AC1-7 | APIs → StreakService, Data Models → Streak | updateStreak(), useStreakFreeze() | Unit: Streak logic (increment/reset), Integration: Freeze mechanic, E2E: 7-day streak simulation |
| Story 2.7 AC1-4 | Services → ProgressAnalyticsService | generateProgressReport() | Unit: Chart data aggregation, Widget: fl_chart rendering, Integration: Multi-module data correlation |
| Story 2.8 AC1-7 | APIs → DailyPlanService | completeTask(), addCustomTask(), reorderTasks() | Unit: Task CRUD operations, Widget: Drag-drop reordering, Integration: Optimistic updates |
| Story 2.9 AC1-5 | APIs → AISuggestionService | suggestGoals() | Unit: Mock AI suggestions, Integration: Goal creation from suggestion, Performance: Cache validation |
| Story 2.10 AC1-5 | Services → WeeklySummaryService | generateWeeklySummary() | Unit: Summary data aggregation, Integration: Email + push notification, E2E: Monday 8AM cron trigger |

---

## Risks, Assumptions, Open Questions

### Risks

| Risk ID | Description | Probability | Impact | Mitigation | Owner |
|---------|-------------|-------------|--------|------------|-------|
| **RISK-E2-001** | AI cost exceeds budget (30% revenue) | Medium | Critical | Monitor usage, implement hard quotas, optimize prompts | Life Coach Team |
| **RISK-E2-002** | AI response quality too low for free tier (Llama) | High | High | Curate Llama prompts carefully, consider upgrading free tier to Claude-light | Product Team |
| **RISK-E2-003** | Users abuse AI quota with spam messages | Low | Medium | Implement profanity filter, rate limiting by IP, CAPTCHA for suspicious activity | Security Team |
| **RISK-E2-004** | Daily plan generation fails frequently | Medium | High | Implement robust fallback template system, retry logic, alert monitoring | DevOps Team |
| **RISK-E2-005** | Streak mechanic too harsh, users churn | Medium | High | Usability testing, adjust freeze count (2 → 3 for free tier), grace period extension | Product Team |
| **RISK-E2-006** | Goal limit (3) too restrictive for free tier | High | Medium | A/B test 3 vs 5 goals, monitor conversion rate to premium | Growth Team |

### Assumptions

1. **AI quality:** Llama 3 produces acceptable quality for basic daily plans and coaching
2. **User engagement:** Users will complete morning check-ins at 60%+ rate (industry average: 40%)
3. **Quota acceptance:** 5 AI chats/day sufficient for free tier users (data shows average usage: 2.3/day)
4. **Goal tracking:** Users prefer simple numeric goals over complex OKR-style goals
5. **Streak psychology:** Streak mechanics increase retention (proven by Duolingo, Snapchat)

### Open Questions

1. **Q:** Should we allow goal sharing (social feature)?
   - **Answer needed from:** Product Owner
   - **Impact:** Social features complexity, privacy concerns

2. **Q:** What's the optimal number of tasks in daily plan? (Currently 5-7)
   - **Answer:** Run A/B test with 5-7 vs 3-5 tasks
   - **Hypothesis:** Fewer tasks = higher completion rate

3. **Q:** Should AI conversations be end-to-end encrypted like journals?
   - **Answer needed from:** Privacy/Legal team
   - **Impact:** Prevents AI learning from conversation patterns (Cross-Module Intelligence)

4. **Q:** How to prevent users from gaming streak system (e.g., check in at 11:59 PM)?
   - **Decision:** Allow it - any check-in counts (similar to Duolingo)

---

## Test Strategy Summary

### Test Pyramid (70/20/10)

**Unit Tests (70%):**
- CheckInService: Validation, streak update logic
- DailyPlanService: AI response parsing, fallback templates
- GoalService: CRUD operations, progress calculation, feature gate enforcement
- AICoachService: Quota enforcement, conversation history management
- StreakService: Increment/reset logic, freeze mechanic
- ProgressAnalyticsService: Chart data aggregation, trend calculation

**Widget Tests (20%):**
- Morning check-in screen: Sliders, validation, submit flow
- Daily plan screen: Task list, drag-drop reordering, checkmark animation
- Goals screen: Create goal form, progress bars, completion celebration
- AI coach chat screen: Message bubbles, typing indicator, quota warning
- Progress dashboard: Charts rendering, date range filter

**Integration Tests (10%):**
- E2E morning check-in → AI plan generation flow
- E2E AI coaching conversation (5 messages)
- E2E goal creation → progress update → completion
- 7-day streak simulation (check-ins every 24h)
- Weekly summary report generation (cron trigger)

### Load Testing

**AI API Load Tests:**
- 1000 concurrent plan generation requests (target: <10s p99)
- 5000 concurrent chat messages (target: <10s p99)

**Database Load Tests:**
- 10k users checking in simultaneously (target: <500ms p95)

### Example Test Case

```dart
// Unit test: StreakService
test('should increment streak when check-in within 24h', () async {
  // Arrange
  final streak = Streak(
    id: '1',
    userId: 'user1',
    type: StreakType.checkIn,
    currentCount: 5,
    lastCheckIn: DateTime.now().subtract(Duration(hours: 20)),
  );
  when(mockRepository.getStreak(StreakType.checkIn))
    .thenAnswer((_) async => Success(streak));

  // Act
  final result = await streakService.updateStreak(StreakType.checkIn);

  // Assert
  result.when(
    success: (updatedStreak) {
      expect(updatedStreak.currentCount, 6);  // 5 + 1
    },
    failure: (_) => fail('Should not fail'),
  );
});

// Integration test: AI daily plan generation
testWidgets('should generate daily plan after morning check-in', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  await loginUser(tester);  // Helper to log in

  // Act
  await tester.tap(find.text('Morning Check-In'));
  await tester.pumpAndSettle();

  await tester.drag(find.byKey(Key('mood_slider')), Offset(200, 0));  // Slide to 7
  await tester.drag(find.byKey(Key('energy_slider')), Offset(150, 0));  // Slide to 6
  await tester.drag(find.byKey(Key('focus_slider')), Offset(250, 0));  // Slide to 8

  await tester.tap(find.text('Generate My Day'));
  await tester.pump();  // Start async operation

  // Wait for AI response (mock returns in 500ms)
  await tester.pump(Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Your Day'), findsOneWidget);  // Daily plan screen
  expect(find.byType(TaskCard), findsNWidgets(5));  // 5 tasks generated
  verify(mockAIService.generateDailyPlan(any)).called(1);
});
```

---

## Implementation Checklist

**Phase 1: Check-Ins & Streaks (2 days)**
- [ ] Implement CheckInService
- [ ] Create morning/evening check-in screens
- [ ] Implement StreakService with freeze mechanic
- [ ] Add FCM push notifications for streak alerts
- [ ] Write unit + integration tests

**Phase 2: AI Daily Plan Generation (3 days)**
- [ ] Setup Supabase Edge Function (generate-daily-plan)
- [ ] Implement DailyPlanService with fallback templates
- [ ] Create daily plan screen (task list, reorder, complete)
- [ ] Add manual task adjustments (add, edit, delete, reorder)
- [ ] Write unit + load tests for AI API

**Phase 3: Goals (2 days)**
- [ ] Implement GoalService with feature gates
- [ ] Create goal screens (create, list, detail, progress)
- [ ] Add AI goal suggestions (Edge Function)
- [ ] Add celebration animations for milestones
- [ ] Write unit + widget tests

**Phase 4: AI Conversational Coaching (2 days)**
- [ ] Setup Supabase Edge Function (ai-coach-chat)
- [ ] Implement AICoachService with quota enforcement
- [ ] Create chat screen (message bubbles, typing indicator)
- [ ] Add conversation history persistence
- [ ] Write unit + integration tests

**Phase 5: Progress Dashboard (1 day)**
- [ ] Implement ProgressAnalyticsService
- [ ] Create dashboard screen with fl_chart
- [ ] Add date range filters
- [ ] Test chart rendering with sample data

**Phase 6: Weekly Summary Report (1 day)**
- [ ] Implement WeeklySummaryService
- [ ] Setup cron trigger (Monday 8 AM)
- [ ] Create email template + FCM payload
- [ ] Add in-app report viewer
- [ ] Test report generation end-to-end

**Phase 7: Testing & Polish (1 day)**
- [ ] End-to-end integration tests
- [ ] Performance profiling (AI response times)
- [ ] Accessibility audit
- [ ] Error handling polish
- [ ] Loading states and animations

**Total Estimate: 12 days (2.4 sprints at 5 days/sprint)**

---

**Epic Status:** Ready for Implementation ✅
**Dependencies:** Epic 1 (Core Platform Foundation)
**Blocks:** Epic 5 (Cross-Module Intelligence)

---

_Tech Spec generated by Bob (BMAD Scrum Master) on 2025-01-16_
