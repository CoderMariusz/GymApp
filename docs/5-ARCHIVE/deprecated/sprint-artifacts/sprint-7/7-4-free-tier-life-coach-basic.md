# Story 7.4: Free Tier (Life Coach Basic)
**Epic:** 7 | **P0** | **2 SP** | **ready-for-dev**

## Dev Agent Record

### Context Reference

- **Story Context File:** [7-4-free-tier-life-coach-basic.context.xml](./7-4-free-tier-life-coach-basic.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation
## AC: ALWAYS FREE: Life Coach (daily planning, 3 goals max, check-ins, AI chat 3-5/day Llama), Mind (mood tracking ALWAYS FREE), Fitness (basic logging, no Smart Pattern, limited templates), Limitations shown clearly, Premium features locked with "Upgrade" CTA, No credit card required, Never expires
## Tech: `subscription_tier = 'free'` (default), Feature checks `if (tier == 'free') { limit }`
**Deps:** Epic 2 | **Cov:** 80%+
