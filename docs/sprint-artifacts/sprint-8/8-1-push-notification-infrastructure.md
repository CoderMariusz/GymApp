# Story 8.1: Push Notification Infrastructure
**Epic:** 8 | **P0** | **3 SP** | **drafted**
## AC: Firebase Cloud Messaging integrated, Works iOS + Android, User grant/deny permission on first launch, Device tokens stored `CREATE TABLE device_tokens (user_id, token, platform)`, Sent via Supabase Edge Functions (cron jobs), Categories: Reminders, Streaks, Insights, Reports, User can enable/disable each category in settings
**Deps:** Epic 1 | **Cov:** 80%+
