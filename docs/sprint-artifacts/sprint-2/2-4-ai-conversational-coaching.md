# Story 2.4: AI Conversational Coaching

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P0 | **Status:** drafted | **Effort:** 5 SP

---

## User Story
**As a** user needing motivation or advice
**I want** to chat with an AI life coach
**So that** I can get personalized guidance and support

---

## Acceptance Criteria
1. ✅ AI Chat from Home tab → "Chat with AI" button
2. ✅ User sends text messages to AI
3. ✅ AI has context: goals, mood, recent activity
4. ✅ AI personality based on onboarding (Sage: calm vs Momentum: energetic)
5. ✅ Free tier: 3-5 conversations/day (Llama), Premium: Unlimited (Claude/GPT-4)
6. ✅ Conversation history saved and viewable
7. ✅ User can delete history (GDPR)
8. ✅ Response time: <2s (Llama), <3s (Claude), <4s (GPT-4)
9. ✅ Timeout: Clear error after 10s, suggest retry
10. ✅ Rate limit indicator: "2 conversations left today"

**FRs:** FR18-FR24

---

## Technical Implementation

### Database Schema
```sql
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  ai_model TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_conversations_session ON ai_conversations(session_id, created_at);
```

### AI Prompt (System Message)
```typescript
const systemPrompt = {
  sage: "You are a calm, wise life coach. Use gentle encouragement. Focus on mindfulness and small steps.",
  momentum: "You are an energetic motivational coach. Be enthusiastic and action-oriented. Use phrases like 'Let's crush this!'"
};

const contextPrompt = `
User Context:
- Goals: ${goals.map(g => g.title).join(', ')}
- Recent mood: ${mood}/5
- Last check-in: ${checkin}
Provide personalized advice based on this context.
`;
```

### Rate Limiting
```dart
class ConversationRateLimiter {
  Future<bool> canSendMessage(String userId) async {
    final tier = await getUserTier(userId);
    if (tier != 'free') return true;

    final todayCount = await countConversationsToday(userId);
    return todayCount < 5; // Free tier limit
  }
}
```

---

## Dependencies
**Prerequisites:** Story 2.3 (Goals for context)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
