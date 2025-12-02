# Epic Technical Specification: Core Platform Foundation

Date: 2025-01-16
Author: Mariusz
Epic ID: epic-1
Status: Draft

---

## Overview

Epic 1 establishes the foundational infrastructure for the LifeOS ecosystem, providing core authentication, data synchronization, and GDPR compliance capabilities that all subsequent modules depend on. This epic implements the critical "plumbing" that enables offline-first functionality, secure multi-device sync, and user data privacy controls.

The epic delivers 6 user stories covering account creation, session management, password recovery, profile management, cross-device sync, and complete GDPR data export/deletion workflows. Completion of this epic unblocks parallel development of the three MVP modules (Life Coach, Fitness, Mind).

## Objectives and Scope

**In Scope:**
- ✅ Multi-provider authentication (Email, Google OAuth, Apple Sign-In)
- ✅ Secure session management with 30-day persistence
- ✅ Password reset flow with email verification
- ✅ User profile management (name, email, avatar)
- ✅ Offline-first data sync across devices (<5s latency)
- ✅ GDPR compliance (data export ZIP, account deletion with 7-day grace period)
- ✅ Supabase Auth integration with RLS policies
- ✅ Drift (SQLite) local database for offline support
- ✅ Conflict resolution (last-write-wins based on timestamp)

**Out of Scope (Deferred to later epics):**
- ❌ Biometric authentication (Face ID, TouchID) - P1 feature
- ❌ Two-factor authentication (2FA) - P1 feature
- ❌ Social profile import (contacts, photos) - P2 feature
- ❌ Account migration from other platforms - P2 feature
- ❌ Multi-account switching - P2 feature

## System Architecture Alignment

**Aligned to Architecture Decisions:**
- **D1 (Hybrid Architecture):** Authentication implemented in `lib/core/auth/`, shared across all feature modules
- **D2 (Shared PostgreSQL Schema):** Core `users` table (Supabase Auth built-in) + custom user metadata tables
- **D3 (Hybrid Sync):** Write-through cache pattern - save to Drift first (instant feedback), sync to Supabase opportunistically
- **D5 (Client-Side E2EE):** Foundation for future E2EE implementation (flutter_secure_storage for encryption keys)
- **D11 (Background Sync):** Opportunistic sync strategy with WiFi preference and exponential backoff retry

**Architecture Components Used:**
- **Frontend:** Flutter 3.38+, Riverpod 3.0, Drift (SQLite), flutter_secure_storage
- **Backend:** Supabase (Auth, PostgreSQL, Storage, Realtime)
- **Security:** RLS policies, HTTPS with certificate pinning, secure token storage

**Constraints:**
- Session tokens stored in flutter_secure_storage (iOS Keychain, Android KeyStore)
- Offline mode must work for minimum 10 seconds without internet (NFR-P4)
- Auth flow must complete in <2 seconds for optimal UX (NFR-P2)

---

## Detailed Design

### Services and Modules

| Service/Module | Responsibilities | Inputs | Outputs | Owner |
|----------------|-----------------|--------|---------|-------|
| **AuthService** | Handle auth flows, manage sessions | Email, password, OAuth tokens | AuthResult<User>, Session | Core Team |
| **UserRepository** | CRUD operations for user profiles | User model, avatar file | Result<User> | Core Team |
| **SyncService** | Orchestrate offline-first sync | SyncQueue items | SyncStatus | Core Team |
| **ProfileProvider** | State management for user profile | User ID | AsyncValue<User> | Core Team |
| **DataExportService** | GDPR data export generation | User ID | ZIP file (JSON + CSV) | Core Team |
| **AccountDeletionService** | Handle account deletion flow | User ID, password confirmation | DeletionScheduleResult | Core Team |

**Service Dependencies:**
```
AuthService → Supabase Auth API
UserRepository → Drift (local) + Supabase (remote)
SyncService → UserRepository + Drift + Supabase Realtime
ProfileProvider → UserRepository
DataExportService → ALL user tables (workouts, moods, etc.)
AccountDeletionService → Supabase Auth + ALL user tables
```

---

### Data Models and Contracts

#### User Profile Model (Domain Layer)
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,           // UUID from Supabase Auth
    required String email,
    required String name,
    String? avatarUrl,           // Supabase Storage URL
    DateTime? emailVerifiedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

#### Auth Result (Domain Layer)
```dart
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult.success(User user, Session session) = AuthSuccess;
  const factory AuthResult.failure(AuthException exception) = AuthFailure;
}

sealed class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Invalid email or password');
}

class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException() : super('Please verify your email first');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Password must be at least 8 characters with 1 uppercase, 1 number, 1 special char');
}
```

#### Sync Queue Item (Data Layer)
```dart
@freezed
class SyncQueueItem with _$SyncQueueItem {
  const factory SyncQueueItem({
    required String id,
    required String tableName,
    required String operation,    // 'insert', 'update', 'delete'
    required Map<String, dynamic> data,
    required SyncPriority priority,
    required DateTime createdAt,
    int retryCount = 0,
  }) = _SyncQueueItem;
}

enum SyncPriority {
  critical,    // Auth changes, profile updates (sync immediately)
  high,        // User actions (workout logs, mood entries)
  normal,      // Analytics events, non-critical updates
}
```

---

### APIs and Interfaces

#### AuthService Interface
```dart
abstract class AuthService {
  /// Register new user with email + password
  /// Throws: [WeakPasswordException], [EmailAlreadyExistsException]
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Login with email + password
  /// Throws: [InvalidCredentialsException], [EmailNotVerifiedException]
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  /// Login with Google OAuth 2.0
  /// Throws: [OAuthCancelledException], [NetworkException]
  Future<AuthResult> signInWithGoogle();

  /// Login with Apple Sign-In
  /// Throws: [OAuthCancelledException], [NetworkException]
  Future<AuthResult> signInWithApple();

  /// Sign out current user
  Future<void> signOut();

  /// Send password reset email
  /// Returns: true if email sent, false if email not found
  Future<bool> sendPasswordResetEmail(String email);

  /// Get current session (null if not authenticated)
  Future<Session?> getCurrentSession();

  /// Listen to auth state changes
  Stream<User?> get authStateChanges;
}
```

#### UserRepository Interface
```dart
abstract class UserRepository {
  /// Get user profile by ID
  Future<Result<User>> getUserProfile(String userId);

  /// Update user profile
  /// Throws: [ValidationException] if data invalid
  Future<Result<User>> updateProfile({
    required String userId,
    String? name,
    String? email,       // Triggers re-verification if changed
  });

  /// Upload and update avatar
  /// Throws: [FileTooLargeException] if >5MB, [InvalidFileTypeException]
  Future<Result<User>> updateAvatar({
    required String userId,
    required File avatarFile,
  });

  /// Change password (requires current password)
  /// Throws: [InvalidPasswordException], [WeakPasswordException]
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
```

#### SyncService Interface
```dart
abstract class SyncService {
  /// Add item to sync queue
  void enqueueSyncItem(SyncQueueItem item);

  /// Trigger manual sync (force immediate sync)
  Future<SyncResult> syncNow();

  /// Get current sync status
  SyncStatus get status;

  /// Listen to sync status changes
  Stream<SyncStatus> get statusStream;

  /// Clear sync queue (danger: only for testing)
  Future<void> clearQueue();
}

enum SyncStatus {
  idle,           // No sync in progress
  syncing,        // Active sync
  offline,        // No network available
  error,          // Sync failed (will retry)
}

class SyncResult {
  final int itemsSynced;
  final int itemsFailed;
  final List<SyncError> errors;

  bool get success => itemsFailed == 0;
}
```

---

### Workflows and Sequencing

#### Workflow 1: User Registration (Story 1.1)
```
1. User taps "Sign up with email"
   ↓
2. UI shows registration form (email, password, confirm password)
   ↓
3. User fills form and taps "Create Account"
   ↓
4. Client validates:
   - Email format (RFC 5322 regex)
   - Password strength (min 8 chars, 1 uppercase, 1 number, 1 special)
   - Passwords match
   ↓
5. AuthService.signUpWithEmail() called
   ↓
6. Supabase Auth creates user account
   ↓
7. Verification email sent (link expires in 24h)
   ↓
8. User profile created in users table (Drift + Supabase)
   ↓
9. Session token stored in flutter_secure_storage
   ↓
10. Navigate to Onboarding flow
    ↓
11. DONE ✅
```

#### Workflow 2: Session Management (Story 1.2)
```
1. App startup
   ↓
2. AuthService.getCurrentSession() checks flutter_secure_storage
   ↓
3. If session exists AND not expired (30 days):
   - Auto-refresh token if <7 days remaining
   - Load user profile from Drift (offline-first)
   - Navigate to Home screen
   ↓
4. If session expired OR doesn't exist:
   - Navigate to Login screen
   ↓
5. User authentication flow...
   ↓
6. On successful login:
   - Store session token (expires in 30 days)
   - Set "Remember me" flag (default: true)
   ↓
7. Background session check (every app resume):
   - Verify token still valid
   - Auto-refresh if needed
   ↓
8. DONE ✅
```

#### Workflow 3: Offline-First Sync (Story 1.5)
```
1. User completes workout (offline)
   ↓
2. FitnessRepository.saveWorkout() → Drift insert
   ↓ (instant, <100ms)
3. UI shows success feedback immediately
   ↓
4. SyncService.enqueueSyncItem(workout, priority: HIGH)
   ↓
5. SyncService checks network:
   - If WiFi available: Start sync immediately
   - If cellular: Check user preference (WiFi-only mode)
   - If offline: Queue persists, retry when online
   ↓
6. Sync attempt:
   - Supabase insert → workouts table
   - On success: Remove from queue
   - On failure: Retry with exponential backoff (1s, 2s, 4s, 8s, ...)
   ↓
7. Conflict detection (if data changed on another device):
   - Compare timestamps (updated_at)
   - Last-write-wins (newer timestamp overwrites)
   - Notify user if conflict detected
   ↓
8. DONE ✅
```

#### Workflow 4: GDPR Data Export (Story 1.6)
```
1. User navigates to Profile → Data & Privacy
   ↓
2. Taps "Export All Data"
   ↓
3. Password confirmation modal (security check)
   ↓
4. DataExportService.generateExport(userId) called
   ↓
5. Service queries ALL user tables:
   - workouts, exercises, meditations, journal_entries
   - goals, daily_plans, mood_logs, stress_logs
   - user profile, settings, subscriptions
   ↓
6. Generate JSON files (structured data) + CSV files (flat data)
   ↓
7. Create ZIP archive with structure:
   /export-{user_id}-{timestamp}.zip
     /json/
       workouts.json
       meditations.json
       ...
     /csv/
       workouts.csv
       meditations.csv
       ...
     /metadata.json (export info, timestamp, schema version)
   ↓
8. Upload ZIP to Supabase Storage (private bucket)
   ↓
9. Generate signed URL (expires in 7 days)
   ↓
10. Send email with download link
    ↓
11. Show confirmation: "Export ready! Check your email."
    ↓
12. DONE ✅
```

---

## Non-Functional Requirements

### Performance

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-P2 | Cold start time | <2s | Flutter skeleton UI, minimal init, cached auth state |
| NFR-P4 | Offline operation | <10s (target: <100ms) | Write-through cache (Drift), instant local writes |
| NFR-P5 | UI response time | <100ms | Riverpod optimistic updates, local-first reads |

**Performance Validation:**
- Auth check: 50ms (read from flutter_secure_storage)
- Load user profile: 20ms (Drift query)
- Save profile update: 10ms (Drift write) + background sync
- **Total cold start: ~500ms** ✅ (well under 2s target)

### Security

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-S1 | E2EE preparation | Foundation ready | flutter_secure_storage for encryption keys, AES-256-GCM ready |
| NFR-S2 | GDPR compliance | Full compliance | RLS policies, export/delete endpoints, consent tracking |
| NFR-S3 | Multi-device sync | <5s latency | Supabase Realtime WebSocket subscriptions |

**Security Measures:**
- ✅ Session tokens stored in secure storage (iOS Keychain, Android KeyStore)
- ✅ HTTPS with certificate pinning
- ✅ RLS policies enforce user data isolation
- ✅ Password validation: min 8 chars, 1 uppercase, 1 number, 1 special char
- ✅ Email verification required before account activation
- ✅ Password reset link expires in 1 hour

**Threat Mitigation:**
- Brute force: Rate limiting on Supabase Auth (5 attempts per 15 minutes)
- MITM attack: HTTPS + certificate pinning
- Token theft: Secure storage + auto-refresh mechanism
- Account takeover: Email verification + password strength requirements

### Reliability/Availability

| NFR ID | Requirement | Target | Implementation Strategy |
|--------|-------------|--------|-------------------------|
| NFR-R1 | System uptime | 99.5% | Supabase SLA 99.9%, offline-first fallback |
| NFR-R3 | Data loss prevention | <0.1% | Sync queue with retry, local persistence |

**Reliability Patterns:**
- Exponential backoff retry (1s, 2s, 4s, 8s, 16s max)
- Circuit breaker pattern (stop retrying after 5 consecutive failures, alert user)
- Graceful degradation (app fully functional offline, sync when network available)

### Observability

**Logging:**
```dart
Logger.log(
  'User registration successful',
  level: LogLevel.info,
  metadata: {
    'user_id': user.id,
    'auth_provider': 'email',
    'email_verified': false,
  },
);
```

**Metrics to Track:**
- Auth success/failure rate
- Session persistence rate (how many users stay logged in vs re-login)
- Sync queue length (offline items waiting)
- Sync success/failure rate
- Avatar upload success rate
- Data export request count
- Account deletion count

**Alerts:**
- 🚨 Auth failure rate >5% (potential service issue)
- 🚨 Sync queue length >100 items (sync service degraded)
- 🚨 Data export failures (GDPR compliance risk)

---

## Dependencies and Integrations

### Flutter Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # Local Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24

  # Supabase
  supabase_flutter: ^2.5.0

  # Secure Storage
  flutter_secure_storage: ^9.2.2

  # OAuth
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0

  # Models
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Utilities
  logger: ^2.3.0

dev_dependencies:
  build_runner: ^2.4.11
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^3.0.0
  mockito: ^5.4.4
  flutter_test:
    sdk: flutter
```

### External Service Integrations

| Service | Purpose | Version/Endpoint | Credentials |
|---------|---------|------------------|-------------|
| **Supabase Auth** | Authentication | v2 API | API URL + anon key (env vars) |
| **Supabase Database** | PostgreSQL + RLS | v15+ | Auto-authenticated via session |
| **Supabase Storage** | Avatar uploads, data export ZIPs | v1 API | Auto-authenticated via session |
| **Supabase Realtime** | Multi-device sync | WebSocket | Auto-authenticated via session |
| **Google OAuth 2.0** | Social login | OAuth 2.0 | Client ID (Android), iOS URL scheme |
| **Apple Sign-In** | Social login | AuthenticationServices | Bundle ID, Team ID |

### Supabase Configuration

**Environment Variables:**
```dart
// lib/core/config/env_config.dart
class EnvConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Validate on app startup
  static void validate() {
    assert(supabaseUrl.isNotEmpty, 'SUPABASE_URL not set');
    assert(supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY not set');
  }
}
```

**Build command:**
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## Acceptance Criteria (Authoritative)

### Story 1.1: User Account Creation
1. ✅ User can register with email + password (min 8 chars, 1 uppercase, 1 number, 1 special char)
2. ✅ User can register with Google OAuth 2.0 (Android + iOS)
3. ✅ User can register with Apple Sign-In (iOS only)
4. ✅ Email verification sent after registration (link expires in 24h)
5. ✅ User profile created with default settings (name from email, placeholder avatar)
6. ✅ User redirected to onboarding flow after successful registration
7. ✅ Error handling: Email already exists, invalid email format, weak password
8. ✅ Supabase Auth integration working (session management)

### Story 1.2: User Login & Session Management
1. ✅ User can log in with email + password
2. ✅ User can log in with Google OAuth 2.0
3. ✅ User can log in with Apple Sign-In
4. ✅ Session persists for 30 days of inactivity
5. ✅ User auto-logged in on app restart if session valid
6. ✅ User can log out manually (session cleared from secure storage)
7. ✅ Error handling: Invalid credentials, account not verified, session expired
8. ✅ "Remember me" checkbox (optional, defaults to true)

### Story 1.3: Password Reset Flow
1. ✅ User can request password reset from login screen
2. ✅ Email sent with reset link (expires in 1 hour)
3. ✅ Reset link opens password change screen (deep link)
4. ✅ User can set new password (same validation as registration)
5. ✅ User auto-logged in after successful password reset
6. ✅ Old password invalidated after reset
7. ✅ Error handling: Email not found, link expired, weak new password

### Story 1.4: User Profile Management
1. ✅ User can update name
2. ✅ User can update email (requires re-verification)
3. ✅ User can update avatar (upload from gallery or camera, max 5MB, JPG/PNG)
4. ✅ User can change password (requires current password confirmation)
5. ✅ Changes saved to Supabase and synced across devices
6. ✅ Avatar uploaded to Supabase Storage (max 5MB, compressed to 512x512px)
7. ✅ Error handling: Invalid email, weak password, upload failed (file too large, invalid type)

### Story 1.5: Data Sync Across Devices
1. ✅ Workout data synced via Supabase Realtime (<5s latency)
2. ✅ Mood logs synced across devices
3. ✅ Goals synced across devices
4. ✅ Meditation progress synced across devices
5. ✅ Sync works offline (queued, synced when online)
6. ✅ Conflict resolution: Last-write-wins based on updated_at timestamp
7. ✅ Sync status indicator in app (syncing/synced/offline icon in navigation bar)

### Story 1.6: GDPR Compliance (Data Export & Deletion)
1. ✅ User can request data export from Profile → Data & Privacy
2. ✅ Export generates ZIP file (JSON + CSV formats)
3. ✅ Export includes: workouts, mood logs, goals, meditations, journal entries, account info
4. ✅ Export download link sent via email (expires in 7 days)
5. ✅ User can request account deletion (requires password confirmation)
6. ✅ Account deletion removes all data within 7 days (GDPR 7-day grace period)
7. ✅ Deletion is irreversible (clear warning shown with "I understand" checkbox)
8. ✅ Deleted data purged from backups after 30 days

---

## Traceability Mapping

| Acceptance Criteria | Spec Section | Component/API | Test Strategy |
|---------------------|--------------|---------------|---------------|
| Story 1.1 AC1-3 | APIs → AuthService | signUpWithEmail(), signInWithGoogle(), signInWithApple() | Unit: Mock Supabase Auth, Integration: E2E registration flow |
| Story 1.1 AC4 | Workflows → Registration | Supabase Auth email service | Integration: Check email sent (test email provider) |
| Story 1.1 AC7 | Data Models → AuthException | InvalidCredentialsException, WeakPasswordException | Unit: Exception handling tests |
| Story 1.2 AC1-4 | APIs → AuthService | getCurrentSession(), authStateChanges stream | Unit: Mock session storage, Widget: Login screen state |
| Story 1.2 AC5 | Workflows → Session Management | flutter_secure_storage persistence | Integration: App restart test |
| Story 1.3 AC1-3 | APIs → AuthService | sendPasswordResetEmail() | Integration: Deep link handling |
| Story 1.4 AC1-4 | APIs → UserRepository | updateProfile(), updateAvatar(), changePassword() | Unit: Repository tests, Integration: Profile update flow |
| Story 1.4 AC6 | Data Models → User | avatarUrl field | Integration: Image upload + compression |
| Story 1.5 AC1-7 | APIs → SyncService | enqueueSyncItem(), syncNow(), statusStream | Unit: Sync queue logic, Integration: Multi-device sync test |
| Story 1.5 AC6 | Workflows → Offline Sync | Conflict resolution (last-write-wins) | Integration: Concurrent edit simulation |
| Story 1.6 AC1-4 | Services → DataExportService | generateExport() | Integration: Full export test (all tables) |
| Story 1.6 AC5-8 | Services → AccountDeletionService | scheduleAccountDeletion() | Integration: Deletion flow + cascade test |

---

## Risks, Assumptions, Open Questions

### Risks

| Risk ID | Description | Probability | Impact | Mitigation | Owner |
|---------|-------------|-------------|--------|------------|-------|
| **RISK-E1-001** | Supabase Auth rate limiting blocks legitimate users | Low | Medium | Implement client-side rate limiting UI (show CAPTCHA after 3 failed attempts) | Core Team |
| **RISK-E1-002** | Avatar upload fails due to network timeout | Medium | Low | Implement retry with exponential backoff, show upload progress | Core Team |
| **RISK-E1-003** | Sync conflicts cause data loss | Low | High | Thorough testing of conflict resolution, user notification on conflicts | Core Team |
| **RISK-E1-004** | Google/Apple OAuth changes break social login | Low | Medium | Pin OAuth library versions, monitor provider changelogs | Core Team |
| **RISK-E1-005** | Data export ZIP exceeds email attachment limits | Low | Low | Upload to Supabase Storage instead, send download link | Core Team |

### Assumptions

1. **Supabase reliability:** Assuming Supabase achieves 99.9% uptime SLA as advertised
2. **OAuth provider stability:** Google and Apple OAuth APIs remain stable and backwards compatible
3. **Email deliverability:** Verification and password reset emails successfully delivered (not caught by spam filters)
4. **User device storage:** Devices have sufficient storage for Drift database (estimated 10-50MB for typical user)
5. **Network availability:** Users will eventually connect to internet for sync (not permanently offline)

### Open Questions

1. **Q:** Should we implement automatic email re-verification if user doesn't verify within 7 days?
   - **Answer needed from:** Product Owner
   - **Impact:** User activation flow, potential abandoned accounts

2. **Q:** What should happen to data export ZIPs after 7 days? Auto-delete or keep?
   - **Answer needed from:** Legal/Privacy team
   - **Impact:** Storage costs, GDPR compliance

3. **Q:** Should account deletion be immediate or have a grace period (7 days)?
   - **Decision:** 7-day grace period (per GDPR best practices, see Story 1.6 AC6)

4. **Q:** How to handle users who delete account but still have active subscription?
   - **Answer needed from:** Product + Billing team
   - **Impact:** Refund policy, subscription cancellation flow

---

## Test Strategy Summary

### Test Pyramid (70/20/10)

**Unit Tests (70%):**
- AuthService: All auth methods (email, Google, Apple), error cases
- UserRepository: CRUD operations, validation logic
- SyncService: Queue management, conflict resolution algorithm
- DataExportService: ZIP generation, data serialization
- Validators: Email format, password strength
- Exception handling: All custom exceptions

**Widget Tests (20%):**
- Login screen: Form validation, error display, loading states
- Registration screen: Multi-step flow, password visibility toggle
- Profile screen: Edit mode, avatar upload preview
- Sync status indicator: Icon changes based on SyncStatus

**Integration Tests (10%):**
- E2E registration flow: Create account → Verify email → Login
- E2E password reset: Request reset → Click email link → Set new password
- Multi-device sync: Simulate 2 devices editing same data
- Data export: Generate ZIP → Verify all tables included
- Account deletion: Schedule deletion → Verify cascade delete

### Test Coverage Targets
- **Unit tests:** >80% code coverage
- **Widget tests:** All user-facing screens
- **Integration tests:** All critical user journeys

### Testing Tools
- flutter_test (unit + widget)
- mockito (mocking)
- integration_test (E2E)
- golden_toolkit (screenshot tests)

### Example Test Case

```dart
// Unit test: AuthService
test('signUpWithEmail should throw WeakPasswordException for weak password', () async {
  // Arrange
  final authService = AuthService(supabaseClient: mockSupabase);
  const email = 'test@example.com';
  const weakPassword = '12345';  // No uppercase, no special char

  // Act & Assert
  expect(
    () => authService.signUpWithEmail(email: email, password: weakPassword),
    throwsA(isA<WeakPasswordException>()),
  );
});

// Integration test: Registration flow
testWidgets('complete registration flow should create account and navigate to onboarding', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());

  // Act
  await tester.tap(find.text('Sign up with email'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password_field')), 'Test123!@');
  await tester.enterText(find.byKey(Key('confirm_password_field')), 'Test123!@');

  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Welcome to LifeOS'), findsOneWidget);  // Onboarding screen
  verify(mockAuthService.signUpWithEmail(any, any)).called(1);
});
```

---

## Implementation Checklist

**Phase 1: Setup (1 day)**
- [ ] Add dependencies to pubspec.yaml
- [ ] Configure Supabase (URL, anon key)
- [ ] Setup flutter_secure_storage
- [ ] Configure OAuth (Google, Apple)
- [ ] Create core directory structure

**Phase 2: Authentication (2 days)**
- [ ] Implement AuthService (email, Google, Apple)
- [ ] Create auth screens (login, registration, password reset)
- [ ] Setup session management
- [ ] Add auth state provider (Riverpod)
- [ ] Write unit tests for AuthService

**Phase 3: User Profile (1 day)**
- [ ] Implement UserRepository
- [ ] Create profile screen with edit mode
- [ ] Add avatar upload with compression
- [ ] Write unit tests for UserRepository

**Phase 4: Sync Infrastructure (2 days)**
- [ ] Setup Drift local database
- [ ] Implement SyncService with queue
- [ ] Add conflict resolution logic
- [ ] Test multi-device sync
- [ ] Add sync status indicator UI

**Phase 5: GDPR (1 day)**
- [ ] Implement DataExportService
- [ ] Create data export ZIP generator
- [ ] Add account deletion flow
- [ ] Test export includes all user data

**Phase 6: Testing & Polish (1 day)**
- [ ] Write integration tests
- [ ] Test all error scenarios
- [ ] Add loading states and error messages
- [ ] Accessibility audit
- [ ] Performance profiling

**Total Estimate: 8 days (1.6 sprints at 5 days/sprint)**

---

**Epic Status:** Ready for Implementation ✅
**Dependencies:** None (foundation epic)
**Blocks:** Epic 2, 3, 4, 5, 6, 7, 8, 9 (all subsequent epics)

---

_Tech Spec generated by Bob (BMAD Scrum Master) on 2025-01-16_
