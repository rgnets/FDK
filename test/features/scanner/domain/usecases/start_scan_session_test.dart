import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/start_scan_session.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late StartScanSession usecase;
  late MockScannerRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(DeviceType.accessPoint);
  });

  setUp(() {
    mockRepository = MockScannerRepository();
    usecase = StartScanSession(mockRepository);
  });

  group('StartScanSession', () {
    const tDeviceType = DeviceType.accessPoint;
    const tParams = StartScanSessionParams(deviceType: tDeviceType);

    final tScanSession = ScanSession(
      id: 'session-123',
      deviceType: tDeviceType,
      startedAt: DateTime(2024, 1, 1, 10, 0, 0),
      completedAt: null,
      scannedBarcodes: const [],
      status: ScanSessionStatus.scanning,
      serialNumber: null,
      macAddress: null,
      partNumber: null,
      assetTag: null,
    );

    test('should start scan session successfully', () async {
      // arrange
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => Right(tScanSession));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tScanSession));
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should start session for different device types', () async {
      // arrange
      const tOntParams = StartScanSessionParams(deviceType: DeviceType.ont);
      final tOntSession = tScanSession.copyWith(
        id: 'session-ont',
        deviceType: DeviceType.ont,
      );
      when(() => mockRepository.startSession(DeviceType.ont))
          .thenAnswer((_) async => Right(tOntSession));

      // act
      final result = await usecase(tOntParams);

      // assert
      expect(result, Right(tOntSession));
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) => expect(session.deviceType, DeviceType.ont),
      );
      verify(() => mockRepository.startSession(DeviceType.ont)).called(1);
    });

    test('should start session for switch device', () async {
      // arrange
      const tSwitchParams = StartScanSessionParams(deviceType: DeviceType.switchDevice);
      final tSwitchSession = tScanSession.copyWith(
        id: 'session-switch',
        deviceType: DeviceType.switchDevice,
      );
      when(() => mockRepository.startSession(DeviceType.switchDevice))
          .thenAnswer((_) async => Right(tSwitchSession));

      // act
      final result = await usecase(tSwitchParams);

      // assert
      expect(result, Right(tSwitchSession));
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) => expect(session.deviceType, DeviceType.switchDevice),
      );
      verify(() => mockRepository.startSession(DeviceType.switchDevice)).called(1);
    });

    test('should return ScannerFailure when session creation fails', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Failed to start scan session',
        statusCode: 500,
      );
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when another session is already active', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Another scan session is already active',
        statusCode: 409,
      );
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache operation fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to save session to cache',
      );
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when device type is invalid', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Invalid device type provided',
        statusCode: 400,
      );
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct device type to repository', () async {
      // arrange
      when(() => mockRepository.startSession(any()))
          .thenAnswer((_) async => Right(tScanSession));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
    });

    test('should return session with correct initial state', () async {
      // arrange
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => Right(tScanSession));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) {
          expect(session.deviceType, tDeviceType);
          expect(session.status, ScanSessionStatus.scanning);
          expect(session.completedAt, isNull);
          expect(session.scannedBarcodes, isEmpty);
          expect(session.isComplete, false);
          expect(session.canRegister, false);
          expect(session.duration, isNull);
        },
      );
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.startSession(tDeviceType))
          .thenAnswer((_) async => Right(tScanSession));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.startSession(tDeviceType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    group('StartScanSessionParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = StartScanSessionParams(deviceType: tDeviceType);
        const params2 = StartScanSessionParams(deviceType: tDeviceType);
        const params3 = StartScanSessionParams(deviceType: DeviceType.ont);

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tDeviceType]);
      });
    });
  });
}