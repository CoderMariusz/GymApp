import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lifeos/core/ai/ai_service.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/core/utils/rate_limiter.dart';
import 'package:lifeos/features/life_coach/ai/daily_plan_generator.dart';
import 'package:lifeos/features/life_coach/domain/repositories/goals_repository.dart';
import 'package:lifeos/features/life_coach/domain/repositories/check_in_repository.dart';
import 'package:lifeos/features/life_coach/data/repositories/daily_plan_repository.dart';
import 'package:lifeos/features/life_coach/domain/repositories/preferences_repository.dart';

import 'daily_plan_generator_test.mocks.dart' as mocks;

@GenerateMocks([
  AIService,
  GoalsRepository,
  CheckInRepository,
  DailyPlanRepository,
  PreferencesRepository,
  RateLimiter,
])
void main() {
  late DailyPlanGenerator generator;
  late mocks.MockAIService mockAIService;
  late mocks.MockGoalsRepository mockGoalsRepo;
  late mocks.MockCheckInRepository mockCheckInRepo;
  late mocks.MockDailyPlanRepository mockPlanRepo;
  late mocks.MockPreferencesRepository mockPrefsRepo;
  late mocks.MockRateLimiter mockRateLimiter;

  setUp(() {
    mockAIService = mocks.MockAIService();
    mockGoalsRepo = mocks.MockGoalsRepository();
    mockCheckInRepo = mocks.MockCheckInRepository();
    mockPlanRepo = mocks.MockDailyPlanRepository();
    mockPrefsRepo = mocks.MockPreferencesRepository();
    mockRateLimiter = mocks.MockRateLimiter();

    generator = DailyPlanGenerator(
      aiService: mockAIService,
      goalsRepo: mockGoalsRepo,
      checkInRepo: mockCheckInRepo,
      planRepo: mockPlanRepo,
      prefsRepo: mockPrefsRepo,
      rateLimiter: mockRateLimiter,
    );
  });

  group('DailyPlanGenerator', () {
    final testUserId = 'test-user-id';
    final validAIResponse = '''
    {
      "tasks": [
        {
          "id": "task-1",
          "title": "Morning workout",
          "description": "30 min cardio",
          "category": "fitness",
          "priority": "high",
          "estimated_duration": 30,
          "suggested_time": "07:00",
          "energy_level": "high",
          "why": "Build cardiovascular endurance"
        }
      ],
      "daily_theme": "Active Start",
      "motivational_quote": "Every journey begins with a single step"
    }
    ''';

    group('generatePlan', () {
      test('should return Result.success with valid AI response', () async {
        // Arrange
        when(mockRateLimiter.checkLimit(any)).thenReturn(null);
        when(mockCheckInRepo.getCheckInForDate(any)).thenAnswer((_) async => null);
        when(mockGoalsRepo.getActiveGoals(any)).thenAnswer((_) async => []);
        when(mockPrefsRepo.getUserPreferences()).thenAnswer((_) async => null);
        when(mockAIService.generateCompletion(
          systemPrompt: anyNamed('systemPrompt'),
          userPrompt: anyNamed('userPrompt'),
        )).thenAnswer((_) async => createMockAIResponse(validAIResponse));
        when(mockPlanRepo.savePlan(any)).thenAnswer((_) async => {});

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isSuccess, true);
        final plan = result.dataOrNull;
        expect(plan, isNotNull);
        expect(plan!.tasks.length, equals(1));
        expect(plan.tasks[0].title, equals('Morning workout'));
      });

      test('should return RateLimitFailure when rate limit exceeded', () async {
        // Arrange
        when(mockRateLimiter.checkLimit(any))
            .thenThrow(RateLimitFailure('Rate limit exceeded'));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.map(
          success: (_) => fail('Should not succeed'),
          failure: (failure) {
            expect(failure.exception, isA<RateLimitFailure>());
          },
        );
      });

      test('should return AIParsingFailure when AI returns invalid JSON', () async {
        // Arrange
        when(mockRateLimiter.checkLimit(any)).thenReturn(null);
        when(mockCheckInRepo.getCheckInForDate(any)).thenAnswer((_) async => null);
        when(mockGoalsRepo.getActiveGoals(any)).thenAnswer((_) async => []);
        when(mockPrefsRepo.getUserPreferences()).thenAnswer((_) async => null);
        when(mockAIService.generateCompletion(
          systemPrompt: anyNamed('systemPrompt'),
          userPrompt: anyNamed('userPrompt'),
        )).thenAnswer((_) async => createMockAIResponse('invalid json'));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.map(
          success: (_) => fail('Should not succeed'),
          failure: (failure) {
            expect(failure.exception, isA<AIParsingFailure>());
            expect((failure.exception as AIParsingFailure).message, contains('Invalid JSON format'));
          },
        );
      });

      test('should return AIParsingFailure when tasks field is not a list', () async {
        // Arrange
        final invalidResponse = '{"tasks": "not a list", "daily_theme": "Test"}';

        when(mockRateLimiter.checkLimit(any)).thenReturn(null);
        when(mockCheckInRepo.getCheckInForDate(any)).thenAnswer((_) async => null);
        when(mockGoalsRepo.getActiveGoals(any)).thenAnswer((_) async => []);
        when(mockPrefsRepo.getUserPreferences()).thenAnswer((_) async => null);
        when(mockAIService.generateCompletion(
          systemPrompt: anyNamed('systemPrompt'),
          userPrompt: anyNamed('userPrompt'),
        )).thenAnswer((_) async => createMockAIResponse(invalidResponse));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.map(
          success: (_) => fail('Should not succeed'),
          failure: (failure) {
            expect(failure.exception, isA<AIParsingFailure>());
            expect((failure.exception as AIParsingFailure).message, contains('Expected "tasks" to be a list'));
          },
        );
      });

      test('should return DatabaseFailure when plan save fails', () async {
        // Arrange
        when(mockRateLimiter.checkLimit(any)).thenReturn(null);
        when(mockCheckInRepo.getCheckInForDate(any)).thenAnswer((_) async => null);
        when(mockGoalsRepo.getActiveGoals(any)).thenAnswer((_) async => []);
        when(mockPrefsRepo.getUserPreferences()).thenAnswer((_) async => null);
        when(mockAIService.generateCompletion(
          systemPrompt: anyNamed('systemPrompt'),
          userPrompt: anyNamed('userPrompt'),
        )).thenAnswer((_) async => createMockAIResponse(validAIResponse));
        when(mockPlanRepo.savePlan(any)).thenThrow(Exception('Database error'));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.map(
          success: (_) => fail('Should not succeed'),
          failure: (failure) {
            expect(failure.exception, isA<DatabaseFailure>());
            expect((failure.exception as DatabaseFailure).message, contains('Failed to save plan'));
          },
        );
      });

      test('should use provided targetDate instead of current date', () async {
        // Arrange
        final targetDate = DateTime(2025, 6, 15);

        when(mockRateLimiter.checkLimit(any)).thenReturn(null);
        when(mockCheckInRepo.getCheckInForDate(targetDate)).thenAnswer((_) async => null);
        when(mockGoalsRepo.getActiveGoals(any)).thenAnswer((_) async => []);
        when(mockPrefsRepo.getUserPreferences()).thenAnswer((_) async => null);
        when(mockAIService.generateCompletion(
          systemPrompt: anyNamed('systemPrompt'),
          userPrompt: anyNamed('userPrompt'),
        )).thenAnswer((_) async => createMockAIResponse(validAIResponse));
        when(mockPlanRepo.savePlan(any)).thenAnswer((_) async => {});

        // Act
        final result = await generator.generatePlan(
          userId: testUserId,
          targetDate: targetDate,
        );

        // Assert
        expect(result.isSuccess, true);
        verify(mockCheckInRepo.getCheckInForDate(targetDate)).called(1);
      });
    });

    group('context building', () {
      test('should include user goals in AI prompt', () async {
        // Test that active goals are fetched and included
      });

      test('should include check-in data in AI prompt', () async {
        // Test that mood/energy data is included
      });

      test('should include user preferences in AI prompt', () async {
        // Test that preferences affect plan generation
      });
    });

    group('error scenarios', () {
      test('should handle network failures gracefully', () async {
        // Test NetworkFailure handling
      });

      test('should handle AI service failures gracefully', () async {
        // Test AIServiceFailure handling
      });

      test('should provide meaningful error messages', () async {
        // Test that error messages are user-friendly
      });
    });
  });
}

// Helper function to create AIResponse for testing
AIResponse createMockAIResponse(
  String content, {
  int tokensUsed = 100,
  double estimatedCost = 0.01,
  String model = 'gpt-4o-mini',
}) {
  return AIResponse(
    content: content,
    tokensUsed: tokensUsed,
    estimatedCost: estimatedCost,
    timestamp: DateTime.now(),
    model: model,
  );
}
