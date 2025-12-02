# Story 4.15: Code Generation and Build Setup
**Epic:** 4 - Mind & Emotion | **P2** | **0.5 SP** | **backlog**

## User Story
**As a** developer, **I want** generated code files for freezed/drift/riverpod, **So that** the app can compile and run properly.

## Context
Extracted from Story 4.1 code review findings (Low Priority - Technical Debt).
Current code uses code generation annotations but missing generated files.

## Acceptance Criteria
1. ✅ Run build_runner successfully
2. ✅ All .freezed.dart files generated
3. ✅ All .g.dart (json_serializable) files generated
4. ✅ All .drift.dart files generated
5. ✅ No compilation errors

## Tech
```bash
# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Verify generated files
find lib -name "*.freezed.dart" -o -name "*.g.dart" -o -name "*.drift.dart"
```

**Dependencies:** None | **Coverage:** N/A

## Tasks
- [ ] Run build_runner for code generation
- [ ] Verify all freezed entities compile
- [ ] Verify all JSON serialization works
- [ ] Verify Drift database generates correctly
- [ ] Add build_runner to CI/CD pipeline
- [ ] Document code generation in README

**MVP:** Required before production but can defer in development
**Estimated Effort:** 0.5 SP (simple command execution)
**Note:** Can be done anytime, low risk
