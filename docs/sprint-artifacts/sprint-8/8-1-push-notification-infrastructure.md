# Story 8.1: Push Notification Infrastructure
**Epic:** 8 | **P0** | **3 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [8-1-push-notification-infrastructure.context.xml](./8-1-push-notification-infrastructure.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: Firebase Cloud Messaging integrated, Works iOS + Android, User grant/deny permission on first launch, Device tokens stored `CREATE TABLE device_tokens (user_id, token, platform)`, Sent via Supabase Edge Functions (cron jobs), Categories: Reminders, Streaks, Insights, Reports, User can enable/disable each category in settings
**Deps:** Epic 1 | **Cov:** 80%+
