# GymApp - Technical Architecture Document

**Version**: 1.0
**Date**: 2025-01-15
**Project**: GymApp - AI-Powered Fitness Tracker
**Phase**: Solutioning (BMAD Workflow)

---

## Table of Contents

1. [System Architecture Overview](#1-system-architecture-overview)
2. [Technology Stack](#2-technology-stack)
3. [Database Schema](#3-database-schema)
4. [State Management Architecture](#4-state-management-architecture)
5. [Offline-First Sync Strategy](#5-offline-first-sync-strategy)
6. [Security Architecture](#6-security-architecture)
7. [API Contracts](#7-api-contracts)
8. [Project Structure](#8-project-structure)
9. [Performance Optimization](#9-performance-optimization)
10. [Scalability Considerations](#10-scalability-considerations)

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GymApp Mobile App                         │
│                     (Flutter 3.16+ / Dart)                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Presentation │  │  Application │  │     Domain   │          │
│  │    Layer     │  │     Layer    │  │     Layer    │          │
│  │   (Widgets)  │  │  (Providers) │  │   (Models)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐          │
│  │              Data Layer (Repositories)            │          │
│  └──────────────────────────────────────────────────┘          │
│         ▲                              ▲                        │
│         │                              │                        │
│  ┌──────┴─────┐               ┌───────┴────────┐              │
│  │   Drift    │               │   Firestore    │              │
│  │ (SQLite)   │◄─────sync────►│   (Cloud DB)   │              │
│  │  Local DB  │               │   Remote DB    │              │
│  └────────────┘               └────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                                  ▲
                                  │
                    ┌─────────────┴──────────────┐
                    │   Firebase Services        │
                    ├────────────────────────────┤
                    │ - Authentication           │
                    │ - Cloud Functions          │
                    │ - Cloud Storage (Photos)   │
                    │ - Cloud Messaging (FCM)    │
                    │ - Analytics                │
                    │ - Crashlytics              │
                    └────────────────────────────┘
```

### 1.2 Architecture Principles

1. **Offline-First**: All core features work without internet connection
2. **Clean Architecture**: Separation of concerns (Presentation → Application → Domain → Data)
3. **Feature-Based Structure**: Organize code by features, not layers
4. **Single Source of Truth**: Drift (local DB) is the source of truth, Firestore is backup/sync
5. **Reactive State Management**: Riverpod providers for reactive UI updates
6. **GDPR by Design**: Privacy and data protection built into every layer

### 1.3 Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Mobile Framework** | Flutter 3.16+ | Cross-platform (iOS + Android), native performance, rich widget library |
| **State Management** | Riverpod 2.x | Type-safe, compile-time safety, better than Provider/Bloc for complex state |
| **Local Database** | Drift (SQLite) | Offline-first, type-safe SQL, reactive queries, migration support |
| **Cloud Database** | Firestore | Real-time sync, NoSQL flexibility, auto-scaling, offline support |
| **Backend** | Firebase Suite | Serverless, managed services, reduces DevOps overhead |
| **Authentication** | Firebase Auth | Multi-provider (Email, Google, Apple), secure, GDPR compliant |

---

## 2. Technology Stack

### 2.1 Core Technologies

**Frontend**
- **Flutter SDK**: 3.16+ (stable channel)
- **Dart**: 3.2+
- **Target Platforms**: iOS 14+, Android 10+ (API 29+)

**Backend & Services**
- **Firebase Authentication**: User management, OAuth providers
- **Cloud Firestore**: Cloud database, real-time sync
- **Firebase Cloud Functions**: Serverless backend logic (Node.js 18)
- **Firebase Cloud Storage**: Photo uploads (progress photos)
- **Firebase Cloud Messaging (FCM)**: Push notifications
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Error reporting

**Local Storage**
- **Drift**: 2.x (formerly Moor) - Type-safe SQLite wrapper
- **Shared Preferences**: Simple key-value storage for settings
- **Secure Storage**: flutter_secure_storage for sensitive tokens

### 2.2 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Local Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0

  # Navigation
  go_router: ^13.0.0

  # Charts
  fl_chart: ^0.66.0

  # Image Handling
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0

  # Utilities
  intl: ^0.18.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Health Integrations
  health: ^10.0.0  # Apple Health + Google Fit

  # Networking
  http: ^1.1.0
  connectivity_plus: ^5.0.0

  # Notifications
  flutter_local_notifications: ^16.3.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.7
  drift_dev: ^2.14.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

---

## 3. Database Schema

### 3.1 Drift (Local SQLite) Schema

Drift is our **source of truth**. All data is first written to Drift, then synced to Firestore.

#### 3.1.1 Users Table

```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text().unique()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // GDPR
  BoolColumn get consentGiven => boolean().withDefault(const Constant(false))();
  DateTimeColumn get consentDate => dateTime().nullable()();
}
```

#### 3.1.2 Workout Sessions Table

```dart
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text()();  // User ID
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()();  // 'in_progress', 'completed', 'abandoned'
  TextColumn get notes => text().nullable()();

  // Sync metadata
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get conflict => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get firestoreId => text().nullable()();  // Firestore document ID
}
```

#### 3.1.3 Exercises Table

```dart
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()();  // 'chest', 'back', 'legs', etc.
  TextColumn get equipment => text()();  // 'barbell', 'dumbbell', 'bodyweight', etc.
  TextColumn get muscleGroup => text()();  // Primary muscle
  TextColumn get secondaryMuscles => text().nullable()();  // JSON array
  TextColumn get instructions => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();  // User-created
  TextColumn get createdBy => text().nullable()();  // Firebase UID if custom
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 3.1.4 Workout Exercises Table

```dart
class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutSessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();  // Order in workout
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 3.1.5 Workout Sets Table

```dart
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutExerciseId => integer().references(WorkoutExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get setNumber => integer()();  // 1, 2, 3, etc.
  IntColumn get reps => integer()();
  RealColumn get weight => real().nullable()();  // Nullable for bodyweight exercises
  TextColumn get unit => text().withDefault(const Constant('kg'))();  // 'kg' or 'lbs'
  IntColumn get perceivedEffort => integer().nullable()();  // RPE 1-10
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}
```

#### 3.1.6 Body Measurements Table

```dart
class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();
  TextColumn get unit => text().withDefault(const Constant('kg'))();
  RealColumn get bodyFatPercent => real().nullable()();
  TextColumn get photoUrls => text().nullable()();  // JSON array of Firebase Storage URLs
  TextColumn get notes => text().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get firestoreId => text().nullable()();
}
```

#### 3.1.7 Daily Check-Ins Table

```dart
class DailyCheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mood => integer()();  // 1-5: sore/tired/okay/good/great
  TextColumn get notes => text().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get firestoreId => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {firebaseUid, date}  // One check-in per user per day
  ];
}
```

#### 3.1.8 Workout Templates Table

```dart
class WorkoutTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsed => dateTime().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get firestoreId => text().nullable()();
}
```

#### 3.1.9 Template Exercises Table

```dart
class TemplateExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(WorkoutTemplates, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  IntColumn get suggestedSets => integer().nullable()();
  IntColumn get suggestedReps => integer().nullable()();
  TextColumn get notes => text().nullable()();
}
```

#### 3.1.10 Achievements Table

```dart
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();  // 'workout_count', 'streak', 'volume', 'social'
  TextColumn get tier => text()();  // 'bronze', 'silver', 'gold', 'platinum'
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get requirement => integer()();  // Numeric threshold
  TextColumn get iconUrl => text().nullable()();
}
```

#### 3.1.11 User Achievements Table

```dart
class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text()();
  IntColumn get achievementId => integer().references(Achievements, #id)();
  DateTimeColumn get unlockedAt => dateTime()();
  IntColumn get progress => integer().withDefault(const Constant(0))();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get firestoreId => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {firebaseUid, achievementId}
  ];
}
```

#### 3.1.12 User Preferences Table

```dart
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text().unique()();

  // Units
  TextColumn get weightUnit => text().withDefault(const Constant('kg'))();  // 'kg' or 'lbs'

  // Notifications
  BoolColumn get workoutReminderEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get workoutReminderTime => text().nullable()();  // HH:mm format
  TextColumn get workoutReminderDays => text().nullable()();  // JSON array [1,3,5] = Mon/Wed/Fri
  BoolColumn get checkinReminderEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get checkinReminderTime => text().nullable()();
  BoolColumn get weeklyReportEnabled => boolean().withDefault(const Constant(true))();

  // Features
  BoolColumn get showDailyQuotes => boolean().withDefault(const Constant(true))();
  IntColumn get streakGracePeriod => integer().withDefault(const Constant(1))();  // 0-2 days

  // Privacy
  BoolColumn get shareActivityWithFriends => boolean().withDefault(const Constant(true))();

  // Integrations
  BoolColumn get appleHealthConnected => boolean().withDefault(const Constant(false))();
  BoolColumn get googleFitConnected => boolean().withDefault(const Constant(false))();
  BoolColumn get stravaConnected => boolean().withDefault(const Constant(false))();
  BoolColumn get stravaAutoShare => boolean().withDefault(const Constant(false))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 3.1.13 Friendships Table

```dart
class Friendships extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get user1Id => text()();  // Firebase UID (alphabetically first)
  TextColumn get user2Id => text()();  // Firebase UID (alphabetically second)
  TextColumn get status => text()();  // 'pending', 'accepted', 'declined'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get acceptedAt => dateTime().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get firestoreId => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {user1Id, user2Id}
  ];
}
```

#### 3.1.14 Referrals Table

```dart
class Referrals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get referrerId => text()();  // User who sent invite
  TextColumn get referredUserId => text().nullable()();  // User who joined (null until signup)
  TextColumn get referralCode => text().unique()();
  TextColumn get status => text()();  // 'pending', 'completed'
  DateTimeColumn get installedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get firestoreId => text().nullable()();
}
```

### 3.2 Firestore (Cloud) Schema

Firestore mirrors Drift structure but uses NoSQL collections. **Drift is source of truth**, Firestore is backup/sync.

#### 3.2.1 Collection Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile (document)
│       │   ├── email: string
│       │   ├── displayName: string
│       │   ├── photoUrl: string
│       │   ├── createdAt: timestamp
│       │   ├── updatedAt: timestamp
│       │   ├── consentGiven: boolean
│       │   └── consentDate: timestamp
│       │
│       ├── stats/
│       │   └── streaks (document)
│       │       ├── currentStreak: number
│       │       ├── longestStreak: number
│       │       ├── lastWorkoutDate: timestamp
│       │       └── workoutCount: number
│       │
│       ├── preferences (document)
│       │   ├── weightUnit: string
│       │   ├── workoutReminderEnabled: boolean
│       │   └── ... (all UserPreferences fields)
│       │
│       ├── workouts/
│       │   └── {workoutId}/
│       │       ├── startTime: timestamp
│       │       ├── endTime: timestamp
│       │       ├── status: string
│       │       ├── notes: string
│       │       ├── createdAt: timestamp
│       │       ├── updatedAt: timestamp
│       │       │
│       │       └── exercises/
│       │           └── {exerciseId}/
│       │               ├── exerciseId: string
│       │               ├── exerciseName: string (denormalized)
│       │               ├── order: number
│       │               ├── notes: string
│       │               │
│       │               └── sets/
│       │                   └── {setId}/
│       │                       ├── setNumber: number
│       │                       ├── reps: number
│       │                       ├── weight: number
│       │                       ├── unit: string
│       │                       ├── perceivedEffort: number
│       │                       ├── notes: string
│       │                       └── timestamp: timestamp
│       │
│       ├── body_measurements/
│       │   └── {measurementId}/
│       │       ├── date: timestamp
│       │       ├── weight: number
│       │       ├── unit: string
│       │       ├── bodyFatPercent: number
│       │       ├── photoUrls: array<string>
│       │       ├── notes: string
│       │       └── createdAt: timestamp
│       │
│       ├── daily_check_ins/
│       │   └── {checkInId}/
│       │       ├── date: timestamp
│       │       ├── mood: number
│       │       ├── notes: string
│       │       └── createdAt: timestamp
│       │
│       ├── templates/
│       │   └── {templateId}/
│       │       ├── name: string
│       │       ├── description: string
│       │       ├── isPublic: boolean
│       │       ├── useCount: number
│       │       ├── lastUsed: timestamp
│       │       ├── createdAt: timestamp
│       │       ├── updatedAt: timestamp
│       │       │
│       │       └── exercises/
│       │           └── {exerciseId}/
│       │               ├── exerciseId: string
│       │               ├── exerciseName: string
│       │               ├── order: number
│       │               ├── suggestedSets: number
│       │               ├── suggestedReps: number
│       │               └── notes: string
│       │
│       ├── achievements/
│       │   └── {achievementId}/
│       │       ├── achievementId: string
│       │       ├── unlockedAt: timestamp
│       │       └── progress: number
│       │
│       └── integrations/
│           ├── apple_health (document)
│           │   ├── connected: boolean
│           │   ├── lastSyncAt: timestamp
│           │   └── lastError: string
│           │
│           ├── google_fit (document)
│           ├── strava (document)
│           └── ...
│
├── friendships/
│   └── {friendshipId}/  # Format: {userId1}_{userId2} (sorted alphabetically)
│       ├── user1Id: string
│       ├── user2Id: string
│       ├── status: string
│       ├── createdAt: timestamp
│       └── acceptedAt: timestamp
│
├── referrals/
│   └── {referralId}/
│       ├── referrerId: string
│       ├── referredUserId: string
│       ├── referralCode: string
│       ├── status: string
│       ├── installedAt: timestamp
│       ├── completedAt: timestamp
│       └── createdAt: timestamp
│
├── exercises/  # Global exercise library (system + user-created public)
│   └── {exerciseId}/
│       ├── name: string
│       ├── category: string
│       ├── equipment: string
│       ├── muscleGroup: string
│       ├── secondaryMuscles: array<string>
│       ├── instructions: string
│       ├── videoUrl: string
│       ├── thumbnailUrl: string
│       ├── isCustom: boolean
│       ├── createdBy: string
│       ├── createdAt: timestamp
│       └── popularity: number  # For ranking
│
└── shared_templates/  # Publicly shared workout templates
    └── {templateId}/
        ├── name: string
        ├── description: string
        ├── createdBy: string
        ├── createdByName: string
        ├── exercises: array<object>
        ├── popularity: number
        ├── createdAt: timestamp
        └── updatedAt: timestamp
```

#### 3.2.2 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidTimestamp(timestamp) {
      return timestamp is timestamp;
    }

    // Users collection
    match /users/{userId} {
      // Profile document
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);

      // User's workouts
      match /workouts/{workoutId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);

        // Nested exercises and sets
        match /{document=**} {
          allow read: if isOwner(userId);
          allow write: if isOwner(userId);
        }
      }

      // Body measurements
      match /body_measurements/{measurementId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }

      // Daily check-ins
      match /daily_check_ins/{checkInId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }

      // Templates
      match /templates/{templateId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);

        match /exercises/{exerciseId} {
          allow read: if isOwner(userId);
          allow write: if isOwner(userId);
        }
      }

      // Achievements
      match /achievements/{achievementId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }

      // Preferences
      match /preferences {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }

      // Stats
      match /stats/{document} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }

      // Integrations
      match /integrations/{integration} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
    }

    // Friendships
    match /friendships/{friendshipId} {
      allow read: if isAuthenticated() &&
        (resource.data.user1Id == request.auth.uid ||
         resource.data.user2Id == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        (resource.data.user1Id == request.auth.uid ||
         resource.data.user2Id == request.auth.uid);
      allow delete: if isAuthenticated() &&
        (resource.data.user1Id == request.auth.uid ||
         resource.data.user2Id == request.auth.uid);
    }

    // Referrals
    match /referrals/{referralId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        resource.data.referrerId == request.auth.uid;
    }

    // Global exercise library
    match /exercises/{exerciseId} {
      allow read: if true;  // Public read
      allow create: if isAuthenticated();  // Users can add custom exercises
      allow update: if isAuthenticated() &&
        resource.data.createdBy == request.auth.uid;  // Only creator can edit
      allow delete: if isAuthenticated() &&
        resource.data.createdBy == request.auth.uid;
    }

    // Shared templates
    match /shared_templates/{templateId} {
      allow read: if true;  // Public read
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        resource.data.createdBy == request.auth.uid;
      allow delete: if isAuthenticated() &&
        resource.data.createdBy == request.auth.uid;
    }
  }
}
```

---

## 4. State Management Architecture

### 4.1 Riverpod Architecture

GymApp uses **Riverpod 2.x** for state management with code generation for type safety.

#### 4.1.1 Provider Types

| Provider Type | Use Case | Example |
|---------------|----------|---------|
| **Provider** | Immutable values, singletons | `exerciseRepositoryProvider` |
| **StateProvider** | Simple mutable state | `selectedExerciseIdProvider` |
| **StateNotifierProvider** | Complex state with logic | `activeWorkoutProvider` |
| **FutureProvider** | Async data loading | `userProfileProvider` |
| **StreamProvider** | Real-time data streams | `workoutHistoryStreamProvider` |

#### 4.1.2 Provider Organization

```
lib/
├── core/
│   └── providers/
│       ├── drift_provider.dart          # Drift database instance
│       ├── firestore_provider.dart      # Firestore instance
│       ├── firebase_auth_provider.dart  # Auth instance
│       └── connectivity_provider.dart   # Network status
│
└── features/
    ├── auth/
    │   └── providers/
    │       ├── auth_state_provider.dart       # Current user state
    │       └── auth_controller_provider.dart  # Login/signup logic
    │
    ├── workout/
    │   └── providers/
    │       ├── active_workout_provider.dart      # Current workout session
    │       ├── workout_repository_provider.dart  # Data access
    │       ├── workout_history_provider.dart     # Past workouts
    │       └── pattern_memory_provider.dart      # Smart Pattern Memory
    │
    ├── exercise/
    │   └── providers/
    │       ├── exercise_library_provider.dart    # All exercises
    │       ├── exercise_search_provider.dart     # Search/filter
    │       └── favorites_provider.dart           # User favorites
    │
    ├── progress/
    │   └── providers/
    │       ├── body_measurements_provider.dart
    │       ├── charts_provider.dart
    │       └── achievements_provider.dart
    │
    └── social/
        └── providers/
            ├── friendships_provider.dart
            ├── referrals_provider.dart
            └── activity_feed_provider.dart
```

#### 4.1.3 Example: Active Workout Provider

```dart
// lib/features/workout/models/active_workout_state.dart
@freezed
class ActiveWorkoutState with _$ActiveWorkoutState {
  const factory ActiveWorkoutState({
    WorkoutSession? session,
    @Default([]) List<WorkoutExerciseWithSets> exercises,
    @Default(false) bool isLoading,
    String? error,
  }) = _ActiveWorkoutState;
}

// lib/features/workout/providers/active_workout_provider.dart
@riverpod
class ActiveWorkout extends _$ActiveWorkout {
  @override
  ActiveWorkoutState build() {
    return const ActiveWorkoutState();
  }

  Future<void> startWorkout() async {
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final session = await repo.createWorkoutSession();

      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e, stack) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      ref.read(crashlyticsProvider).recordError(e, stack);
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    final repo = ref.read(workoutRepositoryProvider);
    final patternMemory = ref.read(patternMemoryProvider);

    // Get pattern memory for this exercise
    final pattern = await patternMemory.getPattern(exercise.id);

    // Create workout exercise
    final workoutExercise = await repo.addExerciseToWorkout(
      workoutId: state.session!.id,
      exerciseId: exercise.id,
      suggestedSets: pattern?.sets ?? [],
    );

    state = state.copyWith(
      exercises: [...state.exercises, workoutExercise],
    );
  }

  Future<void> logSet({
    required int workoutExerciseId,
    required int reps,
    double? weight,
    int? perceivedEffort,
  }) async {
    final repo = ref.read(workoutRepositoryProvider);

    await repo.logSet(
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      perceivedEffort: perceivedEffort,
    );

    // Refresh exercises to show new set
    final updatedExercises = await repo.getWorkoutExercises(state.session!.id);
    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> finishWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);

    await repo.finishWorkout(state.session!.id);

    // Trigger sync
    ref.read(syncServiceProvider).syncWorkout(state.session!.id);

    // Reset state
    state = const ActiveWorkoutState();
  }
}
```

### 4.2 Repository Pattern

All data access goes through repositories to abstract Drift/Firestore complexity.

```dart
// lib/features/workout/repositories/workout_repository.dart
@riverpod
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  return WorkoutRepository(
    database: ref.watch(driftProvider),
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

class WorkoutRepository {
  final AppDatabase database;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  WorkoutRepository({
    required this.database,
    required this.firestore,
    required this.auth,
  });

  // Create workout session (writes to Drift first, sync later)
  Future<WorkoutSession> createWorkoutSession() async {
    final userId = auth.currentUser!.uid;

    final session = WorkoutSessionsCompanion(
      firebaseUid: Value(userId),
      startTime: Value(DateTime.now()),
      status: const Value('in_progress'),
      synced: const Value(false),
      dirty: const Value(true),
    );

    final id = await database.workoutSessionsDao.insertSession(session);
    return await database.workoutSessionsDao.getSessionById(id);
  }

  // Get workout history (from Drift, not Firestore)
  Stream<List<WorkoutSession>> watchWorkoutHistory() {
    final userId = auth.currentUser!.uid;
    return database.workoutSessionsDao.watchWorkoutsByUser(userId);
  }

  // Sync to Firestore (called by SyncService)
  Future<void> syncWorkoutToFirestore(int workoutId) async {
    final workout = await database.workoutSessionsDao.getSessionById(workoutId);

    if (workout.synced) return;  // Already synced

    final userId = auth.currentUser!.uid;
    final firestoreDoc = firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc();

    // Build Firestore document
    final data = {
      'startTime': Timestamp.fromDate(workout.startTime),
      'endTime': workout.endTime != null
          ? Timestamp.fromDate(workout.endTime!)
          : null,
      'status': workout.status,
      'notes': workout.notes,
      'createdAt': Timestamp.fromDate(workout.createdAt),
      'updatedAt': Timestamp.fromDate(workout.updatedAt),
    };

    await firestoreDoc.set(data);

    // Update Drift with Firestore ID and mark as synced
    await database.workoutSessionsDao.updateSession(
      workout.copyWith(
        synced: true,
        dirty: false,
        firestoreId: firestoreDoc.id,
      ),
    );
  }
}
```

---

## 5. Offline-First Sync Strategy

### 5.1 Sync Architecture

```
┌──────────────────────────────────────────────────────┐
│                  App (Foreground)                     │
├──────────────────────────────────────────────────────┤
│                                                       │
│  User Action (e.g., log set)                         │
│          │                                            │
│          ▼                                            │
│    ┌─────────────┐                                   │
│    │   Drift DB  │  ◄── Write immediately (offline)  │
│    └─────────────┘                                   │
│          │                                            │
│          │ Mark as dirty=true, synced=false          │
│          │                                            │
│          ▼                                            │
│    ┌─────────────┐                                   │
│    │ Sync Queue  │                                   │
│    └─────────────┘                                   │
│          │                                            │
│          │ When online...                            │
│          │                                            │
│          ▼                                            │
│    ┌─────────────┐                                   │
│    │  Firestore  │  ◄── Sync in background          │
│    └─────────────┘                                   │
│          │                                            │
│          │ On success...                             │
│          │                                            │
│          ▼                                            │
│    Update Drift: dirty=false, synced=true            │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### 5.2 Sync Service

```dart
// lib/core/services/sync_service.dart
@riverpod
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    database: ref.watch(driftProvider),
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    connectivity: ref.watch(connectivityProvider),
  );
}

class SyncService {
  final AppDatabase database;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Connectivity connectivity;

  StreamSubscription? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  SyncService({
    required this.database,
    required this.firestore,
    required this.auth,
    required this.connectivity,
  });

  void initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (result) {
        if (result != ConnectivityResult.none) {
          syncAll();  // Sync when coming online
        }
      },
    );

    // Periodic sync every 5 minutes when online
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );
  }

  Future<void> syncAll() async {
    if (!await _isOnline()) return;

    try {
      await _syncWorkouts();
      await _syncBodyMeasurements();
      await _syncCheckIns();
      await _syncTemplates();
      await _syncAchievements();

      // Download changes from Firestore
      await _downloadRemoteChanges();
    } catch (e, stack) {
      // Log error but don't throw (silent failure)
      debugPrint('Sync failed: $e');
      Crashlytics.instance.recordError(e, stack);
    }
  }

  Future<void> _syncWorkouts() async {
    final userId = auth.currentUser!.uid;

    // Get all unsynced workouts
    final unsyncedWorkouts = await database.workoutSessionsDao
        .getUnsyncedWorkouts(userId);

    for (final workout in unsyncedWorkouts) {
      try {
        await _syncSingleWorkout(workout);
      } catch (e) {
        // Continue with next workout even if one fails
        debugPrint('Failed to sync workout ${workout.id}: $e');
      }
    }
  }

  Future<void> _syncSingleWorkout(WorkoutSession workout) async {
    final userId = auth.currentUser!.uid;

    // Create or update Firestore document
    final firestoreRef = workout.firestoreId != null
        ? firestore.collection('users/$userId/workouts').doc(workout.firestoreId)
        : firestore.collection('users/$userId/workouts').doc();

    // Build workout data
    final workoutData = {
      'startTime': Timestamp.fromDate(workout.startTime),
      'endTime': workout.endTime != null
          ? Timestamp.fromDate(workout.endTime!)
          : null,
      'status': workout.status,
      'notes': workout.notes,
      'createdAt': Timestamp.fromDate(workout.createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    // Write to Firestore
    await firestoreRef.set(workoutData, SetOptions(merge: true));

    // Sync exercises and sets
    await _syncWorkoutExercises(workout.id, firestoreRef.path);

    // Mark as synced in Drift
    await database.workoutSessionsDao.updateSession(
      workout.copyWith(
        synced: true,
        dirty: false,
        firestoreId: firestoreRef.id,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _syncWorkoutExercises(int workoutId, String workoutPath) async {
    final exercises = await database.workoutExercisesDao
        .getExercisesByWorkout(workoutId);

    for (final exercise in exercises) {
      final exerciseRef = firestore.doc('$workoutPath/exercises/${exercise.id}');

      final exerciseData = {
        'exerciseId': exercise.exerciseId,
        'exerciseName': exercise.exerciseName,  // Denormalized
        'order': exercise.orderIndex,
        'notes': exercise.notes,
      };

      await exerciseRef.set(exerciseData);

      // Sync sets
      await _syncSets(exercise.id, exerciseRef.path);
    }
  }

  Future<void> _syncSets(int workoutExerciseId, String exercisePath) async {
    final sets = await database.workoutSetsDao
        .getSetsByWorkoutExercise(workoutExerciseId);

    final batch = firestore.batch();

    for (final set in sets) {
      final setRef = firestore.doc('$exercisePath/sets/${set.id}');

      final setData = {
        'setNumber': set.setNumber,
        'reps': set.reps,
        'weight': set.weight,
        'unit': set.unit,
        'perceivedEffort': set.perceivedEffort,
        'notes': set.notes,
        'timestamp': Timestamp.fromDate(set.timestamp),
      };

      batch.set(setRef, setData);
    }

    await batch.commit();
  }

  Future<void> _downloadRemoteChanges() async {
    final userId = auth.currentUser!.uid;

    // Get last sync timestamp
    final lastSync = await database.syncMetadataDao.getLastSyncTime(userId);

    // Query Firestore for changes since last sync
    final snapshot = await firestore
        .collection('users/$userId/workouts')
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSync))
        .get();

    for (final doc in snapshot.docs) {
      await _importWorkoutFromFirestore(doc);
    }

    // Update last sync time
    await database.syncMetadataDao.updateLastSyncTime(userId, DateTime.now());
  }

  Future<void> _importWorkoutFromFirestore(DocumentSnapshot doc) async {
    // Check if workout exists locally
    final existingWorkout = await database.workoutSessionsDao
        .getSessionByFirestoreId(doc.id);

    if (existingWorkout != null) {
      // Conflict resolution: compare updatedAt timestamps
      final firestoreUpdatedAt = (doc.data()!['updatedAt'] as Timestamp).toDate();

      if (firestoreUpdatedAt.isAfter(existingWorkout.updatedAt)) {
        // Remote is newer, update local
        await _updateLocalWorkout(existingWorkout, doc);
      } else {
        // Local is newer, mark for re-sync
        await database.workoutSessionsDao.updateSession(
          existingWorkout.copyWith(dirty: true, synced: false),
        );
      }
    } else {
      // New workout from another device, import it
      await _createLocalWorkout(doc);
    }
  }

  Future<bool> _isOnline() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
  }
}
```

### 5.3 Conflict Resolution Strategy

| Scenario | Resolution Strategy |
|----------|-------------------|
| **User edits workout on Device A while offline** | Drift marks `dirty=true, synced=false`. When online, sync to Firestore with `updatedAt=now()` |
| **User edits same workout on Device B while A is offline** | Device B syncs first. When Device A comes online, detects `updatedAt` conflict. Uses **Last Write Wins** (newer `updatedAt` wins). Losing device marks workout as `conflict=true` for user review. |
| **User deletes workout on Device A, edits on Device B** | Delete sync adds `deletedAt` timestamp to Firestore. Device B detects deletion, shows notification: "Workout was deleted on another device. Restore local copy?" |
| **Network error during sync** | Retry with exponential backoff (1s, 2s, 4s, 8s, max 30s). After 5 failures, mark sync as `failed`, show notification. Auto-retry on next app launch or connectivity change. |

---

## 6. Security Architecture

### 6.1 Authentication Flow

```
┌──────────────────────────────────────────────────────────┐
│                    App Launch                             │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  Firebase Auth Check   │
        └────────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
   ┌──────────┐           ┌──────────┐
   │ Logged   │           │   Not    │
   │   In     │           │ Logged In│
   └────┬─────┘           └────┬─────┘
        │                      │
        ▼                      ▼
   ┌──────────┐         ┌────────────┐
   │   Home   │         │   Login    │
   │  Screen  │         │   Screen   │
   └──────────┘         └──────┬─────┘
                               │
               ┌───────────────┼────────────────┐
               │               │                │
               ▼               ▼                ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │  Email/  │    │  Google  │    │  Apple   │
        │ Password │    │ Sign-In  │    │ Sign-In  │
        └────┬─────┘    └────┬─────┘    └────┬─────┘
             │               │                │
             └───────────────┼────────────────┘
                             │
                             ▼
                   ┌──────────────────┐
                   │ Firebase Auth    │
                   │ Creates User     │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │  GDPR Consent    │
                   │     Screen       │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │   Onboarding     │
                   │  (Goal, Level)   │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │   Home Screen    │
                   └──────────────────┘
```

### 6.2 Data Encryption

| Data Type | At Rest | In Transit | Implementation |
|-----------|---------|------------|----------------|
| **Drift Database** | AES-256 (via SQLCipher if sensitive) | N/A (local only) | Use `encrypted_drift` for sensitive fields |
| **Firestore Documents** | AES-256 (Google-managed) | TLS 1.3 | Automatic via Firebase SDK |
| **Firebase Storage (Photos)** | AES-256 (Google-managed) | TLS 1.3 | Automatic via Firebase SDK |
| **Auth Tokens** | Keychain (iOS) / Keystore (Android) | TLS 1.3 | `flutter_secure_storage` |
| **User Passwords** | bcrypt (Firebase Auth) | TLS 1.3 | Firebase Auth handles |

### 6.3 GDPR Compliance

#### 6.3.1 Data Processing Legal Basis

- **Consent**: Required for optional features (analytics, personalized recommendations)
- **Contract**: Necessary for app functionality (logging workouts, syncing data)
- **Legitimate Interest**: Security, fraud prevention, app improvement

#### 6.3.2 User Rights Implementation

| GDPR Right | Implementation | Code Reference |
|------------|---------------|----------------|
| **Right to Access (Art. 15)** | User can view all data in Settings → Privacy | `privacy_screen.dart` |
| **Right to Portability (Art. 20)** | Export all data as CSV | `export_data_service.dart` (Story 6.6) |
| **Right to Erasure (Art. 17)** | Delete account + all data | `account_deletion_service.dart` |
| **Right to Rectification (Art. 16)** | Edit workouts, profile, measurements | Covered by edit features |
| **Right to Object (Art. 21)** | Opt out of analytics, marketing | `user_preferences` table |

#### 6.3.3 Data Retention Policy

```dart
// lib/core/services/gdpr_service.dart
class GDPRService {
  // Delete user data upon account deletion
  Future<void> deleteAllUserData(String userId) async {
    // 1. Delete Firestore data
    final batch = firestore.batch();

    // Delete workouts
    final workouts = await firestore
        .collection('users/$userId/workouts')
        .get();
    for (final doc in workouts.docs) {
      batch.delete(doc.reference);
    }

    // Delete other collections...
    await batch.commit();

    // 2. Delete Firebase Storage photos
    final storageRef = storage.ref('users/$userId');
    final photos = await storageRef.listAll();
    for (final photo in photos.items) {
      await photo.delete();
    }

    // 3. Delete local Drift data
    await database.usersDao.deleteUser(userId);

    // 4. Delete Firebase Auth account
    await auth.currentUser!.delete();
  }

  // Export all data (GDPR Article 20)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    return {
      'profile': await _exportProfile(userId),
      'workouts': await _exportWorkouts(userId),
      'body_measurements': await _exportBodyMeasurements(userId),
      'achievements': await _exportAchievements(userId),
      'templates': await _exportTemplates(userId),
      'exported_at': DateTime.now().toIso8601String(),
      'format_version': '1.0',
    };
  }
}
```

### 6.4 API Security

#### 6.4.1 Firebase Cloud Functions Authentication

```javascript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Middleware: Verify user is authenticated
const requireAuth = async (context: functions.https.CallableContext) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }
  return context.auth.uid;
};

// Example: Weekly report generator
export const generateWeeklyReport = functions.https.onCall(async (data, context) => {
  const userId = await requireAuth(context);

  // Fetch user's workouts from last 7 days
  const workouts = await admin.firestore()
    .collection(`users/${userId}/workouts`)
    .where('startTime', '>=', getLastWeekTimestamp())
    .get();

  // Generate report...
  return {
    totalWorkouts: workouts.size,
    totalVolume: calculateTotalVolume(workouts),
    // ...
  };
});
```

#### 6.4.2 Rate Limiting

```javascript
// functions/src/rate-limiter.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const RATE_LIMIT = 10;  // requests per minute
const WINDOW = 60;  // seconds

export const rateLimiter = async (userId: string, endpoint: string) => {
  const key = `rateLimit:${userId}:${endpoint}`;
  const ref = admin.database().ref(key);

  const snapshot = await ref.once('value');
  const count = snapshot.val() || 0;

  if (count >= RATE_LIMIT) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Too many requests. Please try again later.'
    );
  }

  await ref.set(count + 1);
  await ref.expire(WINDOW);
};
```

---

## 7. API Contracts

### 7.1 Firebase Cloud Functions

#### 7.1.1 Weekly Report Generator

```typescript
// functions/src/reports/weekly-report.ts
export const generateWeeklyReport = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    const userId = await requireAuth(context);

    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7);

    // Query workouts
    const workoutsSnapshot = await admin.firestore()
      .collection(`users/${userId}/workouts`)
      .where('startTime', '>=', admin.firestore.Timestamp.fromDate(startDate))
      .where('startTime', '<=', admin.firestore.Timestamp.fromDate(endDate))
      .where('status', '==', 'completed')
      .get();

    let totalVolume = 0;
    let totalSets = 0;
    const muscleGroupVolume: Record<string, number> = {};

    // Process each workout
    for (const workoutDoc of workoutsSnapshot.docs) {
      const exercisesSnapshot = await workoutDoc.ref
        .collection('exercises')
        .get();

      for (const exerciseDoc of exercisesSnapshot.docs) {
        const setsSnapshot = await exerciseDoc.ref
          .collection('sets')
          .get();

        setsSnapshot.forEach(setDoc => {
          const set = setDoc.data();
          const volume = (set.reps || 0) * (set.weight || 0);
          totalVolume += volume;
          totalSets++;

          // Track muscle group volume
          const muscleGroup = set.muscleGroup || 'Other';
          muscleGroupVolume[muscleGroup] =
            (muscleGroupVolume[muscleGroup] || 0) + volume;
        });
      }
    }

    // Find top muscle group
    const topMuscleGroup = Object.entries(muscleGroupVolume)
      .sort(([, a], [, b]) => b - a)[0];

    return {
      period: {
        start: startDate.toISOString(),
        end: endDate.toISOString(),
      },
      totalWorkouts: workoutsSnapshot.size,
      totalVolume,
      totalSets,
      topMuscleGroup: topMuscleGroup ? {
        name: topMuscleGroup[0],
        volume: topMuscleGroup[1],
        percentage: Math.round((topMuscleGroup[1] / totalVolume) * 100),
      } : null,
    };
  });
```

**Usage in Flutter**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('generateWeeklyReport');
final result = await callable.call();
final report = WeeklyReport.fromJson(result.data);
```

#### 7.1.2 Referral Attribution

```typescript
// functions/src/referrals/track-install.ts
export const trackReferralInstall = functions
  .region('europe-west1')
  .https.onCall(async (data: { referralCode: string }, context) => {
    const userId = await requireAuth(context);
    const { referralCode } = data;

    // Find referrer
    const referralSnapshot = await admin.firestore()
      .collection('referrals')
      .where('referralCode', '==', referralCode)
      .limit(1)
      .get();

    if (referralSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'Invalid referral code');
    }

    const referralDoc = referralSnapshot.docs[0];
    const referralData = referralDoc.data();

    // Update referral with new user
    await referralDoc.ref.update({
      referredUserId: userId,
      status: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to referrer
    await sendFCMNotification(referralData.referrerId, {
      title: 'New Friend Joined!',
      body: 'Your friend just joined GymApp from your invite.',
    });

    // Award badge to referrer
    await awardAchievement(referralData.referrerId, 'connector');

    return { success: true };
  });
```

### 7.2 Third-Party API Integrations

#### 7.2.1 Strava API

```dart
// lib/core/services/strava_service.dart
class StravaService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://www.strava.com/api/v3'));

  Future<void> uploadWorkout(WorkoutSession workout) async {
    final accessToken = await _getAccessToken();

    final response = await _dio.post(
      '/activities',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      data: {
        'name': 'GymApp Strength Workout',
        'type': 'WeightTraining',
        'start_date_local': workout.startTime.toIso8601String(),
        'elapsed_time': workout.duration.inSeconds,
        'description': _buildDescription(workout),
      },
    );

    if (response.statusCode == 201) {
      // Success
      await _saveStravaActivityId(workout.id, response.data['id']);
    }
  }

  String _buildDescription(WorkoutSession workout) {
    return '''
${workout.exercises.length} exercises, ${workout.totalSets} sets, ${workout.totalVolume.toStringAsFixed(0)}kg volume

Logged with GymApp 💪
Download: https://gymapp.io/download
''';
  }
}
```

#### 7.2.2 Apple Health Integration

```dart
// lib/core/services/apple_health_service.dart
import 'package:health/health.dart';

class AppleHealthService {
  final Health _health = Health();

  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.WORKOUT,
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
    ];

    return await _health.requestAuthorization(types);
  }

  Future<void> writeWorkout(WorkoutSession workout) async {
    final success = await _health.writeWorkoutData(
      workout.startTime,
      workout.endTime!,
      activityType: HealthWorkoutActivityType.STRENGTH_TRAINING,
      totalEnergyBurned: _estimateCalories(workout),
      totalDistance: 0,
    );

    if (!success) {
      throw Exception('Failed to write workout to Apple Health');
    }
  }

  Future<List<HealthDataPoint>> fetchWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _health.getHealthDataFromTypes(
      startDate,
      endDate,
      [HealthDataType.WEIGHT],
    );
  }

  double _estimateCalories(WorkoutSession workout) {
    // Rough estimate: volume * 0.5 + duration * 5
    return workout.totalVolume * 0.5 + workout.duration.inMinutes * 5;
  }
}
```

---

## 8. Project Structure

```
lib/
├── main.dart                        # App entry point
├── app.dart                         # MaterialApp setup with routing
│
├── core/
│   ├── config/
│   │   ├── app_config.dart          # Environment config (dev/staging/prod)
│   │   └── firebase_options.dart    # Firebase config (generated)
│   │
│   ├── database/
│   │   ├── app_database.dart        # Drift database definition
│   │   ├── app_database.g.dart      # Generated
│   │   ├── daos/                    # Data Access Objects
│   │   │   ├── users_dao.dart
│   │   │   ├── workout_sessions_dao.dart
│   │   │   ├── exercises_dao.dart
│   │   │   └── ...
│   │   └── tables/                  # Drift table definitions
│   │       ├── users.dart
│   │       ├── workout_sessions.dart
│   │       └── ...
│   │
│   ├── providers/
│   │   ├── drift_provider.dart      # Drift instance provider
│   │   ├── firestore_provider.dart  # Firestore instance provider
│   │   ├── firebase_auth_provider.dart
│   │   └── connectivity_provider.dart
│   │
│   ├── router/
│   │   ├── app_router.dart          # go_router configuration
│   │   └── routes.dart              # Route constants
│   │
│   ├── services/
│   │   ├── sync_service.dart        # Offline-first sync
│   │   ├── gdpr_service.dart        # GDPR compliance
│   │   ├── notification_service.dart
│   │   ├── analytics_service.dart
│   │   ├── apple_health_service.dart
│   │   ├── google_fit_service.dart
│   │   └── strava_service.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart           # Material Design theme
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   └── dimensions.dart
│   │
│   └── utils/
│       ├── validators.dart          # Form validators
│       ├── formatters.dart          # Date, number formatters
│       ├── extensions.dart          # Extension methods
│       └── constants.dart           # App constants
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── user.freezed.dart
│   │   │   └── user.g.dart
│   │   ├── providers/
│   │   │   ├── auth_state_provider.dart
│   │   │   └── auth_controller_provider.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── onboarding_screen.dart
│   │   └── widgets/
│   │       ├── email_field.dart
│   │       ├── password_field.dart
│   │       └── social_login_button.dart
│   │
│   ├── workout/
│   │   ├── models/
│   │   │   ├── workout_session.dart
│   │   │   ├── workout_exercise.dart
│   │   │   ├── workout_set.dart
│   │   │   └── active_workout_state.dart
│   │   ├── providers/
│   │   │   ├── active_workout_provider.dart
│   │   │   ├── workout_repository_provider.dart
│   │   │   ├── workout_history_provider.dart
│   │   │   └── pattern_memory_provider.dart
│   │   ├── repositories/
│   │   │   └── workout_repository.dart
│   │   ├── screens/
│   │   │   ├── active_workout_screen.dart
│   │   │   ├── workout_history_screen.dart
│   │   │   ├── workout_detail_screen.dart
│   │   │   └── workout_summary_screen.dart
│   │   └── widgets/
│   │       ├── exercise_card.dart
│   │       ├── set_input_row.dart
│   │       ├── rest_timer_widget.dart
│   │       ├── pattern_memory_badge.dart
│   │       └── workout_stats_card.dart
│   │
│   ├── exercise/
│   │   ├── models/
│   │   │   └── exercise.dart
│   │   ├── providers/
│   │   │   ├── exercise_library_provider.dart
│   │   │   ├── exercise_search_provider.dart
│   │   │   └── favorites_provider.dart
│   │   ├── repositories/
│   │   │   └── exercise_repository.dart
│   │   ├── screens/
│   │   │   ├── exercise_library_screen.dart
│   │   │   └── exercise_detail_screen.dart
│   │   └── widgets/
│   │       ├── exercise_list_tile.dart
│   │       ├── exercise_filter_chip.dart
│   │       └── exercise_search_bar.dart
│   │
│   ├── progress/
│   │   ├── models/
│   │   │   ├── body_measurement.dart
│   │   │   ├── achievement.dart
│   │   │   └── chart_data.dart
│   │   ├── providers/
│   │   │   ├── body_measurements_provider.dart
│   │   │   ├── charts_provider.dart
│   │   │   └── achievements_provider.dart
│   │   ├── repositories/
│   │   │   ├── progress_repository.dart
│   │   │   └── achievements_repository.dart
│   │   ├── screens/
│   │   │   ├── progress_screen.dart
│   │   │   ├── body_measurements_screen.dart
│   │   │   ├── exercise_progress_screen.dart
│   │   │   └── achievements_screen.dart
│   │   └── widgets/
│   │       ├── line_chart_widget.dart
│   │       ├── bar_chart_widget.dart
│   │       ├── achievement_badge.dart
│   │       └── personal_records_card.dart
│   │
│   ├── templates/
│   │   ├── models/
│   │   │   ├── workout_template.dart
│   │   │   └── template_exercise.dart
│   │   ├── providers/
│   │   │   ├── templates_provider.dart
│   │   │   └── template_builder_provider.dart
│   │   ├── repositories/
│   │   │   └── template_repository.dart
│   │   ├── screens/
│   │   │   ├── templates_screen.dart
│   │   │   ├── template_builder_screen.dart
│   │   │   └── template_detail_screen.dart
│   │   └── widgets/
│   │       ├── template_card.dart
│   │       ├── quick_start_carousel.dart
│   │       └── template_exercise_list.dart
│   │
│   ├── social/
│   │   ├── models/
│   │   │   ├── friendship.dart
│   │   │   └── referral.dart
│   │   ├── providers/
│   │   │   ├── friendships_provider.dart
│   │   │   ├── referrals_provider.dart
│   │   │   └── activity_feed_provider.dart
│   │   ├── repositories/
│   │   │   └── social_repository.dart
│   │   ├── screens/
│   │   │   ├── friends_screen.dart
│   │   │   ├── friend_profile_screen.dart
│   │   │   ├── referral_screen.dart
│   │   │   └── activity_feed_screen.dart
│   │   └── widgets/
│   │       ├── friend_list_tile.dart
│   │       ├── friend_request_card.dart
│   │       ├── activity_card.dart
│   │       └── referral_link_widget.dart
│   │
│   ├── habits/
│   │   ├── models/
│   │   │   ├── daily_check_in.dart
│   │   │   └── streak.dart
│   │   ├── providers/
│   │   │   ├── check_in_provider.dart
│   │   │   ├── streak_provider.dart
│   │   │   └── weekly_report_provider.dart
│   │   ├── repositories/
│   │   │   └── habits_repository.dart
│   │   ├── screens/
│   │   │   ├── calendar_screen.dart
│   │   │   ├── weekly_report_screen.dart
│   │   │   └── daily_check_in_screen.dart
│   │   └── widgets/
│   │       ├── calendar_heatmap.dart
│   │       ├── streak_badge.dart
│   │       ├── mood_selector.dart
│   │       └── weekly_stats_card.dart
│   │
│   ├── settings/
│   │   ├── models/
│   │   │   └── user_preferences.dart
│   │   ├── providers/
│   │   │   ├── preferences_provider.dart
│   │   │   └── integrations_provider.dart
│   │   ├── repositories/
│   │   │   └── settings_repository.dart
│   │   ├── screens/
│   │   │   ├── settings_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── privacy_screen.dart
│   │   │   ├── notifications_screen.dart
│   │   │   └── integrations_screen.dart
│   │   └── widgets/
│   │       ├── setting_tile.dart
│   │       ├── switch_setting.dart
│   │       └── integration_status_card.dart
│   │
│   └── home/
│       ├── providers/
│       │   └── home_provider.dart
│       ├── screens/
│       │   └── home_screen.dart
│       └── widgets/
│           ├── quick_start_section.dart
│           ├── streak_widget.dart
│           ├── daily_quote_card.dart
│           └── friend_activity_widget.dart
│
├── shared/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── loading_indicator.dart
│       ├── error_widget.dart
│       └── empty_state_widget.dart
│
└── assets/
    ├── images/
    ├── icons/
    ├── fonts/
    └── data/
        ├── exercises.json           # Seed data (500+ exercises)
        ├── starter_templates.json   # Pre-built templates
        └── quotes.json              # Daily motivational quotes
```

---

## 9. Performance Optimization

### 9.1 App Startup Optimization

**Target**: App startup < 2 seconds (95th percentile)

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (async, don't await)
  final firebaseInit = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Drift database (async, don't await)
  final databaseInit = _initDatabase();

  // Wait for critical services only
  await Future.wait([
    firebaseInit,
    databaseInit,
  ]);

  // Non-critical services can initialize in background
  unawaited(_initBackgroundServices());

  runApp(
    ProviderScope(
      child: const GymApp(),
    ),
  );
}

Future<void> _initBackgroundServices() async {
  // These don't block app start
  await NotificationService.initialize();
  await SyncService.initialize();
  await AnalyticsService.initialize();
}
```

### 9.2 Lazy Loading & Code Splitting

```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/workout/active',
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
    // Lazy load heavy screens
    GoRoute(
      path: '/progress/charts',
      pageBuilder: (context, state) {
        return MaterialPage(
          child: FutureBuilder(
            future: () async {
              // Load chart library lazily
              await Future.delayed(const Duration(milliseconds: 100));
              return const ProgressChartsScreen();
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return snapshot.data!;
            },
          ),
        );
      },
    ),
  ],
);
```

### 9.3 Database Query Optimization

```dart
// lib/core/database/daos/workout_sessions_dao.dart
@DriftAccessor(tables: [WorkoutSessions, WorkoutExercises, WorkoutSets])
class WorkoutSessionsDao extends DatabaseAccessor<AppDatabase> {
  // Use indexes for frequent queries
  @override
  List<TableInfo> get allTables => [workoutSessions, workoutExercises, workoutSets];

  // Optimize: Use LIMIT to prevent loading all history
  Future<List<WorkoutSession>> getRecentWorkouts(String userId, {int limit = 20}) {
    return (select(workoutSessions)
          ..where((ws) => ws.firebaseUid.equals(userId))
          ..where((ws) => ws.status.equals('completed'))
          ..orderBy([(ws) => OrderingTerm.desc(ws.startTime)])
          ..limit(limit))
        .get();
  }

  // Use streams for reactive UI
  Stream<List<WorkoutSession>> watchRecentWorkouts(String userId) {
    return (select(workoutSessions)
          ..where((ws) => ws.firebaseUid.equals(userId))
          ..where((ws) => ws.status.equals('completed'))
          ..orderBy([(ws) => OrderingTerm.desc(ws.startTime)])
          ..limit(20))
        .watch();
  }
}
```

### 9.4 Image Caching

```dart
// lib/shared/widgets/cached_exercise_image.dart
class CachedExerciseImage extends StatelessWidget {
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      memCacheWidth: 400,  // Resize for memory efficiency
      memCacheHeight: 400,
      placeholder: (context, url) => const LoadingIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.fitness_center),
      cacheManager: CacheManager(
        Config(
          'exercise_images',
          maxNrOfCacheObjects: 200,
          stalePeriod: const Duration(days: 30),
        ),
      ),
    );
  }
}
```

---

## 10. Scalability Considerations

### 10.1 Firestore Scaling

| Collection | Expected Documents | Indexing Strategy | Cost Optimization |
|------------|-------------------|-------------------|-------------------|
| `users` | 100k Year 2 | Composite index on `createdAt` | Single read per user session |
| `users/{uid}/workouts` | 200/user/year = 20M total Year 2 | Index on `startTime`, `status` | Use pagination (20 per page) |
| `users/{uid}/workouts/{id}/exercises` | 5/workout = 100M total | Index on `order` | Batch reads with workout |
| `users/{uid}/workouts/{id}/exercises/{id}/sets` | 15/exercise = 1.5B total | No index needed | Loaded with exercise, not separately |

**Cost Estimate Year 2** (100k users, 20M workouts, 1.5B sets):
- Storage: 1.5B sets × 100 bytes = 150GB × $0.18/GB/month = **$27/month**
- Reads: 100k users × 30 workouts/month × 3 reads = 9M reads × $0.06/100k = **$5.40/month**
- Writes: 100k users × 8 workouts/month × 1 write = 800k writes × $0.18/100k = **$1.44/month**
- **Total Firestore**: ~$35/month Year 2

### 10.2 Cloud Functions Scaling

```javascript
// functions/src/index.ts
import * as functions from 'firebase-functions';

// Use generous timeout and memory for heavy operations
export const generateWeeklyReport = functions
  .runWith({
    timeoutSeconds: 300,  // 5 minutes
    memory: '512MB',
  })
  .https.onCall(async (data, context) => {
    // Implementation...
  });

// Use Pub/Sub for scheduled tasks (not onCall for efficiency)
export const sendWeeklyReports = functions
  .pubsub.schedule('every sunday 20:00')
  .timeZone('Europe/London')
  .onRun(async (context) => {
    // Batch send reports to all active users
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('lastActiveAt', '>', getLastWeekTimestamp())
      .get();

    // Process in batches of 500 (Firestore limit)
    const batches = chunk(usersSnapshot.docs, 500);

    for (const batch of batches) {
      await Promise.all(
        batch.map(userDoc => sendWeeklyReportToUser(userDoc.id))
      );
    }
  });
```

### 10.3 CDN for Static Assets

```yaml
# firebase.json
{
  "hosting": {
    "public": "public",
    "headers": [
      {
        "source": "/exercise-images/**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=2592000"
          }
        ]
      },
      {
        "source": "/exercise-videos/**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

---

## Conclusion

This architecture document provides a comprehensive blueprint for implementing GymApp with:

✅ **Offline-first design** - Drift + Firestore sync
✅ **Clean architecture** - Separation of concerns with Riverpod
✅ **GDPR compliance** - Privacy by design
✅ **Scalability** - Firebase auto-scaling to 100k users
✅ **Security** - End-to-end encryption, authentication
✅ **Performance** - <2s startup, <2min logging

**Next Steps**:
1. Review architecture with team
2. Set up Firebase project (dev/staging/prod)
3. Initialize Flutter project with folder structure
4. Implement Drift database schema
5. Build authentication flow (Epic 2)
6. Proceed with Epic implementation (Epics 1-9)

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Status**: ✅ Ready for Implementation
