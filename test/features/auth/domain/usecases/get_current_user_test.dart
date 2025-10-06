import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/get_current_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUser(mockRepository);
  });

  group('GetCurrentUser', () {
    const tUser = User(
      username: 'testuser',
      apiUrl: 'https://test.rgnets.com/api',
      displayName: 'Test User',
      email: 'test@example.com',
    );

    test('should return user when user exists', () async {
      // arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User?>(tUser));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, User?>(tUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no user is logged in', () async {
      // arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User?>(null));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, User?>(null));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication error occurs', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'User not authenticated',
        statusCode: 401,
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left<Failure, User?>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, User?>(tFailure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read user data from cache',
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left<Failure, User?>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, User?>(tFailure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Failed to fetch user data',
        statusCode: 500,
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left<Failure, User?>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, User?>(tFailure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left<Failure, User?>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, User?>(tFailure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right<Failure, User?>(tUser));

      // act
      await usecase();

      // assert
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}