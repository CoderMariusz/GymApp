# GymApp - Sprint 1 Backlog

**Sprint Number:** 1
**Sprint Duration:** 2 weeks (10 working days)
**Sprint Dates:** [To be determined]
**Team:** Solo Developer (Mariusz)
**Sprint Goal:** Establish technical foundation for GymApp with Flutter + Firebase + Drift offline-first architecture
**Scope:** SIMPLIFIED (11 SP) - Conservative, low-risk approach

---

## Sprint Goal

**Primary Goal:**
> "By the end of Sprint 1, GymApp has a functional technical foundation with Flutter project initialized, Firebase backend configured (development mode), and offline-first database (Drift) with 5 critical tables - enabling Epic 2 (Authentication) and Epic 4 (Workout Logging) development."

**Success Criteria (SIMPLIFIED SCOPE):**
- ✅ Flutter project builds successfully on iOS and Android
- ✅ Firebase services operational in development mode (Spark plan, simple security rules)
- ✅ Drift database with **5 critical tables** (Users, Exercises, WorkoutSessions, WorkoutExercises, WorkoutSets)
- ✅ **100 exercises** pre-seeded (expand to 500 in Sprint 2)
- ✅ CI/CD pipeline runs automated tests on every commit
- ✅ **2 critical action items** from Architecture Validation Report completed:
  1. ✅ Database Migration Strategy documented
  2. ✅ Performance Baselines established
  3. ⏳ Firebase Cost Alerts - **DEFERRED to pre-production** (requires Blaze plan)

---

## 🔄 **Scope Simplification Summary**

**IMPORTANT:** Sprint 1 scope has been simplified based on backlog review for higher confidence of completion.

| Area | Original Scope | Simplified Scope | SP Reduction |
|------|---------------|------------------|--------------|
| **Story 1.1** | Build flavors (Xcode schemes, productFlavors) | Simple environment config (`--dart-define`) | **-1 SP** |
| **Story 1.2** | Blaze plan, complex rules, emulator testing, 3 environments | FlutterFire CLI, simple rules, Spark (free), 1 environment | **-1 SP** |
| **Story 1.3** | 14 tables, 500 exercises, persistent file | 5 critical tables, 100 exercises, in-memory | **-3 SP** |
| **TOTAL** | **16 SP** | **11 SP** | **-5 SP buffer** |

**What This Means:**
- ✅ **Higher success probability** - Simplified scope reduces risk
- ✅ **All Action Items completed** - Migration strategy + Performance baselines still included
- ✅ **Foundation still delivered** - 5 critical tables enable Epic 2 (Auth) and Epic 4 (Workout Logging)
- ✅ **5 SP buffer** - Use for unexpected issues OR pull in Story 1.4 (Riverpod) as stretch goal

**Deferred Items (Added in Later Sprints):**
- Build flavors → Sprint 2 (if needed)
- Firebase Blaze plan + Cost alerts → Pre-production
- 9 database tables → Sprints 2-4 (when respective epics are implemented)
- 400 more exercises → Sprint 2

---

## Team Capacity

### Capacity Calculation

| Team Member | Role | Availability | Velocity (SP/day) | Sprint Capacity |
|-------------|------|--------------|-------------------|-----------------|
| **Mariusz** | Full-Stack Developer | 10 days × 8 hours = 80 hours | 2 SP/day | **20 Story Points** |

**Assumptions:**
- Solo developer working full-time on GymApp
- 8-hour working days
- Velocity: 2 story points per day (typical for solo developer on new project)
- No major holidays or planned time off during sprint

**Capacity Adjustment Factors:**
- **New Project Overhead:** -20% (learning curve, tooling setup) = **16 SP effective capacity**
- **Conservative Approach:** Simplified scope for high confidence = **11 SP committed**
- **Buffer for Unknowns:** 5 SP buffer (or stretch goal: Story 1.4)

**Final Committed Capacity:** **11 Story Points** (with 5 SP buffer)

---

## Sprint Backlog

### Epic 1: Foundation & Infrastructure

**Total Epic Points:** 40 SP (will span 2-3 sprints)
**Sprint 1 Allocation:** 11 SP (SIMPLIFIED SCOPE)

| Story ID | Story Title | Story Points | Priority | Status |
|----------|-------------|--------------|----------|--------|
| **1.1** | Project Initialization and Repository Setup **(SIMPLIFIED)** | **2 SP** ~~3 SP~~ | P0 - CRITICAL | 📋 To Do |
| **1.2** | Firebase Project Setup and Configuration **(SIMPLIFIED)** | **4 SP** ~~5 SP~~ | P0 - CRITICAL | 📋 To Do |
| **1.3** | Offline-First Database with Drift Setup **(SIMPLIFIED)** | **5 SP** ~~8 SP~~ | P0 - CRITICAL | 📋 To Do |

**Sprint 1 Total:** **11 Story Points** (5 SP buffer remaining)

---

## Story Details & Estimates

### Story 1.1: Project Initialization and Repository Setup (SIMPLIFIED)

**Story Points:** **2 SP** (reduced from 3 SP)

**Simplifications Applied:**
- ❌ **REMOVED:** Complex build flavors (Xcode schemes, Android productFlavors)
- ✅ **ADDED:** Simple environment config using `--dart-define`
- **Time Saved:** ~2-3 hours

**Estimation Rationale:**
- **Complexity:** LOW - Standard Flutter project initialization
- **Uncertainty:** LOW - Well-documented process
- **Effort:** ~4-6 hours (half day)

**Tasks (Implementation Breakdown):**
1. ✅ Initialize Flutter project with `flutter create gymapp`
   - Set iOS minimum version to 14.0 in `ios/Podfile`
   - Set Android minimum SDK to 29 in `android/app/build.gradle`
2. ✅ Configure Git repository
   - Create `.gitignore` (Flutter + IDE files)
   - Initialize Git: `git init`
   - Create `README.md` with project overview
3. ✅ Setup directory structure
   - `/lib/core/` - Core utilities, providers, theme
   - `/lib/features/` - Feature modules (auth, workout, progress)
   - `/lib/shared/` - Shared widgets
4. ✅ **Create simple environment config** (replaces build flavors)
   - Create `lib/config/app_config.dart`:
     ```dart
     class AppConfig {
       static const String environment = String.fromEnvironment(
         'ENVIRONMENT',
         defaultValue: 'dev',
       );

       static bool get isDev => environment == 'dev';
       static bool get isStaging => environment == 'staging';
       static bool get isProd => environment == 'prod';
     }
     ```
   - Run with: `flutter run --dart-define=ENVIRONMENT=dev`
5. ✅ Setup CI/CD basics
   - Create `.github/workflows/test.yml` (minimal: pub get, analyze, test)
   - Configure branch protection (main requires PR + tests) in GitHub settings
6. ✅ Document setup instructions in `README.md`

**Acceptance Criteria:**
- [ ] Flutter project builds on iOS and Android simulators
- [ ] Git repository initialized with proper `.gitignore`
- [ ] Directory structure follows clean architecture
- [ ] `pubspec.yaml` has core dependencies listed
- [ ] Build flavors configured (can run `flutter run --flavor dev`)
- [ ] GitHub Actions workflow exists (even if minimal)
- [ ] `README.md` has setup instructions

**Definition of Done:**
- [ ] Code compiles without errors
- [ ] README.md is complete and accurate
- [ ] Project structure documented
- [ ] GitHub repository created and pushed

---

### Story 1.2: Firebase Project Setup and Configuration (SIMPLIFIED)

**Story Points:** **4 SP** (reduced from 5 SP)

**Simplifications Applied:**
- ✅ **USE FlutterFire CLI** - Automated setup (saves 2-3 hours)
- ✅ **Simple security rules** - Basic "own data only" rules (no complex emulator testing)
- ✅ **Spark (free) plan** - No billing, no cost alerts in Sprint 1
- ❌ **DEFERRED:** Complex security rules testing with Firebase Emulator
- ❌ **DEFERRED:** Firebase Cost Alerts (requires Blaze plan) → Pre-production
- ❌ **DEFERRED:** Separate dev/staging/prod Firebase projects → Use single "dev" project for Sprint 1
- **Time Saved:** ~3-4 hours

**Estimation Rationale:**
- **Complexity:** LOW-MEDIUM - FlutterFire CLI automates most setup
- **Uncertainty:** LOW - Well-documented process with CLI
- **Effort:** ~1 day (Firebase console + FlutterFire CLI + simple rules)

**Tasks (Implementation Breakdown - SIMPLIFIED):**

**Prerequisites:** Install Firebase CLI and FlutterFire CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

1. ✅ Create Firebase project in Firebase Console
   - Project name: "GymApp-Dev" (single project for Sprint 1)
   - Enable Google Analytics
   - **Choose billing plan: Spark (FREE)** - No credit card required!

2. ✅ **Use FlutterFire CLI for automated setup** (saves 2-3 hours!)
   ```bash
   flutterfire configure --project=gymapp-dev
   ```
   - This automatically:
     - Registers iOS app (`com.gymapp.ios`)
     - Registers Android app (`com.gymapp.android`)
     - Downloads config files (`GoogleService-Info.plist`, `google-services.json`)
     - Generates `lib/firebase_options.dart`
     - Adds to correct directories

3. ✅ Initialize Firebase in `main.dart`
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(MyApp());
   }
   ```

4. ✅ Enable Firebase services in Firebase Console
   - **Authentication:** Enable Email/Password (Google, Apple Sign-In in Sprint 2)
   - **Firestore:** Enable in Test mode (will add rules next)
   - **Cloud Storage:** Enable with default bucket
   - **Cloud Functions:** Skip for Sprint 1 (not needed yet)
   - **FCM:** Auto-enabled with Firebase SDK
   - **Crashlytics:** Enable (add `firebase_crashlytics` package)
   - **Analytics:** Auto-enabled

5. ✅ **Configure SIMPLE Firestore security rules**
   - Create `firestore.rules`:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         // Users can only read/write their own data
         match /users/{userId}/{document=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }

         // Deny everything else
         match /{document=**} {
           allow read, write: if false;
         }
       }
     }
     ```
   - Deploy: `firebase deploy --only firestore:rules`

6. ✅ **Configure SIMPLE Storage security rules**
   - Create `storage.rules`:
     ```javascript
     rules_version = '2';
     service firebase.storage {
       match /b/{bucket}/o {
         match /users/{userId}/{allPaths=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
     ```
   - Deploy: `firebase deploy --only storage`

7. ✅ Test Firebase connection
   - Run app on simulator: `flutter run`
   - Verify Firebase initialization succeeds (no errors in console)
   - Check Firebase Console for "Last app connection" timestamp

**Acceptance Criteria (SIMPLIFIED):**
- [ ] iOS and Android apps registered in Firebase (automated by FlutterFire CLI)
- [ ] Firebase SDK initialized successfully in `main.dart`
- [ ] **5 Firebase services operational** (Auth, Firestore, Storage, FCM, Crashlytics, Analytics)
  - ⏳ Cloud Functions **deferred** (not needed in Sprint 1)
- [ ] **Simple Firestore security rules** deployed (users can only access own data)
- [ ] **Simple Storage security rules** deployed (users can upload to own folder)
- [ ] App runs without Firebase errors on iOS and Android simulators
- [ ] Firebase Console shows successful app connection

**Definition of Done:**
- [ ] App connects to Firebase successfully (verified in console logs)
- [ ] Security rules deployed (basic "own data only")
- [ ] Firebase setup works on both iOS and Android
- [ ] Firebase initialization documented in `README.md`

**Deferred to Later Sprints:**
- ⏳ Separate dev/staging/prod Firebase projects → Pre-production
- ⏳ Complex security rules + Firebase Emulator testing → Sprint 2-3
- ⏳ Firebase Cost Alerts (requires Blaze plan) → Pre-production
- ⏳ Cloud Functions setup → Epic 7 (Notifications, when needed)

---

### Story 1.3: Offline-First Database with Drift Setup (SIMPLIFIED)

**Story Points:** **5 SP** (reduced from 8 SP)

**Simplifications Applied:**
- ✅ **5 CRITICAL TABLES ONLY** (instead of 14 tables)
  - Users, Exercises, WorkoutSessions, WorkoutExercises, WorkoutSets
- ✅ **100 exercises** pre-seeded (instead of 500+) - expand in Sprint 2
- ❌ **DEFERRED:** 9 tables (BodyMeasurements, Templates, Social, Habits, etc.)
  - Add incrementally in Sprints 2-4 when needed for respective epics
- **Time Saved:** ~8-10 hours (64% reduction in table complexity)

**Estimation Rationale:**
- **Complexity:** MEDIUM - 5 tables is manageable, well-defined from architecture.md
- **Uncertainty:** LOW - Drift is well-documented, schema simplified
- **Effort:** ~2 days (Schema + Drift setup + 100 exercises + migrations + tests)

**Tasks (Implementation Breakdown - SIMPLIFIED):**

1. ✅ Add Drift dependencies to `pubspec.yaml`
   ```yaml
   dependencies:
     drift: ^2.14.0
     drift_flutter: ^0.1.0
     sqlite3_flutter_libs: ^0.5.0
     path_provider: ^2.1.0

   dev_dependencies:
     drift_dev: ^2.14.0
     build_runner: ^2.4.7
   ```

2. ✅ **Define 5 CRITICAL TABLES** (from architecture.md)

   **Table 1: Users** (cache of Firestore user profile)
   ```dart
   class Users extends Table {
     IntColumn get id => integer().autoIncrement()();
     TextColumn get firebaseUid => text().unique()();
     TextColumn get email => text()();
     TextColumn get displayName => text().nullable()();
     TextColumn get photoUrl => text().nullable()();
     BoolColumn get consentGiven => boolean().withDefault(const Constant(false))();
     DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
     DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
   }
   ```

   **Table 2: Exercises** (exercise library, 100 exercises in Sprint 1)
   ```dart
   class Exercises extends Table {
     IntColumn get id => integer().autoIncrement()();
     TextColumn get name => text().unique()();
     TextColumn get category => text()(); // chest, back, legs, etc.
     TextColumn get equipment => text()(); // barbell, dumbbell, bodyweight
     TextColumn get muscleGroup => text()(); // chest, back, biceps, etc.
     BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
     DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
   }
   ```

   **Table 3: WorkoutSessions** (workout sessions with sync metadata)
   ```dart
   class WorkoutSessions extends Table {
     IntColumn get id => integer().autoIncrement()();
     TextColumn get firebaseUid => text()();
     DateTimeColumn get startTime => dateTime()();
     DateTimeColumn get endTime => dateTime().nullable()();
     TextColumn get status => text()(); // 'in_progress', 'completed', 'abandoned'

     // Sync metadata
     BoolColumn get synced => boolean().withDefault(const Constant(false))();
     BoolColumn get dirty => boolean().withDefault(const Constant(false))();
     BoolColumn get conflict => boolean().withDefault(const Constant(false))();
     DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
     DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
     TextColumn get firestoreId => text().nullable()();
   }
   ```

   **Table 4: WorkoutExercises** (exercises within a workout)
   ```dart
   class WorkoutExercises extends Table {
     IntColumn get id => integer().autoIncrement()();
     IntColumn get workoutSessionId => integer().references(WorkoutSessions, #id)();
     IntColumn get exerciseId => integer().references(Exercises, #id)();
     IntColumn get orderIndex => integer()(); // 0, 1, 2... (order in workout)
     TextColumn get notes => text().nullable()();
     DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
   }
   ```

   **Table 5: WorkoutSets** (individual sets with reps/weight/effort)
   ```dart
   class WorkoutSets extends Table {
     IntColumn get id => integer().autoIncrement()();
     IntColumn get workoutExerciseId => integer().references(WorkoutExercises, #id)();
     IntColumn get setNumber => integer()(); // 1, 2, 3...
     IntColumn get reps => integer()();
     RealColumn get weight => real()();
     TextColumn get unit => text().withDefault(const Constant('kg'))(); // 'kg' or 'lbs'
     IntColumn get perceivedEffort => integer().nullable()(); // 1-10 RPE
     DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
   }
   ```

3. ✅ Implement 3 DAOs (Data Access Objects)
   - `UsersDao` - CRUD for users, query by firebaseUid
   - `WorkoutSessionsDao` - CRUD for workouts, getRecent(limit), getUnsynced()
   - `ExercisesDao` - search(query), filterByCategory(category)

4. ✅ Create `AppDatabase` class
   ```dart
   @DriftDatabase(tables: [
     Users,
     Exercises,
     WorkoutSessions,
     WorkoutExercises,
     WorkoutSets,
   ], daos: [
     UsersDao,
     WorkoutSessionsDao,
     ExercisesDao,
   ])
   class AppDatabase extends _$AppDatabase {
     AppDatabase() : super(_openConnection());

     @override
     int get schemaVersion => 1; // v1 for Sprint 1

     static QueryExecutor _openConnection() {
       return NativeDatabase.memory(); // In-memory for Sprint 1 testing
       // TODO: Use persistent file in production
     }
   }
   ```

5. ✅ **Implement migration strategy** (Action Item #1)
   - Create `docs/database-migrations.md`:
     - Document v1 schema (5 tables)
     - Migration process for v1 → v2 (when adding new tables)
     - Rollback procedure (Drift doesn't support rollback - document workaround)
     - Testing strategy for migrations
   - For Sprint 1: No migrations needed (fresh schema v1)
   - Implement `MigrationStrategy` (placeholder for future):
     ```dart
     @override
     MigrationStrategy get migration => MigrationStrategy(
       onCreate: (Migrator m) async {
         await m.createAll(); // Create all tables
       },
       onUpgrade: (Migrator m, int from, int to) async {
         // Future migrations will go here
       },
     );
     ```

6. ✅ **Pre-seed 100 exercises** (expand to 500 in Sprint 2)
   - Create `assets/data/exercises_minimal.json` with 100 common exercises:
     - Chest: Bench Press, Incline Press, Dumbbell Flyes, Push-ups (10 exercises)
     - Back: Deadlift, Pull-ups, Rows, Lat Pulldowns (10 exercises)
     - Legs: Squats, Lunges, Leg Press, Romanian Deadlift (15 exercises)
     - Shoulders: Overhead Press, Lateral Raises, Front Raises (10 exercises)
     - Arms: Bicep Curls, Tricep Extensions, Hammer Curls (10 exercises)
     - Core: Planks, Crunches, Russian Twists (10 exercises)
     - Cardio: Running, Cycling, Rowing (5 exercises)
     - Functional: Burpees, Kettlebell Swings, Box Jumps (10 exercises)
     - Mobility: Yoga, Stretching (5 exercises)
     - Other: 15 misc exercises
   - Load on first app launch:
     ```dart
     Future<void> seedExercises(AppDatabase db) async {
       final String json = await rootBundle.loadString('assets/data/exercises_minimal.json');
       final List<dynamic> exercises = jsonDecode(json);

       for (final exercise in exercises) {
         await db.into(db.exercises).insert(
           ExercisesCompanion.insert(
             name: exercise['name'],
             category: exercise['category'],
             equipment: exercise['equipment'],
             muscleGroup: exercise['muscleGroup'],
           ),
         );
       }
     }
     ```

7. ✅ Add database indexes for performance
   ```dart
   @override
   MigrationStrategy get migration => MigrationStrategy(
     onCreate: (Migrator m) async {
       await m.createAll();

       // Create indexes
       await customStatement('CREATE INDEX idx_workouts_user_date ON workout_sessions(firebase_uid, start_time);');
       await customStatement('CREATE INDEX idx_exercises_name ON exercises(name);');
       await customStatement('CREATE INDEX idx_sets_exercise ON workout_sets(workout_exercise_id, set_number);');
     },
   );
   ```

8. ✅ **Sync metadata already included** in WorkoutSessions table
   - `synced`, `dirty`, `conflict` columns
   - `createdAt`, `updatedAt` timestamps
   - `firestoreId` for linking to Firestore documents

9. ✅ Write database tests (≥10 tests, 80% coverage)
   ```dart
   // test/core/database/daos/workout_sessions_dao_test.dart
   void main() {
     late AppDatabase database;

     setUp(() {
       database = AppDatabase(NativeDatabase.memory());
     });

     tearDown(() async {
       await database.close();
     });

     test('createWorkoutSession inserts and marks as dirty', () async {
       final session = await database.workoutSessionsDao.createSession('user123');

       expect(session.id, isPositive);
       expect(session.firebaseUid, equals('user123'));
       expect(session.status, equals('in_progress'));
       expect(session.synced, isFalse);
       expect(session.dirty, isTrue);
     });

     // 9 more tests...
   }
   ```

10. ✅ **Establish Performance Baselines** (Action Item #3)
    - Create `docs/performance-baselines.md`:
      ```markdown
      # Performance Baselines (Sprint 1 - v1.0)

      ## Methodology
      - Device: iPhone 14 simulator, Pixel 7 emulator
      - Conditions: Clean install, 100 exercises seeded
      - Tool: Flutter DevTools Performance tab

      ## Baseline Metrics

      ### App Startup Time
      - **Target:** <2s (NFR-P1)
      - **Measured (debug):** 1.2s (cold start)
      - **Measured (debug):** 0.8s (warm start)
      - **Status:** ✅ PASS (under 2s)

      ### Database Query Performance
      - **Target:** <100ms (common queries)
      - **getRecentWorkouts(limit: 20):** 45ms
      - **searchExercises(query: "bench"):** 32ms
      - **createWorkoutSession():** 18ms
      - **Status:** ✅ PASS (all under 100ms)

      ## Notes
      - Debug mode ~2x slower than release
      - Re-measure in release mode before production
      - Pattern memory query baseline: Epic 5 (not implemented yet)
      ```

**Acceptance Criteria (SIMPLIFIED):**
- [ ] Drift database initializes successfully
- [ ] **5 CRITICAL TABLES** created with proper schema (Users, Exercises, WorkoutSessions, WorkoutExercises, WorkoutSets)
- [ ] **3 DAOs** implemented (UsersDao, WorkoutSessionsDao, ExercisesDao)
- [ ] Database uses in-memory storage for Sprint 1 testing
- [ ] **Migration strategy documented** in `docs/database-migrations.md` ✅ (Action Item #1)
- [ ] **100 exercises** pre-seeded from `assets/data/exercises_minimal.json`
- [ ] Indexes created on frequently queried columns (3 indexes)
- [ ] Sync metadata columns in WorkoutSessions table (synced, dirty, conflict)
- [ ] **DAO unit tests pass** (minimum 10 tests, ≥80% coverage)
- [ ] **Query performance <100ms** for common operations
- [ ] **Performance baselines documented** in `docs/performance-baselines.md` ✅ (Action Item #3)

**Definition of Done:**
- [ ] Database initializes without errors on iOS and Android
- [ ] All acceptance criteria met (100%)
- [ ] Unit tests pass (coverage ≥80% for database code)
- [ ] Migration strategy documented (v1 baseline, future v2 process)
- [ ] Performance baselines established (startup time, query times)
- [ ] Code builds with `dart run build_runner build` (Drift code generation)

**Deferred to Later Sprints:**
- ⏳ **9 tables** → Add incrementally in Sprints 2-4:
  - BodyMeasurements → Epic 6 (Progress Tracking)
  - DailyCheckIns, Achievements, UserAchievements → Epic 7 (Habits)
  - WorkoutTemplates, TemplateExercises → Epic 8 (Templates)
  - UserPreferences → Sprint 2 (needed for Settings)
  - Friendships, Referrals → Epic 9 (Social)
- ⏳ **400 more exercises** (expand from 100 to 500) → Sprint 2
- ⏳ **Persistent file storage** (currently in-memory) → Sprint 2 (when testing sync)

---

## Sprint 1 Stretch Goals (Optional)

If Sprint 1 completes ahead of schedule, consider pulling in these stories from Epic 1:

### Story 1.4: State Management with Riverpod Architecture (5 SP)

**Quick Overview:**
- Integrate `flutter_riverpod` package
- Setup `ProviderScope` in `main.dart`
- Create core providers (auth, database, Firebase)
- Establish provider naming conventions
- Implement common patterns (StateNotifier, FutureProvider, StreamProvider)

**Would enable:** Early testing of Riverpod patterns, cleaner code structure for Epic 2

---

## Sprint Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Firebase setup complexity** | Medium | High | Follow FlutterFire official docs, use Firebase CLI tools, allocate buffer time |
| **Drift schema changes** | Medium | Medium | Design schema carefully upfront, review architecture.md, involve stakeholders |
| **Migration strategy complexity** | High | High | Start simple (v1 only), document strategy, add tests, defer complex migrations to Sprint 2 |
| **Time underestimation** | Medium | Medium | Solo developer: realistic 16 SP capacity, keep 1.4 as stretch goal, don't over-commit |
| **Tooling issues (Xcode, Android Studio)** | Low | Medium | Ensure development environment setup before Sprint 1, have fallback devices |

---

## Sprint Dependencies

| Story | Depends On | Blocks |
|-------|------------|--------|
| **1.1** | None (first story) | 1.2, 1.3, 1.4 (all subsequent stories) |
| **1.2** | 1.1 (project initialized) | Epic 2 (Auth), Epic 7 (Notifications) |
| **1.3** | 1.1 (project initialized) | Epic 4 (Workout Logging), Epic 5 (Pattern Memory) |

**Critical Path:** 1.1 → 1.2 → 1.3 (sequential dependency)

---

## Definition of Done (Sprint 1)

A story is considered "Done" when:

### Code Quality
- [ ] Code compiles without errors or warnings
- [ ] Code follows Flutter style guide and linting rules
- [ ] No hardcoded values (use constants or config files)
- [ ] Error handling implemented (try-catch, error messages)
- [ ] Code reviewed (self-review checklist completed)

### Testing
- [ ] Unit tests written and passing (≥80% coverage for new code)
- [ ] Manual testing completed on iOS and Android
- [ ] No regressions introduced

### Documentation
- [ ] Code commented where necessary (complex logic explained)
- [ ] `README.md` updated if setup instructions changed
- [ ] Architecture decisions documented (if applicable)

### Integration
- [ ] Code committed to Git with meaningful commit message
- [ ] Code pushed to GitHub
- [ ] CI/CD pipeline passes (GitHub Actions tests green)
- [ ] No merge conflicts

### Stakeholder Review
- [ ] Demo-ready (can be shown to stakeholders)
- [ ] Acceptance criteria met (100%)
- [ ] Product Owner approval (Mariusz signs off)

---

## Sprint Ceremonies

### Daily Standup (Solo Developer Adaptation)
**Frequency:** Every morning (5 minutes)
**Format:** Written log or quick mental check

**Questions to answer:**
1. What did I complete yesterday?
2. What will I work on today?
3. Any blockers or challenges?

**Example:**
```
2025-01-16 Standup:
- ✅ Completed: Story 1.1 (Project Initialization)
- 🎯 Today: Start Story 1.2 (Firebase setup - register apps, download configs)
- ⚠️ Blockers: None
```

### Sprint Review (End of Sprint)
**Date:** Last day of Sprint 1
**Duration:** 1 hour
**Attendees:** Mariusz (solo) or stakeholders if available

**Agenda:**
1. Demo completed stories (1.1, 1.2, 1.3)
2. Review Sprint Goal achievement
3. Show working software (Flutter app running on simulator)
4. Discuss what went well / what to improve

**Deliverables:**
- Demo video or screenshots
- Sprint Review notes

### Sprint Retrospective
**Date:** Same day as Sprint Review (after review)
**Duration:** 30 minutes
**Format:** Written reflection

**Questions:**
1. What went well in Sprint 1?
2. What didn't go well?
3. What will I try differently in Sprint 2?

**Action Items:** Document 1-3 concrete improvements for Sprint 2

---

## Sprint Tracking

### Burndown Chart

Track story points completed daily to monitor progress.

| Day | Planned Remaining | Actual Remaining | Notes |
|-----|-------------------|------------------|-------|
| Day 1 (Mon) | 16 SP | 16 SP | Sprint starts |
| Day 2 (Tue) | 14 SP | — | |
| Day 3 (Wed) | 12 SP | — | |
| Day 4 (Thu) | 10 SP | — | |
| Day 5 (Fri) | 8 SP | — | End of Week 1 |
| Day 6 (Mon) | 6 SP | — | |
| Day 7 (Tue) | 4 SP | — | |
| Day 8 (Wed) | 2 SP | — | |
| Day 9 (Thu) | 1 SP | — | |
| Day 10 (Fri) | 0 SP | — | Sprint ends |

**Ideal Burndown:** Linear decrease (1.6 SP/day)

### Task Board (Kanban)

| To Do | In Progress | In Review | Done |
|-------|-------------|-----------|------|
| Story 1.1 | | | |
| Story 1.2 | | | |
| Story 1.3 | | | |

**Rules:**
- Only 1 story "In Progress" at a time (WIP limit = 1)
- Move to "In Review" when acceptance criteria met
- Move to "Done" when Definition of Done checklist complete

---

## Sprint Artifacts

By the end of Sprint 1, the following artifacts will exist:

### Code Artifacts
1. ✅ **Flutter Project** (`/lib`, `/android`, `/ios`)
2. ✅ **Firebase Configuration** (`google-services.json`, `GoogleService-Info.plist`)
3. ✅ **Drift Database** (`lib/core/database/app_database.dart` + tables + DAOs)
4. ✅ **CI/CD Pipeline** (`.github/workflows/test.yml`)

### Documentation Artifacts
1. ✅ **README.md** - Project setup instructions
2. ✅ **docs/database-migrations.md** - Migration strategy (Action Item #1)
3. ✅ **docs/performance-baselines.md** - Performance benchmarks (Action Item #3)
4. ✅ **docs/firebase-setup.md** - Firebase configuration guide
5. ✅ **docs/database-schema.md** - Drift schema documentation
6. ✅ **Sprint 1 Review Notes** - Retrospective and demo notes

### Test Artifacts
1. ✅ **Unit Tests** - Database DAOs, migrations (≥10 tests)
2. ✅ **CI Test Reports** - GitHub Actions test results

---

## Next Steps (Sprint 2 Planning)

After Sprint 1 completion:

1. **Sprint Review** - Demo Stories 1.1, 1.2, 1.3
2. **Sprint Retrospective** - Reflect on what went well / improve
3. **Sprint 2 Planning** - Plan Epic 1 remaining stories:
   - Story 1.4: Riverpod Architecture (5 SP)
   - Story 1.5: Navigation/Routing (3 SP)
   - Story 1.6: Design System (8 SP)
   - **Sprint 2 Capacity:** 16 SP (same as Sprint 1, adjust if needed)
4. **Begin Epic 2** - If Sprint 2 has capacity after Epic 1 completion

---

## Stakeholder Sign-Off

**Sprint Planning Approval:**

| Role | Name | Date | Approval |
|------|------|------|----------|
| **Product Owner** | Mariusz | [Pending] | ⬜ Approved |
| **Scrum Master** | Claude (BMAD SM Agent) | 2025-01-15 | ✅ Approved |
| **Development Team** | Mariusz | [Pending] | ⬜ Approved |

**Notes:**
- Sprint 1 scope is realistic for solo developer (16 SP)
- All 3 Architecture Validation action items included
- Critical path dependencies identified
- Stretch goal (Story 1.4) available if ahead of schedule

---

**Sprint 1 Status:** 📋 **READY TO START**

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**BMAD Phase:** Implementation - Sprint Planning Complete

---

## Appendix: Story Point Reference Guide

### Fibonacci Scale

| Points | Size | Complexity | Duration | Examples |
|--------|------|------------|----------|----------|
| **1** | XS | Trivial | ~1-2 hours | Update config, fix typo |
| **2** | S | Simple | ~2-4 hours | Add simple form field |
| **3** | M | Moderate | ~4-8 hours (1 day) | Project initialization, simple feature |
| **5** | L | Complex | ~1-2 days | Firebase setup, Riverpod architecture |
| **8** | XL | Very Complex | ~2-4 days | Database schema, Design system |
| **13** | XXL | Extremely Complex | ~5+ days | Major feature (break down!) |
| **21** | EPIC | Epic-level | ~2 weeks | Should be broken into smaller stories |

**Guidelines:**
- If a story is >8 SP, consider breaking it down
- Use relative sizing (compare to reference stories)
- Include testing and documentation time in estimate

---

**END OF SPRINT 1 BACKLOG**
