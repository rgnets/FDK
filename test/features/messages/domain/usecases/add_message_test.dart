import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';
import 'package:rgnets_fdk/features/messages/domain/usecases/add_message.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late AddMessage usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = AddMessage(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(AppMessage(
      id: 'fallback',
      content: 'fallback',
      type: MessageType.info,
      category: MessageCategory.general,
      priority: MessagePriority.normal,
      timestamp: DateTime.now(),
    ));
  });

  group('AddMessage', () {
    final tMessage = AppMessage(
      id: 'msg-1',
      content: 'Test message',
      type: MessageType.info,
      category: MessageCategory.general,
      priority: MessagePriority.normal,
      timestamp: DateTime(2024, 1, 1, 10, 0, 0),
    );

    test('should add message successfully', () async {
      // arrange
      final tParams = AddMessageParams(message: tMessage);
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => Right<Failure, AppMessage>(tMessage));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, AppMessage>(tMessage));
      verify(() => mockRepository.addMessage(tMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should add message with action successfully', () async {
      // arrange
      final tMessageWithAction = tMessage.copyWith(
        action: const MessageAction(
          label: 'Retry',
          actionKey: 'retry_upload',
          data: {'deviceId': 'device-123'},
        ),
      );
      final tParams = AddMessageParams(message: tMessageWithAction);
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => Right<Failure, AppMessage>(tMessageWithAction));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, AppMessage>(tMessageWithAction));
      verify(() => mockRepository.addMessage(tMessageWithAction)).called(1);
    });

    test('should add critical message that should persist', () async {
      // arrange
      final tCriticalMessage = tMessage.copyWith(
        type: MessageType.critical,
        priority: MessagePriority.critical,
      );
      final tParams = AddMessageParams(message: tCriticalMessage);
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => Right<Failure, AppMessage>(tCriticalMessage));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (message) {
          expect(message.shouldPersist, isTrue);
        },
      );
    });

    test('should return CacheFailure when repository fails', () async {
      // arrange
      final tParams = AddMessageParams(message: tMessage);
      const tFailure = CacheFailure(
        message: 'Failed to add message',
      );
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => const Left<Failure, AppMessage>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, AppMessage>(tFailure));
      verify(() => mockRepository.addMessage(tMessage)).called(1);
    });

    test('should add error message with high priority', () async {
      // arrange
      final tErrorMessage = AppMessage(
        id: 'msg-error',
        content: 'Network error occurred',
        type: MessageType.error,
        category: MessageCategory.network,
        priority: MessagePriority.high,
        timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        sourceContext: 'websocket_service',
      );
      final tParams = AddMessageParams(message: tErrorMessage);
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => Right<Failure, AppMessage>(tErrorMessage));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (message) {
          expect(message.shouldPersist, isTrue);
          expect(message.priority, MessagePriority.high);
        },
      );
    });

    test('should add message with deduplication key', () async {
      // arrange
      final tMessageWithDedup = tMessage.copyWith(
        deduplicationKey: 'network_error_ws',
      );
      final tParams = AddMessageParams(message: tMessageWithDedup);
      when(() => mockRepository.addMessage(any()))
          .thenAnswer((_) async => Right<Failure, AppMessage>(tMessageWithDedup));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (message) {
          expect(message.deduplicationKey, 'network_error_ws');
        },
      );
    });
  });
}
