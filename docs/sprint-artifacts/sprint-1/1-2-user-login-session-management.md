# Story 1.2: User Login & Session Management

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** drafted
**Estimated Effort:** 2 SP

---

## User Story

**As a** returning user
**I want** to log in securely and stay logged in across app restarts
**So that** I don't have to re-authenticate every time I open the app

---

## Acceptance Criteria

1. ✅ User can log in with email + password
2. ✅ User can log in with Google OAuth 2.0
3. ✅ User can log in with Apple Sign-In
4. ✅ Session persists for 30 days of inactivity
5. ✅ User auto-logged in on app restart if session valid
6. ✅ User can log out manually (session cleared)
7. ✅ Error handling: Invalid credentials, account not verified, session expired
8. ✅ "Remember me" checkbox (optional, defaults to true)

---

## Functional Requirements Covered

- **FR2:** User login with email/password and social auth, persistent sessions

---

## UX Notes

- Login screen: Email + password fields, "Forgot password?" link
- Social auth buttons above email login
- "Don't have an account? Sign up" link at bottom
- Loading state during authentication

**Design Reference:** UX Design Specification - Authentication Flow

---

## Technical Implementation

### Frontend (Flutter)

**File:** `lib/features/auth/presentation/pages/login_page.dart`

**Key Components:**
```dart
class LoginPage extends ConsumerWidget {
  // Email/password form
  // Social auth buttons
  // Remember me checkbox
  // Forgot password link
  // Error handling
}
```

**Session Management:**
```dart
// Auto-login on app start
class AppInitializer {
  Future<void> checkAuthStatus() async {
    final session = await supabase.auth.currentSession;
    if (session != null && !session.isExpired) {
      // Navigate to Home
    } else {
      // Navigate to Login
    }
  }
}
```

### Backend (Supabase)

**Session Configuration:**
```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseKey,
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce, // Secure flow
  ),
);
```

**Token Storage:**
- iOS: Keychain (secure storage)
- Android: EncryptedSharedPreferences

**Token Refresh:**
- Auto-refresh 5 minutes before expiration
- Silent refresh (no user interaction)

### Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Invalid credentials | "Email or password is incorrect" | Highlight fields |
| Account not verified | "Please verify your email before logging in" | Show resend link |
| Session expired | "Your session has expired. Please log in again." | Clear session, show login |
| Network error | "Connection failed. Please try again." | Retry button |

---

## Dependencies

**Prerequisites:**
- Story 1.1 (User Account Creation - accounts must exist)

**Blocks:**
- All other features (login is required for app access)

---

## Testing Requirements

### Unit Tests
```dart
test('should login user with valid credentials')
test('should fail with invalid password')
test('should persist session after app restart')
test('should auto-refresh token before expiration')
```

### Widget Tests
```dart
testWidgets('should display email and password fields')
testWidgets('should show error on invalid credentials')
testWidgets('should navigate to home on success')
testWidgets('should show forgot password link')
```

### Integration Tests
```dart
testWidgets('complete login flow with email')
testWidgets('session persists after app restart')
testWidgets('auto-login with valid session')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] User can log in with email + password
- [ ] User can log in with Google OAuth
- [ ] User can log in with Apple Sign-In
- [ ] Session persists for 30 days
- [ ] Auto-login works on app restart
- [ ] Manual logout works (session cleared)
- [ ] All error cases handled
- [ ] Unit tests pass (80%+ coverage)
- [ ] Widget tests pass
- [ ] Integration test passes
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**Security:**
- PKCE flow for OAuth (prevents token interception)
- Tokens stored in secure storage (Keychain/EncryptedSharedPreferences)
- Auto-logout after 30 days inactivity

**Performance:**
- Login should complete in <1s
- Auto-login on app start <500ms

**UX:**
- Show loading indicator during login
- Disable login button during request (prevent double-tap)

---

## Related Stories

- **Previous:** Story 1.1 (User Account Creation)
- **Next:** Story 1.3 (Password Reset Flow)

---

**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
