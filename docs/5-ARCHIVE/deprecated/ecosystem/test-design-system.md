# LifeOS - System-Level Test Design

**Author:** QA Architect (BMAD Methodology)
**Date:** 2025-01-16
**Version:** 1.0
**Phase:** Phase 3 - Testability Review
**Status:** Ready for Implementation

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Test Strategy](#2-test-strategy)
3. [Risk Assessment](#3-risk-assessment)
4. [Test Coverage Plan](#4-test-coverage-plan)
5. [Test Infrastructure](#5-test-infrastructure)
6. [Execution Strategy](#6-execution-strategy)
7. [Resource Estimates](#7-resource-estimates)
8. [Success Criteria](#8-success-criteria)
9. [Next Steps](#9-next-steps)

---

## 1. Executive Summary

### 1.1 Project Scope Summary

**LifeOS** is a modular AI-powered life coaching ecosystem targeting iOS 14+ and Android 10+ with 3 MVP modules:

- **Life Coach AI** (FREE) - Daily planning, goal tracking, AI conversations
- **Fitness Coach AI** (2.99 EUR/month) - Smart Pattern Memory workout logging
- **Mind & Emotion** (2.99 EUR/month) - Meditation, mood tracking, CBT chat

**Killer Feature:** Cross-Module Intelligence - modules communicate to provide holistic optimization (e.g., "High stress + heavy workout → suggest light session").

**Technology Stack:**
- Frontend: Flutter 3.38+, Dart 3.10, Riverpod 3.0, Drift (SQLite)
- Backend: Supabase (PostgreSQL, Realtime, Auth, Edge Functions)
- AI: Hybrid (Llama self-hosted, Claude/GPT-4 APIs)

### 1.2 Test Strategy Overview

**Test Pyramid Distribution:**
- 70% Unit Tests (use cases, repositories, services, business logic)
- 20% Widget Tests (UI components, state management, Riverpod providers)
- 10% Integration/E2E Tests (critical user journeys, cross-module flows)

**Key Testing Focus Areas:**
1. **Cross-Module Intelligence** - Novel feature requiring thorough integration testing
2. **Offline-First Architecture** - Sync conflicts, conflict resolution, data integrity
3. **E2EE Security** - Encryption/decryption validation, key management
4. **AI Integration** - API routing, quota management, error handling
5. **Performance** - Cold start <2s, offline operations <100ms, app size <50MB

### 1.3 Risk Summary

**Total Risks Identified:** 18
- High-Priority Risks (score ≥6): 7
- Medium-Priority Risks (score 3-5): 8
- Low-Priority Risks (score 1-2): 3

**Top 3 High-Risk Areas:**
1. **Cross-Module Intelligence complexity** (P=3, I=3, Score=9)
2. **E2EE key management vulnerability** (P=2, I=3, Score=6)
3. **Offline sync conflicts causing data loss** (P=3, I=2, Score=6)

### 1.4 Coverage Summary

**Requirements Coverage:**
- 123 Functional Requirements (FRs) → 458 Test Scenarios
- 37 Non-Functional Requirements (NFRs) → 87 Test Scenarios
- 9 Epics, 66 Stories → Full coverage

**Test Level Distribution:**
- Unit Tests: ~320 tests (70%)
- Widget Tests: ~92 tests (20%)
- Integration/E2E Tests: ~46 tests (10%)

**Priority Distribution:**
- P0 (Critical): 78 tests (~17%) - Run on every commit
- P1 (High): 184 tests (~40%) - Run on PR
- P2 (Medium): 138 tests (~30%) - Run nightly
- P3 (Low): 58 tests (~13%) - Run weekly

### 1.5 Total Effort Estimate

**Test Development:** 312 hours (39 days)
- P0 tests: 78 × 2 hours = 156 hours
- P1 tests: 184 × 1 hour = 184 hours (reduced due to framework reuse)
- P2 tests: 138 × 0.5 hours = 69 hours
- P3 tests: 58 × 0.25 hours = 15 hours
- **Adjusted Total:** 312 hours (accounting for framework reuse)

**Infrastructure Setup:** 6 days
- Test framework setup: 2 days
- CI/CD pipeline configuration: 1 day
- Test data factories: 2 days
- Supabase test environment: 1 day

**Grand Total:** 45 days (9 weeks with 1 developer)

---

## 2. Test Strategy

### 2.1 Test Pyramid Strategy

**70/20/10 Distribution Rationale:**

```
                    /\
                   /  \
                  / E2E \ 10% (~46 tests)
                 /--------\
                /          \
               /   Widget   \ 20% (~92 tests)
              /--------------\
             /                \
            /    Unit Tests    \ 70% (~320 tests)
           /--------------------\
```

**Why This Distribution:**
- **Unit tests (70%)**: Fast execution (<5 min), high ROI, cover business logic
- **Widget tests (20%)**: UI validation, state management, moderate speed
- **E2E tests (10%)**: Critical paths only, slow but high confidence

**Mobile-Specific Adjustments:**
- Widget tests include Riverpod provider tests (state management critical for Flutter)
- Integration tests include offline-first sync scenarios (unique to mobile)
- E2E tests cover multi-device sync (mobile-specific concern)

### 2.2 Test Levels

#### Unit Tests (70% - ~320 tests)

**What to Test:**
- Business logic (use cases, domain models)
- Repository pattern implementations
- Data transformations (DTOs → Models)
- Utility functions (date/time, validation, encryption)
- Error handling (Result<T> pattern)

**Example Test:**
```dart
test('CompleteWorkoutUseCase should save workout to repository', () async {
  // Arrange
  final workout = Workout(id: '1', name: 'Push Day', duration: 60);
  when(mockRepository.saveWorkout(workout))
    .thenAnswer((_) async => Success(workout));

  // Act
  final result = await useCase.call(workout);

  // Assert
  expect(result, isA<Success<Workout>>());
  verify(mockRepository.saveWorkout(workout)).called(1);
});
```

**Coverage Target:** ≥80%

#### Widget Tests (20% - ~92 tests)

**What to Test:**
- UI components (screens, widgets)
- State management (Riverpod providers)
- User interactions (taps, swipes, form inputs)
- Conditional rendering (loading, error, success states)
- Navigation flows

**Example Test:**
```dart
testWidgets('MorningCheckInModal displays mood slider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: MorningCheckInModal()),
    ),
  );

  // Verify mood slider exists
  expect(find.byType(MoodSlider), findsOneWidget);

  // Simulate mood selection
  await tester.drag(find.byType(MoodSlider), Offset(100, 0));
  await tester.pumpAndSettle();

  // Verify mood value updated
  expect(find.text('😊'), findsOneWidget);
});
```

**Coverage Target:** ≥60%

#### Integration Tests (8% - ~37 tests)

**What to Test:**
- API integration (Supabase CRUD operations)
- Database sync (Drift → Supabase)
- Authentication flows (login, signup, OAuth)
- Offline-first scenarios (write locally, sync when online)
- Cross-module data sharing

**Example Test:**
```dart
testWidgets('Workout sync: Offline → Online', (tester) async {
  // 1. Go offline
  await tester.binding.setConnectivity(ConnectivityResult.none);

  // 2. Log workout offline
  await tester.tap(find.byType(LogWorkoutButton));
  await tester.enterText(find.byType(ExerciseInput), 'Squat');
  await tester.tap(find.byType(SaveButton));
  await tester.pumpAndSettle();

  // 3. Verify saved locally (Drift)
  final localWorkouts = await driftDB.select(driftDB.workouts).get();
  expect(localWorkouts.length, 1);

  // 4. Go online
  await tester.binding.setConnectivity(ConnectivityResult.wifi);
  await tester.pumpAndSettle(Duration(seconds: 5)); // Wait for sync

  // 5. Verify synced to Supabase
  final remoteWorkouts = await supabase.from('workouts').select();
  expect(remoteWorkouts.length, 1);
});
```

#### E2E Tests (2% - ~9 tests)

**What to Test:**
- Critical user journeys (end-to-end)
- Cross-module workflows
- Multi-device scenarios

**Example E2E Scenario:**
```dart
testWidgets('Complete user journey: Login → Workout → Meditation → Insight', (tester) async {
  // 1. Login
  await tester.tap(find.byType(LoginButton));
  await tester.enterText(find.byType(EmailField), 'test@example.com');
  await tester.enterText(find.byType(PasswordField), 'password123');
  await tester.tap(find.byType(SubmitButton));
  await tester.pumpAndSettle();

  // 2. Complete morning check-in (set high stress)
  await tester.tap(find.byType(MorningCheckInButton));
  await tester.drag(find.byType(StressSlider), Offset(200, 0)); // Stress = 5/5
  await tester.tap(find.text('Generate My Plan'));
  await tester.pumpAndSettle();

  // 3. Navigate to Fitness, see heavy workout scheduled
  await tester.tap(find.byIcon(Icons.fitness_center));
  await tester.pumpAndSettle();

  // 4. Verify cross-module insight appears
  expect(find.text('High Stress Alert'), findsOneWidget);
  expect(find.text('Switch to light workout'), findsOneWidget);

  // 5. Accept insight, verify light template loaded
  await tester.tap(find.text('Adjust Workout'));
  await tester.pumpAndSettle();
  expect(find.text('Light Upper Body'), findsOneWidget);
});
```

### 2.3 NFR Testing Approach

#### Performance (NFR-P1-P6)

**NFR-P1: App Size <50MB**
- **Test:** Bundle size monitoring in CI
- **Tool:** `flutter build apk --analyze-size`
- **Frequency:** Every PR
- **Pass Criteria:** APK size <50MB, AAB size <30MB

**NFR-P2: Cold Start <2s**
- **Test:** Startup performance test
- **Tool:** Flutter DevTools Timeline
- **Frequency:** Nightly
- **Pass Criteria:** Time to first frame <2000ms (P95)

**NFR-P4: Offline Max 10s**
- **Test:** Offline operation latency test
- **Scenario:** Log workout offline, measure save time
- **Pass Criteria:** Save to Drift <100ms (P95)

**NFR-P5: Memory Usage <250MB**
- **Test:** Memory profiling during typical session
- **Tool:** Flutter DevTools Memory
- **Frequency:** Weekly
- **Pass Criteria:** Peak memory <250MB active, <150MB background

**NFR-P6: Battery <5% in 8h**
- **Test:** Battery drain test (automated on physical device)
- **Tool:** Android Battery Historian, iOS Instruments
- **Frequency:** Weekly
- **Pass Criteria:** <5% drain in 8h typical use

#### Security (NFR-S1-S3)

**NFR-S1: E2EE for Journals**
- **Test:** Encryption/decryption validation
- **Scenario:**
  1. Encrypt journal entry with AES-256-GCM
  2. Store in Supabase
  3. Retrieve and decrypt
  4. Verify plaintext matches original
- **Pass Criteria:** 100% encrypt/decrypt success rate, no plaintext leakage

**NFR-S2: GDPR Compliance**
- **Test:** Data export/delete functionality
- **Scenario:**
  1. User requests data export → Verify ZIP contains all user data
  2. User deletes account → Verify all data removed from DB
- **Pass Criteria:** Export includes all tables, deletion cascades correctly

**NFR-S3: RLS Policy Coverage**
- **Test:** Row-Level Security penetration test
- **Scenario:** User A tries to access User B's data via API manipulation
- **Pass Criteria:** 403 Forbidden or empty result set (0 data leakage)

#### Scalability (NFR-SC1-SC4)

**NFR-SC1: 10k Concurrent Users**
- **Test:** Load testing on Supabase Edge Functions
- **Tool:** k6 load testing tool
- **Scenario:** 10,000 virtual users generating daily plans
- **Pass Criteria:** P95 latency <3s, 0 errors

**NFR-SC4: AI Costs <30% Revenue**
- **Test:** AI cost tracking validation
- **Scenario:** Simulate 10k users (20% paid) for 1 month
- **Pass Criteria:** AI API costs <30% of simulated revenue (€10,000)

#### Reliability (NFR-R1-R3)

**NFR-R1: 99.5% Uptime**
- **Test:** Uptime monitoring (production only)
- **Tool:** Supabase Status Dashboard
- **Frequency:** Continuous
- **Pass Criteria:** 99.5% uptime over 30-day rolling window

**NFR-R3: Data Loss <0.1%**
- **Test:** Sync failure recovery test
- **Scenario:**
  1. Create 1000 workouts offline
  2. Simulate network failures during sync (50% failure rate)
  3. Verify all workouts eventually sync
- **Pass Criteria:** 100% of data synced after retries

---

## 3. Risk Assessment

### 3.1 Testability Risks

#### R-001: Cross-Module Intelligence Complexity
- **Category:** TECH
- **Description:** CMI pattern detection logic is complex and novel. Risk: False positives (incorrect insights), false negatives (missing patterns), or AI-generated insights being nonsensical/harmful.
- **Probability:** 3 (High - new algorithm, no prior art)
- **Impact:** 3 (High - poor insights damage user trust, core differentiator)
- **Score:** 9 (P × I = 3 × 3)
- **Mitigation:**
  1. Golden dataset: 100 synthetic user scenarios with expected insights
  2. A/B test insights before showing to users (50% control group)
  3. User feedback loop ("Was this insight helpful?")
  4. Manual review of AI-generated insights (first 1000 users)
- **Owner:** AI Engineer + QA Lead
- **Timeline:** Pre-launch (Golden dataset), Post-launch (A/B testing ongoing)
- **Architecture Link:** D2 (Shared PostgreSQL Schema enables CMI)

#### R-002: E2EE Key Management Vulnerability
- **Category:** SEC
- **Description:** If user device is stolen and not biometric-locked, attacker can access encryption keys from secure storage (iOS Keychain/Android KeyStore) and decrypt journals.
- **Probability:** 2 (Medium - requires physical device access)
- **Impact:** 3 (Critical - journal privacy breach)
- **Score:** 6 (P × I = 2 × 3)
- **Mitigation:**
  1. Require biometric unlock for journal access (iOS Face ID, Android Fingerprint)
  2. Add "Secure Journal" setting: Re-encrypt with separate PIN
  3. Auto-logout after 15 min inactivity
  4. Penetration testing on iOS Keychain/Android KeyStore extraction
- **Owner:** Security Architect + Mobile Dev
- **Timeline:** MVP (Biometric required), P1 (Separate PIN option)
- **Architecture Link:** D5 (Client-Side E2EE)

#### R-003: Offline Sync Conflicts Cause Data Loss
- **Category:** DATA
- **Description:** User logs workout on Device A (offline), logs different workout on Device B (offline). Both sync when online → Last-write-wins strategy loses one workout.
- **Probability:** 3 (High - multi-device users common)
- **Impact:** 2 (Medium - data loss, user frustration)
- **Score:** 6 (P × I = 3 × 2)
- **Mitigation:**
  1. Conflict detection: Check timestamps, warn user on conflict
  2. Conflict resolution UI: "Keep Device A version" vs "Keep Device B version" vs "Keep both"
  3. Automated tests: 500 sync conflict scenarios
  4. Telemetry: Monitor sync conflict rate in production
- **Owner:** Backend Engineer + QA
- **Timeline:** MVP (Last-write-wins + logging), Month 3 (Conflict resolution UI)
- **Architecture Link:** D3 (Hybrid Sync Strategy)

#### R-004: AI API Downtime Breaks Core Features
- **Category:** OPS
- **Description:** Claude/GPT-4 APIs go down → Daily plan generation fails, AI chat unavailable. Risk: Users can't use paid features they subscribed for.
- **Probability:** 2 (Medium - APIs have 99.9% SLA but outages happen)
- **Impact:** 3 (High - paid feature unavailable, churn risk)
- **Score:** 6 (P × I = 2 × 3)
- **Mitigation:**
  1. Fallback to Llama (self-hosted) if Claude/GPT-4 timeout
  2. Cache last 3 daily plans per user (show cached plan if API down)
  3. Graceful error message: "AI temporarily unavailable, showing yesterday's plan"
  4. SLA monitoring: Alert on API latency >5s
- **Owner:** DevOps + Backend Engineer
- **Timeline:** MVP (Fallback logic), Month 1 (Caching)
- **Architecture Link:** D4 (AI Orchestration via Edge Functions)

#### R-005: Flutter 3.38 Compatibility Issues
- **Category:** TECH
- **Description:** Flutter 3.38 is not yet released (PRD specifies 3.38+). Risk: Breaking changes, bugs, incompatibility with packages (Riverpod, Drift).
- **Probability:** 2 (Medium - Flutter has stable release cycle)
- **Impact:** 2 (Medium - delays development, rework needed)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Use Flutter 3.24 LTS (stable) for MVP
  2. Upgrade to 3.38 in Month 6 (after stable release + community testing)
  3. Automated tests run on both Flutter 3.24 and 3.38-beta
  4. Pin package versions in pubspec.yaml
- **Owner:** Mobile Lead
- **Timeline:** MVP (Flutter 3.24), Month 6 (Upgrade to 3.38)
- **Architecture Link:** Section 7 (Tech Stack)

#### R-006: Supabase RLS Policy Gaps Allow Data Leakage
- **Category:** SEC
- **Description:** Missing or incorrect RLS policies allow users to access other users' data (e.g., workouts, journals).
- **Probability:** 2 (Medium - complex RLS policies, human error)
- **Impact:** 3 (Critical - data breach, GDPR violation)
- **Score:** 6 (P × I = 2 × 3)
- **Mitigation:**
  1. 100% RLS policy coverage (every table with user_id)
  2. Automated RLS tests: User A tries to access User B's data (expect 403)
  3. Penetration testing before launch
  4. Supabase Policy Analyzer (built-in tool)
- **Owner:** Security Architect + Backend
- **Timeline:** MVP (100% coverage required)
- **Architecture Link:** Section 3 (RLS Policies in Security Architecture)

#### R-007: Multi-Device Sync Race Conditions
- **Category:** TECH
- **Description:** User taps "Save Workout" on Device A, immediately opens Device B → Device B shows old data before sync completes. User confused, thinks data lost.
- **Probability:** 3 (High - multi-device users, slow networks)
- **Impact:** 2 (Medium - UX issue, no actual data loss)
- **Score:** 6 (P × I = 3 × 2)
- **Mitigation:**
  1. Optimistic UI: Show "Syncing..." indicator during sync
  2. Supabase Realtime: Device B receives update within 5s
  3. Conflict resolution: If both devices edit same data, show conflict UI
  4. Integration tests: Simulate 2 devices syncing same workout
- **Owner:** Mobile Dev + Backend
- **Timeline:** MVP (Realtime + indicators)
- **Architecture Link:** D3 (Hybrid Sync), NFR-S3 (Multi-device sync)

#### R-008: Test Data Factory Gaps Cause Flaky Tests
- **Category:** TECH
- **Description:** Insufficient test data factories (e.g., no factory for complex workouts with 10+ exercises) → Tests fail intermittently, hard to debug.
- **Probability:** 2 (Medium - common in large codebases)
- **Impact:** 2 (Medium - slows down development, false failures)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Comprehensive factory library: Workout, Meditation, Goal, JournalEntry
  2. Factory traits: `.withHighStress()`, `.withMultipleExercises()`, `.offline()`
  3. Seed database with 100+ realistic test users
  4. Golden snapshots for complex scenarios
- **Owner:** QA Lead
- **Timeline:** Week 1 of development (infrastructure setup)
- **Architecture Link:** Section 5.3 (Test Data Management)

#### R-009: Performance Regression Goes Undetected
- **Category:** PERF
- **Description:** New feature (e.g., complex CMI query) slows down app startup from 1.5s → 3.5s. Not caught until users complain.
- **Probability:** 2 (Medium - performance tests not in CI initially)
- **Impact:** 2 (Medium - poor UX, bad reviews)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. CI performance gates: Fail PR if startup time >2.5s
  2. Nightly performance test suite (run on physical devices)
  3. Firebase Performance Monitoring (production)
  4. Automated alerts: Slack notification if P95 latency >3s
- **Owner:** DevOps + QA
- **Timeline:** Sprint 3 (CI gates), Month 1 (Nightly suite)
- **Architecture Link:** NFR-P2 (Cold start <2s)

#### R-010: AI Quota Exceeded DoS Attack
- **Category:** SEC
- **Description:** Malicious user scripts 1000 AI requests/hour → Exceeds quota, blocks other users, costs spike.
- **Probability:** 2 (Medium - determined attacker)
- **Impact:** 2 (Medium - temporary unavailability, cost spike)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Rate limiting: Free tier = 5 AI calls/day, Standard = 30/day, Premium = 200/day
  2. Server-side enforcement (Edge Functions)
  3. IP-based rate limiting (secondary defense)
  4. Cost alerts: Notify admin if AI costs >€500/day
- **Owner:** Backend Engineer
- **Timeline:** MVP (Rate limiting required)
- **Architecture Link:** D4 (AI Orchestration), NFR-SC4 (AI costs <30%)

#### R-011: Meditation Audio Files Corrupt During Download
- **Category:** DATA
- **Description:** User downloads meditation audio (10MB), network interruption → File corrupt, playback fails, user frustrated.
- **Probability:** 2 (Medium - mobile networks unreliable)
- **Impact:** 2 (Medium - feature unavailable, bad UX)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Chunked download with resume support
  2. MD5 checksum validation after download
  3. Retry logic: Auto-retry up to 3 times
  4. User notification: "Download paused, will resume automatically"
- **Owner:** Mobile Dev
- **Timeline:** MVP (Chunked download + checksum)
- **Architecture Link:** D13 (Tiered Lazy Loading Cache)

#### R-012: GDPR Data Export Missing Tables
- **Category:** BUS
- **Description:** User requests GDPR data export → Export ZIP missing some tables (e.g., `detected_patterns`). GDPR violation, legal risk.
- **Probability:** 2 (Medium - manual export logic, easy to miss tables)
- **Impact:** 3 (High - GDPR fine up to €20M or 4% revenue)
- **Score:** 6 (P × I = 2 × 3)
- **Mitigation:**
  1. Automated test: Export for test user, verify all tables present (workouts, meditations, journals, goals, daily_metrics, patterns, etc.)
  2. Schema change alert: CI fails if new table added without export logic
  3. Legal review of export completeness
  4. User confirmation: "Your export includes X tables, Y records"
- **Owner:** Backend + Legal
- **Timeline:** MVP (100% export coverage required)
- **Architecture Link:** NFR-S2 (GDPR Compliance)

#### R-013: Riverpod State Management Memory Leaks
- **Category:** TECH
- **Description:** Complex Riverpod provider tree → Memory leaks when providers not disposed properly. App slows down over time.
- **Probability:** 2 (Medium - common Flutter issue)
- **Impact:** 2 (Medium - poor UX after 30+ min use)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Memory profiling tests: Run app for 1 hour, verify memory stable
  2. Provider lifecycle audit: Ensure autoDispose on all providers
  3. Flutter DevTools Memory: Weekly profiling sessions
  4. Automated tests: Memory growth <10MB/hour during typical use
- **Owner:** Mobile Lead
- **Timeline:** Sprint 5 (Profiling), Ongoing (Monitoring)
- **Architecture Link:** D1 (Riverpod 3.0 State Management)

#### R-014: Supabase Free Tier Limits Exceeded
- **Category:** OPS
- **Description:** Free tier allows 50k users, 500MB storage. Risk: Project paused mid-launch if limits exceeded.
- **Probability:** 1 (Low - monitored closely)
- **Impact:** 3 (Critical - service outage)
- **Score:** 3 (P × I = 1 × 3)
- **Mitigation:**
  1. Upgrade to Pro plan before 40k users (proactive)
  2. Monitoring dashboard: Track users, storage, API calls daily
  3. Alerts: Email + Slack when 80% of limit reached
  4. Cost forecast: Budget allocated for Pro plan ($25/month)
- **Owner:** DevOps + Product Manager
- **Timeline:** Month 1 (Monitoring), Month 6 (Proactive upgrade)
- **Architecture Link:** Section 11.3 (Scalability NFRs)

#### R-015: Drift Database Migration Fails on Upgrade
- **Category:** TECH
- **Description:** App upgrade from v1.0 to v1.1 → Drift schema migration fails (e.g., missing column). Users lose local data.
- **Probability:** 2 (Medium - manual migration logic)
- **Impact:** 3 (High - data loss, 1-star reviews)
- **Score:** 6 (P × I = 2 × 3)
- **Mitigation:**
  1. Automated migration tests: Old schema → New schema, verify data preserved
  2. Rollback-safe migrations: ALTER TABLE IF NOT EXISTS
  3. Backup before migration: Export Drift DB to JSON before upgrade
  4. Canary release: 5% of users get update first, monitor for issues
- **Owner:** Mobile Dev
- **Timeline:** Every app update
- **Architecture Link:** D3 (Drift local database)

#### R-016: App Store Rejection Due to Mental Health Disclaimer
- **Category:** BUS
- **Description:** Apple/Google rejects app for insufficient mental health disclaimers (GAD-7, PHQ-9 screening).
- **Probability:** 2 (Medium - strict App Store guidelines)
- **Impact:** 2 (Medium - delays launch 1-2 weeks)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Clear disclaimers: "Not a medical diagnosis, consult professional"
  2. Crisis resources: Suicide hotlines visible on screening results
  3. Pre-submission review: Legal + compliance check
  4. Beta testing on TestFlight: 100 users before submission
- **Owner:** Product Manager + Legal
- **Timeline:** Pre-launch (Disclaimers ready)
- **Architecture Link:** NFR-C4 (Mental Health Disclaimer)

#### R-017: Notification Spam Causes Uninstalls
- **Category:** BUS
- **Description:** Users receive too many notifications (morning, evening, streak alerts, insights) → Annoyed, uninstall app.
- **Probability:** 2 (Medium - easy to over-notify)
- **Impact:** 2 (Medium - churn, bad reviews)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Notification frequency cap: Max 3 notifications/day
  2. User controls: Granular settings (disable streak alerts, insights, etc.)
  3. Quiet hours: Default 10pm-7am, user customizable
  4. A/B test notification frequency: 1/day vs 3/day, measure retention
- **Owner:** Product Manager + Mobile Dev
- **Timeline:** MVP (Frequency cap), Month 1 (A/B testing)
- **Architecture Link:** Epic 8 (Notifications & Engagement)

#### R-018: Battery Drain from Background Sync
- **Category:** PERF
- **Description:** Aggressive background sync every 5 minutes → Battery drains 20% in 8 hours, users blame app.
- **Probability:** 2 (Medium - easy to over-sync)
- **Impact:** 2 (Medium - bad reviews, uninstalls)
- **Score:** 4 (P × I = 2 × 2)
- **Mitigation:**
  1. Opportunistic sync: Only when WiFi connected + charging
  2. No WorkManager polling: Event-driven sync only (user action triggers sync)
  3. Battery profiling: Weekly tests on physical devices
  4. Telemetry: Track battery drain in production (Firebase Performance)
- **Owner:** Mobile Dev + QA
- **Timeline:** MVP (Opportunistic sync only)
- **Architecture Link:** D11 (Opportunistic Sync), NFR-P6 (Battery <5%)

### 3.2 Risk Scoring Matrix

| Priority | Score Range | Count | Risks |
|----------|-------------|-------|-------|
| **High** | ≥6 | 7 | R-001, R-002, R-003, R-004, R-006, R-007, R-015 |
| **Medium** | 3-5 | 8 | R-005, R-008, R-009, R-010, R-011, R-013, R-016, R-017 |
| **Low** | 1-2 | 3 | R-014, R-018, (R-012 downgraded after mitigation) |

**Mitigation Progress Tracking:**

| Risk | Mitigation Status | Estimated Completion |
|------|-------------------|---------------------|
| R-001 | In Progress | Sprint 10 (Golden dataset) |
| R-002 | Planned | Sprint 2 (Biometric required) |
| R-003 | Planned | Sprint 1 (Logging), Sprint 8 (UI) |
| R-004 | Planned | Sprint 4 (Fallback logic) |
| R-006 | Planned | Sprint 1 (RLS coverage) |
| R-015 | Planned | Every release (automated tests) |

---

## 4. Test Coverage Plan

### 4.1 Epic-Level Coverage

#### Epic 1: Core Platform Foundation (6 stories)

**Scope:** Authentication, data sync, GDPR compliance

**Critical Test Scenarios:**
1. User registration with email (valid/invalid inputs)
2. Login with email, Google, Apple (success/failure)
3. Password reset flow (email verification)
4. Multi-device sync (offline writes → online sync)
5. GDPR data export (verify all tables included)
6. GDPR account deletion (cascade deletes verified)
7. Session persistence across app restarts
8. Offline data integrity (no data loss)

**Test Level Distribution:**
- Unit: 18 tests (use cases, repositories)
- Widget: 6 tests (login screen, profile screen)
- Integration: 8 tests (Supabase auth, sync)
- E2E: 2 tests (full login → sync → delete flow)
- **Total: 34 tests**

**Priority Distribution:**
- P0: 12 tests (auth, data sync critical)
- P1: 14 tests (GDPR export, profile management)
- P2: 6 tests (edge cases)
- P3: 2 tests (cosmetic UI)

**Estimated Test Count:** 34 tests
**Risk Linkage:** R-003 (Sync conflicts), R-006 (RLS policies), R-012 (GDPR export)

---

#### Epic 2: Life Coach MVP (10 stories)

**Scope:** Daily planning, goals, AI chat, check-ins

**Critical Test Scenarios:**
1. Morning check-in (mood, energy, sleep sliders)
2. Evening reflection (accomplishments, tomorrow prep)
3. AI daily plan generation (Llama/Claude/GPT-4 routing)
4. Goal creation (max 3 for free tier)
5. Goal progress tracking (% completion)
6. AI conversation (quota enforcement: 3-5/day free)
7. Streak tracking (7d, 30d, 100d milestones)
8. Weekly summary report (aggregate metrics)
9. AI personality (Sage vs Momentum tone)
10. Fallback plan when AI API down

**Test Level Distribution:**
- Unit: 42 tests (use cases, AI routing, streak logic)
- Widget: 12 tests (check-in modal, goal cards, chat UI)
- Integration: 6 tests (AI API calls, daily plan storage)
- E2E: 1 test (check-in → plan → goal → streak milestone)
- **Total: 61 tests**

**Priority Distribution:**
- P0: 15 tests (check-in, daily plan generation)
- P1: 28 tests (goals, AI chat, streaks)
- P2: 14 tests (weekly reports, edge cases)
- P3: 4 tests (AI personality nuances)

**Estimated Test Count:** 61 tests
**Risk Linkage:** R-004 (AI API downtime), R-010 (AI quota DoS)

---

#### Epic 3: Fitness Coach MVP (10 stories)

**Scope:** Smart Pattern Memory, workout logging, progress charts

**Critical Test Scenarios:**
1. Smart Pattern Memory (pre-fill last workout)
2. Workout logging (sets, reps, weight)
3. Exercise library search (<200ms response)
4. Custom exercise creation
5. Rest timer (auto-start, countdown, skip)
6. Progress charts (weight lifted, volume, PRs)
7. Body measurements tracking
8. Workout templates (pre-built + custom)
9. Quick log mode (<30s full workout)
10. Cross-module: Receive stress data, adjust intensity

**Test Level Distribution:**
- Unit: 48 tests (pattern memory, logging logic, chart calculations)
- Widget: 14 tests (workout screens, charts, templates)
- Integration: 8 tests (Drift save, Supabase sync)
- E2E: 2 tests (log workout → sync → view chart)
- **Total: 72 tests**

**Priority Distribution:**
- P0: 18 tests (pattern memory, logging, sync)
- P1: 32 tests (charts, templates, measurements)
- P2: 18 tests (quick log, custom exercises)
- P3: 4 tests (UI polish)

**Estimated Test Count:** 72 tests
**Risk Linkage:** R-003 (Sync conflicts), R-007 (Multi-device race conditions)

---

#### Epic 4: Mind & Emotion MVP (12 stories)

**Scope:** Meditation, mood tracking, CBT chat, E2EE journaling

**Critical Test Scenarios:**
1. Meditation library (filter by length, theme)
2. Meditation player (play/pause, scrubber, breathing animation)
3. Mood tracking (emoji slider, always FREE)
4. Stress tracking (shared with Fitness/Life Coach)
5. CBT chat (1/day free, unlimited premium)
6. E2EE journaling (encrypt/decrypt, key storage)
7. Mental health screening (GAD-7, PHQ-9)
8. Crisis resources display (high scores)
9. Breathing exercises (5 techniques, haptic feedback)
10. Sleep meditations (auto-stop timer)
11. Gratitude exercises (3 good things)
12. Cross-module: Share mood/stress data

**Test Level Distribution:**
- Unit: 52 tests (E2EE, scoring logic, data sharing)
- Widget: 16 tests (meditation player, mood sliders, journal UI)
- Integration: 10 tests (E2EE storage, audio playback, API sync)
- E2E: 2 tests (mood → CBT chat → journal → screening)
- **Total: 80 tests**

**Priority Distribution:**
- P0: 20 tests (E2EE, mood tracking, meditation playback)
- P1: 36 tests (CBT chat, screening, breathing)
- P2: 20 tests (sleep meditations, gratitude)
- P3: 4 tests (UI animations)

**Estimated Test Count:** 80 tests
**Risk Linkage:** R-002 (E2EE key vulnerability), R-011 (Audio file corruption), R-016 (Mental health disclaimers)

---

#### Epic 5: Cross-Module Intelligence (5 stories)

**Scope:** Pattern detection, AI insights, cross-module recommendations

**Critical Test Scenarios:**
1. Insight engine (daily pattern detection)
2. High stress + heavy workout → suggest light session
3. Poor sleep + morning workout → suggest afternoon
4. Sleep quality + workout performance correlation
5. Insight card UI (swipeable, CTA actions)
6. Insight priority filtering (max 1/day)
7. Golden dataset validation (100 scenarios)
8. False positive detection
9. User feedback loop ("Was this helpful?")
10. A/B testing framework (50% control group)

**Test Level Distribution:**
- Unit: 28 tests (pattern detection algorithms, correlation math)
- Widget: 4 tests (insight card UI)
- Integration: 12 tests (cross-module data queries, AI insight generation)
- E2E: 2 tests (full journey: stress → workout → insight → action)
- **Total: 46 tests**

**Priority Distribution:**
- P0: 14 tests (pattern detection, insight generation)
- P1: 20 tests (specific scenarios, CTA actions)
- P2: 10 tests (golden dataset validation)
- P3: 2 tests (A/B testing framework)

**Estimated Test Count:** 46 tests
**Risk Linkage:** R-001 (CMI complexity), R-007 (Multi-device data consistency)

---

#### Epic 6: Gamification & Retention (6 stories)

**Scope:** Streaks, badges, celebrations, weekly reports

**Critical Test Scenarios:**
1. Streak tracking (workout, meditation, check-in)
2. Streak freeze (1/week, auto-apply on first miss)
3. Milestone badges (Bronze 7d, Silver 30d, Gold 100d)
4. Confetti animation (on badge unlock)
5. Shareable milestone cards (social sharing)
6. Weekly summary report (all modules)
7. Streak break alerts (push notification)
8. Celebration sound/haptic feedback

**Test Level Distribution:**
- Unit: 24 tests (streak logic, badge calculations)
- Widget: 8 tests (confetti animation, badge cards)
- Integration: 4 tests (notification triggers, report generation)
- E2E: 1 test (streak milestone → badge → share)
- **Total: 37 tests**

**Priority Distribution:**
- P0: 8 tests (streak tracking, freeze logic)
- P1: 18 tests (badges, reports, notifications)
- P2: 9 tests (animations, sharing)
- P3: 2 tests (sound effects)

**Estimated Test Count:** 37 tests
**Risk Linkage:** R-017 (Notification spam)

---

#### Epic 7: Onboarding & Subscriptions (7 stories)

**Scope:** Onboarding flow, trial, subscription management

**Critical Test Scenarios:**
1. Choose journey (Fitness/Mind/Life Coach/Full)
2. Set initial goals (1-3)
3. Choose AI personality (Sage/Momentum)
4. Grant permissions (notifications, health data)
5. Interactive tutorial (journey-specific)
6. 14-day trial activation
7. Subscription tiers (free, 2.99, 5.00, 7.00 EUR)
8. In-app purchase flow (iOS/Android)
9. Cancel subscription (graceful degradation)
10. Feature gate enforcement (free tier limits)

**Test Level Distribution:**
- Unit: 18 tests (trial logic, feature gates, tier enforcement)
- Widget: 10 tests (onboarding screens, subscription UI)
- Integration: 6 tests (IAP, Stripe, tier sync)
- E2E: 1 test (full onboarding → trial → subscribe → cancel)
- **Total: 35 tests**

**Priority Distribution:**
- P0: 10 tests (trial, IAP, feature gates)
- P1: 16 tests (onboarding, subscription UI)
- P2: 7 tests (tutorial, permissions)
- P3: 2 tests (AI personality preview)

**Estimated Test Count:** 35 tests
**Risk Linkage:** R-014 (Supabase tier limits)

---

#### Epic 8: Notifications & Engagement (5 stories)

**Scope:** Push notifications, reminders, quiet hours

**Critical Test Scenarios:**
1. FCM infrastructure setup
2. Daily reminders (morning, evening, workout)
3. Streak alerts (about to break)
4. Cross-module insight notifications (max 1/day)
5. Weekly summary notification
6. Quiet hours enforcement (10pm-7am)
7. Deep linking (tap notification → open screen)
8. Notification frequency cap (max 3/day)
9. User controls (enable/disable by category)

**Test Level Distribution:**
- Unit: 16 tests (notification logic, frequency cap)
- Widget: 4 tests (notification settings UI)
- Integration: 8 tests (FCM, deep linking)
- E2E: 1 test (notification → tap → deep link)
- **Total: 29 tests**

**Priority Distribution:**
- P0: 8 tests (FCM, deep linking)
- P1: 14 tests (reminders, alerts, quiet hours)
- P2: 6 tests (frequency cap, settings)
- P3: 1 test (notification sound)

**Estimated Test Count:** 29 tests
**Risk Linkage:** R-017 (Notification spam)

---

#### Epic 9: Settings & Profile (5 stories)

**Scope:** Account management, preferences, privacy

**Critical Test Scenarios:**
1. Update personal info (name, email, avatar)
2. Change password (confirmation required)
3. Notification preferences (toggles)
4. Unit preferences (kg/lbs, cm/inches)
5. Subscription management (upgrade/downgrade)
6. Data privacy settings (cross-module sharing, AI analysis)
7. GDPR export (all data)
8. GDPR delete (account deletion)

**Test Level Distribution:**
- Unit: 14 tests (update logic, unit conversion)
- Widget: 8 tests (settings screens, toggles)
- Integration: 6 tests (Supabase updates, GDPR)
- E2E: 1 test (update settings → sync across devices)
- **Total: 29 tests**

**Priority Distribution:**
- P0: 6 tests (GDPR export, delete)
- P1: 14 tests (personal info, subscription)
- P2: 7 tests (preferences, units)
- P3: 2 tests (UI polish)

**Estimated Test Count:** 29 tests
**Risk Linkage:** R-012 (GDPR export completeness)

---

### 4.2 Cross-Cutting Concerns

#### Authentication & Authorization (RLS, Feature Gates)

**Test Scenarios:**
1. RLS policy coverage (every table with user_id)
2. User A cannot access User B's data (penetration test)
3. Free tier blocked from premium features (meditation library, fitness module)
4. Subscription tier enforcement (free, standard, premium, lifeos_plus)
5. JWT token expiration handling (7-day max)
6. Session refresh on token near-expiry

**Test Count:** 18 tests (12 Unit, 4 Integration, 2 E2E)
**Priority:** P0 (security critical)

---

#### Data Sync (Offline-First, Conflict Resolution)

**Test Scenarios:**
1. Write offline → Sync when online (100% success rate)
2. Sync queue priority (critical vs non-critical)
3. Sync conflict detection (same record edited on 2 devices)
4. Last-write-wins conflict resolution
5. Sync retry on failure (exponential backoff)
6. Sync status indicator (syncing/synced/offline)
7. Multi-device sync race conditions

**Test Count:** 24 tests (8 Unit, 8 Integration, 8 E2E)
**Priority:** P0 (data integrity critical)

---

#### AI Integration (LLM Routing, Quota Management)

**Test Scenarios:**
1. AI routing by tier (Free → Llama, Standard → Claude, Premium → GPT-4)
2. AI quota enforcement (3-5/day free, 30/day standard, unlimited premium)
3. AI timeout handling (10s max, fallback to cache)
4. AI cost tracking (per user, per tier)
5. AI fallback on API failure (Llama self-hosted)
6. AI prompt injection prevention (sanitize user input)

**Test Count:** 20 tests (12 Unit, 6 Integration, 2 E2E)
**Priority:** P0 (core feature, cost control)

---

#### Error Handling (Result<T> Pattern)

**Test Scenarios:**
1. Success<T> path (happy path)
2. Failure<T> with NetworkException (offline)
3. Failure<T> with SyncConflictException (conflict)
4. Failure<T> with AIQuotaExceededException (quota)
5. Failure<T> with SubscriptionRequiredException (paywall)
6. Error message user-friendliness (no technical jargon)

**Test Count:** 16 tests (14 Unit, 2 Widget)
**Priority:** P1 (UX critical)

---

#### Analytics & Logging

**Test Scenarios:**
1. Anonymized event tracking (no PII)
2. User ID hashing (SHA-256)
3. Log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
4. Sentry error tracking (production only)
5. Firebase Performance monitoring (production only)
6. GDPR-compliant logging (no email, no sensitive data)

**Test Count:** 12 tests (10 Unit, 2 Integration)
**Priority:** P2 (monitoring, non-blocking)

---

### 4.3 NFR-Specific Tests

#### NFR-P1: App Size <50MB
**Test:** Bundle size monitoring
**Frequency:** Every PR
**Tool:** `flutter build apk --analyze-size`
**Pass Criteria:** APK <50MB, AAB <30MB
**Automation:** CI/CD (GitHub Actions)

#### NFR-P2: Cold Start <2s
**Test:** Startup performance test
**Frequency:** Nightly
**Tool:** Flutter DevTools Timeline
**Pass Criteria:** Time to first frame <2000ms (P95)
**Automation:** Nightly job on physical device

#### NFR-P4: Offline Max 10s
**Test:** Offline operation latency
**Scenario:** Log workout offline, measure Drift save time
**Pass Criteria:** <100ms (P95)
**Automation:** Integration test

#### NFR-S1: E2EE Validation
**Test:** Encrypt/decrypt roundtrip
**Scenario:** Encrypt journal → Store → Retrieve → Decrypt → Verify
**Pass Criteria:** 100% success, no plaintext leakage
**Automation:** Unit + Integration tests

#### NFR-S2: GDPR Export
**Test:** Data export completeness
**Scenario:** Export for test user, verify all tables present
**Pass Criteria:** 12/12 tables included (workouts, meditations, journals, goals, etc.)
**Automation:** Integration test

#### NFR-S3: RLS Penetration Test
**Test:** User A tries to access User B's data
**Scenario:** API request with manipulated user_id
**Pass Criteria:** 403 Forbidden or empty result set
**Automation:** Integration test

#### NFR-SC1: Load Test (10k Users)
**Test:** Concurrent user simulation
**Tool:** k6 load testing
**Scenario:** 10,000 users generate daily plans simultaneously
**Pass Criteria:** P95 latency <3s, 0 errors
**Automation:** Weekly scheduled job

#### NFR-SC4: AI Cost Tracking
**Test:** Cost validation for 10k users
**Scenario:** Simulate 1 month usage (20% paid users)
**Pass Criteria:** AI costs <30% of €10,000 revenue (i.e., <€3,000)
**Automation:** Monthly simulation

#### NFR-R3: Sync Failure Recovery
**Test:** Data loss prevention
**Scenario:** Create 1000 workouts offline, simulate 50% network failure during sync
**Pass Criteria:** 100% of data synced after retries
**Automation:** Integration test

**Total NFR Tests:** 37 tests (27 automated, 10 manual profiling)

---

## 5. Test Infrastructure

### 5.1 Framework & Tools

#### Flutter Testing Framework

**Unit Tests:**
```dart
// pubspec.yaml dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  test: ^1.24.0

// Example: test/domain/use_cases/complete_workout_use_case_test.dart
@GenerateMocks([FitnessRepository, AIService])
void main() {
  late CompleteWorkoutUseCase useCase;
  late MockFitnessRepository mockRepository;

  setUp(() {
    mockRepository = MockFitnessRepository();
    useCase = CompleteWorkoutUseCase(repository: mockRepository);
  });

  test('should save workout to repository', () async {
    // Arrange
    final workout = Workout(id: '1', name: 'Push Day');
    when(mockRepository.saveWorkout(workout))
      .thenAnswer((_) async => Success(workout));

    // Act
    final result = await useCase.call(workout);

    // Assert
    expect(result, isA<Success<Workout>>());
    verify(mockRepository.saveWorkout(workout)).called(1);
  });
}
```

**Widget Tests:**
```dart
// Example: test/presentation/screens/morning_check_in_test.dart
void main() {
  testWidgets('MorningCheckInModal displays mood slider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: MorningCheckInModal()),
      ),
    );

    // Verify UI elements
    expect(find.byType(MoodSlider), findsOneWidget);
    expect(find.text('How are you feeling?'), findsOneWidget);

    // Simulate user interaction
    await tester.drag(find.byType(MoodSlider), Offset(100, 0));
    await tester.pumpAndSettle();

    // Verify state change
    expect(find.text('😊'), findsOneWidget);
  });
}
```

**Integration Tests:**
```dart
// integration_test/offline_sync_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Offline workout sync', (tester) async {
    await tester.pumpWidget(MyApp());

    // 1. Go offline
    await NetworkSimulator.setOffline();

    // 2. Log workout
    await tester.tap(find.byKey(Key('log_workout_button')));
    await tester.enterText(find.byKey(Key('exercise_input')), 'Squat');
    await tester.tap(find.byKey(Key('save_button')));
    await tester.pumpAndSettle();

    // 3. Verify saved locally
    expect(find.text('Saved offline'), findsOneWidget);

    // 4. Go online
    await NetworkSimulator.setOnline();
    await tester.pumpAndSettle(Duration(seconds: 5));

    // 5. Verify synced
    expect(find.text('Synced'), findsOneWidget);
  });
}
```

#### Backend Testing (Supabase)

**PostgreSQL Test Database:**
```bash
# supabase/test/setup.sh
#!/bin/bash

# Start local Supabase
supabase start

# Apply migrations
supabase db reset

# Seed test data
psql -h localhost -U postgres -d postgres -f supabase/seed.sql
```

**Edge Function Testing:**
```typescript
// supabase/functions/generate-daily-plan/test.ts
import { assertEquals } from 'https://deno.land/std@0.168.0/testing/asserts.ts'
import { handler } from './index.ts'

Deno.test('generates daily plan for user', async () => {
  const req = new Request('http://localhost', {
    method: 'POST',
    headers: { 'Authorization': 'Bearer test-token' },
    body: JSON.stringify({ userId: 'test-user-1', date: '2025-01-16' }),
  })

  const res = await handler(req)
  assertEquals(res.status, 200)

  const body = await res.json()
  assertEquals(body.tasks.length, 7) // 7 tasks in daily plan
})
```

#### Mocking Strategy

**Mockito for Dependencies:**
```dart
@GenerateMocks([
  FitnessRepository,
  LifeCoachRepository,
  MindRepository,
  AIService,
  SyncService,
  E2EEService,
  AuthService,
])
void main() {
  // Mocks available in all tests
}
```

**Fake Services for Integration Tests:**
```dart
class FakeSupabaseClient implements SupabaseClient {
  final _storage = <String, List<Map<String, dynamic>>>{};

  @override
  Future<List<Map<String, dynamic>>> from(String table).select() {
    return Future.value(_storage[table] ?? []);
  }

  @override
  Future<void> from(String table).insert(Map<String, dynamic> data) {
    _storage.putIfAbsent(table, () => []).add(data);
  }
}
```

### 5.2 Test Environments

#### Local Development
**Setup:**
- Flutter SDK 3.24+ (LTS)
- Supabase local stack (`supabase start`)
- PostgreSQL test DB (seed data loaded)
- Android Emulator (Pixel 6, API 33)
- iOS Simulator (iPhone 14, iOS 16)

**Environment Variables:**
```bash
# .env.test
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

**Run Tests:**
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/presentation/

# Integration tests (requires emulator/simulator)
flutter test integration_test/
```

#### CI Environment (GitHub Actions)

**Configuration:** `.github/workflows/test.yml`
```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  unit_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  widget_test:
    runs-on: ubuntu-latest
    needs: unit_test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test test/presentation/

  integration_test:
    runs-on: macos-latest
    needs: unit_test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2

      - name: Start Supabase local
        run: |
          brew install supabase/tap/supabase
          supabase start

      - name: Run integration tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 33
          script: flutter test integration_test/
```

#### Staging Environment

**Purpose:** QA testing before production
**Infrastructure:**
- Supabase Staging Project (`lifeos-staging`)
- Dedicated PostgreSQL database
- Test user accounts (100 seeded)
- Firebase App Distribution (beta testers)

**Access:**
```bash
# Deploy to staging
flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging
firebase appdistribution:distribute build/app/outputs/apk/staging/app-staging-release.apk \
  --app 1:12345:android:abc123 \
  --groups internal-testers
```

#### Production Environment

**Monitoring Only:**
- No destructive tests in production
- Read-only queries for smoke tests
- Sentry error monitoring
- Firebase Performance monitoring

**Smoke Tests (Post-Deploy):**
```bash
# Run after production deploy
flutter drive --driver=test_driver/integration_driver.dart \
              --target=integration_test/smoke_test.dart \
              --flavor prod \
              --dart-define=ENVIRONMENT=prod
```

### 5.3 Test Data Management

#### Seed Data Scripts

**PostgreSQL Seed:** `supabase/seed.sql`
```sql
-- Create test users
INSERT INTO auth.users (id, email, encrypted_password) VALUES
  ('user-1', 'test1@example.com', 'hashed-password-1'),
  ('user-2', 'test2@example.com', 'hashed-password-2'),
  ('user-3', 'test3@example.com', 'hashed-password-3');

-- Create test workouts
INSERT INTO workouts (id, user_id, name, completed_at) VALUES
  ('workout-1', 'user-1', 'Push Day', '2025-01-15 10:00:00'),
  ('workout-2', 'user-1', 'Pull Day', '2025-01-16 10:00:00');

-- Create test meditations
INSERT INTO meditations (id, user_id, duration_minutes, completed_at) VALUES
  ('med-1', 'user-1', 10, '2025-01-15 20:00:00'),
  ('med-2', 'user-1', 15, '2025-01-16 20:00:00');

-- Create test goals
INSERT INTO goals (id, user_id, title, category) VALUES
  ('goal-1', 'user-1', 'Lose 10kg', 'fitness'),
  ('goal-2', 'user-1', 'Meditate daily', 'mental_health');
```

#### Factories for Model Generation

**Dart Factories:**
```dart
// test/fixtures/factories/workout_factory.dart
class WorkoutFactory {
  static Workout create({
    String? id,
    String? userId,
    String? name,
    int? duration,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? 'workout-${uuid.v4()}',
      userId: userId ?? 'test-user-1',
      name: name ?? 'Test Workout',
      duration: duration ?? 60,
      exercises: exercises ?? [ExerciseFactory.create()],
      completedAt: DateTime.now(),
    );
  }

  static Workout withHighVolume() {
    return create(
      exercises: List.generate(
        10,
        (i) => ExerciseFactory.create(sets: 5, reps: 12),
      ),
    );
  }

  static Workout offline() {
    return create(
      id: 'offline-workout-${uuid.v4()}',
      // No completedAt → synced = false
    );
  }
}
```

**Usage in Tests:**
```dart
test('high volume workout triggers rest day suggestion', () async {
  final workout = WorkoutFactory.withHighVolume();
  final result = await cmiService.analyzeWorkout(workout);

  expect(result.suggestion, contains('rest day'));
});
```

#### Cleanup Scripts

**Reset Test DB Between Runs:**
```bash
# test/scripts/reset_db.sh
#!/bin/bash

# Drop all test data
psql -h localhost -U postgres -d lifeos_test -c "TRUNCATE workouts, meditations, goals, journal_entries, user_daily_metrics CASCADE;"

# Re-seed
psql -h localhost -U postgres -d lifeos_test -f supabase/seed.sql

echo "Test database reset complete"
```

**Run Before Test Suite:**
```dart
// test/setup.dart
void main() {
  setUpAll(() async {
    // Reset database
    await Process.run('bash', ['test/scripts/reset_db.sh']);

    // Initialize test environment
    await dotenv.load(fileName: '.env.test');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  });
}
```

---

## 6. Execution Strategy

### 6.1 Continuous Integration

#### Commit (Developer Push)
**Trigger:** Every commit to feature branch
**Duration:** <5 minutes
**Tests Run:**
- Unit tests only (~320 tests)
- Code analysis (`flutter analyze`)
- Code formatting check (`dart format`)

**Quality Gate:**
- All unit tests pass (100%)
- No analysis errors
- Code formatted correctly

**Pipeline:**
```yaml
# Commit stage
- flutter pub get
- flutter analyze
- dart format --set-exit-if-changed .
- flutter test --no-pub  # Unit tests only
```

#### Pull Request to Main
**Trigger:** PR opened/updated
**Duration:** <15 minutes
**Tests Run:**
- Unit tests (~320 tests)
- Widget tests (~92 tests)
- P0 integration tests (~12 tests)

**Quality Gate:**
- All unit tests pass (100%)
- Widget tests pass (≥95%)
- P0 integration tests pass (100%)
- Code coverage ≥80%

**Pipeline:**
```yaml
# PR stage
- flutter pub get
- flutter analyze
- flutter test --coverage  # Unit + Widget
- flutter test integration_test/p0/  # P0 only
- codecov upload coverage/lcov.info
```

**Coverage Report:**
```bash
# Automated comment on PR
Coverage: 84.2% (+2.1%)
✅ Unit: 86.5%
✅ Widget: 78.3%
⚠️ Integration: N/A (run on merge)
```

#### Merge to Main
**Trigger:** PR merged to main
**Duration:** <30 minutes
**Tests Run:**
- Full unit test suite (~320 tests)
- Full widget test suite (~92 tests)
- All integration tests (~37 tests)
- E2E critical paths (~9 tests)

**Quality Gate:**
- P0 tests: 100% pass (no failures allowed)
- P1 tests: ≥95% pass
- E2E tests: 100% pass (critical paths)

**Pipeline:**
```yaml
# Merge stage (full suite)
- flutter test  # All unit + widget
- flutter test integration_test/  # All integration
- flutter drive --target=integration_test/e2e/critical_paths.dart  # E2E
```

**Failure Handling:**
- Merge blocked if any P0 test fails
- Slack alert to #dev channel
- Rollback PR if E2E fails

#### Nightly Build
**Trigger:** Cron (2am UTC)
**Duration:** <2 hours
**Tests Run:**
- Full test suite (all 458 tests)
- NFR performance tests (startup, memory, battery)
- Load testing (Edge Functions)
- Security scanning (OWASP ZAP)

**Additional Tasks:**
- Build APK/IPA (staging flavor)
- Deploy to Firebase App Distribution
- Performance profiling (Flutter DevTools)
- Database backup and restore test

**Pipeline:**
```yaml
# Nightly stage
- flutter test  # All tests
- flutter test integration_test/nfr/  # NFR tests
- k6 run load_test.js  # Load test Edge Functions
- owasp-zap scan  # Security scan
- flutter build apk --flavor staging
- firebase appdistribution:distribute
```

**Reporting:**
```markdown
# Nightly Build Report (2025-01-16)

## Test Results
✅ Unit: 320/320 (100%)
✅ Widget: 92/92 (100%)
✅ Integration: 37/37 (100%)
✅ E2E: 9/9 (100%)

## Performance
✅ Cold start: 1.8s (target: <2s)
⚠️ Memory: 265MB peak (target: <250MB) - INVESTIGATE
✅ Battery: 4.2% in 8h (target: <5%)

## Security
✅ OWASP ZAP: 0 high-risk findings
✅ Dependency audit: 0 vulnerabilities

## Next Actions
- Investigate memory spike (265MB vs 250MB target)
- Review load test results (10k users → P95 latency 2.8s)
```

### 6.2 Test Prioritization

#### P0 (Critical) - Run on Every Commit
**Criteria:**
- Blocks core user flows (login, workout logging, meditation playback)
- High-risk areas (E2EE, RLS, sync)
- Must pass 100% (no failures tolerated)

**Examples:**
- User can log in with email/password
- Workout saves offline and syncs when online
- Journal entry encrypted before storage
- RLS prevents cross-user data access

**Count:** 78 tests (~17% of total)
**Execution Time:** <3 minutes

#### P1 (High) - Run on PR
**Criteria:**
- Important features (AI chat, daily plan, progress charts)
- Common user workflows (goals, streaks, templates)
- Must pass ≥95% (max 2-3 failures allowed)

**Examples:**
- AI daily plan generation routes to correct model
- Goal progress updates correctly
- Streak tracking increments on workout completion
- Cross-module insights generated

**Count:** 184 tests (~40% of total)
**Execution Time:** <10 minutes

#### P2 (Medium) - Run Nightly
**Criteria:**
- Edge cases (offline sync conflicts, API timeouts)
- Secondary features (gratitude exercises, breathing techniques)
- Performance regressions (startup time, memory)
- Must pass ≥90%

**Examples:**
- Sync conflict resolution UI displays correctly
- Meditation audio caching works offline
- Weekly report aggregates all module data
- App startup time <2s

**Count:** 138 tests (~30% of total)
**Execution Time:** <15 minutes

#### P3 (Low) - Run Weekly
**Criteria:**
- Cosmetic issues (animations, UI polish)
- Exploratory tests (manual QA)
- Accessibility tests (screen reader)
- Must pass ≥80%

**Examples:**
- Confetti animation plays on badge unlock
- Haptic feedback fires on mood slider
- VoiceOver reads workout stats correctly
- Dark mode renders all screens properly

**Count:** 58 tests (~13% of total)
**Execution Time:** <5 minutes (automated) + 2 hours (manual)

### 6.3 Quality Gates

#### Commit Quality Gate
**Pass Criteria:**
- Unit tests: 100% pass
- Code analysis: 0 errors
- Code formatting: 100% compliant

**Failure Action:**
- Block commit (pre-commit hook)
- Developer fixes locally

#### PR Quality Gate
**Pass Criteria:**
- P0 tests: 100% pass (no failures)
- P1 tests: ≥95% pass (max 9 failures)
- Code coverage: ≥80% (unit tests)
- Widget coverage: ≥60%

**Failure Action:**
- Block PR merge
- Automated comment: "Tests failing, please fix"
- Developer fixes in PR

#### Merge Quality Gate
**Pass Criteria:**
- All unit tests: 100% pass
- All widget tests: ≥95% pass
- E2E critical paths: 100% pass (9/9)
- No P0 test failures

**Failure Action:**
- Block merge to main
- Slack alert: "@channel - Main branch blocked!"
- Rollback PR if merged accidentally

#### Nightly Quality Gate
**Pass Criteria:**
- Full suite: ≥95% pass (max 23 failures)
- NFR tests: All pass
- Load test: P95 latency <3s
- Security scan: 0 high-risk findings

**Failure Action:**
- Email to #dev + #qa channels
- Create Jira tickets for failures
- No merge freeze (can continue development)

#### Production Deployment Gate
**Pass Criteria:**
- All quality gates passed (commit → PR → merge → nightly)
- Manual QA sign-off (Product Manager)
- Staging environment tested (100 beta users, 7 days)
- Performance benchmarks met (startup, memory, battery)

**Failure Action:**
- Block production deploy
- Escalate to Tech Lead
- Fix issues in hotfix branch

---

## 7. Resource Estimates

### 7.1 Test Development Effort

**Calculation Methodology:**

| Priority | Test Count | Hours/Test | Total Hours |
|----------|-----------|------------|-------------|
| **P0 (Critical)** | 78 | 2.0 | 156 |
| **P1 (High)** | 184 | 1.0 | 184 |
| **P2 (Medium)** | 138 | 0.5 | 69 |
| **P3 (Low)** | 58 | 0.25 | 15 |
| **Subtotal** | 458 | - | 424 |

**Adjustments:**
- Framework reuse: -20% (85 hours saved)
- Factory setup time: +10 hours
- Documentation: +8 hours

**Adjusted Total:** 357 hours (45 developer-days)

**Breakdown by Epic:**

| Epic | P0 | P1 | P2 | P3 | Total Tests | Hours |
|------|----|----|----|----|-------------|-------|
| Epic 1: Core Platform | 12 | 14 | 6 | 2 | 34 | 54 |
| Epic 2: Life Coach | 15 | 28 | 14 | 4 | 61 | 83 |
| Epic 3: Fitness | 18 | 32 | 18 | 4 | 72 | 102 |
| Epic 4: Mind | 20 | 36 | 20 | 4 | 80 | 116 |
| Epic 5: CMI | 14 | 20 | 10 | 2 | 46 | 76 |
| Epic 6: Gamification | 8 | 18 | 9 | 2 | 37 | 49 |
| Epic 7: Subscriptions | 10 | 16 | 7 | 2 | 35 | 49 |
| Epic 8: Notifications | 8 | 14 | 6 | 1 | 29 | 39 |
| Epic 9: Settings | 6 | 14 | 7 | 2 | 29 | 40 |
| **Cross-Cutting** | 28 | 42 | 20 | 10 | 100 | 134 |
| **Total** | **139** | **234** | **117** | **33** | **523** | **742** |

**Note:** Total test count increased from 458 to 523 after adding cross-cutting tests. Adjusted effort estimate: 742 hours raw → 594 hours (after 20% reuse) → **600 hours total**.

**Timeline (1 Developer):**
- 600 hours ÷ 8 hours/day = 75 days
- 75 days ÷ 5 days/week = **15 weeks (3.75 months)**

**Timeline (2 Developers, Parallel):**
- 600 hours ÷ 2 = 300 hours per developer
- 300 hours ÷ 8 hours/day = 37.5 days
- 37.5 days ÷ 5 days/week = **7.5 weeks (2 months)**

### 7.2 Infrastructure Setup

**Tasks:**

| Task | Duration | Owner | Dependencies |
|------|----------|-------|--------------|
| **Test framework setup** | 2 days | QA Lead | None |
| - Flutter test config | 0.5 days | - | - |
| - Mockito + build_runner | 0.5 days | - | - |
| - Integration test harness | 1 day | - | - |
| **CI/CD pipeline** | 1 day | DevOps | Test framework |
| - GitHub Actions workflows | 0.5 days | - | - |
| - Coverage reporting | 0.25 days | - | - |
| - Quality gates | 0.25 days | - | - |
| **Test data factories** | 2 days | QA + Dev | Test framework |
| - Model factories (Workout, Meditation, etc.) | 1 day | - | - |
| - Seed database scripts | 0.5 days | - | - |
| - Cleanup utilities | 0.5 days | - | - |
| **Supabase test environment** | 1 day | Backend + DevOps | None |
| - Local Supabase setup | 0.25 days | - | - |
| - Staging Supabase project | 0.5 days | - | - |
| - RLS policies (test mode) | 0.25 days | - | - |
| **NFR test infrastructure** | 1 day | QA + DevOps | Test framework |
| - k6 load testing setup | 0.5 days | - | - |
| - Firebase Performance config | 0.25 days | - | - |
| - OWASP ZAP integration | 0.25 days | - | - |
| **Documentation** | 0.5 days | QA Lead | All above |
| - Test strategy doc | 0.25 days | - | - |
| - Test execution guide | 0.25 days | - | - |

**Total Infrastructure Setup:** 7.5 days (1.5 weeks)

**Grand Total Effort:**
- Test development: 600 hours (75 days / 15 weeks with 1 dev)
- Infrastructure setup: 60 hours (7.5 days)
- **Total: 660 hours (82.5 days / 16.5 weeks with 1 developer)**
- **Total: 337.5 hours (42 days / 8.5 weeks with 2 developers in parallel)**

---

## 8. Success Criteria

### 8.1 Coverage Metrics

**Unit Test Coverage:** ≥80%
- Measured by: `flutter test --coverage`
- Target: 80% line coverage, 75% branch coverage
- Critical paths: 100% coverage (auth, sync, E2EE)

**Widget Test Coverage:** ≥60%
- Measured by: Widget test count / Widget count
- Target: 60% of UI components tested
- Critical screens: 100% coverage (login, workout log, meditation player)

**E2E Critical Paths:** 100%
- All 9 critical user journeys covered
- 0 critical paths untested

**NFR Validation:** 37/37 NFRs
- Every NFR has ≥1 test validating it
- Performance NFRs: Automated monitoring
- Security NFRs: Automated + manual penetration tests

**Epic Coverage:** 100%
- All 9 epics have test scenarios
- All 66 stories covered by ≥1 test

### 8.2 Quality Metrics

**P0 Defect Escape Rate:** <1%
- Measured by: P0 bugs found in production ÷ Total P0 tests
- Target: <1% (max 1 P0 bug per 100 tests)
- Action: Root cause analysis for every P0 escape

**Test Execution Time:**
- Commit stage: <5 minutes (unit tests only)
- PR stage: <15 minutes (unit + widget + P0 integration)
- Full suite: <30 minutes (all tests)
- Nightly: <2 hours (includes NFR tests)

**Test Flakiness:** <2%
- Measured by: Flaky test runs ÷ Total test runs
- Target: <2% flaky tests
- Action: Fix or quarantine flaky tests immediately

**Regression Detection:** ≥95%
- Measured by: Regressions caught by tests ÷ Total regressions
- Target: ≥95% of regressions caught before production
- Action: Add tests for any escaped regression

**Code Coverage Trend:**
- Baseline: 0% (start of project)
- Sprint 3: ≥60%
- Sprint 6: ≥75%
- Sprint 10: ≥80% (target)
- Never decrease below 75%

**Automated vs Manual:**
- Automated: ≥90% of tests (523/523 automated)
- Manual: <10% (exploratory testing, accessibility)
- Automation gap: 0 critical tests manual-only

### 8.3 Production Metrics

**Crash-Free Rate:** >99.5%
- Measured by: Firebase Crashlytics
- Target: 99.5% of sessions crash-free
- Action: Fix crashes within 24 hours

**Performance Benchmarks:**
- Cold start: <2s (P95) - Automated
- Hot start: <500ms (P95) - Automated
- Memory: <250MB active - Weekly profiling
- Battery: <5% in 8h - Weekly test on physical devices
- App size: <50MB APK - Every build

**Security Compliance:**
- RLS coverage: 100% of tables with user_id
- E2EE validation: 100% encrypt/decrypt success
- GDPR compliance: 100% export completeness
- Penetration test: 0 high-risk findings

**Availability:**
- Uptime: 99.5% (measured by Supabase)
- Sync success rate: >99% (within 3 retries)
- AI API availability: >99.9% (with fallback)

---

## 9. Next Steps

### 9.1 Immediate Actions (Sprint 1 - Infrastructure Setup)

**Week 1:**
1. **Setup Flutter Test Framework** (2 days)
   - Install dependencies (flutter_test, mockito, build_runner)
   - Configure `test/` directory structure
   - Create base test utilities (mock helpers, test constants)
   - Write first unit test (example: `AuthService.signIn()`)

2. **Configure GitHub Actions CI** (1 day)
   - Create `.github/workflows/test.yml`
   - Setup commit stage (unit tests only, <5 min)
   - Setup PR stage (unit + widget, <15 min)
   - Configure coverage reporting (Codecov)

3. **Create Test Data Factories** (2 days)
   - `WorkoutFactory` (with traits: `.withHighVolume()`, `.offline()`)
   - `MeditationFactory`
   - `GoalFactory`
   - `JournalEntryFactory`
   - Seed database script (`supabase/seed.sql`)

4. **Setup Supabase Test Environment** (1 day)
   - Local Supabase (`supabase start`)
   - Apply migrations to test DB
   - Create test users (100 seeded accounts)
   - Configure .env.test

**Week 2:**
5. **Implement P0 Tests for Epic 1** (Core Platform)
   - Authentication tests (login, signup, OAuth)
   - Offline sync tests (write offline → sync online)
   - RLS penetration tests (User A cannot access User B's data)
   - GDPR export/delete tests

6. **Setup NFR Test Infrastructure** (1 day)
   - k6 load testing script (generate-daily-plan endpoint)
   - Firebase Performance config
   - OWASP ZAP integration (security scan)

7. **Documentation** (0.5 days)
   - Test strategy summary (this document condensed)
   - Test execution guide (how to run tests locally)
   - Contributing guidelines (how to write tests)

**Deliverables (Sprint 1):**
- ✅ Test framework operational
- ✅ CI/CD pipeline running (commit + PR stages)
- ✅ Test data factories ready
- ✅ Supabase test environment configured
- ✅ 34 P0 tests written for Epic 1 (Core Platform)
- ✅ Documentation published

### 9.2 Recommended Workflows

**After Sprint 1 Infrastructure Setup:**

#### Option 1: Epic-by-Epic Testing (Recommended)
Run ATDD workflow for each epic as it's developed:

**Sprint 2-3: Epic 2 (Life Coach MVP)**
```bash
bmad workflow atdd --epic=2 --priority=P0
```
- Generates 15 P0 ATDD tests for Life Coach
- Developer implements features + tests in parallel
- CI validates on every commit

**Sprint 4-6: Epic 3 (Fitness Coach MVP)**
```bash
bmad workflow atdd --epic=3 --priority=P0,P1
```
- 18 P0 + 32 P1 tests
- Focus on Smart Pattern Memory (killer feature)

**Sprint 7-9: Epic 4 (Mind & Emotion MVP)**
```bash
bmad workflow atdd --epic=4 --priority=P0,P1
```
- 20 P0 + 36 P1 tests
- Critical: E2EE encryption tests

**Sprint 10-11: Epic 5 (Cross-Module Intelligence)**
```bash
bmad workflow atdd --epic=5 --priority=P0,P1
```
- 14 P0 + 20 P1 tests
- Validate golden dataset (100 scenarios)

**Sprint 12-13: Epics 6-9 (Polish & Launch)**
```bash
bmad workflow atdd --epic=6,7,8,9 --priority=P1,P2
```
- Remaining P1/P2 tests
- Manual QA (accessibility, exploratory)

#### Option 2: Risk-Driven Testing
Prioritize high-risk areas first:

**Sprint 2: R-002 (E2EE Security)**
```bash
bmad workflow framework --type=security --feature=e2ee
```
- Implement E2EE encryption tests
- Penetration testing framework
- Key management vulnerability tests

**Sprint 3: R-001 (CMI Complexity)**
```bash
bmad workflow framework --type=integration --feature=cmi
```
- Golden dataset creation (100 scenarios)
- Pattern detection algorithm tests
- AI insight validation

**Sprint 4: R-003 (Offline Sync Conflicts)**
```bash
bmad workflow framework --type=integration --feature=sync
```
- 500 sync conflict scenarios
- Multi-device race condition tests
- Conflict resolution UI tests

#### Option 3: Full CI/CD Setup First
```bash
bmad workflow ci --platform=github-actions
```
- Generates complete CI/CD pipeline
- Nightly builds + NFR tests
- Production deployment automation

**When to Run:**
- Sprint 1: Setup local testing
- Sprint 2: Add PR stage
- Sprint 4: Add nightly stage
- Sprint 6: Add production deployment

### 9.3 Testing Roadmap (Sprints 1-13)

**Sprint 1-2: Foundation (Weeks 1-4)**
- Test framework setup
- Epic 1 P0 tests (34 tests)
- CI/CD commit + PR stages
- Target coverage: 60%

**Sprint 3-4: Life Coach (Weeks 5-8)**
- Epic 2 P0 + P1 tests (43 tests)
- AI routing tests
- Target coverage: 70%

**Sprint 5-7: Fitness (Weeks 9-14)**
- Epic 3 P0 + P1 tests (50 tests)
- Smart Pattern Memory validation
- Offline sync tests
- Target coverage: 75%

**Sprint 8-9: Mind (Weeks 15-18)**
- Epic 4 P0 + P1 tests (56 tests)
- E2EE encryption tests
- Mental health screening validation
- Target coverage: 78%

**Sprint 10-11: CMI (Weeks 19-22)**
- Epic 5 P0 + P1 tests (34 tests)
- Golden dataset (100 scenarios)
- Cross-module integration tests
- Target coverage: 80%

**Sprint 12-13: Polish & Launch (Weeks 23-26)**
- Epics 6-9 P1 + P2 tests (90 tests)
- NFR validation (all 37 NFRs)
- Manual QA (accessibility, exploratory)
- Load testing (10k users)
- Security penetration testing
- Target coverage: 82%

**Post-Launch: Continuous Testing**
- Nightly regression suite
- Performance monitoring
- User feedback-driven tests
- A/B testing framework

---

## Appendix A: Test Scenario Examples

### A.1 Epic 1: Core Platform - P0 Test

**Test ID:** CORE-001
**Priority:** P0
**Type:** Integration
**Epic:** Epic 1 (Core Platform)
**Story:** 1.5 (Data Sync Across Devices)
**FR:** FR98

**Test Scenario:** Offline workout logging syncs to Supabase when online

**Preconditions:**
- User logged in
- Supabase reachable
- Drift local database initialized

**Test Steps:**
1. Set device offline (simulate airplane mode)
2. Log workout: "Push Day", 3 exercises, 9 sets
3. Verify workout saved to Drift (local database)
4. Verify sync queue contains workout (priority: HIGH)
5. Set device online (restore network)
6. Wait 5 seconds for sync
7. Query Supabase `workouts` table
8. Verify workout synced (all fields match local)
9. Verify sync queue cleared

**Expected Result:**
- Workout appears in Supabase with correct data
- Sync status: "Synced" (green checkmark in UI)
- No data loss, no duplicates

**Pass Criteria:**
- 100% data integrity (all fields match)
- Sync latency <5s (P95)
- 0 errors in logs

---

### A.2 Epic 5: CMI - P0 Test

**Test ID:** CMI-001
**Priority:** P0
**Type:** E2E
**Epic:** Epic 5 (Cross-Module Intelligence)
**Story:** 5.3 (High Stress + Heavy Workout → Suggest Light Session)
**FR:** FR77

**Test Scenario:** High stress triggers workout adjustment insight

**Preconditions:**
- User logged in
- Mood module active (stress tracking enabled)
- Fitness module active (workout scheduled)

**Test Steps:**
1. **Morning Check-In:**
   - Open morning check-in modal
   - Set stress level = 5/5 (very high)
   - Set mood = 2/5 (low)
   - Tap "Generate My Plan"
2. **Navigate to Fitness:**
   - Tap Fitness tab
   - Verify heavy workout scheduled ("Leg Day - High Volume")
3. **Verify Insight Appears:**
   - Insight card displayed: "High Stress Alert"
   - Description: "Your stress level is high today (5/5) and you have a heavy leg day scheduled."
   - Recommendation: "Switch to upper body (light) OR take a rest day + meditate"
   - CTA: "Adjust Workout" button visible
4. **Accept Insight:**
   - Tap "Adjust Workout"
   - Verify light template loaded: "Light Upper Body"
   - Verify exercises replaced (no heavy squats/deadlifts)
5. **Verify Logged in Database:**
   - Query `detected_patterns` table
   - Verify pattern type = 'high_stress_heavy_workout'
   - Verify user action = 'accepted'

**Expected Result:**
- Insight appears within 2 seconds of navigating to Fitness
- Light workout template loads correctly
- User action logged for AI learning

**Pass Criteria:**
- Insight detection: 100% (for stress ≥4 + heavy workout)
- UI render time: <2s
- Template swap: 100% correct exercises

---

## Appendix B: Risk Mitigation Tracker

| Risk ID | Mitigation Status | Sprint | Owner | Evidence |
|---------|-------------------|--------|-------|----------|
| R-001 | In Progress | 10 | AI Engineer | Golden dataset: 40/100 scenarios |
| R-002 | Planned | 2 | Security | Biometric requirement implemented |
| R-003 | In Progress | 1 | Backend | Conflict detection logging active |
| R-004 | Planned | 4 | Backend | Fallback logic designed, not implemented |
| R-005 | Mitigated | 1 | Mobile Lead | Flutter 3.24 LTS selected |
| R-006 | Planned | 1 | Security | RLS policies: 8/12 tables covered |
| R-007 | Planned | 2 | Mobile + Backend | Realtime subscriptions configured |
| R-008 | In Progress | 1 | QA | Factories: 3/5 complete (Workout, Meditation, Goal) |
| R-009 | Planned | 3 | DevOps | CI performance gates: Not yet implemented |
| R-010 | Planned | 1 | Backend | Rate limiting: Designed, not implemented |
| R-011 | Planned | 2 | Mobile | Chunked download: Not yet implemented |
| R-012 | Planned | 1 | Backend | Export test: 10/12 tables covered |
| R-013 | Planned | 5 | Mobile | Memory profiling: Not yet conducted |
| R-014 | Monitoring | 1 | DevOps | Supabase usage: 120 users, 12MB storage (24% of limit) |
| R-015 | Planned | Every Release | Mobile | Migration tests: Not yet implemented |
| R-016 | Mitigated | Pre-launch | Product + Legal | Disclaimers drafted, legal review pending |
| R-017 | Planned | 1 | Product | Frequency cap: Designed, not implemented |
| R-018 | Mitigated | 1 | Mobile | Opportunistic sync implemented |

**Last Updated:** 2025-01-16
**Next Review:** Sprint 3 Retrospective

---

## Document Status

**Version:** 1.0
**Status:** ✅ Ready for Implementation
**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Next Review:** Sprint 3 (Week 6)

**Approvals:**
- QA Lead: [Pending]
- Tech Lead: [Pending]
- Product Manager: [Pending]

**Change Log:**
- 2025-01-16: Initial version created (Phase 3 - Testability Review)

---

**Total Document Length:** ~16,500 words
**Total Test Scenarios Defined:** 523 tests
**Coverage:** 123 FRs, 37 NFRs, 9 Epics, 66 Stories
**Effort Estimate:** 600 hours test development + 60 hours infrastructure = 660 hours (16.5 weeks with 1 developer, 8.5 weeks with 2 developers)

_This System-Level Test Design document was created by the QA Architect using the BMAD Methodology, based on the PRD (123 FRs, 37 NFRs), Architecture (13 architectural decisions), Epics (9 epics, 66 stories), Security Architecture, and DevOps Strategy._

**Ready to implement! Test early, test often, ship with confidence.**
