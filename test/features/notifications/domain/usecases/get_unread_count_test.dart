import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification_filter.dart';
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/notifications/domain/usecases/get_unread_count.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late GetUnreadCount usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = GetUnreadCount(mockRepository);
  });

  group('GetUnreadCount', () {
    test('should get unread count without filter successfully', () async {
      // arrange
      const tUnreadCount = 5;
      const tParams = GetUnreadCountParams();
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get unread count with filter successfully', () async {
      // arrange
      const tUnreadCount = 3;
      const tFilter = NotificationFilter(
        types: {NotificationType.error, NotificationType.warning},
        priorities: {NotificationPriority.urgent},
      );
      const tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return zero when no unread notifications exist', () async {
      // arrange
      const tUnreadCount = 0;
      const tParams = GetUnreadCountParams();
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
    });

    test('should handle filter by device ID', () async {
      // arrange
      const tUnreadCount = 2;
      const tFilter = NotificationFilter(deviceId: 'device-123');
      const tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
    });

    test('should handle filter by room ID', () async {
      // arrange
      const tUnreadCount = 1;
      const tFilter = NotificationFilter(location: 'room-456');
      const tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
    });

    test('should handle filter by date range', () async {
      // arrange
      const tUnreadCount = 4;
      final tFilter = NotificationFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 2),
      );
      final tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
    });

    test('should handle filter by search query', () async {
      // arrange
      const tUnreadCount = 2;
      const tFilter = NotificationFilter(searchQuery: 'critical error');
      const tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: tFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
    });

    test('should return NotificationFailure when repository fails', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      const tFailure = NotificationFailure(
        message: 'Failed to get unread count',
        statusCode: 500,
      );
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Left<Failure, int>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, int>(tFailure));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Left<Failure, int>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, int>(tFailure));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Left<Failure, int>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, int>(tFailure));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      const tFailure = CacheFailure(
        message: 'Failed to read unread count from cache',
      );
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Left<Failure, int>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, int>(tFailure));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      const tFailure = AuthFailure(
        message: 'Unauthorized to access notifications',
        statusCode: 401,
      );
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Left<Failure, int>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, int>(tFailure));
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
    });

    test('should handle complex filter with multiple criteria', () async {
      // arrange
      const tUnreadCount = 1;
      final tComplexFilter = NotificationFilter(
        types: {NotificationType.deviceOffline},
        priorities: {NotificationPriority.urgent},
        startDate: DateTime(2024, 1, 1, 9, 0, 0),
        endDate: DateTime(2024, 1, 1, 18, 0, 0),
        deviceId: 'device-critical',
        location: 'server-room',
        searchQuery: 'offline',
      );
      final tParams = GetUnreadCountParams(filter: tComplexFilter);
      when(() => mockRepository.getUnreadCount(filter: tComplexFilter))
          .thenAnswer((_) async => const Right<Failure, int>(tUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tUnreadCount));
      verify(() => mockRepository.getUnreadCount(filter: tComplexFilter)).called(1);
    });

    test('should return high count for busy systems', () async {
      // arrange
      const tHighUnreadCount = 99;
      const tParams = GetUnreadCountParams();
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Right<Failure, int>(tHighUnreadCount));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, int>(tHighUnreadCount));
      result.fold(
        (failure) => fail('Should not return failure'),
        (count) => expect(count, greaterThan(50)),
      );
    });

    test('should pass correct filter to repository', () async {
      // arrange
      const tFilter = NotificationFilter(
        types: {NotificationType.info},
        unreadOnly: true,
      );
      const tParams = GetUnreadCountParams(filter: tFilter);
      when(() => mockRepository.getUnreadCount(filter: any(named: 'filter')))
          .thenAnswer((_) async => const Right<Failure, int>(0));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.getUnreadCount(filter: tFilter)).called(1);
    });

    test('should call repository method once', () async {
      // arrange
      const tParams = GetUnreadCountParams();
      when(() => mockRepository.getUnreadCount(filter: null))
          .thenAnswer((_) async => const Right<Failure, int>(5));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.getUnreadCount(filter: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}