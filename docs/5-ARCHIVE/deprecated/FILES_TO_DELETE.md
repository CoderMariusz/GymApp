# Files to Delete - Documentation Cleanup

**Date:** 2025-11-23
**Purpose:** Remove obsolete brainstorming, research, and temporary analysis files

---

## DELETE Immediately (Build Artifacts & Temporary Files)

These files are temporary build/analysis outputs and should be deleted:

1. `analyze_output_latest.txt`
2. `build_runner_output.txt`
3. `build_runner_output2.txt`
4. `build_runner_output3.txt`
5. `dev1_raw_errors.txt`
6. `dev1_tasks.md`
7. `dev2_raw_errors.txt`
8. `dev2_tasks.md`
9. `error_analysis_data.json`
10. `errors_summary.md`
11. `flutter_analyze_full.txt`

**Reason:** These are temporary analysis files from debugging sessions. Not needed for future development.

**Command to delete:**
```bash
rm analyze_output_latest.txt build_runner_output*.txt dev1_*.txt dev1_tasks.md dev2_*.txt dev2_tasks.md error_analysis_data.json errors_summary.md flutter_analyze_full.txt
```

---

## ARCHIVE (Historical Documentation - Move to docs/archive/)

These files contain historical brainstorming and research that may be valuable for reference but clutter the main docs:

### Ecosystem Brainstorming/Research
12. `docs/ecosystem/bmm-brainstorming-session-2025-01-16.md`
13. `docs/ecosystem/brainstorming-answers.md`
14. `docs/ecosystem/research-domain-2025-01-16.md`
15. `docs/ecosystem/research-technical-2025-01-16.md`

### Module-Fitness Brainstorming/Research
16. `docs/modules/module-fitness/bmm-brainstorming-session-2025-11-15.md`
17. `docs/modules/module-fitness/deep-research-prompts.md`
18. `docs/modules/module-fitness/market-research-condensed.md`
19. `docs/modules/module-fitness/technical-research-condensed.md`
20. `docs/modules/module-fitness/user-research-condensed.md`

**Reason:** These files were useful during planning phase but are no longer needed for day-to-day development. Archive for historical reference.

**Recommended action:**
```bash
# Create archive directory
mkdir -p docs/archive/historical/2025-01-16-planning
mkdir -p docs/archive/historical/2025-11-15-fitness-research

# Move ecosystem files
mv docs/ecosystem/bmm-brainstorming-session-2025-01-16.md docs/archive/historical/2025-01-16-planning/
mv docs/ecosystem/brainstorming-answers.md docs/archive/historical/2025-01-16-planning/
mv docs/ecosystem/research-domain-2025-01-16.md docs/archive/historical/2025-01-16-planning/
mv docs/ecosystem/research-technical-2025-01-16.md docs/archive/historical/2025-01-16-planning/

# Move fitness module files
mv docs/modules/module-fitness/bmm-brainstorming-session-2025-11-15.md docs/archive/historical/2025-11-15-fitness-research/
mv docs/modules/module-fitness/deep-research-prompts.md docs/archive/historical/2025-11-15-fitness-research/
mv docs/modules/module-fitness/market-research-condensed.md docs/archive/historical/2025-11-15-fitness-research/
mv docs/modules/module-fitness/technical-research-condensed.md docs/archive/historical/2025-11-15-fitness-research/
mv docs/modules/module-fitness/user-research-condensed.md docs/archive/historical/2025-11-15-fitness-research/
```

---

## KEEP (Essential Documentation)

Do NOT delete these files - they are actively used:

### Core Documentation
- `docs/ecosystem/PRD.md` - Product Requirements Document
- `docs/ecosystem/architecture.md` - System architecture
- `docs/ecosystem/epics.md` - All epics overview
- `docs/PROJECT-SETUP-GUIDE.md` - Setup instructions
- `docs/DEVELOPMENT_GUIDE.md` - **NEW** Consolidated development guide
- `docs/DOCUMENTATION_AUDIT_REPORT.md` - **NEW** This audit report

### Sprint Documentation
- `docs/sprint-artifacts/sprint-1/SPRINT-SUMMARY.md` through `sprint-9/SPRINT-SUMMARY.md`
- All story files in sprint-artifacts directories

### Module Documentation
- `docs/modules/module-fitness/epics.md`
- `docs/modules/module-fitness/sprint-*.md`
- All story context files

---

## Summary

**Total Files to Process:** 20

- **Delete immediately:** 11 files (temporary build/analysis outputs)
- **Archive:** 9 files (historical brainstorming/research)
- **Keep:** All sprint artifacts, epics, architecture, PRD, guides

**Cleanup Benefits:**
- Cleaner docs/ directory
- Easier navigation for developers
- Preserve historical context in archive
- Remove clutter from root directory

---

**Next Steps:**

1. Review this list
2. Execute DELETE commands (verify files aren't needed first)
3. Execute ARCHIVE commands (move to docs/archive/)
4. Update .gitignore to prevent future temporary files:
   ```
   # Add to .gitignore
   *_output.txt
   *_errors.txt
   error_analysis_data.json
   errors_summary.md
   flutter_analyze_*.txt
   ```

---

**Created:** 2025-11-23
**Part of:** Documentation Audit & Cleanup Initiative
