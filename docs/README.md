# LifeOS - Documentation Structure

**Project:** LifeOS (Life Operating System) - Modular Life Coaching Ecosystem
**Tagline:** "Your AI-powered operating system for life"
**Created:** 2025-01-16
**Status:** Phase 0 - Discovery (In Progress)

---

## 📁 Documentation Structure

This project uses a **modular architecture**. Documentation is organized as follows:

```
docs/
├── README.md                          # This file - documentation guide
├── bmm-workflow-status.yaml           # Legacy file (redirects to ecosystem/)
│
├── ecosystem/                         # Ecosystem-level planning
│   ├── bmm-workflow-status.yaml       # BMAD workflow tracker (entire ecosystem)
│   ├── brainstorming-session.md       # (Pending) Ecosystem brainstorming
│   ├── product-brief.md               # (Pending) Product vision
│   ├── PRD.md                         # (Pending) Ecosystem-level requirements
│   ├── architecture.md                # (Pending) Modular architecture + AI infra
│   └── sprint-planning-summary.md     # (Pending) MVP sprint planning
│
├── modules/                           # Individual module planning
│   │
│   ├── module-fitness/                # Fitness Coach AI (formerly GymApp)
│   │   ├── README.md                  # Module overview
│   │   ├── bmm-workflow-status.yaml   # Module workflow (Phase 3 COMPLETE)
│   │   ├── PRD.md                     # Module requirements (23 FRs, 15 NFRs)
│   │   ├── epics.md                   # 9 Epics, 70+ user stories
│   │   ├── architecture.md            # Offline-first, Firebase, Drift
│   │   ├── test-design.md             # QA strategy
│   │   ├── sprint-1-backlog.md        # Sprint 1 (11 SP)
│   │   ├── sprint-2-backlog.md        # Sprint 2 (16 SP)
│   │   ├── sprint-3-backlog.md        # Sprint 3 (16 SP)
│   │   ├── sprint-planning-summary.md # 3-sprint overview (43 SP)
│   │   └── [15+ more files]           # Complete planning docs
│   │
│   ├── module-life-coach/             # Life Coach AI (Core Module)
│   │   ├── README.md                  # Module overview
│   │   └── [Pending brainstorming]
│   │
│   └── module-mind/                   # Mind & Emotion Module
│       ├── README.md                  # Module overview
│       └── [Pending brainstorming]
│
└── sprint-artifacts/                  # Shared sprint artifacts (future)
```

---

## 🎯 Project Overview

### What is LifeOS?

**LifeOS (Life Operating System)** is a modular life coaching ecosystem powered by AI. It consists of multiple modules that work together or standalone:

**MVP Modules (Phase 1):**
1. **Life Coach AI** - Core AI brain, daily life planning, goal tracking
2. **Fitness Coach AI** - Workout tracking, training plans, AR analysis
3. **Mind & Emotion** - Mental health, mindfulness, meditation, CBT

**Phase 2 Modules:**
4. **Talent Tree** - RPG-style gamification of life progress
5. **Relationship AI** - Communication coaching, relationship guidance
6. **Tandem/Team Mode** - Social features, shared goals
7. **Human Help** - Peer support, social good platform
8. **E-Learning** - Micro courses on life skills
9. **AI Future Self** - Conversations with your future self
10. **Life Map** - Visual dashboard of life progress

### Monetization Model

**Free Tier:**
- Life Coach (basic features)
- 14-day trial of any module
- Ad-supported

**Paid Tiers:**
- **Single Module:** 2.99 EUR/month
- **3-Module Pack:** 5.00 EUR/month
- **LifeOS+ (All Access):** 7.00 EUR/month (all modules + GPT-4 + ad-free)

---

## 📊 Current Status

### Ecosystem Planning

| Phase | Status | Completion |
|-------|--------|------------|
| **Phase 0: Discovery** | 🟡 In Progress | 10% |
| Phase 1: Planning | ⏳ Not Started | 0% |
| Phase 2: Solutioning | ⏳ Not Started | 0% |
| Phase 3: Implementation | ⏳ Not Started | 0% |

**Next Step:** Brainstorming Session to define ecosystem vision and MVP modules

### Module Status

| Module | Status | Planning Complete | Notes |
|--------|--------|-------------------|-------|
| **Fitness Coach AI** | ✅ Designed | 100% | Originally "GymApp", fully planned (43 SP) |
| **Life Coach AI** | 🟡 Concept | 0% | Core module, pending brainstorming |
| **Mind & Emotion** | 🟡 Concept | 0% | MVP module, pending brainstorming |
| Talent Tree | 💡 Idea | 0% | Phase 2 |
| Relationship AI | 💡 Idea | 0% | Phase 2 |
| Tandem/Team Mode | 💡 Idea | 0% | Phase 2 |
| Human Help | 💡 Idea | 0% | Phase 2 |
| E-Learning | 💡 Idea | 0% | Phase 2 |
| AI Future Self | 💡 Idea | 0% | Phase 2 |
| Life Map | 💡 Idea | 0% | Phase 2 |

---

## 🚀 Getting Started

### For Product Development

1. **Read Ecosystem Workflow Status:**
   `docs/ecosystem/bmm-workflow-status.yaml`

2. **Review Fitness Module (example of complete planning):**
   `docs/modules/module-fitness/sprint-planning-summary.md`

3. **Understand BMAD Methodology:**
   We follow Business Method for Application Development (BMAD):
   - Phase 0: Discovery (Brainstorming, Research, Product Brief)
   - Phase 1: Planning (PRD, User Stories)
   - Phase 2: Solutioning (Architecture, Test Design)
   - Phase 3: Implementation (Sprint Planning, Execution)

### For Developers (Future)

When implementation begins:
- Each module has its own codebase under `lib/modules/[module-name]/`
- Shared infrastructure in `lib/core/`
- Module-specific docs in `docs/modules/[module-name]/`

---

## 📖 Key Documents

### Ecosystem-Level
- **Workflow Status:** `ecosystem/bmm-workflow-status.yaml` - BMAD progress tracker
- **Product Brief:** (Pending) - Vision and value proposition
- **PRD:** (Pending) - Ecosystem-level requirements
- **Architecture:** (Pending) - Modular architecture + AI infrastructure

### Fitness Coach AI Module (Complete Planning)
- **Sprint Planning Summary:** `modules/module-fitness/sprint-planning-summary.md` - 3-sprint overview
- **PRD:** `modules/module-fitness/PRD.md` - 23 FRs, 15 NFRs
- **Architecture:** `modules/module-fitness/architecture.md` - Offline-first design
- **Sprint Backlogs:** Sprint 1 (11 SP), Sprint 2 (16 SP), Sprint 3 (16 SP)

---

## 🤝 Contributing

This is currently in planning phase. Once development begins:
- Follow the architecture defined in each module's docs
- Update sprint-status.yaml daily during sprints
- Document all decisions in module-specific docs

---

## 📝 Notes

**Why "LifeCoach AI"?**
- Clear value proposition (AI-powered life coaching)
- Modular architecture allows flexible pricing
- Each module addresses different aspect of life improvement
- AI integration throughout creates cohesive experience

**Why modular?**
- Users can start with one module (lower barrier to entry)
- Flexible pricing (pay only for what you use)
- Easier to market (different modules = different audiences)
- Scalable development (can build modules in parallel)
- Better App Store visibility (can publish standalone apps if needed)

**Relationship to GymApp:**
- GymApp was originally planned as standalone fitness app
- Now integrated as "Fitness Coach AI" module
- All planning is complete and can be reused
- Gives us a head start on MVP development!

---

**Document Version:** 1.0
**Last Updated:** 2025-01-16
**Status:** Living Document (updated as project evolves)
