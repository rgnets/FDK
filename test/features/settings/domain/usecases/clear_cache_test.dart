import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/clear_cache.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ClearCache usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = ClearCache(mockRepository);
  });

  group('ClearCache', () {
    test('should clear cache successfully', () async {
      // arrange
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache clearing fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to clear application cache',
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return SettingsFailure when cache service is unavailable', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Cache service is unavailable',
        statusCode: 503,
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return PermissionFailure when insufficient permissions', () async {
      // arrange
      const tFailure = PermissionFailure(
        message: 'Insufficient permissions to clear cache',
        statusCode: 403,
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle successful cache clear with void return type', () async {
      // arrange
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.clearCache()).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle storage access failure', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Unable to access cache storage',
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle partial cache clear failure', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Some cache entries could not be cleared',
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle disk space issues during cache clear', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Insufficient disk space for cache operations',
      );
      when(() => mockRepository.clearCache())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearCache()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
