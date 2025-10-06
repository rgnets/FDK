import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/clear_notifications.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late ClearNotifications usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = ClearNotifications(mockRepository);
  });

  group('ClearNotifications', () {
    test('should clear all notifications without filter successfully', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should clear notifications with filter successfully', () async {
      // arrange
      const tFilter = NotificationFilter(
        types: {NotificationType.info, NotificationType.system},
      );
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should clear notifications by priority filter', () async {
      // arrange
      const tFilter = NotificationFilter(
        priorities: {NotificationPriority.low, NotificationPriority.medium},
      );
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should clear notifications by date range filter', () async {
      // arrange
      final tFilter = NotificationFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7), // Clear notifications from first week of January
      );
      final tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should clear notifications by device ID filter', () async {
      // arrange
      const tFilter = NotificationFilter(deviceId: 'device-123');
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should clear notifications by room ID filter', () async {
      // arrange
      const tFilter = NotificationFilter(location: 'room-456');
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should clear only read notifications when unreadOnly is false', () async {
      // arrange
      const tFilter = NotificationFilter(unreadOnly: false);
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should return NotificationFailure when clearing fails', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = NotificationFailure(
        message: 'Failed to clear notifications',
        statusCode: 500,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache clearing fails', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = CacheFailure(
        message: 'Failed to clear notifications from cache',
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = ServerFailure(
        message: 'Internal server error during bulk delete',
        statusCode: 500,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = AuthFailure(
        message: 'Unauthorized to clear notifications',
        statusCode: 401,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should return PermissionFailure when insufficient permissions', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = PermissionFailure(
        message: 'Insufficient permissions to clear notifications',
        statusCode: 403,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should handle successful clear with void return type', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });

    test('should handle complex filter with multiple criteria', () async {
      // arrange
      final tComplexFilter = NotificationFilter(
        types: {NotificationType.info, NotificationType.system},
        priorities: {NotificationPriority.low},
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        unreadOnly: false, // Clear only read notifications
        deviceId: 'device-old',
        location: 'storage-room',
      );
      final tParams = ClearNotificationsParams(filter: tComplexFilter);
      when(() => mockRepository.clearNotifications(filter: tComplexFilter))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.clearNotifications(filter: tComplexFilter)).called(1);
    });

    test('should handle case when no notifications match filter', () async {
      // arrange
      const tFilter = NotificationFilter(
        types: {NotificationType.error},
        deviceId: 'non-existent-device',
      );
      const tParams = ClearNotificationsParams(filter: tFilter);
      const tFailure = NotificationFailure(
        message: 'No notifications match the filter criteria',
        statusCode: 204,
      );
      when(() => mockRepository.clearNotifications(filter: tFilter))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should pass correct filter to repository', () async {
      // arrange
      const tFilter = NotificationFilter(
        types: {NotificationType.warning},
        priorities: {NotificationPriority.medium},
      );
      const tParams = ClearNotificationsParams(filter: tFilter);
      when(() => mockRepository.clearNotifications(filter: any(named: 'filter')))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.clearNotifications(filter: tFilter)).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle timeout during bulk delete operation', () async {
      // arrange
      const tParams = ClearNotificationsParams();
      const tFailure = NetworkFailure(
        message: 'Operation timeout during bulk delete',
        statusCode: 408,
      );
      when(() => mockRepository.clearNotifications(filter: null))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.clearNotifications(filter: null)).called(1);
    });
  });
}