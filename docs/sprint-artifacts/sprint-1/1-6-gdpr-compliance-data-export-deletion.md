# Story 1.6: GDPR Compliance (Data Export & Deletion)

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** drafted
**Estimated Effort:** 5 SP

---

## User Story

**As a** user concerned about data privacy
**I want** to export or delete my data
**So that** I comply with my rights under GDPR

---

## Acceptance Criteria

1. ✅ User can request data export from Profile → Data & Privacy
2. ✅ Export generates ZIP file (JSON + CSV formats)
3. ✅ Export includes: workouts, mood logs, goals, meditations, journal entries, account info
4. ✅ Export download link sent via email (expires in 7 days)
5. ✅ User can request account deletion (requires password confirmation)
6. ✅ Account deletion removes all data within 7 days (GDPR compliance)
7. ✅ Deletion is irreversible (clear warning shown)
8. ✅ Deleted data purged from backups after 30 days

---

## Functional Requirements Covered

- **FR100:** Data export in machine-readable format
- **FR101:** Account deletion with 7-day grace period
- **FR102:** GDPR compliance (right to be forgotten)
- **NFR-S6:** GDPR compliance (data portability, right to erasure)

---

## UX Notes

- Data & Privacy screen: Export button + Delete account button (red, bottom)
- Export: "Preparing your data..." loading state → Email sent confirmation
- Delete: Modal with password input + "I understand this is permanent" checkbox
- Delete confirmation: "Your account will be deleted in 7 days. You can cancel anytime."

**Design Reference:** UX Design Specification - Settings → Data & Privacy

---

## Technical Implementation

### Frontend (Flutter)

**File:** `lib/features/settings/presentation/pages/data_privacy_page.dart`

**Data Export Flow:**
```dart
class DataPrivacyPage extends ConsumerWidget {
  Future<void> requestDataExport() async {
    // Call Supabase Edge Function
    await supabase.functions.invoke('export-user-data');

    // Show confirmation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Export Requested'),
        content: Text('Your data export will be sent to your email within 24 hours.'),
      ),
    );
  }
}
```

**Account Deletion Flow:**
```dart
Future<void> requestAccountDeletion(String password) async {
  // Confirm password
  final isValid = await _verifyPassword(password);
  if (!isValid) throw Exception('Invalid password');

  // Call Edge Function
  await supabase.functions.invoke('delete-account');

  // Log out user
  await supabase.auth.signOut();

  // Navigate to login
}
```

### Backend (Supabase Edge Functions)

**Export Edge Function:**
```typescript
// supabase/functions/export-user-data/index.ts
Deno.serve(async (req) => {
  const userId = req.headers.get('user-id');

  // Fetch all user data
  const userData = await fetchAllUserData(userId);

  // Generate ZIP with JSON + CSV
  const zipFile = await generateExportZip(userData);

  // Upload to Storage (expires in 7 days)
  const { data } = await supabaseClient.storage
    .from('exports')
    .upload(`${userId}/export-${Date.now()}.zip`, zipFile, {
      contentType: 'application/zip',
    });

  // Send email with download link
  await sendExportEmail(userId, data.path);

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

**Data Structure (JSON):**
```json
{
  "account": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-01-16T10:00:00Z"
  },
  "workouts": [
    {
      "id": "uuid",
      "date": "2025-01-15",
      "duration": 3600,
      "exercises": [...]
    }
  ],
  "mood_logs": [...],
  "goals": [...],
  "meditations": [...],
  "journal_entries": [...] // Encrypted
}
```

**Delete Edge Function:**
```typescript
// supabase/functions/delete-account/index.ts
Deno.serve(async (req) => {
  const userId = req.headers.get('user-id');

  // Mark account for deletion (soft delete)
  await supabaseClient
    .from('users')
    .update({ deletion_requested_at: new Date() })
    .eq('id', userId);

  // Schedule hard delete in 7 days (cron job)
  // User can cancel deletion within 7 days

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

**Hard Delete Cron Job:**
```typescript
// supabase/functions/cleanup-deleted-accounts/index.ts
Deno.serve(async () => {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

  // Find accounts marked for deletion >7 days ago
  const { data: accountsToDelete } = await supabaseClient
    .from('users')
    .select('id')
    .lt('deletion_requested_at', sevenDaysAgo);

  // Delete all user data (cascading deletes)
  for (const account of accountsToDelete) {
    await deleteAllUserData(account.id);
  }

  return new Response('Cleanup complete', { status: 200 });
});
```

### Database Schema

**Cascading Deletes:**
```sql
-- All user tables have ON DELETE CASCADE
ALTER TABLE workouts
  ADD CONSTRAINT fk_user
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE;

ALTER TABLE mood_logs
  ADD CONSTRAINT fk_user
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE;

-- Repeat for all user tables
```

**Soft Delete Flag:**
```sql
ALTER TABLE users ADD COLUMN deletion_requested_at TIMESTAMPTZ;
```

### Email Templates

**Export Email:**
```
Subject: Your LifeOS Data Export is Ready

Hi [Name],

Your data export is ready for download:
[Download Link] (expires in 7 days)

This ZIP file contains all your data in JSON and CSV formats.

If you didn't request this export, please contact support immediately.

- LifeOS Team
```

**Deletion Confirmation Email:**
```
Subject: Account Deletion Requested

Hi [Name],

Your account deletion has been scheduled for [Date + 7 days].

If you change your mind, log in before [Date] to cancel.

After [Date], all your data will be permanently deleted.

- LifeOS Team
```

---

## Dependencies

**Prerequisites:**
- Story 1.1 (User accounts must exist)
- Story 1.2 (User must be logged in)
- All data features (workouts, mood, goals, etc.)

---

## Testing Requirements

### Unit Tests
```dart
test('should generate export ZIP with all data')
test('should mark account for deletion')
test('should hard delete after 7 days')
test('should send export email')
```

### Integration Tests
```dart
testWidgets('complete data export flow')
testWidgets('complete account deletion flow')
testWidgets('cancel deletion within 7 days')
```

**Coverage Target:** 80%+

---

## Definition of Done

- [ ] User can request data export
- [ ] Export ZIP generated (JSON + CSV)
- [ ] Export includes all user data
- [ ] Export email sent with download link
- [ ] Download link expires in 7 days
- [ ] User can request account deletion
- [ ] Password confirmation required for deletion
- [ ] Account soft-deleted immediately
- [ ] Hard delete after 7 days
- [ ] Cascading deletes work correctly
- [ ] Deletion emails sent
- [ ] User can cancel deletion within 7 days
- [ ] Unit tests pass (80%+ coverage)
- [ ] Integration tests pass
- [ ] GDPR compliance verified
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**GDPR Compliance:**
- Right to data portability (Article 20) ✅
- Right to erasure (Article 17) ✅
- 7-day grace period (best practice, not required)
- Data purged from backups after 30 days

**Security:**
- Export link expires in 7 days (prevent data leaks)
- Password confirmation required for deletion
- Export stored in private Storage bucket (user-specific access)

**Performance:**
- Export generation <30s for average user
- Email sent within 5 minutes
- Hard delete <5s (cascading deletes optimized)

**Edge Cases:**
- User requests export, then deletes account → Export still sent
- User deletes account, then tries to export → Error (account deleted)
- User has encrypted journal entries → Exported as encrypted (cannot decrypt)

---

## Related Stories

- **Previous:** Story 1.5 (Data Sync Across Devices)
- **Completes:** Epic 1 (Core Platform Foundation)

---

**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
