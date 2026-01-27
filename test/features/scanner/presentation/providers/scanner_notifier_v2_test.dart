import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/scanner/data/services/scanner_validation_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier_v2.dart';

void main() {
  late ProviderContainer container;
  late ScannerNotifierV2 notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(scannerNotifierV2Provider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('ScannerNotifierV2', () {
    group('initial state', () {
      test('should start in auto mode with idle UI state', () {
        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.auto);
        expect(state.uiState, ScannerUIState.idle);
        expect(state.scanData, const AccumulatedScanData());
        expect(state.isPopupShowing, false);
      });
    });

    group('setScanMode', () {
      test('should change scan mode', () {
        notifier.setScanMode(ScanMode.accessPoint);
        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.accessPoint);
      });

      test('should clear scan data when mode changes', () {
        // First accumulate some data
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC

        // Change mode
        notifier.setScanMode(ScanMode.ont);
        final state = container.read(scannerNotifierV2Provider);

        expect(state.scanMode, ScanMode.ont);
        expect(state.scanData.mac, isEmpty);
      });
    });

    group('processBarcode - auto detection', () {
      test('should auto-detect AP from 1K9 serial pattern', () {
        notifier.setScanMode(ScanMode.auto);
        notifier.processBarcode('1K9ABC12345'); // AP serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.accessPoint);
        expect(state.isAutoLocked, true);
        expect(state.scanData.serialNumber, '1K9ABC12345');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should auto-detect ONT from ALCL serial pattern', () {
        notifier.setScanMode(ScanMode.auto);
        notifier.processBarcode('ALCL12345678'); // ONT serial (12 chars)

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.ont);
        expect(state.isAutoLocked, true);
        expect(state.scanData.serialNumber, 'ALCL12345678');
      });

      test('should auto-detect Switch from LL serial pattern', () {
        notifier.setScanMode(ScanMode.auto);
        notifier.processBarcode('LL1234567890AB'); // Switch serial (14+ chars)

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.switchDevice);
        expect(state.isAutoLocked, true);
        expect(state.scanData.serialNumber, 'LL1234567890AB');
      });

      test('should detect MAC address without locking mode', () {
        notifier.setScanMode(ScanMode.auto);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC address

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanMode, ScanMode.auto); // Still auto
        expect(state.isAutoLocked, false);
        expect(state.scanData.mac, 'AABBCCDDEEFF');
      });
    });

    group('processBarcode - AP mode', () {
      test('should accept valid AP serial (1K9)', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('1K9ABC12345');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, '1K9ABC12345');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should accept valid AP serial (1M3)', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('1M3XYZ99887');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, '1M3XYZ99887');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should accept valid AP serial (1HN)', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('1HNTEST1234');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, '1HNTEST1234');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should reject non-AP serial in AP mode', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('ALCL12345678'); // ONT serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, isEmpty);
        expect(state.scanData.hasValidSerial, false);
      });

      test('should accept MAC address in AP mode', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('AABBCCDDEEFF');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.mac, 'AABBCCDDEEFF');
      });

      test('should mark complete when MAC and serial are present', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC
        notifier.processBarcode('1K9ABC12345'); // Serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.isScanComplete, true);
      });
    });

    group('processBarcode - ONT mode', () {
      test('should accept valid ALCL serial', () {
        notifier.setScanMode(ScanMode.ont);
        notifier.processBarcode('ALCL12345678');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, 'ALCL12345678');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should reject non-ONT serial in ONT mode', () {
        notifier.setScanMode(ScanMode.ont);
        notifier.processBarcode('1K9ABC12345'); // AP serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, isEmpty);
      });

      test('should require part number for completion', () {
        notifier.setScanMode(ScanMode.ont);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC
        notifier.processBarcode('ALCL12345678'); // Serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.isScanComplete, false);
        expect(state.missingFields, contains('Part Number'));
      });

      test('should mark complete with MAC, serial, and part number', () {
        notifier.setScanMode(ScanMode.ont);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC
        notifier.processBarcode('ALCL12345678'); // Serial
        notifier.processBarcode('1PABC12345XY'); // Part number

        final state = container.read(scannerNotifierV2Provider);
        expect(state.isScanComplete, true);
      });
    });

    group('processBarcode - Switch mode', () {
      test('should accept valid LL serial', () {
        notifier.setScanMode(ScanMode.switchDevice);
        notifier.processBarcode('LL1234567890AB');

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.serialNumber, 'LL1234567890AB');
        expect(state.scanData.hasValidSerial, true);
      });

      test('should mark complete with MAC and LL serial', () {
        notifier.setScanMode(ScanMode.switchDevice);
        notifier.processBarcode('AABBCCDDEEFF'); // MAC
        notifier.processBarcode('LL1234567890AB'); // Serial

        final state = container.read(scannerNotifierV2Provider);
        expect(state.isScanComplete, true);
      });
    });

    group('registration popup controls', () {
      test('should show registration popup', () {
        notifier.showRegistrationPopup();
        final state = container.read(scannerNotifierV2Provider);
        expect(state.isPopupShowing, true);
        expect(state.uiState, ScannerUIState.popup);
      });

      test('should hide registration popup', () {
        notifier.showRegistrationPopup();
        notifier.hideRegistrationPopup();
        final state = container.read(scannerNotifierV2Provider);
        expect(state.isPopupShowing, false);
      });

      test('should set registration in progress', () {
        notifier.setRegistrationInProgress(true);
        var state = container.read(scannerNotifierV2Provider);
        expect(state.isRegistrationInProgress, true);

        notifier.setRegistrationInProgress(false);
        state = container.read(scannerNotifierV2Provider);
        expect(state.isRegistrationInProgress, false);
      });
    });

    group('room selection', () {
      test('should set room selection', () {
        notifier.setRoomSelection(123, 'Room 101');
        final state = container.read(scannerNotifierV2Provider);
        expect(state.selectedRoomId, 123);
        expect(state.selectedRoomNumber, 'Room 101');
      });

      test('should clear room selection', () {
        notifier.setRoomSelection(123, 'Room 101');
        notifier.setRoomSelection(null, null);
        final state = container.read(scannerNotifierV2Provider);
        expect(state.selectedRoomId, isNull);
        expect(state.selectedRoomNumber, isNull);
      });
    });

    group('device match status', () {
      test('should set device match status', () {
        notifier.setDeviceMatchStatus(
          status: DeviceMatchStatus.fullMatch,
          deviceId: 456,
          deviceName: 'Test Device',
          deviceRoomId: 789,
          deviceRoomName: 'Room 202',
        );

        final state = container.read(scannerNotifierV2Provider);
        expect(state.matchStatus, DeviceMatchStatus.fullMatch);
        expect(state.matchedDeviceId, 456);
        expect(state.matchedDeviceName, 'Test Device');
        expect(state.matchedDeviceRoomId, 789);
        expect(state.matchedDeviceRoomName, 'Room 202');
      });
    });

    group('clearScanData', () {
      test('should clear all accumulated scan data', () {
        notifier.setScanMode(ScanMode.accessPoint);
        notifier.processBarcode('AABBCCDDEEFF');
        notifier.processBarcode('1K9ABC12345');
        notifier.setRoomSelection(123, 'Room 101');

        notifier.clearScanData();

        final state = container.read(scannerNotifierV2Provider);
        expect(state.scanData.mac, isEmpty);
        expect(state.scanData.serialNumber, isEmpty);
        expect(state.selectedRoomId, isNull);
        expect(state.matchStatus, DeviceMatchStatus.unchecked);
      });
    });

    group('startScanning', () {
      test('should transition to scanning UI state', () {
        notifier.startScanning();
        final state = container.read(scannerNotifierV2Provider);
        expect(state.uiState, ScannerUIState.scanning);
      });
    });

    group('stopScanning', () {
      test('should transition to idle UI state', () {
        notifier.startScanning();
        notifier.stopScanning();
        final state = container.read(scannerNotifierV2Provider);
        expect(state.uiState, ScannerUIState.idle);
      });
    });
  });

  group('SerialPatterns', () {
    test('AP serials should be detected correctly', () {
      expect(SerialPatterns.isAPSerial('1K9ABC12345'), true);
      expect(SerialPatterns.isAPSerial('1M3XYZ99887'), true);
      expect(SerialPatterns.isAPSerial('1HNTEST1234'), true);
      expect(SerialPatterns.isAPSerial('ALCL12345678'), false);
      expect(SerialPatterns.isAPSerial('LL1234567890'), false);
    });

    test('ONT serials should be detected correctly', () {
      expect(SerialPatterns.isONTSerial('ALCL12345678'), true);
      expect(SerialPatterns.isONTSerial('ALCL1234567'), false); // Too short
      expect(SerialPatterns.isONTSerial('1K9ABC12345'), false);
    });

    test('Switch serials should be detected correctly', () {
      expect(SerialPatterns.isSwitchSerial('LL1234567890AB'), true);
      expect(SerialPatterns.isSwitchSerial('LL123456789012'), true);
      expect(SerialPatterns.isSwitchSerial('LL12345'), false); // Too short
      expect(SerialPatterns.isSwitchSerial('1K9ABC12345'), false);
    });

    test('detectDeviceType should return correct types', () {
      expect(
        SerialPatterns.detectDeviceType('1K9ABC12345'),
        DeviceTypeFromSerial.accessPoint,
      );
      expect(
        SerialPatterns.detectDeviceType('ALCL12345678'),
        DeviceTypeFromSerial.ont,
      );
      expect(
        SerialPatterns.detectDeviceType('LL1234567890AB'),
        DeviceTypeFromSerial.switchDevice,
      );
      expect(SerialPatterns.detectDeviceType('UNKNOWN123'), isNull);
    });
  });

  group('ScannerValidationService', () {
    test('detectDeviceTypeFromBarcode should detect AP serial', () {
      expect(
        ScannerValidationService.detectDeviceTypeFromBarcode('1K9ABC12345'),
        DeviceTypeFromSerial.accessPoint,
      );
    });

    test('detectDeviceTypeFromBarcode should detect ONT serial', () {
      expect(
        ScannerValidationService.detectDeviceTypeFromBarcode('ALCL12345678'),
        DeviceTypeFromSerial.ont,
      );
    });

    test('detectDeviceTypeFromBarcode should detect Switch serial', () {
      expect(
        ScannerValidationService.detectDeviceTypeFromBarcode('LL1234567890AB'),
        DeviceTypeFromSerial.switchDevice,
      );
    });

    test('detectDeviceTypeFromBarcode should return null for MAC', () {
      expect(
        ScannerValidationService.detectDeviceTypeFromBarcode('AABBCCDDEEFF'),
        isNull,
      );
    });
  });
}
