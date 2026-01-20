import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/usecases/get_all_room_readiness.dart';

class MockRoomReadinessRepository extends Mock
    implements RoomReadinessRepository {}

void main() {
  late GetAllRoomReadiness usecase;
  late MockRoomReadinessRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomReadinessRepository();
    usecase = GetAllRoomReadiness(mockRepository);
  });

  group('GetAllRoomReadiness', () {
    final tMetricsList = [
      RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.ready,
        totalDevices: 5,
        onlineDevices: 5,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime(2024, 1, 1, 10, 0, 0),
      ),
      RoomReadinessMetrics(
        roomId: 2,
        roomName: 'Room 102',
        status: RoomStatus.partial,
        totalDevices: 3,
        onlineDevices: 2,
        offlineDevices: 1,
        issues: const [],
        lastUpdated: DateTime(2024, 1, 1, 10, 0, 0),
      ),
    ];

    test('should get room readiness metrics list from repository successfully',
        () async {
      // arrange
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer(
          (_) async => Right<Failure, List<RoomReadinessMetrics>>(tMetricsList));

      // act
      final result = await usecase();

      // assert
      expect(
          result, Right<Failure, List<RoomReadinessMetrics>>(tMetricsList));
      verify(() => mockRepository.getAllRoomReadiness()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no rooms found', () async {
      // arrange
      const tEmptyList = <RoomReadinessMetrics>[];
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer((_) async =>
          const Right<Failure, List<RoomReadinessMetrics>>(tEmptyList));

      // act
      final result = await usecase();

      // assert
      expect(result,
          const Right<Failure, List<RoomReadinessMetrics>>(tEmptyList));
      verify(() => mockRepository.getAllRoomReadiness()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RoomReadinessFailure when repository fails', () async {
      // arrange
      const tFailure = RoomReadinessFailure(
        message: 'Failed to fetch room readiness',
        statusCode: 500,
      );
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer((_) async =>
          const Left<Failure, List<RoomReadinessMetrics>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result,
          const Left<Failure, List<RoomReadinessMetrics>>(tFailure));
      verify(() => mockRepository.getAllRoomReadiness()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer((_) async =>
          const Left<Failure, List<RoomReadinessMetrics>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result,
          const Left<Failure, List<RoomReadinessMetrics>>(tFailure));
      verify(() => mockRepository.getAllRoomReadiness()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer(
          (_) async => Right<Failure, List<RoomReadinessMetrics>>(tMetricsList));

      // act
      await usecase();

      // assert
      verify(() => mockRepository.getAllRoomReadiness()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return correct number of room metrics', () async {
      // arrange
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer(
          (_) async => Right<Failure, List<RoomReadinessMetrics>>(tMetricsList));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) => expect(metrics.length, 2),
      );
    });

    test('should return room metrics with correct properties', () async {
      // arrange
      when(() => mockRepository.getAllRoomReadiness()).thenAnswer(
          (_) async => Right<Failure, List<RoomReadinessMetrics>>(tMetricsList));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (metrics) {
          expect(metrics.first.roomId, 1);
          expect(metrics.first.roomName, 'Room 101');
          expect(metrics.first.status, RoomStatus.ready);
          expect(metrics.first.totalDevices, 5);
          expect(metrics.first.onlineDevices, 5);

          expect(metrics.last.roomId, 2);
          expect(metrics.last.roomName, 'Room 102');
          expect(metrics.last.status, RoomStatus.partial);
          expect(metrics.last.offlineDevices, 1);
        },
      );
    });
  });
}
