import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/usecases/reboot_device.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late RebootDevice usecase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    usecase = RebootDevice(mockRepository);
  });

  group('RebootDevice', () {
    const tDeviceId = 'device-123';
    const tParams = RebootDeviceParams(deviceId: tDeviceId);

    test('should reboot device successfully', () async {
      // arrange
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DeviceFailure when device not found', () async {
      // arrange
      const tFailure = DeviceFailure(
        message: 'Device not found',
        statusCode: 404,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DeviceFailure when device is offline', () async {
      // arrange
      const tFailure = DeviceFailure(
        message: 'Device is offline and cannot be rebooted',
        statusCode: 400,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when network error occurs', () async {
      // arrange
      const tFailure = NetworkFailure(
        message: 'Network connection failed',
        statusCode: 408,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const tFailure = ServerFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when authentication fails', () async {
      // arrange
      const tFailure = AuthFailure(
        message: 'Unauthorized access',
        statusCode: 401,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return PermissionFailure when user lacks permission', () async {
      // arrange
      const tFailure = PermissionFailure(
        message: 'Insufficient permissions to reboot device',
        statusCode: 403,
      );
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Left<Failure, void>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, void>(tFailure));
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct device id to repository', () async {
      // arrange
      when(() => mockRepository.rebootDevice(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
    });

    test('should handle successful reboot with void return type', () async {
      // arrange
      when(() => mockRepository.rebootDevice(tDeviceId))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => <String, dynamic>{/* void return type, no assertion needed */},
      );
      verify(() => mockRepository.rebootDevice(tDeviceId)).called(1);
    });

    group('RebootDeviceParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = RebootDeviceParams(deviceId: tDeviceId);
        const params2 = RebootDeviceParams(deviceId: tDeviceId);
        const params3 = RebootDeviceParams(deviceId: 'different-id');

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tDeviceId]);
      });
    });
  });
}