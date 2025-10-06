import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/mark_as_read.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MarkAsRead usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = MarkAsRead(mockRepository);
  });

  group('MarkAsRead', () {
    const tNotificationId = 'notif-123';
    const tParams = MarkAsReadParams(notificationId: tNotificationId);

    test('should mark notification as read successfully', () async {
      // arrange
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotificationFailure when notification not found', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Notification not found',
        statusCode: 404,
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotificationFailure when marking fails', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Failed to mark notification as read',
        statusCode: 500,
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache update fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to update notification cache',
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when notification ID is invalid', () async {
      // arrange
      const tInvalidId = '';
      const tInvalidParams = MarkAsReadParams(notificationId: tInvalidId);
      const tFailure = ValidationFailure(
        message: 'Invalid notification ID',
        statusCode: 400,
      );
      when(() => mockRepository.markAsRead(tInvalidId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tInvalidParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tInvalidId)).called(1);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle successful mark as read with void return type', () async {
      // arrange
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
    });

    test('should pass correct notification ID to repository', () async {
      // arrange
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
    });

    test('should handle different notification ID formats', () async {
      // arrange
      const tUuidId = '550e8400-e29b-41d4-a716-446655440000';
      const tUuidParams = MarkAsReadParams(notificationId: tUuidId);
      when(() => mockRepository.markAsRead(tUuidId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tUuidParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.markAsRead(tUuidId)).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle already read notification gracefully', () async {
      // arrange
      const tFailure = NotificationFailure(
        message: 'Notification is already marked as read',
        statusCode: 400,
      );
      when(() => mockRepository.markAsRead(tNotificationId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.markAsRead(tNotificationId)).called(1);
    });
  });
}