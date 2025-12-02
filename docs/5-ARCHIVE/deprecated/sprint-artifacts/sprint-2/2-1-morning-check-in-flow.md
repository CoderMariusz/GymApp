# Story 2.1: Morning Check-in Flow

**Epic:** Epic 2 - Life Coach MVP
**Phase:** MVP
**Priority:** P0
**Status:** ready-for-dev
**Estimated Effort:** 3 SP

---

## User Story

**As a** user starting my day
**I want** to complete a quick morning check-in
**So that** the AI can generate a personalized daily plan

---

## Acceptance Criteria

1. ✅ Morning check-in modal appears on first app open (if not done today)
2. ✅ User rates mood (1-5 emoji slider, default 3)
3. ✅ User rates energy (1-5 emoji slider, default 3)
4. ✅ User rates sleep quality (1-5 emoji slider, default 3)
5. ✅ Optional note field ("Anything on your mind?")
6. ✅ Haptic feedback on emoji selection
7. ✅ "Generate My Plan" CTA triggers AI daily plan generation
8. ✅ "Skip for today" option (text link, bottom)
9. ✅ Check-in saves to database (mood, energy, sleep, note, timestamp)
10. ✅ Accessibility: VoiceOver reads "Mood: Happy, 4 out of 5"

---

## Functional Requirements Covered

- **FR25:** Morning check-in with mood, energy, sleep ratings
- **FR27:** Check-in data used for AI personalization

---

## UX Notes

- Modal card (swipe down to dismiss NOT allowed - must complete or skip)
- Emoji sliders: 😢 😞 😐 😊 😄 for mood
- Default mid-point (3/5) if user doesn't adjust
- Loading indicator during AI generation: "Generating your perfect day..." (animated sparkle)
- Target completion time: <60 seconds

**Design Reference:** UX Design Specification - Life Coach Module

---

## Technical Implementation

### Frontend (Flutter)

**File:** `lib/features/life_coach/presentation/widgets/morning_checkin_modal.dart`

**Key Components:**
```dart
class MorningCheckinModal extends ConsumerStatefulWidget {
  @override
  State<MorningCheckinModal> createState() => _MorningCheckinModalState();
}

class _MorningCheckinModalState extends ConsumerState<MorningCheckinModal> {
  int mood = 3;
  int energy = 3;
  int sleepQuality = 3;
  String? note;

  Future<void> submitCheckin() async {
    final checkin = CheckinEntity(
      userId: ref.read(authProvider).userId!,
      date: DateTime.now(),
      mood: mood,
      energy: energy,
      sleepQuality: sleepQuality,
      note: note,
    );

    await ref.read(checkinUseCaseProvider).saveCheckin(checkin);

    // Trigger AI daily plan generation
    await ref.read(dailyPlanUseCaseProvider).generatePlan(
      mood: mood,
      energy: energy,
      sleepQuality: sleepQuality,
    );

    Navigator.pop(context);
  }
}
```

**Emoji Slider Widget:**
```dart
class EmojiSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<String> emojis;

  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(index + 1);
              },
              child: Text(
                emojis[index],
                style: TextStyle(
                  fontSize: value == index + 1 ? 48 : 32,
                ),
              ),
            );
          }),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged(v.toInt());
          },
        ),
      ],
    );
  }
}
```

### Backend (Supabase)

**Database Schema:**
```sql
CREATE TABLE check_ins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  mood INT NOT NULL CHECK (mood BETWEEN 1 AND 5),
  energy INT NOT NULL CHECK (energy BETWEEN 1 AND 5),
  sleep_quality INT NOT NULL CHECK (sleep_quality BETWEEN 1 AND 5),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, date)
);

CREATE INDEX idx_checkins_user_date ON check_ins(user_id, date DESC);

-- RLS Policies
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own check-ins" ON check_ins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own check-ins" ON check_ins
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own check-ins" ON check_ins
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## Dependencies

**Prerequisites:**
- Epic 1 (auth, data sync) - COMPLETE
- Story 2.2 (AI Daily Plan Generation) - Linked (generates plan after check-in)

**Blocks:**
- Story 2.5 (Evening Reflection - similar UI pattern)
- Story 2.6 (Streak Tracking - uses check-in data)
- Story 2.7 (Progress Dashboard - displays check-in trends)

---

## Testing Requirements

### Unit Tests
```dart
test('should save check-in with valid data')
test('should default to mid-point (3) for all ratings')
test('should trigger daily plan generation on submit')
test('should allow skip without saving')
```

### Widget Tests
```dart
testWidgets('should display emoji sliders')
testWidgets('should show haptic feedback on selection')
testWidgets('should show loading during AI generation')
testWidgets('should navigate away after submit')
```

### Integration Tests
```dart
testWidgets('complete morning check-in flow')
testWidgets('check-in syncs across devices')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] Modal appears on first app open (if not done today)
- [ ] Emoji sliders work (mood, energy, sleep)
- [ ] Haptic feedback on selection
- [ ] Note field optional
- [ ] "Generate My Plan" triggers AI
- [ ] "Skip" option works
- [ ] Check-in saves to database
- [ ] Syncs across devices
- [ ] Accessibility support (VoiceOver)
- [ ] Unit tests pass (80%+ coverage)
- [ ] Widget tests pass
- [ ] Integration test passes
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**UX Principles:**
- MAX 60 seconds completion time
- Swipe-down disabled (must complete or skip)
- Default mid-point reduces friction
- Haptic feedback = delightful micro-interaction

**Performance:**
- Modal renders in <100ms
- AI plan generation in <3s (shows loading state)

---

## Related Stories

- **Next:** Story 2.2 (AI Daily Plan Generation)
- **Enables:** Story 2.5 (Evening Reflection), 2.6 (Streak Tracking), 2.7 (Progress Dashboard)

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [2-1-morning-check-in-flow.context.xml](./2-1-morning-check-in-flow.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
**Updated:** 2025-11-17 - Context generated, status changed to ready-for-dev
