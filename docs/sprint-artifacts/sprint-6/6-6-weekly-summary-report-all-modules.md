# Story 6.6: Weekly Summary Report (All Modules)
**Epic:** 6 | **P0** | **4 SP** | **drafted**
## AC: Generated Monday 6am, Push "📊 Your week in review!", Report: Fitness (workouts, PRs, volume), Mind (meditations, stress -X%, mood avg), Life Coach (check-ins X/7, goals progressed, plan completion), Streaks, Top insight ("Best workouts after 8+ hours sleep"), Shareable image, Saved in history
## Tech: Cron Monday 6am, Aggregate queries (7 days all modules), FCM notification, `CREATE TABLE weekly_reports (user_id, week_start_date, report_data JSONB)`
**Deps:** Epic 2, 3, 4 | **Cov:** 75%+
