# Story 6.1: Streak Tracking System
**Epic:** 6 | **P0** | **3 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [6-1-streak-tracking-system-workouts-meditations-check-ins.context.xml](./6-1-streak-tracking-system-workouts-meditations-check-ins.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: 3 streak types (Workout, Meditation, Check-in), Increments daily, Breaks if missed, 1 freeze/week/type (auto-use), Freeze resets Sunday, Longest streak saved, Current shown on Home (🔥)
## Tech: `CREATE TABLE streaks (user_id, type, current_streak, longest_streak, freeze_used_this_week, last_activity_date)` | Cron job daily
**Deps:** Epic 2, 3, 4 | **Cov:** 80%+
