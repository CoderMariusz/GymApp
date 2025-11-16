# Story 3.3: Workout Logging with Rest Timer

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P0 | **Status:** drafted | **Effort:** 3 SP

---

## User Story
**As a** user during a workout
**I want** to log sets with automatic rest timer
**So that** I track my workout and rest appropriately

---

## Acceptance Criteria
1. ✅ User logs set → Rest timer auto-starts (default 90s, customizable)
2. ✅ Timer shown as countdown (large, readable)
3. ✅ Haptic + sound when rest complete
4. ✅ Skip rest (tap "Next Set")
5. ✅ Adjust rest time mid-workout (tap timer)
6. ✅ Workout duration tracked (start to finish)
7. ✅ Add notes to workout ("Felt strong today")
8. ✅ Add notes to sets ("Failed last rep")
9. ✅ Workout saves when "Complete Workout" tapped

**FRs:** FR34, FR35, FR36

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  duration INT, -- seconds
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE workout_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id),
  set_number INT NOT NULL,
  reps INT NOT NULL,
  weight DECIMAL(5, 2), -- 999.99 kg
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Rest Timer Widget
```dart
class RestTimer extends StatefulWidget {
  final int duration;

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          playSound('rest_complete.mp3');
        }
      });
    controller.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: controller.value,
        );
      },
    );
  }
}
```

---

## Dependencies
**Prerequisites:** Story 3.1 (Smart Pattern), Story 3.2 (Exercise Library)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
