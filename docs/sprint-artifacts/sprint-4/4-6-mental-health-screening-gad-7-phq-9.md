# Story 4.6: Mental Health Screening (GAD-7, PHQ-9)
**Epic:** 4 - Mind & Emotion | **P1** | **3 SP** | **drafted**

## User Story
**As a** user concerned about mental health, **I want** anxiety/depression screenings, **So that** I assess symptoms and seek help if needed.

## Acceptance Criteria
1. ✅ Accessible from Mind tab → "Mental Health Check"
2. ✅ GAD-7 (anxiety): 7 questions, scored 0-21
3. ✅ PHQ-9 (depression): 9 questions, scored 0-27
4. ✅ One question at a time (not overwhelming)
5. ✅ Score categorized: Minimal, Mild, Moderate, Moderately Severe, Severe
6. ✅ If high (GAD-7 >15, PHQ-9 >20): Show crisis resources (hotlines: UK 116 123, Poland 116 123)
7. ✅ Recommendation: "Consider speaking to a professional"
8. ✅ History saved (track trends)
9. ✅ Disclaimer: "This is not a diagnosis. Consult healthcare professional."

**FRs:** FR66-FR70

## Tech
```sql
CREATE TABLE screenings (
  id UUID PRIMARY KEY,
  user_id UUID,
  type TEXT CHECK (type IN ('GAD-7', 'PHQ-9')),
  score INT,
  category TEXT,
  timestamp TIMESTAMPTZ
);
```
**Dependencies:** Epic 1 | **Coverage:** 80%+
