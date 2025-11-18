# Story 1.1: User Account Creation

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** ready-for-dev
**Estimated Effort:** 3 SP

---

## User Story

**As a** new user
**I want** to create an account using email or social authentication
**So that** I can start using LifeOS and have my data synced across devices

---

## Acceptance Criteria

1. ✅ User can register with email + password (min 8 chars, 1 uppercase, 1 number, 1 special char)
2. ✅ User can register with Google OAuth 2.0 (Android + iOS)
3. ✅ User can register with Apple Sign-In (iOS)
4. ✅ Email verification sent after registration (link expires in 24h)
5. ✅ User profile created with default settings (name, email, avatar placeholder)
6. ✅ User redirected to onboarding flow after successful registration
7. ✅ Error handling: Email already exists, invalid email format, weak password
8. ✅ Supabase Auth integration working (session management)

---

## Functional Requirements Covered

- **FR1:** User registration with email/password and social auth (Google, Apple)

---

## UX Notes

- Use Supabase Auth UI library (styled with LifeOS Deep Blue theme)
- Social auth buttons: Google (white), Apple (black)
- "Sign up with email" option below social buttons
- Privacy policy link visible before registration

**Design Reference:** UX Design Specification - Authentication Flow

---

## Technical Implementation

### Frontend (Flutter)

**File:** `lib/features/auth/presentation/pages/register_page.dart`

**Packages:**
- `supabase_flutter` (authentication)
- `flutter_riverpod` (state management)
- `go_router` (navigation)

**Key Components:**
```dart
class RegisterPage extends ConsumerWidget {
  // Email/password form
  // Google OAuth button
  // Apple Sign-In button
  // Form validation
  // Error handling
}
```

**State Management:**
```dart
// Provider: authStateProvider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
```

### Backend (Supabase)

**Database:**
```sql
-- users table (auto-created by Supabase Auth)
-- user_profiles table
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policy
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = id);
```

**Email Template:**
- Customize Supabase email verification template with LifeOS branding
- Deep link: `lifeos://verify?token={token}`

### Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Email exists | "This email is already registered. Try logging in?" | Show login link |
| Weak password | "Password must be 8+ chars with uppercase, number, special char" | Highlight requirements |
| Invalid email | "Please enter a valid email address" | Show inline error |
| Network error | "Connection failed. Please try again." | Retry button |

---

## Dependencies

**Prerequisites:** None (first story in Epic 1)

**Blocks:**
- Story 1.2 (Login requires registration)
- Story 1.4 (Profile management requires account)
- All other features (auth is foundation)

---

## Testing Requirements

### Unit Tests
```dart
// lib/features/auth/domain/usecases/register_user_test.dart
test('should create user with valid email and password')
test('should fail with weak password')
test('should fail with existing email')
```

### Widget Tests
```dart
// lib/features/auth/presentation/pages/register_page_test.dart
testWidgets('should display email and password fields')
testWidgets('should show error on weak password')
testWidgets('should navigate to onboarding on success')
```

### Integration Tests
```dart
// integration_test/auth/register_flow_test.dart
testWidgets('complete registration flow with email')
testWidgets('complete registration flow with Google OAuth')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] User can register with email + password
- [ ] User can register with Google OAuth (Android + iOS)
- [ ] User can register with Apple Sign-In (iOS)
- [ ] Email verification sent and working
- [ ] User profile created in database
- [ ] Navigation to onboarding flow works
- [ ] All error cases handled gracefully
- [ ] Unit tests pass (80%+ coverage)
- [ ] Widget tests pass
- [ ] Integration test passes
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**Security:**
- Password validation enforced server-side (Supabase Auth)
- No plaintext passwords stored
- OAuth tokens stored securely (iOS Keychain, Android KeyStore)

**GDPR:**
- User can delete account later (Story 1.6)
- Privacy policy link shown before registration

**Performance:**
- Registration should complete in <2s (excluding email send)
- OAuth redirect should be <1s

---

## Related Stories

- **Next:** Story 1.2 (User Login & Session Management)
- **Depends On:** Epic 7 Story 7.1 (Onboarding Flow - redirection target)

---

## Dev Agent Record

### Context Reference

- **Story Context File:** [1-1-user-account-creation.context.xml](./1-1-user-account-creation.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

**Created:** 2025-01-16
**Last Updated:** 2025-11-17 - Context generated, status changed to ready-for-dev
**Author:** Bob (Scrum Master - BMAD)
