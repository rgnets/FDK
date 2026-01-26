import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';
import 'package:rgnets_fdk/features/messages/domain/usecases/get_message_metrics.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late GetMessageMetrics usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = GetMessageMetrics(mockRepository);
  });

  group('GetMessageMetrics', () {
    final tMetrics = MessageMetrics(
      totalShown: 100,
      totalDeduplicated: 20,
      totalDropped: 5,
      totalErrors: 10,
      queueSize: 3,
      maxQueueSize: 20,
      byType: {'info': 50, 'error': 30, 'warning': 20},
      byCategory: {'network': 40, 'general': 60},
      bySource: {'websocket': 30, 'auth': 20, 'other': 50},
      sessionStart: DateTime(2024, 1, 1, 10, 0, 0),
      lastMessageTime: DateTime(2024, 1, 1, 12, 0, 0),
      healthScore: 85,
      issues: ['High error rate'],
      recommendations: ['Check network connectivity'],
    );

    test('should get metrics successfully', () async {
      // arrange
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => Right<Failure, MessageMetrics>(tMetrics));

      // act
      final result = await usecase();

      // assert
      expect(result, Right<Failure, MessageMetrics>(tMetrics));
      verify(() => mockRepository.getMetrics()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return metrics with correct calculations', () async {
      // arrange
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => Right<Failure, MessageMetrics>(tMetrics));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) {
          expect(metrics.queueUtilization, 15.0); // 3/20 * 100
          expect(metrics.deduplicationRate, closeTo(16.67, 0.01)); // 20/(100+20) * 100
          expect(metrics.errorRate, 10.0); // 10/100 * 100
        },
      );
    });

    test('should return CacheFailure when repository fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to get metrics',
      );
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => const Left<Failure, MessageMetrics>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, MessageMetrics>(tFailure));
      verify(() => mockRepository.getMetrics()).called(1);
    });

    test('should return empty metrics when no messages exist', () async {
      // arrange
      const tEmptyMetrics = MessageMetrics();
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => const Right<Failure, MessageMetrics>(tEmptyMetrics));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) {
          expect(metrics.totalShown, 0);
          expect(metrics.queueUtilization, 0);
          expect(metrics.healthScore, 100);
        },
      );
    });

    test('should handle metrics with issues', () async {
      // arrange
      final tMetricsWithIssues = tMetrics.copyWith(
        healthScore: 50,
        issues: ['High error rate', 'Message storms detected', 'Queue overflow'],
        recommendations: [
          'Check network connectivity',
          'Reduce message frequency',
          'Increase queue size',
        ],
      );
      when(() => mockRepository.getMetrics())
          .thenAnswer((_) async => Right<Failure, MessageMetrics>(tMetricsWithIssues));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) {
          expect(metrics.issues.length, 3);
          expect(metrics.recommendations.length, 3);
          expect(metrics.healthScore, 50);
        },
      );
    });
  });
}
