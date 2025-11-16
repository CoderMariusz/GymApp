# Story 4.5: Private Journaling (E2E Encrypted)
**Epic:** 4 - Mind & Emotion | **P0** | **4 SP** | **drafted**

## User Story
**As a** user wanting private journaling, **I want** E2E encryption, **So that** no one (not even LifeOS) can read my thoughts.

## Acceptance Criteria
1. ✅ Journal accessible from Mind tab
2. ✅ Rich text editor for entries
3. ✅ Entries encrypted client-side (E2E encryption)
4. ✅ Decryption key stored locally (device-specific)
5. ✅ Entries synced as encrypted blobs
6. ✅ AI sentiment analysis opt-in only (user must enable in settings)
7. ✅ If AI enabled: Sentiment shown (Positive, Neutral, Negative)
8. ✅ History viewable (sorted by date)
9. ✅ Export journal (PDF, encrypted ZIP)

**FRs:** FR62-FR65

## Tech
```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY,
  user_id UUID,
  timestamp TIMESTAMPTZ,
  encrypted_content TEXT, -- AES-256-GCM
  iv TEXT, -- Initialization vector
  salt TEXT
);
```
```dart
// AES-256-GCM client-side encryption
// Key derived from user password (PBKDF2, 100k iterations)
// IV random per entry
```
**Dependencies:** Epic 1 | **Coverage:** 85%+ (Security critical!)
