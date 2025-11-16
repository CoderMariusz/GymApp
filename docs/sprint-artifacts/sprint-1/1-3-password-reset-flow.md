# Story 1.3: Password Reset Flow

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** drafted
**Estimated Effort:** 2 SP

---

## User Story

**As a** user who forgot their password
**I want** to reset it via email
**So that** I can regain access to my account

---

## Acceptance Criteria

1. ✅ User can request password reset from login screen
2. ✅ Email sent with reset link (expires in 1 hour)
3. ✅ Reset link opens password change screen (deep link)
4. ✅ User can set new password (same validation as registration)
5. ✅ User auto-logged in after successful password reset
6. ✅ Old password invalidated after reset
7. ✅ Error handling: Email not found, link expired, weak new password

---

## Functional Requirements Covered

- **FR3:** Password reset via email

---

## UX Notes

- "Forgot password?" link on login screen → Modal with email input
- "Check your email" confirmation screen
- Password reset screen: New password + confirm password fields
- Success message: "Password reset successfully! Logging you in..."

**Design Reference:** UX Design Specification - Authentication Flow

---

## Technical Implementation

### Frontend (Flutter)

**Files:**
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/reset_password_page.dart`

**Forgot Password Flow:**
```dart
class ForgotPasswordPage extends ConsumerWidget {
  Future<void> sendResetEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'lifeos://reset-password',
    );
  }
}
```

**Reset Password Flow:**
```dart
class ResetPasswordPage extends ConsumerWidget {
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    // Auto-login user
  }
}
```

### Backend (Supabase)

**Email Template:**
- Customize password reset email with LifeOS branding
- Reset link: `lifeos://reset-password?token={token}`
- Link expires in 1 hour (Supabase default)

**Deep Link Handling:**
```dart
// lib/core/routing/deep_link_handler.dart
class DeepLinkHandler {
  void handleDeepLink(Uri uri) {
    if (uri.path == '/reset-password') {
      // Extract token, navigate to ResetPasswordPage
    }
  }
}
```

### Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Email not found | "No account found with this email" | Suggest sign up |
| Link expired | "This reset link has expired. Request a new one." | Show request button |
| Weak password | "Password must be 8+ chars with uppercase, number, special char" | Highlight requirements |
| Network error | "Connection failed. Please try again." | Retry button |

---

## Dependencies

**Prerequisites:**
- Story 1.1 (User accounts must exist)
- Story 1.2 (Login flow for auto-login after reset)

---

## Testing Requirements

### Unit Tests
```dart
test('should send reset email for valid email')
test('should fail if email not found')
test('should update password with valid token')
test('should fail with expired token')
```

### Widget Tests
```dart
testWidgets('should display email input')
testWidgets('should show confirmation after email sent')
testWidgets('should display new password fields on reset page')
```

### Integration Tests
```dart
testWidgets('complete password reset flow')
testWidgets('auto-login after password reset')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] User can request password reset
- [ ] Email sent with reset link
- [ ] Deep link opens reset password screen
- [ ] User can set new password
- [ ] Password validation enforced
- [ ] User auto-logged in after reset
- [ ] Old password invalidated
- [ ] All error cases handled
- [ ] Unit tests pass (80%+ coverage)
- [ ] Widget tests pass
- [ ] Integration test passes
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**Security:**
- Reset token expires in 1 hour (cannot be reused)
- Old password immediately invalidated
- Password validation same as registration (8+ chars, etc.)

**GDPR:**
- Reset emails don't expose user data
- User can request account deletion if locked out (Story 1.6)

**Performance:**
- Email sent in <3s
- Password update in <1s

---

## Related Stories

- **Previous:** Story 1.2 (User Login & Session Management)
- **Next:** Story 1.4 (User Profile Management)

---

**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
