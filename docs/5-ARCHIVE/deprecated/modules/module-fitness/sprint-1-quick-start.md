# Sprint 1 Quick Start Guide

**Purpose:** Get started with Sprint 1 in 30 minutes or less!

**Sprint Goal:** Establish technical foundation for GymApp (Flutter + Firebase + Drift)
**Scope:** SIMPLIFIED (11 SP) - 3 stories, 2 weeks
**Ready to Start:** ✅ YES - All planning complete

---

## 🚀 **Pre-Sprint Checklist (Before Day 1)**

### Development Environment Setup

**1. Install Flutter 3.16+**
```bash
# Check Flutter version
flutter --version  # Should be 3.16.0 or higher

# If not installed:
# Download from https://flutter.dev/docs/get-started/install
# Follow platform-specific instructions (Windows/Mac/Linux)
```

**2. Install Firebase CLI**
```bash
# Install Node.js first (required for Firebase CLI)
# Download from: https://nodejs.org/

# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version
```

**3. Install FlutterFire CLI**
```bash
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

**4. Setup IDE (Choose one)**

**VS Code (Recommended for Flutter):**
- Install VS Code: https://code.visualstudio.com/
- Install extensions:
  - Flutter (Dart-Code.flutter)
  - Dart (Dart-Code.dart-code)
  - GitLens (eamodio.gitlens)

**Android Studio:**
- Install Android Studio: https://developer.android.com/studio
- Install plugins: Flutter, Dart

**5. Setup Simulators/Emulators**

**iOS Simulator (Mac only):**
```bash
# Open Xcode, install iOS 14+ simulator
open -a Simulator

# List available simulators
xcrun simctl list devices
```

**Android Emulator:**
```bash
# Open Android Studio > Device Manager
# Create emulator: Pixel 7, Android 10 (API 29) or higher
```

**6. Create Firebase Account**
- Go to https://firebase.google.com/
- Sign in with Google account
- No billing required (using Spark free plan)

**7. Create GitHub Account + Repository**
- Sign up: https://github.com/
- Create new repository: "GymApp" (private)
- Don't initialize with README (we'll create it in Story 1.1)

---

## 📋 **Sprint 1 Roadmap (Day-by-Day)**

### Week 1

| Day | Story | Tasks | Hours | Status |
|-----|-------|-------|-------|--------|
| **Mon** | 1.1 | Flutter project init, Git setup, directory structure | 4 hours | ⬜ |
| **Tue** | 1.1 | Environment config, CI/CD, README | 2 hours | ⬜ |
| **Tue** | 1.2 | Firebase project creation, FlutterFire CLI setup | 2 hours | ⬜ |
| **Wed** | 1.2 | Enable Firebase services, simple security rules | 4 hours | ⬜ |
| **Thu** | 1.3 | Drift dependencies, define 5 tables | 4 hours | ⬜ |
| **Fri** | 1.3 | Implement 3 DAOs, AppDatabase class | 4 hours | ⬜ |

### Week 2

| Day | Story | Tasks | Hours | Status |
|-----|-------|-------|-------|--------|
| **Mon** | 1.3 | Migration strategy doc, create exercises JSON (100) | 4 hours | ⬜ |
| **Tue** | 1.3 | Pre-seed exercises, database indexes | 3 hours | ⬜ |
| **Wed** | 1.3 | Write DAO unit tests (≥10 tests) | 4 hours | ⬜ |
| **Thu** | 1.3 | Performance baselines, final testing | 3 hours | ⬜ |
| **Fri** | **SPRINT REVIEW** | Demo, retrospective, Sprint 2 planning | 2 hours | ⬜ |

**Total:** 40 hours over 10 days (4 hours/day average)

---

## 🎯 **Story 1.1: Project Initialization (2 SP) - Day 1-2**

### Task Checklist

**Day 1 (4 hours):**

- [ ] **1.1.1** Initialize Flutter project
  ```bash
  flutter create gymapp
  cd gymapp
  flutter run  # Verify it works
  ```

- [ ] **1.1.2** Configure iOS minimum version
  - Open `ios/Podfile`
  - Change: `platform :ios, '14.0'` (find and replace '11.0' with '14.0')

- [ ] **1.1.3** Configure Android minimum SDK
  - Open `android/app/build.gradle`
  - Find `minSdkVersion` and change to `29` (Android 10)

- [ ] **1.1.4** Initialize Git repository
  ```bash
  git init
  git add .
  git commit -m "Initial commit: Flutter project setup"
  ```

- [ ] **1.1.5** Create GitHub repository and push
  ```bash
  git remote add origin https://github.com/YOUR_USERNAME/GymApp.git
  git branch -M main
  git push -u origin main
  ```

- [ ] **1.1.6** Create directory structure
  ```bash
  mkdir -p lib/core/{providers,services,theme,database,config}
  mkdir -p lib/features/{auth,workout,exercise,progress,templates,social,habits,settings}
  mkdir -p lib/shared/widgets
  ```

**Day 2 (2 hours):**

- [ ] **1.1.7** Create simple environment config
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

      static String get appName {
        if (isDev) return 'GymApp (Dev)';
        if (isStaging) return 'GymApp (Staging)';
        return 'GymApp';
      }
    }
    ```

- [ ] **1.1.8** Create GitHub Actions CI/CD
  - Create `.github/workflows/test.yml`:
    ```yaml
    name: Flutter CI

    on: [push, pull_request]

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - uses: subosito/flutter-action@v2
            with:
              flutter-version: '3.16.0'
              channel: 'stable'
          - run: flutter pub get
          - run: flutter analyze
          - run: flutter test
    ```

- [ ] **1.1.9** Update README.md
  ```markdown
  # GymApp

  AI-powered fitness tracker with Smart Pattern Memory

  ## Setup

  1. Install Flutter 3.16+
  2. Run `flutter pub get`
  3. Run `flutter run --dart-define=ENVIRONMENT=dev`

  ## Project Structure

  - `/lib/core` - Core utilities, providers, database
  - `/lib/features` - Feature modules (auth, workout, etc.)
  - `/lib/shared` - Shared widgets

  ## Sprint Status

  - Sprint 1: Foundation & Infrastructure (IN PROGRESS)
  ```

- [ ] **1.1.10** Commit and push
  ```bash
  git add .
  git commit -m "Setup project structure, environment config, CI/CD"
  git push
  ```

**Story 1.1 Done!** ✅ Check GitHub Actions to see if CI passes.

---

## 🔥 **Story 1.2: Firebase Setup (4 SP) - Day 2-3**

### Prerequisites

- [ ] Firebase account created
- [ ] Firebase CLI installed (`firebase --version`)
- [ ] FlutterFire CLI installed (`flutterfire --version`)

### Task Checklist

**Day 2 Evening (2 hours):**

- [ ] **1.2.1** Login to Firebase CLI
  ```bash
  firebase login
  ```

- [ ] **1.2.2** Create Firebase project in console
  - Go to https://console.firebase.google.com/
  - Click "Add project"
  - Project name: "GymApp-Dev"
  - Enable Google Analytics: YES
  - Choose billing plan: **Spark (FREE)** ✅

- [ ] **1.2.3** Use FlutterFire CLI to configure
  ```bash
  flutterfire configure --project=gymapp-dev
  ```
  - This automatically:
    - Registers iOS app (`com.gymapp.ios`)
    - Registers Android app (`com.gymapp.android`)
    - Downloads config files
    - Generates `lib/firebase_options.dart`

**Day 3 (4 hours):**

- [ ] **1.2.4** Add Firebase dependencies to `pubspec.yaml`
  ```yaml
  dependencies:
    firebase_core: ^2.24.0
    firebase_auth: ^4.15.0
    cloud_firestore: ^4.13.0
    firebase_storage: ^11.5.0
    firebase_crashlytics: ^3.4.0
    firebase_analytics: ^10.7.0
  ```

- [ ] **1.2.5** Run `flutter pub get`

- [ ] **1.2.6** Initialize Firebase in `lib/main.dart`
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

- [ ] **1.2.7** Enable Firebase services in Firebase Console:
  - **Authentication:** Enable Email/Password
  - **Firestore:** Enable in Test mode (we'll add rules next)
  - **Storage:** Enable with default bucket
  - **Crashlytics:** Enable
  - **Analytics:** Auto-enabled

- [ ] **1.2.8** Create simple Firestore security rules
  - Create `firestore.rules` in project root:
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

- [ ] **1.2.9** Create simple Storage security rules
  - Create `storage.rules` in project root:
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

- [ ] **1.2.10** Deploy security rules
  ```bash
  firebase deploy --only firestore:rules,storage:rules
  ```

- [ ] **1.2.11** Test Firebase connection
  ```bash
  flutter run
  ```
  - Check console for "Firebase initialization successful" (no errors)
  - Check Firebase Console > Authentication for "Last app connection" timestamp

- [ ] **1.2.12** Commit and push
  ```bash
  git add .
  git commit -m "Configure Firebase with FlutterFire CLI, deploy security rules"
  git push
  ```

**Story 1.2 Done!** ✅ Firebase is operational!

---

## 💾 **Story 1.3: Drift Database (5 SP) - Day 4-9**

### Task Checklist

**Day 4 (4 hours) - Dependencies & Schema:**

- [ ] **1.3.1** Add Drift dependencies to `pubspec.yaml`
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

- [ ] **1.3.2** Run `flutter pub get`

- [ ] **1.3.3** Create Drift table definitions
  - Create `lib/core/database/tables/users.dart` (copy from sprint-1-backlog.md)
  - Create `lib/core/database/tables/exercises.dart`
  - Create `lib/core/database/tables/workout_sessions.dart`
  - Create `lib/core/database/tables/workout_exercises.dart`
  - Create `lib/core/database/tables/workout_sets.dart`

**Day 5 (4 hours) - DAOs & AppDatabase:**

- [ ] **1.3.4** Create DAOs
  - Create `lib/core/database/daos/users_dao.dart`
  - Create `lib/core/database/daos/workout_sessions_dao.dart`
  - Create `lib/core/database/daos/exercises_dao.dart`

- [ ] **1.3.5** Create AppDatabase class
  - Create `lib/core/database/app_database.dart`
  - Configure with 5 tables and 3 DAOs
  - Use in-memory database for Sprint 1

- [ ] **1.3.6** Run code generation
  ```bash
  dart run build_runner build
  ```
  - This generates `app_database.g.dart`
  - Fix any errors shown

**Day 6 (4 hours) - Migration Strategy & Exercises:**

- [ ] **1.3.7** Create migration strategy document
  - Create `docs/database-migrations.md`
  - Document v1 schema (5 tables)
  - Document future migration process (v1 → v2)
  - Document rollback strategy
  - **ACTION ITEM #1 COMPLETE** ✅

- [ ] **1.3.8** Create exercise library JSON
  - Create `assets/data/exercises_minimal.json`
  - Add 100 common exercises (10 per category)
  - Categories: Chest (10), Back (10), Legs (15), Shoulders (10), Arms (10), Core (10), Cardio (5), Functional (10), Mobility (5), Other (15)

**Day 7 (3 hours) - Seeding & Indexes:**

- [ ] **1.3.9** Implement exercise seeding logic
  - Create `lib/core/database/seed_data.dart`
  - Load JSON from assets
  - Insert into Exercises table on first launch

- [ ] **1.3.10** Add database indexes
  - Update `AppDatabase.migration.onCreate` with 3 indexes
  - Test index creation

**Day 8 (4 hours) - Unit Tests:**

- [ ] **1.3.11** Write DAO unit tests
  - Create `test/core/database/daos/workout_sessions_dao_test.dart`
  - Create `test/core/database/daos/exercises_dao_test.dart`
  - Create `test/core/database/daos/users_dao_test.dart`
  - Write ≥10 tests total
  - Target: ≥80% coverage for database code

- [ ] **1.3.12** Run tests
  ```bash
  flutter test
  ```
  - Verify all tests pass

**Day 9 (3 hours) - Performance Baselines & Final:**

- [ ] **1.3.13** Establish performance baselines
  - Measure app startup time (target: <2s)
  - Measure database query times (target: <100ms)
  - Create `docs/performance-baselines.md`
  - Document baseline metrics
  - **ACTION ITEM #3 COMPLETE** ✅

- [ ] **1.3.14** Final testing
  - Run app on iOS simulator
  - Run app on Android emulator
  - Verify database initializes
  - Verify exercises are seeded
  - Check no errors in console

- [ ] **1.3.15** Commit and push
  ```bash
  git add .
  git commit -m "Implement Drift database with 5 tables, 100 exercises, unit tests, baselines"
  git push
  ```

**Story 1.3 Done!** ✅ Database foundation complete!

---

## 📊 **Sprint Review & Retrospective (Day 10)**

### Sprint Review (1 hour)

**Prepare Demo:**
- [ ] Record screen recording or prepare live demo
- [ ] Show Flutter app running on iOS and Android
- [ ] Show database initialization and exercise seeding
- [ ] Show CI/CD pipeline (GitHub Actions passing)
- [ ] Review completed stories (1.1, 1.2, 1.3)

**Demo Script:**
1. "This is the GymApp project initialized with Flutter 3.16+"
2. "Here's the directory structure (show `/lib/core`, `/lib/features`)"
3. "Firebase is configured and operational (show Firebase Console)"
4. "Database has 5 tables and 100 exercises seeded (show database inspector)"
5. "All tests passing (show GitHub Actions green checkmark)"

### Sprint Retrospective (1 hour)

**Reflect on Sprint 1:**

- [ ] **What went well?**
  - What was easier than expected?
  - What tools/processes helped?
  - What knowledge did you gain?

- [ ] **What didn't go well?**
  - What took longer than expected?
  - What blockers did you hit?
  - What would you change?

- [ ] **Action items for Sprint 2:**
  - List 1-3 concrete improvements
  - Example: "Allocate more time for Drift code generation errors"

**Document Retrospective:**
- Create `docs/sprint-1-retrospective.md`
- Save for future reference

---

## 🎯 **Sprint 1 Success Checklist**

At the end of Sprint 1, verify:

**Code Deliverables:**
- [ ] Flutter project builds on iOS and Android ✅
- [ ] Firebase SDK initialized, all services operational ✅
- [ ] Drift database with 5 tables ✅
- [ ] 100 exercises pre-seeded ✅
- [ ] 3 DAOs implemented ✅
- [ ] CI/CD pipeline (GitHub Actions) passing ✅

**Documentation Deliverables:**
- [ ] `README.md` with setup instructions ✅
- [ ] `docs/database-migrations.md` (Action Item #1) ✅
- [ ] `docs/performance-baselines.md` (Action Item #3) ✅
- [ ] `docs/sprint-1-retrospective.md` ✅

**Test Deliverables:**
- [ ] ≥10 unit tests for DAOs ✅
- [ ] Test coverage ≥80% for database code ✅
- [ ] All tests passing in CI/CD ✅

**If ALL checkboxes are checked:** **Sprint 1 COMPLETE!** 🎉

---

## 🚀 **Next Steps: Sprint 2 Preview**

After Sprint 1, you'll be ready to start Sprint 2 with:
- Story 1.4: Riverpod Architecture (5 SP)
- Story 1.5: Navigation/Routing (3 SP)
- Story 1.6: Design System (8 SP)

**Or begin Epic 2: Authentication!**

---

## 🆘 **Troubleshooting Common Issues**

### Issue: FlutterFire CLI not found
```bash
# Fix: Add Dart global bin to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"  # Mac/Linux
# Windows: Add C:\Users\<USERNAME>\AppData\Local\Pub\Cache\bin to PATH
```

### Issue: Drift code generation fails
```bash
# Fix: Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Firebase initialization error
```bash
# Fix: Verify firebase_options.dart exists
ls lib/firebase_options.dart

# If missing, re-run FlutterFire CLI
flutterfire configure --project=gymapp-dev
```

### Issue: iOS Simulator not showing
```bash
# Fix: Open Xcode, install simulator
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
open -a Simulator
```

---

**Ready to Start?** 🚀

**Command to run today:**
```bash
flutter create gymapp
cd gymapp
flutter run  # Verify it works!
```

**Good luck with Sprint 1!** 💪

---

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**Status:** READY TO START
