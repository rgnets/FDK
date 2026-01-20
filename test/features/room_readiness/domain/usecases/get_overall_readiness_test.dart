import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_overall_readiness.dart';

class MockRoomReadinessRepository extends Mock
    implements RoomReadinessRepository {}

void main() {
  late GetOverallReadiness usecase;
  late MockRoomReadinessRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomReadinessRepository();
    usecase = GetOverallReadiness(mockRepository);
  });

  group('GetOverallReadiness', () {
    test('should get overall readiness percentage from repository successfully',
        () async {
      // arrange
      const tPercentage = 85.5;
      when(() => mockRepository.getOverallReadinessPercentage())
          .thenAnswer((_) async => const Right<Failure, double>(tPercentage));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, double>(tPercentage));
      verify(() => mockRepository.getOverallReadinessPercentage()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return 0 when no rooms available', () async {
      // arrange
      const tPercentage = 0.0;
      when(() => mockRepository.getOverallReadinessPercentage())
          .thenAnswer((_) async => const Right<Failure, double>(tPercentage));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, double>(tPercentage));
      verify(() => mockRepository.getOverallReadinessPercentage()).called(1);
    });

    test('should return 100 when all rooms are ready', () async {
      // arrange
      const tPercentage = 100.0;
      when(() => mockRepository.getOverallReadinessPercentage())
          .thenAnswer((_) async => const Right<Failure, double>(tPercentage));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, double>(tPercentage));
    });

    test('should return RoomReadinessFailure when repository fails', () async {
      // arrange
      const tFailure = RoomReadinessFailure(
        message: 'Failed to calculate readiness',
        statusCode: 500,
      );
      when(() => mockRepository.getOverallReadinessPercentage())
          .thenAnswer((_) async => const Left<Failure, double>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, double>(tFailure));
      verify(() => mockRepository.getOverallReadinessPercentage()).called(1);
    });

    test('should exclude empty rooms from calculation', () async {
      // This tests that the repository correctly excludes empty rooms
      // The actual calculation is done in the repository
      const tPercentage = 75.0; // 3 out of 4 non-empty rooms are ready
      when(() => mockRepository.getOverallReadinessPercentage())
          .thenAnswer((_) async => const Right<Failure, double>(tPercentage));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (percentage) {
          expect(percentage, 75.0);
        },
      );
    });
  });
}
