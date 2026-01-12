import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';
import 'package:rgnets_fdk/features/rooms/domain/usecases/get_rooms.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late GetRooms usecase;
  late MockRoomRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomRepository();
    usecase = GetRooms(mockRepository);
  });

  group('GetRooms', () {
    final tRoomsList = [
      Room(
        id: 1,
        name: '(Building A) Main Office',
        number: '101',
        description: 'Primary office space',
        location: 'Ground Floor',
        deviceIds: const ['device-1', 'device-2'],
        metadata: const {'capacity': 50, 'type': 'office'},
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 10, 0, 0),
      ),
      Room(
        id: 2,
        name: '(Building A) Conference Room A',
        number: '201',
        description: 'Large conference room',
        location: 'First Floor',
        deviceIds: const ['device-3', 'device-4', 'device-5'],
        metadata: const {'capacity': 20, 'type': 'conference'},
        createdAt: DateTime(2024, 1, 1, 11, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 11, 0, 0),
      ),
    ];

    test('should get rooms list from repository successfully', () async {
      // arrange
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => Right<Failure, List<Room>>(tRoomsList));

      // act
      final result = await usecase();

      // assert
      expect(result, Right<Failure, List<Room>>(tRoomsList));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no rooms found', () async {
      // arrange
      const tEmptyList = <Room>[];
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Right<Failure, List<Room>>(tEmptyList));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, List<Room>>(tEmptyList));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RoomFailure when repository fails', () async {
      // arrange
      const tFailure = RoomFailure(
        message: 'Failed to fetch rooms',
        statusCode: 500,
      );
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Left<Failure, List<Room>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, List<Room>>(tFailure));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Left<Failure, List<Room>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, List<Room>>(tFailure));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Left<Failure, List<Room>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, List<Room>>(tFailure));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized access',
        statusCode: 401,
      );
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Left<Failure, List<Room>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, List<Room>>(tFailure));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read rooms from cache',
      );
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => const Left<Failure, List<Room>>(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left<Failure, List<Room>>(tFailure));
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => Right<Failure, List<Room>>(tRoomsList));

      // act
      await usecase();

      // assert
      verify(() => mockRepository.getRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return correct number of rooms', () async {
      // arrange
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => Right<Failure, List<Room>>(tRoomsList));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (rooms) => expect(rooms.length, 2),
      );
    });

    test('should return rooms with correct properties', () async {
      // arrange
      when(() => mockRepository.getRooms())
          .thenAnswer((_) async => Right<Failure, List<Room>>(tRoomsList));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (rooms) {
          expect(rooms.first.id, 1);
          expect(rooms.first.name, '(Building A) Main Office');
          expect(rooms.first.number, '101');
          expect(rooms.first.deviceIds, const ['device-1', 'device-2']);
          
          expect(rooms.last.id, 2);
          expect(rooms.last.name, '(Building A) Conference Room A');
          expect(rooms.last.number, '201');
          expect(rooms.last.deviceIds, const ['device-3', 'device-4', 'device-5']);
        },
      );
    });
  });
}
