# Story 7.7: Cancel Subscription & Graceful Degradation
**Epic:** 7 | **P0** | **3 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [7-7-cancel-subscription-graceful-degradation.context.xml](./7-7-cancel-subscription-graceful-degradation.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: "Cancel" button on Subscription screen, Warning "Subscription ends [date]. You'll keep premium until then", Confirms cancellation (not instant, end of billing), Status "Active until [date]" (grace period), After cancel: Revert to free tier, Graceful degradation (Goals >3 → read-only, Meditation library → locked, AI chat → 3-5/day Llama), NO data loss, Can re-subscribe anytime
## Tech: `subscription_status` ('active', 'cancelled', 'expired'), Grace period `subscription_end_date`, Feature checks `if (NOW() < subscription_end_date) { allow }`
**Deps:** 7.6 | **Cov:** 80%+
