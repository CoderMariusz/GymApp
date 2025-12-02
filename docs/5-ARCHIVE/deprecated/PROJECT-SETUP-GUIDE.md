# LifeOS - Project Setup Guide

**Version:** 1.0
**Last Updated:** 2025-11-17
**Author:** Bob (BMAD Scrum Master)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Flutter Project Initialization](#flutter-project-initialization)
4. [Supabase Setup](#supabase-setup)
5. [Project Dependencies](#project-dependencies)
6. [Architecture Overview](#architecture-overview)
7. [Running the Project](#running-the-project)
8. [Testing](#testing)
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Tools

- **Flutter SDK**: 3.38+ (Dart 3.10+)
  - Download: https://flutter.dev/docs/get-started/install
  - Verify: `flutter --version`

- **Android Studio** (for Android development)
  - Download: https://developer.android.com/studio
  - Install Android SDK 33+ and Android NDK

- **Xcode** (for iOS development, macOS only)
  - Download: https://developer.apple.com/xcode/
  - Xcode 14.0+ required

- **Git**: Version control
  - Download: https://git-scm.com/downloads
  - Verify: `git --version`

- **Node.js**: 18+ (for Supabase Edge Functions)
  - Download: https://nodejs.org/
  - Verify: `node --version`

- **Supabase CLI**: For local development
  - Install: `npm install -g supabase`
  - Verify: `supabase --version`

### Optional Tools

- **VS Code** (recommended IDE)
  - Download: https://code.visualstudio.com/
  - Extensions:
    - Flutter (by Dart Code)
    - Dart (by Dart Code)
    - Riverpod Snippets
    - Error Lens

- **Android Emulator** or **iOS Simulator**
  - Android: Set up via Android Studio AVD Manager
  - iOS: Included with Xcode

- **Docker** (for local Supabase development)
  - Download: https://www.docker.com/products/docker-desktop

---

## Development Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/CoderMariusz/GymApp.git
cd GymApp
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all checkmarks are green. If not, follow the instructions provided.

### 3. Configure Flutter

```bash
# Enable web support (optional, for web development)
flutter config --enable-web

# Set up Android licenses (if needed)
flutter doctor --android-licenses
```

---

## Flutter Project Initialization

### 1. Create Flutter Project

Since this is a **greenfield project**, you'll need to initialize the Flutter project structure:

```bash
# Create Flutter app
flutter create lifeos_app --org com.lifeos --platforms android,ios

# Navigate to project directory
cd lifeos_app
```

### 2. Update `pubspec.yaml`

Replace the contents of `pubspec.yaml` with the following dependencies:

```yaml
name: lifeos_app
description: LifeOS - Your Life Operating System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.10.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Supabase & Backend
  supabase_flutter: ^2.3.0

  # Offline-First Database
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.18

  # Routing & Navigation
  go_router: ^13.0.0

  # UI & Design
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  fl_chart: ^0.66.0
  shimmer: ^3.0.0

  # Images & Media
  image: ^4.1.3
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0

  # Audio (Meditations)
  just_audio: ^0.9.36
  audio_session: ^0.1.16

  # Notifications
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.2.0

  # Utilities
  intl: ^0.19.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.2
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  path_provider: ^2.1.1

  # Encryption (for E2EE journals)
  encrypt: ^5.0.3

  # In-App Purchases
  in_app_purchase: ^3.1.11

  # Firebase Core
  firebase_core: ^2.24.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

  # Code Generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  drift_dev: ^2.14.0

  # Testing
  mocktail: ^1.0.2
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/lottie/
    - assets/audio/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### 3. Install Dependencies

```bash
flutter pub get
```

---

## Supabase Setup

### 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click **New Project**
3. Project Settings:
   - **Name**: LifeOS
   - **Database Password**: (Strong password, save it securely)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier (upgrade later as needed)
4. Click **Create new project**

### 2. Configure Supabase Locally

Create `.env` file in the project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-role-key-here

# Firebase Configuration (for FCM)
FIREBASE_PROJECT_ID=your-firebase-project-id
```

**Note**: Replace placeholders with actual values from Supabase Dashboard → Settings → API

### 3. Initialize Supabase in Flutter

Create `lib/core/supabase/supabase_config.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}

// Global Supabase client
final supabase = Supabase.instance.client;
```

### 4. Database Schema Setup

Run the SQL migrations from `docs/sprint-artifacts/database-schema.sql` in your Supabase SQL Editor:

1. Go to Supabase Dashboard → SQL Editor
2. Create a new query
3. Copy contents of `database-schema.sql`
4. Execute the query

**Key Tables**:
- `user_profiles` (Epic 1)
- `goals`, `check_ins`, `daily_plans` (Epic 2)
- `workouts`, `workout_sets`, `exercises` (Epic 3)
- `meditations`, `mood_logs`, `journal_entries` (Epic 4)
- `insights`, `streaks`, `badges` (Epic 5 & 6)
- `notification_settings`, `user_settings` (Epic 8 & 9)

### 5. Row Level Security (RLS)

Enable RLS on all tables:

```sql
-- Example for user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);
```

**Note**: RLS policies should be applied to ALL tables as specified in each story's context XML.

### 6. Supabase Storage Buckets

Create the following storage buckets:

1. **user-avatars** (public)
   - Used for: User profile avatars (Story 1.4, 9.1)
   - Max file size: 5MB
   - Allowed formats: JPG, PNG

2. **body-measurement-photos** (private)
   - Used for: E2EE body measurement photos (Story 3.6)
   - Max file size: 10MB
   - Allowed formats: JPG, PNG

3. **meditation-audio** (public)
   - Used for: Meditation audio files (Story 4.1)
   - Max file size: 50MB
   - Allowed formats: MP3, M4A

### 7. Supabase Edge Functions

Edge Functions are used for:
- Daily insights generation (Epic 5)
- Weekly report generation (Epic 6)
- Push notifications (Epic 8)

**Setup**:

```bash
# Initialize Supabase locally
supabase init

# Create Edge Function
supabase functions new detect-patterns

# Deploy Edge Function
supabase functions deploy detect-patterns --project-ref your-project-ref
```

**Cron Jobs** (pg_cron):

```sql
-- Daily insights (6am)
SELECT cron.schedule(
  'detect-patterns',
  '0 6 * * *',
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/detect-patterns',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);

-- Weekly reports (Monday 6am)
SELECT cron.schedule(
  'generate-weekly-reports',
  '0 6 * * 1',
  $$SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/generate-weekly-reports',
    headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_KEY')
  )$$
);
```

---

## Project Dependencies

### Core Dependencies Explained

1. **flutter_riverpod**: State management (Riverpod architecture)
2. **supabase_flutter**: Backend as a Service (authentication, database, storage)
3. **drift**: Offline-first local SQLite database
4. **go_router**: Declarative routing and navigation
5. **firebase_messaging**: Push notifications (FCM)
6. **just_audio**: Audio playback for meditations
7. **fl_chart**: Charts for progress visualization
8. **lottie**: Celebration animations
9. **encrypt**: E2EE for journals and sensitive data
10. **in_app_purchase**: Subscription management

### Generate Code

Run code generation for Riverpod, Freezed, and Drift:

```bash
# Generate once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file changes)
flutter pub run build_runner watch
```

---

## Architecture Overview

### Hybrid Architecture (D1)

LifeOS uses a **feature-first** structure with **clean architecture**:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── supabase/
│   ├── router/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/               # Epic 1: User Authentication
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── life_coach/         # Epic 2: Life Coach MVP
│   ├── fitness/            # Epic 3: Fitness Coach MVP
│   ├── mind/               # Epic 4: Mind & Emotion MVP
│   ├── insights/           # Epic 5: Cross-Module Intelligence
│   ├── gamification/       # Epic 6: Gamification & Retention
│   ├── onboarding/         # Epic 7: Onboarding & Subscriptions
│   ├── notifications/      # Epic 8: Notifications & Engagement
│   └── settings/           # Epic 9: Settings & Profile
└── shared/
    ├── widgets/
    ├── models/
    └── services/
```

### Clean Architecture Layers

Each feature follows this structure:

```
feature/
├── domain/
│   ├── entities/          # Business objects
│   ├── repositories/      # Repository interfaces
│   └── use_cases/         # Business logic
├── data/
│   ├── models/            # Data models (DTOs)
│   ├── repositories/      # Repository implementations
│   └── data_sources/      # API, Database, etc.
└── presentation/
    ├── screens/           # UI screens
    ├── widgets/           # Feature-specific widgets
    └── providers/         # Riverpod providers
```

### Offline-First (D3)

**Hybrid Sync Strategy**:
- **Drift (SQLite)**: Local database for offline access
- **Supabase**: Cloud database for sync
- **Sync Logic**: Last-write-wins, <5s latency
- **Conflict Resolution**: Automatic with timestamp-based resolution

**Example**:

```dart
// Drift local database
@DriftDatabase(tables: [Workouts, WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Sync service
class SyncService {
  Future<void> syncWorkouts() async {
    final localWorkouts = await database.getAllWorkouts();
    final remoteWorkouts = await supabase.from('workouts').select();

    // Merge and resolve conflicts
    // Upload local changes to Supabase
    // Download remote changes to Drift
  }
}
```

---

## Running the Project

### 1. Configure Firebase (for FCM)

1. Create Firebase project: https://console.firebase.google.com/
2. Add Android app: `com.lifeos.lifeos_app`
3. Add iOS app: `com.lifeos.lifeosApp`
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. Place files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 2. Run the App

```bash
# Run on Android
flutter run --flavor dev --target lib/main_dev.dart

# Run on iOS
flutter run --flavor dev --target lib/main_dev.dart -d iPhone

# Run on Web (optional)
flutter run -d chrome
```

### 3. Hot Reload

Press `r` in the terminal to hot reload, or `R` for hot restart.

---

## Testing

### Unit Tests

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests

```bash
# Run widget tests
flutter test test/features/life_coach/presentation/
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/
```

### Test Coverage Target

- **Unit Tests**: 70% of codebase
- **Widget Tests**: 20% of codebase
- **Integration Tests**: 10% of codebase
- **Overall Target**: 75-85% coverage

---

## CI/CD Pipeline

### GitHub Actions Setup

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

      - name: Build APK
        run: flutter build apk --release

      - name: Build iOS (on macOS)
        if: runner.os == 'macOS'
        run: flutter build ios --release --no-codesign
```

### Pre-commit Hooks (Optional)

Install `pre-commit` package:

```bash
pip install pre-commit
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-test
        name: Flutter Test
        entry: flutter test
        language: system
        pass_filenames: false

      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
```

Activate:

```bash
pre-commit install
```

---

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

**Problem**: Flutter doctor shows errors

**Solution**:
```bash
# Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade

# Clear cache
flutter clean
```

#### 2. Supabase Connection Errors

**Problem**: Cannot connect to Supabase

**Solution**:
- Verify `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Check internet connection
- Verify project is not paused in Supabase Dashboard

#### 3. Build Failures

**Problem**: Build fails with dependency errors

**Solution**:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 4. iOS Build Issues

**Problem**: iOS build fails with signing errors

**Solution**:
- Open `ios/Runner.xcworkspace` in Xcode
- Go to Signing & Capabilities
- Select your development team
- Enable automatic signing

#### 5. Android Emulator Not Detected

**Problem**: `flutter devices` shows no Android devices

**Solution**:
- Open Android Studio → AVD Manager
- Create a new virtual device
- Start the emulator
- Run `flutter devices` again

---

## Next Steps

1. **Start with Epic 1**: Implement user authentication (Story 1.1 - 1.6)
2. **Follow Story Context XMLs**: Each story has a comprehensive context XML with:
   - Implementation tasks (7-10 tasks with 40-50 subtasks)
   - Acceptance criteria (5-12 criteria)
   - Constraints (architectural, security, UX, performance, testing)
   - Interface definitions (entities, use cases, repositories, DB schemas)
   - Test ideas (12-20 test scenarios)
3. **Use BMAD Workflow**: Follow the BMAD methodology for sprint planning and execution
4. **Test Coverage**: Maintain 75-85% test coverage throughout development
5. **Code Reviews**: All PRs should be reviewed before merging

---

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Supabase Docs**: https://supabase.com/docs
- **Drift Docs**: https://drift.simonbinder.eu/
- **Firebase Docs**: https://firebase.google.com/docs

---

## Support

For questions or issues:
- **GitHub Issues**: https://github.com/CoderMariusz/GymApp/issues
- **Scrum Master**: Bob (BMAD)
- **Project Manager**: Alice (BMAD)

---

**Last Updated**: 2025-11-17
**Project Status**: All 66 stories ready for dev (Epic 1-9 complete)
