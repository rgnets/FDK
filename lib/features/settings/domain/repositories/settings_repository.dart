import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings);
  Future<Either<Failure, void>> resetSettings();
  Future<Either<Failure, void>> clearCache();
  Future<Either<Failure, Map<String, dynamic>>> exportSettings();
  Future<Either<Failure, AppSettings>> importSettings(Map<String, dynamic> data);
}