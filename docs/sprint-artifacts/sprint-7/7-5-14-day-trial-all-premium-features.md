# Story 7.5: 14-Day Trial (All Premium)
**Epic:** 7 | **P0** | **3 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [7-5-14-day-trial-all-premium-features.context.xml](./7-5-14-day-trial-all-premium-features.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: Auto-starts after onboarding (no card required), Includes: Fitness (Smart Pattern, all templates), Mind (full meditation library, unlimited CBT GPT-4), Life Coach (unlimited goals, unlimited AI GPT-4), Countdown "13 days left", Reminder push 3 days before end, Trial end → Revert to free (no data loss), Can subscribe anytime (trial ends)
## Tech: `trial_end_date` column, Feature checks `if (NOW() < trial_end_date || tier == 'premium') { allow }`, Cron job check expiration daily
**Deps:** 7.3, 7.4 | **Cov:** 80%+
