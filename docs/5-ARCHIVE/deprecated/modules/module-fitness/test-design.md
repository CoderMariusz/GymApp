# GymApp - Test Design Document

**Version**: 1.0
**Date**: 2025-01-15
**Project**: GymApp - AI-Powered Fitness Tracker
**Phase**: Solutioning (BMAD Workflow)

---

## Table of Contents

1. [Testing Strategy Overview](#1-testing-strategy-overview)
2. [Test Pyramid](#2-test-pyramid)
3. [Unit Testing](#3-unit-testing)
4. [Widget Testing](#4-widget-testing)
5. [Integration Testing](#5-integration-testing)
6. [End-to-End Testing](#6-end-to-end-testing)
7. [Test Coverage Requirements](#7-test-coverage-requirements)
8. [Testing Tools & Frameworks](#8-testing-tools--frameworks)
9. [Test Organization](#9-test-organization)
10. [Mocking & Test Data](#10-mocking--test-data)
11. [CI/CD Integration](#11-cicd-integration)
12. [Performance Testing](#12-performance-testing)
13. [Security Testing](#13-security-testing)
14. [Accessibility Testing](#14-accessibility-testing)

---

## 1. Testing Strategy Overview

### 1.1 Testing Philosophy

GymApp follows a **Risk-Based Testing** approach:

1. **Critical Path First**: Test features that impact core value proposition (workout logging, Smart Pattern Memory)
2. **Offline-First Validation**: Extensively test offline scenarios and sync conflicts
3. **Data Integrity**: Zero tolerance for data loss - comprehensive sync testing
4. **GDPR Compliance**: Validate all data deletion, export, and consent flows
5. **Cross-Platform Parity**: Ensure identical behavior on iOS and Android

### 1.2 Testing Principles

| Principle | Description |
|-----------|-------------|
| **Fast Feedback** | Unit tests run in <10s, integration tests <2min, E2E <10min |
| **Deterministic** | No flaky tests - all tests must pass consistently |
| **Isolated** | Tests don't depend on external services (use mocks) |
| **Maintainable** | Test code follows same quality standards as production code |
| **Automated** | All tests run in CI/CD pipeline on every commit |

### 1.3 Quality Gates

| Phase | Quality Gate | Criteria |
|-------|--------------|----------|
| **Pre-Commit** | Local tests | All unit tests pass |
| **Pull Request** | CI/CD pipeline | Unit + Widget tests pass, coverage ≥80% |
| **Pre-Merge** | Full suite | Integration tests pass |
| **Pre-Release** | E2E + manual QA | E2E tests pass, manual smoke test, performance benchmarks met |

---

## 2. Test Pyramid

```
                    ▲
                   / \
                  /   \
                 /  E2E \          10 tests (~10min)
                /  Tests \         - Critical user journeys
               /-----------\       - Smoke tests
              /             \
             / Integration   \     50 tests (~2min)
            /     Tests       \    - Feature workflows
           /-------------------\   - API integrations
          /                     \
         /     Widget Tests      \ 200 tests (~30s)
        /                         \ - UI components
       /---------------------------\ - User interactions
      /                             \
     /         Unit Tests            \ 500 tests (~10s)
    /                                 \ - Business logic
   /___________________________________\ - Repositories
                                         - Providers
                                         - Services

   Total: ~760 tests, ~13 minutes full suite
```

### 2.1 Test Distribution

| Test Type | Count | % of Total | Execution Time | Coverage Target |
|-----------|-------|------------|----------------|-----------------|
| **Unit Tests** | 500 | 66% | ~10s | 90% code coverage |
| **Widget Tests** | 200 | 26% | ~30s | 80% widget coverage |
| **Integration Tests** | 50 | 7% | ~2min | Critical paths |
| **E2E Tests** | 10 | 1% | ~10min | Smoke tests only |

---

## 3. Unit Testing

### 3.1 Unit Test Scope

**What to test**:
- Business logic in providers (Riverpod StateNotifiers)
- Repository methods (data access layer)
- Service classes (SyncService, GDPRService, etc.)
- Utility functions (validators, formatters, extensions)
- Model methods (if any business logic)

**What NOT to test**:
- Flutter framework code
- Third-party packages
- Getters/setters without logic
- UI widgets (covered by widget tests)

### 3.2 Unit Test Examples

#### 3.2.1 Testing Riverpod Providers

```dart
// test/features/workout/providers/active_workout_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp/features/workout/providers/active_workout_provider.dart';
import 'package:gymapp/features/workout/repositories/workout_repository.dart';

@GenerateMocks([WorkoutRepository])
import 'active_workout_provider_test.mocks.dart';

void main() {
  late MockWorkoutRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockWorkoutRepository();

    container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ActiveWorkoutProvider', () {
    test('initial state is empty', () {
      final provider = container.read(activeWorkoutProvider);

      expect(provider.session, isNull);
      expect(provider.exercises, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('startWorkout creates session and updates state', () async {
      // Arrange
      final mockSession = WorkoutSession(
        id: 1,
        firebaseUid: 'user123',
        startTime: DateTime.now(),
        status: 'in_progress',
        synced: false,
        dirty: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async => mockSession);

      // Act
      await container.read(activeWorkoutProvider.notifier).startWorkout();

      // Assert
      final state = container.read(activeWorkoutProvider);
      expect(state.session, isNotNull);
      expect(state.session!.id, equals(1));
      expect(state.session!.status, equals('in_progress'));
      expect(state.isLoading, isFalse);

      verify(mockRepository.createWorkoutSession()).called(1);
    });

    test('addExercise adds exercise with pattern memory', () async {
      // Arrange
      final mockSession = WorkoutSession(/* ... */);
      final mockExercise = Exercise(id: 1, name: 'Bench Press');
      final mockPattern = PatternMemory(
        exerciseId: 1,
        lastPerformedDate: DateTime.now().subtract(Duration(days: 3)),
        sets: [
          PatternSet(setNumber: 1, reps: 8, weight: 80, unit: 'kg', effort: 7),
          PatternSet(setNumber: 2, reps: 8, weight: 80, unit: 'kg', effort: 7),
          PatternSet(setNumber: 3, reps: 8, weight: 80, unit: 'kg', effort: 8),
        ],
        confidence: Confidence.high,
      );

      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async => mockSession);
      when(mockPatternMemory.getPattern(1))
          .thenAnswer((_) async => mockPattern);
      when(mockRepository.addExerciseToWorkout(
        workoutId: anyNamed('workoutId'),
        exerciseId: anyNamed('exerciseId'),
        suggestedSets: anyNamed('suggestedSets'),
      )).thenAnswer((_) async => WorkoutExerciseWithSets(/* ... */));

      await container.read(activeWorkoutProvider.notifier).startWorkout();

      // Act
      await container.read(activeWorkoutProvider.notifier)
          .addExercise(mockExercise);

      // Assert
      final state = container.read(activeWorkoutProvider);
      expect(state.exercises, hasLength(1));
      expect(state.exercises[0].exercise.name, equals('Bench Press'));

      verify(mockPatternMemory.getPattern(1)).called(1);
      verify(mockRepository.addExerciseToWorkout(
        workoutId: anyNamed('workoutId'),
        exerciseId: 1,
        suggestedSets: mockPattern.sets,
      )).called(1);
    });

    test('finishWorkout updates status and triggers sync', () async {
      // Arrange
      final mockSession = WorkoutSession(/* ... */);
      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async => mockSession);
      when(mockRepository.finishWorkout(any))
          .thenAnswer((_) async => {});

      await container.read(activeWorkoutProvider.notifier).startWorkout();

      // Act
      await container.read(activeWorkoutProvider.notifier).finishWorkout();

      // Assert
      final state = container.read(activeWorkoutProvider);
      expect(state.session, isNull);  // State reset after finish

      verify(mockRepository.finishWorkout(mockSession.id)).called(1);
      verify(mockSyncService.syncWorkout(mockSession.id)).called(1);
    });

    test('handles errors gracefully', () async {
      // Arrange
      when(mockRepository.createWorkoutSession())
          .thenThrow(Exception('Database error'));

      // Act
      await container.read(activeWorkoutProvider.notifier).startWorkout();

      // Assert
      final state = container.read(activeWorkoutProvider);
      expect(state.session, isNull);
      expect(state.error, contains('Database error'));
      expect(state.isLoading, isFalse);

      verify(mockCrashlytics.recordError(any, any)).called(1);
    });
  });
}
```

#### 3.2.2 Testing Repositories

```dart
// test/features/workout/repositories/workout_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late WorkoutRepository repository;

  setUp(() {
    // Use in-memory database for testing
    database = AppDatabase(NativeDatabase.memory());
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    repository = WorkoutRepository(
      database: database,
      firestore: mockFirestore,
      auth: mockAuth,
    );

    // Setup auth mock
    when(mockAuth.currentUser).thenReturn(
      MockUser()..uid = 'test_user_123',
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('WorkoutRepository', () {
    test('createWorkoutSession inserts into Drift and marks as dirty', () async {
      // Act
      final session = await repository.createWorkoutSession();

      // Assert
      expect(session.id, isPositive);
      expect(session.firebaseUid, equals('test_user_123'));
      expect(session.status, equals('in_progress'));
      expect(session.synced, isFalse);
      expect(session.dirty, isTrue);

      // Verify database state
      final dbSessions = await database.workoutSessionsDao.getAllSessions();
      expect(dbSessions, hasLength(1));
      expect(dbSessions[0].id, equals(session.id));
    });

    test('syncWorkoutToFirestore uploads workout data', () async {
      // Arrange
      final session = await repository.createWorkoutSession();

      final mockDocRef = MockDocumentReference();
      when(mockFirestore.collection('users'))
          .thenReturn(mockCollectionRef);
      when(mockCollectionRef.doc('test_user_123'))
          .thenReturn(mockDocRef);
      when(mockDocRef.collection('workouts'))
          .thenReturn(mockWorkoutsCollection);
      when(mockWorkoutsCollection.doc())
          .thenReturn(mockWorkoutDoc);
      when(mockWorkoutDoc.set(any))
          .thenAnswer((_) async => {});

      // Act
      await repository.syncWorkoutToFirestore(session.id);

      // Assert
      verify(mockWorkoutDoc.set(argThat(containsPair('status', 'in_progress'))))
          .called(1);

      final updatedSession = await database.workoutSessionsDao
          .getSessionById(session.id);
      expect(updatedSession.synced, isTrue);
      expect(updatedSession.dirty, isFalse);
      expect(updatedSession.firestoreId, isNotEmpty);
    });

    test('getRecentWorkouts returns limited results', () async {
      // Arrange - Create 25 workouts
      for (int i = 0; i < 25; i++) {
        await repository.createWorkoutSession();
      }

      // Act
      final recentWorkouts = await repository.getRecentWorkouts(
        'test_user_123',
        limit: 10,
      );

      // Assert
      expect(recentWorkouts, hasLength(10));
    });

    test('watchWorkoutHistory returns stream of workouts', () async {
      // Arrange
      await repository.createWorkoutSession();
      await repository.createWorkoutSession();

      // Act
      final stream = repository.watchWorkoutHistory();

      // Assert
      await expectLater(
        stream,
        emits(hasLength(2)),
      );
    });
  });
}
```

#### 3.2.3 Testing Services

```dart
// test/core/services/sync_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockAppDatabase mockDatabase;
  late MockFirebaseFirestore mockFirestore;
  late MockConnectivity mockConnectivity;
  late SyncService syncService;

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockFirestore = MockFirebaseFirestore();
    mockConnectivity = MockConnectivity();

    syncService = SyncService(
      database: mockDatabase,
      firestore: mockFirestore,
      connectivity: mockConnectivity,
    );
  });

  group('SyncService', () {
    test('syncAll skips when offline', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // Act
      await syncService.syncAll();

      // Assert
      verifyNever(mockDatabase.workoutSessionsDao.getUnsyncedWorkouts(any));
      verifyNever(mockFirestore.collection(any));
    });

    test('syncAll syncs unsynced workouts when online', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final mockWorkout = WorkoutSession(
        id: 1,
        firebaseUid: 'user123',
        startTime: DateTime.now(),
        status: 'completed',
        synced: false,
        dirty: true,
      );

      when(mockDatabase.workoutSessionsDao.getUnsyncedWorkouts('user123'))
          .thenAnswer((_) async => [mockWorkout]);

      // Mock Firestore operations
      when(mockFirestore.collection('users/user123/workouts').doc())
          .thenReturn(mockDocRef);
      when(mockDocRef.set(any, any))
          .thenAnswer((_) async => {});

      // Act
      await syncService.syncAll();

      // Assert
      verify(mockDatabase.workoutSessionsDao.getUnsyncedWorkouts('user123'))
          .called(1);
      verify(mockDocRef.set(any, any)).called(1);
    });

    test('conflict resolution uses last write wins', () async {
      // Arrange
      final localWorkout = WorkoutSession(
        id: 1,
        firestoreId: 'firestore123',
        updatedAt: DateTime(2025, 1, 15, 10, 0),  // 10:00 AM
        synced: true,
      );

      final remoteWorkout = {
        'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 15, 11, 0)),  // 11:00 AM
        'status': 'completed',
      };

      when(mockDatabase.workoutSessionsDao.getSessionByFirestoreId('firestore123'))
          .thenAnswer((_) async => localWorkout);

      // Act
      await syncService._importWorkoutFromFirestore(
        MockDocumentSnapshot(data: remoteWorkout),
      );

      // Assert
      // Remote is newer, so local should be updated
      verify(mockDatabase.workoutSessionsDao.updateSession(
        argThat(predicate((WorkoutSession ws) => ws.status == 'completed')),
      )).called(1);
    });

    test('retry with exponential backoff on network error', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockFirestore.collection(any).doc().set(any))
          .thenThrow(FirebaseException(code: 'unavailable'));

      // Act & Assert
      await syncService.syncAll();

      // Should have attempted retry with backoff
      await Future.delayed(Duration(seconds: 2));  // Wait for retry

      verify(mockCrashlytics.recordError(
        argThat(isA<FirebaseException>()),
        any,
      )).called(greaterThan(1));
    });
  });
}
```

### 3.3 Unit Test Coverage Requirements

| Module | Coverage Target | Priority |
|--------|----------------|----------|
| **Providers** | 90% | HIGH - Core business logic |
| **Repositories** | 85% | HIGH - Data access critical |
| **Services** | 80% | HIGH - Background operations |
| **Models** | 70% | MEDIUM - Mostly data classes |
| **Utils** | 95% | MEDIUM - Pure functions, easy to test |

---

## 4. Widget Testing

### 4.1 Widget Test Scope

**What to test**:
- UI component rendering
- User interactions (taps, swipes, text input)
- State changes reflected in UI
- Navigation
- Error states
- Loading states

**What NOT to test**:
- Business logic (covered by unit tests)
- Network calls (mock repositories)
- Database operations (mock repositories)

### 4.2 Widget Test Examples

#### 4.2.1 Testing Stateless Widgets

```dart
// test/features/workout/widgets/set_input_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/features/workout/widgets/set_input_row.dart';

void main() {
  group('SetInputRow', () {
    testWidgets('displays input fields for reps, weight, and effort',
        (tester) async {
      // Arrange
      int? savedReps;
      double? savedWeight;
      int? savedEffort;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetInputRow(
              onSave: (reps, weight, effort) {
                savedReps = reps;
                savedWeight = weight;
                savedEffort = effort;
              },
            ),
          ),
        ),
      );

      // Assert - Check all fields are present
      expect(find.byType(TextField), findsNWidgets(2));  // Reps + Weight
      expect(find.byType(Slider), findsOneWidget);  // Effort slider
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Effort'), findsOneWidget);
    });

    testWidgets('saves set data when Add Set button is tapped',
        (tester) async {
      // Arrange
      int? savedReps;
      double? savedWeight;
      int? savedEffort;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetInputRow(
              onSave: (reps, weight, effort) {
                savedReps = reps;
                savedWeight = weight;
                savedEffort = effort;
              },
            ),
          ),
        ),
      );

      // Act - Enter data
      await tester.enterText(
        find.widgetWithText(TextField, 'Reps'),
        '8',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Weight'),
        '80.5',
      );

      // Adjust effort slider to 7
      final sliderFinder = find.byType(Slider);
      await tester.drag(sliderFinder, Offset(100, 0));
      await tester.pumpAndSettle();

      // Tap Add Set button
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedReps, equals(8));
      expect(savedWeight, closeTo(80.5, 0.01));
      expect(savedEffort, isNotNull);
    });

    testWidgets('validates reps input (must be positive)',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SetInputRow(onSave: (_, __, ___) {}),
          ),
        ),
      );

      // Act - Enter invalid data
      await tester.enterText(
        find.widgetWithText(TextField, 'Reps'),
        '0',
      );
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Assert - Error message displayed
      expect(find.text('Reps must be greater than 0'), findsOneWidget);
    });
  });
}
```

#### 4.2.2 Testing Stateful Widgets with Riverpod

```dart
// test/features/workout/screens/active_workout_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:gymapp/features/workout/screens/active_workout_screen.dart';
import 'package:gymapp/features/workout/providers/active_workout_provider.dart';

void main() {
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  group('ActiveWorkoutScreen', () {
    testWidgets('displays empty state when no workout started',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('No active workout'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
    });

    testWidgets('starts workout when Start Workout button tapped',
        (tester) async {
      // Arrange
      final mockSession = WorkoutSession(
        id: 1,
        firebaseUid: 'user123',
        startTime: DateTime.now(),
        status: 'in_progress',
      );

      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async => mockSession);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add Exercise'), findsOneWidget);
      expect(find.text('Finish Workout'), findsOneWidget);
      verify(mockRepository.createWorkoutSession()).called(1);
    });

    testWidgets('displays exercises after adding them',
        (tester) async {
      // Arrange
      final mockSession = WorkoutSession(/* ... */);
      final mockExercise = WorkoutExerciseWithSets(
        exercise: Exercise(id: 1, name: 'Bench Press'),
        sets: [],
      );

      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async => mockSession);
      when(mockRepository.addExerciseToWorkout(
        workoutId: anyNamed('workoutId'),
        exerciseId: anyNamed('exerciseId'),
        suggestedSets: anyNamed('suggestedSets'),
      )).thenAnswer((_) async => mockExercise);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Act - Add exercise (simplified, normally goes through exercise picker)
      // This would be tested in integration test

      // Assert
      // Verify exercise card is displayed
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('displays loading indicator while starting workout',
        (tester) async {
      // Arrange
      when(mockRepository.createWorkoutSession())
          .thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return WorkoutSession(/* ... */);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Start Workout'));
      await tester.pump();  // Don't settle, check during loading

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message on workout creation failure',
        (tester) async {
      // Arrange
      when(mockRepository.createWorkoutSession())
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to start workout'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
```

#### 4.2.3 Testing Navigation

```dart
// test/features/workout/screens/workout_history_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('navigates to workout detail when workout card tapped',
      (tester) async {
    // Arrange
    bool navigatedToDetail = false;
    final mockRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => WorkoutHistoryScreen(),
        ),
        GoRoute(
          path: '/workout/:id',
          builder: (context, state) {
            navigatedToDetail = true;
            return WorkoutDetailScreen(
              workoutId: int.parse(state.params['id']!),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: mockRouter,
      ),
    );
    await tester.pumpAndSettle();

    // Act - Tap on first workout card
    await tester.tap(find.byType(WorkoutCard).first);
    await tester.pumpAndSettle();

    // Assert
    expect(navigatedToDetail, isTrue);
  });
}
```

### 4.3 Widget Test Best Practices

1. **Use `pumpAndSettle()` for animations**: Wait for all animations to complete
2. **Use `pump()` for testing loading states**: Don't wait for async operations
3. **Use finders effectively**:
   - `find.text('text')` - Find by text
   - `find.byType(Widget)` - Find by widget type
   - `find.byKey(ValueKey('key'))` - Find by key (best for stable tests)
4. **Mock repositories, not widgets**: Override Riverpod providers, not UI
5. **Test user journeys**: Test full flows (e.g., start workout → add exercise → log set)

---

## 5. Integration Testing

### 5.1 Integration Test Scope

**What to test**:
- Multi-feature workflows
- Database → Repository → Provider → UI integration
- Offline-to-online sync scenarios
- Firebase Authentication flows
- Third-party API integrations (Strava, Apple Health)

### 5.2 Integration Test Examples

#### 5.2.1 Complete Workout Flow

```dart
// integration_test/workout_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Workout Flow', () {
    testWidgets('user can log a complete workout', (tester) async {
      // Arrange - Start app
      app.main();
      await tester.pumpAndSettle();

      // Assume user is already logged in (setup in setUp block)

      // Act 1: Start workout
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Act 2: Add exercise
      await tester.tap(find.text('Add Exercise'));
      await tester.pumpAndSettle();

      // Search for Bench Press
      await tester.enterText(find.byType(TextField), 'Bench Press');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Act 3: Log first set
      await tester.enterText(find.widgetWithText(TextField, 'Reps'), '8');
      await tester.enterText(find.widgetWithText(TextField, 'Weight'), '80');
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Verify set is added
      expect(find.text('1 × 8 × 80kg'), findsOneWidget);

      // Act 4: Log second set
      await tester.enterText(find.widgetWithText(TextField, 'Reps'), '8');
      await tester.enterText(find.widgetWithText(TextField, 'Weight'), '80');
      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      // Act 5: Finish workout
      await tester.tap(find.text('Finish Workout'));
      await tester.pumpAndSettle();

      // Assert - Workout summary displayed
      expect(find.text('Workout Summary'), findsOneWidget);
      expect(find.text('1 exercise'), findsOneWidget);
      expect(find.text('2 sets'), findsOneWidget);
      expect(find.text('1,280kg volume'), findsOneWidget);

      // Assert - Workout appears in history
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });
  });
}
```

#### 5.2.2 Offline Sync Integration Test

```dart
// integration_test/offline_sync_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Sync', () {
    testWidgets('workout logged offline syncs when online', (tester) async {
      // Arrange - Start app in offline mode
      await setNetworkConnectivity(false);
      app.main();
      await tester.pumpAndSettle();

      // Act 1: Log workout offline
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // ... add exercise and log sets ...

      await tester.tap(find.text('Finish Workout'));
      await tester.pumpAndSettle();

      // Verify offline indicator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Not synced'), findsOneWidget);

      // Act 2: Go online
      await setNetworkConnectivity(true);
      await tester.pump(Duration(seconds: 1));  // Wait for connectivity change
      await tester.pumpAndSettle();

      // Assert - Sync indicator changes
      await tester.pump(Duration(seconds: 5));  // Wait for sync
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);

      // Verify data in Firestore
      final workouts = await getFirestoreWorkouts('test_user_123');
      expect(workouts, hasLength(1));
      expect(workouts[0].status, equals('completed'));
    });

    testWidgets('conflict resolution uses last write wins', (tester) async {
      // Arrange - Create workout on Device A (offline)
      await setNetworkConnectivity(false);
      app.main();
      await tester.pumpAndSettle();

      // Log workout with Bench Press
      // ... (simplified for brevity)

      // Simulate Device B editing same workout (online)
      await editWorkoutOnDeviceB(workoutId: 'workout123', exercise: 'Squat');

      // Act - Device A goes online
      await setNetworkConnectivity(true);
      await tester.pump(Duration(seconds: 5));

      // Assert - Conflict detected, Device B wins (newer timestamp)
      expect(find.text('Sync Conflict'), findsOneWidget);
      expect(find.text('Workout was modified on another device'), findsOneWidget);

      // User can choose to keep local or accept remote
      await tester.tap(find.text('Accept Remote'));
      await tester.pumpAndSettle();

      // Verify workout now has Squat instead of Bench Press
      final workout = await getLocalWorkout('workout123');
      expect(workout.exercises[0].name, equals('Squat'));
    });
  });
}
```

#### 5.2.3 Authentication Flow Integration Test

```dart
// integration_test/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('new user can sign up and complete onboarding', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act 1: Tap Sign Up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Act 2: Enter email and password
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'SecurePassword123!',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Assert 1: GDPR consent screen appears
      expect(find.text('Privacy & Data Consent'), findsOneWidget);

      // Act 3: Accept GDPR consent
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.text('I Agree'));
      await tester.pumpAndSettle();

      // Assert 2: Onboarding screen appears
      expect(find.text('What\'s your fitness goal?'), findsOneWidget);

      // Act 4: Complete onboarding
      await tester.tap(find.text('Build Muscle'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intermediate'));
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Assert 3: Home screen appears
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Welcome to GymApp!'), findsOneWidget);
    });

    testWidgets('existing user can log in', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'existing@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'ExistingPassword123!',
      );
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Start Workout'), findsOneWidget);

      // Verify user data loaded from Firestore
      expect(find.text('5-Day Streak'), findsOneWidget);  // Existing streak
    });
  });
}
```

### 5.3 Integration Test Environment

**Test Database**: Use Firebase Emulator Suite for integration tests
```bash
firebase emulators:start --only firestore,auth,storage
```

**Test Configuration**:
```dart
// integration_test/test_config.dart
void setupTestEnvironment() {
  // Use Firebase Emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

  // Use in-memory Drift database
  setupDriftTestDatabase();
}
```

---

## 6. End-to-End Testing

### 6.1 E2E Test Scope

**What to test**:
- Critical user journeys (smoke tests)
- Real Firebase backend (staging environment)
- Real device/simulator (not just emulator)
- Performance under real conditions

### 6.2 E2E Test Examples

#### 6.2.1 Smoke Test Suite

```dart
// integration_test/smoke_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke Tests (Critical Paths)', () {
    testWidgets('SMOKE: New user signup → onboarding → first workout',
        (tester) async {
      // This is the MOST critical path - if this breaks, app is unusable

      app.main();
      await tester.pumpAndSettle();

      // Signup
      await signupNewUser(tester, email: generateRandomEmail());

      // Onboarding
      await completeOnboarding(tester);

      // Start workout
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Add exercise
      await addExercise(tester, exerciseName: 'Bench Press');

      // Log 3 sets
      for (int i = 0; i < 3; i++) {
        await logSet(tester, reps: 8, weight: 80);
      }

      // Finish workout
      await tester.tap(find.text('Finish Workout'));
      await tester.pumpAndSettle();

      // Assert success
      expect(find.text('Workout Summary'), findsOneWidget);
      expect(find.text('3 sets'), findsOneWidget);
    });

    testWidgets('SMOKE: Existing user login → view history → log workout',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await loginExistingUser(tester, email: 'test@example.com');

      // View history
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutCard), findsWidgets);

      // Start new workout
      await tester.tap(find.byIcon(Icons.home));
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Quick start from template
      await tester.tap(find.text('Push Day'));  // Pre-saved template
      await tester.pumpAndSettle();

      // Verify exercises pre-loaded from template
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);

      // Log sets and finish
      await logMultipleSets(tester);
      await finishWorkout(tester);

      expect(find.text('Workout Summary'), findsOneWidget);
    });

    testWidgets('SMOKE: Smart Pattern Memory pre-fills workout',
        (tester) async {
      // This tests the KILLER FEATURE

      app.main();
      await tester.pumpAndSettle();
      await loginExistingUser(tester, email: 'test@example.com');

      // Start workout
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Add exercise
      await addExercise(tester, exerciseName: 'Bench Press');

      // Assert - Pattern Memory pre-filled sets
      expect(find.text('Last logged: 3 days ago'), findsOneWidget);
      expect(find.text('Set 1: 8 × 80kg'), findsOneWidget);
      expect(find.text('Set 2: 8 × 80kg'), findsOneWidget);
      expect(find.text('Set 3: 8 × 80kg'), findsOneWidget);

      // Tap "Accept All" to use pre-filled data
      await tester.tap(find.text('Accept All'));
      await tester.pumpAndSettle();

      // Verify sets logged
      expect(find.text('3 sets logged'), findsOneWidget);
    });
  });
}
```

### 6.3 E2E Test Environment

- **Backend**: Firebase Staging Project
- **Devices**: iOS Simulator (iPhone 14), Android Emulator (Pixel 7)
- **Test Data**: Pre-seeded test accounts with workout history
- **Execution**: Runs nightly in CI/CD

---

## 7. Test Coverage Requirements

### 7.1 Coverage Metrics

| Metric | Target | Enforcement |
|--------|--------|-------------|
| **Overall Code Coverage** | ≥80% | Blocked in CI if <80% |
| **Critical Modules** | ≥90% | Manual review required |
| **New Code** | ≥85% | PR checks fail if <85% |
| **Regression Coverage** | 100% | All bugs fixed must have test |

### 7.2 Coverage by Module

| Module | Unit | Widget | Integration | Priority |
|--------|------|--------|-------------|----------|
| **Workout Logging** | 95% | 85% | 100% | CRITICAL |
| **Smart Pattern Memory** | 95% | 80% | 100% | CRITICAL |
| **Offline Sync** | 90% | N/A | 100% | CRITICAL |
| **Authentication** | 85% | 80% | 100% | HIGH |
| **Progress Charts** | 80% | 85% | 50% | HIGH |
| **Templates** | 85% | 80% | 75% | MEDIUM |
| **Social** | 75% | 75% | 50% | MEDIUM |
| **Habits** | 80% | 80% | 50% | MEDIUM |

### 7.3 Coverage Reporting

```bash
# Generate coverage report
flutter test --coverage

# Convert to HTML
genhtml coverage/lcov.info -o coverage/html

# Upload to Codecov
bash <(curl -s https://codecov.io/bash) -t $CODECOV_TOKEN
```

**CI/CD Integration**:
```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: flutter test --coverage

- name: Check coverage threshold
  run: |
    lcov --summary coverage/lcov.info | grep "lines......: 80" || exit 1

- name: Upload to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
    fail_ci_if_error: true
```

---

## 8. Testing Tools & Frameworks

### 8.1 Testing Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  # Core testing
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Mocking
  mockito: ^5.4.4
  build_runner: ^2.4.7

  # Code generation for mocks
  mockito_annotations: ^5.4.4

  # Test utilities
  fake_async: ^1.3.1
  clock: ^1.1.1

  # Integration test driver
  flutter_driver:
    sdk: flutter

  # Network mocking
  http_mock_adapter: ^0.6.0

  # Firebase mocking
  firebase_auth_mocks: ^0.13.0
  fake_cloud_firestore: ^2.4.0
```

### 8.2 Test Helpers & Utilities

```dart
// test/helpers/test_helpers.dart

// Pump until a condition is met
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));

    if (tester.any(finder)) {
      return;
    }
  }

  throw Exception('Timeout waiting for $finder');
}

// Create test workout session
WorkoutSession createTestWorkoutSession({
  int id = 1,
  String userId = 'test_user',
  DateTime? startTime,
  String status = 'in_progress',
}) {
  return WorkoutSession(
    id: id,
    firebaseUid: userId,
    startTime: startTime ?? DateTime.now(),
    status: status,
    synced: false,
    dirty: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Create test provider container
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      // Common test overrides
      driftProvider.overrideWithValue(createTestDatabase()),
      ...overrides,
    ],
  );
}

// Setup Firebase emulator
void setupFirebaseEmulator() {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## 9. Test Organization

### 9.1 Test Directory Structure

```
test/
├── helpers/
│   ├── test_helpers.dart           # Common test utilities
│   ├── mock_factories.dart         # Mock object factories
│   └── test_data.dart              # Test fixtures
│
├── core/
│   ├── database/
│   │   ├── daos/
│   │   │   ├── users_dao_test.dart
│   │   │   └── workout_sessions_dao_test.dart
│   │   └── app_database_test.dart
│   │
│   ├── services/
│   │   ├── sync_service_test.dart
│   │   ├── gdpr_service_test.dart
│   │   └── notification_service_test.dart
│   │
│   └── utils/
│       ├── validators_test.dart
│       └── formatters_test.dart
│
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_controller_provider_test.dart
│   │   ├── repositories/
│   │   │   └── auth_repository_test.dart
│   │   └── screens/
│   │       ├── login_screen_test.dart
│   │       └── signup_screen_test.dart
│   │
│   ├── workout/
│   │   ├── providers/
│   │   │   ├── active_workout_provider_test.dart
│   │   │   └── pattern_memory_provider_test.dart
│   │   ├── repositories/
│   │   │   └── workout_repository_test.dart
│   │   ├── screens/
│   │   │   └── active_workout_screen_test.dart
│   │   └── widgets/
│   │       ├── set_input_row_test.dart
│   │       └── exercise_card_test.dart
│   │
│   └── progress/
│       ├── providers/
│       │   └── charts_provider_test.dart
│       └── widgets/
│           └── line_chart_widget_test.dart
│
└── mocks/
    ├── mock_workout_repository.dart
    ├── mock_firestore.dart
    ├── mock_firebase_auth.dart
    └── mock_drift_database.dart

integration_test/
├── auth_flow_test.dart
├── workout_flow_test.dart
├── offline_sync_test.dart
├── pattern_memory_test.dart
└── smoke_test.dart
```

### 9.2 Naming Conventions

| Test Type | File Naming | Test Naming |
|-----------|-------------|-------------|
| **Unit** | `<class_name>_test.dart` | `test('description', () {...})` |
| **Widget** | `<widget_name>_test.dart` | `testWidgets('description', (tester) {...})` |
| **Integration** | `<feature>_flow_test.dart` | `testWidgets('user can...', (tester) {...})` |
| **E2E** | `smoke_test.dart` | `testWidgets('SMOKE: ...', (tester) {...})` |

---

## 10. Mocking & Test Data

### 10.1 Mock Strategies

#### 10.1.1 Mocking Repositories with Mockito

```dart
// test/mocks/mock_workout_repository.dart
import 'package:mockito/annotations.dart';
import 'package:gymapp/features/workout/repositories/workout_repository.dart';

@GenerateMocks([WorkoutRepository])
void main() {}  // Required for code generation

// Generated file: mock_workout_repository.mocks.dart
// Usage:
// final mockRepo = MockWorkoutRepository();
// when(mockRepo.createWorkoutSession()).thenAnswer((_) async => mockSession);
```

#### 10.1.2 Mocking Firebase with Fake Cloud Firestore

```dart
// test/helpers/firebase_mocks.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

FakeFirebaseFirestore createMockFirestore() {
  final firestore = FakeFirebaseFirestore();

  // Pre-populate with test data
  firestore.collection('users').doc('test_user').set({
    'email': 'test@example.com',
    'displayName': 'Test User',
    'createdAt': FieldValue.serverTimestamp(),
  });

  return firestore;
}

MockFirebaseAuth createMockAuth() {
  return MockFirebaseAuth(
    mockUser: MockUser(
      uid: 'test_user',
      email: 'test@example.com',
      displayName: 'Test User',
    ),
  );
}
```

#### 10.1.3 Mocking Drift Database

```dart
// test/helpers/drift_test_database.dart
import 'package:drift/native.dart';
import 'package:gymapp/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  // Use in-memory database for tests
  final database = AppDatabase(NativeDatabase.memory());

  // Optionally seed with test data
  seedTestData(database);

  return database;
}

Future<void> seedTestData(AppDatabase database) async {
  // Insert test exercises
  await database.into(database.exercises).insert(
    ExercisesCompanion.insert(
      name: 'Bench Press',
      category: 'chest',
      equipment: 'barbell',
      muscleGroup: 'chest',
    ),
  );

  // Insert test workout
  final sessionId = await database.into(database.workoutSessions).insert(
    WorkoutSessionsCompanion.insert(
      firebaseUid: 'test_user',
      startTime: DateTime.now().subtract(Duration(days: 3)),
      endTime: Value(DateTime.now().subtract(Duration(days: 3, hours: -1))),
      status: 'completed',
    ),
  );

  // Insert test sets
  // ...
}
```

### 10.2 Test Data Factories

```dart
// test/helpers/test_data.dart
import 'package:gymapp/features/workout/models/workout_session.dart';

class TestData {
  static WorkoutSession createWorkoutSession({
    int id = 1,
    String userId = 'test_user',
    DateTime? startTime,
    String status = 'completed',
  }) {
    return WorkoutSession(
      id: id,
      firebaseUid: userId,
      startTime: startTime ?? DateTime.now().subtract(Duration(days: 3)),
      endTime: DateTime.now().subtract(Duration(days: 3, hours: -1)),
      status: status,
      synced: true,
      dirty: false,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      updatedAt: DateTime.now().subtract(Duration(days: 3)),
    );
  }

  static Exercise createExercise({
    int id = 1,
    String name = 'Bench Press',
  }) {
    return Exercise(
      id: id,
      name: name,
      category: 'chest',
      equipment: 'barbell',
      muscleGroup: 'chest',
      isCustom: false,
      createdAt: DateTime.now(),
    );
  }

  static WorkoutSet createWorkoutSet({
    int id = 1,
    int setNumber = 1,
    int reps = 8,
    double weight = 80.0,
  }) {
    return WorkoutSet(
      id: id,
      workoutExerciseId: 1,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      unit: 'kg',
      perceivedEffort: 7,
      timestamp: DateTime.now(),
    );
  }
}
```

---

## 11. CI/CD Integration

### 11.1 GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-and-widget-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Verify formatting
        run: flutter format --set-exit-if-changed .

      - name: Analyze code
        run: flutter analyze

      - name: Run unit and widget tests
        run: flutter test --coverage --reporter=expanded

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          fail_ci_if_error: true

  integration-tests:
    runs-on: macos-latest  # Need macOS for iOS Simulator
    timeout-minutes: 30

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Start Firebase Emulators
        run: |
          firebase emulators:start --only firestore,auth,storage &
          sleep 10  # Wait for emulators to start

      - name: Get dependencies
        run: flutter pub get

      - name: Run integration tests (iOS)
        run: |
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/smoke_test.dart \
            -d 'iPhone 14'

      - name: Setup Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 29
          script: |
            flutter drive \
              --driver=test_driver/integration_test.dart \
              --target=integration_test/smoke_test.dart

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-results
          path: build/integration_test_results/

  e2e-tests:
    runs-on: macos-latest
    timeout-minutes: 60
    if: github.ref == 'refs/heads/main'  # Only on main branch

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run E2E tests (iOS - Staging)
        env:
          FIREBASE_CONFIG: ${{ secrets.FIREBASE_STAGING_CONFIG }}
        run: |
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/smoke_test.dart \
            --dart-define=ENVIRONMENT=staging \
            -d 'iPhone 14'

      - name: Upload E2E test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-test-results
          path: build/e2e_test_results/
```

### 11.2 Pre-Commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/sh

echo "Running pre-commit checks..."

# Run unit tests
echo "Running unit tests..."
flutter test

if [ $? -ne 0 ]; then
  echo "Unit tests failed. Commit aborted."
  exit 1
fi

# Check code formatting
echo "Checking code formatting..."
flutter format --set-exit-if-changed .

if [ $? -ne 0 ]; then
  echo "Code is not formatted. Run 'flutter format .' and try again."
  exit 1
fi

# Run static analysis
echo "Running static analysis..."
flutter analyze

if [ $? -ne 0 ]; then
  echo "Static analysis failed. Fix the issues and try again."
  exit 1
fi

echo "All checks passed!"
exit 0
```

---

## 12. Performance Testing

### 12.1 Performance Benchmarks

```dart
// test/performance/workout_logging_benchmark.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';

void main() {
  group('Performance Benchmarks', () {
    test('workout logging completes in <2 minutes', () async {
      final stopwatch = Stopwatch()..start();

      // Simulate workout logging flow
      await startWorkout();
      await addExercise('Bench Press');
      for (int i = 0; i < 3; i++) {
        await logSet(reps: 8, weight: 80);
      }
      await finishWorkout();

      stopwatch.stop();

      // Assert performance requirement
      expect(
        stopwatch.elapsed,
        lessThan(Duration(minutes: 2)),
        reason: 'Workout logging took ${stopwatch.elapsed}',
      );
    });

    test('app startup completes in <2 seconds', () async {
      final stopwatch = Stopwatch()..start();

      await initializeApp();  // Firebase, Drift, etc.

      stopwatch.stop();

      expect(
        stopwatch.elapsed,
        lessThan(Duration(seconds: 2)),
        reason: 'App startup took ${stopwatch.elapsed}',
      );
    });

    test('chart rendering completes in <1 second', () async {
      // Setup: Create workout history
      await seedWorkoutHistory(workoutCount: 100);

      final stopwatch = Stopwatch()..start();

      await renderProgressChart(exerciseId: 1);

      stopwatch.stop();

      expect(
        stopwatch.elapsed,
        lessThan(Duration(seconds: 1)),
        reason: 'Chart rendering took ${stopwatch.elapsed}',
      );
    });
  });
}
```

### 12.2 Memory Profiling

```dart
// test/performance/memory_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_service/vm_service.dart' as vm;

void main() {
  test('memory usage stays below 200MB during workout', () async {
    final vmService = await vm.vmServiceConnectUri('ws://localhost:8181/ws');

    // Get initial memory usage
    final initialMemory = await vmService.getMemoryUsage('isolates/main');

    // Perform workout logging operations
    await performWorkoutOperations();

    // Get final memory usage
    final finalMemory = await vmService.getMemoryUsage('isolates/main');

    final memoryIncrease = finalMemory.heapUsage! - initialMemory.heapUsage!;
    final memoryIncreaseMB = memoryIncrease / (1024 * 1024);

    expect(
      memoryIncreaseMB,
      lessThan(200),
      reason: 'Memory increased by ${memoryIncreaseMB}MB',
    );
  });
}
```

---

## 13. Security Testing

### 13.1 Security Test Checklist

| Security Concern | Test | Status |
|------------------|------|--------|
| **SQL Injection** | Test Drift queries with malicious input | ✅ Automated |
| **XSS** | Test text input sanitization | ✅ Automated |
| **Authentication** | Test Firebase Auth token validation | ✅ Automated |
| **Authorization** | Test Firestore security rules | ✅ Manual |
| **Data Encryption** | Verify TLS 1.3 in network calls | ✅ Manual |
| **GDPR Compliance** | Test data deletion, export, consent | ✅ Automated |
| **Secret Management** | Verify no hardcoded secrets | ✅ Static Analysis |

### 13.2 Security Test Examples

```dart
// test/security/firestore_security_rules_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_rules_unit_testing/firebase_rules_unit_testing.dart';

void main() {
  setUpAll(() async {
    await initializeTestEnvironment(
      projectId: 'gymapp-test',
      firestore: FirestoreTestConfiguration(
        rules: File('firestore.rules').readAsStringSync(),
      ),
    );
  });

  group('Firestore Security Rules', () {
    test('users can only read their own data', () async {
      final alice = testEnv.authenticatedContext('alice');
      final bob = testEnv.authenticatedContext('bob');

      // Alice can read her own data
      await assertSucceeds(
        alice.firestore().collection('users').doc('alice').get(),
      );

      // Alice cannot read Bob's data
      await assertFails(
        alice.firestore().collection('users').doc('bob').get(),
      );
    });

    test('users can only write their own workouts', () async {
      final alice = testEnv.authenticatedContext('alice');

      // Alice can create her own workout
      await assertSucceeds(
        alice.firestore()
            .collection('users/alice/workouts')
            .add({'status': 'in_progress'}),
      );

      // Alice cannot create workout for Bob
      await assertFails(
        alice.firestore()
            .collection('users/bob/workouts')
            .add({'status': 'in_progress'}),
      );
    });

    test('unauthenticated users cannot access any data', () async {
      final unauth = testEnv.unauthenticatedContext();

      await assertFails(
        unauth.firestore().collection('users').doc('alice').get(),
      );
    });
  });
}
```

---

## 14. Accessibility Testing

### 14.1 Accessibility Test Checklist

```dart
// test/accessibility/accessibility_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all interactive elements have semantic labels',
      (tester) async {
    await tester.pumpWidget(MyApp());

    // Get semantics
    final semantics = tester.getSemantics(find.byType(ElevatedButton));

    expect(semantics.label, isNotEmpty);
    expect(semantics.tooltip, isNotEmpty);
  });

  testWidgets('app is navigable with screen reader', (tester) async {
    await tester.pumpWidget(MyApp());

    // Enable semantics
    tester.binding.pipelineOwner.semanticsOwner!.performAction(
      0,
      SemanticsAction.tap,
    );

    // Verify all screens have proper headings
    expect(find.bySemanticsLabel('Home Screen'), findsOneWidget);
  });

  testWidgets('text meets WCAG AA contrast ratio', (tester) async {
    await tester.pumpWidget(MyApp());

    final textWidget = tester.widget<Text>(find.byType(Text).first);
    final textColor = textWidget.style?.color ?? Colors.black;
    final backgroundColor = Theme.of(tester.element(find.byType(Scaffold)))
        .scaffoldBackgroundColor;

    final contrastRatio = _calculateContrastRatio(textColor, backgroundColor);

    expect(contrastRatio, greaterThan(4.5));  // WCAG AA standard
  });
}
```

---

## Conclusion

This test design document provides a comprehensive testing strategy for GymApp:

✅ **760+ tests** across all levels (Unit, Widget, Integration, E2E)
✅ **80%+ code coverage** enforced in CI/CD
✅ **10-minute full suite** execution time
✅ **Automated quality gates** (pre-commit, PR checks, pre-release)
✅ **Performance benchmarks** (<2s startup, <2min logging)
✅ **Security testing** (Firestore rules, GDPR compliance)
✅ **Accessibility testing** (WCAG AA compliance)

**Next Steps**:
1. ✅ Review test design with team
2. Set up test infrastructure (Firebase Emulator, CI/CD)
3. Write first unit tests for Epic 1 (Foundation)
4. Achieve 80% coverage before merging any PR
5. Run integration tests nightly
6. Run E2E smoke tests before each release

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Status**: ✅ Ready for Implementation
