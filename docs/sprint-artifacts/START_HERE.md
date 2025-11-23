# START HERE - Template-Based Context Creation Guide

**Last Updated:** 2025-11-23
**Status:** Ready to Use 🎉

---

## 🎯 What Changed?

**We optimized the story context creation process and saved 67% tokens (99,900 tokens)!**

### Before
- 12 batches
- 150,000 tokens
- 10-12 weeks
- Full context for every story

### After ✅
- **9 batches**
- **50,100 tokens**
- **6-8 weeks**
- **Template-based** (reference shared patterns)

---

## 📚 5 New Documents You Need to Know

### 1. **SHARED_TEMPLATES_LIBRARY.md** ⭐ CRITICAL
**What:** 16 reusable templates covering 95% of implementation patterns
**Why:** Instead of writing 3,000 tokens per story, reference templates and write only custom elements (500-1,200 tokens)
**Templates:**
- ARCH-01: CRUD Pattern
- ARCH-02: AI Integration
- ARCH-03: List + Detail View
- DB-01-03: Database schemas
- CODE-01-04: Dart code patterns
- TEST-01-03: Testing strategies
- UI-01-02: UI patterns
- DOD-01: Definition of Done

### 2. **BATCH_PLAN_OPTIMIZED.md** ⭐ CRITICAL
**What:** Complete optimized batch execution plan (9 batches)
**Why:** Shows exactly which stories to create in each session with token estimates
**Use:** Start with Batch 1 (Epic 1 - Core Platform)

### 3. **STORY_TEMPLATE_MAPPING.md**
**What:** All 65 stories mapped to templates with customization levels (⭐ to ⭐⭐⭐⭐⭐)
**Why:** Quickly see which templates apply to each story
**Use:** Check before starting any story

### 4. **QUICK_CONTEXT_FORMAT.md**
**What:** Ultra-compact format for 90%+ template stories
**Why:** Stories that are mostly templates need only 400-600 tokens
**Use:** For stories marked ⭐ or ⭐⭐

### 5. **OPTIMIZATION_REPORT.md**
**What:** Complete analysis of patterns, savings, and recommendations
**Why:** Understand the optimization strategy
**Use:** Read once for context

---

## 🚀 How to Start (3 Steps)

### Step 1: Read Templates (30 minutes)
```
1. Open SHARED_TEMPLATES_LIBRARY.md
2. Skim all 16 templates
3. Understand the structure
```

**You don't need to memorize!** Just understand that templates exist.

### Step 2: Choose First Batch (5 minutes)
```
1. Open BATCH_PLAN_OPTIMIZED.md
2. Start with Batch 1 (Epic 1 - Core Platform)
3. Note: 6 stories, ~5,700 tokens, 60-90 min
```

### Step 3: Execute Batch (60-90 minutes)
```
1. Tell me: "Zaczynamy Batch 1 - Epic 1"
2. I will generate 6 story contexts using templates
3. You review and approve
```

---

## 📖 Template-Based Workflow Example

### OLD WAY (3,000 tokens):
```markdown
# Story 2.1: Morning Check-in

## Executive Summary
[300 tokens describing what check-in does]

## System Architecture
[500 tokens with full ASCII diagram]

## Implementation
[1,000 tokens with complete code examples]

## Database Schema
[400 tokens with full Supabase + Drift schema]

## Testing Strategy
[600 tokens with all test cases]

## Definition of Done
[200 tokens with checklist]

TOTAL: ~3,000 tokens
```

### NEW WAY (600 tokens):
```markdown
# Story 2.1: Morning Check-in

**Base Templates:**
- TEMPLATE-ARCH-01 (CRUD Pattern)
- TEMPLATE-DB-02 (Timestamped Entity)
- TEMPLATE-CODE-04 (Form Widget)
- TEMPLATE-TEST-01 (Repository Test)
- TEMPLATE-DOD-01 (Standard Checklist)

**Custom Elements:**
1. **Fields:** Add mood (1-5), energy (1-5), sleep_hours (0-24)
2. **UI:** Emoji sliders (😞 😐 😊 😁 😍)
3. **Validation:** mood required, others optional
4. **Trigger:** After submit, auto-generate AI daily plan

**Performance Target:** <500ms to submit

**Customized DoD:**
- Standard DoD (see TEMPLATE-DOD-01)
- + Emoji UI renders in <100ms
- + Triggers story 2.2 (AI Daily Plan)

TOTAL: ~600 tokens (80% savings!)
```

---

## 🎯 Execution Strategy

### Week 1-2: Foundation (MUST DO FIRST)
- **Batch 1:** Epic 1 - Core Platform (6 stories, 5.7k tokens)
  - Auth, profile, sync, GDPR
  - Blocks everything else
  - Priority: 🔴 CRITICAL

### Week 3-4: Core Features (HIGH PRIORITY)
- **Batch 2:** Epic 2 - Life Coach Core (4 stories, 3.7k tokens)
- **Batch 4:** Epic 3 - Fitness Foundation (4 stories, 3.6k tokens)
- Can run in parallel (different epics)

### Week 5-6: Advanced Features
- **Batch 3:** Epic 2 - Life Coach Support (5 stories, 4.0k tokens)
- **Batch 5:** Epic 3 - Fitness Progress (5 stories, 4.1k tokens)
- **Batch 6:** Epic 4+5 - Mind + Intelligence (8 stories, 7.6k tokens)

### Week 7-8: Polish & Launch Prep
- **Batch 7:** Epic 4 - Mind Remaining (6 stories, 4.6k tokens)
- **Batch 8:** Epic 6 - Gamification (6 stories, 5.6k tokens)
- **Batch 9:** Epic 7-9 - Onboarding + Settings (12 stories, 11.2k tokens)

---

## 💡 Pro Tips

### Tip 1: Always Check Template Mapping
Before creating any story context:
```
1. Open STORY_TEMPLATE_MAPPING.md
2. Find your story (e.g., 2.1)
3. Note customization level (⭐ or ⭐⭐)
4. Note which templates apply
```

### Tip 2: Use Quick Format for Simple Stories
Stories marked ⭐ or ⭐⭐ (90%+ template):
```
Use QUICK_CONTEXT_FORMAT.md
Expected tokens: 400-800
Time: 10-15 minutes per story
```

### Tip 3: Parallel Execution
You can run batches from different tracks in parallel:
```
Session 1: Batch 1 (Epic 1) + Batch 6 (Epic 4)
Session 2: Batch 2 (Epic 2) + Batch 7 (Epic 4)
→ Finish in 4-5 sessions instead of 9!
```

### Tip 4: Template Customization
Common customizations to document:
- New database fields
- Custom UI components
- Special validation rules
- Performance targets
- Integration points

### Tip 5: Quality Check
After each batch:
- [ ] All templates referenced correctly
- [ ] Custom elements clearly documented
- [ ] Token budget not exceeded
- [ ] Inventory updated

---

## 📊 Success Metrics

### Per Batch
- ✅ All stories have contexts (template-based or full)
- ✅ Token budget <12k per batch
- ✅ Consistency across stories
- ✅ Templates properly referenced

### Overall Project
- 🎯 Target: 60 stories completed
- 🎯 Target: <60k tokens total (we're at 50k!)
- 🎯 Target: 6-8 weeks
- 🎯 Target: High quality (template consistency)

---

## 🚨 Common Mistakes to Avoid

### Mistake 1: Ignoring Templates
❌ Don't: Write full context for ⭐ stories
✅ Do: Use QUICK_CONTEXT_FORMAT.md

### Mistake 2: Copying Templates
❌ Don't: Copy/paste entire template into story context
✅ Do: Reference template by ID (TEMPLATE-ARCH-01)

### Mistake 3: Skipping Customization
❌ Don't: Just list template IDs without custom elements
✅ Do: Clearly document what's DIFFERENT from template

### Mistake 4: Over-Documenting
❌ Don't: Document things already in templates
✅ Do: Document ONLY custom/unique aspects

---

## 📞 Next Steps

**Ready to start?**

Option A: **Start Batch 1** (RECOMMENDED)
```
Say: "Zaczynamy Batch 1 - Epic 1"
I will create 6 story contexts for Core Platform
Time: 60-90 minutes
Tokens: ~5,700
```

Option B: **Review Templates First**
```
Say: "Pokaż mi przykład template-based context"
I will show you an example comparison
```

Option C: **Customize Plan**
```
Say: "Chcę zmienić kolejność batchy"
We can adjust priorities
```

---

**Document Status:** Ready for Production 🎉
**Estimated Project Completion:** 6-8 weeks
**Token Budget:** 50,100 tokens (67% savings!)
**ROI:** 300% (3x return on optimization effort)

---

**Created:** 2025-11-23
**Part of:** Story Context Creation Optimization Initiative
