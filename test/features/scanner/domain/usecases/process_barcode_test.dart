import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_barcode.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late ProcessBarcode usecase;
  late MockScannerRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(DeviceType.accessPoint);
  });

  setUp(() {
    mockRepository = MockScannerRepository();
    usecase = ProcessBarcode(mockRepository);
  });

  group('ProcessBarcode', () {
    const tSessionId = 'session-123';
    const tBarcode = 'SN123456';
    const tDeviceType = DeviceType.accessPoint;
    const tParams = ProcessBarcodeParams(
      sessionId: tSessionId,
      barcode: tBarcode,
      deviceType: tDeviceType,
    );

    final tUpdatedSession = ScanSession(
      id: tSessionId,
      deviceType: tDeviceType,
      startedAt: DateTime(2024, 1, 1, 10, 0, 0),
      completedAt: null,
      scannedBarcodes: [
        ScanResult(
          id: 'result-1',
          barcode: tBarcode,
          type: BarcodeType.serialNumber,
          value: tBarcode,
          scannedAt: DateTime(2024, 1, 1, 10, 1, 0),
        ),
      ],
      status: ScanSessionStatus.scanning,
      serialNumber: tBarcode,
      macAddress: null,
      partNumber: null,
      assetTag: null,
    );

    test('should process barcode successfully when validation passes', () async {
      // arrange
      when(() => mockRepository.validateBarcode(tBarcode, tDeviceType))
          .thenAnswer((_) async => const Right<Failure, bool>(true));
      when(() => mockRepository.updateSession(tSessionId, tBarcode))
          .thenAnswer((_) async => Right<Failure, ScanSession>(tUpdatedSession));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, ScanSession>(tUpdatedSession));
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tBarcode)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when barcode validation fails', () async {
      // arrange
      when(() => mockRepository.validateBarcode(tBarcode, tDeviceType))
          .thenAnswer((_) async => const Right<Failure, bool>(false));

      // act
      final result = await usecase(tParams);

      // assert
      expect(
        result,
        const Left<Failure, ScanSession>(
          ValidationFailure(message: 'Invalid barcode for device type'),
        ),
      );
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verifyNever(() => mockRepository.updateSession(any(), any()));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when barcode validation throws error', () async {
      // arrange
      const tValidationFailure = ValidationFailure(
        message: 'Barcode validation service unavailable',
        statusCode: 503,
      );
      when(() => mockRepository.validateBarcode(tBarcode, tDeviceType))
          .thenAnswer((_) async => const Left<Failure, bool>(tValidationFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, ScanSession>(tValidationFailure));
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verifyNever(() => mockRepository.updateSession(any(), any()));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when session update fails', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Failed to update scan session',
        statusCode: 500,
      );
      when(() => mockRepository.validateBarcode(tBarcode, tDeviceType))
          .thenAnswer((_) async => const Right<Failure, bool>(true));
      when(() => mockRepository.updateSession(tSessionId, tBarcode))
          .thenAnswer((_) async => const Left<Failure, ScanSession>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, ScanSession>(tFailure));
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tBarcode)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when session not found', () async {
      // arrange
      const tFailure = ScannerFailure(
        message: 'Scan session not found',
        statusCode: 404,
      );
      when(() => mockRepository.validateBarcode(tBarcode, tDeviceType))
          .thenAnswer((_) async => const Right<Failure, bool>(true));
      when(() => mockRepository.updateSession(tSessionId, tBarcode))
          .thenAnswer((_) async => const Left<Failure, ScanSession>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, ScanSession>(tFailure));
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tBarcode)).called(1);
    });

    test('should handle different device types correctly', () async {
      // arrange
      const tOntParams = ProcessBarcodeParams(
        sessionId: tSessionId,
        barcode: tBarcode,
        deviceType: DeviceType.ont,
      );
      when(() => mockRepository.validateBarcode(tBarcode, DeviceType.ont))
          .thenAnswer((_) async => const Right<Failure, bool>(true));
      when(() => mockRepository.updateSession(tSessionId, tBarcode))
          .thenAnswer((_) async => Right<Failure, ScanSession>(tUpdatedSession));

      // act
      final result = await usecase(tOntParams);

      // assert
      expect(result, Right<Failure, ScanSession>(tUpdatedSession));
      verify(() => mockRepository.validateBarcode(tBarcode, DeviceType.ont)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tBarcode)).called(1);
    });

    test('should handle MAC address barcode processing', () async {
      // arrange
      const tMacAddress = '00:11:22:33:44:55';
      const tMacParams = ProcessBarcodeParams(
        sessionId: tSessionId,
        barcode: tMacAddress,
        deviceType: tDeviceType,
      );
      final tMacSession = tUpdatedSession.copyWith(
        macAddress: tMacAddress,
        scannedBarcodes: [
          ScanResult(
            id: 'result-mac',
            barcode: tMacAddress,
            type: BarcodeType.macAddress,
            value: tMacAddress,
            scannedAt: DateTime(2024, 1, 1, 10, 2, 0),
          ),
        ],
      );
      when(() => mockRepository.validateBarcode(tMacAddress, tDeviceType))
          .thenAnswer((_) async => const Right<Failure, bool>(true));
      when(() => mockRepository.updateSession(tSessionId, tMacAddress))
          .thenAnswer((_) async => Right<Failure, ScanSession>(tMacSession));

      // act
      final result = await usecase(tMacParams);

      // assert
      expect(result, Right<Failure, ScanSession>(tMacSession));
      verify(() => mockRepository.validateBarcode(tMacAddress, tDeviceType)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tMacAddress)).called(1);
    });

    test('should pass correct parameters to repository methods', () async {
      // arrange
      when(() => mockRepository.validateBarcode(any(), any()))
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.updateSession(any(), any()))
          .thenAnswer((_) async => Right(tUpdatedSession));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.validateBarcode(tBarcode, tDeviceType)).called(1);
      verify(() => mockRepository.updateSession(tSessionId, tBarcode)).called(1);
    });

    group('ProcessBarcodeParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        const params1 = ProcessBarcodeParams(
          sessionId: tSessionId,
          barcode: tBarcode,
          deviceType: tDeviceType,
        );
        const params2 = ProcessBarcodeParams(
          sessionId: tSessionId,
          barcode: tBarcode,
          deviceType: tDeviceType,
        );
        const params3 = ProcessBarcodeParams(
          sessionId: 'different-id',
          barcode: tBarcode,
          deviceType: tDeviceType,
        );

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [tSessionId, tBarcode, tDeviceType]);
      });
    });
  });
}
