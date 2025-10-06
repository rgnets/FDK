import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/check_auth_status.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CheckAuthStatus usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = CheckAuthStatus(mockRepository);
  });

  group('CheckAuthStatus', () {
    test('should return true when user is authenticated', () async {
      // arrange
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Right<Failure, bool>(true));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, bool>(true));
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when user is not authenticated', () async {
      // arrange
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Right<Failure, bool>(false));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, bool>(false));
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when repository fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Authentication check failed',
        statusCode: 401,
      );
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Left<Failure, bool>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read authentication status from cache',
      );
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Left<Failure, bool>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Left<Failure, bool>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.isAuthenticated())
          .thenAnswer((_) async => const Right<Failure, bool>(true));

      // act
      await usecase();

      // assert
      verify(() => mockRepository.isAuthenticated()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}