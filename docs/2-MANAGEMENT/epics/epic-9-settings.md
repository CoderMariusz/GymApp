# Epic 9: Settings & Profile

<!-- AI-INDEX: settings, profile, preferences, privacy, gdpr, account, units, notifications-settings -->

**Goal:** Deliver user settings, preferences, account management, and data privacy controls.

**Value:** Users can customize app, manage subscription, and control data privacy (GDPR compliance).

**FRs Covered:** FR116-FR123 (Settings & Profile)

**Dependencies:** Epic 1 (auth), Epic 7 (subscriptions)

**Stories:** 5

---

## Story 9.1: Personal Settings (Name, Email, Password, Avatar)

**Phase:** MVP
**Status:** Complete

**As a** user
**I want** to update my personal information
**So that** my account is current

### Acceptance Criteria

1. Settings screen accessible from Profile tab
2. Personal info section: Name, Email, Password, Avatar
3. Edit mode: Tap field → Inline editing
4. Name: Max 50 chars, validation (no special chars)
5. Email: Validation (valid format), requires re-verification if changed
6. Password: Change password (requires current password confirmation)
7. Avatar: Upload from gallery or camera (max 5MB, JPG/PNG)
8. Changes saved to Supabase (synced across devices)
9. Success message: "Settings updated successfully"

**FRs:** FR116, FR4

### UX Notes
- Settings screen: List of sections (Personal Info, Notifications, Subscription, etc.)
- Edit mode: Pencil icon → Inline editing
- Avatar: Circular image with "Change photo" overlay

### Technical Notes
- Update user table (name, email, avatar_url)
- Email change triggers verification email
- Avatar upload to Supabase Storage

---

## Story 9.2: Notification Preferences

**Phase:** MVP
**Status:** Complete

**As a** user
**I want** to control which notifications I receive
**So that** I'm not overwhelmed

### Acceptance Criteria

1. Notification settings section (Settings → Notifications)
2. Toggle for each notification type:
   - Morning check-in reminder
   - Evening reflection reminder
   - Workout reminder
   - Meditation reminder
   - Streak alerts
   - Cross-module insights
   - Weekly summary
3. Customize times: Morning reminder time, Evening reminder time
4. Quiet hours: Start time, End time (default 10pm - 7am)
5. Changes saved immediately (optimistic UI)
6. Test notification button ("Send test notification")

**FRs:** FR117

### UX Notes
- Toggle switches: iOS style (green when ON)
- Time pickers: Native OS pickers (iOS wheel, Android clock)
- "Test notification" button: Sends sample notification immediately

### Technical Notes
- notification_settings table updated
- Test notification: Send via Firebase Cloud Messaging immediately

---

## Story 9.3: Unit Preferences (kg/lbs, cm/inches)

**Phase:** MVP
**Status:** Complete

**As a** user from different regions
**I want** to choose my preferred units
**So that** data is displayed in familiar format

### Acceptance Criteria

1. Unit settings section (Settings → Units)
2. Weight unit: kg or lbs (toggle)
3. Distance unit: km or miles (toggle, P1 for running)
4. Height unit: cm or inches (toggle)
5. Unit changes apply immediately across app
6. Historical data converted automatically (e.g., 100kg → 220lbs)
7. Workout logs re-rendered with new units

**FRs:** FR118

### UX Notes
- Toggle switches: "kg / lbs"
- Immediate feedback: "Weight unit changed to lbs"

### Technical Notes
- user_settings table: weight_unit, distance_unit, height_unit
- Conversion functions: kgToLbs(), cmToInches()
- Display logic: Check user preference before rendering

---

## Story 9.4: Subscription & Billing Management

**Phase:** MVP
**Status:** Complete

**As a** subscribed user
**I want** to manage my subscription
**So that** I can upgrade, downgrade, or cancel

### Acceptance Criteria

1. Subscription section (Settings → Subscription)
2. Current plan shown: Tier name, Price, Billing date
3. Upgrade options: "Upgrade to Full Access" button
4. Downgrade options: "Switch to 1-Module" button
5. Cancel subscription button (red, bottom)
6. Billing history: List of past charges (date, amount, receipt)
7. Receipt download button (PDF)
8. Manage subscription → Opens App Store/Google Play subscription management (iOS/Android)

**FRs:** FR119

### UX Notes
- Current plan: Highlighted card (Teal border)
- Upgrade/downgrade: Clear CTAs
- Billing history: Scrollable list (date, amount, status)

### Technical Notes
- Query subscription status from RevenueCat or Supabase
- Billing history: Store in subscriptions table (transaction history)
- Receipt: Generate PDF (Supabase Edge Function)

---

## Story 9.5: Data Privacy & Cross-Module Settings

**Phase:** MVP
**Status:** Complete

**As a** privacy-conscious user
**I want** to control data sharing and AI analysis
**So that** I maintain privacy

### Acceptance Criteria

1. Data & Privacy section (Settings → Data & Privacy)
2. Toggle: "Allow modules to share data" (default ON)
   - If OFF: Cross-module insights disabled (warning shown)
3. Toggle: "AI analysis of journal entries" (default OFF)
   - If OFF: Sentiment analysis disabled (E2E encryption only)
4. Toggle: "Send anonymous analytics" (default ON)
   - App usage data (no PII)
5. "Export All Data" button → Generate ZIP (Story 1.6)
6. "Delete Account" button (red, bottom) → Confirmation modal
7. Privacy Policy link
8. GDPR compliance message: "Your data is yours. We never sell it."

**FRs:** FR122, FR123, FR102

### UX Notes
- Clear explanations for each toggle
- Warning if user disables cross-module sharing: "Some features won't work"
- Privacy Policy: Opens in-app browser

### Technical Notes
- user_settings table: share_data_across_modules, ai_journal_analysis, send_analytics
- Feature checks: if (!share_data_across_modules) { disable insights }

---

## Settings Structure

```
Settings
├── Personal Info
│   ├── Name
│   ├── Email
│   ├── Password
│   └── Avatar
├── Notifications
│   ├── Reminders (toggles)
│   ├── Reminder Times
│   └── Quiet Hours
├── Units
│   ├── Weight (kg/lbs)
│   ├── Distance (km/miles)
│   └── Height (cm/inches)
├── Subscription
│   ├── Current Plan
│   ├── Upgrade/Downgrade
│   ├── Billing History
│   └── Cancel
└── Data & Privacy
    ├── Cross-module sharing
    ├── AI analysis
    ├── Analytics
    ├── Export Data
    ├── Delete Account
    └── Privacy Policy
```

---

## Related Documents

- [PRD-nfr.md](../../1-BASELINE/product/PRD-nfr.md) - NFR requirements (GDPR)
- [ARCH-security.md](../../1-BASELINE/architecture/ARCH-security.md) - Security architecture
- [epic-7-onboarding-subscriptions.md](./epic-7-onboarding-subscriptions.md) - Subscriptions

---

*5 Stories | FR116-FR123 | Settings & Profile | Status: 80% Complete*
