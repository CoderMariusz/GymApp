# Sprint 2 - Deferred Items from Sprint 1

**Document Purpose:** Track items deferred from Sprint 1 simplified scope to be added in Sprint 2.

**Created:** 2025-01-15
**Sprint 1 Simplification:** Reduced from 16 SP to 11 SP (5 SP buffer gained)

---

## Deferred from Story 1.1: Project Initialization

### Build Flavors Configuration

**Original Scope:** Complex build flavors with Xcode schemes and Android productFlavors
**Simplified to:** Simple environment config using `--dart-define`
**Reason for Deferral:** Build flavors add 2-3 hours complexity, not critical for Sprint 1
**Deferred to:** Sprint 2 (if needed) or defer indefinitely if simple config is sufficient

**Implementation Details (when added):**

**iOS - Xcode Schemes:**
1. Duplicate "Runner" scheme 3 times (Dev, Staging, Prod)
2. Configure each scheme with build configuration:
   - Dev: Debug, use `GoogleService-Info-Dev.plist`
   - Staging: Release, use `GoogleService-Info-Staging.plist`
   - Prod: Release, use `GoogleService-Info-Prod.plist`

**Android - Product Flavors:**
```gradle
// android/app/build.gradle
android {
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        prod {
            dimension "environment"
        }
    }
}
```

**Estimated Effort:** 3 SP (if implemented)
**Priority:** LOW - Simple environment config is sufficient for MVP

---

## Deferred from Story 1.2: Firebase Setup

### 1. Separate Firebase Projects (Dev/Staging/Prod)

**Original Scope:** 3 separate Firebase projects for each environment
**Simplified to:** Single "GymApp-Dev" project for Sprint 1
**Reason for Deferral:** 3 projects add complexity, single project is sufficient for development
**Deferred to:** Pre-production (before public launch)

**Implementation Details (when added):**
1. Create Firebase projects:
   - GymApp-Dev (for development)
   - GymApp-Staging (for pre-production testing)
   - GymApp-Prod (for production)
2. Configure each project with separate credentials
3. Update `AppConfig` to switch Firebase projects based on environment
4. Setup separate Firestore databases for each environment

**Estimated Effort:** 2 SP
**Priority:** MEDIUM - Needed before public launch, not critical for MVP development

---

### 2. Firebase Blaze Plan + Cost Alerts

**Original Scope:** Enable Blaze (pay-as-you-go) plan, configure cost alerts (£200/£400 thresholds)
**Simplified to:** Use Spark (free) plan, no billing required
**Reason for Deferral:** Free tier is sufficient for Sprint 1-3 development (no users yet)
**Deferred to:** Pre-production (when expecting real users)

**Implementation Details (when added):**
1. Enable billing in Firebase Console (requires credit card)
2. Upgrade to Blaze plan
3. Configure Cloud Budget alerts:
   - £200/month (50% threshold) - Warning email
   - £400/month (100% threshold) - Critical email
4. Setup Slack/email notifications

**Estimated Effort:** 0.5 SP (15-30 minutes)
**Priority:** HIGH - Required for Architecture Validation Action Item #2, but deferred until closer to production

**Note:** This is Architecture Validation Action Item #2, which is conditionally deferred to pre-production.

---

### 3. Complex Firestore Security Rules + Emulator Testing

**Original Scope:** Complex security rules with field-level permissions, tested with Firebase Emulator
**Simplified to:** Simple "own data only" rules, no emulator testing
**Reason for Deferral:** Complex rules add 2-3 hours, simple rules are sufficient for Sprint 1
**Deferred to:** Sprint 2-3 (when implementing sensitive features like social, payments)

**Implementation Details (when added):**

**Complex Firestore Rules Example:**
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection - own data + read-only profile
    match /users/{userId} {
      allow read: if isAuthenticated(); // All authenticated users can read profiles
      allow write: if isOwner(userId);

      // Nested collections - own data only
      match /{document=**} {
        allow read, write: if isOwner(userId);
      }
    }

    // Public exercise library - read-only
    match /exercises/{exerciseId} {
      allow read: if true; // Public
      allow write: if false; // Only admins (via Cloud Functions)
    }

    // Mikroklub challenges - members can read
    match /challenges/{challengeId} {
      allow read: if isAuthenticated() &&
        request.auth.uid in resource.data.memberIds;
      allow write: if false; // Only via Cloud Functions
    }
  }
}
```

**Emulator Testing Setup:**
```bash
# Install Firebase Emulators
firebase init emulators  # Select Firestore, Auth, Storage

# firebase.json
{
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "auth": {
      "port": 9099
    }
  }
}

# Start emulators
firebase emulators:start

# Run tests
flutter test --dart-define=USE_FIREBASE_EMULATOR=true
```

**Estimated Effort:** 3 SP (complex rules + emulator setup + tests)
**Priority:** MEDIUM - Needed before social features, not critical for MVP

---

### 4. Cloud Functions Setup

**Original Scope:** Enable Cloud Functions with Node.js 18 runtime
**Simplified to:** Skip Cloud Functions in Sprint 1 (not needed yet)
**Reason for Deferral:** No features require Cloud Functions in Sprint 1-2
**Deferred to:** Epic 7 (when implementing weekly reports, badge awards via Cloud Functions)

**When Needed:**
- Weekly report generation (Epic 7, FR35)
- Badge award triggers (Epic 7, FR31)
- Referral attribution (Epic 9, FR48)

**Estimated Effort:** 2 SP (when first Cloud Function is implemented)
**Priority:** LOW - Deferred until Epic 7

---

## Deferred from Story 1.3: Drift Database

### 1. Additional Database Tables (9 tables)

**Original Scope:** 14 tables created in Sprint 1
**Simplified to:** 5 critical tables (Users, Exercises, WorkoutSessions, WorkoutExercises, WorkoutSets)
**Reason for Deferral:** 9 tables not needed until respective epics are implemented
**Deferred to:** Sprints 2-4 (add incrementally when needed)

**Deferred Tables:**

| Table | Needed For | Estimated Sprint | Effort |
|-------|-----------|------------------|--------|
| **UserPreferences** | Epic 2 (Settings), FR40-44 | Sprint 2 | 1 SP |
| **BodyMeasurements** | Epic 6 (Progress Tracking), FR24, FR26 | Sprint 4 | 1 SP |
| **DailyCheckIns** | Epic 7 (Habits), FR30, FR33-34 | Sprint 5 | 1 SP |
| **Achievements** | Epic 7 (Badges), FR31 | Sprint 5 | 0.5 SP |
| **UserAchievements** | Epic 7 (Badges), FR31 | Sprint 5 | 0.5 SP |
| **WorkoutTemplates** | Epic 8 (Templates), FR36-39 | Sprint 6 | 1 SP |
| **TemplateExercises** | Epic 8 (Templates), FR36-39 | Sprint 6 | 0.5 SP |
| **Friendships** | Epic 9 (Social), FR49 | Sprint 7 | 1 SP |
| **Referrals** | Epic 9 (Social), FR48 | Sprint 7 | 0.5 SP |

**Total Deferred Effort:** ~7 SP (spread across Sprints 2-7)

**Implementation Strategy:**
- Add tables incrementally as epics are implemented
- Each table addition requires:
  1. Update schema version (v1 → v2 → v3...)
  2. Implement `onUpgrade` migration in Drift
  3. Create corresponding DAO
  4. Write unit tests
  5. Update `docs/database-migrations.md`

**Priority:** MEDIUM - Add when needed for each epic

---

### 2. Exercise Library Expansion (400 more exercises)

**Original Scope:** 500+ exercises pre-seeded
**Simplified to:** 100 common exercises
**Reason for Deferral:** 100 exercises sufficient for testing/demos, reduces Sprint 1 effort by 4-6 hours
**Deferred to:** Sprint 2

**Implementation Details (when added):**
1. Research/find open-source exercise database (e.g., wger.de REST API)
2. Convert to GymApp JSON format
3. Create `assets/data/exercises_full.json` (500+ exercises)
4. Load on app update (migration from 100 → 500)
5. Update seeding logic to check for duplicates

**Estimated Effort:** 2 SP (research + data conversion + testing)
**Priority:** LOW-MEDIUM - Nice to have, not blocking any features

**Alternative:** Allow users to create custom exercises (FR in backlog), defer full library indefinitely

---

### 3. Persistent File Storage (Currently In-Memory)

**Original Scope:** Drift database stored in persistent file (`gymapp.db`)
**Simplified to:** In-memory database for Sprint 1 testing
**Reason for Deferral:** In-memory is faster for testing, no data loss concerns (no real users)
**Deferred to:** Sprint 2 (when testing offline sync and data persistence)

**Implementation Details (when added):**

**Change 1 line in `AppDatabase`:**
```dart
// FROM (Sprint 1 - in-memory):
static QueryExecutor _openConnection() {
  return NativeDatabase.memory();
}

// TO (Sprint 2 - persistent file):
static QueryExecutor _openConnection() {
  return NativeDatabase.createQueryExecutor('gymapp.db');
}
```

**Estimated Effort:** 0.5 SP (1-2 hours including testing)
**Priority:** MEDIUM - Needed before testing offline sync in Epic 4

---

## Summary

**Total Deferred Scope:** ~18 SP (spread across Sprints 2-7)
**Sprint 1 Simplified Scope:** 11 SP (from 16 SP)
**Sprint 1 Buffer Gained:** 5 SP

**Deferred Items by Priority:**

| Priority | Item | Sprint | Effort |
|----------|------|--------|--------|
| **HIGH** | Firebase Cost Alerts | Pre-prod | 0.5 SP |
| **MEDIUM** | Separate Firebase projects (dev/staging/prod) | Pre-prod | 2 SP |
| **MEDIUM** | UserPreferences table | Sprint 2 | 1 SP |
| **MEDIUM** | Persistent file storage | Sprint 2 | 0.5 SP |
| **MEDIUM** | Complex Firestore security rules | Sprint 2-3 | 3 SP |
| **LOW-MEDIUM** | Exercise library expansion (100 → 500) | Sprint 2 | 2 SP |
| **LOW** | Build flavors | Sprint 2 (if needed) | 3 SP |
| **LOW** | Cloud Functions setup | Epic 7 | 2 SP |
| **LOW** | 8 additional database tables | Sprints 2-7 | 7 SP |

**Recommendation for Sprint 2:**
- Focus on completing Epic 1 remaining stories (1.4-1.8): 16 SP
- Add high-priority deferred items:
  - UserPreferences table (1 SP)
  - Persistent file storage (0.5 SP)
  - Exercise library expansion (2 SP)
- **Total Sprint 2 Estimated:** ~20 SP

---

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**Status:** TRACKING
