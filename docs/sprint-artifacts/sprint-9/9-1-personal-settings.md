# Story 9.1: Personal Settings (Name, Email, Password, Avatar)

**Epic:** Epic 9 - Settings & Profile
**Sprint:** 9
**Story Points:** 3
**Priority:** P0
**Status:** Draft

---

## User Story

**As a** user
**I want** to update my personal information (name, email, password, avatar)
**So that** my profile is accurate and secure

---

## Acceptance Criteria

- ✅ User can update **name** (1-50 characters, instant update with optimistic UI)
- ✅ User can update **email** (requires verification, confirmation email sent)
- ✅ User can change **password** (requires current password, must be 8+ chars with 1 uppercase, 1 number, 1 special char)
- ✅ User can upload/change **avatar** (compressed to 512x512, upload <2s)
- ✅ Avatar displayed in header, profile screen, and settings
- ✅ Email change requires verification (user must click link in email)
- ✅ Password change requires current password confirmation
- ✅ Settings update with optimistic UI (<200ms perceived latency)

---

## Technical Implementation

See: `docs/sprint-artifacts/tech-spec-epic-9.md` Section 3.1

**Key Services:**
- `UserSettingsService.updateName()`
- `UserSettingsService.updateEmail()` (Supabase Auth)
- `UserSettingsService.updatePassword()` (Supabase Auth)
- `UserSettingsService.updateAvatar()` (Supabase Storage)

**Avatar Upload Flow:**
1. User selects photo (camera or gallery)
2. Compress to 512x512 using `image` package
3. Upload to Supabase Storage bucket: `user-avatars`
4. Get public URL
5. Update `user_settings.avatar_url`
6. Display immediately (optimistic UI)

---

## UI/UX Design

**PersonalSettingsScreen**
- Avatar circle at top (tap to change)
- List of editable fields:
  - Name (tap to edit → text dialog)
  - Email (tap to edit → verification required)
  - Password (tap → ChangePasswordScreen)

**Avatar Change Modal:**
- Option 1: Take Photo (camera)
- Option 2: Choose from Gallery

**Email Verification Flow:**
- User updates email → Confirmation dialog
- "Verification email sent to new-email@example.com"
- User clicks link in email → Email updated
- Old email receives notification of change (security)

**Password Change Screen:**
- Current password field
- New password field
- Confirm new password field
- Password strength indicator (weak/medium/strong)
- Requirements checklist:
  - ✅ 8+ characters
  - ✅ 1 uppercase letter
  - ✅ 1 number
  - ✅ 1 special character

---

## Testing

**Critical Scenarios:**
1. Update name → Save → Name updated instantly across app
2. Update email → Verification sent → User clicks link → Email updated
3. Change password (incorrect current) → Error: "Current password incorrect"
4. Change password (weak new password) → Error: "Password must be 8+ chars..."
5. Upload avatar → Compressed → Uploaded <2s → Displayed immediately

---

## Definition of Done

- ✅ User can update name, email, password, avatar
- ✅ Email change requires verification
- ✅ Password change requires current password
- ✅ Avatar upload <2s
- ✅ Optimistic UI (<200ms)
- ✅ Unit tests passing
- ✅ Code reviewed and merged

**Created:** 2025-01-16 | **Author:** Bob
