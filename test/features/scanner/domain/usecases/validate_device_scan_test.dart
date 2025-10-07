import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/validate_device_scan.dart';

void main() {
  late ValidateDeviceScan usecase;

  setUp(() {
    usecase = ValidateDeviceScan();
  });

  group('ValidateDeviceScan', () {
    final tBaseSession = ScanSession(
      id: 'session-123',
      deviceType: DeviceType.accessPoint,
      startedAt: DateTime(2024, 1, 1, 10, 0, 0),
      completedAt: null,
      scannedBarcodes: const [],
      status: ScanSessionStatus.scanning,
      serialNumber: null,
      macAddress: null,
      partNumber: null,
      assetTag: null,
    );

    group('Access Point validation', () {
      test('should return true when both serial number and MAC address are present', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: 'SN123456',
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });

      test('should return false when serial number is missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: null,
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when MAC address is missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: 'SN123456',
          macAddress: null,
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when serial number is empty', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: '',
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when MAC address is empty', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: 'SN123456',
          macAddress: '',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when both fields are missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: null,
          macAddress: null,
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });
    });

    group('ONT validation', () {
      test('should return true when both serial number and MAC address are present', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.ont,
          serialNumber: 'ONT123456',
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });

      test('should return false when serial number is missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.ont,
          serialNumber: null,
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when MAC address is missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.ont,
          serialNumber: 'ONT123456',
          macAddress: null,
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when both fields are empty strings', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.ont,
          serialNumber: '',
          macAddress: '',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });
    });

    group('Switch Device validation', () {
      test('should return true when serial number is present', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.switchDevice,
          serialNumber: 'SW123456',
          macAddress: null, // MAC not required for switches
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });

      test('should return true when serial number is present and MAC address is also present', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.switchDevice,
          serialNumber: 'SW123456',
          macAddress: '00:11:22:33:44:55', // Optional for switches
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });

      test('should return false when serial number is missing', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.switchDevice,
          serialNumber: null,
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });

      test('should return false when serial number is empty', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.switchDevice,
          serialNumber: '',
          macAddress: '00:11:22:33:44:55',
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(false));
      });
    });

    group('Complex scenarios', () {
      test('should validate completed access point session', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: 'AP123456',
          macAddress: '00:11:22:33:44:55',
          partNumber: 'PN789012',
          assetTag: 'AT345678',
          status: ScanSessionStatus.complete,
          completedAt: DateTime(2024, 1, 1, 10, 5, 0),
          scannedBarcodes: [
            ScanResult(
              id: 'result-1',
              barcode: 'AP123456',
              type: BarcodeType.serialNumber,
              value: 'AP123456',
              scannedAt: DateTime(2024, 1, 1, 10, 1, 0),
            ),
            ScanResult(
              id: 'result-2',
              barcode: '00:11:22:33:44:55',
              type: BarcodeType.macAddress,
              value: '00:11:22:33:44:55',
              scannedAt: DateTime(2024, 1, 1, 10, 2, 0),
            ),
          ],
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });

      test('should validate session with additional metadata', () async {
        // arrange
        final tSession = tBaseSession.copyWith(
          deviceType: DeviceType.accessPoint,
          serialNumber: 'AP123456',
          macAddress: '00:11:22:33:44:55',
          additionalData: {
            'firmware': '2.1.0',
            'model': 'AP-500',
            'location': 'Office 1',
          },
        );
        final tParams = ValidateDeviceScanParams(scanSession: tSession);

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, const Right<Failure, bool>(true));
      });
    });

    group('ValidateDeviceScanParams', () {
      test('should have correct props for equality comparison', () {
        // arrange
        final session1 = tBaseSession.copyWith(serialNumber: 'SN123');
        final session2 = tBaseSession.copyWith(serialNumber: 'SN123');
        final session3 = tBaseSession.copyWith(serialNumber: 'SN456');

        final params1 = ValidateDeviceScanParams(scanSession: session1);
        final params2 = ValidateDeviceScanParams(scanSession: session2);
        final params3 = ValidateDeviceScanParams(scanSession: session3);

        // assert
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.props, [session1]);
      });
    });
  });
}
