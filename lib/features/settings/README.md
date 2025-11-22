# Settings Feature - GDPR Compliance

## Overview

This feature implements GDPR compliance for LifeOS, providing users with the ability to export their data (Article 20) and request account deletion (Article 17).

## Features

### 1. Data Export (Article 20 - Right to Data Portability)

Users can request a complete export of their data, which includes:
- User profile information
- Workout templates and history
- Mood logs
- Goals and progress
- Meditation sessions
- Journal entries (encrypted)
- Mental health screenings
- AI conversations
- Streaks and achievements
- Subscription information

**Export Format:**
- JSON: Complete data in structured format
- CSV: Separate CSV files for each data type
- Delivered as ZIP file via email
- Download link expires in 7 days

**Rate Limiting:**
- Maximum 1 export request per hour per user

### 2. Account Deletion (Article 17 - Right to Erasure)

Users can permanently delete their account with the following safeguards:
- Password confirmation required
- "I understand this is permanent" checkbox
- 7-day grace period before deletion
- Ability to cancel within grace period
- All data deleted via cascading deletes
- Backups purged after 30 days (GDPR compliant)

## Architecture

### Clean Architecture Layers

```
lib/features/settings/
├── domain/              # Business logic
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Use cases (export, delete, cancel)
├── data/                # Data layer
│   ├── datasources/     # Supabase API calls
│   └── repositories/    # Repository implementations
└── presentation/        # UI layer
    ├── pages/           # Data Privacy page
    ├── widgets/         # Export button, Delete modal
    └── providers/       # Riverpod providers
```

### Backend (Supabase)

**Edge Functions:**
- `export-user-data`: Generates data export
- `delete-account`: Schedules account deletion
- `cleanup-deleted-accounts`: Cron job (runs daily at 2 AM)

**Database:**
- `data_export_requests`: Tracks export requests
- `account_deletion_requests`: Tracks deletion requests
- `gdpr_email_queue`: Email notification queue

**Storage:**
- Bucket: `exports`
- Privacy: Private (RLS enforced)
- Lifecycle: Auto-delete after 7 days

## Usage

### Adding Data Privacy Page to Navigation

```dart
import 'package:lifeos/features/settings/presentation/pages/data_privacy_page.dart';

// In your router or navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DataPrivacyPage()),
);
```

### Using Use Cases Directly

```dart
// Request data export
final exportUseCase = ref.read(exportDataUseCaseProvider);
final requestId = await exportUseCase.call();

// Check export status
final downloadUrl = await exportUseCase.checkStatus(requestId);

// Request account deletion
final deleteUseCase = ref.read(deleteAccountUseCaseProvider);
final deletionId = await deleteUseCase.call('user-password');

// Cancel deletion
final cancelUseCase = ref.read(cancelDeletionUseCaseProvider);
await cancelUseCase.call();
```

## Testing

### Unit Tests

```bash
flutter test test/features/settings/
```

### Integration Tests

```bash
flutter test integration_test/settings/
```

**Note:** Integration tests require a test Supabase instance with Edge Functions deployed.

## Security Considerations

1. **Password Verification:** Account deletion requires password confirmation
2. **RLS Policies:** Users can only access their own exports
3. **Signed URLs:** Temporary access to export files (7-day expiration)
4. **Rate Limiting:** Prevents abuse of export functionality
5. **Cascading Deletes:** Ensures no orphaned data remains

## GDPR Compliance

### Article 20 - Right to Data Portability ✅
- Users can export data in machine-readable format (JSON, CSV)
- Export delivered within reasonable time (<5 minutes)
- Data completeness verified

### Article 17 - Right to Erasure ✅
- Users can request deletion
- Grace period for accidental requests
- Complete data removal (including backups)
- Deletion confirmation

### Article 12 - Transparent Information ✅
- Clear warnings about irreversibility
- Grace period clearly communicated
- GDPR rights explained in UI

## Email Notifications (TODO)

The following emails should be sent:

1. **Export Ready:**
   - Subject: "Your Data Export is Ready"
   - Content: Download link (expires in 7 days)

2. **Deletion Scheduled:**
   - Subject: "Account Deletion Scheduled"
   - Content: Deletion date, how to cancel

3. **Deletion Reminder:**
   - Subject: "Account Deletion in 24 Hours"
   - Content: Final reminder, cancellation link

4. **Deletion Cancelled:**
   - Subject: "Account Deletion Cancelled"
   - Content: Confirmation that account is safe

## Cron Job Setup

The `cleanup-deleted-accounts` function should run daily:

```bash
# Supabase CLI
supabase functions schedule cleanup-deleted-accounts "0 2 * * *"

# Or via Supabase Dashboard:
# Functions → cleanup-deleted-accounts → Settings → Cron Schedule
# Schedule: 0 2 * * * (daily at 2 AM UTC)
```

Set the `CRON_SECRET` environment variable for security:

```bash
supabase secrets set CRON_SECRET="your-secure-random-secret"
```

## Storage Configuration

Create the exports bucket and set lifecycle policy:

```bash
# Create bucket
supabase storage create exports --public=false

# Set lifecycle policy (auto-delete after 7 days)
supabase storage update exports --lifecycle-rules '[
  {
    "action": "Delete",
    "condition": {
      "age": 7,
      "matchesPrefix": [""]
    }
  }
]'
```

## Monitoring

Monitor GDPR operations:

```sql
-- Export requests in last 24 hours
SELECT COUNT(*), status
FROM data_export_requests
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY status;

-- Pending deletions
SELECT COUNT(*)
FROM account_deletion_requests
WHERE status = 'pending';

-- Failed deletions (requires manual review)
SELECT *
FROM account_deletion_requests
WHERE status = 'failed';
```

## Future Enhancements

- [ ] Email notification integration
- [ ] Export status polling UI
- [ ] Deletion countdown timer in app
- [ ] Admin dashboard for GDPR operations
- [ ] Audit log for compliance tracking
- [ ] Multi-language support for GDPR notices
- [ ] PDF export option
- [ ] Selective data export (choose what to export)

## Related Stories

- **Story 1.1:** User Account Creation (dependency)
- **Story 1.2:** User Login (dependency)
- **Story 9.5:** Privacy Controls (future enhancement)

## Compliance Documentation

For compliance audits, maintain:
- Request logs (data_export_requests, account_deletion_requests)
- Deletion completion logs
- Email delivery receipts
- RLS policy configurations
- Data retention policies
