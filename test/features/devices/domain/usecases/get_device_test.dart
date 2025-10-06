import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/get_device.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late GetDevice usecase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    usecase = GetDevice(mockRepository);
  });

  group('GetDevice', () {
    const tDeviceId = 'device-123';
    const tParams = GetDeviceParams(id: tDeviceId);
    
    final tDevice = Device(
      id: tDeviceId,
      name: 'Test Device',
      type: 'Router',
      status: 'online',
      ipAddress: '192.168.1.1',
      macAddress: '00:11:22:33:44:55',
      location: 'Main Office',
      lastSeen: DateTime(2024, 1, 1, 10, 0, 0),
      model: 'RG-100',
      serialNumber: 'SN123456',
      firmware: '1.2.3',
      signalStrength: -45,
      uptime: 86400,
      connectedClients: 15,
    );

    test('should get device from repository successfully', () async {
      // arrange
      when(() => mockRepository.getDevice(tDeviceId))
          .thenAnswer((_) async => Right<Failure, Device>(tDevice));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, Device>(tDevice));
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DeviceFailure when device not found', () async {
      // arrange
      const tFailure = DeviceFailure(
        message: 'Device not found',
        statusCode: 404,
      );
      when(() => mockRepository.getDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, Device>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, Device>(tFailure));
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.getDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, Device>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, Device>(tFailure));
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.getDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, Device>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, Device>(tFailure));
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized access',
        statusCode: 401,
      );
      when(() => mockRepository.getDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, Device>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, Device>(tFailure));
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct device id to repository', () async {
      // arrange
      when(() => mockRepository.getDevice(any()))
          .thenAnswer((_) async => Right<Failure, Device>(tDevice));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.getDevice(tDeviceId)).called(1);
    });

    group('GetDeviceParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = GetDeviceParams(id: tDeviceId);
        const params2 = GetDeviceParams(id: tDeviceId);
        const params3 = GetDeviceParams(id: 'different-id');

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tDeviceId]);
      });
    });
  });
}