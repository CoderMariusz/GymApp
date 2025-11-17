# Story 9.3: Unit Preferences (kg/lbs, cm/inches)

**Epic:** Epic 9 - Settings & Profile
**Sprint:** 9
**Story Points:** 2
**Priority:** P1
**Status:** ready-for-dev

## Dev Agent Record

### Context Reference

- **Story Context File:** [9-3-unit-preferences.context.xml](./9-3-unit-preferences.context.xml)
- **Generated:** 2025-11-17
- **Status:** Context created, story ready for implementation

---

---

## User Story

**As a** user
**I want** to choose my preferred units (kg/lbs, km/miles, cm/inches)
**So that** data is displayed in units I'm familiar with

---

## Acceptance Criteria

- ✅ User can select **weight unit**: kg or lbs (default: kg)
- ✅ User can select **distance unit**: km or miles (default: km)
- ✅ User can select **height unit**: cm or inches (default: cm)
- ✅ All historical data displayed in selected units (conversion at display time)
- ✅ **No data modification:** Historical data remains in original units
- ✅ Conversion formulas:
  - Weight: 1 kg = 2.20462 lbs
  - Distance: 1 km = 0.621371 miles
  - Height: 1 cm = 0.393701 inches
- ✅ Settings persist and sync across devices

---

## Technical Implementation

See: `docs/sprint-artifacts/tech-spec-epic-9.md` Section 3.2

**Key Services:**
- `UserSettingsService.updateWeightUnit()`
- `UserSettingsService.updateDistanceUnit()`
- `UserSettingsService.updateHeightUnit()`
- `UnitConversionService.formatWeight()`
- `UnitConversionService.formatDistance()`
- `UnitConversionService.formatHeight()`

**Storage Strategy:**
- Historical data stored in **original units** (no conversion)
- User preference stored in `user_settings` table
- Conversion happens **at display time** only

**Example:**
```dart
// Display logic
String formatWeight(double weightKg, WeightUnit unit) {
  if (unit == WeightUnit.lbs) {
    final weightLbs = weightKg * 2.20462;
    return '${weightLbs.toStringAsFixed(1)} lbs';
  }
  return '${weightKg.toStringAsFixed(1)} kg';
}
```

---

## UI/UX Design

**UnitPreferencesScreen**
- Section 1: Weight
  - Segmented button: kg | lbs
  - Selected unit highlighted

- Section 2: Distance
  - Segmented button: km | miles
  - Selected unit highlighted

- Section 3: Height
  - Segmented button: cm | inches
  - Selected unit highlighted

- Footer note:
  - "Historical data remains in original units. Conversion happens at display time."

---

## Testing

**Critical Scenarios:**
1. User logs workout (100kg squat) → Switch to lbs → Display shows "220.5 lbs"
2. Switch back to kg → Display shows "100.0 kg" (original data preserved)
3. User in US (prefers lbs) → All workout data displayed in lbs
4. New user → Default units (kg, km, cm)

---

## Definition of Done

- ✅ User can select weight/distance/height units
- ✅ All data displayed in selected units
- ✅ No data modification (conversion at display time)
- ✅ Settings persist and sync
- ✅ Unit tests for conversion formulas
- ✅ Code reviewed and merged

**Created:** 2025-01-16 | **Author:** Bob
