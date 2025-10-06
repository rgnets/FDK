import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/reset_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ResetSettings usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = ResetSettings(mockRepository);
  });

  group('ResetSettings', () {
    test('should reset settings to defaults successfully', () async {
      // arrange
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return SettingsFailure when reset fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to reset settings',
        statusCode: 500,
      );
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache clearing fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to clear settings cache',
      );
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return SettingsFailure when storage access fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to access settings storage',
        statusCode: 503,
      );
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle successful reset with void return type', () async {
      // arrange
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.resetSettings()).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Right(null));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle permission failure when unable to write defaults', () async {
      // arrange
      const tFailure = PermissionFailure(
        message: 'Permission denied to reset settings',
        statusCode: 403,
      );
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle validation failure when default settings are invalid', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Default settings validation failed',
        statusCode: 400,
      );
      when(() => mockRepository.resetSettings())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.resetSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}