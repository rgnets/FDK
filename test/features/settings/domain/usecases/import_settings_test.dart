import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/import_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ImportSettings usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = ImportSettings(mockRepository);
  });

  group('ImportSettings', () {
    const tImportData = {
      'version': '1.0.0',
      'settings': {
        'themeMode': 'dark',
        'showDebugInfo': false,
        'enableHapticFeedback': true,
        'scanTimeoutSeconds': 10,
        'enableScanSound': false,
        'enableContinuousScanning': true,
        'apiTimeoutSeconds': 45,
        'enableOfflineMode': false,
        'cacheExpirationHours': 24,
        'enableNotifications': true,
        'enableCriticalAlerts': true,
        'enableInfoAlerts': false,
        'autoSync': false,
        'syncIntervalMinutes': 60,
        'useCellularData': false,
        'enableLogging': true,
        'showPerformanceOverlay': false,
        'enableMockData': true,
      },
      'exportedAt': '2024-01-01T10:00:00Z',
    };

    const tImportedSettings = AppSettings(
      themeMode: AppThemeMode.dark,
      showDebugInfo: false,
      enableHapticFeedback: true,
      scanTimeoutSeconds: 10,
      enableScanSound: false,
      enableContinuousScanning: true,
      apiTimeoutSeconds: 45,
      enableOfflineMode: false,
      cacheExpirationHours: 24,
      enableNotifications: true,
      enableCriticalAlerts: true,
      enableInfoAlerts: false,
      autoSync: false,
      syncIntervalMinutes: 60,
      useCellularData: false,
      enableLogging: true,
      showPerformanceOverlay: false,
      enableMockData: true,
    );

    const tParams = ImportSettingsParams(data: tImportData);

    test('should import settings successfully', () async {
      // arrange
      when(() => mockRepository.importSettings(tImportData))
          .thenAnswer((_) async => const Right(tImportedSettings));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(tImportedSettings));
      verify(() => mockRepository.importSettings(tImportData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return imported settings with correct values', () async {
      // arrange
      when(() => mockRepository.importSettings(tImportData))
          .thenAnswer((_) async => const Right(tImportedSettings));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.dark);
          expect(settings.scanTimeoutSeconds, 10);
          expect(settings.enableScanSound, false);
          expect(settings.enableContinuousScanning, true);
          expect(settings.apiTimeoutSeconds, 45);
          expect(settings.enableOfflineMode, false);
          expect(settings.enableLogging, true);
          expect(settings.enableMockData, true);
        },
      );
    });

    test('should return ValidationFailure when import data is invalid', () async {
      // arrange
      const tInvalidData = {
        'invalidStructure': true,
        'missingSettings': null,
      };
      const tInvalidParams = ImportSettingsParams(data: tInvalidData);
      const tFailure = ValidationFailure(
        message: 'Invalid import data format',
        statusCode: 400,
      );
      when(() => mockRepository.importSettings(tInvalidData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tInvalidParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tInvalidData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when version is incompatible', () async {
      // arrange
      const tIncompatibleData = {
        'version': '2.0.0',
        'settings': {'themeMode': 'dark'},
      };
      const tIncompatibleParams = ImportSettingsParams(data: tIncompatibleData);
      const tFailure = ValidationFailure(
        message: 'Incompatible settings version',
        statusCode: 400,
      );
      when(() => mockRepository.importSettings(tIncompatibleData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tIncompatibleParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tIncompatibleData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return SettingsFailure when import process fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to import settings',
        statusCode: 500,
      );
      when(() => mockRepository.importSettings(tImportData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tImportData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache write fails during import', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to save imported settings to cache',
      );
      when(() => mockRepository.importSettings(tImportData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tImportData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle partial import with missing fields', () async {
      // arrange
      const tPartialData = {
        'version': '1.0.0',
        'settings': {
          'themeMode': 'light',
          'scanTimeoutSeconds': 8,
          // Missing other fields - should use defaults
        },
      };
      final tPartialSettings = AppSettings.defaults().copyWith(
        themeMode: AppThemeMode.light,
        scanTimeoutSeconds: 8,
      );
      const tPartialParams = ImportSettingsParams(data: tPartialData);
      when(() => mockRepository.importSettings(tPartialData))
          .thenAnswer((_) async => Right(tPartialSettings));

      // act
      final result = await usecase(tPartialParams);

      // assert
      expect(result, Right(tPartialSettings));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.light);
          expect(settings.scanTimeoutSeconds, 8);
          // Other fields should have default values
          expect(settings.enableHapticFeedback, true);
          expect(settings.enableScanSound, true);
        },
      );
    });

    test('should handle import with extra unknown fields', () async {
      // arrange
      final tDataWithExtra = Map<String, dynamic>.from(tImportData);
      tDataWithExtra['unknownField'] = 'should be ignored';
      tDataWithExtra['futureFeature'] = {'enabled': true};
      final tParamsWithExtra = ImportSettingsParams(data: tDataWithExtra);
      
      when(() => mockRepository.importSettings(tDataWithExtra))
          .thenAnswer((_) async => const Right(tImportedSettings));

      // act
      final result = await usecase(tParamsWithExtra);

      // assert
      expect(result, const Right(tImportedSettings));
      verify(() => mockRepository.importSettings(tDataWithExtra)).called(1);
    });

    test('should handle empty settings data', () async {
      // arrange
      const tEmptyData = {
        'version': '1.0.0',
        'settings': <String, dynamic>{},
      };
      final tDefaultSettings = AppSettings.defaults();
      const tEmptyParams = ImportSettingsParams(data: tEmptyData);
      when(() => mockRepository.importSettings(tEmptyData))
          .thenAnswer((_) async => Right(tDefaultSettings));

      // act
      final result = await usecase(tEmptyParams);

      // assert
      expect(result, Right(tDefaultSettings));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          // Should have all default values
          expect(settings.themeMode, AppThemeMode.system);
          expect(settings.enableHapticFeedback, true);
          expect(settings.scanTimeoutSeconds, 6);
        },
      );
    });

    test('should pass correct import data to repository', () async {
      // arrange
      when(() => mockRepository.importSettings(any()))
          .thenAnswer((_) async => const Right(tImportedSettings));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.importSettings(tImportData)).called(1);
    });

    test('should handle malformed JSON-like data', () async {
      // arrange
      const tMalformedData = {
        'version': null,
        'settings': 'not_a_map',
        'corruptedField': ['array', 'when', 'object', 'expected'],
      };
      const tMalformedParams = ImportSettingsParams(data: tMalformedData);
      const tFailure = ValidationFailure(
        message: 'Malformed import data structure',
        statusCode: 400,
      );
      when(() => mockRepository.importSettings(tMalformedData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tMalformedParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tMalformedData)).called(1);
    });

    test('should handle permission failure during import', () async {
      // arrange
      const tFailure = PermissionFailure(
        message: 'Permission denied to import settings',
        statusCode: 403,
      );
      when(() => mockRepository.importSettings(tImportData))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.importSettings(tImportData)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}