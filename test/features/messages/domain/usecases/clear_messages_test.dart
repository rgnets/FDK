import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/messages/domain/repositories/message_repository.dart';
import 'package:rgnets_fdk/features/messages/domain/usecases/clear_messages.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late ClearMessages usecase;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    usecase = ClearMessages(mockRepository);
  });

  group('ClearMessages', () {
    test('should clear messages successfully', () async {
      // arrange
      when(() => mockRepository.clearMessages())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearMessages()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when clearing fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to clear messages',
      );
      when(() => mockRepository.clearMessages())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearMessages()).called(1);
    });
  });
}
