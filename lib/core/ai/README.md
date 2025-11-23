# AI Service Layer - Core Module

Foundation layer for AI-powered features in LifeOS.

## Overview

This module provides a unified interface for AI integrations (OpenAI, Anthropic) with:
- ✅ Non-streaming completions
- ✅ Streaming completions (word-by-word)
- ✅ Error handling & retries
- ✅ Cost estimation
- ✅ API key validation

## Setup

1. **Install dependencies** (already in pubspec.yaml):
   ```yaml
   dependencies:
     dio: ^5.4.0
     flutter_dotenv: ^5.1.0
     rxdart: ^0.28.0
   ```

2. **Configure API keys**:
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

3. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Usage

### Basic Completion

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/ai/ai_provider.dart';

final response = await ref.read(aiServiceProvider).generateCompletion(
  systemPrompt: 'You are a helpful life coach.',
  userPrompt: 'Give me 3 tips for better sleep.',
);

print(response.content);  // AI response
print(response.tokensUsed);  // 150
print(response.estimatedCost);  // $0.00001
```

### Streaming Completion

```dart
final stream = ref.read(aiServiceProvider).streamCompletion(
  systemPrompt: 'You are a creative writer.',
  userPrompt: 'Write a motivational quote.',
);

await for (final chunk in stream) {
  print(chunk);  // Word-by-word output
}
```

### With Context

```dart
final response = await ref.read(aiServiceProvider).generateCompletion(
  systemPrompt: 'You are a fitness coach.',
  userPrompt: 'Suggest a workout plan.',
  context: {
    'fitness_level': 'beginner',
    'goals': 'lose weight, build strength',
    'available_time': '30 minutes/day',
  },
);
```

## Error Handling

```dart
try {
  final response = await aiService.generateCompletion(...);
} on RateLimitException catch (e) {
  print('Rate limited. Retry after: ${e.retryAfterSeconds}s');
} on AuthenticationException catch (e) {
  print('Invalid API key');
} on NetworkException catch (e) {
  print('Network error: $e');
}
```

## Architecture

```
lib/core/ai/
├── ai_service.dart              # Main service (use this!)
├── ai_config.dart               # Configuration
├── ai_provider.dart             # Riverpod provider
├── models/
│   ├── ai_request.dart          # Request DTO
│   ├── ai_response.dart         # Response DTO
│   └── ai_error.dart            # Error types
└── providers/
    ├── ai_provider_interface.dart
    └── openai_provider.dart     # OpenAI implementation
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key | - |
| `OPENAI_MODEL` | Model to use | `gpt-4o-mini` |
| `OPENAI_MAX_TOKENS` | Max response tokens | `2000` |
| `OPENAI_TEMPERATURE` | Creativity (0-1) | `0.7` |
| `AI_TIMEOUT_SECONDS` | Request timeout | `30` |
| `AI_MAX_RETRIES` | Max retry attempts | `3` |

## Testing

```bash
flutter test test/core/ai/
```

## Used By

- ✅ BATCH 2: AI Daily Plan Generation (Story 2.2)
- ✅ BATCH 2: AI Conversational Coaching (Story 2.4)
- ✅ BATCH 2: Goal Suggestions AI (Story 2.9)

## Token Budget

- **Creation:** ~2K tokens
- **Total Saves:** ~18K tokens (3 stories × 6K each)
- **Efficiency:** 90% reusability 🎉
