# Epic 1: Core Platform Foundation

<!-- AI-INDEX: epic-1, core, platform, authentication, auth, sync, gdpr, foundation -->

**Epic ID:** EPIC-1
**Status:** ✅ ~90% Complete
**Priority:** P0 (MVP Critical)
**Stories:** 6

---

## Overview

| Aspect | Value |
|--------|-------|
| **Goal** | Establish core auth, data sync, and GDPR compliance foundation |
| **Value** | Users can create accounts, log in securely, sync data across devices |
| **FRs Covered** | FR1-FR5 (Auth), FR98-FR103 (Data & Privacy) |
| **Dependencies** | None (foundation epic) |
| **Sprint** | Sprint 1 |

---

## User Stories

| ID | Story | Points | Status | Sprint |
|----|-------|--------|--------|--------|
| 1.1 | User Account Creation | 5 | ✅ Done | 1 |
| 1.2 | User Login & Session Management | 3 | ✅ Done | 1 |
| 1.3 | Password Reset Flow | 3 | ✅ Done | 1 |
| 1.4 | User Profile Management | 5 | ✅ Done | 1 |
| 1.5 | Data Sync Across Devices | 8 | ✅ Done | 1 |
| 1.6 | GDPR Compliance (Export & Deletion) | 5 | ✅ Done | 1 |

**Total Points:** 29

---

## Story Details

### Story 1.1: User Account Creation

**As a** new user
**I want** to create an account using email or social authentication
**So that** I can start using LifeOS and have my data synced

**Acceptance Criteria:**
1. Register with email + password (min 8 chars, 1 uppercase, 1 number, 1 special)
2. Register with Google OAuth 2.0 (Android + iOS)
3. Register with Apple Sign-In (iOS)
4. Email verification sent (expires 24h)
5. User profile created with defaults
6. Redirect to onboarding after success
7. Error handling: Email exists, invalid format, weak password
8. Supabase Auth integration working

**Technical Notes:**
- Supabase Auth (email + social providers)
- PostgreSQL user table with RLS
- Flutter Supabase SDK

---

### Story 1.2: User Login & Session Management

**As a** returning user
**I want** to log in securely and stay logged in
**So that** I don't re-authenticate every app open

**Acceptance Criteria:**
1. Login with email + password
2. Login with Google OAuth 2.0
3. Login with Apple Sign-In
4. Session persists 30 days
5. Auto-login on app restart if valid
6. Manual logout clears session
7. Error handling: Invalid credentials, not verified
8. "Remember me" option

**Technical Notes:**
- Session token in flutter_secure_storage
- Auto-refresh before expiration

---

### Story 1.3: Password Reset Flow

**As a** user who forgot password
**I want** to reset via email
**So that** I can regain access

**Acceptance Criteria:**
1. Request reset from login screen
2. Email with reset link (expires 1h)
3. Deep link opens password change screen
4. New password validation
5. Auto-login after success
6. Old password invalidated
7. Error handling: Email not found, link expired

---

### Story 1.4: User Profile Management

**As a** user
**I want** to update my profile
**So that** my account reflects current details

**Acceptance Criteria:**
1. Update name
2. Update email (requires re-verification)
3. Update avatar (upload from gallery/camera)
4. Change password (requires current password)
5. Changes synced across devices
6. Avatar upload to Supabase Storage (max 5MB)
7. Error handling

---

### Story 1.5: Data Sync Across Devices

**As a** user with multiple devices
**I want** my data synced in real-time
**So that** I can seamlessly switch devices

**Acceptance Criteria:**
1. Workout data synced (<5s latency)
2. Mood logs synced
3. Goals synced
4. Meditation progress synced
5. Offline sync (queued, synced when online)
6. Conflict resolution: Last-write-wins
7. Sync status indicator

**Technical Notes:**
- Supabase Realtime subscriptions
- Drift (SQLite) for offline-first
- Sync queue for offline writes

---

### Story 1.6: GDPR Compliance

**As a** user concerned about privacy
**I want** to export or delete my data
**So that** I comply with GDPR rights

**Acceptance Criteria:**
1. Request data export from Profile → Data & Privacy
2. Export generates ZIP (JSON + CSV)
3. Includes: workouts, mood, goals, meditations, journals, account
4. Download link via email (expires 7 days)
5. Request account deletion (password required)
6. Deletion removes all data within 7 days
7. Irreversible warning shown
8. Purge from backups after 30 days

---

## Definition of Done

- [x] All stories implemented
- [x] Unit tests >80% coverage
- [x] Integration tests passing
- [x] Auth flows work on iOS + Android
- [x] Offline sync working
- [x] GDPR export/delete functional
- [x] RLS policies verified

---

## Technical Decisions

| Decision | Choice |
|----------|--------|
| Auth Provider | Supabase Auth |
| Session Storage | flutter_secure_storage |
| Offline DB | Drift (SQLite) |
| Sync | Supabase Realtime + Queue |
| Conflict Resolution | Last-write-wins |

---

## Dependencies

| Dependency | Status |
|------------|--------|
| Supabase project setup | ✅ |
| Flutter SDK 3.38+ | ✅ |
| Database migrations | ✅ |

---

**Source:** `docs/ecosystem/epics.md` (lines 44-264)
