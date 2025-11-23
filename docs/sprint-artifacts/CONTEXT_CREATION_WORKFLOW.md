# Context Creation Workflow (OPTIMIZED)
**Generated:** 2025-11-23
**Last Updated:** 2025-11-23 (Template-Based Optimization)
**Purpose:** Step-by-step OPTIMIZED workflow using shared templates (67% token savings)

---

## 🎉 MAJOR UPDATE: Template-Based Workflow

**This workflow has been optimized to use shared templates.**

**Before you start:**
1. Read **SHARED_TEMPLATES_LIBRARY.md** (16 reusable templates)
2. Check **STORY_TEMPLATE_MAPPING.md** (find which templates apply)
3. Use **QUICK_CONTEXT_FORMAT.md** for 90%+ template stories
4. Follow **BATCH_PLAN_OPTIMIZED.md** (9 batches, 50k tokens)

**Token Savings: 67% (99,900 tokens saved!)**

---

## Quick Reference: Optimized Session Tracks

```
OPTIMIZED - Using Template-Based Approach:

TRACK A: Epic 1-3 (Core + Life Coach + Fitness)
├─ Batch 1: Epic 1 (6 stories) [5.7K tokens] ← 68% savings!
├─ Batch 2: Epic 2 Core (4 stories) [3.7K tokens] ← 72% savings!
├─ Batch 3: Epic 2 Support (5 stories) [4.0K tokens] ← 65% savings!
├─ Batch 4: Epic 3 Foundation (4 stories) [3.6K tokens] ← 73% savings!
└─ Batch 5: Epic 3 Progress (5 stories) [4.1K tokens] ← 64% savings!

TRACK B: Epic 4-6 (Mind + Cross-Module + Gamification)
├─ Batch 6: Epic 4+5 Combined (8 stories) [7.6K tokens] ← 64% savings!
├─ Batch 7: Epic 4 Remaining (6 stories) [4.6K tokens] ← 70% savings!
└─ Batch 8: Epic 6 Gamification (6 stories) [5.6K tokens] ← 69% savings!

TRACK C: Epic 7-9 (Onboarding + Notifications + Settings)
└─ Batch 9: Epic 7+8+9 Combined (12 stories) [11.2K tokens] ← 65% savings!

TOTAL: 9 batches, 50,100 tokens (vs 12 batches, 150,000 tokens)
SAVINGS: 99,900 tokens (67% reduction) 🎉
```

### How Template-Based Approach Works

**OLD WAY (Full Context):**
1. Write complete architecture diagram (500 tokens)
2. Write all code examples (1,000 tokens)
3. Write database schemas (400 tokens)
4. Write testing strategy (600 tokens)
5. Write DoD checklist (200 tokens)
→ TOTAL: ~2,700 tokens per story

**NEW WAY (Template-Based):**
1. Reference template: "See TEMPLATE-ARCH-01" (50 tokens)
2. Document ONLY custom elements (300-800 tokens)
→ TOTAL: ~500-1,200 tokens per story (60-80% savings!)
```

---

## Standard Session Workflow Template

### Phase 1: Preparation (15-20 minutes)

#### Step 1.1: Review Batch Plan
```
Action: Read the batch plan from BATCH_CONTEXT_CREATION_PLAN.md
Check:
- [ ] Which stories are in this batch?
- [ ] What is the estimated token budget?
- [ ] What are the key focus areas?
- [ ] Which template should I use?
```

#### Step 1.2: Read Prerequisites
```
Action: Read all prerequisite files BEFORE starting context creation
Files to read (typical):
- [ ] Epic tech spec (docs/sprint-artifacts/tech-spec-epic-X.md)
- [ ] Sprint summary (docs/sprint-artifacts/sprint-X/SPRINT-SUMMARY.md)
- [ ] Template context file (story-2-2-detailed-context.md or relevant)
- [ ] Story files (docs/sprint-artifacts/sprint-X/X-Y-story-name.md)

Tip: Use parallel Read calls to fetch all files at once
```

#### Step 1.3: Analyze Template Structure
```
Action: Review template file structure
Standard sections:
- Executive Summary (🎯)
- System Architecture (📊) - ASCII diagram required
- Implementation (💻) - Dart code snippets
- Testing Strategy (🧪) - Unit + integration tests
- Performance Optimization (⚡) - If applicable
- Definition of Done (✅) - Checklist

Note: Adapt sections based on story complexity
```

---

### Phase 2: Context Creation (60-90 minutes per batch)

#### Step 2.1: Create Story Contexts in Order

**For each story in the batch:**

##### Substep A: Analyze Story Requirements
```
Read the story file (X-Y-story-name.md)
Extract:
- [ ] User story (As a... I want... So that...)
- [ ] Acceptance criteria (functional requirements)
- [ ] Non-functional requirements (performance, security, etc.)
- [ ] Story points (complexity indicator)
- [ ] Dependencies (other stories required)
- [ ] Priority (P0/P1/P2)
```

##### Substep B: Design System Architecture
```
Create ASCII diagram showing:
- [ ] User trigger (button tap, API call, cron job)
- [ ] Data flow (client → service → repository → database)
- [ ] External integrations (Supabase, AI APIs, FCM, etc.)
- [ ] Performance targets (response times, token limits, etc.)

Example:
┌─────────────────────────────────────────┐
│ TRIGGER: User taps "Log Workout"        │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ STEP 1: Fetch Last Workout (<200ms)    │
│  - Query workout_sets table             │
│  - Filter by exercise_id + user_id     │
│  - Order by created_at DESC, limit 10   │
└─────────────────────────────────────────┘
```

##### Substep C: Write Implementation Code
```
Provide Dart code snippets for:
- [ ] Data models (@freezed classes)
- [ ] Repositories (database queries - Drift)
- [ ] Services (business logic)
- [ ] Providers (Riverpod state management)
- [ ] UI widgets (if UI-heavy story)

Guidelines:
- Use @freezed for immutable data classes
- Use Riverpod for state management
- Use Drift for local database (SQLite)
- Use Supabase client for backend queries
- Include error handling (try-catch, Result<T> pattern)
```

##### Substep D: Define Database Schema
```
Include both:
1. Supabase (PostgreSQL) schema:
   CREATE TABLE table_name (
     id UUID PRIMARY KEY,
     user_id UUID REFERENCES auth.users(id),
     ...
   );

2. Drift (SQLite) mirror:
   @DriftDatabase(tables: [TableName])
   class AppDatabase extends _$AppDatabase {
     ...
   }

3. Indexes for performance:
   CREATE INDEX idx_workout_sets_user_exercise
   ON workout_sets(user_id, exercise_id, created_at DESC);
```

##### Substep E: Write Testing Strategy
```
Include:
- [ ] Unit tests (test business logic, services, repositories)
- [ ] Widget tests (test UI components, user interactions)
- [ ] Integration tests (test E2E flows, API calls)
- [ ] Performance tests (if applicable - response times, memory usage)

Example:
test('Smart Pattern Memory pre-fills last workout', () async {
  // Setup
  await createMockWorkout(userId, exerciseId, sets: 3, reps: 10, weight: 100);

  // Execute
  final lastWorkout = await workoutService.getLastWorkout(exerciseId);

  // Assert
  expect(lastWorkout.sets.length, equals(3));
  expect(lastWorkout.sets.first.reps, equals(10));
  expect(lastWorkout.sets.first.weight, equals(100));
});
```

##### Substep F: Add Performance Optimization (if applicable)
```
For performance-critical stories (Smart Pattern, AI generation, Charts):
- [ ] Target metrics (e.g., <2s per set, <3s AI response)
- [ ] Optimization strategies (caching, indexing, parallel queries)
- [ ] Monitoring plan (logging, analytics)

Example:
**Target: <2s per set**
Breakdown:
- Fetch last workout: <200ms (indexed query)
- Pre-fill UI: <50ms (cached data)
- User adjustment: <100ms (debounced input)
- Save to DB: <150ms (batch insert)
- Total: <500ms ✅
```

##### Substep G: Complete Definition of Done
```
Checklist format:
- [ ] Feature X implemented
- [ ] Unit tests passing (80%+ coverage)
- [ ] Widget tests passing (70%+ coverage)
- [ ] Integration tests passing (E2E flow)
- [ ] Performance targets met
- [ ] Code reviewed and approved
- [ ] Merged to develop branch
- [ ] Documentation updated
```

---

#### Step 2.2: Cross-Reference and Validate

**After creating all contexts in the batch:**

```
Action: Validate consistency across stories
Checks:
- [ ] Database schemas align across stories (no conflicts)
- [ ] Data models are consistent (same field names, types)
- [ ] Dependencies are correctly referenced
- [ ] No circular dependencies
- [ ] All NFRs (non-functional requirements) are addressed

Example:
Story 2.1 (Morning Check-in) creates check_ins table
Story 2.2 (AI Daily Plan) references check_ins.mood, check_ins.energy
→ Ensure field names match exactly!
```

---

### Phase 3: Quality Assurance (15-20 minutes)

#### Step 3.1: Self-Review Checklist

```
For each story context, verify:

Structure:
- [ ] All sections present (Executive Summary, Architecture, Implementation, Testing, DoD)
- [ ] Consistent formatting (headings, code blocks, lists)
- [ ] No placeholder text (no "TODO", "TBD", "[Insert here]")

Technical Depth:
- [ ] ASCII architecture diagram included
- [ ] Code snippets are complete (not pseudocode)
- [ ] Database schema included (both Supabase + Drift)
- [ ] Error handling shown in code examples

Testing:
- [ ] Unit test examples provided
- [ ] Integration test scenarios described
- [ ] Coverage targets specified (80%+ unit, 70%+ widget)

Cross-References:
- [ ] Links to related stories (e.g., "Depends on Story 2.1")
- [ ] References to epic tech spec
- [ ] References to existing implementation (if available)

Completeness:
- [ ] All acceptance criteria addressed
- [ ] All NFRs addressed (performance, security, etc.)
- [ ] Definition of Done is actionable
```

---

#### Step 3.2: Token Usage Check

```
Action: Verify batch stays within token budget

Estimate:
- Small story (2 SP): ~2,000 tokens
- Medium story (3 SP): ~2,500-3,000 tokens
- Large story (4-5 SP): ~3,500-4,500 tokens

Batch limit: ~20,000 tokens max

If over budget:
1. Consolidate code examples (focus on critical paths)
2. Simplify ASCII diagrams (reduce whitespace)
3. Reduce test example count (keep most critical)
4. Move low-priority stories to next batch
```

---

### Phase 4: Finalization (10-15 minutes)

#### Step 4.1: Save Context Files

```
Action: Write each context to a file

File naming convention:
story-X-Y-detailed-context.md

Where:
- X = Epic number (1-9)
- Y = Story number within epic (1-N)

Example:
story-1-1-detailed-context.md (Epic 1, Story 1)
story-2-4-detailed-context.md (Epic 2, Story 4)

Location:
C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\
```

---

#### Step 4.2: Update Inventory

```
Action: Update STORY_CONTEXT_INVENTORY.md

Change story status from:
🔄 NEEDS CONTEXT → ✅ READY

Update statistics:
- Stories with Context: X (+N)
- Coverage %: Update epic-level percentages

Example:
| 2.1 | Morning Check-in Flow | 2 | ✅ completed | ✅ READY | C:\...\story-2-1-detailed-context.md |
```

---

#### Step 4.3: Document Learnings

```
Action: Note any insights or adjustments for next batch

Common learnings:
- Token usage: Did we over/under estimate?
- Template fit: Did the template work well for this epic?
- Dependencies: Did we discover new dependencies?
- Complexity: Were story points accurate?

Save notes in:
docs/sprint-artifacts/batch-execution-log.md (create if needed)
```

---

## Detailed Session Guides

### Session 1: Batch 1 - Epic 1 Foundation
**Stories:** 1.1, 1.2, 1.5, 1.6
**Est. Duration:** 90-120 minutes
**Est. Tokens:** 12,000

#### Prerequisites
```
Read before starting:
1. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\tech-spec-epic-1.md
2. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-1\SPRINT-SUMMARY.md
3. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-1\1-1-user-account-creation.md
4. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-1\1-2-user-login-session-management.md
5. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-1\1-5-data-sync-across-devices.md
6. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-1\1-6-gdpr-compliance-data-export-deletion.md
7. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\story-4-5-detailed-context.md (template for security patterns)
```

#### Template Reference
Use story-4-5-detailed-context.md for:
- Security patterns (encryption, auth)
- Data privacy considerations
- GDPR compliance patterns

#### Key Focus Areas
1. **Story 1.1 (User Account Creation):**
   - Supabase Auth integration (email + Google + Apple)
   - Email verification flow
   - User profile creation (auto-generate user_profiles row)
   - Error handling (duplicate email, weak password, etc.)

2. **Story 1.2 (Login & Session Management):**
   - Supabase Auth session handling
   - Session persistence (30 days)
   - Auto-login on app launch
   - Secure token storage (Flutter Secure Storage)

3. **Story 1.5 (Data Sync):**
   - Hybrid sync strategy (Write-Through Cache + Sync Queue)
   - Conflict resolution (last-write-wins)
   - Opportunistic sync (battery-friendly <5%)
   - Offline queue management

4. **Story 1.6 (GDPR Compliance):**
   - Data export (ZIP with JSON + CSV)
   - Deletion request (7-day grace period)
   - Edge Functions (export-user-data, delete-account)
   - Email notifications (export ready, deletion confirmed)

#### Output Files
```
story-1-1-detailed-context.md (~3,000 tokens)
story-1-2-detailed-context.md (~2,500 tokens)
story-1-5-detailed-context.md (~3,500 tokens)
story-1-6-detailed-context.md (~3,000 tokens)
Total: ~12,000 tokens ✅
```

---

### Session 2: Batch 2 - Epic 2 Core AI
**Stories:** 2.1, 2.4, 2.3
**Est. Duration:** 90-120 minutes
**Est. Tokens:** 10,000

#### Prerequisites
```
Read before starting:
1. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\tech-spec-epic-2.md
2. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-2\SPRINT-SUMMARY.md
3. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-2\2-1-morning-check-in-flow.md
4. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-2\2-4-ai-conversational-coaching.md
5. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\sprint-2\2-3-goal-creation-tracking.md
6. C:\Users\Mariusz K\Documents\Programowanie\GymAPP\GymApp\docs\sprint-artifacts\story-2-2-detailed-context.md (template for AI patterns)
```

#### Template Reference
Use story-2-2-detailed-context.md for:
- AI integration patterns (context aggregation, prompt engineering)
- Multi-tier AI routing (Llama/Claude/GPT-4)
- Rate limiting (free tier restrictions)
- Response parsing and validation

#### Key Focus Areas
1. **Story 2.1 (Morning Check-in):**
   - UI design (mood, energy, sleep - 1-5 scale with emoji)
   - Quick completion (<60 seconds)
   - Data validation (required fields, range checks)
   - Triggers Story 2.2 (AI Daily Plan)

2. **Story 2.4 (AI Conversational Coaching):**
   - Chat architecture (context window management - last 10 messages)
   - AI personality (Sage vs Momentum)
   - Multi-tier routing (Llama/Claude/GPT-4)
   - Rate limiting (free: 5 conversations/day, premium: unlimited)
   - Conversation history storage

3. **Story 2.3 (Goal Creation & Tracking):**
   - Goal form (title, category, target date, milestones)
   - Free tier limit (max 3 goals)
   - Progress tracking (0-100%)
   - Goal status (active, completed, archived)

#### Output Files
```
story-2-1-detailed-context.md (~2,500 tokens)
story-2-4-detailed-context.md (~4,500 tokens - complex AI feature)
story-2-3-detailed-context.md (~3,000 tokens)
Total: ~10,000 tokens ✅
```

---

### Session 3-12: Follow Similar Pattern

**For each subsequent session:**
1. Read prerequisites (epic tech spec, sprint summary, story files, template)
2. Focus on key areas (from batch plan)
3. Create contexts following template structure
4. Validate consistency across stories
5. Save files with correct naming convention
6. Update inventory

---

## Common Pitfalls to Avoid

### Pitfall 1: Skipping Prerequisites
```
❌ Don't: Start writing contexts without reading story files
✅ Do: Read all prerequisites first (15-20 minutes investment)

Why: Context creation is much faster when you understand the full picture
```

### Pitfall 2: Inconsistent Data Models
```
❌ Don't: Use different field names across related stories
   Story 2.1: checkIns.moodLevel
   Story 2.2: checkIn.mood  ← INCONSISTENT!

✅ Do: Standardize field names from the start
   Both: checkIns.mood ✅
```

### Pitfall 3: Vague Acceptance Criteria
```
❌ Don't: "User can log workouts" (too vague)
✅ Do: "User can log a set in <2 seconds using Smart Pattern Memory pre-fill"

Why: Specific criteria enable better testing and validation
```

### Pitfall 4: Missing Error Handling
```
❌ Don't: Show only happy path in code examples
✅ Do: Include try-catch, null checks, Result<T> pattern

Example:
try {
  final plan = await dailyPlanService.generateDailyPlan(userId);
  return Result.success(plan);
} catch (e) {
  if (e is RateLimitException) {
    return Result.failure('Daily plan limit reached (5/day on free tier)');
  }
  return Result.failure('Failed to generate plan: $e');
}
```

### Pitfall 5: Ignoring Performance
```
❌ Don't: Forget to specify performance targets
✅ Do: Define clear targets and optimization strategies

Example:
**Target: <3s AI plan generation**
- Context aggregation: <500ms (parallel queries)
- AI API call: <2.5s (streaming response)
- Parsing & saving: <200ms
```

---

## Quick Reference: Template Sections

### Minimal Template (Simple Story, 2 SP)
```
1. Executive Summary (2-3 sentences)
2. System Architecture (simple ASCII diagram)
3. Implementation (key code snippets)
4. Testing Strategy (2-3 critical tests)
5. Definition of Done (5-7 items)

Total: ~2,000 tokens
```

### Standard Template (Medium Story, 3 SP)
```
1. Executive Summary (3-4 sentences)
2. System Architecture (detailed ASCII diagram)
3. Implementation (multiple code snippets - models, services, providers)
4. Database Schema (Supabase + Drift)
5. Testing Strategy (unit + integration tests)
6. Definition of Done (7-10 items)

Total: ~2,500-3,000 tokens
```

### Comprehensive Template (Complex Story, 4-5 SP)
```
1. Executive Summary (4-5 sentences)
2. System Architecture (detailed ASCII diagram with performance notes)
3. Implementation (extensive code - models, repositories, services, providers, UI)
4. Database Schema (Supabase + Drift + indexes + materialized views)
5. Testing Strategy (unit + widget + integration + performance tests)
6. Performance Optimization (targets, strategies, monitoring)
7. Non-Functional Requirements (NFRs)
8. Risks & Mitigations
9. Definition of Done (10-15 items)

Total: ~3,500-4,500 tokens
```

---

## Success Metrics

### Per Session
- [ ] All stories in batch have detailed contexts
- [ ] Token budget not exceeded
- [ ] Inventory updated
- [ ] No blockers identified

### Per Epic
- [ ] All HIGH priority stories completed
- [ ] Database schemas consistent across stories
- [ ] Cross-references validated
- [ ] Dependencies mapped

### Overall Project
- [ ] 60 stories with detailed contexts
- [ ] All epics covered
- [ ] Implementation-ready documentation
- [ ] Developer velocity increased (clear specs → faster coding)

---

**Document Status:** Ready for Use
**Estimated Time to Complete All Sessions:** 8-10 weeks (with parallel tracks)
**Success Rate Target:** 95%+ (58+ out of 60 stories completed to high quality)
