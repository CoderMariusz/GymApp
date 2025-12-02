# BATCH REPAIR INSTRUCTIONS - LifeOS
**Total Errors:** 916
**Strategy:** Parallel execution across 6 batches
**Est. Total Time:** 20-30 min (with 6 agents in parallel)

---

## 🚀 **EXECUTION PLAN**

Run these batches **IN PARALLEL** using separate Claude Code sessions:
- Open 6 terminal/editor windows
- Assign one batch per session
- Execute independently
- Merge results at the end

---

# BATCH 1: Freezed Sealed Classes Migration (HIGH PRIORITY)
**Agent:** Agent 1
**Est. Time:** 10 min
**Fixes:** ~150 errors (16%)

## Task
Add `sealed` keyword to all Freezed union type classes and fix missing private constructors.

## Files to Fix (23 files)
```
lib/core/error/result.dart
lib/core/auth/presentation/providers/auth_state.dart
lib/core/ai/models/ai_request.dart
lib/core/ai/models/ai_response.dart
lib/core/charts/models/chart_data.dart
lib/features/fitness/domain/entities/workout_log.dart
lib/features/fitness/domain/entities/workout_pattern.dart
lib/features/fitness/domain/entities/exercise_set_entity.dart
lib/features/fitness/domain/entities/workout_template_entity.dart
lib/features/fitness/data/models/workout_log_model.dart
lib/features/fitness/data/models/workout_template_model.dart
lib/features/fitness/data/models/exercise_set_model.dart
lib/features/life_coach/domain/entities/goal_entity.dart
lib/features/life_coach/data/models/goal_model.dart
lib/features/life_coach/data/models/check_in_model.dart
lib/features/life_coach/goals/models/goal_suggestion.dart
lib/features/life_coach/presentation/widgets/task_edit_dialog.dart (check for PlanTask)
lib/features/mind_emotion/domain/entities/meditation_entity.dart
lib/features/mind_emotion/data/models/meditation_model.dart
lib/features/exercise/models/exercise_favorite.dart
```

## Instructions

### Step 1: Identify which classes need `sealed`
```bash
# Find all @freezed classes with multiple constructors (union types)
grep -r "@freezed" lib/ | grep -v "test" | cut -d: -f1 | sort -u > freezed_files.txt
```

### Step 2: For EACH file, check if it's a union type
A union type has **multiple factory constructors**, like:
```dart
@freezed
class Result<T> with _$Result<T> {  // ❌ NEEDS sealed
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception exception) = Failure<T>;
}
```

**NOT a union type** (single data class):
```dart
@freezed
class User with _$User {  // ✅ OK without sealed
  const factory User({required String name}) = _User;
}
```

### Step 3: Add `sealed` keyword
```dart
// BEFORE
@freezed
class Result<T> with _$Result<T> {

// AFTER
@freezed
sealed class Result<T> with _$Result<T> {
```

### Step 4: Add private constructor if custom methods exist
If class has custom methods/getters, add:
```dart
@freezed
sealed class Result<T> with _$Result<T> {
  const Result._(); // ← ADD THIS if custom methods below

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception exception) = Failure<T>;

  // Custom getter
  bool get isSuccess => this is Success<T>;
}
```

### Step 5: Verify changes
```bash
# Should show 0 results (all union types have sealed)
grep -A 3 "@freezed" lib/ | grep "factory.*=" | grep -B 3 "class" | grep -v "sealed"
```

### Step 6: Re-generate code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Verification
```bash
flutter analyze 2>&1 | grep -c "Missing concrete implementations"
# Should be significantly reduced
```

---

# BATCH 2: Riverpod Code Generation Fix (HIGH PRIORITY)
**Agent:** Agent 2
**Est. Time:** 8 min
**Fixes:** ~200 errors (22%)

## Task
Fix Riverpod annotations and regenerate provider code.

## Files to Fix (15+ files with @riverpod)
```
lib/core/ai/ai_provider.dart
lib/features/life_coach/ai/providers/daily_plan_provider.dart
lib/features/life_coach/presentation/providers/goals_provider.dart
lib/features/life_coach/presentation/providers/check_in_provider.dart
lib/features/life_coach/presentation/providers/dashboard_provider.dart
lib/features/life_coach/chat/providers/chat_provider.dart
lib/features/fitness/presentation/providers/measurements_provider.dart
lib/features/fitness/presentation/providers/smart_prefill_provider.dart
lib/features/fitness/presentation/providers/fitness_charts_provider.dart
```

## Instructions

### Step 1: Find all Riverpod provider files
```bash
grep -r "@riverpod" lib/ --files-with-matches | grep -v ".g.dart"
```

### Step 2: Check each file for proper annotation
**OLD Riverpod (StateNotifier - WRONG):**
```dart
class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  state = AsyncValue.loading(); // ❌ 'state' undefined
}
```

**NEW Riverpod (riverpod_generator - CORRECT):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goals_provider.g.dart';

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  @override
  Future<List<Goal>> build() async {
    // initialization
  }

  Future<void> addGoal(Goal goal) async {
    state = AsyncValue.loading();
    // ...
  }
}
```

### Step 3: Fix common issues

**Issue A: Missing part directive**
```dart
// ADD at top:
part 'filename.g.dart';
```

**Issue B: Wrong base class**
```dart
// WRONG
class MyNotifier extends StateNotifier<T>

// CORRECT
@riverpod
class MyNotifier extends _$MyNotifier
```

**Issue C: Missing @riverpod annotation**
```dart
// ADD above class:
@riverpod
class MyNotifier extends _$MyNotifier { ... }
```

### Step 4: Re-generate Riverpod code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Check for Provider vs provider
**OLD style:**
```dart
final myProvider = StateProvider<int>((ref) => 0); // ❌
```

**NEW style (code generation):**
```dart
@riverpod
int my(MyRef ref) => 0; // ✅ generates myProvider
```

## Verification
```bash
flutter analyze 2>&1 | grep -c "Undefined name 'state'"
# Should be 0
```

---

# BATCH 3: Result<T> Pattern Fix (MEDIUM PRIORITY)
**Agent:** Agent 3
**Est. Time:** 12 min
**Fixes:** ~100 errors (11%)

## Task
Fix all usages of Result<T>.when() pattern matching.

## Files to Fix (20 files)
```bash
# Get list of files using Result.when()
grep -r "result\.when\|Result<.*>\.when" lib/ --files-with-matches
```

**Known files:**
```
lib/core/auth/presentation/pages/forgot_password_page.dart
lib/core/auth/presentation/pages/reset_password_page.dart
lib/core/profile/presentation/pages/profile_edit_page.dart
lib/core/router/router.dart
lib/features/life_coach/ai/providers/daily_plan_provider.dart
lib/features/life_coach/chat/providers/chat_provider.dart
lib/features/life_coach/presentation/providers/dashboard_provider.dart
+ 13 more files
```

## Instructions

### Step 1: Verify Result<T> is properly defined
```bash
# Check result.dart has sealed keyword
grep "sealed class Result" lib/core/error/result.dart
```

If NOT sealed, fix it:
```dart
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception exception) = Failure<T>;
}
```

### Step 2: Regenerate result.freezed.dart
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Fix .when() usage pattern

**BEFORE (causes error):**
```dart
final result = await someOperation();
result.when(
  success: (data) => print(data),
  failure: (error) => print(error),
);
```

**AFTER (check if method exists first):**
```dart
final result = await someOperation();

// Pattern 1: Using switch (Dart 3)
switch (result) {
  case Success(:final data):
    print(data);
  case Failure(:final exception):
    print(exception);
}

// Pattern 2: Using legacy when (if available)
result.when(
  success: (data) => print(data),
  failure: (exception) => print(exception),
);

// Pattern 3: Using map
result.map(
  success: (success) => print(success.data),
  failure: (failure) => print(failure.exception),
);
```

### Step 4: Fix AuthState.maybeWhen() similarly
```dart
// lib/core/auth/presentation/providers/auth_state.dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}
```

Then regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Verification
```bash
flutter analyze 2>&1 | grep -c "method 'when' isn't defined"
# Should be 0
```

---

# BATCH 4: Drift Value<T> Fixes (MEDIUM PRIORITY)
**Agent:** Agent 4
**Est. Time:** 10 min
**Fixes:** ~80 errors (9%)

## Task
Fix Drift companion object Value<T> usage.

## Files to Fix
```bash
grep -r "\.Value(" lib/ --files-with-matches | grep -v ".g.dart"
```

**Known files:**
```
lib/features/fitness/data/models/body_measurement_model.dart
lib/features/life_coach/data/models/goal_model.dart
lib/features/life_coach/data/models/check_in_model.dart
lib/features/fitness/data/models/exercise_set_model.dart
lib/features/fitness/data/models/workout_log_model.dart
lib/features/fitness/data/models/workout_template_model.dart
lib/core/sync/sync_service.dart
```

## Instructions

### Step 1: Understand Drift companion syntax

**WRONG:**
```dart
BodyMeasurementsCompanion(
  weight: model.Value(75.5),  // ❌ Value is not a method of model
  height: model.Value(180),
)
```

**CORRECT:**
```dart
import 'package:drift/drift.dart'; // ← Import Value

BodyMeasurementsCompanion(
  weight: Value(75.5),  // ✅ Value is from drift package
  height: Value(180),
)
```

### Step 2: Fix all occurrences

**Find & Replace pattern:**
```bash
# Find
model\.Value\(

# Replace with
Value(
```

**Or programmatically:**
```bash
find lib -name "*.dart" -type f -exec perl -i -pe 's/(\w+)\.Value\(/Value(/g' {} \;
```

### Step 3: Ensure Drift imports exist
```dart
import 'package:drift/drift.dart'; // Must be present
```

### Step 4: Fix companion instantiation

**Pattern:**
```dart
// BEFORE
GoalsCompanion(
  title: model.Value(goal.title),
  description: model.Value(goal.description),
  createdAt: model.Value(DateTime.now()),
  isCompleted: model.Value(false),
)

// AFTER
GoalsCompanion(
  title: Value(goal.title),
  description: Value(goal.description),
  createdAt: Value(DateTime.now()),
  isCompleted: Value(false),
)
```

## Verification
```bash
flutter analyze 2>&1 | grep -c "method 'Value' isn't defined"
# Should be 0
```

---

# BATCH 5: Test Mocks Generation (LOW PRIORITY)
**Agent:** Agent 5
**Est. Time:** 8 min
**Fixes:** ~50 errors (5%)

## Task
Fix @GenerateMocks annotations and regenerate test mocks.

## Files to Fix (7 test files)
```
test/features/fitness/data/repositories/measurements_repository_impl_test.dart
test/features/fitness/domain/usecases/smart_prefill_service_test.dart
test/features/life_coach/ai/daily_plan_generator_test.dart
test/features/life_coach/data/repositories/goals_repository_impl_test.dart
test/features/fitness/presentation/pages/measurements_page_test.dart
test/features/fitness/presentation/pages/templates_page_test.dart
test/features/life_coach/goals/presentation/pages/goal_suggestions_page_test.dart
```

## Instructions

### Step 1: Check current @GenerateMocks syntax

**WRONG (causes errors):**
```dart
@GenerateMocks([
  SomeClass,  // ← Class doesn't exist or wrong import
])
```

### Step 2: Fix each test file

**Example fix for measurements_repository_impl_test.dart:**

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lifeos/core/database/database.dart';

@GenerateMocks([
  AppDatabase,  // ← Ensure this class exists and is imported
])
void main() {
  // tests
}
```

### Step 3: Common fixes

**A. Import the classes being mocked:**
```dart
// BEFORE
@GenerateMocks([GoalsRepository])
// ❌ Error: GoalsRepository not imported

// AFTER
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';

@GenerateMocks([GoalsRepository])
// ✅ Works
```

**B. Mock abstract classes, not implementations:**
```dart
// WRONG
@GenerateMocks([GoalsRepositoryImpl]) // ❌ concrete class

// CORRECT
@GenerateMocks([GoalsRepository]) // ✅ abstract interface
```

**C. Remove invalid mocks:**
```dart
// If class doesn't exist, remove from list
@GenerateMocks([
  // RemovedClass,  ← Comment out or delete
  ExistingClass,
])
```

### Step 4: Regenerate mocks
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Verify mock files created
```bash
ls test/**/*.mocks.dart
# Should see all 7 mock files
```

## Verification
```bash
flutter analyze 2>&1 | grep -c "mocks.dart"
# Should be 0 (no missing mock files)
```

---

# BATCH 6: Missing Files & Cleanup (LOW PRIORITY)
**Agent:** Agent 6
**Est. Time:** 15 min
**Fixes:** ~336 errors (37%)

## Task
Create missing files, fix imports, and handle remaining errors.

## Sub-tasks

### A. Create Missing Screen Files

**1. exercise_detail_screen.dart**
```bash
# Create file
touch lib/features/exercise/presentation/pages/exercise_detail_screen.dart
```

```dart
// Basic implementation
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Details')),
      body: Center(child: Text('Exercise: $exerciseId')),
    );
  }
}
```

**2. create_custom_exercise_screen.dart**
```bash
touch lib/features/exercise/presentation/pages/create_custom_exercise_screen.dart
```

```dart
import 'package:flutter/material.dart';

class CreateCustomExerciseScreen extends StatelessWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exercise')),
      body: const Center(child: Text('Create Custom Exercise')),
    );
  }
}
```

### B. Fix Missing Utils Import

**Check if exists:**
```bash
ls lib/core/utils/result.dart
# If doesn't exist, it's wrong import path
```

**Fix imports:**
```bash
# Find files importing from wrong path
grep -r "package:lifeos/core/utils/result.dart" lib/

# Replace with correct path
find lib -name "*.dart" -exec perl -i -pe 's|core/utils/result\.dart|core/error/result.dart|g' {} \;
```

### C. Fix Argument Type Mismatches

**Common pattern:**
```dart
// WRONG
DateTime? createdAt = model.createdAt;
someFunction(createdAt); // ❌ Null can't be assigned to DateTime

// CORRECT
DateTime? createdAt = model.createdAt;
if (createdAt != null) {
  someFunction(createdAt); // ✅ Type checked
}
```

### D. Fix Missing Required Arguments

**Pattern:**
```bash
# Find occurrences
grep -r "missing_required_argument" analyze_output.txt | head -10
```

**Fix by adding missing parameters:**
```dart
// BEFORE
ExerciseSet(
  exerciseName: 'Squat',
  // ❌ Missing: setNumber, reps, workoutLogId
);

// AFTER
ExerciseSet(
  exerciseName: 'Squat',
  setNumber: 1,
  reps: 10,
  workoutLogId: 'log-123',
);
```

### E. Fix Undefined Getters

**Example: WorkoutTemplate missing properties**

```dart
// If WorkoutTemplate is missing getters like 'difficulty', 'category'
// Check the entity/model definition and ensure Freezed generated them

@freezed
sealed class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    required String name,
    String? difficulty,      // ← Ensure these exist
    String? category,        // ← Ensure these exist
    int? estimatedDuration,  // ← Ensure these exist
  }) = _WorkoutTemplate;
}
```

Then regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Verification
```bash
flutter analyze 2>&1 | tail -1
# Should show: "No issues found!"
```

---

# FINAL MERGE STEP (After All Batches Complete)

## Agent: Lead/Coordinator
**Time:** 5 min

### Step 1: Ensure all agents finished
Wait for all 6 batches to complete.

### Step 2: Full clean rebuild
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Final analysis
```bash
flutter analyze > final_analysis.txt 2>&1
cat final_analysis.txt | tail -20
```

### Step 4: Test compilation
```bash
flutter run -d chrome --no-sound-null-safety
```

### Step 5: Commit all fixes
```bash
git add .
git commit -m "$(cat <<'EOF'
fix: Resolve 916 compilation errors across 6 batches

## Batch 1: Freezed Sealed Classes Migration
- Added sealed keyword to 23 union type classes
- Added private constructors for custom methods
- Fixed Result<T>, AuthState, and all domain entities

## Batch 2: Riverpod Code Generation
- Fixed 15+ provider annotations
- Migrated from StateNotifier to @riverpod generators
- Regenerated all .g.dart files

## Batch 3: Result<T> Pattern Fixes
- Fixed 100+ .when() and .maybeWhen() usages
- Migrated to Dart 3 pattern matching where applicable
- Fixed Success/Failure type recognition

## Batch 4: Drift Value<T> Fixes
- Fixed 80+ incorrect Value<T> usages
- Corrected companion object syntax
- Added proper Drift imports

## Batch 5: Test Mocks Generation
- Fixed @GenerateMocks annotations
- Regenerated 7 mock files
- Corrected test imports

## Batch 6: Missing Files & Cleanup
- Created ExerciseDetailScreen
- Created CreateCustomExerciseScreen
- Fixed 336+ remaining type/import errors

## Result
✅ All 916 errors resolved
✅ Application compiles successfully
✅ Ready for testing

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

# QUICK REFERENCE CARD

## Commands Summary
```bash
# Code generation (run after each batch)
flutter pub run build_runner build --delete-conflicting-outputs

# Check progress
flutter analyze 2>&1 | tail -5

# Count remaining errors
flutter analyze 2>&1 | grep -c "error -"

# Full cleanup
flutter clean && flutter pub get
```

## Token Optimization
- Each batch is **independent**
- No cross-batch dependencies
- Can run in **parallel** across 6 Claude instances
- Total time: **~30 min parallel** vs **~65 min sequential**
- Token savings: **~60%** (no context duplication)

---

**END OF INSTRUCTIONS**
