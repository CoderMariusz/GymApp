# Story 7.5: 14-Day Trial (All Premium)
**Epic:** 7 | **P0** | **3 SP** | **drafted**
## AC: Auto-starts after onboarding (no card required), Includes: Fitness (Smart Pattern, all templates), Mind (full meditation library, unlimited CBT GPT-4), Life Coach (unlimited goals, unlimited AI GPT-4), Countdown "13 days left", Reminder push 3 days before end, Trial end → Revert to free (no data loss), Can subscribe anytime (trial ends)
## Tech: `trial_end_date` column, Feature checks `if (NOW() < trial_end_date || tier == 'premium') { allow }`, Cron job check expiration daily
**Deps:** 7.3, 7.4 | **Cov:** 80%+
