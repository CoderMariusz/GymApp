# Story 3.6: Body Measurements Tracking

**Epic:** Epic 3 - Fitness Coach MVP
**Priority:** P1 | **Status:** drafted | **Effort:** 2 SP

---

## User Story
**As a** user tracking body composition
**I want** to log body measurements
**So that** I can see non-scale victories

---

## Acceptance Criteria
1. ✅ Body measurements screen (Fitness tab → "Measurements")
2. ✅ Log: Weight, body fat %, chest, waist, hips, arms, legs
3. ✅ Measurements saved with timestamp
4. ✅ Trend charts (line graphs, 30-day, 90-day)
5. ✅ Goal weight setting (optional)
6. ✅ Progress to goal shown ("3kg to go!")
7. ✅ Units: kg/lbs, cm/inches (user preference)

**FRs:** FR39

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE body_measurements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  weight DECIMAL(5, 2),
  body_fat_pct DECIMAL(4, 2),
  chest DECIMAL(5, 2),
  waist DECIMAL(5, 2),
  hips DECIMAL(5, 2),
  arms DECIMAL(5, 2),
  legs DECIMAL(5, 2),
  unit TEXT NOT NULL CHECK (unit IN ('metric', 'imperial')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

### Unit Conversion
```dart
class UnitConverter {
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;
  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => inches * 2.54;
}
```

---

## Dependencies
**Prerequisites:** Epic 1 (Data Sync)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
