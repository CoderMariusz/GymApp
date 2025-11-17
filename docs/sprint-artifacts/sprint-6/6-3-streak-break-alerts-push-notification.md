# Story 6.3: Streak Break Alerts
**Epic:** 6 | **P1** | **2 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [6-3-streak-break-alerts-push-notification.context.xml](./6-3-streak-break-alerts-push-notification.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: Push at 8pm if activity not done, Message "🔥 Streak Alert! Your 15-day meditation streak is about to break", NOT sent if freeze available (auto-used), User can disable in settings
## Tech: Cron job 8pm, FCM notification, Deep link to module
**Deps:** 6.1, 8.1 | **Cov:** 75%+
