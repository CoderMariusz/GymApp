# Story 6.6: Weekly Summary Report (All Modules)
**Epic:** 6 | **P0** | **4 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [6-6-weekly-summary-report-all-modules.context.xml](./6-6-weekly-summary-report-all-modules.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: Generated Monday 6am, Push "📊 Your week in review!", Report: Fitness (workouts, PRs, volume), Mind (meditations, stress -X%, mood avg), Life Coach (check-ins X/7, goals progressed, plan completion), Streaks, Top insight ("Best workouts after 8+ hours sleep"), Shareable image, Saved in history
## Tech: Cron Monday 6am, Aggregate queries (7 days all modules), FCM notification, `CREATE TABLE weekly_reports (user_id, week_start_date, report_data JSONB)`
**Deps:** Epic 2, 3, 4 | **Cov:** 75%+
