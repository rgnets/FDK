import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_room_readiness_by_id.dart';

class MockRoomReadinessRepository extends Mock
    implements RoomReadinessRepository {}

void main() {
  late GetRoomReadinessById usecase;
  late MockRoomReadinessRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomReadinessRepository();
    usecase = GetRoomReadinessById(mockRepository);
  });

  group('GetRoomReadinessById', () {
    const tRoomId = 1;

    final tIssue = Issue.deviceOffline(
      deviceId: 1,
      deviceName: 'AP-001',
      deviceType: 'AP',
    );

    final tMetrics = RoomReadinessMetrics(
      roomId: tRoomId,
      roomName: 'Room 101',
      status: RoomStatus.partial,
      totalDevices: 5,
      onlineDevices: 4,
      offlineDevices: 1,
      issues: [tIssue],
      lastUpdated: DateTime(2024, 1, 1, 10, 0, 0),
    );

    test('should get room readiness metrics by id from repository successfully',
        () async {
      // arrange
      when(() => mockRepository.getRoomReadinessById(tRoomId))
          .thenAnswer((_) async => Right<Failure, RoomReadinessMetrics>(tMetrics));

      // act
      final result = await usecase(tRoomId);

      // assert
      expect(result, Right<Failure, RoomReadinessMetrics>(tMetrics));
      verify(() => mockRepository.getRoomReadinessById(tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when room not found', () async {
      // arrange
      const tFailure = NotFoundFailure(
        message: 'Room not found',
        statusCode: 404,
      );
      when(() => mockRepository.getRoomReadinessById(tRoomId))
          .thenAnswer((_) async => const Left<Failure, RoomReadinessMetrics>(tFailure));

      // act
      final result = await usecase(tRoomId);

      // assert
      expect(result, const Left<Failure, RoomReadinessMetrics>(tFailure));
      verify(() => mockRepository.getRoomReadinessById(tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RoomReadinessFailure when repository fails', () async {
      // arrange
      const tFailure = RoomReadinessFailure(
        message: 'Failed to fetch room readiness',
        statusCode: 500,
      );
      when(() => mockRepository.getRoomReadinessById(tRoomId))
          .thenAnswer((_) async => const Left<Failure, RoomReadinessMetrics>(tFailure));

      // act
      final result = await usecase(tRoomId);

      // assert
      expect(result, const Left<Failure, RoomReadinessFailure>(tFailure));
      verify(() => mockRepository.getRoomReadinessById(tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getRoomReadinessById(tRoomId))
          .thenAnswer((_) async => const Left<Failure, RoomReadinessMetrics>(tFailure));

      // act
      final result = await usecase(tRoomId);

      // assert
      expect(result, const Left<Failure, RoomReadinessMetrics>(tFailure));
      verify(() => mockRepository.getRoomReadinessById(tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return room metrics with correct properties', () async {
      // arrange
      when(() => mockRepository.getRoomReadinessById(tRoomId))
          .thenAnswer((_) async => Right<Failure, RoomReadinessMetrics>(tMetrics));

      // act
      final result = await usecase(tRoomId);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) {
          expect(metrics.roomId, tRoomId);
          expect(metrics.roomName, 'Room 101');
          expect(metrics.status, RoomStatus.partial);
          expect(metrics.totalDevices, 5);
          expect(metrics.onlineDevices, 4);
          expect(metrics.offlineDevices, 1);
          expect(metrics.issues.length, 1);
          expect(metrics.issues.first.code, 'DEVICE_OFFLINE');
        },
      );
    });
  });
}
