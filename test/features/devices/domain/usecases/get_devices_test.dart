import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_devices_params.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late GetDevices usecase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    usecase = GetDevices(mockRepository);
  });

  group('GetDevices', () {
    final tDevicesList = [
      const Device(
        id: 'device-1',
        name: 'Router 1',
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
        name: 'Access Point 1',
        type: 'Access Point',
        status: 'offline',
        ipAddress: '192.168.1.2',
        macAddress: '00:11:22:33:44:56',
        location: 'Conference Room',
        model: 'RG-200',
        serialNumber: 'SN123457',
        firmware: '1.2.4',
        signalStrength: -55,
        uptime: 43200,
        connectedClients: 8,
      ),
    ];

    test('should get devices list from repository successfully', () async {
      // arrange
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => Right<Failure, List<Device>>(tDevicesList));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, Right<Failure, List<Device>>(tDevicesList));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no devices found', () async {
      // arrange
      const tEmptyList = <Device>[];
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Right<Failure, List<Device>>(tEmptyList));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Right<Failure, List<Device>>(tEmptyList));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DeviceFailure when repository fails', () async {
      // arrange
      const tFailure = DeviceFailure(
        message: 'Failed to fetch devices',
        statusCode: 500,
      );
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized access',
        statusCode: 401,
      );
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read devices from cache',
      );
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => const Left<Failure, List<Device>>(tFailure));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      expect(result, const Left<Failure, List<Device>>(tFailure));
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => Right<Failure, List<Device>>(tDevicesList));

      // act
      await usecase(const GetDevicesParams());

      // assert
      verify(() => mockRepository.getDevices()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return correct number of devices', () async {
      // arrange
      when(() => mockRepository.getDevices())
          .thenAnswer((_) async => Right<Failure, List<Device>>(tDevicesList));

      // act
      final result = await usecase(const GetDevicesParams());

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (devices) => expect(devices.length, 2),
      );
    });
  });
}
