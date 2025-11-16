# Story 9.5: Data Privacy & Cross-Module Settings

**Epic:** Epic 9 - Settings & Profile
**Sprint:** 9
**Story Points:** 3
**Priority:** P0
**Status:** Draft

---

## User Story

**As a** user
**I want** to control how my data is used and shared
**So that** I maintain privacy and comply with GDPR

---

## Acceptance Criteria

### Privacy Controls
- ✅ User can toggle **"Allow modules to share data"** (default: ON)
  - If OFF: Cross-module insights disabled, Life Coach doesn't see mood/stress, Fitness doesn't see stress
  - Warning modal shown when disabling (explains impact)
- ✅ User can toggle **"AI analysis of journal entries"** (default: OFF)
  - If ON: Journal sentiment analysis enabled (opt-in only)
  - If OFF: Journals remain fully E2E encrypted
- ✅ User can toggle **"Send anonymous analytics"** (default: ON)
  - Helps improve LifeOS (no PII)

### GDPR Compliance
- ✅ User can **export all data** (GDPR right to data portability)
  - Request export → Background job processes → Email sent with download link (ZIP file, expires in 7 days)
  - Export includes: workouts, meditations, journals (encrypted), mood logs, stress logs, goals, daily plans, check-ins
- ✅ User can **delete account** (GDPR right to erasure)
  - Request deletion → 7-day grace period → Confirmation email sent
  - User can cancel deletion within 7 days
  - After 7 days: Account and all data permanently deleted
  - Deletion requires password confirmation

### Privacy Policy
- ✅ Link to **Privacy Policy** (opens in-app browser or external link)
- ✅ Footer: "Your data is yours. We never sell it."

---

## Technical Implementation

See: `docs/sprint-artifacts/tech-spec-epic-9.md` Section 3.3

**Key Services:**
- `DataPrivacyService.updateShareDataAcrossModules(bool)`
- `DataPrivacyService.updateAIJournalAnalysis(bool)`
- `DataPrivacyService.updateSendAnonymousAnalytics(bool)`
- `DataPrivacyService.requestDataExport()` → Supabase Edge Function
- `DataPrivacyService.requestAccountDeletion()` → 7-day grace period
- `DataPrivacyService.cancelAccountDeletion()`

**Data Export Edge Function:**
```typescript
// Supabase Edge Function: generate-data-export
// 1. Fetch all user data (workouts, meditations, journals, etc.)
// 2. Create ZIP file (JSON + CSV formats)
// 3. Upload to Supabase Storage
// 4. Generate signed URL (expires in 7 days)
// 5. Send email with download link
```

**Account Deletion Flow:**
1. User requests deletion → Password confirmation required
2. Deletion request created with `scheduled_deletion_date` (7 days from now)
3. Confirmation email sent: "Your account will be deleted on [date]. Cancel anytime."
4. Daily cron job checks for expired deletion requests → Deletes accounts

---

## UI/UX Design

**DataPrivacyScreen**

**Section 1: Privacy Controls**
- Toggle: "Allow modules to share data"
  - Subtitle: "Cross-module insights require this"
  - Warning modal if disabled:
    - "Some features won't work:"
    - • Cross-module insights
    - • AI daily plan optimization
    - • Fitness intensity adjustment

- Toggle: "AI analysis of journal entries"
  - Subtitle: "Sentiment analysis (opt-in only)"

- Toggle: "Send anonymous analytics"
  - Subtitle: "Helps us improve LifeOS (no PII)"

**Section 2: GDPR Rights**
- Button: "Export All Data"
  - Icon: Download
  - Subtitle: "Download a copy of your data (GDPR)"
  - Tap → Confirmation dialog → Request export → "You'll receive an email when ready"

- Button: "Delete Account" (RED)
  - Icon: Delete Forever
  - Subtitle: "Permanent deletion after 7-day grace period"
  - Tap → Confirmation dialog → Password confirmation → Request deletion → "Account scheduled for deletion on [date]"

**Section 3: Legal**
- Link: "Privacy Policy" (opens https://lifeos.app/privacy)

**Footer:**
- Text: "Your data is yours. We never sell it." (gray, centered)

---

## Export Data Confirmation Dialog

```
┌────────────────────────────────────────┐
│ Export All Data                        │
├────────────────────────────────────────┤
│ We'll generate a ZIP file with all    │
│ your data (JSON + CSV).                │
│                                        │
│ You'll receive an email with the      │
│ download link (expires in 7 days).    │
├────────────────────────────────────────┤
│ [Cancel]                    [Export]   │
└────────────────────────────────────────┘
```

---

## Delete Account Confirmation Dialog

```
┌────────────────────────────────────────┐
│ Delete Account                         │
├────────────────────────────────────────┤
│ Your account will be scheduled for     │
│ deletion in 7 days. You can cancel     │
│ anytime during this period.            │
│                                        │
│ ⚠️ This action is irreversible after  │
│ 7 days.                                │
├────────────────────────────────────────┤
│ [Cancel]              [Delete Account] │
└────────────────────────────────────────┘
```

**Password Confirmation:**
```
┌────────────────────────────────────────┐
│ Confirm Password                       │
├────────────────────────────────────────┤
│ [Enter your password]                  │
├────────────────────────────────────────┤
│ [Cancel]                    [Confirm]  │
└────────────────────────────────────────┘
```

---

## Testing

**Critical Scenarios:**
1. Disable cross-module sharing → Warning shown → Confirm → Cross-module insights disabled
2. Enable AI journal analysis → Journals analyzed for sentiment (opt-in)
3. Request data export → Background job processes → Email received with download link (ZIP file)
4. Download export → ZIP contains JSON and CSV files with all user data
5. Request account deletion → Password confirmed → 7-day grace period starts → Confirmation email sent
6. Cancel account deletion (within 7 days) → Deletion cancelled → "Welcome back!" message
7. Account deletion after 7 days → Account and all data permanently deleted

---

## Definition of Done

- ✅ Privacy controls working (cross-module sharing, AI journal analysis, analytics)
- ✅ Data export functional (ZIP generation, email delivery, 7-day expiry)
- ✅ Account deletion functional (7-day grace period, cancellation option, permanent deletion)
- ✅ Privacy Policy link working
- ✅ GDPR compliance validated
- ✅ Code reviewed and merged

**Created:** 2025-01-16 | **Author:** Bob
