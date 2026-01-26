import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';
import 'package:rgnets_fdk/features/messages/domain/usecases/get_messages.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late GetMessages usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = GetMessages(mockRepository);
  });

  group('GetMessages', () {
    final tMessagesList = [
      AppMessage(
        id: 'msg-1',
        content: 'Test message 1',
        type: MessageType.info,
        category: MessageCategory.general,
        priority: MessagePriority.normal,
        timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        isRead: false,
      ),
      AppMessage(
        id: 'msg-2',
        content: 'Test message 2',
        type: MessageType.error,
        category: MessageCategory.network,
        priority: MessagePriority.high,
        timestamp: DateTime(2024, 1, 1, 11, 0, 0),
        isRead: true,
      ),
    ];

    test('should get messages without filter successfully', () async {
      // arrange
      const tParams = GetMessagesParams();
      when(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppMessage>>(tMessagesList));
      verify(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get messages with type filter successfully', () async {
      // arrange
      const tParams = GetMessagesParams(type: MessageType.error);
      final tFilteredList = [tMessagesList[1]];

      when(() => mockRepository.getMessages(
            type: MessageType.error,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tFilteredList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppMessage>>(tFilteredList));
      verify(() => mockRepository.getMessages(
            type: MessageType.error,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).called(1);
    });

    test('should get messages with category filter successfully', () async {
      // arrange
      const tParams = GetMessagesParams(category: MessageCategory.network);
      final tFilteredList = [tMessagesList[1]];

      when(() => mockRepository.getMessages(
            type: null,
            category: MessageCategory.network,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tFilteredList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppMessage>>(tFilteredList));
    });

    test('should get unread messages only', () async {
      // arrange
      const tParams = GetMessagesParams(unreadOnly: true);
      final tFilteredList = [tMessagesList[0]];

      when(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: true,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tFilteredList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppMessage>>(tFilteredList));
    });

    test('should handle pagination parameters', () async {
      // arrange
      const tParams = GetMessagesParams(limit: 10, offset: 5);
      when(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: 10,
            offset: 5,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tMessagesList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppMessage>>(tMessagesList));
      verify(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: 10,
            offset: 5,
          )).called(1);
    });

    test('should return empty list when no messages found', () async {
      // arrange
      const tParams = GetMessagesParams();
      const tEmptyList = <AppMessage>[];
      when(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => const Right<Failure, List<AppMessage>>(tEmptyList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, List<AppMessage>>(tEmptyList));
    });

    test('should return CacheFailure when repository fails', () async {
      // arrange
      const tParams = GetMessagesParams();
      const tFailure = CacheFailure(
        message: 'Failed to fetch messages',
      );
      when(() => mockRepository.getMessages(
            type: null,
            category: null,
            unreadOnly: null,
            limit: null,
            offset: null,
          )).thenAnswer(
          (_) async => const Left<Failure, List<AppMessage>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<AppMessage>>(tFailure));
    });

    test('should handle combined filters', () async {
      // arrange
      const tParams = GetMessagesParams(
        type: MessageType.error,
        category: MessageCategory.network,
        unreadOnly: true,
        limit: 20,
        offset: 0,
      );

      when(() => mockRepository.getMessages(
            type: MessageType.error,
            category: MessageCategory.network,
            unreadOnly: true,
            limit: 20,
            offset: 0,
          )).thenAnswer(
          (_) async => Right<Failure, List<AppMessage>>(tMessagesList));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.getMessages(
            type: MessageType.error,
            category: MessageCategory.network,
            unreadOnly: true,
            limit: 20,
            offset: 0,
          )).called(1);
    });
  });
}
