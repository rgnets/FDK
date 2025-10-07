import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/features/settings/domain/usecases/get_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late GetSettings usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = GetSettings(mockRepository);
  });

  group('GetSettings', () {
    final tSettings = AppSettings.defaults();

    test('should get settings from repository successfully', () async {
      // arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Right<Failure, AppSettings>(tSettings));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right<Failure, AppSettings>(tSettings));
      verify(() => mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return custom settings when available', () async {
      // arrange
      final tCustomSettings = tSettings.copyWith(
        themeMode: AppThemeMode.dark,
        enableHapticFeedback: false,
        scanTimeoutSeconds: 10,
        enableOfflineMode: false,
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Right<Failure, AppSettings>(tCustomSettings));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right<Failure, AppSettings>(tCustomSettings));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          expect(settings.themeMode, AppThemeMode.dark);
          expect(settings.enableHapticFeedback, false);
          expect(settings.scanTimeoutSeconds, 10);
          expect(settings.enableOfflineMode, false);
        },
      );
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('should return SettingsFailure when repository fails', () async {
      // arrange
      const tFailure = SettingsFailure(
        message: 'Failed to retrieve settings',
        statusCode: 500,
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache access fails', () async {
      // arrange
      const tFailure = CacheFailure(
        message: 'Failed to read settings from cache',
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when settings data is corrupted', () async {
      // arrange
      const tFailure = ValidationFailure(
        message: 'Settings data is corrupted',
        statusCode: 400,
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const Left<Failure, AppSettings>(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left<Failure, AppSettings>(tFailure));
      verify(() => mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle settings with all configuration options', () async {
      // arrange
      const tAllConfigSettings = AppSettings(
        // Display Settings
        themeMode: AppThemeMode.light,
        showDebugInfo: true,
        enableHapticFeedback: false,
        
        // Scanner Settings
        scanTimeoutSeconds: 15,
        enableScanSound: false,
        enableContinuousScanning: true,
        
        // Network Settings
        apiTimeoutSeconds: 60,
        enableOfflineMode: false,
        cacheExpirationHours: 24,
        
        // Notification Settings
        enableNotifications: false,
        enableCriticalAlerts: true,
        enableInfoAlerts: false,
        
        // Data Settings
        autoSync: false,
        syncIntervalMinutes: 60,
        useCellularData: false,
        
        // Developer Settings
        enableLogging: true,
        showPerformanceOverlay: true,
        enableMockData: true,
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const Right<Failure, AppSettings>(tAllConfigSettings));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Right<Failure, AppSettings>(tAllConfigSettings));
      result.fold(
        (failure) => fail('Should not return failure'),
        (settings) {
          // Verify all settings are correctly returned
          expect(settings.themeMode, AppThemeMode.light);
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

    test('should call repository method once', () async {
      // arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Right<Failure, AppSettings>(tSettings));

      // act
      await usecase(const NoParams());

      // assert
      verify(() => mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}