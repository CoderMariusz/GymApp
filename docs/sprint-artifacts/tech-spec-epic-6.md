# Tech Spec - Epic 6: Gamification & Retention

**Epic:** Epic 6 - Gamification & Retention
**Author:** Winston (BMAD Architect)
**Date:** 2025-01-16
**Status:** Ready for Implementation
**Sprint:** TBD (Sprint 7)
**Stories:** 6 (6.1 - 6.6)
**Estimated Duration:** 8-10 days
**Dependencies:** Epic 2, Epic 3, Epic 4 (modules for streak tracking)

---

## 1. Overview

### 1.1 Epic Goal

Implement gamification mechanics (streaks, badges, celebrations) and weekly summary reports to drive user retention and engagement.

### 1.2 Value Proposition

**For users:** Visible progress, milestone celebrations, and concrete evidence of improvement through streaks, badges, and weekly reports.

**For business:** Increase retention from industry average 3.3% to target 10-12% Day 30 retention.

### 1.3 Scope Summary

**In Scope (MVP):**
- Streak tracking (workouts, meditations, check-ins)
- Milestone badges (Bronze 7d, Silver 30d, Gold 100d)
- Streak break alerts (push notifications)
- Celebration animations (confetti, badge pop)
- Shareable milestone cards (social sharing)
- Weekly summary report (all modules)

**Out of Scope (P1/P2):**
- Leaderboards (P1)
- Challenges (30-day meditation, workout streaks) (P1)
- XP/leveling system (P2)
- Talent Tree (P1)

### 1.4 Success Criteria

**Functional:**
- ✅ 3 streak types tracked (workout, meditation, check-in)
- ✅ Streak freeze working (1/week per type)
- ✅ Badges awarded at milestones (7d, 30d, 100d)
- ✅ Weekly report generated every Monday 6am
- ✅ Shareable milestone cards (image generation)

**Non-Functional:**
- ✅ Streak update <100ms (offline-first)
- ✅ Badge unlock animation <2s (no janky performance)
- ✅ Weekly report generation <5s (30-day aggregation)
- ✅ Social share image generation <1s

---

## 2. Architecture Alignment

### 2.1 Data Models

```dart
enum StreakType { workout, meditation, checkIn }

@freezed
class Streak with _$Streak {
  const factory Streak({
    required String id,
    required String userId,
    required StreakType type,
    required int currentStreak,
    required int longestStreak,
    required bool freezeUsedThisWeek,
    required DateTime? lastActivityDate,
    required DateTime createdAt,
  }) = _Streak;
}

enum BadgeTier { bronze, silver, gold }

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String userId,
    required StreakType type,
    required BadgeTier tier,
    required DateTime earnedAt,
  }) = _Badge;
}

@freezed
class WeeklyReport with _$WeeklyReport {
  const factory WeeklyReport({
    required String id,
    required String userId,
    required DateTime weekStartDate,
    required WeeklyReportData data,
    required DateTime createdAt,
  }) = _WeeklyReport;
}

@freezed
class WeeklyReportData with _$WeeklyReportData {
  const factory WeeklyReportData({
    // Fitness
    required int workoutsCompleted,
    required String prAchieved,          // e.g., "+5kg squat"
    required String volumeChange,        // e.g., "+12%"
    // Mind
    required int meditationsCompleted,
    required int avgMeditationDuration,
    required String stressChange,        // e.g., "-23%"
    required double avgMood,
    // Life Coach
    required int checkInsCompleted,
    required int goalsProgressed,
    required double avgDailyPlanCompletion,
    // Streaks
    required Map<StreakType, int> streaks,
    // Top Insight
    required String topInsight,
  }) = _WeeklyReportData;
}
```

### 2.2 Database Schema

```sql
-- Streaks
CREATE TABLE streaks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('workout', 'meditation', 'check_in')),
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  freeze_used_this_week BOOLEAN DEFAULT FALSE,
  last_activity_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, type)
);

CREATE INDEX idx_streaks_user ON streaks(user_id);

-- Badges
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('workout', 'meditation', 'check_in')),
  tier TEXT NOT NULL CHECK (tier IN ('bronze', 'silver', 'gold')),
  earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, type, tier)
);

CREATE INDEX idx_badges_user ON badges(user_id);

-- Weekly Reports
CREATE TABLE weekly_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  week_start_date DATE NOT NULL,
  report_data JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, week_start_date)
);

CREATE INDEX idx_weekly_reports_user_date ON weekly_reports(user_id, week_start_date DESC);

-- RLS Policies
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own streaks"
  ON streaks FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access their own badges"
  ON badges FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access their own weekly reports"
  ON weekly_reports FOR ALL USING (auth.uid() = user_id);
```

---

## 3. Detailed Design

### 3.1 Story 6.1: Streak Tracking System

**Goal:** Track 3 streak types (workout, meditation, check-in) with freeze mechanics.

#### 3.1.1 Services

**StreakService**
```dart
class StreakService {
  final StreakRepository _repository;
  final SupabaseClient _supabase;

  /// Update streak after activity completion
  Future<void> updateStreak(StreakType type) async {
    final streak = await _repository.getStreak(_currentUserId, type)
      ?? _createDefaultStreak(type);

    final today = DateUtils.dateOnly(DateTime.now());
    final lastActivity = streak.lastActivityDate;

    if (lastActivity == null || lastActivity.isBefore(today.subtract(Duration(days: 1)))) {
      // Streak broken or new streak
      if (lastActivity != null && !streak.freezeUsedThisWeek) {
        // Use freeze automatically
        await _useFreezeAndMaintainStreak(streak);
      } else {
        // Streak broken, reset to 1
        await _resetStreak(streak);
      }
    } else if (DateUtils.isSameDay(lastActivity, today.subtract(Duration(days: 1)))) {
      // Consecutive day, increment streak
      await _incrementStreak(streak);
    }
    // If last activity is today, do nothing (already counted)

    // Check for milestone badges
    await _checkForBadgeMilestone(streak);
  }

  Future<void> _useFreezeAndMaintainStreak(Streak streak) async {
    final updatedStreak = streak.copyWith(
      freezeUsedThisWeek: true,
      lastActivityDate: DateUtils.dateOnly(DateTime.now()),
    );

    await _repository.updateStreak(updatedStreak);

    // Send notification
    await _notificationService.send(
      userId: _currentUserId,
      title: 'Streak Freeze Used',
      body: 'Your ${streak.type.name} streak is protected! You have 0 freezes left this week.',
    );
  }

  Future<void> _resetStreak(Streak streak) async {
    final updatedStreak = streak.copyWith(
      currentStreak: 1,
      lastActivityDate: DateUtils.dateOnly(DateTime.now()),
    );

    await _repository.updateStreak(updatedStreak);
  }

  Future<void> _incrementStreak(Streak streak) async {
    final newStreak = streak.currentStreak + 1;
    final updatedStreak = streak.copyWith(
      currentStreak: newStreak,
      longestStreak: max(newStreak, streak.longestStreak),
      lastActivityDate: DateUtils.dateOnly(DateTime.now()),
    );

    await _repository.updateStreak(updatedStreak);
  }

  /// Reset freeze on Sunday (weekly reset)
  Future<void> resetWeeklyFreezes() async {
    await _supabase
      .from('streaks')
      .update({'freeze_used_this_week': false})
      .neq('freeze_used_this_week', false);
  }
}
```

**Cron Job: Reset Freezes (Sunday 11:59pm)**
```sql
SELECT cron.schedule(
  'reset-weekly-freezes',
  '59 23 * * 0',  -- Sunday 11:59pm
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/reset-weekly-freezes',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

### 3.2 Story 6.2: Milestone Badges

**Goal:** Award badges at 7-day (Bronze), 30-day (Silver), 100-day (Gold) milestones.

#### 3.2.1 Services

**BadgeService**
```dart
class BadgeService {
  final BadgeRepository _repository;
  final NotificationService _notificationService;

  Future<void> checkForBadgeMilestone(Streak streak) async {
    final currentStreak = streak.currentStreak;

    BadgeTier? tier;
    if (currentStreak == 7) tier = BadgeTier.bronze;
    else if (currentStreak == 30) tier = BadgeTier.silver;
    else if (currentStreak == 100) tier = BadgeTier.gold;

    if (tier != null) {
      await _awardBadge(streak.userId, streak.type, tier);
    }
  }

  Future<void> _awardBadge(String userId, StreakType type, BadgeTier tier) async {
    // Check if badge already awarded
    final existingBadge = await _repository.getBadge(userId, type, tier);
    if (existingBadge != null) return;

    // Award badge
    final badge = Badge(
      id: uuid.v4(),
      userId: userId,
      type: type,
      tier: tier,
      earnedAt: DateTime.now().toUtc(),
    );

    await _repository.saveBadge(badge);

    // Trigger celebration animation
    await _celebrationService.showBadgeUnlock(badge);

    // Send push notification
    await _notificationService.send(
      userId: userId,
      title: '🎉 ${tier.name.capitalize()} Badge Earned!',
      body: 'You\'ve reached a ${currentStreak(tier)}-day ${type.name} streak!',
    );
  }

  int currentStreak(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze: return 7;
      case BadgeTier.silver: return 30;
      case BadgeTier.gold: return 100;
    }
  }
}
```

#### 3.2.2 UI Components

**BadgeUnlockScreen** (Full-screen modal)
```dart
class BadgeUnlockScreen extends StatefulWidget {
  final Badge badge;

  @override
  _BadgeUnlockScreenState createState() => _BadgeUnlockScreenState();
}

class _BadgeUnlockScreenState extends State<BadgeUnlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          // Confetti animation (Lottie)
          Lottie.asset('assets/animations/confetti.json'),

          // Badge icon (zooms in with elastic bounce)
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getBadgeEmoji(widget.badge.tier),
                    style: TextStyle(fontSize: 120),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '${widget.badge.tier.name.capitalize()} Badge Earned!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_getStreakDays(widget.badge.tier)}-day ${widget.badge.type.name} streak',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Continue'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _shareAchievement(),
                    child: Text('Share Achievement', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeEmoji(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze: return '🥉';
      case BadgeTier.silver: return '🥈';
      case BadgeTier.gold: return '🥇';
    }
  }

  int _getStreakDays(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze: return 7;
      case BadgeTier.silver: return 30;
      case BadgeTier.gold: return 100;
    }
  }

  Future<void> _shareAchievement() async {
    final image = await _generateShareableImage(widget.badge);
    await Share.shareFiles([image.path], text: 'I earned a ${widget.badge.tier.name} badge on LifeOS!');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### 3.3 Story 6.3: Streak Break Alerts

**Goal:** Send push notification if streak about to break (8pm, if activity not done).

#### 3.3.1 Supabase Edge Function: `check-streak-alerts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_KEY')!)

  // Get all users with active streaks
  const { data: streaks } = await supabase
    .from('streaks')
    .select('user_id, type, current_streak, last_activity_date, freeze_used_this_week')
    .gt('current_streak', 0)

  const today = new Date().toISOString().split('T')[0]

  for (const streak of streaks || []) {
    const lastActivity = streak.last_activity_date

    // If activity not done today and no freeze available
    if (lastActivity !== today && !streak.freeze_used_this_week) {
      await sendStreakAlert(supabase, streak.user_id, streak.type, streak.current_streak)
    }
  }

  return new Response(JSON.stringify({ processed: streaks?.length || 0 }), { status: 200 })
})

async function sendStreakAlert(supabase: any, userId: string, type: string, currentStreak: number) {
  await supabase.functions.invoke('send-notification', {
    body: {
      userId,
      title: '🔥 Streak Alert!',
      body: `Your ${currentStreak}-day ${type} streak is about to break. ${getActivityCTA(type)}`,
      deepLink: getDeepLink(type),
    },
  })
}

function getActivityCTA(type: string): string {
  switch (type) {
    case 'workout': return 'Log a workout now!'
    case 'meditation': return 'Meditate now!'
    case 'check_in': return 'Complete your evening reflection!'
    default: return 'Complete your activity!'
  }
}

function getDeepLink(type: string): string {
  switch (type) {
    case 'workout': return 'lifeos://fitness/log'
    case 'meditation': return 'lifeos://mind/meditation'
    case 'check_in': return 'lifeos://life-coach/check-in/evening'
    default: return 'lifeos://home'
  }
}
```

**Cron Job: Check Streaks (8pm daily)**
```sql
SELECT cron.schedule(
  'check-streak-alerts',
  '0 20 * * *',  -- 8pm daily
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/check-streak-alerts',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

### 3.4 Story 6.6: Weekly Summary Report

**Goal:** Generate comprehensive weekly report every Monday 6am.

#### 3.4.1 Supabase Edge Function: `generate-weekly-reports`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_KEY')!)

  // Get all active users
  const { data: users } = await supabase.from('auth.users').select('id')

  for (const user of users || []) {
    try {
      await generateWeeklyReport(supabase, user.id)
    } catch (error) {
      console.error(`Error generating report for user ${user.id}:`, error)
    }
  }

  return new Response(JSON.stringify({ processed: users?.length || 0 }), { status: 200 })
})

async function generateWeeklyReport(supabase: any, userId: string) {
  const today = new Date()
  const weekStart = new Date(today)
  weekStart.setDate(today.getDate() - 7)

  // Aggregate data from last 7 days
  const { data: metrics } = await supabase
    .from('user_daily_metrics')
    .select('*')
    .eq('user_id', userId)
    .gte('date', weekStart.toISOString().split('T')[0])
    .lt('date', today.toISOString().split('T')[0])

  if (!metrics || metrics.length === 0) return

  // Calculate report data
  const reportData = {
    // Fitness
    workoutsCompleted: metrics.filter(m => m.workout_completed).length,
    prAchieved: await getPRAchieved(supabase, userId, weekStart),
    volumeChange: calculateVolumeChange(metrics),

    // Mind
    meditationsCompleted: metrics.filter(m => m.meditation_completed).length,
    avgMeditationDuration: avgOf(metrics, 'meditation_duration_minutes'),
    stressChange: calculateStressChange(metrics),
    avgMood: avgOf(metrics, 'mood_score'),

    // Life Coach
    checkInsCompleted: metrics.filter(m => m.daily_plan_generated).length,
    goalsProgressed: await getGoalsProgressed(supabase, userId, weekStart),
    avgDailyPlanCompletion: avgOf(metrics, 'completion_rate'),

    // Streaks
    streaks: await getCurrentStreaks(supabase, userId),

    // Top Insight
    topInsight: await getTopInsight(supabase, userId, weekStart),
  }

  // Save report
  await supabase.from('weekly_reports').insert({
    user_id: userId,
    week_start_date: weekStart.toISOString().split('T')[0],
    report_data: reportData,
  })

  // Send push notification
  await sendWeeklyReportNotification(supabase, userId, reportData)
}

async function sendWeeklyReportNotification(supabase: any, userId: string, data: any) {
  const summary = `${data.workoutsCompleted} workouts, ${data.prAchieved || 'no PRs'}, stress ${data.stressChange}`

  await supabase.functions.invoke('send-notification', {
    body: {
      userId,
      title: '📊 Your Week in Review',
      body: summary,
      deepLink: 'lifeos://home/weekly-report',
    },
  })
}
```

**Cron Job: Generate Weekly Reports (Monday 6am)**
```sql
SELECT cron.schedule(
  'generate-weekly-reports',
  '0 6 * * 1',  -- Monday 6am
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/generate-weekly-reports',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

#### 3.4.2 UI Components

**WeeklyReportCard**
```dart
class WeeklyReportCard extends StatelessWidget {
  final WeeklyReportData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Week in Review', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            _buildSection(
              '💪 Fitness',
              [
                'Workouts: ${data.workoutsCompleted}/7',
                'PR: ${data.prAchieved}',
                'Volume: ${data.volumeChange}',
              ],
              Colors.orange,
            ),

            _buildSection(
              '🧠 Mind',
              [
                'Meditations: ${data.meditationsCompleted}',
                'Avg duration: ${data.avgMeditationDuration} min',
                'Stress: ${data.stressChange}',
                'Mood: ${data.avgMood.toStringAsFixed(1)}/5 ${_getTrendArrow(data.avgMood)}',
              ],
              Colors.purple,
            ),

            _buildSection(
              '☀️ Life Coach',
              [
                'Check-ins: ${data.checkInsCompleted}/7',
                'Goals progressed: ${data.goalsProgressed}',
                'Daily plan: ${(data.avgDailyPlanCompletion * 100).toInt()}% avg',
              ],
              Colors.blue,
            ),

            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.topInsight,
                      style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReport(data),
                    icon: Icon(Icons.share),
                    label: Text('Share Report'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewPastWeeks(),
                    child: Text('View Past Weeks'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(left: 16, bottom: 4),
            child: Text('• $item', style: TextStyle(fontSize: 14)),
          )),
        ],
      ),
    );
  }

  String _getTrendArrow(double avgMood) {
    // Compare with last week (simplified)
    if (avgMood >= 4.0) return '↑';
    if (avgMood <= 3.0) return '↓';
    return '→';
  }

  Future<void> _shareReport(WeeklyReportData data) async {
    final image = await _generateReportImage(data);
    await Share.shareFiles([image.path], text: 'My LifeOS weekly progress!');
  }

  void _viewPastWeeks() {
    // Navigate to weekly reports history
  }
}
```

---

## 4. Non-Functional Requirements

| NFR | Target | Implementation |
|-----|--------|----------------|
| **NFR-G1** | Streak update <100ms | Offline-first (Drift), instant feedback |
| **NFR-G2** | Badge unlock animation <2s | Lottie animation, optimized rendering |
| **NFR-G3** | Weekly report generation <5s | Aggregate queries, pre-calculated metrics |
| **NFR-G4** | Social share image <1s | Server-side image generation or cached template |

---

## 5. Dependencies & Integrations

| Dependency | Type | Reason |
|------------|------|--------|
| **Epic 2: Life Coach** | Hard | Check-in streak data |
| **Epic 3: Fitness** | Hard | Workout streak data |
| **Epic 4: Mind** | Hard | Meditation streak data |
| **Epic 8: Notifications** | Hard | Streak alerts, badge unlocks, weekly reports |

---

## 6. Acceptance Criteria

### 6.1 Epic-Level Acceptance

**Functional:**
- ✅ 3 streak types tracked (workout, meditation, check-in)
- ✅ Streak freeze working (1/week per type, auto-used)
- ✅ Badges awarded at milestones (7d, 30d, 100d)
- ✅ Celebration animation on badge unlock (confetti + badge pop)
- ✅ Streak break alerts sent (8pm if activity not done)
- ✅ Weekly report generated (Monday 6am)
- ✅ Shareable milestone cards (image generation)

**Non-Functional:**
- ✅ Streak update <100ms
- ✅ Badge animation <2s
- ✅ Weekly report <5s
- ✅ Share image <1s

---

## 7. Traceability Mapping

| FR Range | Feature | Stories | Status |
|----------|---------|---------|--------|
| FR85-FR87 | Streaks & Freeze | 6.1, 6.3 | ✅ |
| FR86, FR88 | Badges & Celebrations | 6.2, 6.4 | ✅ |
| FR89 | Social Sharing | 6.5 | ✅ |
| FR90 | Weekly Reports | 6.6 | ✅ |

**Coverage:** 6/6 FRs covered (FR85-FR90) ✅

---

## 8. Risks & Test Strategy

### 8.1 Identified Risks

| Risk ID | Description | Mitigation |
|---------|-------------|------------|
| **RISK-G1** | Streak freeze logic complex (weekly reset) | Comprehensive unit tests, manual testing |
| **RISK-G2** | Badge unlock spam (multiple badges at once) | Queue badge unlocks, show one at a time |
| **RISK-G3** | Weekly report generation slow (10k users) | Batch processing, optimize queries |

### 8.2 Test Strategy

**Critical Scenarios:**
1. **Streak freeze:** Miss check-in → Freeze auto-used → Streak maintained → Notification sent
2. **Badge unlock:** Complete 7-day streak → Badge awarded → Celebration animation → Push notification
3. **Streak break alert:** 8pm, activity not done → Push notification sent → Tap notification → Opens relevant module
4. **Weekly report:** Monday 6am → Report generated → Push notification → Tap → Opens report card
5. **Social share:** Unlock badge → Tap "Share Achievement" → Image generated → Share to Instagram Stories

**Coverage Target:** 80%+ unit, 75%+ widget, 100% critical flows

---

## Document Status

✅ **COMPLETE** - Ready for implementation

**Version:** 1.0
**Last Updated:** 2025-01-16
**Epic 6 Tech Spec created by Winston (BMAD Architect)**
**Total Pages:** 28
**Estimated Implementation:** 8-10 days
