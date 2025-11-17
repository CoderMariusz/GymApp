# Story 9.4: Subscription & Billing Management

**Epic:** Epic 9 - Settings & Profile
**Sprint:** 9
**Story Points:** 3
**Priority:** P0
**Status:** ready-for-dev

## Dev Agent Record

### Context Reference

- **Story Context File:** [9-4-subscription-billing-management.context.xml](./9-4-subscription-billing-management.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

---

## User Story

**As a** user
**I want** to view and manage my subscription and billing
**So that** I can upgrade, downgrade, or cancel my plan

---

## Acceptance Criteria

- ✅ User can view **current subscription tier** (Free, Single Module, 3-Module Pack, Full Access)
- ✅ User can view **subscription status** (Active, Trial, Cancelled, Expired)
- ✅ User can view **trial end date** (if in trial)
- ✅ User can view **next billing date** (if paid subscriber)
- ✅ User can **upgrade** to higher tier (via In-App Purchase)
- ✅ User can **downgrade** to lower tier (takes effect at end of billing period)
- ✅ User can **cancel subscription** (graceful degradation, 7-day access after cancellation)
- ✅ User can **reactivate** cancelled subscription (within 7-day window)
- ✅ User can view **billing history** (receipts for past payments)
- ✅ User can **restore purchases** (iOS/Android restore button)

---

## Technical Implementation

See: `docs/sprint-artifacts/tech-spec-epic-7.md` Story 7.6 & 7.7

**Key Services:**
- `SubscriptionService.getCurrentSubscription()`
- `SubscriptionService.upgradeSubscription(tier)`
- `SubscriptionService.downgradeSubscription(tier)`
- `SubscriptionService.cancelSubscription()`
- `SubscriptionService.reactivateSubscription()`
- `InAppPurchaseService.restorePurchases()`

**Subscription Tiers:**
- Free: Life Coach basic (€0)
- Single Module: 1 module (€2.99/month)
- 3-Module Pack: All 3 modules (€5.00/month) — **Most Popular**
- Full Access: All modules + GPT-4 (€7.00/month)

---

## UI/UX Design

**SubscriptionScreen**

**Section 1: Current Plan**
```
┌────────────────────────────────────────┐
│ Current Plan                           │
│ ───────────────────────────────────────│
│ 3-Module Pack                          │
│ €5.00/month                            │
│                                        │
│ Status: Active                         │
│ Next billing: Feb 16, 2025             │
└────────────────────────────────────────┘
```

**Section 2: Available Tiers (Cards)**
- Free (no card, just text)
- Single Module (€2.99) — Choose module dropdown
- 3-Module Pack (€5.00) — **Most Popular** badge
- Full Access (€7.00) — GPT-4 unlimited

Each card:
- Tier name + price
- Feature list (checkmarks)
- "Current Plan" button (if active) OR "Subscribe" button
- "Upgrade" (green) or "Downgrade" (gray) label

**Section 3: Actions**
- "Cancel Subscription" (red text, bottom)
- "Restore Purchases" (for iOS/Android)

---

## Cancel Subscription Flow

**Confirmation Dialog:**
```
┌────────────────────────────────────────┐
│ Cancel Subscription?                   │
├────────────────────────────────────────┤
│ Your subscription will remain active   │
│ until Feb 16, 2025.                    │
│                                        │
│ After that, you'll be downgraded to    │
│ Free tier (Life Coach basic only).    │
│                                        │
│ No data will be lost.                  │
├────────────────────────────────────────┤
│ [Keep Subscription]  [Cancel Anyway]   │
└────────────────────────────────────────┘
```

**Graceful Degradation:**
- Subscription cancelled → Remains active until end of billing period
- After billing period ends → Downgrade to Free tier
- NO DATA LOSS: All workouts, meditations, journals remain accessible (read-only if >3 goals)

---

## Testing

**Critical Scenarios:**
1. View current subscription → "3-Module Pack, €5/month, Active, Next billing: Feb 16"
2. Upgrade Free → 3-Module Pack → In-App Purchase flow → Subscription activated
3. Downgrade Full Access → Single Module → "Downgrade takes effect on Feb 16"
4. Cancel subscription → Confirmation → "Subscription will end on Feb 16"
5. Reactivate cancelled subscription (within 7 days) → Subscription active again
6. Restore purchases (iOS) → Previous purchases restored, subscription activated

---

## Definition of Done

- ✅ User can view current subscription details
- ✅ User can upgrade/downgrade/cancel
- ✅ Graceful degradation on cancel (no data loss)
- ✅ In-App Purchase working (iOS + Android)
- ✅ Restore purchases working
- ✅ Billing history accessible
- ✅ Code reviewed and merged

**Created:** 2025-01-16 | **Author:** Bob
