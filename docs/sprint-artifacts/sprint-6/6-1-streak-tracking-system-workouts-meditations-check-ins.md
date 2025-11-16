# Story 6.1: Streak Tracking System
**Epic:** 6 | **P0** | **3 SP** | **drafted**
## AC: 3 streak types (Workout, Meditation, Check-in), Increments daily, Breaks if missed, 1 freeze/week/type (auto-use), Freeze resets Sunday, Longest streak saved, Current shown on Home (🔥)
## Tech: `CREATE TABLE streaks (user_id, type, current_streak, longest_streak, freeze_used_this_week, last_activity_date)` | Cron job daily
**Deps:** Epic 2, 3, 4 | **Cov:** 80%+
