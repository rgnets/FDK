import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/update_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late UpdateSettings usecase;
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AppSettings.defaults());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = UpdateSettings(mockRepository);
  });

  group('UpdateSettings', () {
    final tOriginalSettings = AppSettings.defaults();
    final tUpdatedSettings = tOriginalSettings.copyWith(
      themeMode: AppThemeMode.dark,
      enableHapticFeedback: false,
      scanTimeoutSeconds: 10,
    );
    final tParams = UpdateSettingsParams(settings: tUpdatedSettings);

    test('should update settings successfully', () async {
      // arrange
      when(() => mockRepository.updateSettings(tUpdatedSettings))
          .thenAnswer((_) async => Right<Failure, AppSettings>(tUpdatedSettings));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right<Failure, AppSettings>(tUpdatedSettings));
      verify(() => mockRepository.updateSettings(tUpdatedSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return updated settings with all changes applied', () async {
      // arrange
      when(() => mockRepository.updateSettings(tUpdatedSettings))
          .thenAnswer((_) async => Right<Failure, AppSettings>(tUpdatedSettings));

      // act
      final result = await usecase(tParams);

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.dark);
          expect(settings.enableHapticFeedback, false);
          expect(settings.scanTimeoutSeconds, 10);
          // Verify unchanged settings remain the same
          expect(settings.enableScanSound, tOriginalSettings.enableScanSound);
          expect(settings.apiTimeoutSeconds, tOriginalSettings.apiTimeoutSeconds);
        },
      );
    });

    test('should return SettingsFailure when update fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to update settings',
        statusCode: 500,
      );
      when(() => mockRepository.updateSettings(tUpdatedSettings))
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.updateSettings(tUpdatedSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when settings are invalid', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Invalid settings provided',
        statusCode: 400,
      );
      when(() => mockRepository.updateSettings(tUpdatedSettings))
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.updateSettings(tUpdatedSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache write fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to save settings to cache',
      );
      when(() => mockRepository.updateSettings(tUpdatedSettings))
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.updateSettings(tUpdatedSettings)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle updating single setting field', () async {
      // arrange
      final tSingleUpdate = tOriginalSettings.copyWith(
        themeMode: AppThemeMode.light,
      );
      final tSingleParams = UpdateSettingsParams(settings: tSingleUpdate);
      when(() => mockRepository.updateSettings(tSingleUpdate))
          .thenAnswer((_) async => Right<Failure, AppSettings>(tSingleUpdate));

      // act
      final result = await usecase(tSingleParams);

      // assert
      expect(result, Right<Failure, AppSettings>(tSingleUpdate));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.light);
          // All other settings should remain unchanged
          expect(settings.enableHapticFeedback, tOriginalSettings.enableHapticFeedback);
          expect(settings.scanTimeoutSeconds, tOriginalSettings.scanTimeoutSeconds);
        },
      );
    });

    test('should handle updating all settings at once', () async {
      // arrange
      const tCompleteUpdate = AppSettings(
        themeMode: AppThemeMode.dark,
        showDebugInfo: true,
        enableHapticFeedback: false,
        scanTimeoutSeconds: 15,
        enableScanSound: false,
        enableContinuousScanning: true,
        apiTimeoutSeconds: 60,
        enableOfflineMode: false,
        cacheExpirationHours: 24,
        enableNotifications: false,
        enableCriticalAlerts: true,
        enableInfoAlerts: false,
        autoSync: false,
        syncIntervalMinutes: 60,
        useCellularData: false,
        enableLogging: true,
        showPerformanceOverlay: true,
        enableMockData: true,
      );
      const tCompleteParams = UpdateSettingsParams(settings: tCompleteUpdate);
      when(() => mockRepository.updateSettings(tCompleteUpdate))
          .thenAnswer((_) async => const Right<Failure, AppSettings>(tCompleteUpdate));

      // act
      final result = await usecase(tCompleteParams);

      // assert
      expect(result, const Right<Failure, AppSettings>(tCompleteUpdate));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.dark);
          expect(settings.showDebugInfo, true);
          expect(settings.enableHapticFeedback, false);
          expect(settings.scanTimeoutSeconds, 15);
          expect(settings.enableScanSound, false);
          expect(settings.enableContinuousScanning, true);
          expect(settings.apiTimeoutSeconds, 60);
          expect(settings.enableOfflineMode, false);
          expect(settings.cacheExpirationHours, 24);
          expect(settings.enableNotifications, false);
          expect(settings.enableCriticalAlerts, true);
          expect(settings.enableInfoAlerts, false);
          expect(settings.autoSync, false);
          expect(settings.syncIntervalMinutes, 60);
          expect(settings.useCellularData, false);
          expect(settings.enableLogging, true);
          expect(settings.showPerformanceOverlay, true);
          expect(settings.enableMockData, true);
        },
      );
    });

    test('should pass correct settings to repository', () async {
      // arrange
      when(() => mockRepository.updateSettings(any()))
          .thenAnswer((_) async => Right<Failure, AppSettings>(tUpdatedSettings));

      // act
      await usecase(tParams);

      // assert
      verify(() => mockRepository.updateSettings(tUpdatedSettings)).called(1);
    });

    test('should handle settings with extreme values', () async {
      // arrange
      final tExtremeSettings = tOriginalSettings.copyWith(
        scanTimeoutSeconds: 1, // minimum
        apiTimeoutSeconds: 300, // maximum
        syncIntervalMinutes: 1, // minimum
        cacheExpirationHours: 168, // one week
      );
      final tExtremeParams = UpdateSettingsParams(settings: tExtremeSettings);
      when(() => mockRepository.updateSettings(tExtremeSettings))
          .thenAnswer((_) async => Right<Failure, AppSettings>(tExtremeSettings));

      // act
      final result = await usecase(tExtremeParams);

      // assert
      expect(result, Right<Failure, AppSettings>(tExtremeSettings));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.scanTimeoutSeconds, 1);
          expect(settings.apiTimeoutSeconds, 300);
          expect(settings.syncIntervalMinutes, 1);
          expect(settings.cacheExpirationHours, 168);
        },
      );
    });
  });
}