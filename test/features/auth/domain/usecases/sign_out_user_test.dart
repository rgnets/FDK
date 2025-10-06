import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/sign_out_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignOutUser(mockRepository);
  });

  group('SignOutUser', () {
    test('should sign out user successfully', () async {
      // arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when sign out fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Failed to sign out user',
        statusCode: 401,
      );
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache clearing fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to clear authentication cache',
      );
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed during sign out',
        statusCode: 408,
      );
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Server error during sign out',
        statusCode: 500,
      );
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase();

      // assert
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle successful sign out with void return type', () async {
      // arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}