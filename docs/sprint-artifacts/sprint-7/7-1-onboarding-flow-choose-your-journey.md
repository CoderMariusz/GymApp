# Story 7.1: Onboarding Flow - Choose Your Journey
**Epic:** 7 | **P0** | **3 SP** | **drafted**
## AC: Starts after account creation, Screen 1 "Welcome to LifeOS 🌟", Screen 2 Choose journey (💪 Fitness, 🧠 Stress, ☀️ Life, 🌟 All), Flow adapts (Fitness-first → workout tutorial, Mind-first → meditation tutorial, etc.), Progress dots (●○○○○), "Skip" option
## Tech: `CREATE TABLE onboarding_state (user_id, journey_choice, completed)` | Save preference for personalization
**Deps:** 1.1 (Account creation) | **Cov:** 80%+
