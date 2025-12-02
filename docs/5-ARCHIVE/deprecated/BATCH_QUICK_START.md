# BATCH REPAIR - QUICK START GUIDE

## 🚀 **READY TO START?**

You have **916 errors** divided into **6 independent batches**.

---

## **OPTION 1: Single Agent (Sequential) - 65 min**
Run batches one by one:
```bash
# Follow BATCH_REPAIR_INSTRUCTIONS.md
# Do Batch 1, then 2, then 3, etc.
```

## **OPTION 2: Multiple Agents (Parallel) - 30 min** ⭐ RECOMMENDED

### Setup
1. Open 6 Claude Code sessions (or 6 terminal windows)
2. Each session: `cd /path/to/GymApp`
3. Assign batches:
   - **Session 1** → BATCH 1 (Freezed)
   - **Session 2** → BATCH 2 (Riverpod)
   - **Session 3** → BATCH 3 (Result<T>)
   - **Session 4** → BATCH 4 (Drift)
   - **Session 5** → BATCH 5 (Mocks)
   - **Session 6** → BATCH 6 (Cleanup)

### Execute
Each session independently follows their batch instructions from `BATCH_REPAIR_INSTRUCTIONS.md`.

### Merge
After all done, one agent runs "FINAL MERGE STEP".

---

## **BATCH PRIORITY ORDER** (If doing sequentially)

1. **BATCH 1** - Freezed (CRITICAL) - 10 min → fixes 150 errors
2. **BATCH 2** - Riverpod (CRITICAL) - 8 min → fixes 200 errors
3. **BATCH 3** - Result<T> (HIGH) - 12 min → fixes 100 errors
4. **BATCH 4** - Drift (MEDIUM) - 10 min → fixes 80 errors
5. **BATCH 5** - Mocks (LOW) - 8 min → fixes 50 errors
6. **BATCH 6** - Cleanup (LOW) - 15 min → fixes 336 errors

**Total Sequential:** 63 min
**Total Parallel:** ~15 min (longest batch) + 5 min (merge)

---

## **VERIFICATION CHECKPOINTS**

After each batch:
```bash
flutter analyze 2>&1 | grep -c "error -"
```

Expected error reduction:
- After Batch 1: ~766 errors (150 fixed)
- After Batch 2: ~566 errors (200 fixed)
- After Batch 3: ~466 errors (100 fixed)
- After Batch 4: ~386 errors (80 fixed)
- After Batch 5: ~336 errors (50 fixed)
- After Batch 6: ~0 errors (336 fixed)

---

## **WHAT EACH AGENT NEEDS TO KNOW**

### Agent Instructions Format
```
Agent [N], you are assigned BATCH [N].

Read: docs/BATCH_REPAIR_INSTRUCTIONS.md
Section: "BATCH [N]: [Title]"

Follow the instructions exactly.
After completion, report:
- ✅ Files modified
- ✅ Errors before
- ✅ Errors after
- ❌ Any issues encountered
```

### Example Prompt for Agent 1
```
You are Agent 1.
Your task: BATCH 1 - Freezed Sealed Classes Migration

Read the file: docs/BATCH_REPAIR_INSTRUCTIONS.md
Section: "BATCH 1: Freezed Sealed Classes Migration"

Follow all steps under "Instructions".
Do NOT touch files from other batches.

When done, run:
flutter analyze 2>&1 | grep -c "error -"

Report the count.
```

---

## **TOKEN SAVINGS CALCULATION**

### Sequential (1 agent):
- Agent reads full context: 120K tokens
- Total: 120K tokens

### Parallel (6 agents):
- Each agent reads only their batch: ~25K tokens
- Total: 6 × 25K = 150K tokens
- BUT executes in 1/4 the time!

**Trade-off:** +30K tokens for 4x speed improvement ✅

---

## **EMERGENCY: Single Critical Fix**

If you just want app to compile ASAP, run only:

```bash
# BATCH 1 + BATCH 2 (20 min, fixes 350 errors = 38%)
# This might be enough to compile
```

Then regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
```

If still errors, continue with Batch 3-6.

---

## **READY TO START?**

Choose your approach:
- [ ] **Parallel** (6 agents, 30 min)
- [ ] **Sequential** (1 agent, 65 min)
- [ ] **Critical Only** (Batch 1+2, 20 min)

Then follow: `docs/BATCH_REPAIR_INSTRUCTIONS.md`
