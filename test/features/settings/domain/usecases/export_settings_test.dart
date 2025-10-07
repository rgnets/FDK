import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/export_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ExportSettings usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = ExportSettings(mockRepository);
  });

  group('ExportSettings', () {
    const tExportedData = {
      'version': '1.0.0',
      'settings': {
        'themeMode': 'dark',
        'showDebugInfo': false,
        'enableHapticFeedback': true,
        'scanTimeoutSeconds': 6,
        'enableScanSound': true,
        'enableContinuousScanning': false,
        'apiTimeoutSeconds': 30,
        'enableOfflineMode': true,
        'cacheExpirationHours': 12,
        'enableNotifications': true,
        'enableCriticalAlerts': true,
        'enableInfoAlerts': true,
        'autoSync': true,
        'syncIntervalMinutes': 30,
        'useCellularData': true,
        'enableLogging': false,
        'showPerformanceOverlay': false,
        'enableMockData': false,
      },
      'exportedAt': '2024-01-01T10:00:00Z',
      'deviceInfo': {
        'platform': 'android',
        'version': '1.0.0+1',
      },
    };

    test('should export settings successfully', () async {
      // arrange
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tExportedData));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, Map<String, dynamic>>(tExportedData));
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return exported data with correct structure', () async {
      // arrange
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tExportedData));

      // act
      final result = await usecase(const NoParams());

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data, containsPair('version', '1.0.0'));
          expect(data, contains('settings'));
          expect(data, contains('exportedAt'));
          expect(data, contains('deviceInfo'));
          
          final settings = data['settings'] as Map<String, dynamic>;
          expect(settings, containsPair('themeMode', 'dark'));
          expect(settings, containsPair('scanTimeoutSeconds', 6));
          expect(settings, containsPair('enableHapticFeedback', true));
        },
      );
    });

    test('should return minimal export data when settings are defaults', () async {
      // arrange
      const tMinimalExport = {
        'version': '1.0.0',
        'settings': {
          'themeMode': 'system',
          'showDebugInfo': false,
          'enableHapticFeedback': true,
        },
        'exportedAt': '2024-01-01T10:00:00Z',
      };
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tMinimalExport));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, Map<String, dynamic>>(tMinimalExport));
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data.keys.length, 3);
          expect(data, containsPair('version', '1.0.0'));
          expect(data, contains('settings'));
          expect(data, contains('exportedAt'));
        },
      );
    });

    test('should return SettingsFailure when export fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to export settings',
        statusCode: 500,
      );
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Left<Failure, Map<String, dynamic>>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, Map<String, dynamic>>(tFailure));
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache read fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read settings from cache for export',
      );
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Left<Failure, Map<String, dynamic>>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, Map<String, dynamic>>(tFailure));
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when settings cannot be serialized', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Settings cannot be serialized for export',
        statusCode: 400,
      );
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Left<Failure, Map<String, dynamic>>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, Map<String, dynamic>>(tFailure));
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle complex settings export', () async {
      // arrange
      const tComplexExport = {
        'version': '1.0.0',
        'settings': {
          'themeMode': 'light',
          'showDebugInfo': true,
          'enableHapticFeedback': false,
          'scanTimeoutSeconds': 15,
          'enableScanSound': false,
          'enableContinuousScanning': true,
          'apiTimeoutSeconds': 60,
          'enableOfflineMode': false,
          'cacheExpirationHours': 24,
          'enableNotifications': false,
          'enableCriticalAlerts': true,
          'enableInfoAlerts': false,
          'autoSync': false,
          'syncIntervalMinutes': 60,
          'useCellularData': false,
          'enableLogging': true,
          'showPerformanceOverlay': true,
          'enableMockData': true,
        },
        'exportedAt': '2024-01-01T15:30:00Z',
        'deviceInfo': {
          'platform': 'ios',
          'version': '1.2.0+5',
          'buildNumber': '5',
        },
        'metadata': {
          'exportReason': 'backup',
          'userAgent': 'RGNets-FDK/1.2.0',
        },
      };
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tComplexExport));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, Map<String, dynamic>>(tComplexExport));
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data, contains('metadata'));
          final settings = data['settings'] as Map<String, dynamic>;
          expect(settings.keys.length, greaterThan(10));
          expect(settings, containsPair('enableLogging', true));
          expect(settings, containsPair('showPerformanceOverlay', true));
        },
      );
    });

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tExportedData));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty settings export', () async {
      // arrange
      const tEmptyExport = <String, dynamic>{
        'version': '1.0.0',
        'settings': <String, dynamic>{},
        'exportedAt': '2024-01-01T10:00:00Z',
      };
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Right<Failure, Map<String, dynamic>>(tEmptyExport));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, Map<String, dynamic>>(tEmptyExport));
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          final settings = data['settings'] as Map<String, dynamic>;
          expect(settings.isEmpty, true);
        },
      );
    });

    test('should handle permission failure when unable to read settings', () async {
      // arrange
      const tFailure = PermissionFailure(
        message: 'Permission denied to read settings for export',
        statusCode: 403,
      );
      when(() => mockRepository.exportSettings())
          .thenAnswer((_) async => const Left<Failure, Map<String, dynamic>>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, Map<String, dynamic>>(tFailure));
      verify(() => mockRepository.exportSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}