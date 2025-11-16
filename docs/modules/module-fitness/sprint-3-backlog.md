# Sprint 3 Backlog - Complete Epic 1 + Begin Authentication

**Sprint Goal:** Complete Epic 1 technical foundation with error handling and analytics, then establish core authentication with email/password signup and persistent login sessions.

**Sprint Duration:** 8 days (Jan 29 - Feb 5, 2025)
**Sprint Capacity:** 16 SP (2 SP/day for solo developer)
**Sprint Focus:** Epic 1 completion (Stories 1.7-1.8) + Epic 2 start (Stories 2.1, 2.4)

**Created:** 2025-01-15
**Status:** PLANNED

---

## Sprint 3 Scope

**Epic 1: Technical Foundation (Final Stories)**

| Story | Description | Story Points | Status |
|-------|-------------|--------------|--------|
| 1.7 | Error Handling and Logging Framework | 3 SP | Planned |
| 1.8 | App Performance Monitoring and Analytics | 5 SP | Planned |

**Epic 2: User Authentication (Core Stories)**

| Story | Description | Story Points | Status |
|-------|-------------|--------------|--------|
| 2.1 | Email/Password Authentication | 5 SP | Planned |
| 2.4 | Login Flow with Persistent Sessions | 3 SP | Planned |

**Total Sprint 3 Scope:** 16 SP

---

## Deferred to Sprint 4

The following Epic 2 stories are deferred to Sprint 4 to maintain realistic sprint capacity:

| Story | Description | Story Points | Rationale |
|-------|-------------|--------------|-----------|
| 2.2 | Google Sign-In Integration | 2 SP | Social auth not critical for MVP testing |
| 2.3 | Apple Sign-In Integration (iOS) | 2 SP | Social auth not critical for MVP testing |
| 2.5 | Password Reset Flow | 2 SP | Can test with email/password first |
| 2.6 | GDPR Compliance | 5 SP | Important but not blocking initial auth testing |

**Total Deferred:** 11 SP

---

## Story 1.7: Error Handling and Logging Framework

**Story Points:** 3 SP
**Prerequisites:** Story 1.2 (Firebase configured)
**Priority:** HIGH (critical for production readiness)

**User Story:**

**As a** developer,
**I want** comprehensive error tracking and logging,
**So that** bugs are caught early and user issues can be diagnosed.

### Acceptance Criteria

**Given** the app will encounter errors in production
**When** implementing error handling
**Then** Firebase Crashlytics integrated:
- `firebase_crashlytics` package configured
- Fatal crashes automatically reported with stack traces
- Non-fatal errors logged with `FirebaseCrashlytics.instance.recordError()`
- User IDs attached to crash reports (for debugging without PII)

**And** logging framework established:
- `logger` package for structured logging
- Log levels: debug, info, warning, error, fatal
- Logs written to console (dev) and Firebase Analytics (prod)
- Sensitive data (passwords, tokens) never logged

**And** error boundaries:
- `FlutterError.onError` catches Flutter framework errors
- `PlatformDispatcher.instance.onError` catches async errors
- User-friendly error messages shown (not raw stack traces)
- Retry mechanisms for network failures

**And** monitoring alerts:
- Crashlytics alerts configured for spike in crash rate (>1% sessions)
- Critical error types flagged for immediate attention
- Weekly error reports reviewed

### Tasks

**Day 1-2: Firebase Crashlytics Integration (1.5 SP)**

1. **Add Crashlytics Package**
   ```bash
   flutter pub add firebase_crashlytics
   ```

2. **Configure Crashlytics in main.dart**
   ```dart
   // lib/main.dart
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';
   import 'dart:async';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Pass all uncaught errors from the framework to Crashlytics
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

     // Pass all uncaught asynchronous errors to Crashlytics
     PlatformDispatcher.instance.onError = (error, stack) {
       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
       return true;
     };

     runApp(const MyApp());
   }
   ```

3. **Add User Context to Crash Reports**
   ```dart
   // lib/features/auth/providers/auth_provider.dart
   class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
     Future<void> _setCrashlyticsUser(User user) async {
       await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
       await FirebaseCrashlytics.instance.setCustomKey('email', user.email ?? 'unknown');
       await FirebaseCrashlytics.instance.setCustomKey('signup_date', user.metadata.creationTime?.toIso8601String() ?? 'unknown');
     }
   }
   ```

4. **Test Crashlytics (Force a Crash)**
   ```dart
   // Test button in dev mode
   if (AppConfig.isDev) {
     FirebaseCrashlytics.instance.crash(); // Forces test crash
   }
   ```

**Day 3: Logger Package Integration (0.5 SP)**

1. **Add Logger Package**
   ```bash
   flutter pub add logger
   ```

2. **Create AppLogger Service**
   ```dart
   // lib/core/services/app_logger.dart
   import 'package:logger/logger.dart';
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   class AppLogger {
     static final Logger _logger = Logger(
       filter: ProductionFilter(), // Only logs in debug mode
       printer: PrettyPrinter(
         methodCount: 2,
         errorMethodCount: 8,
         lineLength: 120,
         colors: true,
         printEmojis: true,
         printTime: true,
       ),
     );

     static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
       _logger.d(message, error: error, stackTrace: stackTrace);
     }

     static void info(String message, [dynamic error, StackTrace? stackTrace]) {
       _logger.i(message, error: error, stackTrace: stackTrace);
     }

     static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
       _logger.w(message, error: error, stackTrace: stackTrace);
       // Send warnings to Crashlytics as non-fatal
       if (error != null) {
         FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
       }
     }

     static void error(String message, [dynamic error, StackTrace? stackTrace]) {
       _logger.e(message, error: error, stackTrace: stackTrace);
       // Send errors to Crashlytics
       if (error != null) {
         FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
       }
     }

     static void fatal(String message, dynamic error, StackTrace? stackTrace) {
       _logger.f(message, error: error, stackTrace: stackTrace);
       // Send fatal errors to Crashlytics
       FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
     }
   }
   ```

3. **Add Logging to Key Operations**
   ```dart
   // Example: Logging in workout repository
   class WorkoutRepository {
     Future<WorkoutSession> createWorkoutSession() async {
       try {
         AppLogger.info('Creating new workout session');
         final session = await _database.createWorkoutSession();
         AppLogger.debug('Workout session created: ${session.id}');
         return session;
       } catch (e, stack) {
         AppLogger.error('Failed to create workout session', e, stack);
         rethrow;
       }
     }
   }
   ```

**Day 4: Error Boundaries and User-Friendly Messages (1 SP)**

1. **Create Custom Exception Types**
   ```dart
   // lib/core/exceptions/app_exceptions.dart

   /// Base exception for all app errors
   abstract class AppException implements Exception {
     final String message;
     final String? userMessage; // User-friendly message
     final dynamic originalError;

     AppException(this.message, {this.userMessage, this.originalError});

     @override
     String toString() => 'AppException: $message';
   }

   /// Network-related errors
   class NetworkException extends AppException {
     NetworkException(String message, {dynamic originalError})
         : super(
             message,
             userMessage: 'Connection failed. Please check your internet and try again.',
             originalError: originalError,
           );
   }

   /// Database errors
   class DatabaseException extends AppException {
     DatabaseException(String message, {dynamic originalError})
         : super(
             message,
             userMessage: 'Failed to save data. Please try again.',
             originalError: originalError,
           );
   }

   /// Authentication errors
   class AuthException extends AppException {
     AuthException(String message, {dynamic originalError})
         : super(
             message,
             userMessage: 'Authentication failed. Please try again.',
             originalError: originalError,
           );
   }

   /// Sync errors
   class SyncException extends AppException {
     SyncException(String message, {dynamic originalError})
         : super(
             message,
             userMessage: 'Sync failed. Your data is saved locally and will sync when connection is restored.',
             originalError: originalError,
           );
   }
   ```

2. **Create Error UI Widget**
   ```dart
   // lib/core/widgets/error_view.dart
   class ErrorView extends StatelessWidget {
     final String message;
     final VoidCallback? onRetry;

     const ErrorView({
       required this.message,
       this.onRetry,
       super.key,
     });

     @override
     Widget build(BuildContext context) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
               const SizedBox(height: 16),
               Text(
                 message,
                 textAlign: TextAlign.center,
                 style: Theme.of(context).textTheme.bodyLarge,
               ),
               if (onRetry != null) ...[
                 const SizedBox(height: 24),
                 AppButton(
                   label: 'Retry',
                   onPressed: onRetry!,
                   type: AppButtonType.primary,
                 ),
               ],
             ],
           ),
         ),
       );
     }
   }
   ```

3. **Implement Retry Logic for Network Failures**
   ```dart
   // lib/core/services/network_service.dart
   class NetworkService {
     static const int maxRetries = 3;
     static const Duration retryDelay = Duration(seconds: 2);

     static Future<T> retryOperation<T>(
       Future<T> Function() operation, {
       int retries = maxRetries,
     }) async {
       for (int attempt = 0; attempt < retries; attempt++) {
         try {
           return await operation();
         } catch (e) {
           if (attempt == retries - 1) rethrow;
           AppLogger.warning('Operation failed (attempt ${attempt + 1}/$retries), retrying...', e);
           await Future.delayed(retryDelay * (attempt + 1)); // Exponential backoff
         }
       }
       throw Exception('Retry logic failed unexpectedly');
     }
   }
   ```

**Day 4: Configure Monitoring Alerts (30 minutes)**

1. **Setup Crashlytics Alerts in Firebase Console**
   - Navigate to Crashlytics → Alerts
   - Create alert: "Crash Rate Spike"
     - Condition: Crash-free sessions < 99%
     - Notification: Email to developer
   - Create alert: "New Fatal Error"
     - Condition: New fatal error type detected
     - Notification: Email immediately

2. **Document Weekly Review Process**
   ```markdown
   # Error Monitoring Weekly Review

   **When:** Every Friday 4pm
   **Duration:** 30 minutes

   **Checklist:**
   1. Review Crashlytics dashboard
   2. Check top 5 crashes by volume
   3. Check new error types introduced this week
   4. Triage: High priority (affects >10 users), Medium (affects <10), Low (edge cases)
   5. Create tickets for high-priority fixes
   6. Review crash-free sessions metric (target: >99%)
   ```

### Definition of Done

- [ ] Firebase Crashlytics integrated and catching crashes
- [ ] Logger package configured with appropriate log levels
- [ ] Custom exception types created for domain errors
- [ ] Error boundaries implemented (FlutterError.onError, PlatformDispatcher.instance.onError)
- [ ] User-friendly error messages shown (no stack traces)
- [ ] Retry logic implemented for network failures
- [ ] Crashlytics alerts configured for spike in crash rate
- [ ] Test crash verified in Firebase Console
- [ ] Code reviewed
- [ ] Merged to main

---

## Story 1.8: App Performance Monitoring and Analytics

**Story Points:** 5 SP
**Prerequisites:** Story 1.2 (Firebase configured), Story 1.5 (Routing)
**Priority:** HIGH (needed for UX optimization and product decisions)

**User Story:**

**As a** product manager,
**I want** to track app performance and user behavior,
**So that** I can optimize UX and measure success metrics.

### Acceptance Criteria

**Given** the app needs performance and usage insights
**When** implementing analytics
**Then** Firebase Analytics configured:
- `firebase_analytics` package integrated
- Screen view tracking (automatic with go_router integration)
- Custom events logged (workout_completed, exercise_logged, streak_milestone, etc.)

**And** performance monitoring:
- Firebase Performance Monitoring enabled
- App startup time tracked (target: <2s per NFR-P1)
- Network request traces (Firestore queries, Cloud Functions)
- Custom traces for critical flows (workout_logging_flow, pattern_memory_query, chart_render)

**And** user properties tracked:
- `fitness_goal`, `experience_level`, `workout_frequency_preference`
- `days_since_signup`, `premium_user`

**And** privacy compliance:
- Analytics data anonymized (no PII)
- User consent obtained before tracking (GDPR)
- Analytics can be disabled in settings
- Data retention set to 14 months

### Tasks

**Day 5: Firebase Analytics Integration (1.5 SP)**

1. **Add Analytics Packages**
   ```bash
   flutter pub add firebase_analytics
   ```

2. **Setup Analytics Provider**
   ```dart
   // lib/core/providers/analytics_provider.dart
   import 'package:firebase_analytics/firebase_analytics.dart';
   import 'package:riverpod_annotation/riverpod_annotation.dart';

   part 'analytics_provider.g.dart';

   @riverpod
   FirebaseAnalytics analytics(AnalyticsRef ref) {
     return FirebaseAnalytics.instance;
   }

   @riverpod
   FirebaseAnalyticsObserver analyticsObserver(AnalyticsObserverRef ref) {
     final analytics = ref.watch(analyticsProvider);
     return FirebaseAnalyticsObserver(analytics: analytics);
   }
   ```

3. **Integrate with go_router for Screen Tracking**
   ```dart
   // lib/core/providers/router_provider.dart
   @riverpod
   GoRouter router(RouterRef ref) {
     final analyticsObserver = ref.watch(analyticsObserverProvider);

     return GoRouter(
       observers: [analyticsObserver], // Automatic screen view tracking
       routes: [
         // ... routes
       ],
     );
   }
   ```

4. **Create Analytics Service**
   ```dart
   // lib/core/services/analytics_service.dart
   import 'package:firebase_analytics/firebase_analytics.dart';

   class AnalyticsService {
     final FirebaseAnalytics _analytics;

     AnalyticsService(this._analytics);

     // Workout Events
     Future<void> logWorkoutCompleted({
       required int durationMinutes,
       required int exerciseCount,
       required int totalSets,
     }) async {
       await _analytics.logEvent(
         name: 'workout_completed',
         parameters: {
           'duration': durationMinutes,
           'exercise_count': exerciseCount,
           'total_sets': totalSets,
         },
       );
     }

     Future<void> logExerciseLogged({
       required String exerciseName,
       required int sets,
       required int reps,
       required double weight,
     }) async {
       await _analytics.logEvent(
         name: 'exercise_logged',
         parameters: {
           'exercise_name': exerciseName,
           'sets': sets,
           'reps': reps,
           'weight_kg': weight,
         },
       );
     }

     Future<void> logStreakMilestone(int days) async {
       await _analytics.logEvent(
         name: 'streak_milestone',
         parameters: {'days': days},
       );
     }

     Future<void> logPatternMemoryUsed(int timeSavedSeconds) async {
       await _analytics.logEvent(
         name: 'pattern_memory_used',
         parameters: {'time_saved_seconds': timeSavedSeconds},
       );
     }

     Future<void> logChartViewed({
       required String chartType,
       required String timeframe,
     }) async {
       await _analytics.logEvent(
         name: 'chart_viewed',
         parameters: {
           'chart_type': chartType,
           'timeframe': timeframe,
         },
       );
     }

     Future<void> logTemplateUsed(String templateName) async {
       await _analytics.logEvent(
         name: 'template_used',
         parameters: {'template_name': templateName},
       );
     }

     // User Properties
     Future<void> setUserProperties({
       required String fitnessGoal,
       required String experienceLevel,
       required String workoutFrequency,
       required DateTime signupDate,
       bool isPremium = false,
     }) async {
       await _analytics.setUserProperty(name: 'fitness_goal', value: fitnessGoal);
       await _analytics.setUserProperty(name: 'experience_level', value: experienceLevel);
       await _analytics.setUserProperty(name: 'workout_frequency_preference', value: workoutFrequency);

       final daysSinceSignup = DateTime.now().difference(signupDate).inDays;
       await _analytics.setUserProperty(name: 'days_since_signup', value: daysSinceSignup.toString());

       await _analytics.setUserProperty(name: 'premium_user', value: isPremium ? 'true' : 'false');
     }

     // Set user ID (anonymized)
     Future<void> setUserId(String userId) async {
       await _analytics.setUserId(id: userId);
     }
   }

   @riverpod
   AnalyticsService analyticsService(AnalyticsServiceRef ref) {
     final analytics = ref.watch(analyticsProvider);
     return AnalyticsService(analytics);
   }
   ```

**Day 6: Firebase Performance Monitoring (1.5 SP)**

1. **Add Performance Monitoring Package**
   ```bash
   flutter pub add firebase_performance
   ```

2. **Enable Performance Monitoring**
   ```dart
   // lib/main.dart
   import 'package:firebase_performance/firebase_performance.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Performance monitoring is automatically enabled
     // Tracks app startup time, HTTP requests, and more

     runApp(const MyApp());
   }
   ```

3. **Track App Startup Time**
   ```dart
   // lib/main.dart
   Future<void> main() async {
     final startupTrace = FirebasePerformance.instance.newTrace('app_startup');
     await startupTrace.start();

     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     runApp(const MyApp());

     // Stop trace after first frame
     WidgetsBinding.instance.addPostFrameCallback((_) async {
       await startupTrace.stop();
     });
   }
   ```

4. **Create Custom Traces for Critical Flows**
   ```dart
   // lib/core/services/performance_service.dart
   import 'package:firebase_performance/firebase_performance.dart';

   class PerformanceService {
     // Trace: Workout Logging Flow (target: <2min per NFR-P2)
     Future<T> traceWorkoutLoggingFlow<T>(Future<T> Function() operation) async {
       final trace = FirebasePerformance.instance.newTrace('workout_logging_flow');
       await trace.start();

       try {
         final result = await operation();
         trace.putAttribute('status', 'success');
         return result;
       } catch (e) {
         trace.putAttribute('status', 'error');
         rethrow;
       } finally {
         await trace.stop();
       }
     }

     // Trace: Pattern Memory Query (target: <500ms per NFR-P3)
     Future<T> tracePatternMemoryQuery<T>(Future<T> Function() operation) async {
       final trace = FirebasePerformance.instance.newTrace('pattern_memory_query');
       await trace.start();

       try {
         final result = await operation();
         trace.putAttribute('status', 'success');
         return result;
       } catch (e) {
         trace.putAttribute('status', 'error');
         rethrow;
       } finally {
         await trace.stop();
       }
     }

     // Trace: Chart Render (target: <1s per NFR-P4)
     Future<T> traceChartRender<T>(String chartType, Future<T> Function() operation) async {
       final trace = FirebasePerformance.instance.newTrace('chart_render');
       trace.putAttribute('chart_type', chartType);
       await trace.start();

       try {
         final result = await operation();
         trace.putAttribute('status', 'success');
         return result;
       } catch (e) {
         trace.putAttribute('status', 'error');
         rethrow;
       } finally {
         await trace.stop();
       }
     }

     // HTTP Trace (automatic for most packages, manual for custom requests)
     Future<T> traceHttpRequest<T>(String url, Future<T> Function() operation) async {
       final metric = FirebasePerformance.instance.newHttpMetric(
         url,
         HttpMethod.Get,
       );
       await metric.start();

       try {
         final result = await operation();
         metric.responseCode = 200;
         return result;
       } catch (e) {
         metric.responseCode = 500;
         rethrow;
       } finally {
         await metric.stop();
       }
     }
   }

   @riverpod
   PerformanceService performanceService(PerformanceServiceRef ref) {
     return PerformanceService();
   }
   ```

**Day 7: Privacy Compliance and User Consent (1.5 SP)**

1. **Create Analytics Consent Provider**
   ```dart
   // lib/features/settings/providers/analytics_consent_provider.dart
   @riverpod
   class AnalyticsConsent extends _$AnalyticsConsent {
     @override
     bool build() {
       // Load from shared preferences
       final prefs = ref.watch(sharedPreferencesProvider);
       return prefs.getBool('analytics_enabled') ?? true; // Opt-out by default (GDPR compliant)
     }

     Future<void> setConsent(bool enabled) async {
       final prefs = ref.read(sharedPreferencesProvider);
       await prefs.setBool('analytics_enabled', enabled);

       // Update Firebase Analytics collection
       await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);

       state = enabled;
     }
   }
   ```

2. **Add Analytics Toggle in Settings**
   ```dart
   // lib/features/settings/screens/privacy_settings_screen.dart
   class PrivacySettingsScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final analyticsEnabled = ref.watch(analyticsConsentProvider);

       return Scaffold(
         appBar: AppBar(title: const Text('Privacy & Data')),
         body: ListView(
           children: [
             SwitchListTile(
               title: const Text('Analytics'),
               subtitle: const Text('Help improve the app by sharing anonymous usage data'),
               value: analyticsEnabled,
               onChanged: (value) {
                 ref.read(analyticsConsentProvider.notifier).setConsent(value);
               },
             ),
             const Divider(),
             ListTile(
               title: const Text('What data is collected?'),
               subtitle: const Text('View our privacy policy'),
               trailing: const Icon(Icons.arrow_forward_ios),
               onTap: () {
                 // Open privacy policy
               },
             ),
           ],
         ),
       );
     }
   }
   ```

3. **Anonymize Analytics Data**
   ```dart
   // Ensure no PII is sent to Analytics
   // ✅ GOOD: Anonymized
   analyticsService.logWorkoutCompleted(
     durationMinutes: 45,
     exerciseCount: 5,
     totalSets: 15,
   );

   // ❌ BAD: Contains PII
   analyticsService.logEvent(
     name: 'user_signed_up',
     parameters: {
       'email': 'user@example.com', // PII - don't log
       'full_name': 'John Doe', // PII - don't log
     },
   );

   // ✅ GOOD: Use anonymized user ID
   analyticsService.setUserId(firebaseUid); // Firebase UID is anonymized
   ```

4. **Set Data Retention in Firebase Console**
   - Navigate to Analytics → Settings → Data Retention
   - Set retention: 14 months (default)
   - Enable "Reset user data on new activity": No

**Day 8: Dashboard Setup and Testing (0.5 SP)**

1. **Create Custom Dashboards in Firebase Console**
   ```markdown
   ## Dashboard 1: User Engagement
   - Daily Active Users (DAU)
   - Weekly Active Users (WAU)
   - Monthly Active Users (MAU)
   - Average session duration
   - Screens per session

   ## Dashboard 2: Workout Metrics
   - Workouts completed (daily)
   - Avg exercises per workout
   - Avg workout duration
   - Pattern memory usage rate

   ## Dashboard 3: Performance
   - App startup time (p50, p90, p95)
   - Workout logging flow duration
   - Pattern memory query time
   - Chart render time
   - Crash-free sessions %
   ```

2. **Test Analytics Events**
   ```dart
   // Test analytics in debug mode
   if (AppConfig.isDev) {
     await analyticsService.logWorkoutCompleted(
       durationMinutes: 45,
       exerciseCount: 5,
       totalSets: 15,
     );

     // View events in Firebase Console → DebugView
     // Enable debug mode: `adb shell setprop debug.firebase.analytics.app com.gymapp.dev`
   }
   ```

3. **Optional: Setup BigQuery Export for Advanced Analysis**
   - Navigate to Analytics → Integrations → BigQuery
   - Click "Link"
   - Create BigQuery dataset: `gymapp_analytics`
   - Enable daily export
   - Note: Free tier allows 10GB/month storage

### Definition of Done

- [ ] Firebase Analytics integrated
- [ ] Screen view tracking working with go_router
- [ ] Custom events logged (workout_completed, exercise_logged, etc.)
- [ ] User properties set (fitness_goal, experience_level, etc.)
- [ ] Firebase Performance Monitoring enabled
- [ ] App startup time tracked
- [ ] Custom traces for critical flows (workout_logging_flow, pattern_memory_query, chart_render)
- [ ] Analytics consent toggle in settings
- [ ] Analytics can be disabled (GDPR compliant)
- [ ] No PII logged in analytics
- [ ] Custom dashboards created in Firebase Console
- [ ] Test events verified in Firebase DebugView
- [ ] Code reviewed
- [ ] Merged to main

---

## Story 2.1: Email/Password Authentication

**Story Points:** 5 SP
**Prerequisites:** Story 1.2 (Firebase Auth configured), Story 1.4 (Riverpod), Story 1.5 (Routing), Story 1.6 (Design System)
**Priority:** HIGH (core authentication for MVP)

**User Story:**

**As a** new user,
**I want** to create an account with email and password,
**So that** I can start tracking my workouts securely.

### Acceptance Criteria

**Given** a user wants to sign up
**When** filling out the signup form
**Then** form includes:
- Email field with RFC 5322 validation
- Password field with show/hide toggle
- Password requirements displayed
- Password strength meter (weak/medium/strong)
- "Sign Up" button (disabled until valid input)

**And** validation provides clear feedback:
- Email error: "Please enter a valid email address"
- Password error: "Password must be at least 8 characters with 1 uppercase, 1 number, 1 special character"
- Real-time validation (not just on submit)

**And** signup succeeds:
- Firebase Authentication creates account
- Success: User redirected to onboarding flow (deferred to Sprint 4)
- Error handling with clear messages

**And** performance:
- Account creation completes in <2 seconds (NFR-P1)
- Loading state shown during network request

**And** accessibility:
- All fields labeled for screen readers
- Keyboard navigation supported
- Touch targets ≥44x44dp (NFR-A3)
- Color contrast ≥4.5:1 (NFR-A2)

### Tasks

**Day 8: Auth Provider and Models (1 SP)**

1. **Create Auth Models**
   ```dart
   // lib/features/auth/models/auth_user.dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'auth_user.freezed.dart';
   part 'auth_user.g.dart';

   @freezed
   class AuthUser with _$AuthUser {
     const factory AuthUser({
       required String uid,
       required String email,
       String? displayName,
       String? photoUrl,
       required DateTime createdAt,
       required bool emailVerified,
     }) = _AuthUser;

     factory AuthUser.fromFirebase(User firebaseUser) {
       return AuthUser(
         uid: firebaseUser.uid,
         email: firebaseUser.email ?? '',
         displayName: firebaseUser.displayName,
         photoUrl: firebaseUser.photoURL,
         createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
         emailVerified: firebaseUser.emailVerified,
       );
     }

     factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
   }
   ```

2. **Create Auth Repository**
   ```dart
   // lib/features/auth/repositories/auth_repository.dart
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:riverpod_annotation/riverpod_annotation.dart';

   part 'auth_repository.g.dart';

   class AuthRepository {
     final FirebaseAuth _auth;

     AuthRepository(this._auth);

     // Auth state stream
     Stream<User?> authStateChanges() {
       return _auth.authStateChanges();
     }

     // Current user
     User? get currentUser => _auth.currentUser;

     // Sign up with email/password
     Future<UserCredential> signUpWithEmailPassword({
       required String email,
       required String password,
     }) async {
       try {
         final credential = await _auth.createUserWithEmailAndPassword(
           email: email,
           password: password,
         );

         AppLogger.info('User signed up: ${credential.user?.uid}');
         return credential;
       } on FirebaseAuthException catch (e) {
         AppLogger.error('Sign up failed', e);
         throw _handleAuthException(e);
       }
     }

     // Sign in with email/password
     Future<UserCredential> signInWithEmailPassword({
       required String email,
       required String password,
     }) async {
       try {
         final credential = await _auth.signInWithEmailAndPassword(
           email: email,
           password: password,
         );

         AppLogger.info('User signed in: ${credential.user?.uid}');
         return credential;
       } on FirebaseAuthException catch (e) {
         AppLogger.error('Sign in failed', e);
         throw _handleAuthException(e);
       }
     }

     // Sign out
     Future<void> signOut() async {
       await _auth.signOut();
       AppLogger.info('User signed out');
     }

     // Handle Firebase Auth exceptions
     AuthException _handleAuthException(FirebaseAuthException e) {
       switch (e.code) {
         case 'email-already-in-use':
           return AuthException(
             'Email already in use',
             userMessage: 'An account with this email already exists. Try logging in.',
           );
         case 'weak-password':
           return AuthException(
             'Weak password',
             userMessage: 'Password is too weak. Use a stronger password.',
           );
         case 'invalid-email':
           return AuthException(
             'Invalid email',
             userMessage: 'Please enter a valid email address.',
           );
         case 'user-not-found':
         case 'wrong-password':
           return AuthException(
             'Invalid credentials',
             userMessage: 'Email or password is incorrect.',
           );
         case 'too-many-requests':
           return AuthException(
             'Too many requests',
             userMessage: 'Too many failed login attempts. Try again in 5 minutes.',
           );
         case 'network-request-failed':
           return NetworkException('Network error', originalError: e);
         default:
           return AuthException('Unknown error: ${e.code}', originalError: e);
       }
     }
   }

   @riverpod
   AuthRepository authRepository(AuthRepositoryRef ref) {
     return AuthRepository(FirebaseAuth.instance);
   }
   ```

3. **Create Auth State Provider**
   ```dart
   // lib/features/auth/providers/auth_provider.dart
   @riverpod
   class AuthState extends _$AuthState {
     @override
     Stream<AuthUser?> build() {
       final repo = ref.watch(authRepositoryProvider);
       return repo.authStateChanges().map((user) {
         if (user == null) return null;

         // Set analytics user ID
         ref.read(analyticsServiceProvider).setUserId(user.uid);

         // Set Crashlytics user ID
         FirebaseCrashlytics.instance.setUserIdentifier(user.uid);

         return AuthUser.fromFirebase(user);
       });
     }
   }

   @riverpod
   class SignUp extends _$SignUp {
     @override
     FutureOr<void> build() {}

     Future<void> signUp({
       required String email,
       required String password,
     }) async {
       state = const AsyncLoading();

       state = await AsyncValue.guard(() async {
         final repo = ref.read(authRepositoryProvider);
         await repo.signUpWithEmailPassword(email: email, password: password);
       });
     }
   }
   ```

**Day 9: Signup Screen UI (2 SP)**

1. **Create Password Validator**
   ```dart
   // lib/features/auth/utils/password_validator.dart
   class PasswordValidator {
     static const int minLength = 8;

     static String? validate(String? password) {
       if (password == null || password.isEmpty) {
         return 'Password is required';
       }

       if (password.length < minLength) {
         return 'Password must be at least $minLength characters';
       }

       if (!password.contains(RegExp(r'[A-Z]'))) {
         return 'Password must contain at least 1 uppercase letter';
       }

       if (!password.contains(RegExp(r'[0-9]'))) {
         return 'Password must contain at least 1 number';
       }

       if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
         return 'Password must contain at least 1 special character';
       }

       return null; // Valid
     }

     static PasswordStrength getStrength(String password) {
       if (password.length < minLength) return PasswordStrength.weak;

       int score = 0;
       if (password.length >= 12) score++;
       if (password.contains(RegExp(r'[A-Z]'))) score++;
       if (password.contains(RegExp(r'[a-z]'))) score++;
       if (password.contains(RegExp(r'[0-9]'))) score++;
       if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

       if (score <= 2) return PasswordStrength.weak;
       if (score <= 4) return PasswordStrength.medium;
       return PasswordStrength.strong;
     }
   }

   enum PasswordStrength { weak, medium, strong }
   ```

2. **Create Password Strength Indicator**
   ```dart
   // lib/features/auth/widgets/password_strength_indicator.dart
   class PasswordStrengthIndicator extends StatelessWidget {
     final PasswordStrength strength;

     const PasswordStrengthIndicator({required this.strength, super.key});

     @override
     Widget build(BuildContext context) {
       return Row(
         children: [
           Expanded(
             child: LinearProgressIndicator(
               value: _getProgressValue(),
               backgroundColor: Colors.grey[300],
               color: _getColor(),
             ),
           ),
           const SizedBox(width: 8),
           Text(
             _getLabel(),
             style: TextStyle(
               fontSize: 12,
               color: _getColor(),
               fontWeight: FontWeight.w500,
             ),
           ),
         ],
       );
     }

     double _getProgressValue() {
       switch (strength) {
         case PasswordStrength.weak:
           return 0.33;
         case PasswordStrength.medium:
           return 0.66;
         case PasswordStrength.strong:
           return 1.0;
       }
     }

     Color _getColor() {
       switch (strength) {
         case PasswordStrength.weak:
           return Colors.red;
         case PasswordStrength.medium:
           return Colors.orange;
         case PasswordStrength.strong:
           return Colors.green;
       }
     }

     String _getLabel() {
       switch (strength) {
         case PasswordStrength.weak:
           return 'Weak';
         case PasswordStrength.medium:
           return 'Medium';
         case PasswordStrength.strong:
           return 'Strong';
       }
     }
   }
   ```

3. **Create Signup Screen**
   ```dart
   // lib/features/auth/screens/signup_screen.dart
   class SignupScreen extends ConsumerStatefulWidget {
     const SignupScreen({super.key});

     @override
     ConsumerState<SignupScreen> createState() => _SignupScreenState();
   }

   class _SignupScreenState extends ConsumerState<SignupScreen> {
     final _formKey = GlobalKey<FormState>();
     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     bool _obscurePassword = true;
     PasswordStrength _passwordStrength = PasswordStrength.weak;

     @override
     void dispose() {
       _emailController.dispose();
       _passwordController.dispose();
       super.dispose();
     }

     void _onPasswordChanged(String password) {
       setState(() {
         _passwordStrength = PasswordValidator.getStrength(password);
       });
     }

     Future<void> _signUp() async {
       if (!_formKey.currentState!.validate()) return;

       await ref.read(signUpProvider.notifier).signUp(
         email: _emailController.text.trim(),
         password: _passwordController.text,
       );

       final signUpState = ref.read(signUpProvider);

       signUpState.when(
         data: (_) {
           // Success - router will auto-redirect via redirect logic
           AppLogger.info('Sign up successful');
         },
         error: (error, stack) {
           // Show error snackbar
           final message = error is AppException
               ? error.userMessage ?? error.message
               : 'Sign up failed. Please try again.';

           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(message)),
           );
         },
         loading: () {},
       );
     }

     @override
     Widget build(BuildContext context) {
       final signUpState = ref.watch(signUpProvider);
       final isLoading = signUpState.isLoading;

       return Scaffold(
         appBar: AppBar(title: const Text('Sign Up')),
         body: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 // Email field
                 TextFormField(
                   controller: _emailController,
                   keyboardType: TextInputType.emailAddress,
                   decoration: const InputDecoration(
                     labelText: 'Email',
                     hintText: 'user@example.com',
                     prefixIcon: Icon(Icons.email),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Email is required';
                     }
                     // RFC 5322 simplified regex
                     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                     if (!emailRegex.hasMatch(value)) {
                       return 'Please enter a valid email address';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 16),

                 // Password field
                 TextFormField(
                   controller: _passwordController,
                   obscureText: _obscurePassword,
                   onChanged: _onPasswordChanged,
                   decoration: InputDecoration(
                     labelText: 'Password',
                     prefixIcon: const Icon(Icons.lock),
                     suffixIcon: IconButton(
                       icon: Icon(
                         _obscurePassword ? Icons.visibility : Icons.visibility_off,
                       ),
                       onPressed: () {
                         setState(() {
                           _obscurePassword = !_obscurePassword;
                         });
                       },
                     ),
                   ),
                   validator: PasswordValidator.validate,
                 ),
                 const SizedBox(height: 8),

                 // Password strength indicator
                 PasswordStrengthIndicator(strength: _passwordStrength),
                 const SizedBox(height: 8),

                 // Password requirements
                 Text(
                   'Password must be at least 8 characters with 1 uppercase, 1 number, 1 special character',
                   style: Theme.of(context).textTheme.bodySmall,
                 ),
                 const SizedBox(height: 24),

                 // Sign up button
                 AppButton(
                   label: 'Sign Up',
                   onPressed: isLoading ? null : _signUp,
                   isLoading: isLoading,
                   type: AppButtonType.primary,
                 ),
                 const SizedBox(height: 16),

                 // Login link
                 TextButton(
                   onPressed: () {
                     context.go('/login');
                   },
                   child: const Text('Already have an account? Log In'),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```

**Day 10: Testing and Accessibility (1 SP)**

1. **Write Unit Tests for Password Validator**
   ```dart
   // test/features/auth/utils/password_validator_test.dart
   void main() {
     group('PasswordValidator', () {
       test('rejects password less than 8 characters', () {
         expect(PasswordValidator.validate('Short1!'), isNotNull);
       });

       test('rejects password without uppercase', () {
         expect(PasswordValidator.validate('password1!'), isNotNull);
       });

       test('rejects password without number', () {
         expect(PasswordValidator.validate('Password!'), isNotNull);
       });

       test('rejects password without special character', () {
         expect(PasswordValidator.validate('Password1'), isNotNull);
       });

       test('accepts valid password', () {
         expect(PasswordValidator.validate('Password1!'), isNull);
       });

       test('strength weak for short password', () {
         expect(PasswordValidator.getStrength('Pass1!'), PasswordStrength.weak);
       });

       test('strength medium for decent password', () {
         expect(PasswordValidator.getStrength('Password1!'), PasswordStrength.medium);
       });

       test('strength strong for complex password', () {
         expect(PasswordValidator.getStrength('MyP@ssw0rd!2024'), PasswordStrength.strong);
       });
     });
   }
   ```

2. **Write Widget Tests for Signup Screen**
   ```dart
   // test/features/auth/screens/signup_screen_test.dart
   void main() {
     testWidgets('shows validation errors for invalid input', (tester) async {
       await tester.pumpWidget(
         ProviderScope(
           child: MaterialApp(home: SignupScreen()),
         ),
       );

       // Tap sign up without filling fields
       await tester.tap(find.text('Sign Up'));
       await tester.pump();

       expect(find.text('Email is required'), findsOneWidget);
       expect(find.text('Password is required'), findsOneWidget);
     });

     testWidgets('password visibility toggle works', (tester) async {
       await tester.pumpWidget(
         ProviderScope(
           child: MaterialApp(home: SignupScreen()),
         ),
       );

       final passwordField = find.byType(TextFormField).last;
       final visibilityToggle = find.byIcon(Icons.visibility);

       // Initially obscured
       expect(tester.widget<TextFormField>(passwordField).obscureText, isTrue);

       // Tap toggle
       await tester.tap(visibilityToggle);
       await tester.pump();

       // Now visible
       expect(tester.widget<TextFormField>(passwordField).obscureText, isFalse);
     });
   }
   ```

3. **Verify Accessibility**
   ```dart
   // Run accessibility checks
   await tester.pumpWidget(
     ProviderScope(
       child: MaterialApp(home: SignupScreen()),
     ),
   );

   // Check semantics
   final SemanticsHandle handle = tester.ensureSemantics();
   expect(tester, meetsGuideline(androidTapTargetGuideline)); // ≥48x48dp
   expect(tester, meetsGuideline(iOSTapTargetGuideline)); // ≥44x44dp
   expect(tester, meetsGuideline(textContrastGuideline)); // ≥4.5:1
   handle.dispose();
   ```

**Day 10: Error Handling and Analytics (1 SP)**

1. **Add Analytics for Signup Events**
   ```dart
   // In SignupScreen._signUp()
   signUpState.when(
     data: (_) {
       // Log signup event
       ref.read(analyticsServiceProvider).logSignUp(method: 'email');
       AppLogger.info('Sign up successful');
     },
     // ... error handling
   );
   ```

2. **Test Error Scenarios**
   - Email already exists → Show user-friendly message
   - Weak password → Show validation error
   - Network error → Show retry option
   - Unknown error → Log to Crashlytics, show generic message

### Definition of Done

- [ ] Auth repository created with email/password signup
- [ ] Auth state provider created (Riverpod)
- [ ] Signup screen UI implemented with validation
- [ ] Password strength meter working
- [ ] Real-time validation working
- [ ] Error handling with user-friendly messages
- [ ] Loading state shown during signup
- [ ] Accessibility verified (touch targets, contrast, screen readers)
- [ ] Unit tests written for password validator
- [ ] Widget tests written for signup screen
- [ ] Analytics event logged for signup
- [ ] Code reviewed
- [ ] Merged to main

---

## Story 2.4: Login Flow with Persistent Sessions

**Story Points:** 3 SP
**Prerequisites:** Story 2.1 (email/password auth), Story 1.5 (routing)
**Priority:** HIGH (required for returning users)

**User Story:**

**As a** returning user,
**I want** to log in quickly and stay logged in,
**So that** I don't have to re-authenticate every time.

### Acceptance Criteria

**Given** a user has an existing account
**When** opening the app
**Then** automatic login:
- If authenticated session valid: Redirect to home screen
- If session expired: Show login screen
- Session check completes in <500ms

**And** manual login form includes:
- Email field
- Password field with show/hide toggle
- "Forgot Password?" link (non-functional, deferred to Sprint 4)
- "Log In" button
- "Don't have an account? Sign Up" link

**And** login succeeds:
- Firebase Auth validates credentials
- Success: Redirect to home screen
- Error handling with clear messages

**And** session management:
- Auth token refreshed automatically
- Token stored securely
- Logout clears token

### Tasks

**Day 10: Login Screen UI (1.5 SP)**

1. **Create Login Screen**
   ```dart
   // lib/features/auth/screens/login_screen.dart
   class LoginScreen extends ConsumerStatefulWidget {
     const LoginScreen({super.key});

     @override
     ConsumerState<LoginScreen> createState() => _LoginScreenState();
   }

   class _LoginScreenState extends ConsumerState<LoginScreen> {
     final _formKey = GlobalKey<FormState>();
     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     bool _obscurePassword = true;

     @override
     void dispose() {
       _emailController.dispose();
       _passwordController.dispose();
       super.dispose();
     }

     Future<void> _login() async {
       if (!_formKey.currentState!.validate()) return;

       await ref.read(signInProvider.notifier).signIn(
         email: _emailController.text.trim(),
         password: _passwordController.text,
       );

       final signInState = ref.read(signInProvider);

       signInState.when(
         data: (_) {
           AppLogger.info('Login successful');
           // Analytics
           ref.read(analyticsServiceProvider).logLogin(method: 'email');
         },
         error: (error, stack) {
           final message = error is AppException
               ? error.userMessage ?? error.message
               : 'Login failed. Please try again.';

           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(message)),
           );
         },
         loading: () {},
       );
     }

     @override
     Widget build(BuildContext context) {
       final signInState = ref.watch(signInProvider);
       final isLoading = signInState.isLoading;

       return Scaffold(
         appBar: AppBar(title: const Text('Log In')),
         body: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 // Email field
                 TextFormField(
                   controller: _emailController,
                   keyboardType: TextInputType.emailAddress,
                   decoration: const InputDecoration(
                     labelText: 'Email',
                     prefixIcon: Icon(Icons.email),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Email is required';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 16),

                 // Password field
                 TextFormField(
                   controller: _passwordController,
                   obscureText: _obscurePassword,
                   decoration: InputDecoration(
                     labelText: 'Password',
                     prefixIcon: const Icon(Icons.lock),
                     suffixIcon: IconButton(
                       icon: Icon(
                         _obscurePassword ? Icons.visibility : Icons.visibility_off,
                       ),
                       onPressed: () {
                         setState(() {
                           _obscurePassword = !_obscurePassword;
                         });
                       },
                     ),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Password is required';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 8),

                 // Forgot password link (non-functional for Sprint 3)
                 Align(
                   alignment: Alignment.centerRight,
                   child: TextButton(
                     onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('Password reset coming in Sprint 4'),
                         ),
                       );
                     },
                     child: const Text('Forgot Password?'),
                   ),
                 ),
                 const SizedBox(height: 24),

                 // Login button
                 AppButton(
                   label: 'Log In',
                   onPressed: isLoading ? null : _login,
                   isLoading: isLoading,
                   type: AppButtonType.primary,
                 ),
                 const SizedBox(height: 16),

                 // Signup link
                 TextButton(
                   onPressed: () {
                     context.go('/signup');
                   },
                   child: const Text("Don't have an account? Sign Up"),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```

2. **Create SignIn Provider**
   ```dart
   // lib/features/auth/providers/auth_provider.dart (add to existing file)
   @riverpod
   class SignIn extends _$SignIn {
     @override
     FutureOr<void> build() {}

     Future<void> signIn({
       required String email,
       required String password,
     }) async {
       state = const AsyncLoading();

       state = await AsyncValue.guard(() async {
         final repo = ref.read(authRepositoryProvider);
         await repo.signInWithEmailPassword(email: email, password: password);
       });
     }
   }
   ```

**Day 10: Session Management and Auto-Login (1 SP)**

1. **Update Router with Auth Redirect**
   ```dart
   // lib/core/providers/router_provider.dart
   @riverpod
   GoRouter router(RouterRef ref) {
     final authState = ref.watch(authStateProvider);

     return GoRouter(
       initialLocation: '/',
       redirect: (context, state) {
         final isLoggedIn = authState.value != null;
         final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

         // If not logged in and not going to auth screen, redirect to login
         if (!isLoggedIn && !isGoingToAuth) {
           return '/login';
         }

         // If logged in and going to auth screen, redirect to home
         if (isLoggedIn && isGoingToAuth) {
           return '/';
         }

         return null; // No redirect needed
       },
       routes: [
         GoRoute(
           path: '/login',
           builder: (context, state) => const LoginScreen(),
         ),
         GoRoute(
           path: '/signup',
           builder: (context, state) => const SignupScreen(),
         ),
         GoRoute(
           path: '/',
           builder: (context, state) => const HomeScreen(),
         ),
         // ... more routes
       ],
     );
   }
   ```

2. **Add Logout Functionality**
   ```dart
   // lib/features/auth/providers/auth_provider.dart (add to existing file)
   @riverpod
   class SignOut extends _$SignOut {
     @override
     FutureOr<void> build() {}

     Future<void> signOut() async {
       state = const AsyncLoading();

       state = await AsyncValue.guard(() async {
         final repo = ref.read(authRepositoryProvider);
         await repo.signOut();

         // Clear local data
         final database = ref.read(databaseProvider);
         await database.clearAllData();

         AppLogger.info('User logged out, local data cleared');
       });
     }
   }
   ```

3. **Add Logout Button in Settings/Profile**
   ```dart
   // lib/features/settings/screens/settings_screen.dart (create basic version)
   class SettingsScreen extends ConsumerWidget {
     const SettingsScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final signOutState = ref.watch(signOutProvider);

       return Scaffold(
         appBar: AppBar(title: const Text('Settings')),
         body: ListView(
           children: [
             ListTile(
               leading: const Icon(Icons.logout),
               title: const Text('Log Out'),
               onTap: signOutState.isLoading
                   ? null
                   : () async {
                       // Confirm dialog
                       final confirmed = await showDialog<bool>(
                         context: context,
                         builder: (context) => AlertDialog(
                           title: const Text('Log Out'),
                           content: const Text('Are you sure you want to log out?'),
                           actions: [
                             TextButton(
                               onPressed: () => Navigator.pop(context, false),
                               child: const Text('Cancel'),
                             ),
                             TextButton(
                               onPressed: () => Navigator.pop(context, true),
                               child: const Text('Log Out'),
                             ),
                           ],
                         ),
                       );

                       if (confirmed == true) {
                         await ref.read(signOutProvider.notifier).signOut();
                       }
                     },
             ),
           ],
         ),
       );
     }
   }
   ```

**Day 10: Testing (0.5 SP)**

1. **Test Auto-Login Flow**
   ```dart
   // Manual test:
   // 1. Sign up with new account
   // 2. Close app (kill process)
   // 3. Reopen app
   // Expected: Auto-login to home screen (no login screen shown)

   // 4. Tap "Log Out"
   // 5. Reopen app
   // Expected: Login screen shown
   ```

2. **Test Session Expiry**
   ```dart
   // Test in Firebase Console:
   // 1. Sign in
   // 2. Revoke user's refresh token in Firebase Console (Authentication → Users → {user} → Disable)
   // 3. Reopen app
   // Expected: Login screen shown (session expired)
   ```

3. **Widget Tests for Login Screen**
   ```dart
   // test/features/auth/screens/login_screen_test.dart
   void main() {
     testWidgets('shows validation errors for empty fields', (tester) async {
       await tester.pumpWidget(
         ProviderScope(
           child: MaterialApp(home: LoginScreen()),
         ),
       );

       await tester.tap(find.text('Log In'));
       await tester.pump();

       expect(find.text('Email is required'), findsOneWidget);
       expect(find.text('Password is required'), findsOneWidget);
     });
   }
   ```

### Definition of Done

- [ ] Login screen UI implemented
- [ ] SignIn provider created
- [ ] SignOut provider created with local data clearing
- [ ] Router redirect logic working (auto-login if session valid)
- [ ] Logout functionality working
- [ ] Session persistence working (user stays logged in after app restart)
- [ ] Error handling with user-friendly messages
- [ ] Widget tests written for login screen
- [ ] Manual testing verified (auto-login, session expiry)
- [ ] Code reviewed
- [ ] Merged to main

---

## Sprint 3 Day-by-Day Roadmap

**Total:** 8 days (Jan 29 - Feb 5, 2025)

| Day | Focus | Stories | Hours | SP |
|-----|-------|---------|-------|-----|
| **Day 1** | Error Handling: Crashlytics Setup | 1.7 | 6h | 1.5 |
| **Day 2** | Error Handling: Crashlytics Testing | 1.7 | 2h | 0.5 |
| **Day 3** | Error Handling: Logger + Error Boundaries | 1.7 | 4h | 1 |
| **Day 4** | Analytics: Firebase Analytics Integration | 1.8 | 6h | 1.5 |
| **Day 5** | Analytics: Performance Monitoring | 1.8 | 6h | 1.5 |
| **Day 6** | Analytics: Privacy Compliance + Dashboards | 1.8 | 8h | 2 |
| **Day 7** | Auth: Signup Screen (Email/Password) | 2.1 | 8h | 2 |
| **Day 8** | Auth: Signup Testing + Accessibility | 2.1 | 6h | 1.5 |
| **Day 9** | Auth: Login Screen + Session Management | 2.4 | 6h | 1.5 |
| **Day 10** | Auth: Logout + Auto-Login Testing | 2.4, 2.1 final polish | 6h | 1.5 |

**Total Estimated:** 58 hours (avg 5.8 hours/day) = **16 SP**

---

## Sprint 3 Testing Checklist

### Story 1.7: Error Handling

- [ ] Test crash is reported to Firebase Crashlytics
- [ ] User ID attached to crash reports
- [ ] Non-fatal errors logged with `FirebaseCrashlytics.instance.recordError()`
- [ ] Logger outputs to console in dev mode
- [ ] Logger sends errors to Crashlytics in prod mode
- [ ] Error boundaries catch Flutter framework errors
- [ ] Error boundaries catch async errors
- [ ] User-friendly error messages shown (not stack traces)
- [ ] Retry logic works for network failures
- [ ] Crashlytics alerts configured and tested

### Story 1.8: Analytics

- [ ] Firebase Analytics events logged
- [ ] Screen view tracking working automatically
- [ ] Custom events logged (workout_completed, exercise_logged, etc.)
- [ ] User properties set correctly
- [ ] App startup time tracked in Performance Monitoring
- [ ] Custom traces working (workout_logging_flow, pattern_memory_query, chart_render)
- [ ] Analytics consent toggle works
- [ ] Analytics disabled when user opts out
- [ ] No PII logged in analytics
- [ ] Events visible in Firebase DebugView

### Story 2.1: Email/Password Authentication

- [ ] Signup form validation working (email, password requirements)
- [ ] Password strength meter updates in real-time
- [ ] Show/hide password toggle works
- [ ] Signup button disabled until valid input
- [ ] Account created in Firebase Authentication
- [ ] User redirected after successful signup
- [ ] Error messages shown for invalid input
- [ ] Loading state shown during signup
- [ ] Touch targets ≥44x44dp
- [ ] Color contrast ≥4.5:1
- [ ] Screen reader labels working
- [ ] Keyboard navigation working

### Story 2.4: Login Flow

- [ ] Login form validation working
- [ ] Login succeeds with valid credentials
- [ ] Error messages shown for invalid credentials
- [ ] Show/hide password toggle works
- [ ] Auto-login works (user stays logged in after app restart)
- [ ] Logout clears session and local data
- [ ] Router redirects logged-in users from /login to /
- [ ] Router redirects logged-out users to /login
- [ ] Loading state shown during login
- [ ] Session check completes quickly (<500ms)

---

## Sprint 3 Success Metrics

**Sprint Goal Achievement:**
- [ ] Epic 1 completed (all 8 stories done)
- [ ] Epic 2 authentication foundation established (email/password signup + login)
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] No critical bugs

**Technical Debt:**
- [ ] Code coverage ≥70% for new code
- [ ] No linting errors
- [ ] All TODOs documented in backlog

**Performance:**
- [ ] App startup time <2s (NFR-P1)
- [ ] Account creation <2s (NFR-P1)
- [ ] Login <2s (NFR-P1)
- [ ] Crash-free sessions >99%

**Documentation:**
- [ ] Error monitoring weekly review process documented
- [ ] Firebase dashboards created
- [ ] README updated with auth flow instructions

---

## What's Next: Sprint 4 Preview

**Sprint 4 Focus:** Complete Epic 2 (Authentication + Onboarding)

**Planned Stories (Estimated 18 SP):**
- Story 2.2: Google Sign-In Integration (2 SP)
- Story 2.3: Apple Sign-In Integration (2 SP)
- Story 2.5: Password Reset Flow (2 SP)
- Story 2.6: GDPR Compliance (5 SP)
- Story 2.7: Onboarding Flow - Goal Selection (3 SP)
- Story 2.8: Onboarding Flow - Profile Setup (4 SP)

**Epic 2 Completion:** After Sprint 4, users will be able to:
- Sign up with email/password, Google, or Apple
- Reset forgotten passwords
- Complete goal-driven onboarding
- Export their data (GDPR compliance)
- Delete their account (GDPR compliance)

---

**Document Version:** 1.0
**Created:** 2025-01-15
**Status:** READY FOR EXECUTION
**Next Step:** Review Sprint 3 plan, then begin execution on Day 1
