import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymapp/core/ai/ai_service.dart';
import 'package:gymapp/core/error/failures.dart';
import 'package:gymapp/core/utils/rate_limiter.dart';
import 'package:gymapp/features/life_coach/ai/daily_plan_generator.dart';
import 'package:gymapp/features/life_coach/domain/repositories/goals_repository.dart';
import 'package:gymapp/features/life_coach/domain/repositories/check_in_repository.dart';
import 'package:gymapp/features/life_coach/data/repositories/daily_plan_repository.dart';
import 'package:gymapp/features/life_coach/domain/repositories/preferences_repository.dart';

import 'daily_plan_generator_test.mocks.dart';

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
  late MockAIService mockAIService;
  late MockGoalsRepository mockGoalsRepo;
  late MockCheckInRepository mockCheckInRepo;
  late MockDailyPlanRepository mockPlanRepo;
  late MockPreferencesRepository mockPrefsRepo;
  late MockRateLimiter mockRateLimiter;

  setUp(() {
    mockAIService = MockAIService();
    mockGoalsRepo = MockGoalsRepository();
    mockCheckInRepo = MockCheckInRepository();
    mockPlanRepo = MockDailyPlanRepository();
    mockPrefsRepo = MockPreferencesRepository();
    mockRateLimiter = MockRateLimiter();

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
        )).thenAnswer((_) async => MockAIResponse(validAIResponse));
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
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (error) {
            expect(error, isA<RateLimitFailure>());
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
        )).thenAnswer((_) async => MockAIResponse('invalid json'));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (error) {
            expect(error, isA<AIParsingFailure>());
            expect(error.message, contains('Invalid JSON format'));
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
        )).thenAnswer((_) async => MockAIResponse(invalidResponse));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (error) {
            expect(error, isA<AIParsingFailure>());
            expect(error.message, contains('Expected "tasks" to be a list'));
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
        )).thenAnswer((_) async => MockAIResponse(validAIResponse));
        when(mockPlanRepo.savePlan(any)).thenThrow(Exception('Database error'));

        // Act
        final result = await generator.generatePlan(userId: testUserId);

        // Assert
        expect(result.isFailure, true);
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (error) {
            expect(error, isA<DatabaseFailure>());
            expect(error.message, contains('Failed to save plan'));
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
        )).thenAnswer((_) async => MockAIResponse(validAIResponse));
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

class MockAIResponse {
  final String content;
  final int tokensUsed;
  final double estimatedCost;
  final String model;

  MockAIResponse(
    this.content, {
    this.tokensUsed = 100,
    this.estimatedCost = 0.01,
    this.model = 'gpt-4o-mini',
  });
}
