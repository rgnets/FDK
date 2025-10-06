import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/search_devices.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late SearchDevices usecase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    usecase = SearchDevices(mockRepository);
  });

  group('SearchDevices', () {
    const tQuery = 'router';
    const tParams = SearchDevicesParams(query: tQuery);
    
    final tSearchResults = [
      const Device(
        id: 'device-1',
        name: 'Main Router',
        type: 'Router',
        status: 'online',
        ipAddress: '192.168.1.1',
        macAddress: '00:11:22:33:44:55',
        location: 'Main Office',
        model: 'RG-100',
        serialNumber: 'SN123456',
        firmware: '1.2.3',
        signalStrength: -45,
        uptime: 86400,
        connectedClients: 15,
      ),
      const Device(
        id: 'device-2',
        name: 'Backup Router',
        type: 'Router',
        status: 'offline',
        ipAddress: '192.168.1.2',
        macAddress: '00:11:22:33:44:56',
        location: 'Server Room',
        model: 'RG-200',
        serialNumber: 'SN123457',
        firmware: '1.2.4',
        signalStrength: -55,
        uptime: 43200,
        connectedClients: 0,
      ),
    ];

    test('should search devices successfully with query', () async {
      // arrange
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => Right<Failure, List<Device>>(tSearchResults));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, List<Device>>(tSearchResults));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no devices match query', () async {
      // arrange
      const tEmptyResults = <Device>[];
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => const Right<Failure, List<Device>>(tEmptyResults));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, List<Device>>(tEmptyResults));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty query string', () async {
      // arrange
      const tEmptyQuery = '';
      const tEmptyParams = SearchDevicesParams(query: tEmptyQuery);
      const tEmptyResults = <Device>[];
      when(() => mockRepository.searchDevices(tEmptyQuery))
          .thenAnswer((_) async => const Right<Failure, List<Device>>(tEmptyResults));

      // act
      final result = await usecase(tEmptyParams);

      // assert
      expect(result, const Right<Failure, List<Device>>(tEmptyResults));
      verify(() => mockRepository.searchDevices(tEmptyQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle whitespace-only query', () async {
      // arrange
      const tWhitespaceQuery = '   ';
      const tWhitespaceParams = SearchDevicesParams(query: tWhitespaceQuery);
      const tEmptyResults = <Device>[];
      when(() => mockRepository.searchDevices(tWhitespaceQuery))
          .thenAnswer((_) async => const Right<Failure, List<Device>>(tEmptyResults));

      // act
      final result = await usecase(tWhitespaceParams);

      // assert
      expect(result, const Right<Failure, List<Device>>(tEmptyResults));
      verify(() => mockRepository.searchDevices(tWhitespaceQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DeviceFailure when search fails', () async {
      // arrange
      const tFailure = DeviceFailure(
        message: 'Search operation failed',
        statusCode: 500,
      );
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized access',
        statusCode: 401,
      );
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct query to repository', () async {
      // arrange
      when(() => mockRepository.searchDevices(any()))
          .thenAnswer((_) async => Right<Failure, List<Device>>(tSearchResults));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.searchDevices(tQuery)).called(1);
    });

    test('should return correct number of search results', () async {
      // arrange
      when(() => mockRepository.searchDevices(tQuery))
          .thenAnswer((_) async => Right<Failure, List<Device>>(tSearchResults));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (devices) => expect(devices.length, 2),
      );
    });

    group('SearchDevicesParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = SearchDevicesParams(query: tQuery);
        const params2 = SearchDevicesParams(query: tQuery);
        const params3 = SearchDevicesParams(query: 'different query');

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tQuery]);
      });
    });
  });
}