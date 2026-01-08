import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/authenticate_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthenticateUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = AuthenticateUser(mockRepository);
  });

  group('AuthenticateUser', () {
    const tFqdn = 'test.rgnets.com';
    const tLogin = 'testuser';
    const tApiKey = 'test-api-key-123';
    const tParams = AuthenticateUserParams(
      fqdn: tFqdn,
      login: tLogin,
      apiKey: tApiKey,
    );
    
    const tUser = User(
      username: tLogin,
      apiUrl: 'https://$tFqdn/api',
      displayName: 'Test User',
      email: 'test@example.com',
    );

    test('should authenticate user successfully when repository returns user', () async {
      // arrange
      when(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).thenAnswer((_) async => const Right<Failure, User>(tUser));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, User>(tUser));
      verify(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).thenAnswer((_) async => const Left<Failure, User>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, User>(tFailure));
      verify(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Connection timeout',
        statusCode: 408,
      );
      when(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).thenAnswer((_) async => const Left<Failure, User>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, User>(tFailure));
      verify(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).thenAnswer((_) async => const Left<Failure, User>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, User>(tFailure));
      verify(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct parameters to repository', () async {
      // arrange
      when(() => mockRepository.authenticate(
        fqdn: any(named: 'fqdn'),
        login: any(named: 'login'),
        apiKey: any(named: 'apiKey'),
      )).thenAnswer((_) async => const Right<Failure, User>(tUser));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.authenticate(
        fqdn: tFqdn,
        login: tLogin,
        apiKey: tApiKey,
      )).called(1);
    });

    group('AuthenticateUserParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = AuthenticateUserParams(
          fqdn: tFqdn,
          login: tLogin,
          apiKey: tApiKey,
        );
        const params2 = AuthenticateUserParams(
          fqdn: tFqdn,
          login: tLogin,
          apiKey: tApiKey,
        );
        const params3 = AuthenticateUserParams(
          fqdn: 'different.com',
          login: tLogin,
          apiKey: tApiKey,
        );

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tFqdn, tLogin, tApiKey, null, null, null]);
      });
    });
  });
}
