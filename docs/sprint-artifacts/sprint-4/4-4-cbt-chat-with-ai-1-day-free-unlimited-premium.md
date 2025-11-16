# Story 4.4: CBT Chat with AI (1/day free, unlimited premium)
**Epic:** 4 - Mind & Emotion | **P0** | **4 SP** | **drafted**

## User Story
**As a** user with negative thoughts, **I want** CBT-trained AI chat, **So that** I reframe thinking and feel better.

## Acceptance Criteria
1. ✅ Accessible from Mind tab
2. ✅ AI uses CBT techniques: Identify distortions, challenge beliefs, reframe thoughts
3. ✅ Free tier: 1 conversation/day (Llama), Premium: Unlimited (Claude/GPT-4)
4. ✅ Empathetic, warm tone (not clinical)
5. ✅ Conversation history saved (GDPR: user can delete)
6. ✅ Response time: <2s (Llama), <3s (Claude/GPT-4)
7. ✅ Timeout handling: Clear error, retry

**FRs:** FR61, FR63

## Tech
```sql
CREATE TABLE cbt_conversations (
  id UUID PRIMARY KEY,
  user_id UUID,
  message_id UUID,
  role TEXT CHECK (role IN ('user', 'assistant')),
  content TEXT,
  timestamp TIMESTAMPTZ
);
```
```typescript
// System prompt: CBT-trained, empathetic
const prompt = "You are a CBT therapist. Help identify cognitive distortions..."
```
**Dependencies:** Epic 1 | **Coverage:** 80%+
