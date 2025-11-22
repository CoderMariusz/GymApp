# Shared Components - Foundation Layer

**Epic:** 2 & 3
**Token Budget:** ~5K
**Czas:** 1 dzień
**Priorytet:** CRITICAL (required by both BATCH 2 and BATCH 4)

---

## Cel

Utworzenie wspólnych komponentów wielokrotnego użytku dla:
- **BATCH 2:** AI Service Layer (OpenAI/Anthropic integration)
- **BATCH 4:** Chart Widgets (fl_chart wrappers)

**Token Savings:** ~60% (komponenty używane 10+ razy w różnych stories)

---

## Dependencies

```yaml
# pubspec.yaml - dodaj:
dependencies:
  # AI Features (BATCH 2)
  http: ^1.1.0
  dio: ^5.4.0
  flutter_dotenv: ^5.1.0
  rxdart: ^0.28.0
  uuid: ^4.3.3

  # Charts (BATCH 4)
  fl_chart: ^0.68.0
  collection: ^1.18.0

  # Shared
  intl: ^0.19.0
  freezed_annotation: ^2.4.1

dev_dependencies:
  freezed: ^2.4.7
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

---

## Part 1: AI Service Layer (BATCH 2 Foundation)

### 1.1 Struktura Folderów

```
lib/core/ai/
├── ai_service.dart                  ✅ Main interface
├── ai_config.dart                   ✅ Configuration (API keys, models)
├── providers/
│   ├── ai_provider_interface.dart   ✅ Abstract provider
│   ├── openai_provider.dart         ✅ ChatGPT implementation
│   └── anthropic_provider.dart      ✅ Claude fallback
├── models/
│   ├── ai_request.dart              ✅ Request DTO
│   ├── ai_response.dart             ✅ Response DTO
│   └── ai_error.dart                ✅ Error types
├── prompt_builder.dart              ✅ Template engine
├── stream_handler.dart              ✅ SSE streaming
└── error_handler.dart               ✅ Retry logic
```

---

### 1.2 Implementation Steps

#### Step 1: Environment Setup

**File:** `.env` (create at project root)

```env
# OpenAI Configuration
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=2000
OPENAI_TEMPERATURE=0.7

# Anthropic Configuration (fallback)
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxx
ANTHROPIC_MODEL=claude-3-5-haiku-20241022
ANTHROPIC_MAX_TOKENS=2000

# General
AI_TIMEOUT_SECONDS=30
AI_MAX_RETRIES=3
```

**File:** `lib/core/ai/ai_config.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIConfig {
  // OpenAI
  static String get openAIKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIModel => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
  static int get maxTokens => int.parse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '2000');
  static double get temperature => double.parse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7');

  // Anthropic (fallback)
  static String get anthropicKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  static String get anthropicModel => dotenv.env['ANTHROPIC_MODEL'] ?? 'claude-3-5-haiku-20241022';

  // General
  static int get timeoutSeconds => int.parse(dotenv.env['AI_TIMEOUT_SECONDS'] ?? '30');
  static int get maxRetries => int.parse(dotenv.env['AI_MAX_RETRIES'] ?? '3');

  // Validate configuration
  static bool get isConfigured => openAIKey.isNotEmpty || anthropicKey.isNotEmpty;
}
```

**Update:** `lib/main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
```

---

#### Step 2: Data Models

**File:** `lib/core/ai/models/ai_request.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_request.freezed.dart';
part 'ai_request.g.dart';

@freezed
class AIRequest with _$AIRequest {
  const factory AIRequest({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
    @Default(false) bool stream,
    @Default(2000) int maxTokens,
    @Default(0.7) double temperature,
  }) = _AIRequest;

  factory AIRequest.fromJson(Map<String, dynamic> json) =>
      _$AIRequestFromJson(json);
}
```

**File:** `lib/core/ai/models/ai_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String content,
    required int tokensUsed,
    required double estimatedCost,
    required DateTime timestamp,
    String? model,
    Map<String, dynamic>? metadata,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}
```

**File:** `lib/core/ai/models/ai_error.dart`

```dart
sealed class AIException implements Exception {
  final String message;
  final int? statusCode;

  const AIException(this.message, [this.statusCode]);

  @override
  String toString() => 'AIException: $message (status: $statusCode)';
}

class RateLimitException extends AIException {
  final int retryAfterSeconds;

  const RateLimitException({
    required this.retryAfterSeconds,
    String message = 'Rate limit exceeded',
  }) : super(message, 429);
}

class AuthenticationException extends AIException {
  const AuthenticationException([String message = 'Invalid API key'])
      : super(message, 401);
}

class InvalidRequestException extends AIException {
  const InvalidRequestException([String message = 'Invalid request'])
      : super(message, 400);
}

class NetworkException extends AIException {
  const NetworkException([String message = 'Network error'])
      : super(message);
}

class TimeoutException extends AIException {
  const TimeoutException([String message = 'Request timeout'])
      : super(message, 408);
}
```

---

#### Step 3: Provider Interface

**File:** `lib/core/ai/providers/ai_provider_interface.dart`

```dart
import '../models/ai_request.dart';
import '../models/ai_response.dart';

abstract class AIProviderInterface {
  Future<AIResponse> complete(AIRequest request);
  Stream<String> streamCompletion(AIRequest request);
  Future<bool> validateApiKey();
}
```

**File:** `lib/core/ai/providers/openai_provider.dart`

```dart
import 'package:dio/dio.dart';
import '../ai_config.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import '../models/ai_error.dart';
import 'ai_provider_interface.dart';

class OpenAIProvider implements AIProviderInterface {
  final Dio _dio;

  OpenAIProvider() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    headers: {
      'Authorization': 'Bearer ${AIConfig.openAIKey}',
      'Content-Type': 'application/json',
    },
    connectTimeout: Duration(seconds: AIConfig.timeoutSeconds),
  ));

  @override
  Future<AIResponse> complete(AIRequest request) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': AIConfig.openAIModel,
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'max_tokens': request.maxTokens,
        'temperature': request.temperature,
        'stream': false,
      });

      final data = response.data;
      final content = data['choices'][0]['message']['content'] as String;
      final tokensUsed = data['usage']['total_tokens'] as int;

      return AIResponse(
        content: content,
        tokensUsed: tokensUsed,
        estimatedCost: _calculateCost(tokensUsed),
        timestamp: DateTime.now(),
        model: AIConfig.openAIModel,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Stream<String> streamCompletion(AIRequest request) async* {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': AIConfig.openAIModel,
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'max_tokens': request.maxTokens,
        'temperature': request.temperature,
        'stream': true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    await for (final chunk in response.data.stream) {
      final text = String.fromCharCodes(chunk);
      if (text.contains('data: ')) {
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            final json = line.substring(6);
            try {
              final data = jsonDecode(json);
              final delta = data['choices'][0]['delta']['content'];
              if (delta != null) {
                yield delta as String;
              }
            } catch (_) {}
          }
        }
      }
    }
  }

  @override
  Future<bool> validateApiKey() async {
    try {
      await _dio.get('/models');
      return true;
    } catch (_) {
      return false;
    }
  }

  double _calculateCost(int tokens) {
    // gpt-4o-mini pricing (as of 2024)
    const inputCostPer1M = 0.15;  // $0.15 per 1M input tokens
    const outputCostPer1M = 0.60; // $0.60 per 1M output tokens

    // Simplified: assume 50/50 split
    return (tokens / 1000000) * ((inputCostPer1M + outputCostPer1M) / 2);
  }

  AIException _handleDioError(DioException e) {
    if (e.response?.statusCode == 429) {
      final retryAfter = int.tryParse(
        e.response?.headers.value('retry-after') ?? '60'
      ) ?? 60;
      return RateLimitException(retryAfterSeconds: retryAfter);
    } else if (e.response?.statusCode == 401) {
      return const AuthenticationException();
    } else if (e.response?.statusCode == 400) {
      return InvalidRequestException(e.response?.data['error']['message']);
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return const TimeoutException();
    } else {
      return NetworkException(e.message ?? 'Unknown network error');
    }
  }
}
```

---

#### Step 4: Main AI Service

**File:** `lib/core/ai/ai_service.dart`

```dart
import 'models/ai_request.dart';
import 'models/ai_response.dart';
import 'models/ai_error.dart';
import 'providers/ai_provider_interface.dart';
import 'providers/openai_provider.dart';
import 'ai_config.dart';

class AIService {
  final AIProviderInterface _provider;

  AIService() : _provider = OpenAIProvider();

  /// Generate a completion (non-streaming)
  Future<AIResponse> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
  }) async {
    final request = AIRequest(
      systemPrompt: systemPrompt,
      userPrompt: _buildContextualPrompt(userPrompt, context),
      stream: false,
    );

    return await _provider.complete(request);
  }

  /// Generate a completion with streaming (word-by-word)
  Stream<String> streamCompletion({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
  }) {
    final request = AIRequest(
      systemPrompt: systemPrompt,
      userPrompt: _buildContextualPrompt(userPrompt, context),
      stream: true,
    );

    return _provider.streamCompletion(request);
  }

  /// Validate API configuration
  Future<bool> validateConfiguration() async {
    if (!AIConfig.isConfigured) return false;
    return await _provider.validateApiKey();
  }

  String _buildContextualPrompt(String prompt, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return prompt;

    final contextStr = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');

    return '$prompt\n\nContext:\n$contextStr';
  }
}
```

---

#### Step 5: Riverpod Provider

**File:** `lib/core/ai/ai_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'ai_service.dart';

part 'ai_provider.g.dart';

@riverpod
AIService aiService(AiServiceRef ref) {
  return AIService();
}
```

---

#### Step 6: Testing

**File:** `test/core/ai/ai_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gym_app/core/ai/ai_service.dart';
import 'package:gym_app/core/ai/models/ai_response.dart';

void main() {
  group('AIService', () {
    late AIService service;

    setUp(() {
      service = AIService();
    });

    test('generateCompletion returns valid response', () async {
      final response = await service.generateCompletion(
        systemPrompt: 'You are a helpful assistant.',
        userPrompt: 'Say hello',
      );

      expect(response.content, isNotEmpty);
      expect(response.tokensUsed, greaterThan(0));
    });

    test('streamCompletion yields chunks', () async {
      final stream = service.streamCompletion(
        systemPrompt: 'You are a helpful assistant.',
        userPrompt: 'Count to 5',
      );

      final chunks = await stream.toList();

      expect(chunks, isNotEmpty);
      expect(chunks.join(), contains('1'));
    });
  });
}
```

---

## Part 2: Chart Widgets (BATCH 4 Foundation)

### 2.1 Struktura Folderów

```
lib/core/charts/
├── base_chart.dart                  ✅ Abstract base class
├── widgets/
│   ├── line_chart_widget.dart       ✅ Reusable line chart
│   ├── bar_chart_widget.dart        ✅ Reusable bar chart
│   ├── progress_ring.dart           ✅ Circular progress
│   └── chart_legend.dart            ✅ Color legend
├── models/
│   ├── chart_data.dart              ✅ Generic data model
│   └── chart_config.dart            ✅ Styling config
├── processors/
│   ├── data_aggregator.dart         ✅ Group by period
│   └── data_interpolator.dart       ✅ Fill missing data
└── theme/
    └── chart_theme.dart             ✅ Unified colors
```

---

### 2.2 Implementation Steps

#### Step 1: Data Models

**File:** `lib/core/charts/models/chart_data.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data.freezed.dart';

@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    required double x,      // Usually timestamp or index
    required double y,      // Value
    String? label,          // Optional label (e.g., "Jan 15")
    dynamic metadata,       // Extra data for tooltips
  }) = _ChartDataPoint;
}

enum AggregationPeriod { daily, weekly, monthly }
enum AggregationType { sum, average, max, min }
```

---

#### Step 2: Data Aggregator (DRY!)

**File:** `lib/core/charts/processors/data_aggregator.dart`

```dart
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart';

class DataAggregator {
  /// Generic aggregation - reusable for ANY time-series data!
  static List<ChartDataPoint> aggregateByPeriod<T>({
    required List<T> items,
    required DateTime Function(T) getDate,
    required double Function(T) getValue,
    required AggregationPeriod period,
    required AggregationType type,
  }) {
    if (items.isEmpty) return [];

    // Group by period
    final grouped = groupBy<T, DateTime>(items, (item) {
      final date = getDate(item);
      switch (period) {
        case AggregationPeriod.daily:
          return DateTime(date.year, date.month, date.day);
        case AggregationPeriod.weekly:
          return _getWeekStart(date);
        case AggregationPeriod.monthly:
          return DateTime(date.year, date.month);
      }
    });

    // Aggregate values
    return grouped.entries.map((entry) {
      final values = entry.value.map(getValue).toList();
      final aggregated = _aggregate(values, type);

      return ChartDataPoint(
        x: entry.key.millisecondsSinceEpoch.toDouble(),
        y: aggregated,
        label: _formatLabel(entry.key, period),
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  static double _aggregate(List<double> values, AggregationType type) {
    if (values.isEmpty) return 0;

    switch (type) {
      case AggregationType.sum:
        return values.reduce((a, b) => a + b);
      case AggregationType.average:
        return values.average;
      case AggregationType.max:
        return values.reduce((a, b) => a > b ? a : b);
      case AggregationType.min:
        return values.reduce((a, b) => a < b ? a : b);
    }
  }

  static DateTime _getWeekStart(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  static String _formatLabel(DateTime date, AggregationPeriod period) {
    switch (period) {
      case AggregationPeriod.daily:
        return DateFormat('MMM dd').format(date);
      case AggregationPeriod.weekly:
        return DateFormat('MMM dd').format(date);
      case AggregationPeriod.monthly:
        return DateFormat('MMM yyyy').format(date);
    }
  }
}
```

---

#### Step 3: Reusable Line Chart

**File:** `lib/core/charts/widgets/line_chart_widget.dart`

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/chart_data.dart';

class ReusableLineChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String title;
  final String yAxisLabel;
  final Color lineColor;
  final bool showGrid;
  final bool showDots;
  final double? minY;
  final double? maxY;

  const ReusableLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.yAxisLabel,
    this.lineColor = Colors.blue,
    this.showGrid = true,
    this.showDots = true,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: showGrid,
                drawVerticalLine: false,
              ),
              titlesData: _buildTitles(),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((d) => FlSpot(d.x, d.y)).toList(),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 3,
                  dotData: FlDotData(show: showDots),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((spot) {
                    final dataPoint = data[spot.spotIndex];
                    return LineTooltipItem(
                      '${dataPoint.label ?? ''}\n${spot.y.toStringAsFixed(1)}',
                      const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: Text(yAxisLabel, style: const TextStyle(fontSize: 12)),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = data.indexWhere((d) => d.x == value);
            if (index == -1) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                data[index].label ?? '',
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No data available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
```

---

#### Step 4: Reusable Bar Chart

**File:** `lib/core/charts/widgets/bar_chart_widget.dart`

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/chart_data.dart';

class ReusableBarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String title;
  final String yAxisLabel;
  final Color barColor;

  const ReusableBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.yAxisLabel,
    this.barColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.y,
                      color: barColor,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: _buildTitles(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: Text(yAxisLabel),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                data[index].label ?? '',
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Text('No data available'),
    );
  }
}
```

---

## Checklist

### AI Service Layer
- [ ] Install dependencies (`http`, `dio`, `flutter_dotenv`, etc.)
- [ ] Create `.env` file with API keys
- [ ] Create `AIConfig` class
- [ ] Implement data models (`AIRequest`, `AIResponse`, `AIError`)
- [ ] Implement `AIProviderInterface` + `OpenAIProvider`
- [ ] Implement main `AIService` class
- [ ] Create Riverpod provider (`aiServiceProvider`)
- [ ] Write unit tests (API calls, error handling)
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Chart Widgets
- [ ] Install `fl_chart` dependency
- [ ] Create `ChartDataPoint` model
- [ ] Implement `DataAggregator` (generic aggregation logic)
- [ ] Create `ReusableLineChart` widget
- [ ] Create `ReusableBarChart` widget
- [ ] Write widget tests (rendering, empty states)
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Testing

```bash
# Run all tests
flutter test

# Run specific tests
flutter test test/core/ai/
flutter test test/core/charts/

# Generate code (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Next Steps

Po ukończeniu tego planu:
1. ✅ Przejdź do `batch-2-ai-features.md` (Stories 2.2, 2.4, 2.9)
2. ✅ Przejdź do `batch-4-charts-smart-features.md` (Stories 2.7, 3.5, 3.1, 2.8)

**Token Savings:** Komponenty stworzone tutaj są używane 10+ razy w różnych stories, oszczędzając ~30K tokenów! 🎉
