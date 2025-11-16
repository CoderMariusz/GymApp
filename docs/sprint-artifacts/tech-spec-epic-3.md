# Epic Technical Specification: Fitness Coach MVP

Date: 2025-01-16
Author: Mariusz
Epic ID: epic-3
Status: Draft

---

## Overview

Epic 3 delivers the Fitness Coach AI module, a premium feature (2.99 EUR/month) that provides comprehensive workout tracking, smart exercise pattern memory, progress analytics, and AI-powered training recommendations. This module is designed for serious lifters and fitness enthusiasts who demand **speed** (<2s per set logging) and **offline-first** reliability.

The epic implements 10 user stories covering the complete fitness tracking workflow: ultra-fast workout logging with Smart Pattern Memory (pre-fills last workout data), 500+ exercise library with search, rest timers, workout history, progress charts (strength gains, volume, personal records), body measurements, workout templates, quick log mode for rapid entry, exercise form tips, and cross-module stress data integration from Mind module.

**Key Differentiator:** Smart Pattern Memory auto-fills exercise data from last session, enabling <2s per set logging (industry best: 5-8s).

## Objectives and Scope

**In Scope:**
- ✅ Smart Pattern Memory (auto-fill last workout data for instant logging)
- ✅ Exercise library (500+ exercises, searchable, filterable by muscle group/equipment)
- ✅ Workout logging (sets, reps, weight, RPE, notes)
- ✅ Rest timer (auto-start after set completion, customizable 30s-5min)
- ✅ Workout history (calendar view, detail view, edit/delete)
- ✅ Progress charts (1RM strength trend, total volume, personal records timeline)
- ✅ Body measurements tracking (weight, body fat %, muscle mass, photos)
- ✅ Workout templates (pre-built programs + user custom templates)
- ✅ Quick Log mode (rapid entry for advanced users, <30s full workout)
- ✅ Exercise instructions (video/GIF demos, form tips, muscle activation)
- ✅ Cross-module: Receive stress data from Mind module (adjust workout intensity)

**Out of Scope (Deferred to P1/P2):**
- ❌ AR form analysis (camera-based rep counting, form correction) - P1
- ❌ AI training plan generator - P1
- ❌ Social features (share workouts, compete with friends) - P2 (Tandem Mode)
- ❌ Wearable integration (Apple Watch, Garmin) - P1
- ❌ Nutrition tracking - P2 (separate module)
- ❌ Barcode scanner for equipment weights - P2

## System Architecture Alignment

**Aligned to Architecture Decisions:**
- **D1 (Hybrid Architecture):** Fitness module in `lib/features/fitness/` with clean architecture
- **D2 (Shared Schema):** Uses `user_daily_metrics` table (workout_completed, duration, calories), `workouts` and `exercises` tables
- **D3 (Offline-First Sync):** ALL workout operations save to Drift first (<100ms), sync to Supabase when online
- **D13 (Tiered Cache):** Exercise library (critical tier - 15MB bundled), exercise videos (lazy load on WiFi)
- **Smart Pattern Memory:** Query Drift for last workout with same exercise (instant <20ms query)

**Architecture Components:**
- **Frontend:** Flutter 3.38+, Riverpod 3.0, Drift (SQLite), fl_chart (progress charts)
- **Backend:** Supabase (PostgreSQL, Storage for exercise videos, Realtime for multi-device sync)
- **Cache Strategy:** Exercise library cached locally (500+ exercises, ~10MB), videos lazy-loaded
- **Multimedia:** cached_network_image (exercise thumbnails), video_player (form videos)

**Database Schema (Epic 3 Tables):**
```sql
-- Fitness specific tables
workouts (id, user_id, name, scheduled_at, completed_at, duration_minutes, calories_burned, notes, created_at)
exercises (id, workout_id, exercise_library_id, sets JSONB, created_at)
  -- sets: [{ weight: 100, reps: 5, rpe: 8, rest_seconds: 90 }, ...]
exercise_library (id, name, muscle_group, equipment, instructions, video_url, thumbnail_url)
workout_templates (id, user_id, name, exercises JSONB, is_public, created_at)
body_measurements (id, user_id, weight_kg, body_fat_percentage, muscle_mass_kg, photo_url, date, created_at)
personal_records (id, user_id, exercise_library_id, weight_kg, reps, estimated_1rm, date, created_at)
```

**Constraints:**
- Workout logging must work offline (NFR-P4)
- Set logging target: <2s per set (Smart Pattern Memory)
- Exercise library size: <15MB bundled (500+ exercises)
- Video streaming: WiFi-only mode (user preference to avoid cellular data)

---

## Detailed Design

### Services and Modules

| Service/Module | Responsibilities | Inputs | Outputs | Owner |
|----------------|-----------------|--------|---------|-------|
| **WorkoutService** | Manage workouts (create, complete, history) | Workout model | Result<Workout> | Fitness Team |
| **ExerciseService** | Log exercises with sets/reps/weight | Exercise model, Sets data | Result<Exercise> | Fitness Team |
| **SmartPatternService** | Auto-fill last workout data | Exercise ID, User ID | PatternData | Fitness Team |
| **RestTimerService** | Countdown timer between sets | Rest duration (seconds) | TimerState stream | Fitness Team |
| **ProgressService** | Calculate strength gains, volume, PRs | Time range, Exercise ID | ProgressReport | Fitness Team |
| **BodyMeasurementService** | Track body composition | Measurement model, Photo | Result<Measurement> | Fitness Team |
| **TemplateService** | Manage workout templates | Template model | Result<Template> | Fitness Team |
| **ExerciseLibraryService** | Search/filter 500+ exercises | Search query, Filters | List<ExerciseLibraryItem> | Fitness Team |
| **FormTipsService** | Provide exercise instructions | Exercise ID | FormGuide | Fitness Team |

**Service Dependencies:**
```
WorkoutService → SmartPatternService (load last workout data)
              → ProgressService (update PR if new record)
              → user_daily_metrics table (aggregate workout_completed)

ExerciseService → RestTimerService (auto-start timer after set logged)

ProgressService → workouts + exercises tables (aggregate data)
                → personal_records table (detect PRs)

TemplateService → ExerciseLibraryService (validate exercise IDs in template)
```

---

### Data Models and Contracts

#### Workout Model
```dart
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String userId,
    String? name,                      // Optional: "Push Day A" or null (auto-generated)
    DateTime? scheduledAt,             // Future workout (template)
    DateTime? completedAt,             // Actual completion time
    int? durationMinutes,              // Total workout duration
    int? caloriesBurned,               // Estimated from weight/reps/duration
    String? notes,                     // Post-workout notes
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Workout;

  // Computed property: is workout completed
  bool get isCompleted => completedAt != null;

  // Computed property: is workout scheduled for future
  bool get isScheduled => scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
}
```

#### Exercise Model
```dart
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String workoutId,
    required String exerciseLibraryId,  // FK to exercise_library
    required List<ExerciseSet> sets,
    String? notes,                       // Exercise-specific notes
    required DateTime createdAt,
  }) = _Exercise;

  // Computed property: total volume (weight × reps for all sets)
  int get totalVolume {
    return sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  }

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}

@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    required int setNumber,             // 1, 2, 3, ...
    required double weight,             // kg (or lbs based on user preference)
    required int reps,
    int? rpe,                           // Rate of Perceived Exertion (1-10), optional
    int? restSeconds,                   // Rest time after this set
    required DateTime completedAt,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);
}
```

#### ExerciseLibraryItem Model
```dart
@freezed
class ExerciseLibraryItem with _$ExerciseLibraryItem {
  const factory ExerciseLibraryItem({
    required String id,
    required String name,                  // "Barbell Bench Press"
    required MuscleGroup primaryMuscle,
    List<MuscleGroup>? secondaryMuscles,
    required EquipmentType equipment,
    String? instructions,                  // Text instructions
    String? videoUrl,                      // Supabase Storage URL
    String? thumbnailUrl,                  // Cached thumbnail
    required Difficulty difficulty,
  }) = _ExerciseLibraryItem;

  factory ExerciseLibraryItem.fromJson(Map<String, dynamic> json) => _$ExerciseLibraryItemFromJson(json);
}

enum MuscleGroup {
  chest, back, shoulders, biceps, triceps, legs, glutes, abs, cardio
}

enum EquipmentType {
  barbell, dumbbell, machine, cable, bodyweight, kettlebell, bands
}

enum Difficulty {
  beginner, intermediate, advanced
}
```

#### SmartPattern Model
```dart
@freezed
class SmartPattern with _$SmartPattern {
  const factory SmartPattern({
    required String exerciseLibraryId,
    required List<ExerciseSet> lastSets,   // Pre-filled data from last workout
    required DateTime lastPerformed,
  }) = _SmartPattern;

  factory SmartPattern.fromJson(Map<String, dynamic> json) => _$SmartPatternFromJson(json);
}
```

#### BodyMeasurement Model
```dart
@freezed
class BodyMeasurement with _$BodyMeasurement {
  const factory BodyMeasurement({
    required String id,
    required String userId,
    required double weightKg,
    double? bodyFatPercentage,
    double? muscleMassKg,
    String? photoUrl,                     // Supabase Storage (optional progress photo)
    required DateTime date,
    required DateTime createdAt,
  }) = _BodyMeasurement;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) => _$BodyMeasurementFromJson(json);
}
```

#### WorkoutTemplate Model
```dart
@freezed
class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    String? userId,                       // null for pre-built templates
    required String name,                 // "Push Day A", "5x5 Stronglifts"
    String? description,
    required List<TemplateExercise> exercises,
    @Default(false) bool isPublic,        // Share template with community (P2 feature)
    required DateTime createdAt,
  }) = _WorkoutTemplate;

  // Computed property: is pre-built template
  bool get isPreBuilt => userId == null;

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) => _$WorkoutTemplateFromJson(json);
}

@freezed
class TemplateExercise with _$TemplateExercise {
  const factory TemplateExercise({
    required String exerciseLibraryId,
    required int sets,
    required int reps,
    int? weight,                          // Optional suggested weight
    int? restSeconds,
  }) = _TemplateExercise;

  factory TemplateExercise.fromJson(Map<String, dynamic> json) => _$TemplateExerciseFromJson(json);
}
```

---

### APIs and Interfaces

#### WorkoutService Interface
```dart
abstract class WorkoutService {
  /// Start new workout
  Future<Result<Workout>> startWorkout({String? name});

  /// Complete workout (marks as done, calculates duration)
  Future<Result<Workout>> completeWorkout(String workoutId);

  /// Get workout by ID
  Future<Result<Workout>> getWorkout(String workoutId);

  /// Get workout history (paginated)
  Future<Result<List<Workout>>> getWorkoutHistory({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 50,
    int offset = 0,
  });

  /// Delete workout
  Future<Result<void>> deleteWorkout(String workoutId);

  /// Edit workout (name, notes)
  Future<Result<Workout>> updateWorkout({
    required String workoutId,
    String? name,
    String? notes,
  });
}
```

#### ExerciseService Interface
```dart
abstract class ExerciseService {
  /// Add exercise to workout
  Future<Result<Exercise>> addExercise({
    required String workoutId,
    required String exerciseLibraryId,
  });

  /// Log set for exercise
  /// Triggers: Rest timer auto-start, PR detection, Smart Pattern update
  Future<Result<Exercise>> logSet({
    required String exerciseId,
    required double weight,
    required int reps,
    int? rpe,
  });

  /// Update set (edit logged set)
  Future<Result<Exercise>> updateSet({
    required String exerciseId,
    required int setNumber,
    double? weight,
    int? reps,
    int? rpe,
  });

  /// Delete set
  Future<Result<Exercise>> deleteSet({
    required String exerciseId,
    required int setNumber,
  });

  /// Get exercise details with all sets
  Future<Result<Exercise>> getExercise(String exerciseId);
}
```

#### SmartPatternService Interface
```dart
abstract class SmartPatternService {
  /// Get last workout data for exercise
  /// Returns: Sets from last workout (weight, reps, RPE) for instant pre-fill
  /// Query time: <20ms (Drift local query)
  Future<SmartPattern?> getLastWorkoutPattern(String exerciseLibraryId);

  /// Get typical rest time for exercise (based on last 5 workouts)
  Future<int?> getSuggestedRestTime(String exerciseLibraryId);

  /// Clear pattern cache (force refresh)
  Future<void> clearPatternCache();
}
```

#### RestTimerService Interface
```dart
abstract class RestTimerService {
  /// Start rest timer (called automatically after set logged)
  void startTimer(int seconds);

  /// Pause timer
  void pauseTimer();

  /// Resume timer
  void resumeTimer();

  /// Skip timer (start next set immediately)
  void skipTimer();

  /// Get timer state stream
  Stream<RestTimerState> get timerStateStream;
}

@freezed
class RestTimerState with _$RestTimerState {
  const factory RestTimerState({
    @Default(0) int remainingSeconds,
    @Default(0) int totalSeconds,
    @Default(false) bool isRunning,
    @Default(false) bool isPaused,
  }) = _RestTimerState;

  // Computed property: progress percentage
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
}
```

#### ProgressService Interface
```dart
abstract class ProgressService {
  /// Get strength progress for exercise (1RM trend over time)
  Future<Result<List<ProgressDataPoint>>> getStrengthProgress({
    required String exerciseLibraryId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get total volume trend (all exercises combined)
  Future<Result<List<ProgressDataPoint>>> getVolumeProgress({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get personal records for all exercises
  Future<Result<List<PersonalRecord>>> getPersonalRecords();

  /// Detect if new PR achieved (called after set logged)
  Future<PersonalRecord?> detectNewPR({
    required String exerciseLibraryId,
    required double weight,
    required int reps,
  });
}

@freezed
class ProgressDataPoint with _$ProgressDataPoint {
  const factory ProgressDataPoint({
    required DateTime date,
    required double value,    // Weight (kg) or Volume (kg)
  }) = _ProgressDataPoint;
}

@freezed
class PersonalRecord with _$PersonalRecord {
  const factory PersonalRecord({
    required String id,
    required String exerciseLibraryId,
    required String exerciseName,      // Denormalized for display
    required double weightKg,
    required int reps,
    required double estimated1RM,      // Calculated using Epley formula
    required DateTime achievedAt,
  }) = _PersonalRecord;

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => _$PersonalRecordFromJson(json);
}
```

---

### Workflows and Sequencing

#### Workflow 1: Smart Pattern Memory - Lightning Fast Workout Logging (Story 3.1)
```
1. User opens "Log Workout" screen
   ↓
2. User taps "Start Workout" button
   ↓
3. WorkoutService.startWorkout() → Creates workout record in Drift
   ↓ (instant, <50ms)
4. User taps "+ Add Exercise" button
   ↓
5. Exercise library search screen appears (500+ exercises cached locally)
   ↓
6. User types "bench" → Autocomplete filters to "Barbell Bench Press"
   ↓
7. User selects "Barbell Bench Press"
   ↓
8. ExerciseService.addExercise() called
   ↓
9. 🚀 SMART PATTERN MEMORY TRIGGERS:
   - SmartPatternService.getLastWorkoutPattern('bench-press') called
   - Query Drift for last workout with this exercise (<20ms)
   - Returns last sets: [
       {weight: 100kg, reps: 5, rpe: 8},
       {weight: 100kg, reps: 5, rpe: 8},
       {weight: 100kg, reps: 4, rpe: 9}
     ]
   ↓
10. Set logging screen PRE-FILLED with last workout data:
    Set 1: [100kg] [5 reps] (sliders pre-positioned)
    Set 2: [100kg] [5 reps]
    Set 3: [100kg] [4 reps]
    ↓
11. User ONLY needs to adjust if different from last time:
    - Swipe weight slider up to 102.5kg (progressive overload)
    - Tap "Log Set 1" button
    ↓ (<2s elapsed from opening screen!)
12. ExerciseService.logSet() called
    ↓
13. Save to Drift → Instant feedback (checkmark animation)
    ↓
14. RestTimerService auto-starts (90s default for this exercise)
    ↓
15. Show timer overlay: "Next set in 1:30"
    ↓
16. User adjusts reps to 4 (fatigue from first set)
    ↓
17. Tap "Log Set 2" → <1s (already pre-filled!)
    ↓
18. Timer auto-starts again (90s)
    ↓
19. Repeat for Set 3...
    ↓
20. Total time for 3 sets: ~6 seconds of actual input 🚀
    ↓
21. User completes workout (all exercises)
    ↓
22. Tap "Finish Workout" button
    ↓
23. WorkoutService.completeWorkout() → Calculates duration, calories
    ↓
24. Sync to Supabase (background, opportunistic)
    ↓
25. DONE ✅ - Workout logged in minutes, not hours!
```

#### Workflow 2: Progress Charts - Visualize Strength Gains (Story 3.5)
```
1. User navigates to "Progress" tab
   ↓
2. Screen shows tabs:
   - Strength (1RM trends per exercise)
   - Volume (total weight × reps over time)
   - Personal Records (timeline of PRs)
   ↓
3. User selects "Strength" tab
   ↓
4. User taps "Barbell Bench Press" from exercise dropdown
   ↓
5. ProgressService.getStrengthProgress('bench-press', last90Days) called
   ↓
6. Service queries Drift:
   - Fetch all bench press exercises from last 90 days
   - Calculate estimated 1RM for each workout using Epley formula:
     1RM = weight × (1 + reps / 30)
   - Group by date, aggregate max 1RM per day
   ↓
7. Data points returned: [
     {date: 2024-11-01, value: 110kg},
     {date: 2024-11-08, value: 112kg},
     {date: 2024-11-15, value: 115kg},
     ...
   ]
   ↓
8. fl_chart renders line chart:
   - X-axis: Dates (Nov 1 - Jan 16)
   - Y-axis: 1RM weight (kg)
   - Trend line shows 5kg gain over 90 days 📈
   ↓
9. User can tap data point to see workout details (drill-down)
   ↓
10. User switches to "Volume" tab
    ↓
11. ProgressService.getVolumeProgress(last90Days) called
    ↓
12. Service calculates total volume per workout:
    Volume = Σ (weight × reps) for all exercises
    ↓
13. Bar chart shows weekly volume trend
    ↓
14. User switches to "Personal Records" tab
    ↓
15. ProgressService.getPersonalRecords() called
    ↓
16. Timeline shows PRs with celebrations:
    - Jan 10: Deadlift 180kg (🎉 New PR!)
    - Dec 20: Squat 150kg
    - Nov 15: Bench Press 115kg
    ↓
17. DONE ✅ - User motivated by visible progress!
```

#### Workflow 3: Workout Templates - Reusable Programs (Story 3.7)
```
1. User navigates to "Templates" tab
   ↓
2. Screen shows:
   - Pre-built templates (5x5 Stronglifts, PPL, Upper/Lower)
   - User custom templates
   ↓
3. User taps "Create Custom Template" button
   ↓
4. Template creation screen appears
   ↓
5. User enters name: "Push Day A"
   ↓
6. User taps "+ Add Exercise"
   ↓
7. Selects exercises from library:
   - Barbell Bench Press (4 sets × 5 reps)
   - Incline Dumbbell Press (3 sets × 8 reps)
   - Overhead Press (3 sets × 6 reps)
   - Tricep Dips (3 sets × 10 reps)
   ↓
8. User taps "Save Template"
   ↓
9. TemplateService.createTemplate() → Saves to Drift + Supabase
   ↓
10. Template appears in "My Templates" list
    ↓
11. Next workout day, user taps "Start from Template"
    ↓
12. Selects "Push Day A" template
    ↓
13. WorkoutService creates new workout pre-populated with exercises
    ↓
14. Smart Pattern Memory STILL works:
    - Pre-fills last performed weight/reps for each exercise
    - User only adjusts if needed (progressive overload)
    ↓
15. User logs sets normally (same fast workflow)
    ↓
16. DONE ✅ - Consistent program execution, zero planning overhead!
```

#### Workflow 4: Cross-Module - Stress Data Integration (Story 3.10)
```
1. User completes evening reflection in Mind module
   ↓
2. Stress level logged: 8/10 (High stress)
   ↓
3. Mind module writes to user_daily_metrics:
   UPDATE user_daily_metrics
   SET stress_level = 8
   WHERE user_id = '...' AND date = CURRENT_DATE
   ↓
4. Next morning, user opens Fitness module
   ↓
5. User taps "Start Workout" (heavy deadlift session scheduled)
   ↓
6. WorkoutService.startWorkout() called
   ↓
7. Service checks user_daily_metrics for today:
   - stress_level = 8 (HIGH)
   - workout_intensity scheduled = 0.9 (HEAVY)
   ↓
8. 🧠 CROSS-MODULE INTELLIGENCE TRIGGERS:
   - If stress_level > 7 AND workout_intensity > 0.8:
     - Show warning banner:
       "High stress detected. Consider a lighter session today."
     - Suggest deload template (60% weight, same exercises)
   ↓
9. User sees warning with 2 options:
   - [A] Continue with planned workout (heavy)
   - [B] Switch to deload session (light)
   ↓
10. User taps [B] "Switch to deload"
    ↓
11. TemplateService loads deload template
    - Same exercises, but weight reduced to 60%
    - Reps increased to 8-10 (hypertrophy range)
    ↓
12. User completes lighter workout
    ↓
13. Avoids overtraining + injury risk 🎯
    ↓
14. Evening: User completes reflection, stress now 5/10 (Moderate)
    ↓
15. Next day: No warning, resume normal training
    ↓
16. DONE ✅ - AI prevents burnout, optimizes recovery!
```

---

## Non-Functional Requirements

### Performance

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-FIT1 | Set logging speed | <2s per set | Smart Pattern Memory pre-fills data, optimized Drift queries |
| NFR-P4 | Offline mode | Full functionality | All CRUD operations save to Drift first, sync when online |
| NFR-FIT2 | Exercise library search | <100ms | 500+ exercises cached locally, indexed by name/muscle group |
| NFR-P5 | UI response time | <100ms | Riverpod optimistic updates, instant visual feedback |
| NFR-FIT3 | Workout history load | <500ms | Paginated queries (50 workouts per page), Drift indexing |

**Performance Benchmarks:**
- Start workout: 50ms (Drift insert)
- Add exercise with Smart Pattern Memory: 70ms (query last workout + pre-fill UI)
- Log set: 30ms (Drift insert + update)
- Exercise library search: 50ms (Drift full-text search)
- Load workout history (50 items): 200ms (Drift query with pagination)
- **Total set logging workflow: 1.5s** ✅ (target: <2s)

### Security

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-S2 | GDPR compliance | Data export includes workouts | Include workouts, exercises, measurements, PRs in ZIP export |
| NFR-S6 | Photo privacy | Progress photos E2EE optional | User can enable E2EE for body measurement photos |

### Reliability/Availability

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-R3 | Data loss prevention | <0.1% | Sync queue with retry, local Drift persistence |
| NFR-FIT4 | Workout recovery | Restore after app crash | Auto-save workout state every 10s, resume on app restart |

**Crash Recovery:**
- Workout state saved to Drift every 10 seconds
- On app restart, prompt: "Continue your workout from 15 minutes ago?"
- Restore workout with all logged sets intact

### Observability

**Metrics to Track:**
- Average set logging time (target: <2s p95)
- Workout completion rate (target: 80%+ - finish what you start)
- Smart Pattern Memory usage rate (target: 90%+ of exercises use pre-fill)
- Exercise library search abandonment rate
- Personal record achievement rate (gamification metric)

**Alerts:**
- 🚨 Set logging time >5s p95 (UX degraded, investigate Smart Pattern Memory)
- 🚨 Workout crash recovery usage >5% (app stability issue)
- 🚨 Sync queue length >50 items (sync service degraded)

---

## Dependencies and Integrations

### Flutter Dependencies (Epic 3 Specific)
```yaml
dependencies:
  # Charts & Visualization
  fl_chart: ^0.68.0            # Progress charts, strength trends

  # Timers
  circular_countdown_timer: ^0.2.3  # Rest timer UI

  # Video playback
  video_player: ^2.8.6         # Exercise form videos
  cached_video_player: ^2.0.4  # Cache videos for offline

  # Image handling
  image_picker: ^1.0.7         # Body measurement photos
  image_cropper: ^5.0.1        # Crop progress photos
  cached_network_image: ^3.3.1 # Exercise thumbnails

  # Search
  flutter_typeahead: ^5.2.0    # Exercise library autocomplete
```

### Exercise Library Data Source

**Source:** Pre-built SQLite database (exercise_library table)
- **Size:** ~10MB (500+ exercises with metadata)
- **Content:** Exercise name, muscle group, equipment, instructions, video URLs
- **Bundled:** Included in app bundle (critical tier cache)
- **Updates:** Delta updates via Supabase (new exercises added monthly)

**Schema:**
```sql
CREATE TABLE exercise_library (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  muscle_group TEXT NOT NULL,
  equipment TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  instructions TEXT,
  video_url TEXT,
  thumbnail_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_name ON exercise_library(name);
CREATE INDEX idx_muscle_group ON exercise_library(muscle_group);
CREATE INDEX idx_equipment ON exercise_library(equipment);
```

### Cross-Module Integration

**Integration with Mind Module (Story 3.10):**
- **Data flow:** Mind module writes `stress_level` to `user_daily_metrics` table
- **Fitness reads:** Query `user_daily_metrics.stress_level` on workout start
- **Action:** If stress > 7, suggest deload workout (60% weight, higher reps)
- **Implementation:** Supabase Realtime subscription on `user_daily_metrics` (live updates)

---

## Acceptance Criteria (Authoritative)

### Story 3.1: Smart Pattern Memory
1. ✅ User opens "Log Workout" modal
2. ✅ If exercise logged before, app pre-fills last session's data:
   - Exercise name
   - Sets (same count as last time)
   - Reps per set (same as last time)
   - Weight per set (same as last time)
3. ✅ If first time logging exercise, show empty form
4. ✅ User can swipe up/down on weight to increment/decrement (5kg/10lbs increments)
5. ✅ User can tap reps to edit (number picker modal)
6. ✅ User taps checkmark → Set logged (<2s target)
7. ✅ Haptic feedback on check (light tap)
8. ✅ Offline-first (works without internet)
9. ✅ Data synced when online

### Story 3.2: Exercise Library (500+ Exercises)
1. ✅ User can search by exercise name (autocomplete, fuzzy matching)
2. ✅ User can filter by muscle group (chest, back, legs, etc.)
3. ✅ User can filter by equipment (barbell, dumbbell, bodyweight, etc.)
4. ✅ User can favorite exercises (quick access)
5. ✅ Exercise list shows thumbnail + name + muscle group
6. ✅ Tapping exercise shows detail view (instructions, video)
7. ✅ Library cached locally (works offline)

### Story 3.3: Workout Logging with Rest Timer
1. ✅ User logs set → Rest timer auto-starts (default 90s, customizable 30s-5min)
2. ✅ Timer shown as overlay (countdown + progress circle)
3. ✅ User can pause/resume timer
4. ✅ User can skip timer (start next set immediately)
5. ✅ Timer plays sound + vibration when finished (notification)
6. ✅ Timer persists if user switches to another exercise
7. ✅ User can adjust default rest time per exercise (settings)

### Story 3.4: Workout History & Detail View
1. ✅ User can view workout history (calendar view or list view)
2. ✅ User can filter by date range (last 7/30/90 days, all time)
3. ✅ Each workout shows: name, date, duration, exercises count
4. ✅ Tapping workout opens detail view (all exercises + sets)
5. ✅ User can edit workout (name, notes, individual sets)
6. ✅ User can delete workout (confirmation dialog, soft delete)

### Story 3.5: Progress Charts (Strength, Volume, PRs)
1. ✅ User can view strength progress chart (1RM trend per exercise)
2. ✅ User can view volume progress chart (total weight × reps over time)
3. ✅ User can view personal records timeline (all exercises, sorted by date)
4. ✅ Charts show last 30/90/365 days (date range selector)
5. ✅ Tapping data point shows workout details (drill-down)
6. ✅ PR achievements highlighted with badge icon
7. ✅ Trend lines show direction (gaining/losing strength)

### Story 3.6: Body Measurements Tracking
1. ✅ User can log body weight (kg or lbs)
2. ✅ User can log body fat percentage (optional)
3. ✅ User can log muscle mass (optional)
4. ✅ User can upload progress photo (camera or gallery, max 10MB)
5. ✅ Photo compressed to 1024x1024px before upload
6. ✅ Measurements shown in line chart (weight trend over time)
7. ✅ Photos displayed in grid view (timeline)

### Story 3.7: Workout Templates (Pre-built + Custom)
1. ✅ User can browse pre-built templates (5x5 Stronglifts, PPL, Upper/Lower)
2. ✅ User can create custom template (name, list of exercises with sets/reps)
3. ✅ User can start workout from template (exercises pre-populated)
4. ✅ User can edit template (add/remove exercises, adjust sets/reps)
5. ✅ User can delete template (confirmation dialog)
6. ✅ Templates stored locally + Supabase (sync across devices)

### Story 3.8: Quick Log (Rapid Workout Entry)
1. ✅ User can enable "Quick Log" mode (settings toggle)
2. ✅ Quick Log shows condensed UI (minimal taps, keyboard-friendly)
3. ✅ User can log entire workout in <30 seconds (advanced users)
4. ✅ Quick Log uses Smart Pattern Memory (auto-fill)
5. ✅ User can swipe between exercises (horizontal carousel)
6. ✅ User can switch back to normal mode anytime

### Story 3.9: Exercise Instructions & Form Tips
1. ✅ User can tap exercise to view instructions
2. ✅ Instructions include: muscle activation diagram, setup, execution, common mistakes
3. ✅ Video demo available (15-30s loop, muted autoplay)
4. ✅ User can play video with sound (tap video)
5. ✅ User can favorite form tips (quick reference)

### Story 3.10: Cross-Module: Receive Stress Data from Mind
1. ✅ Fitness module reads stress_level from user_daily_metrics table
2. ✅ If stress_level > 7 AND workout_intensity > 0.8, show warning:
   "High stress detected. Consider a lighter session today."
3. ✅ User can choose: [A] Continue with planned workout, [B] Switch to deload
4. ✅ Deload template loads with 60% weight, 8-10 reps
5. ✅ Warning only shown once per day (dismissible)

---

## Traceability Mapping

| AC | Spec Section | Component/API | Test Strategy |
|----|--------------|---------------|---------------|
| Story 3.1 AC1-9 | Workflows → Smart Pattern Memory, APIs → SmartPatternService | getLastWorkoutPattern() | Unit: Pattern query speed (<20ms), Integration: E2E pre-fill flow, Performance: 1000 queries benchmark |
| Story 3.2 AC1-7 | APIs → ExerciseLibraryService | searchExercises(), filterByMuscleGroup() | Unit: Search algorithm (fuzzy matching), Widget: Exercise list rendering, Integration: Offline cache validation |
| Story 3.3 AC1-7 | APIs → RestTimerService | startTimer(), timerStateStream | Unit: Timer countdown logic, Widget: Circular timer UI, Integration: Background timer (app minimized) |
| Story 3.4 AC1-6 | APIs → WorkoutService | getWorkoutHistory(), deleteWorkout() | Unit: Pagination logic, Widget: Calendar view rendering, Integration: Edit workout flow |
| Story 3.5 AC1-7 | APIs → ProgressService | getStrengthProgress(), detectNewPR() | Unit: 1RM calculation (Epley formula), Widget: fl_chart rendering, Integration: PR detection on set log |
| Story 3.6 AC1-7 | APIs → BodyMeasurementService | createMeasurement() | Unit: Photo compression, Widget: Photo upload UI, Integration: Supabase Storage upload |
| Story 3.7 AC1-6 | APIs → TemplateService | createTemplate(), startWorkoutFromTemplate() | Unit: Template validation, Widget: Template builder UI, Integration: Template sync |
| Story 3.8 AC1-6 | Data Models → UI Mode Toggle | Quick Log UI variant | Widget: Quick Log screen rendering, Performance: Input speed test |
| Story 3.9 AC1-5 | Services → FormTipsService | getFormGuide() | Widget: Video player integration, Integration: Video caching |
| Story 3.10 AC1-5 | Cross-Module → user_daily_metrics query | Stress data read | Integration: Supabase Realtime subscription, E2E: Mind → Fitness flow |

---

## Risks, Assumptions, Open Questions

### Risks

| Risk ID | Description | Probability | Impact | Mitigation | Owner |
|---------|-------------|-------------|--------|------------|-------|
| **RISK-E3-001** | Smart Pattern Memory fails if user switches devices mid-workout | Medium | Medium | Sync workout state to Supabase every 10s, resume on any device | Fitness Team |
| **RISK-E3-002** | Exercise library becomes outdated (new exercises released) | High | Low | Monthly delta updates via Supabase, auto-download on WiFi | Fitness Team |
| **RISK-E3-003** | Video streaming uses too much cellular data | Medium | Medium | WiFi-only mode (default), compress videos to <5MB | Fitness Team |
| **RISK-E3-004** | Users find 500+ exercises overwhelming | Low | Low | Smart search + muscle group filters, "Popular" section for beginners | UX Team |
| **RISK-E3-005** | Cross-module stress integration feels intrusive | Low | High | Make warning dismissible, add "Don't show again" option | Product Team |
| **RISK-E3-006** | Rest timer notifications annoying during workout | Medium | Low | Subtle notification (vibration only), user can disable in settings | Fitness Team |

### Assumptions

1. **User behavior:** Users prefer pre-filled data over empty forms (validated by Fitness app usability studies)
2. **Exercise library size:** 500 exercises sufficient for 95% of users (can expand in P1)
3. **Smart Pattern Memory accuracy:** Last workout is representative of next workout (handles progressive overload via slider adjustment)
4. **Offline usage:** 80% of workouts logged offline (gym WiFi unreliable)
5. **Video quality:** 480p resolution sufficient for form demos (balance quality vs file size)

### Open Questions

1. **Q:** Should we support custom exercises (user-created)?
   - **Answer:** Yes, but P1 feature (allow users to submit custom exercises for approval)

2. **Q:** What's the optimal default rest time? (Currently 90s)
   - **Answer:** A/B test 60s vs 90s vs 120s, segment by user skill level

3. **Q:** Should we integrate with Apple Health / Google Fit?
   - **Answer:** P1 feature (export workouts, sync body weight)

4. **Q:** How to handle users who want imperial units (lbs, inches)?
   - **Decision:** User preference setting (metric/imperial), conversion on display

---

## Test Strategy Summary

### Test Pyramid (70/20/10)

**Unit Tests (70%):**
- SmartPatternService: Pattern query logic, pre-fill data validation
- WorkoutService: CRUD operations, duration calculation
- ExerciseService: Set logging, volume calculation
- RestTimerService: Countdown logic, notification triggers
- ProgressService: 1RM calculation (Epley formula), PR detection
- BodyMeasurementService: Photo compression, measurement validation

**Widget Tests (20%):**
- Workout logging screen: Smart Pattern Memory pre-fill UI
- Exercise library screen: Search autocomplete, filter chips
- Rest timer overlay: Circular countdown, pause/resume buttons
- Progress charts: fl_chart rendering, data point drill-down
- Template builder: Exercise list, drag-drop reordering

**Integration Tests (10%):**
- E2E workout flow: Start → Add exercise → Log 3 sets → Finish
- E2E Smart Pattern Memory: Log workout → Exit → Log same exercise next day (pre-filled)
- E2E sync test: Log workout offline → Go online → Verify Supabase sync
- E2E PR detection: Log new personal record → Verify celebration animation
- Multi-device test: Start workout on phone → Continue on tablet

### Load Testing

**Offline Performance:**
- 1000 consecutive set logs (target: <30ms p95 per log)
- Exercise library search with 500 exercises (target: <100ms p95)

**Sync Performance:**
- 100 workouts queued for sync (target: all synced within 60s on WiFi)

### Example Test Case

```dart
// Unit test: SmartPatternService
test('should return last workout pattern for exercise', () async {
  // Arrange
  final lastWorkout = Workout(
    id: 'w1',
    userId: 'user1',
    completedAt: DateTime.now().subtract(Duration(days: 2)),
  );
  final lastExercise = Exercise(
    id: 'e1',
    workoutId: 'w1',
    exerciseLibraryId: 'bench-press',
    sets: [
      ExerciseSet(setNumber: 1, weight: 100, reps: 5, completedAt: DateTime.now()),
      ExerciseSet(setNumber: 2, weight: 100, reps: 5, completedAt: DateTime.now()),
    ],
  );
  when(mockRepository.getLastExercise('bench-press'))
    .thenAnswer((_) async => Success(lastExercise));

  // Act
  final pattern = await patternService.getLastWorkoutPattern('bench-press');

  // Assert
  expect(pattern, isNotNull);
  expect(pattern!.lastSets.length, 2);
  expect(pattern.lastSets[0].weight, 100);
  expect(pattern.lastSets[0].reps, 5);
});

// Integration test: Smart Pattern Memory E2E
testWidgets('should pre-fill exercise data from last workout', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  await loginUser(tester);
  await logWorkout(tester, exerciseName: 'Bench Press', weight: 100, reps: 5, sets: 3);  // Day 1
  await Future.delayed(Duration(seconds: 1));  // Simulate next day

  // Act
  await tester.tap(find.text('Start Workout'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('+ Add Exercise'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Bench');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bench Press'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('100 kg'), findsNWidgets(3));  // Pre-filled weight for 3 sets
  expect(find.text('5 reps'), findsNWidgets(3));  // Pre-filled reps for 3 sets
  verify(mockPatternService.getLastWorkoutPattern('bench-press')).called(1);
});
```

---

## Implementation Checklist

**Phase 1: Core Workout Logging (3 days)**
- [ ] Implement WorkoutService (start, complete, history)
- [ ] Implement ExerciseService (add, log set, update, delete)
- [ ] Create workout logging screen (minimal UI)
- [ ] Setup Drift schema (workouts, exercises tables)
- [ ] Write unit tests for core services

**Phase 2: Smart Pattern Memory (2 days)**
- [ ] Implement SmartPatternService (query last workout)
- [ ] Add pre-fill logic to exercise logging UI
- [ ] Optimize Drift queries (<20ms target)
- [ ] Add haptic feedback on set log
- [ ] Write integration tests for pre-fill flow

**Phase 3: Exercise Library (2 days)**
- [ ] Bundle exercise library SQLite database (500+ exercises)
- [ ] Implement ExerciseLibraryService (search, filter)
- [ ] Create exercise library screen (autocomplete, filters)
- [ ] Add exercise detail view (instructions, video)
- [ ] Write widget tests for search UI

**Phase 4: Rest Timer (1 day)**
- [ ] Implement RestTimerService (countdown, notifications)
- [ ] Create rest timer overlay UI (circular progress)
- [ ] Add timer controls (pause, resume, skip)
- [ ] Test background timer (app minimized)

**Phase 5: Progress Charts (2 days)**
- [ ] Implement ProgressService (1RM calculation, volume, PRs)
- [ ] Create progress screen with fl_chart
- [ ] Add PR detection logic (on set log)
- [ ] Add celebration animation for new PRs
- [ ] Write unit tests for 1RM formula

**Phase 6: Body Measurements (1 day)**
- [ ] Implement BodyMeasurementService
- [ ] Create measurement logging screen (weight, body fat %, photo)
- [ ] Add photo compression (1024x1024px)
- [ ] Upload to Supabase Storage
- [ ] Write integration tests for photo upload

**Phase 7: Workout Templates (1 day)**
- [ ] Implement TemplateService
- [ ] Create template builder UI
- [ ] Add pre-built templates (5x5, PPL, etc.)
- [ ] Test template → workout conversion

**Phase 8: Quick Log Mode (1 day)**
- [ ] Create Quick Log UI variant (condensed)
- [ ] Add mode toggle (settings)
- [ ] Optimize for keyboard input
- [ ] Performance test (<30s full workout)

**Phase 9: Cross-Module Integration (1 day)**
- [ ] Add stress data query from user_daily_metrics
- [ ] Create warning banner UI (high stress)
- [ ] Add deload template suggestion
- [ ] Test Supabase Realtime subscription

**Phase 10: Testing & Polish (2 days)**
- [ ] End-to-end integration tests
- [ ] Load testing (1000 set logs, 100 sync queue)
- [ ] Accessibility audit
- [ ] Error handling polish
- [ ] Loading states and animations

**Total Estimate: 16 days (3.2 sprints at 5 days/sprint)**

---

**Epic Status:** Ready for Implementation ✅
**Dependencies:** Epic 1 (Core Platform Foundation)
**Blocks:** Epic 5 (Cross-Module Intelligence - depends on Fitness data)

---

_Tech Spec generated by Bob (BMAD Scrum Master) on 2025-01-16_
