# Story 7.3: Onboarding - Permissions & Tutorial
**Epic:** 7 | **P0** | **3 SP** | **drafted**
## AC: Screen 5 Permissions (push notifications "max 1/day", health data P1), "Enable Notifications" button + "Maybe Later", Interactive tutorial based on journey (Fitness: log 1 sample workout, Mind: 2-min breathing, Life Coach: check-in), Completion "You're all set! 🎉", Skippable, 14-day trial banner shown
## Tech: iOS/Android permission requests, Tutorial state saved, Trial activation `trial_end_date = NOW() + 14 days`
**Deps:** 7.1, 7.2 | **Cov:** 80%+
