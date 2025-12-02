# Quick Context Format
**Generated:** 2025-11-23
**Purpose:** Ultra-compact format for stories that are 90%+ template-based

---

## Overview

For stories with **⭐ or ⭐⭐ customization** (48 of 65 stories), use this ultra-compact format instead of full context.

**Token Savings:**
- Full context: ~2,500-3,000 tokens
- Quick context: ~300-800 tokens
- **Savings: 80-90% per story**

---

## Quick Context Template

```markdown
# Story X.Y: [Title]

**Epic:** [Number] - [Name]
**Sprint:** [Number]
**Story Points:** [SP]
**Complexity:** [⭐ to ⭐⭐⭐⭐⭐]
**Token Estimate:** [Tokens] (vs [Full Context Tokens] for full context)

---

## Base Templates

**Architecture:**
- [TEMPLATE-ARCH-XX]: [Template Name] - [Use case]

**Database:**
- [TEMPLATE-DB-XX]: [Template Name] - [Use case]

**Code:**
- [TEMPLATE-CODE-XX]: [Template Name] - [Use case]
- [TEMPLATE-CODE-XX]: [Template Name] - [Use case]

**Testing:**
- [TEMPLATE-TEST-XX]: [Template Name] - [Use case]

**UI:**
- [TEMPLATE-UI-XX]: [Template Name] - [Use case]

**Definition of Done:**
- TEMPLATE-DOD-01: Standard checklist

---

## Custom Elements

### 1. [Custom Element Name]
**What's Different:**
- [Specific difference from template]
- [Specific difference from template]

**Why:**
- [Brief explanation]

**Code Snippet:**
```dart
// Only show code that's DIFFERENT from template
[Custom code here]
```

### 2. [Custom Element Name]
**What's Different:**
- [Specific difference from template]

**Why:**
- [Brief explanation]

---

## Performance Targets

- [Metric]: [Target] (e.g., Query: <20ms, UI render: <100ms)
- [Metric]: [Target]

---

## Acceptance Criteria Deltas

**Standard CRUD criteria apply (see TEMPLATE-ARCH-01), PLUS:**
- [Additional AC specific to this story]
- [Additional AC specific to this story]

---

## Risk Assessment

**Template Risks:** All mitigated (see templates)
**Custom Risks:**
- [Risk]: [Mitigation]

---

## Token Savings

**Full context would be:** ~[X] tokens
**Quick context:** ~[Y] tokens
**Savings:** [Z] tokens ([%]% reduction) ✅
```

---

## Examples

### Example 1: Story 1.4 (User Profile Management) - ⭐ Customization

```markdown
# Story 1.4: User Profile Management

**Epic:** 1 - Core Platform Foundation
**Sprint:** 1
**Story Points:** 2
**Complexity:** ⭐
**Token Estimate:** 400 tokens (vs 2,500 for full context)

---

## Base Templates

**Architecture:**
- TEMPLATE-ARCH-01: CRUD Pattern - Standard update operations

**Database:**
- TEMPLATE-DB-01: User-Scoped Table - Users table (already exists)

**Code:**
- TEMPLATE-CODE-01: Freezed Model - User model
- TEMPLATE-CODE-02: Repository Pattern - UserRepository
- TEMPLATE-CODE-03: Riverpod Provider - userProfileProvider
- TEMPLATE-CODE-04: Form Widget - ProfileEditForm

**Testing:**
- TEMPLATE-TEST-01: Repository Test
- TEMPLATE-TEST-02: Provider Test
- TEMPLATE-TEST-03: Widget Test

**UI:**
- TEMPLATE-UI-01: List View - Not needed (single profile)
- TEMPLATE-UI-02: Loading/Error States - Standard

**Definition of Done:**
- TEMPLATE-DOD-01: Standard checklist

---

## Custom Elements

### 1. Avatar Upload
**What's Different:**
- Supabase Storage integration (bucket: 'avatars')
- Image compression before upload (512x512px max)
- Max file size: 5MB

**Why:**
- Storage optimization
- Faster upload/download

**Code Snippet:**
```dart
Future<Result<String>> uploadAvatar(File file) async {
  // Compress image
  final compressed = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 512,
    minHeight: 512,
    quality: 85,
  );

  // Upload to Supabase Storage
  final fileName = '${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _supabase.storage.from('avatars').uploadBinary(
    fileName,
    compressed!,
    fileOptions: FileOptions(contentType: 'image/jpeg'),
  );

  return Result.success(fileName);
}
```

### 2. Email Re-verification
**What's Different:**
- Trigger email verification on email change
- User must verify new email before it's saved

**Why:**
- Security (prevent email hijacking)
- GDPR compliance

**Code Snippet:**
```dart
Future<Result<void>> updateEmail(String newEmail) async {
  await _supabase.auth.updateUser(UserAttributes(email: newEmail));
  // Supabase automatically sends verification email
  return Result.success(null);
}
```

---

## Performance Targets

- Avatar upload: <3s (5MB file over 4G)
- Profile update: <500ms (local + sync queue)

---

## Acceptance Criteria Deltas

**Standard CRUD criteria apply (see TEMPLATE-ARCH-01), PLUS:**
- Avatar uploaded to Supabase Storage (public read, user-specific write)
- Email change triggers verification email
- Old email remains until new email verified

---

## Risk Assessment

**Template Risks:** All mitigated (see TEMPLATE-ARCH-01)
**Custom Risks:**
- Image compression fails: Fallback to original (warn user if >5MB)
- Upload fails: Show retry button, keep local copy

---

## Token Savings

**Full context would be:** ~2,500 tokens
**Quick context:** ~400 tokens
**Savings:** 2,100 tokens (84% reduction) ✅
```

---

### Example 2: Story 2.1 (Morning Check-in Flow) - ⭐⭐ Customization

```markdown
# Story 2.1: Morning Check-in Flow

**Epic:** 2 - Life Coach MVP
**Sprint:** 2
**Story Points:** 3
**Complexity:** ⭐⭐
**Token Estimate:** 700 tokens (vs 2,800 for full context)

---

## Base Templates

**Architecture:**
- TEMPLATE-ARCH-01: CRUD Pattern - Create check-in entry

**Database:**
- TEMPLATE-DB-01: User-Scoped Table - check_ins table
- TEMPLATE-DB-02: Timestamped Entity - created_at, updated_at

**Code:**
- TEMPLATE-CODE-01: Freezed Model - CheckIn model
- TEMPLATE-CODE-02: Repository Pattern - CheckInRepository
- TEMPLATE-CODE-03: Riverpod Provider - checkInProvider
- TEMPLATE-CODE-04: Form Widget - CheckInForm

**Testing:**
- TEMPLATE-TEST-01: Repository Test
- TEMPLATE-TEST-02: Provider Test
- TEMPLATE-TEST-03: Widget Test

**UI:**
- TEMPLATE-UI-02: Loading/Error States

**Definition of Done:**
- TEMPLATE-DOD-01: Standard checklist

---

## Custom Elements

### 1. Emoji Slider UI
**What's Different:**
- Custom slider widget with emoji feedback
- 5 emojis per metric (mood, energy, sleep)
- Haptic feedback on selection
- Default mid-point (3/5)

**Why:**
- Faster input (no text entry)
- Visual feedback (emojis communicate state)
- Accessible (VoiceOver reads "Mood: Happy, 4 out of 5")

**Code Snippet:**
```dart
class EmojiSlider extends StatefulWidget {
  final String label;
  final List<String> emojis; // ['😢', '😞', '😐', '😊', '😄']
  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  State<EmojiSlider> createState() => _EmojiSliderState();
}

class _EmojiSliderState extends State<EmojiSlider> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final emojiValue = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() => _value = emojiValue);
                HapticFeedback.lightImpact();
                widget.onChanged(emojiValue);
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _value == emojiValue
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.emojis[index],
                  style: TextStyle(fontSize: 32),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 4),
        Text(
          _getAccessibilityLabel(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getAccessibilityLabel() {
    final labels = ['Poor', 'Below Average', 'Average', 'Good', 'Excellent'];
    return '${widget.label}: ${labels[_value - 1]}, $_value out of 5';
  }
}
```

### 2. Modal Behavior
**What's Different:**
- Modal cannot be dismissed by swipe-down
- User MUST complete or tap "Skip for today"
- Triggers AI daily plan generation on complete

**Why:**
- Encourages completion (streak building)
- Prevents accidental dismissal
- Links to Story 2.2 (AI plan needs check-in data)

**Code Snippet:**
```dart
Future<void> showCheckInModal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: false, // Cannot dismiss by swipe
    enableDrag: false, // Cannot drag down
    isScrollControlled: true,
    builder: (context) => CheckInModal(),
  );
}
```

### 3. Accessibility
**What's Different:**
- VoiceOver reads: "Mood: Happy, 4 out of 5"
- Semantic labels for all emojis
- Keyboard navigation support

**Why:**
- WCAG compliance
- Inclusive design

---

## Performance Targets

- Modal open: <100ms
- Emoji selection feedback: <50ms (haptic)
- Form submission: <300ms (local + sync queue)

---

## Acceptance Criteria Deltas

**Standard CRUD criteria apply (see TEMPLATE-ARCH-01), PLUS:**
- Modal appears on first app open (if not done today)
- Haptic feedback on emoji selection
- "Skip for today" option (text link, bottom)
- "Generate My Plan" CTA triggers Story 2.2
- Accessibility: VoiceOver support

---

## Risk Assessment

**Template Risks:** All mitigated (see TEMPLATE-ARCH-01)
**Custom Risks:**
- User frustrated by forced modal: Mitigation = "Skip for today" option
- Emoji not culturally appropriate: Mitigation = Test with diverse users

---

## Token Savings

**Full context would be:** ~2,800 tokens
**Quick context:** ~700 tokens
**Savings:** 2,100 tokens (75% reduction) ✅
```

---

### Example 3: Story 3.6 (Body Measurements Tracking) - ⭐ Customization

```markdown
# Story 3.6: Body Measurements Tracking

**Epic:** 3 - Fitness Coach MVP
**Sprint:** 3
**Story Points:** 2
**Complexity:** ⭐
**Token Estimate:** 600 tokens (vs 2,500 for full context)

---

## Base Templates

**Architecture:**
- TEMPLATE-ARCH-01: CRUD Pattern - Standard create/read/update/delete
- TEMPLATE-ARCH-03: List + Detail View - Measurement history

**Database:**
- TEMPLATE-DB-01: User-Scoped Table - body_measurements table
- TEMPLATE-DB-02: Timestamped Entity - created_at, updated_at

**Code:**
- TEMPLATE-CODE-01: Freezed Model - BodyMeasurement model
- TEMPLATE-CODE-02: Repository Pattern - MeasurementRepository
- TEMPLATE-CODE-03: Riverpod Provider - measurementProvider
- TEMPLATE-CODE-04: Form Widget - MeasurementForm

**Testing:**
- TEMPLATE-TEST-01: Repository Test
- TEMPLATE-TEST-02: Provider Test
- TEMPLATE-TEST-03: Widget Test

**UI:**
- TEMPLATE-UI-01: List View with Pull-to-Refresh
- TEMPLATE-UI-02: Loading/Error/Empty States

**Definition of Done:**
- TEMPLATE-DOD-01: Standard checklist

---

## Custom Elements

### 1. Multiple Measurement Fields
**What's Different:**
- 7 measurement types: weight, body_fat_pct, chest, waist, hips, arms, legs
- All fields optional except weight (primary metric)
- Form allows partial entry

**Why:**
- Users track different metrics
- Progressive tracking (start with weight, add more later)

**Schema:**
```sql
CREATE TABLE body_measurements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  date DATE NOT NULL,
  weight DECIMAL(5,2), -- kg or lbs
  body_fat_pct DECIMAL(4,2), -- percentage
  chest DECIMAL(5,2), -- cm or inches
  waist DECIMAL(5,2),
  hips DECIMAL(5,2),
  arms DECIMAL(5,2),
  legs DECIMAL(5,2),
  unit TEXT NOT NULL CHECK (unit IN ('metric', 'imperial')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Unit Conversion
**What's Different:**
- User can toggle between metric (kg, cm) and imperial (lbs, inches)
- Conversion happens on display (stored in user's preferred unit)
- Conversion formulas: 1 kg = 2.20462 lbs, 1 cm = 0.393701 inches

**Why:**
- Regional preferences (US users expect lbs/inches)
- User can switch units anytime

**Code Snippet:**
```dart
class UnitConverter {
  static double weightToDisplay(double kg, bool isMetric) {
    return isMetric ? kg : kg * 2.20462;
  }

  static double lengthToDisplay(double cm, bool isMetric) {
    return isMetric ? cm : cm * 0.393701;
  }

  static String weightUnit(bool isMetric) => isMetric ? 'kg' : 'lbs';
  static String lengthUnit(bool isMetric) => isMetric ? 'cm' : 'in';
}
```

### 3. Goal Weight Tracking
**What's Different:**
- User can set goal weight (optional)
- Progress shown: "3kg to go!" or "Goal reached! 🎉"
- Line on chart shows goal weight

**Why:**
- Motivational (visual progress to goal)

---

## Performance Targets

- Measurement list query: <50ms (indexed on user_id, date)
- Chart rendering: <200ms (30 data points)
- Unit conversion: <10ms (simple math)

---

## Acceptance Criteria Deltas

**Standard CRUD criteria apply (see TEMPLATE-ARCH-01), PLUS:**
- 7 measurement types (weight required, rest optional)
- Unit toggle (metric ↔ imperial)
- Goal weight setting + progress indicator
- Trend charts (30-day, 90-day)

---

## Risk Assessment

**Template Risks:** All mitigated (see TEMPLATE-ARCH-01)
**Custom Risks:**
- Unit conversion errors: Mitigation = Unit tests for all conversions
- Goal weight unrealistic: Mitigation = Warn if >20% change requested

---

## Token Savings

**Full context would be:** ~2,500 tokens
**Quick context:** ~600 tokens
**Savings:** 1,900 tokens (76% reduction) ✅
```

---

## Usage Guidelines

### When to Use Quick Context

✅ **USE for stories with:**
- ⭐ customization (90%+ template)
- ⭐⭐ customization (70-90% template)
- Simple business logic
- Standard UI patterns

❌ **DON'T USE for stories with:**
- ⭐⭐⭐⭐⭐ customization (killer features)
- Complex algorithms
- Security-critical features
- Novel UX patterns

### Quick Context Checklist

Before submitting quick context, verify:
- [ ] All base templates listed
- [ ] Only custom elements documented (not template content)
- [ ] Code snippets show ONLY what's different
- [ ] Performance targets specified (if applicable)
- [ ] Acceptance criteria deltas (not full ACs)
- [ ] Token savings calculated
- [ ] Stays under estimated token budget

---

## Token Impact Summary

### Stories by Customization Level

| Level | Count | Quick Context Tokens | Full Context Tokens | Savings |
|-------|-------|---------------------|---------------------|---------|
| ⭐ | 20 | 400-500 | 2,500 | ~2,000 (80%) |
| ⭐⭐ | 28 | 600-800 | 2,800 | ~2,100 (75%) |
| ⭐⭐⭐ | 12 | 900-1,200 | 3,000 | ~1,900 (63%) |
| **Subtotal** | **48** | **~35,000** | **~135,000** | **~100,000 (74%)** |

**Total Project Impact:**
- 48 stories use quick context
- Average savings: 2,000 tokens per story
- **Total savings: ~100,000 tokens across project**

---

## Template Structure

### Sections (in order)

1. **Header** (Story ID, Epic, Sprint, SP, Complexity, Token Estimate)
2. **Base Templates** (List all templates used)
3. **Custom Elements** (Only what's different)
4. **Performance Targets** (If applicable)
5. **Acceptance Criteria Deltas** (Only additions to template ACs)
6. **Risk Assessment** (Custom risks only)
7. **Token Savings** (Show calculation)

### What to EXCLUDE (Covered by Templates)

- Standard CRUD flow diagrams
- Standard repository implementations
- Standard provider patterns
- Standard form validation
- Standard UI layouts (unless custom)
- Standard testing patterns
- Standard DoD checklist

### What to INCLUDE (Custom to This Story)

- Unique business rules
- Custom widgets
- Performance optimizations
- Integration specifics
- Novel algorithms
- Security considerations
- Accessibility features

---

**Document Status:** ✅ Complete
**Version:** 1.0
**Last Updated:** 2025-11-23
**Expected Usage:** 48 of 65 stories (74%)
**Token Savings:** ~100,000 tokens (74% reduction)
