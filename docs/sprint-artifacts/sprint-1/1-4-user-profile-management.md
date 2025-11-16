# Story 1.4: User Profile Management

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** drafted
**Estimated Effort:** 3 SP

---

## User Story

**As a** user
**I want** to update my profile information
**So that** my account reflects my current details

---

## Acceptance Criteria

1. ✅ User can update name
2. ✅ User can update email (requires re-verification)
3. ✅ User can update avatar (upload from gallery or camera)
4. ✅ User can change password (requires current password confirmation)
5. ✅ Changes saved to Supabase and synced across devices
6. ✅ Avatar uploaded to Supabase Storage (max 5MB, JPG/PNG)
7. ✅ Error handling: Invalid email, weak password, upload failed

---

## Functional Requirements Covered

- **FR4:** User profile updates (name, email, password, avatar)
- **FR116:** Personal settings management

---

## UX Notes

- Profile screen accessible from Profile tab
- Edit mode: Inline editing with "Save" button
- Avatar: Circular image with "Change photo" button overlay
- Form validation before save

**Design Reference:** UX Design Specification - Profile Screen

---

## Technical Implementation

### Frontend (Flutter)

**File:** `lib/features/profile/presentation/pages/profile_edit_page.dart`

**Key Components:**
```dart
class ProfileEditPage extends ConsumerWidget {
  // Name text field
  // Email text field (with verification warning)
  // Avatar image picker
  // Change password button
  // Save button
}
```

**Avatar Upload:**
```dart
Future<String> uploadAvatar(File imageFile) async {
  // Compress image to 512x512px
  final compressedImage = await FlutterImageCompress.compressAndGetFile(
    imageFile.path,
    targetPath,
    quality: 85,
    maxWidth: 512,
    maxHeight: 512,
  );

  // Upload to Supabase Storage
  final path = '${userId}/avatar.jpg';
  await supabase.storage.from('avatars').upload(path, compressedImage);

  // Return public URL
  return supabase.storage.from('avatars').getPublicUrl(path);
}
```

### Backend (Supabase)

**Database:**
```sql
-- Update user_profiles table
UPDATE user_profiles
SET
  name = $1,
  email = $2,
  avatar_url = $3,
  updated_at = NOW()
WHERE id = $4;
```

**Storage Bucket:**
```sql
-- avatars bucket (public read, user-specific write)
CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can view avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');
```

**Email Update:**
```dart
// Triggers re-verification email
await supabase.auth.updateUser(
  UserAttributes(email: newEmail),
);
```

### Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Invalid email | "Please enter a valid email address" | Highlight field |
| Weak password | "Password must be 8+ chars with uppercase, number, special char" | Show requirements |
| Upload failed | "Avatar upload failed. Try again or choose smaller image." | Retry button |
| File too large | "Image must be under 5MB" | Show size limit |
| Network error | "Connection failed. Changes not saved." | Retry button |

---

## Dependencies

**Prerequisites:**
- Story 1.1 (User accounts must exist)
- Story 1.2 (User must be logged in)

---

## Testing Requirements

### Unit Tests
```dart
test('should update user name')
test('should update email and trigger verification')
test('should compress and upload avatar')
test('should fail with invalid email')
test('should fail with file >5MB')
```

### Widget Tests
```dart
testWidgets('should display profile fields')
testWidgets('should show image picker on avatar tap')
testWidgets('should show success message on save')
```

### Integration Tests
```dart
testWidgets('complete profile update flow')
testWidgets('avatar upload and display')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] User can update name
- [ ] User can update email (verification triggered)
- [ ] User can upload avatar from gallery
- [ ] User can upload avatar from camera
- [ ] User can change password
- [ ] Avatar compressed to 512x512px
- [ ] Avatar uploaded to Supabase Storage
- [ ] Changes synced across devices
- [ ] All error cases handled
- [ ] Unit tests pass (80%+ coverage)
- [ ] Widget tests pass
- [ ] Integration test passes
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**Performance:**
- Image compression <1s
- Upload time <3s (for 512x512 JPEG)
- Profile update <1s

**Storage:**
- Max 5MB per avatar (enforced client-side)
- Compressed to ~100KB after optimization
- Old avatar overwritten (no version history)

**GDPR:**
- User can delete avatar (Story 1.6 - account deletion)
- Avatar stored in user-specific folder (privacy)

---

## Related Stories

- **Previous:** Story 1.3 (Password Reset Flow)
- **Next:** Story 1.5 (Data Sync Across Devices)

---

**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
