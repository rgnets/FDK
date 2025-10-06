import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/get_notifications.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late GetNotifications usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = GetNotifications(mockRepository);
  });

  group('GetNotifications', () {
    final tNotificationsList = [
      AppNotification(
        id: 'notif-1',
        title: 'Device Online',
        message: 'Router 1 is now online',
        type: NotificationType.deviceOnline,
        priority: NotificationPriority.medium,
        timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        isRead: false,
        deviceId: 'device-1',
        location: 'room-1',
        metadata: {'connectionTime': '2024-01-01T10:00:00Z'},
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Scan Complete',
        message: 'Device scan session completed successfully',
        type: NotificationType.scanComplete,
        priority: NotificationPriority.low,
        timestamp: DateTime(2024, 1, 1, 11, 0, 0),
        isRead: true,
        deviceId: 'device-2',
        location: null,
        metadata: {'scanDuration': 120, 'devicesFound': 5},
      ),
    ];

    test('should get notifications without filter successfully', () async {
      // arrange
      const tParams = GetNotificationsParams();
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tNotificationsList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppNotification>>(tNotificationsList));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get notifications with filter successfully', () async {
      // arrange
      const tFilter = NotificationFilter(
        types: {NotificationType.deviceOnline, NotificationType.deviceOffline},
        unreadOnly: true,
      );
      const tParams = GetNotificationsParams(filter: tFilter, limit: 10, offset: 0);
      final tFilteredList = [tNotificationsList.first]; // Only unread device online notification
      
      when(() => mockRepository.getNotifications(
        filter: tFilter,
        limit: 10,
        offset: 0,
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tFilteredList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppNotification>>(tFilteredList));
      verify(() => mockRepository.getNotifications(
        filter: tFilter,
        limit: 10,
        offset: 0,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no notifications found', () async {
      // arrange
      const tParams = GetNotificationsParams();
      const tEmptyList = <AppNotification>[];
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => const Right<Failure, List<AppNotification>>(tEmptyList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, List<AppNotification>>(tEmptyList));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).called(1);
    });

    test('should handle pagination parameters', () async {
      // arrange
      const tParams = GetNotificationsParams(limit: 5, offset: 10);
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: 5,
        offset: 10,
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tNotificationsList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppNotification>>(tNotificationsList));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: 5,
        offset: 10,
      )).called(1);
    });

    test('should return NotificationFailure when repository fails', () async {
      // arrange
      const tParams = GetNotificationsParams();
      const tFailure = NotificationFailure(
        message: 'Failed to fetch notifications',
        statusCode: 500,
      );
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => const Left<Failure, List<AppNotification>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<AppNotification>>(tFailure));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).called(1);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tParams = GetNotificationsParams();
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => const Left<Failure, List<AppNotification>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<AppNotification>>(tFailure));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tParams = GetNotificationsParams();
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => const Left<Failure, List<AppNotification>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<AppNotification>>(tFailure));
      verify(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).called(1);
    });

    test('should handle complex filter with multiple criteria', () async {
      // arrange
      final tComplexFilter = NotificationFilter(
        types: {NotificationType.error, NotificationType.warning},
        priorities: {NotificationPriority.urgent},
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 2),
        unreadOnly: true,
        searchQuery: 'critical',
        deviceId: 'device-123',
      );
      final tParams = GetNotificationsParams(filter: tComplexFilter);
      
      when(() => mockRepository.getNotifications(
        filter: tComplexFilter,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tNotificationsList));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppNotification>>(tNotificationsList));
      verify(() => mockRepository.getNotifications(
        filter: tComplexFilter,
        limit: null,
        offset: null,
      )).called(1);
    });

    test('should handle notifications with different types and priorities', () async {
      // arrange
      final tDiverseNotifications = [
        AppNotification(
          id: 'notif-critical',
          title: 'Critical Error',
          message: 'System failure detected',
          type: NotificationType.error,
          priority: NotificationPriority.urgent,
          timestamp: DateTime(2024, 1, 1, 12, 0, 0),
          isRead: false,
          deviceId: 'device-critical',
          location: 'server-room',
        ),
        AppNotification(
          id: 'notif-info',
          title: 'System Update',
          message: 'System update completed successfully',
          type: NotificationType.system,
          priority: NotificationPriority.low,
          timestamp: DateTime(2024, 1, 1, 13, 0, 0),
          isRead: false,
          deviceId: null,
          location: null,
        ),
      ];
      const tParams = GetNotificationsParams();
      
      when(() => mockRepository.getNotifications(
        filter: null,
        limit: null,
        offset: null,
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tDiverseNotifications));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<AppNotification>>(tDiverseNotifications));
      result.fold(
        (failure) => fail('Should not return failure'),
        (notifications) {
          expect(notifications.length, 2);
          expect(notifications.first.priority, NotificationPriority.urgent);
          expect(notifications.last.priority, NotificationPriority.low);
        },
      );
    });

    test('should pass all parameters correctly to repository', () async {
      // arrange
      const tFilter = NotificationFilter(unreadOnly: true);
      const tParams = GetNotificationsParams(
        filter: tFilter,
        limit: 20,
        offset: 5,
      );
      
      when(() => mockRepository.getNotifications(
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => Right<Failure, List<AppNotification>>(tNotificationsList));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.getNotifications(
        filter: tFilter,
        limit: 20,
        offset: 5,
      )).called(1);
    });
  });
}