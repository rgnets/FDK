import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/mark_all_as_read.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MarkAllAsRead usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = MarkAllAsRead(mockRepository);
  });

  group('MarkAllAsRead', () {
    test('should mark all notifications as read successfully', () async {
      // arrange
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotificationFailure when marking all fails', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Failed to mark all notifications as read',
        statusCode: 500,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache bulk update fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to update notifications cache',
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error during bulk update',
        statusCode: 500,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized to mark notifications as read',
        statusCode: 401,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle successful mark all as read with void return type', () async {
      // arrange
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.markAllAsRead()).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle case when no notifications exist', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'No notifications to mark as read',
        statusCode: 204,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });

    test('should handle case when all notifications are already read', () async {
      // arrange
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });

    test('should return timeout failure when operation takes too long', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Operation timeout during bulk update',
        statusCode: 408,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });

    test('should handle partial failure gracefully', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Some notifications could not be marked as read',
        statusCode: 207, // Multi-status
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });

    test('should handle database constraint failures', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Database constraint violation during bulk update',
        statusCode: 409,
      );
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });
  });
}