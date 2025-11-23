# LifeOS - Comprehensive Development Guide

**Last Updated:** 2025-11-23
**Version:** 2.0
**Project:** LifeOS (Life Operating System)

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Project Setup](#project-setup)
3. [Architecture & Code Standards](#architecture--code-standards)
4. [Development Workflow](#development-workflow)
5. [Testing Guidelines](#testing-guidelines)
6. [Code Review Checklist](#code-review-checklist)
7. [Common Patterns](#common-patterns)
8. [Debugging & Troubleshooting](#debugging--troubleshooting)
9. [Performance Optimization](#performance-optimization)
10. [Security Best Practices](#security-best-practices)

---

## Quick Start

### Prerequisites Checklist

- [ ] Flutter SDK 3.38+ installed (`flutter --version`)
- [ ] Dart 3.10+ installed
- [ ] Android Studio (for Android dev)
- [ ] Xcode 14.0+ (for iOS dev, macOS only)
- [ ] Git configured
- [ ] Node.js 18+ (for Supabase Edge Functions)
- [ ] Supabase CLI (`npm install -g supabase`)
- [ ] VS Code with Flutter/Dart extensions

### Get Running in 5 Minutes

```bash
# 1. Clone & setup
git clone https://github.com/CoderMariusz/GymApp.git
cd GymApp

# 2. Install dependencies
flutter pub get

# 3. Generate code (Riverpod, Drift, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Setup .env file (copy from .env.example)
cp .env.example .env
# Edit .env with your Supabase credentials

# 5. Run app
flutter run
```

### First Time Setup Checklist

- [ ] Supabase project created and configured
- [ ] Database schema migrated (docs/sprint-artifacts/database-schema.sql)
- [ ] Firebase project setup (for FCM)
- [ ] google-services.json (Android) and GoogleService-Info.plist (iOS) added
- [ ] .env file configured with API keys
- [ ] Pre-commit hooks installed (optional)

---

## Project Setup

### Environment Variables

Create `.env` file in project root:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project

# AI API Keys (for development)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

**Security**: NEVER commit `.env` to version control!

### Dependencies Installation

```bash
# Install Flutter dependencies
flutter pub get

# Install Supabase CLI (if not installed)
npm install -g supabase

# Verify installation
flutter doctor -v
supabase --version
```

### Code Generation

Run this after any changes to `@riverpod`, `@freezed`, or Drift tables:

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on save)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Tip**: Add this to VS Code tasks.json for one-click generation.

---

## Architecture & Code Standards

### Clean Architecture Layers

**Domain Layer** (Business Logic)
- **Entities**: Core business objects (immutable with Freezed)
- **Repositories**: Abstract interfaces (contracts)
- **Use Cases**: Single-responsibility business operations

**Data Layer** (Data Sources)
- **Models**: DTOs for API/Database (with JSON serialization)
- **Repositories**: Concrete implementations
- **Data Sources**: Remote (Supabase), Local (Drift)

**Presentation Layer** (UI)
- **Screens**: Full-page widgets
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state management

### Directory Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # MaterialApp configuration
├── core/                      # Shared infrastructure
│   ├── ai/                    # AI provider abstraction
│   ├── auth/                  # Authentication system
│   ├── database/              # Drift database tables
│   ├── router/                # Go Router configuration
│   ├── sync/                  # Offline-first sync logic
│   ├── theme/                 # App theme and styles
│   └── widgets/               # Global reusable widgets
├── features/                  # Feature modules (Epic-based)
│   ├── life_coach/            # Epic 2: Life Coach MVP
│   │   ├── domain/
│   │   │   ├── entities/      # CheckIn, Goal, DailyPlan
│   │   │   ├── repositories/  # Abstract interfaces
│   │   │   └── usecases/      # Business logic
│   │   ├── data/
│   │   │   ├── models/        # DTOs with JSON
│   │   │   ├── repositories/  # Implementations
│   │   │   └── datasources/   # API, Database
│   │   └── presentation/
│   │       ├── pages/         # Full screens
│   │       ├── widgets/       # Feature-specific widgets
│   │       └── providers/     # Riverpod providers
│   ├── fitness/               # Epic 3: Fitness Coach MVP
│   ├── mind_emotion/          # Epic 4: Mind & Emotion MVP
│   ├── exercise/              # Shared exercise library
│   ├── onboarding/            # Epic 7: Onboarding
│   ├── settings/              # Epic 9: Settings
│   └── ...
└── shared/                    # Cross-feature utilities
    ├── models/                # Shared data models
    ├── utils/                 # Helper functions
    └── constants/             # App constants
```

### Naming Conventions

**Files**:
- Use `snake_case` for all Dart files
- Entity: `goal_entity.dart`
- Model: `goal_model.dart`
- Provider: `goals_provider.dart`
- Screen: `goals_list_page.dart`
- Widget: `goal_card_widget.dart`
- Use case: `create_goal_usecase.dart`

**Classes**:
- Use `PascalCase`
- Entity: `GoalEntity`
- Model: `GoalModel`
- Provider: `GoalsNotifier`
- Screen: `GoalsListPage`
- Widget: `GoalCardWidget`
- Use case: `CreateGoalUseCase`

**Variables**:
- Use `camelCase`
- Private: `_privateVariable`
- Constants: `kConstantValue` or `ALL_CAPS`

### Code Style

**Follow Dart Style Guide**:
```dart
// ✅ GOOD
class GoalEntity {
  final String id;
  final String title;
  final GoalCategory category;

  const GoalEntity({
    required this.id,
    required this.title,
    required this.category,
  });
}

// ❌ BAD
class goal_entity {
  String ID;
  String Title;
  String category;
}
```

**Immutability with Freezed**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_entity.freezed.dart';

@freezed
class GoalEntity with _$GoalEntity {
  const factory GoalEntity({
    required String id,
    required String title,
    required GoalCategory category,
    required int progress,
    required GoalStatus status,
  }) = _GoalEntity;
}
```

**Use Riverpod 2.x with Code Generation**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goals_provider.g.dart';

@riverpod
class Goals extends _$Goals {
  @override
  FutureOr<List<GoalEntity>> build() async {
    final repository = ref.watch(goalsRepositoryProvider);
    return repository.getActiveGoals();
  }

  Future<void> createGoal(GoalEntity goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalsRepositoryProvider);
      await repository.createGoal(goal);
      return ref.refresh(goalsProvider.future);
    });
  }
}
```

---

## Development Workflow

### BMAD Sprint Workflow

**1. Story Assignment**
- Pick story from current sprint backlog (docs/sprint-artifacts/sprint-X/)
- Read story context XML thoroughly
- Understand acceptance criteria and constraints

**2. Implementation**
- Create feature branch: `feature/story-X-Y-short-description`
- Follow TDD: Write tests first (when applicable)
- Implement according to story context
- Run code generation after changes
- Test locally on iOS and Android

**3. Testing**
- Write unit tests (70% coverage minimum)
- Write widget tests (20% coverage)
- Write integration tests (10% coverage)
- Manual testing on both platforms

**4. Code Review**
- Self-review using checklist below
- Create PR with clear description
- Reference story ID in PR title
- Wait for review approval
- Address review comments

**5. Merge & Deploy**
- Merge to `develop` branch
- CI/CD runs automated tests
- Deploy to staging environment
- Verify on staging
- Merge to `main` for production

### Git Workflow

**Branch Naming**:
```bash
# Feature branches
feature/story-2-1-morning-check-in
feature/story-3-5-progress-charts

# Bugfix branches
fix/login-crash-on-android
fix/sync-conflict-resolution

# Hotfix branches (critical production bugs)
hotfix/memory-leak-meditation-player
```

**Commit Messages** (Conventional Commits):
```bash
# Format: <type>(<scope>): <subject>

# Examples
feat(life-coach): implement morning check-in flow (Story 2.1)
fix(fitness): resolve smart pattern memory query bug
refactor(auth): extract password validation logic
test(goals): add unit tests for goal creation
docs(readme): update setup instructions
chore(deps): update riverpod to 2.4.10
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`

### Pull Request Template

```markdown
## Story Context
- **Story ID**: Story 2.1
- **Epic**: Epic 2 - Life Coach MVP
- **Title**: Morning Check-in Flow

## Summary
Brief description of changes

## Changes
- [ ] Implemented check-in entity and model
- [ ] Created check-in repository
- [ ] Built morning check-in UI
- [ ] Added Riverpod provider
- [ ] Wrote unit and widget tests

## Testing
- [ ] Unit tests pass (70%+ coverage)
- [ ] Widget tests pass
- [ ] Manual testing on Android
- [ ] Manual testing on iOS
- [ ] Accessibility tested with screen reader

## Screenshots
[Add screenshots/videos if UI changes]

## Checklist
- [ ] Code follows style guide
- [ ] All acceptance criteria met
- [ ] No new warnings or errors
- [ ] Documentation updated (if needed)
- [ ] Reviewed own code
```

---

## Testing Guidelines

### Test Coverage Targets

- **Unit Tests**: 70% minimum
- **Widget Tests**: 20% minimum
- **Integration Tests**: 10% minimum
- **Overall**: 75-85% target

### Unit Testing

**Location**: `test/features/{feature}/domain/usecases/`

```dart
// test/features/life_coach/domain/usecases/create_goal_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalsRepository extends Mock implements GoalsRepository {}

void main() {
  late CreateGoalUseCase useCase;
  late MockGoalsRepository repository;

  setUp(() {
    repository = MockGoalsRepository();
    useCase = CreateGoalUseCase(repository);
  });

  group('CreateGoalUseCase', () {
    test('creates goal successfully', () async {
      // Arrange
      final goal = GoalEntity(
        id: '1',
        title: 'Read 20 pages daily',
        category: GoalCategory.learning,
        progress: 0,
        status: GoalStatus.active,
      );
      when(() => repository.createGoal(goal))
          .thenAnswer((_) async => goal);

      // Act
      final result = await useCase.call(goal);

      // Assert
      expect(result, equals(goal));
      verify(() => repository.createGoal(goal)).called(1);
    });

    test('throws exception on repository error', () async {
      // Arrange
      final goal = GoalEntity(...);
      when(() => repository.createGoal(goal))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(goal),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### Widget Testing

**Location**: `test/features/{feature}/presentation/widgets/`

```dart
// test/features/life_coach/presentation/widgets/goal_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GoalCard displays goal information', (tester) async {
    // Arrange
    final goal = GoalEntity(
      id: '1',
      title: 'Read 20 pages daily',
      category: GoalCategory.learning,
      progress: 50,
      status: GoalStatus.active,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalCard(goal: goal),
        ),
      ),
    );

    // Assert
    expect(find.text('Read 20 pages daily'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('GoalCard tap triggers callback', (tester) async {
    // Arrange
    bool tapped = false;
    final goal = GoalEntity(...);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalCard(
            goal: goal,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GoalCard));

    // Assert
    expect(tapped, isTrue);
  });
}
```

### Integration Testing

**Location**: `integration_test/`

```dart
// integration_test/life_coach_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete morning check-in flow', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());

    // Navigate to morning check-in
    await tester.tap(find.text('Start Check-in'));
    await tester.pumpAndSettle();

    // Select mood
    await tester.tap(find.text('😊'));
    await tester.pumpAndSettle();

    // Select energy
    await tester.tap(find.text('⚡⚡⚡'));
    await tester.pumpAndSettle();

    // Select sleep quality
    await tester.tap(find.text('😴😴😴😴'));
    await tester.pumpAndSettle();

    // Add note
    await tester.enterText(find.byType(TextField), 'Feeling great today!');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.text('Generate My Plan'));
    await tester.pumpAndSettle(Duration(seconds: 5));

    // Verify daily plan generated
    expect(find.text('Your Daily Plan'), findsOneWidget);
  });
}
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/life_coach/domain/usecases/create_goal_usecase_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests
flutter test integration_test/

# Watch mode (re-run on changes)
flutter test --watch
```

---

## Code Review Checklist

### Before Creating PR

- [ ] **Code compiles without errors** (`flutter analyze`)
- [ ] **All tests pass** (`flutter test`)
- [ ] **Code generated** (`build_runner` if needed)
- [ ] **Self-reviewed using checklist below**
- [ ] **Manual testing on iOS and Android**
- [ ] **No debug print statements left**
- [ ] **No commented-out code (remove or document)**

### Code Quality

- [ ] **Follows Clean Architecture** (domain/data/presentation layers)
- [ ] **Single Responsibility Principle** (classes do one thing well)
- [ ] **DRY Principle** (Don't Repeat Yourself - extract common code)
- [ ] **Proper error handling** (try-catch, Result<T> pattern)
- [ ] **Meaningful variable/function names** (self-documenting)
- [ ] **Constants extracted** (no magic numbers/strings)
- [ ] **Null safety** (no nullable without reason)
- [ ] **Immutability** (use `final`, Freezed, const where possible)

### Architecture

- [ ] **Repository pattern** (data access abstracted)
- [ ] **Use cases** (business logic in domain layer)
- [ ] **Entities vs Models** (domain entities separate from DTOs)
- [ ] **Dependency injection** (via Riverpod providers)
- [ ] **No business logic in UI** (presentation only)
- [ ] **Offline-first** (local-first, sync later if applicable)

### State Management (Riverpod)

- [ ] **Providers properly scoped** (global vs local)
- [ ] **AsyncValue handled** (loading, data, error states)
- [ ] **No setState in StatelessWidget** (use Riverpod)
- [ ] **Proper disposal** (streams, controllers cleaned up)
- [ ] **Auto-refresh logic** (ref.invalidate, ref.refresh)

### UI/UX

- [ ] **Accessibility** (semantic labels, screen reader support)
- [ ] **Touch targets ≥44x44dp** (per NFR-A3)
- [ ] **Loading states** (show progress indicators)
- [ ] **Error states** (user-friendly error messages)
- [ ] **Empty states** (e.g., "No goals yet - create one!")
- [ ] **Responsive design** (works on phones and tablets)
- [ ] **Dark mode support** (if theme implemented)
- [ ] **Haptic feedback** (where appropriate, e.g., button taps)

### Performance

- [ ] **No unnecessary rebuilds** (use const, keys, selectors)
- [ ] **Lazy loading** (lists, images)
- [ ] **Image optimization** (cached, compressed)
- [ ] **Database indexes** (for frequently queried fields)
- [ ] **Query optimization** (limit, pagination)
- [ ] **No memory leaks** (dispose controllers, cancel subscriptions)

### Security

- [ ] **No hardcoded secrets** (API keys, passwords)
- [ ] **Input validation** (sanitize user input)
- [ ] **SQL injection prevention** (use parameterized queries)
- [ ] **XSS prevention** (escape HTML if rendering user content)
- [ ] **E2EE for sensitive data** (journals, measurements)
- [ ] **RLS policies** (Supabase Row Level Security enforced)

### Testing

- [ ] **Unit tests added** (for use cases, repositories)
- [ ] **Widget tests added** (for complex widgets)
- [ ] **Integration tests added** (for critical user flows)
- [ ] **Edge cases covered** (null, empty, max values)
- [ ] **Error scenarios tested** (network failure, invalid input)

### Documentation

- [ ] **Public APIs documented** (doc comments on classes/methods)
- [ ] **Complex logic explained** (inline comments where needed)
- [ ] **README updated** (if setup/usage changes)
- [ ] **Story context referenced** (link to story in PR description)

---

## Common Patterns

### Result<T> Pattern (Error Handling)

```dart
// core/utils/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final Exception exception;
  const Failure(this.exception);
}

// Usage in repository
class GoalsRepositoryImpl implements GoalsRepository {
  @override
  Future<Result<List<GoalEntity>>> getActiveGoals() async {
    try {
      final response = await supabase
          .from('goals')
          .select()
          .eq('status', 'active');

      final goals = (response as List)
          .map((json) => GoalModel.fromJson(json).toEntity())
          .toList();

      return Success(goals);
    } catch (e) {
      return Failure(Exception('Failed to fetch goals: $e'));
    }
  }
}

// Usage in provider
@riverpod
class Goals extends _$Goals {
  @override
  Future<List<GoalEntity>> build() async {
    final repository = ref.watch(goalsRepositoryProvider);
    final result = await repository.getActiveGoals();

    return switch (result) {
      Success(data: final goals) => goals,
      Failure(exception: final e) => throw e,
    };
  }
}
```

### Offline-First Sync Pattern

```dart
// Hybrid sync: Write to local DB first, then sync to Supabase
class WorkoutRepository {
  final AppDatabase _localDb;
  final SupabaseClient _supabase;

  Future<void> logWorkout(WorkoutEntity workout) async {
    // 1. Write to local database immediately (offline-first)
    await _localDb.insertWorkout(workout.toModel());

    // 2. Queue for sync (if online, sync immediately; if offline, queue)
    _syncQueue.add(workout.id);

    // 3. Attempt sync (opportunistic)
    if (await _isOnline()) {
      await _syncWorkout(workout);
    }
  }

  Future<void> _syncWorkout(WorkoutEntity workout) async {
    try {
      await _supabase.from('workouts').upsert(workout.toJson());
      await _localDb.markSynced(workout.id);
    } catch (e) {
      // Sync failed, will retry later via sync queue
      _logger.warning('Sync failed for workout ${workout.id}: $e');
    }
  }
}
```

### Optimistic UI Updates

```dart
@riverpod
class Goals extends _$Goals {
  Future<void> updateGoalProgress(String goalId, int newProgress) async {
    // 1. Optimistic update: Update UI immediately
    state = state.whenData((goals) {
      return goals.map((goal) {
        if (goal.id == goalId) {
          return goal.copyWith(progress: newProgress);
        }
        return goal;
      }).toList();
    });

    // 2. Backend update
    try {
      final repository = ref.read(goalsRepositoryProvider);
      await repository.updateGoalProgress(goalId, newProgress);
    } catch (e) {
      // 3. Rollback on error
      ref.invalidateSelf();
      rethrow;
    }
  }
}
```

### Repository Pattern with Caching

```dart
class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDataSource _localDataSource;
  final ExerciseRemoteDataSource _remoteDataSource;

  // In-memory cache (expires after 5 minutes)
  final Map<String, (DateTime, List<ExerciseEntity>)> _cache = {};
  static const _cacheExpiry = Duration(minutes: 5);

  @override
  Future<List<ExerciseEntity>> searchExercises(String query) async {
    // 1. Check cache
    if (_cache.containsKey(query)) {
      final (cachedAt, exercises) = _cache[query]!;
      if (DateTime.now().difference(cachedAt) < _cacheExpiry) {
        return exercises; // Cache hit
      }
    }

    // 2. Try local database (offline-first)
    try {
      final exercises = await _localDataSource.searchExercises(query);
      if (exercises.isNotEmpty) {
        _updateCache(query, exercises);
        return exercises;
      }
    } catch (_) {}

    // 3. Fetch from remote (Supabase)
    final exercises = await _remoteDataSource.searchExercises(query);

    // 4. Update local database
    await _localDataSource.insertExercises(exercises);

    // 5. Update cache
    _updateCache(query, exercises);

    return exercises;
  }

  void _updateCache(String query, List<ExerciseEntity> exercises) {
    _cache[query] = (DateTime.now(), exercises);
  }
}
```

---

## Debugging & Troubleshooting

### Debug Tools

**Flutter DevTools**:
```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Run app with debug mode
flutter run --debug
```

**Riverpod DevTools** (in DevTools):
- View provider state tree
- Track state changes
- Inspect provider dependencies

**Drift Inspector** (for database debugging):
```dart
// Add to AppDatabase
@override
MigrationStrategy get migration => MigrationStrategy(
  onFinished: (connection) async {
    if (kDebugMode) {
      final tables = await connection.rawQuery('SELECT * FROM sqlite_master');
      print('Database tables: $tables');
    }
  },
);
```

### Common Issues

**Issue**: `build_runner` fails
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Supabase connection timeout
```dart
// Solution: Increase timeout
final supabase = SupabaseClient(
  url,
  anonKey,
  httpClient: IOClient(
    HttpClient()..connectionTimeout = Duration(seconds: 30),
  ),
);
```

**Issue**: Memory leak in provider
```dart
// Bad: Stream not disposed
@riverpod
Stream<List<GoalEntity>> goals(GoalsRef ref) {
  return supabase.from('goals').stream(); // ❌ Leaks!
}

// Good: Use autoDispose
@riverpod
Stream<List<GoalEntity>> goals(GoalsRef ref) {
  return supabase.from('goals').stream(primaryKey: ['id']); // ✅ Auto-disposed
}
```

**Issue**: Race condition in sync
```dart
// Bad: Concurrent syncs
Future<void> syncData() async {
  await syncGoals();
  await syncWorkouts(); // May conflict if both modify same tables
}

// Good: Sequential with locks
final _syncLock = Lock(); // from package:synchronized

Future<void> syncData() async {
  await _syncLock.synchronized(() async {
    await syncGoals();
    await syncWorkouts();
  });
}
```

### Logging Best Practices

```dart
// Use logger package
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

// Usage
logger.d('Debug: Fetching goals for user $userId');
logger.i('Info: Goal created successfully');
logger.w('Warning: Sync failed, will retry');
logger.e('Error: Failed to parse API response', e, stackTrace);
```

---

## Performance Optimization

### Database Optimization

**Indexes** (critical for queries):
```sql
-- Create indexes on frequently queried columns
CREATE INDEX idx_workouts_user_date ON workouts(user_id, created_at DESC);
CREATE INDEX idx_goals_status ON goals(user_id, status);
CREATE INDEX idx_exercises_name ON exercises(name);
```

**Pagination** (for large datasets):
```dart
Future<List<WorkoutEntity>> getWorkoutHistory({
  required int limit,
  required int offset,
}) async {
  final response = await supabase
      .from('workouts')
      .select()
      .order('created_at', ascending: false)
      .limit(limit)
      .range(offset, offset + limit - 1);

  return (response as List)
      .map((json) => WorkoutModel.fromJson(json).toEntity())
      .toList();
}
```

### Widget Optimization

**Use `const` constructors**:
```dart
// ✅ Good: Const constructor (no rebuild)
const Text('Hello');
const Icon(Icons.home);

// ❌ Bad: Runtime constructor (rebuilds unnecessarily)
Text('Hello');
Icon(Icons.home);
```

**Keys for lists**:
```dart
// ✅ Good: Use keys for list items
ListView.builder(
  itemCount: goals.length,
  itemBuilder: (context, index) {
    final goal = goals[index];
    return GoalCard(
      key: ValueKey(goal.id), // Prevents unnecessary rebuilds
      goal: goal,
    );
  },
);
```

**Select only needed data in Riverpod**:
```dart
// ❌ Bad: Rebuilds on any goal change
final activeGoalsCount = ref.watch(goalsProvider).value?.length ?? 0;

// ✅ Good: Rebuilds only when count changes
final activeGoalsCount = ref.watch(goalsProvider.select((goals) => goals.value?.length ?? 0));
```

### Image Optimization

```dart
// Use CachedNetworkImage for remote images
CachedNetworkImage(
  imageUrl: avatarUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  maxHeightDiskCache: 512, // Limit cache size
  maxWidthDiskCache: 512,
);

// Compress before upload
Future<File> compressImage(File image) async {
  final compressed = await FlutterImageCompress.compressAndGetFile(
    image.absolute.path,
    '${image.path}_compressed.jpg',
    quality: 70,
    minWidth: 512,
    minHeight: 512,
  );
  return compressed!;
}
```

---

## Security Best Practices

### Environment Variables

```dart
// ✅ Good: Use environment variables
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

// ❌ Bad: Hardcoded API keys
const supabaseUrl = 'https://xyz.supabase.co'; // ❌ DON'T!
```

### Input Validation

```dart
// Validate and sanitize user input
String sanitizeInput(String input) {
  // Remove dangerous characters
  return input
      .replaceAll(RegExp(r'[<>]'), '')
      .trim()
      .substring(0, min(input.length, 500)); // Max length
}

// Validate email
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

// Validate password strength
bool isStrongPassword(String password) {
  return password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[0-9]')) &&
      password.contains(RegExp(r'[!@#$%^&*]'));
}
```

### E2EE for Sensitive Data

```dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key _key;
  final IV _iv;

  EncryptionService()
      : _key = Key.fromSecureRandom(32),
        _iv = IV.fromSecureRandom(16);

  String encrypt(String plaintext) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String ciphertext) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
    final decrypted = encrypter.decrypt64(ciphertext, iv: _iv);
    return decrypted;
  }
}

// Usage for journal entries
class JournalRepository {
  final EncryptionService _encryption;

  Future<void> saveEntry(String content) async {
    final encryptedContent = _encryption.encrypt(content);
    await supabase.from('journal_entries').insert({
      'content': encryptedContent, // E2EE - Supabase cannot read this!
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Supabase Docs**: https://supabase.com/docs
- **Drift Docs**: https://drift.simonbinder.eu/
- **BMAD Methodology**: docs/ecosystem/prd.md

---

## Support & Contact

- **GitHub Issues**: https://github.com/CoderMariusz/GymApp/issues
- **Documentation**: docs/ directory
- **Architecture**: docs/ecosystem/architecture.md

---

**Last Updated**: 2025-11-23
**Maintained By**: BMAD Development Team
